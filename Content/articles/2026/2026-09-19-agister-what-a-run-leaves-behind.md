---
date: 2026-09-19 12:00
description: Every Agister run leaves a folder with the exact definitions by digest, inputs, permission plan, events and patches. Why the record matters more than the terminal output when agents do the work.
tags: Agister, Go, AI Agents, Observability, Showcase
---

# Agister: What a Run Leaves Behind

When an AI agent does a piece of work, the interesting questions come later. Why did the review miss that bug? Which prompt was it — the one before or after I edited it? Which model ran, at what effort, with what permissions? How much did it cost? Was the worktree clean when it started?

A terminal scrollback answers none of these. [Agister](https://igor1309.dev/agister/) is designed so that every run answers them from a folder on disk.

## The folder

Each run is a folder under `~/.agister/runs`, named by its start time in UTC and six random hex characters. Inside:

- **`record.json`** — the request, status and result, and every call that ended: its process, agent, inputs, permission plan, environment, the definition files by digest, the HEAD and content it left, its cost and its result. Child workflows appear under `children`, each with its params, inputs and output.
- **`events.jsonl`** — one line per event as it happens: a step started or reused, a tool call, a turn that went stale, a turn at capacity, a fallback to another agent, a branch taken with each condition it read, a repeat's pass and why it stopped.
- **`definitions/`** — the actual bytes of every settings file a call was made from, by digest.
- **`patches/`** — for calls that pinned a revision, the changes they made.

The record keeps the *definitions themselves*, not their names. Prompts change daily. A month later, "the code_review workflow" means something different; the digest and the bytes do not.

## Names you can grep

Steps have stable names that carry their position in the workflow. A step inside a repeat is named by its pass, `fix/2/1`; a step inside a child workflow is named under the item, `tests/revise/1`. The call, its record entry, its progress line, its events and its reuse all use that name. "What did the second pass of the fix loop do?" becomes a search, not an investigation.

## Records that pay for themselves

A record is not only for reading. Two flags use it:

- **`--reuse <run id>`** runs a request again but takes an earlier call in place of making it, when its process, agent, inputs, definitions and environment are the same and the worktree is as that call left it. Change one prompt late in a long workflow and only the affected steps run again.
- **`--continue <run id>`** goes on in the session of a one-step run's call.

Reuse is only safe because the record is precise. Without digests of definitions and a fingerprint of the worktree, "same as last time" would be a guess.

## What the record does not decide

Agister runs what settings define and records it. Committing, pushing, deciding what a review's findings mean, and asking the owner stay with whoever called it. That boundary is deliberate: the runner is the part that should be boring and exact, and judgement belongs to the caller — a person, or another agent with its own instructions.

Progress goes to stderr as it happens; the result goes to stdout as JSON; `agister runs export` copies a run out. Everything else is in the folder.

Read the [run architecture](https://igor1309.dev/agister/run-architecture/) for the full picture, or the code at [github.com/igor1309/agister](https://github.com/igor1309/agister).
