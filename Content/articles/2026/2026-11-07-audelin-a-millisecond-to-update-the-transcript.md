---
date: 2026-11-07 14:00
description: Audelin's live transcript used to rebuild the whole call whenever a word changed. Making the work follow the live tail brought a late view update from hundreds of milliseconds to about one.
tags: Audelin, Swift, macOS, Performance, Showcase
---

# Audelin: A Millisecond to Update the Transcript

[Audelin](https://github.com/igor1309/audelin) is a macOS app that transcribes both sides of a call and shows the text while people are speaking. The transcript grows throughout the call. Updating its last few words should stay cheap however much text came before them.

It didn't. At 1,620 entries, one update to the transcript view took 343 ms. The next words could arrive while the panel was still drawing the previous ones.

After the fixes, an optimized development build measured about a millisecond per view update, even at 6,000 entries. These are measurements from development branches, not a released version or a promise about recognition latency. The earlier and later runs also used different transcript sizes; this is the history of fixing a bottleneck, rather than a controlled speedup ratio.

## A new word rebuilt the old conversation

Every update made a fresh attributed transcript. Each entry needed its font, paragraph style and text. Applying it touched attributes in the unchanged prefix, invalidating layout that could have been kept. Sizing the view could then ask the text system to lay out the whole document.

The work grew with the conversation even when only the last word changed.

First, fonts and styles were built once, and unchanged text kept its attributes. Then the log began keeping the attributed paragraphs it had already built. An update rebuilt the changed rows and edited the text storage from the first change, leaving the earlier layout alone. The reducer kept rows ordered instead of sorting them again and rebuilt only the changed row.

One detail mattered more than it looked: the real panel could ask for the log's size without proposing a height. A shortcut that worked in a fixed-height test still laid out the whole call in the app. The sizing code and the test both had to follow that actual path.

## Measure a late update

The view load test preloads a transcript, changes its live tail and measures the update through layout. A retained optimized run reported:

| Transcript entries | Time per view update |
|---|---:|
| 20 | 0.49 ms |
| 800 | 0.69 ms |
| 6,000 | 1.15 ms |

That is the view alone. The model had its own growth: an intermediate optimized measurement was about 0.02 ms early and 0.6 ms at 1,620 entries. Small in absolute terms, but still roughly thirty times as much work late in the call.

That remaining work was addressed too. Updates now carry changed entries and say which text is final, so the reading model can keep settled history and work on the live tail. The later panel model test passed its late-against-early check. The intermediate model timings above describe the earlier stage, not the current result.

## The test must ask what the app asks

A rehearsal representing a three-hour call under Time Profiler exposed work growing with the transcript. It used fake recognisers and ran faster than real time: useful for finding expensive paths, unsuitable for claiming how far real speech recognition falls behind.

The fix needed a shorter, repeatable check. The [view load test](https://github.com/igor1309/audelin/blob/main/macos/Tests/PanelUITests/TranscriptLogLoadTests.swift) compares fixed transcript sizes, while the [panel model test](https://github.com/igor1309/audelin/blob/main/macos/App/Tests/ComposerTests/PanelLoadTests.swift) checks the path before drawing. Optimized test runs label their build so debug timings cannot quietly become app timings. Earlier row-count tests also checked that changing one row rebuilt one paragraph.

Reading how Zed, iTerm2 and Ghostty measure performance helped make the distinction clear: prepare the workload, drive the operation the app actually performs, and measure optimized code. A long profile finds a problem; a small test keeps asking the question that found it.

For this panel, that question is simple: when one word changes, how much of the conversation do we make the computer do again?
