---
date: 2026-11-09 12:00
description: Agister is a Go command-line runner for AI-agent work defined in settings files — agents, processes and workflows — with a record of every run. What it is and why I built it.
tags: Agister, Go, AI Agents, Workflows, Showcase
---

# Agister: Agent Work as Settings, Not Code

The projects earlier in this series — [RexLab](https://rexlab.enoa.ai) and [FolioTell](https://foliotell.pages.dev) — were built with AI coding agents. After a few months of that, the hard part was no longer getting an agent to write code. It was everything around it: which model with which effort for which job, what each call was allowed to touch, how a review was put together from several lenses, and, afterwards, what actually happened in a run that went wrong.

I kept solving these with shell scripts and prompt files, and kept losing track. [Agister](https://igor1309.dev/agister/) is the tool that replaced them. The code is at [github.com/igor1309/agister](https://github.com/igor1309/agister).

## Three kinds of settings

Agister describes work in three kinds of documents:

- An **agent** picks a runtime — Claude Code, Codex or bash — and, for a model, which model and effort.
- A **process** says what one call needs: its inputs, its prompt, the shape of its output as a JSON schema, and the permissions it asks for.
- A **workflow** composes steps — each a process on an agent — and other workflows: in sequence, in parallel, on a branch, or in a bounded repeat.

That separation is the point. "Review this diff for test quality" is a process. "Use a strong model at high effort" is an agent. "Run five review lenses in parallel, then have a judge merge them" is a workflow. Each can change without touching the others, and nothing about the work lives in Go code. Code adds only a new runtime or a new kind of input source.

## Resolve first, then run

Before anything runs, Agister resolves the request into definitions or a refusal. A process that needs a permission its agent's runtime cannot grant is refused. A workflow that references a missing document is refused, with the chain that leads to the fault. `agister check` resolves every document and refuses exactly what a run would.

That gate matters with agents. A misconfigured run that starts, spends twenty minutes and money, and fails at step four is far worse than one that never starts.

## Every call ends the same way

Whatever the runtime, every call ends in one result shape: status, output checked against the process's schema, cost. And every run leaves a record — the exact definitions with their digests, the inputs, the permission plan, the events and the outcome. When something goes wrong, there is something to look at besides a scrolled-away terminal. The second post in this series is about that record.

## Try it without a model

The simplest agent is bash: a process's prompt is its script, and each input is an environment variable. The README walks through a "Hello, world" run that needs no model and no API key, and leaves a full record under `home/runs/`.

Agister also ships a home folder with a multi-lens code review — the workflows I use every day — and an implement process. The third post looks at how that review is composed.

## Status

Agister is a working tool I use daily to implement and review code with AI agents. Settings and records are versioned formats (`v1alpha1`) and may still change. The code is public to read; it is not open source.

Documentation: [how a run executes](https://igor1309.dev/agister/run-architecture/) and [how settings are read, layered and resolved](https://igor1309.dev/agister/settings-architecture/). Code: [github.com/igor1309/agister](https://github.com/igor1309/agister).
