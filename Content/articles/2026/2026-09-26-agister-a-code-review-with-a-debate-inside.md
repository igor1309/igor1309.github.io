---
date: 2026-09-26 12:00
description: The code review that ships with Agister runs several lenses in parallel, one of them a writer–critic debate in a bounded repeat, before a judge merges the findings. How it is composed from settings.
tags: Agister, Code Review, AI Agents, Workflows, Showcase
---

# Agister: a Code Review With a Debate Inside

Asking one model "review this diff" gets you a review. It is usually plausible, partly right, and blind in ways that depend on the model and the prompt. The home folder that ships with [Agister](https://igor1309.dev/agister/) contains the review I actually use, and it is built differently: several focused lenses, a debate inside one of them, and a judge at the end. All of it is settings, in [`home/`](https://github.com/igor1309/agister/tree/main/home).

## Five lenses

`code_review` takes a base revision, a candidate and a goal file, and runs five lenses: **architecture**, **tests**, **adversarial**, **clarity** and **intent** — does the change do what its goal says. Each lens is a process with its own prompt and a narrow question. Each is a step, a process bound to an agent, so each can run on the model and effort that suits it.

The lenses sit in a `parallel` item. Parallel in Agister can be capped: the shipped review sets `max: 1`, so the lenses run one at a time and share the machine politely; raise it and they run at once. Either way one failing lens does not stop the others — at least one must complete — and the output is a list of each lens's status and output, in declared order. A review where one lens timed out is still a review, and the record says which lens is missing.

## A debate in a bounded repeat

The tests lens is itself a workflow, `tests_debate`. One model drafts the review. Another critiques it. The writer revises in its own session — it keeps the context of its draft — until the critique converges or two passes have run. Only the last review reaches the judge.

In settings this is a `repeat` item: a body, a state, a `next` binding over that state and an `until` condition, with a `max`. Conditions in Agister are pure: they read params, inputs, the repeat's state and the outputs of items that already ended, with `equals`, `present`, `all`, `any`, `and`, `or` and `not`. The repeat never reads `until` before the first pass, and `max` guarantees it ends.

Why a debate for tests specifically? Test review is where a single model is most easily satisfied: tests exist, they pass, coverage looks fine. A critic whose only job is to push back catches tests that assert nothing or test the mock.

## A judge

The judge is one more step, on a different model. It receives the lenses' outputs, each checked against its process's output schema, and rules only on the evidence they present — it does not go back to the code. It checks each finding's severity against its evidence, merges findings that make the same claim across lenses, sorts them, and rejects those whose evidence does not hold: no concrete case, a claim asserted but not traced, or evidence another lens contradicts. A lens that produced nothing is recorded as a coverage gap, never as an approval.

Schemas make this possible: the judge reads structured findings, not five essays.

## Why compose instead of prompt

All of this could be one giant prompt. Splitting it gives three things:

1. **Each part is replaceable.** Try a different model for the critic by editing one agent file. Settings layer by field — home, repository, project — so a repository can override one lens without copying the rest.
2. **Each part is visible.** The record shows each lens, each debate pass with its state and why the repeat stopped, and the judge's input.
3. **Failures stay small.** A lens at capacity is retried, then falls back to its agent's fallback if it names one; the review goes on.

What Agister does not do is decide what the findings mean. The review produces findings; acting on them stays with the caller.

Read how [settings are layered and resolved](https://igor1309.dev/agister/settings-architecture/), or browse the review's settings in [github.com/igor1309/agister](https://github.com/igor1309/agister).
