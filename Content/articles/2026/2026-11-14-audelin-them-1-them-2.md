---
date: 2026-11-14 19:00
description: After every call, Audelin splits the far side of the transcript into separate remote speakers, numbers them Them 1, Them 2, and names each one only from their own introduction.
tags: Audelin, macOS, AI, Showcase
---

# Audelin: Them 1, Them 2

[Audelin](https://github.com/igor1309/audelin) records a call as two sides: your microphone, and everything else. Everything else used to be one label, “Them”. On a call with three other people, that is one voice in the transcript for three people, and a summary that cannot say who promised what.

Now, after every call, the far side is split into its speakers on the Mac, and the transcript, the notes and the panel all use the split.

## Why “Them” was not enough

The notes prompt had to warn the model that a remote label could hide several people, and so the model could not tie a decision or a task to anyone on the far side. A transcript that says `Them 1` and `Them 2` gives it something to hold on to. The prompt now says so: a plain “Them” can still be several people, while “Them 1”, “Them 2”… are separate speakers, though the split can be wrong.

The labels follow the order people first spoke, and the file keeps a short list of speakers at the top. A call with only one remote speaker stays plain “Them”: a number with nothing to tell it apart from adds noise, not information. If a second voice turns up, the rows already written are relabelled.

## Diarization after the call

Telling voices apart in a recording is called diarization. Audelin runs an on-device diarization model over the call's recorded track once the call ends, and gives each row of the far side to the speaker whose turns overlap it most.

That one pass now does two jobs. On a Zoom call it also confirms the names Zoom showed during the call, so a confirmed speaker is listed by name instead of a number. Before, those were two separate runs over the same audio.

The model is large, and nobody wants to wait for a download when a call has just ended. It now starts loading when a call opens, is kept for every later call, and a failed load is simply tried again next time.

Diarizing is also its own phase in the state machine that hands a finished call on to cleanup and notes. The file closes, the phase starts, and only once the speakers are found, or the pass has failed, is the transcript offered for notes. Cleanup and the summary wait for that phase and read the speakers from it, so the notes see the same `Them 1` and `Them 2` as the file. If the pass fails, nothing is lost: the far side stays plain “Them”, as before.

## Names from introductions

A number is better than nothing; a name is better still. People often introduce themselves at the start of a call, so Audelin asks the model to name each remote speaker, with the quote and time of the line that names them, and then checks the answer against the transcript before keeping anything.

The check is strict on purpose. A speaker is named only from their own introduction. Someone who is addressed by name, “Anna, I agree”, does not become Anna. A speaker who gives two different names gets neither. And a speaker cannot borrow another person's introduction. Anything the check rejects stays a number.

## What the panel shows

The floating panel shows the live transcript while the call runs, with the far side as one speaker. When the call ends and the pass finishes, an open panel switches over: each remote speaker's rows take their own colour, from three new colour tokens next to the existing one, and a caption gives the speaker's name or number where the speaker changes. Live guesses are still drawn as tentative; numbers and confirmed names are not.

The interface follows the system language, so a Russian system shows “Собеседник 2” instead of “Them 2”.

## Next

All of this happens after the call. Telling who is speaking while the call is still running needs a different witness than the audio, and a coming post reads names from the call page in the browser.

The recorder, the transcript format and the diarization code are in [Audelin's public repository](https://github.com/igor1309/audelin).
