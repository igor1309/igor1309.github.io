# Working on this blog

Posts live in `Content/articles/<year>/<date>-<slug>.md` and are built with Publish. A merge into `author` deploys straight to https://igor1309.dev. There is no PR CI and no scheduling: a post is live as soon as it is merged, whatever its `date`.

## Images in a post

Wrap every raw `<img>` in a `<div>`, with blank lines around the block:

```html
<div>
<img src="/images/<project>/<file>.webp" width="100%" title="...">
</div>
```

A bare `<img>` line starts an HTML block that the Markdown parser does not close, so all the text after it, up to the next image, renders as raw Markdown.

## Rendering check (mandatory before merge)

Merging does not prove a post renders, and the deploy passing does not either. Before you ask for approval or merge:

1. Build locally with `swift run`, then serve `Output/` (for example `python3 -m http.server`).
2. Open the post at desktop width (about 1440 px) and as an iPhone, using real device emulation (Safari's Responsive Design Mode, Chrome DevTools device mode, or Puppeteer's `KnownDevices`). A plain headless `--window-size=390` is not a phone: Chrome clamps the width.
3. Check that headings, lists, links and code are formatted, that no raw Markdown or HTML shows, that the images load and fit, and that nothing scrolls sideways on the phone.
4. Attach the desktop and iPhone screenshots to the PR or issue where approval is asked.

After merge, check the live URL the same way once the Deploy run passes.
