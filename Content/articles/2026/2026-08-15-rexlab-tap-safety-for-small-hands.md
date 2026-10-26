---
date: 2026-08-15 12:00
description: Children tap twice, tap hard and drag when they mean to tap. How RexLab filters a child's double tap at the root of the app, without any screen knowing about it.
tags: RexLab, TypeScript, Touch, UX, Showcase
---

# RexLab: Tap Safety for Small Hands

Watch a four-year-old use a tablet and you will see the same thing again and again: a confident double tap on a button that wanted one. On most screens that is harmless. In a quiz it answers the next question before the child has seen it. On a result screen it skips the celebration the child was waiting for.

[RexLab](https://rexlab.enoa.ai) handles this once, at the root of the app, with a small pure function: [`src/tapFilter.ts`](https://github.com/igor1309/rexlab/blob/main/src/tapFilter.ts).

## The rule

A press that comes less than half a second after a tap's release, and less than 100 CSS pixels from it, is that tap's second. It is swallowed, together with the rest of its touch and the tap it would make. A drag counts as a drag once a finger has moved 8 pixels, and a drag opens no window.

```ts
export const TAP_LIMITS: TapLimits = { window: 500, reach: 100, drag: 8 };
```

Two refinements make it feel right:

- **A burst counts once.** A swallowed press keeps the window open from its own release. Three quick taps are one tap, not a tap and then a fresh one.
- **Keys are never filtered.** A tap made by a keyboard is always intended, so it goes straight through.

## Why at the root

The tempting fix is a debounce on each button. It spreads timing logic across every screen and fails the moment a new screen forgets it. Worse, a second tap often lands on a *different* button: the first tap changed the screen, and the second hits whatever appeared under the finger.

So the filter sits where every input passes: the root of the app sees each press, move, release and cancel, with its pointer id, position and the time it happened — the time of the event, never the time a handler runs. It returns one boolean: does this input go on to the app? The filter knows nothing about screens. Screens know nothing about the filter.

## Pure and testable

`tapFilter` is a closure over a few bits of state — the last release, the pointers pressed, the pointers swallowed — and a function from an input to a decision. No DOM, no timers, no React. That makes the awkward cases easy to state as tests:

- two fingers at once are two pointers, not a double tap;
- a cancelled touch clears the window;
- a press far from the last tap is a new tap, however quick;
- a drag in the sorting game is never mistaken for a second tap.

This was a good shape for working with agents too. The scenario says what a child does; the function has one job; the tests feed it sequences of inputs and check the answers. An agent can change the internals freely, and the tests say whether a child would notice.

## Small detail, large effect

Nobody will praise an app because a double tap did nothing. But a child who keeps skipping screens by accident decides the app is "broken" and walks away. Tap safety is one of those invisible features that decide whether a children's app is used at all.

Try it with your own double tap at [rexlab.enoa.ai](https://rexlab.enoa.ai); the code is at [github.com/igor1309/rexlab](https://github.com/igor1309/rexlab).
