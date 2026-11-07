# Working on this blog

Posts live in `Content/articles/<year>/<date>-<slug>.md` and are built with Publish. A merge into `author` deploys to https://igor1309.dev.

## Merging is publishing

- Only the owner merges a post. An agent merges only when the owner's approval explicitly says to merge; a plain "Approved" or "looks good" is not that.
- Ask for approval with the desktop and iPhone screenshots from the PR's `Post checks` run (artifact `post-screenshots`), and only once every check is green.
- A post is done only after Deploy has run and the live URL has been checked on desktop and as an iPhone (see below).

## Publication time

The build leaves out any post whose `date` is still in the future, and the `Scheduled publish` workflow checks every hour and deploys once a post's time has passed. So a post can be merged ahead of time and goes live at its slot, within the hour.

- `date` is read as UTC (the runner's time zone): `date: 2026-11-08 14:00` goes live shortly after 14:00 UTC.
- Merging a post dated in the past publishes it at once.
- To render future posts locally, build with `PUBLISH_FUTURE_POSTS=1 swift run`. The PR checks do this.

## Post rules

- Public sources only. Link only to public pages: the project's public repo, its site, public docs. Never link to or name private repositories, internal trackers, issue ids, internal tools, or local paths. The `Post checks` guardrail catches some of these, not all.
- About 400–700 words.
- Follow the format of the existing posts: front matter with `date` (`YYYY-MM-DD HH:MM`), `description` and `tags`; an H1 title; a short opening; `##` sections; a closing line with the public links.
- New images are WebP, under 200 KB, in `Resources/images/<project>/`.

## Images in a post

Wrap every raw `<img>` in a `<div>`, with blank lines around the block:

```html
<div>
<img src="/images/<project>/<file>.webp" width="100%" title="..." />
</div>
```

A bare `<img>` line starts an HTML block that the Markdown parser does not close, so all the text after it, up to the next image, renders as raw Markdown. Close the tag too (`<img ... />`): `ContentLayoutTests` fails on an unclosed one.

## PR checks

`Post checks` runs on every pull request into `author` and must pass before merge. For each changed post it:

1. builds the site and runs the tests;
2. fails on banned content (private repo names, issue ids, internal tool names, local paths), missing front matter, and new images that are not WebP or are 200 KB or more;
3. fails on raw Markdown or HTML in the rendered article text outside `pre`/`code`, and on broken local links or images;
4. fails on any external link that does not return 2xx/3xx without logging in;
5. takes desktop (1440 px) and iPhone 15 screenshots (Puppeteer `KnownDevices`), uploads them as the `post-screenshots` artifact, and fails if the page scrolls sideways on the phone.

Run them locally:

```sh
PUBLISH_FUTURE_POSTS=1 swift run
python3 scripts/check_posts.py source   Content/articles/2026/<post>.md
python3 scripts/check_posts.py rendered Content/articles/2026/<post>.md
python3 scripts/check_posts.py links    Content/articles/2026/<post>.md
(cd scripts && npm install && npx puppeteer browsers install chrome)
(cd Output && python3 -m http.server 8123 &)
node scripts/screenshots.mjs http://localhost:8123 shots Content/articles/2026/<post>.md
```

## Checking the live post

Checks passing does not prove a post reads well. After Deploy, open the live URL at desktop width (about 1440 px) and as an iPhone, using real device emulation (Safari's Responsive Design Mode, Chrome DevTools device mode, or Puppeteer's `KnownDevices`). A plain headless `--window-size=390` is not a phone: Chrome clamps the width. Check that headings, lists, links and code are formatted, that no raw Markdown or HTML shows, that images load and fit, and that nothing scrolls sideways.
