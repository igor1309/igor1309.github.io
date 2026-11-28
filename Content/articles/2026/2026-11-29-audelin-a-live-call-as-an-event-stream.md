---
date: 2026-11-29 19:00
description: Audelin gets help during a live call without changing the app. A small program outside it turns the growing transcript into a stream of three events, with no model and no policy inside.
tags: Audelin, macOS, AI, Go, Showcase
---

# Audelin: A Live Call as an Event Stream

Notes after a call are useful. Help during the call is better: a hint when someone asks a question your project already answers, a correction when a claim contradicts a decision you made. Silence otherwise.

[Audelin](https://github.com/igor1309/audelin) records both sides of a call and writes a live transcript on the Mac. This week it got the plumbing for a live call assistant, and the app itself did not change at all.

## Why not let the model read the file

The live transcript is a file that grows while the call goes on. The obvious assistant rereads it on every step. That repeats the same work again and again, and the cost grows with the call.

The next idea is to let the model keep its place: read the new part, decide where a window starts and ends. That spends tokens and latency on mechanics that need no model at all. Cutting text into windows is a job for plain code.

So the decision went the other way.

## Three events, no model, no policy

A separate source, outside the app, reads the call's existing transcript and emits a stream of three events over server-sent events:

- `chunk`: the next window of text, cut by a size and an overlap the client asks for, such as three minutes overlapping by one;
- `noCall`: nothing is being recorded;
- `callEnded`: the call is over.

The source holds no model and no policy. What to do with a chunk, summarise it, offer a hint or stay quiet, is each client's choice. Because nothing in the source calls a model, a silent call costs nothing.

Clients depend on an abstract event source, not on Audelin, and are tested against a fake one.

## What the decision costs

Two trade-offs were taken on purpose.

The recent tail is not reconciled. The last rows of a live transcript can still be revised. A chunk is sent as the file shows it, and later revisions of text already sent are not sent again. Over a whole call the difference is small.

The transcript format becomes a contract. An outside reader now depends on how Audelin writes the file, so regression tests on that format keep the reader true. The same contract would bind a source built into the app later.

## Built as small Go programs

The source and its client are small Go programs: an iterator over the live call's windows, a reader that finds the live call and reads its transcript, an SSE server that listens only on loopback, a client that tells "not running", "refused", "lost" and "ended" apart, and a follow client that prints one record per event. Every test runs on a fake clock and temporary folders, with no waits. The reader's fixtures are Audelin's own renderings, checked byte for byte from the app's side.

Code review then found real defects, and each fix came with a regression test:

- transcript rows now carry a stable segment ID, so the reader stops guessing which part is which from time and words;
- following no longer ends when it reads a transcript Audelin is still creating; discovery retries;
- the last window holds every unsent part before `callEnded`;
- malformed metadata is a failed read, not a call end.

A later test proves that the follow client writes each record as exactly one line, and writes it before it asks for the next event.

## The experiment that left the feed

One question stayed open: how big should a window be? An experiment replayed two generated calls, an hour and a quarter of an hour long, with facts fixed in advance, and compared rereading the whole call against rolling summaries over several window sizes.

No strategy missed a fact. Rereading used about four times the input tokens of the rolling three-minute window on the long call. The default of three minutes overlapping by one stayed.

Then the experiment itself was removed from the feed. Its command called a real model from the feed's code, and that broke the rule the feed was built on. Model runs belong to evaluation work. The report keeps the results; the feed keeps no model.

An earlier post on the transcript itself is [Where the Transcript Goes](/articles/2026/2026-11-14-audelin-where-the-transcript-goes/).

Audelin's code, screenshots and build instructions are in [its public repository](https://github.com/igor1309/audelin).
