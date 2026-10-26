---
date: 2026-08-22 12:00
description: FolioTell is an offline iPhone app that reads Markdown and plain-text files aloud. Why it exists, and why it has no account, no backend and no network.
tags: FolioTell, iOS, SwiftUI, Speech, Showcase
---

# FolioTell: an App That Reads Your Notes Aloud

I write a lot in Markdown: notes, drafts, research summaries, documentation. Much of it I would happily *listen* to on a walk instead of reading at a desk. Yet every way of doing that was awkward. Screen readers are built for navigation, not for long-form listening. Text-to-speech services want an upload, an account and a subscription. Pasting into a "read this" app loses the file and my place in it.

[FolioTell](https://foliotell.pages.dev) is the small app I wanted: open a `.md` or `.txt` file where it already lives, press Play, and listen. The source is at [github.com/igor1309/foliotell](https://github.com/igor1309/foliotell).

## What it does

- **Opens files where they are**: On My iPhone, iCloud Drive or any Files provider, through the system document browser. No import, no copy.
- **Reads them on the device** with Apple's speech synthesis. The voice follows the document's language — English or Russian — or you choose one.
- **Playback controls**: play and pause, previous or next sentence, stop, start over, and speeds from 1x to 2x.
- **Remembers where you stopped** in each document.
- **Handles front matter**: a YAML header at the top of a Markdown file is skipped, or read aloud if you prefer.
- **Suggests a better voice**: when only a standard-quality voice is installed for a language, it tells you where in Settings to download an Enhanced or Premium one.

## What it does not do

FolioTell is read-only and offline. There is no account, no backend, no analytics, no subscription and no network access at all.

That list is the product as much as the features are. Notes are personal. A tool that reads them should not need to see them anywhere but on the phone. Apple's on-device voices have become good enough — especially the Enhanced and Premium ones — that the cloud adds little for this job.

Being read-only also keeps the app honest about its scope. It does not try to be an editor or a notes app. Your files stay in whatever app or sync service you already use; FolioTell is just a speaker.

## Markdown is not prose

Reading a Markdown file aloud naively is unpleasant: "hash hash Introduction", "asterisk asterisk important asterisk asterisk", "dash dash dash". Before text reaches the synthesizer, FolioTell strips heading markers, list markers, quote markers and inline emphasis, drops delimiter-only lines like `---`, and collapses blank lines. Code inside fences is kept as written, because there the characters *are* the content.

It is a small, pure function with its own tests, and it makes the difference between "a text-to-speech demo" and something you can listen to for half an hour.

## How it is built

Swift 6 and SwiftUI on iOS 26: a `DocumentGroup` app over `AVSpeechSynthesizer`. The playback logic is a separate library, `FolioTellCore`, made of pure reducers and effect handlers, with the speech engine and storage behind injected adapters. 196 Swift Testing tests cover it, and Maestro flows drive the playback controls on a simulator. Like the other projects in this series, it was built with AI coding agents working from specs and tests.

The next two posts look inside: the reducer architecture, and the surprisingly tricky problem of knowing *where* in the text you are.

Website: [foliotell.pages.dev](https://foliotell.pages.dev). Code: [github.com/igor1309/foliotell](https://github.com/igor1309/foliotell).
