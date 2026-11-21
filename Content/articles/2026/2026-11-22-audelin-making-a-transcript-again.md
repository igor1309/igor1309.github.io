---
date: 2026-11-22 19:00
description: Audelin can now make a call's transcript again from its recorded tracks, keeps the one it replaced, restores it in one step, and marks notes made from a transcript that is no longer current.
tags: Audelin, macOS, AI, Showcase
---

# Audelin: Making a Transcript Again Without Losing the One You Had

A call's transcript is made once, while the call happens. Then the recognizer gets better, or the split of the far side into speakers went wrong, and the recording is still there. Why not make the transcript again?

Because it is scary. The transcript you have might be the better one. The notes were written from it. Speaker names came from the call app and cannot be read again. Redoing a transcript is only useful if nothing you had can be lost on the way.

[Audelin](https://github.com/igor1309/audelin) records both sides of a call and transcribes them on the Mac. This week it learned to make a call's transcript again, and most of the work went into the guarantees around it.

## First, know where a transcript came from

Before you decide to redo a transcript, you need to know what made it. So a transcript file now starts with its origin as front matter: the Audelin version and build, the speech model that heard each side, whether the microphone side was cleaned of echo, and which diarizer split the far side.

The origin is saved in the same write as the text it describes, so it is always true of the words on disk. Each finishing stage is recorded with its outcome: done, nothing kept, or skipped because the app was quitting. A merged call lists the origin of each original call, in order. A transcript made before this feature has no origin, and Audelin says unknown rather than guessing.

## Making it again

For a single call, Audelin hears both tracks again, splits the far side, cleans the microphone side, and publishes one new transcript. Progress is one fraction from the first track to the last.

A merged call is made again from its original calls, merges of merges included, and joined the way merging joins them. If one original call cannot be heard, the run fails and names that call. A split or clean that keeps nothing still finishes, as it does after a live call.

Starting a recording stops the run: a call to record matters more than a call already kept.

## Keeping the previous one

The replaced transcript is not thrown away. It stays as a second file beside the current one in the call's folder, kept exactly, with the origin it had. You can compare the two in any editor.

At most one previous transcript is kept: the exact text you had before the last replacement. Restoring it from the call's row menu swaps the two in one step, so neither is lost, and no end of the run, a crash included, leaves a mix of old and new. Cancel or quit before the swap keeps the old pair.

## Notes that tell you they are stale

Making notes sends the transcript to a model provider, and that is the user's choice. So replacing or restoring a transcript never starts new notes by itself.

Instead, notes remember which transcript they were made from. When it is no longer current, the notes are marked; restore it and the mark goes away. Notes made before Audelin tracked this are marked once the transcript is replaced, and stay marked until made again.

## Names move only one-to-one

Names the call app showed during the call cannot be read from audio. A name moves from an old speaker to a new one only when each spends more than half of its own time overlapping the other. Any other match stays unnamed: no name is better than a wrong one. The microphone side is never named; it is yours.

Re-recognition, merging and restoring exclude each other, so two of them never change the same call at once.

## Spec first, one component at a time

The feature went from a user spec to an architecture, then component specs, then one commit per component: the transcript pair, name carry, re-recognition, the run and the restore, the notes' mark, the calls list. It ended with a live test of the composed app.

How speakers get their names in the first place is in [Who Is Speaking on the Call](/articles/2026/2026-11-21-audelin-who-is-speaking-on-the-call/).

The recording and live-transcript code, screenshots and build instructions are in [Audelin's public repository](https://github.com/igor1309/audelin).
