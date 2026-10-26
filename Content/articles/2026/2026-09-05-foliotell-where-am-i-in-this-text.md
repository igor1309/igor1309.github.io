---
date: 2026-09-05 12:00
description: Skipping by sentence and resuming where you stopped sound trivial. In FolioTell they meant mapping UTF-16 offsets from the speech engine back to sentences in the original text.
tags: FolioTell, Swift, Unicode, Speech, Showcase
---

# FolioTell: Where Am I in This Text?

Two features of [FolioTell](https://foliotell.pages.dev) look like one-liners on a product list: "previous or next sentence" and "remembers where you stopped". Both depend on one question the app has to answer all the time: *where in the text is the voice right now?*

## The engine speaks in UTF-16

`AVSpeechSynthesizer` reports progress through a delegate callback that says which range of the utterance it is about to speak. That range is an `NSRange`, which means UTF-16 code units, relative to the *utterance*, not to the document.

Swift strings, meanwhile, are collections of grapheme clusters. An emoji, a combining accent or a Cyrillic letter with a diacritic can be one `Character` and several UTF-16 units. Mix the two and positions drift: after a few non-ASCII characters, "resume here" lands mid-word.

FolioTell picks one unit and sticks to it. Every position in the playback state is a UTF-16 offset into the speech text: where the current utterance started, and how far it has been spoken. When a word-boundary callback arrives, the reducer adds the utterance-relative offset to the utterance's start and clamps the result to the text's length. Converting to `String.Index` happens only at the edges, when Foundation needs one.

## Sentences from Foundation, not from regex

"Next sentence" needs a definition of a sentence. A regex on full stops fails quickly: abbreviations, decimals, ellipses, quotes, and Russian punctuation rules all disagree with it.

Instead, `PlaybackPositionMapping` asks Foundation:

```swift
text.enumerateSubstrings(
    in: text.startIndex..<text.endIndex,
    options: [.bySentences, .substringNotRequired]
) { _, sentenceRange, _, stop in ... }
```

and converts each sentence's start to a UTF-16 offset. From there the rules are simple:

- **Next** is the first sentence that starts after the one containing the current offset, or nothing at the end.
- **Previous** is the start of the sentence *before* the one containing the current offset, or the beginning. Like most audio players, a tap goes to the previous sentence, not to the start of the current one.

A jump then restarts the utterance from that offset with a new utterance token, so callbacks from the abandoned utterance are ignored (the previous post explains the token).

## Resuming after a relaunch

There is a wrinkle: the voice speaks the *speech text* — the Markdown after heading, list and emphasis markers are stripped — while the file on disk still has them. An offset in one is not an offset in the other, and the speech text changes whenever the normalization rules or the front matter setting do.

So FolioTell saves its place as an anchor in the *original document*. When it derives the speech text, it also keeps, for every unit of speech text, the source offset it came from. Saving maps the spoken offset back to the document; reopening maps the anchor forward to the first speech offset at or after it, and then to the start of the sentence containing it. A slightly earlier point is better than starting mid-sentence when you have forgotten the context. The sentence starts are kept sorted, so the lookup on every spoken word is a binary search.

## Tested in two languages

The tests for this part are deliberately bilingual: English and Russian sentences, front matter skipped or read, each case pinning an offset and checking the jump or the resume. It is the kind of code where an agent's confident "this should work" means little and a failing test with a Cyrillic sentence means a lot.

Code: [github.com/igor1309/foliotell](https://github.com/igor1309/foliotell). App: [foliotell.pages.dev](https://foliotell.pages.dev).
