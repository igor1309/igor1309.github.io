#!/usr/bin/env python3
"""PR checks for blog posts.

Usage: check_posts.py <command> <changed post .md files...>
Commands: source (guardrail, front matter, images), rendered (Output/ HTML),
links (external links reachable). Prints every failure, exits 1 on any.
"""
import html as htmllib
import re
import subprocess
import sys
import urllib.error
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

OUTPUT = Path("Output")
RESOURCES = Path("Resources")
WEBP_LIMIT = 200 * 1024

FORBIDDEN = [
    (re.compile(r"ai-labs", re.I), "mentions ai-labs"),
    (re.compile(r"\b(LAB|MUL)-\d+\b"), "contains a LAB-/MUL- issue id"),
    (re.compile(r"multica", re.I), "mentions Multica"),
    (re.compile(r"(/Users/|/home/[a-z]|~/[A-Za-z]|[A-Z]:\\\\|file://)"), "contains a local path"),
]
RAW = [
    (re.compile(r"(^|\s)#{1,6} \S"), "raw Markdown heading"),
    (re.compile(r"\*\*\S"), "raw Markdown bold"),
    (re.compile(r"\]\((https?://|/)"), "raw Markdown link"),
    (re.compile(r"<img\b", re.I), "raw <img> as text"),
    (re.compile(r"<div\b", re.I), "raw <div> as text"),
]


def output_page(post: Path) -> Path:
    # Content/articles/2026/<slug>.md -> Output/articles/2026/<slug>/index.html
    rel = post.relative_to("Content").with_suffix("")
    return OUTPUT / rel / "index.html"


def front_matter(text: str):
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    fields = {}
    for line in m.group(1).splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            fields[k.strip()] = v.strip()
    return fields, text[m.end():]


def added_files():
    base = subprocess.run(["git", "merge-base", "HEAD", "origin/author"],
                          capture_output=True, text=True).stdout.strip()
    if not base:
        return set()
    out = subprocess.run(["git", "diff", "--name-only", "--diff-filter=A", base, "HEAD"],
                         capture_output=True, text=True).stdout
    return {Path(p) for p in out.split()}


def check_source(posts):
    errors = []
    for post in posts:
        text = post.read_text()
        fields, body = front_matter(text)
        if fields is None:
            errors.append(f"{post}: no front matter")
            fields = {}
        for key in ("date", "description", "tags"):
            if not fields.get(key):
                errors.append(f"{post}: front matter has no `{key}`")
        if fields.get("date") and not re.fullmatch(r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}", fields["date"]):
            errors.append(f"{post}: date must look like 2026-11-08 14:00")
        for n, line in enumerate(text.splitlines(), 1):
            for rx, why in FORBIDDEN:
                if rx.search(line):
                    errors.append(f"{post}:{n}: {why}: {line.strip()[:120]}")
        for n, line in enumerate(body.splitlines(), 1):
            if re.match(r"\s*<img\b", line) and not line.rstrip().endswith("/>"):
                errors.append(f"{post}: unclosed <img> (use <img ... />)")
    for f in sorted(added_files()):
        if f.parts[:2] == ("Resources", "images") and f.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}:
            if f.suffix.lower() != ".webp":
                errors.append(f"{f}: new images must be WebP")
            elif f.stat().st_size > WEBP_LIMIT:
                errors.append(f"{f}: {f.stat().st_size // 1024} KB, limit is 200 KB")
    return errors


class Article(HTMLParser):
    """Collects article text outside pre/code and every local link."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.depth = 0       # inside <article>
        self.skip = 0        # inside pre/code/script/style
        self.text = []
        self.links = []

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "article":
            self.depth += 1
        if tag in ("pre", "code", "script", "style"):
            self.skip += 1
        for key in ("href", "src"):
            if a.get(key):
                self.links.append(a[key])

    def handle_endtag(self, tag):
        if tag == "article":
            self.depth -= 1
        if tag in ("pre", "code", "script", "style") and self.skip:
            self.skip -= 1

    def handle_data(self, data):
        if self.depth and not self.skip:
            self.text.append(data)


def local_target(link: str, page: Path):
    link = link.split("#")[0].split("?")[0]
    if not link or re.match(r"^[a-z]+:", link) or link.startswith("//"):
        return None
    target = OUTPUT / link.lstrip("/") if link.startswith("/") else page.parent / link
    return target / "index.html" if target.suffix == "" else target


def check_rendered(posts):
    errors = []
    for post in posts:
        page = output_page(post)
        if not page.is_file():
            errors.append(f"{post}: not rendered at {page}")
            continue
        p = Article()
        p.feed(page.read_text())
        if not p.text:
            errors.append(f"{page}: no <article> text")
        for line in "".join(p.text).splitlines():
            for rx, why in RAW:
                if rx.search(line):
                    errors.append(f"{page}: {why}: {line.strip()[:120]}")
        for link in p.links:
            target = local_target(link, page)
            if target and not target.is_file():
                errors.append(f"{page}: broken local link {link}")
    return errors


def check_links(posts):
    errors = []
    seen = set()
    for post in posts:
        _, body = front_matter(post.read_text())
        body = re.sub(r"```.*?```", "", body, flags=re.S)
        body = re.sub(r"`[^`\n]*`", "", body)  # inline code is not a link
        for url in re.findall(r"https?://[^\s)\"'<>`]+", body):
            url = htmllib.unescape(url).rstrip(".,;:")
            if url in seen:
                continue
            seen.add(url)
            status = fetch(url)
            print(f"{status} {url}")
            if not isinstance(status, int) or not 200 <= status < 400:
                errors.append(f"{post}: {url} -> {status}")
    return errors


def fetch(url):
    headers = {"User-Agent": "Mozilla/5.0 (link check for igor1309.dev)"}
    for method in ("HEAD", "GET"):
        try:
            req = urllib.request.Request(url, method=method, headers=headers)
            with urllib.request.urlopen(req, timeout=20) as r:
                return r.status
        except urllib.error.HTTPError as e:
            if method == "GET" or e.code not in (403, 405, 404, 501):
                return e.code
        except Exception as e:  # noqa: BLE001
            if method == "GET":
                return f"error: {e}"
    return "error"


def main():
    command, files = sys.argv[1], [Path(f) for f in sys.argv[2:]]
    posts = [f for f in files if f.suffix == ".md" and f.is_file()]
    errors = {"source": check_source, "rendered": check_rendered, "links": check_links}[command](posts)
    if errors:
        print("\n".join(errors))
        sys.exit(1)
    print(f"{command}: {len(posts)} post(s) OK")


if __name__ == "__main__":
    main()
