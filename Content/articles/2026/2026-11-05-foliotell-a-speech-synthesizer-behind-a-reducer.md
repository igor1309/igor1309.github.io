---
date: 2026-11-05 12:00
description: AVSpeechSynthesizer is asynchronous and full of late callbacks. How FolioTell keeps playback correct with pure reducers, effect handlers and utterance tokens.
tags: FolioTell, Swift, Architecture, Reducers, Testing, Showcase
---

# FolioTell: a Speech Synthesizer Behind a Reducer

On the surface a text-to-speech player has a handful of buttons: play, pause, stop, skip, speed. Underneath, `AVSpeechSynthesizer` is an asynchronous engine that reports back through delegate callbacks — a word is about to be spoken, an utterance finished, an utterance was cancelled — and those callbacks arrive *after* you already changed your mind.

Tap "next sentence" while a word is being spoken and the synthesizer may still tell you about the old utterance: one more word boundary, then a cancellation. Handle those naively and the player jumps back, stops when it should be speaking, or resumes a word too early. [FolioTell](https://foliotell.pages.dev) treats this as a state machine problem.

## Events in, state and effects out

The playback logic lives in `FolioTellCore`, a library with no UIKit, no SwiftUI and no AVFoundation. Its core is a reducer:

```swift
func reduce(_ state: State, _ event: Event) -> (State, Effect?)
```

Every button tap is an event (`primaryTapped`, `stopTapped`, `jumpToNextSentenceTapped`, `speedChanged`, …), and so is every synthesizer callback (`willSpeakRange`, `utteranceDidFinish`, `utteranceDidCancel`, `pauseResolved`, …). The reducer computes the next state and, optionally, an effect: start an utterance, restart it from an offset, pause, deactivate the audio session. An effect handler performs it against the real engine through an injected adapter.

A small runtime, `RxViewModel`, ties it together on the main actor: events enter one funnel, the reducer runs, effects may dispatch follow-up events, and those are processed in FIFO order. Nothing re-enters the reducer while it is running.

## Utterance tokens

The key idea for the late-callback problem is a token. Every time playback starts a new utterance — on play, a jump, a speed or voice change, start over — the reducer increments `utteranceToken` and stamps the new command with it. Every callback carries the token of the utterance it is about.

The reducer then accepts a callback only when the token matches the current session:

```swift
case let .speaking(session) where session.utteranceToken == utteranceToken:
```

Anything else is stale — a replaced utterance, a stop already applied — and is ignored. Changing speed mid-sentence becomes simple: bump the token, restart from the current offset, and let the old utterance's cancellation fall on the floor.

One subtle case is documented right in the code: a word-boundary callback can land just *after* an accepted pause. The paused state must still track it, or resume would repeat or skip a word.

## Why this shape

Three reasons, in order of importance:

1. **Testability.** Every race above is a sequence of events. A test feeds the reducer "play, word at 40, next tapped, word at 52 with the old token, cancel with the old token" and checks the state. No simulator, no timing. Most of the 196 tests look like that.
2. **Working with agents.** A reducer gives an agent a narrow, well-tested surface. It can add a feature — say, start over — by adding an event and a case, and the existing tests say whether it broke a race it never thought about.
3. **Replaceable edges.** The synthesizer and the position store are adapters. The app wires real ones; tests wire fakes.

Remembering where you stopped is a second reducer with the same shape, `PlaybackPosition`, so the two concerns never tangle.

Code: [github.com/igor1309/foliotell](https://github.com/igor1309/foliotell). App: [foliotell.pages.dev](https://foliotell.pages.dev).
