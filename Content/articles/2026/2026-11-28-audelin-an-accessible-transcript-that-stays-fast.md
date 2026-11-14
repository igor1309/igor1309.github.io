---
date: 2026-11-28 12:00
description: Audelin's live transcript panel now tells VoiceOver who said each line. The row elements are built only when accessibility asks for them, so a late update in a long call stays as cheap as before.
tags: Audelin, Swift, macOS, Accessibility, Performance, Showcase
---

# Audelin: An Accessible Transcript That Stays Fast

[Audelin](https://github.com/igor1309/audelin) is a macOS app that transcribes both sides of a call and shows the text in a small panel while people speak. An [earlier post](/articles/2026/2026-11-07-audelin-a-millisecond-to-update-the-transcript/) described how an update late in a long call went from hundreds of milliseconds to about one. This one is about making the same panel readable by VoiceOver without giving that back.

## One text view, many lines

The panel draws the whole transcript in a single text view. That is what keeps it fast: an update edits the text from the first change and leaves the rest of the layout alone. To accessibility, though, a single text view is one long string. VoiceOver could read the words but not where one person stopped and the next began, or who was speaking.

So each row of the panel became an accessibility element of its own. Its label is the row's text, settled words and the words still arriving together. Its value is the speaker's name when the app knows it: a name from the call in the browser, shown for every row that speaker says. The local user's rows carry no name. Each element also has a stable identifier, `panel.row.<id>`, so a script can find a row the way VoiceOver does.

A [panel test](https://github.com/igor1309/audelin/blob/main/macos/Tests/PanelUITests/TranscriptLogTests.swift) hosts four rows, two of them from the same remote speaker, and checks the elements' identifiers, texts and names in order.

## Built when asked

The first version rebuilt every row's element on each update. That is the pattern the earlier post removed from drawing: work that grows with the conversation when only the last word changed. In a long call, every new word would have made one accessibility object per row, whether or not anything was listening.

The fix keeps only the current lines. An update drops the built elements and tells accessibility the layout changed. The elements are made the next time accessibility asks the view for its children, and kept until the lines change again. With VoiceOver off, nothing asks, and an update costs what it did before.

## The same check as before

The [view load test](https://github.com/igor1309/audelin/blob/main/macos/Tests/PanelUITests/TranscriptLogLoadTests.swift) hosts the panel with a long transcript, changes the live tail a few times and measures each update through layout. It fails if an update late in the call costs more than three times one early. The row elements live in the view it hosts, and nothing in the test asks for them, so it measures the update path, which builds none. An optimized local run of the committed test reported, per case, an early and a late transcript:

| Case | 20 entries | Long transcript |
|---|---:|---:|
| 800 entries | 1.08 ms | 1.37 ms |
| 6,000 entries | 1.13 ms | 1.47 ms |

About 0.04 ms of each update is building the changed rows; the rest is layout. These are local timings on one Mac, not CI measurements. The test asks the ratio, not the absolute time, and these runs are not comparable to the earlier post's table.

## Read by the same API

The rows are also how Audelin's nightly live test checks the app. It launches the built app on fixture data, replays a recorded call with two remote speakers and reads the panel over the accessibility API by those identifiers, asserting each row's text and name. Whatever VoiceOver reads, that test reads too.

<div>
<img src="/images/audelin/panel-voiceover.webp" width="100%" title="VoiceOver reading a panel row with its speaker's name" />
</div>

Making a fast view accessible did not need a second view. It needed the accessibility tree to follow the same rule as the drawing: when one word changes, do not rebuild the conversation.

Source: [igor1309/audelin](https://github.com/igor1309/audelin).
