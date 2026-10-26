---
date: 2026-11-19 12:00
description: Agonara can grade a student's open answer with any model behind an OpenAI-compatible endpoint. The model grades per criterion, its output is validated before a student sees it, and the work runs as a leased, retried, budgeted job.
tags: Agonara, Node.js, LLM, Assessment, Showcase
---

# Agonara: Grading Open Answers with a Model

A multiple-choice check is easy to grade: the student picked an option, and it is right or wrong. In [Agonara](https://github.com/igor1309/agonara) that is the Quick Check, and no model is involved.

An open answer — "explain why this works" — is where real understanding shows, and where grading is hard. A model can do it, and do it well, but it can also wander: grade against criteria nobody wrote, return a paragraph instead of a verdict, or leak details of the system it runs in. This post is about how Agonara lets a model grade without letting it do any of that.

## The curator writes the criteria

An open-answer check comes with **assessment criteria**, accepted by a curator like any other program content. The model never decides what a good answer is. It gets the student's answer, the exact revision of the check and the exact revisions of its criteria, and is asked one thing: for each criterion, was it met?

The answer has a fixed shape. For every criterion there must be exactly one item, naming that criterion's revision, with an outcome of **met**, **partially met**, **missing** or **unclear**, and a line of feedback. There is also a short summary.

## Check the output, then show it

The request asks for JSON matching a schema, but a schema in the request is a hope, not a guarantee. So the result is checked again when it comes back:

- exactly one feedback item per required criterion, no extras, no duplicates;
- every outcome one of the four allowed values;
- every piece of text non-empty, and free of anything that looks like an operational detail — sessions, cookies, authorization, raw prompts, stack traces, temporary paths, connection strings.

Output that fails is not shown to the student. The attempt is evaluated again, or marked as failed. The raw prompt and the raw model response are not kept; what is stored is the validated feedback and the token usage.

## A job, not a request

Grading is not done while the student waits on the HTTP request. Submitting an answer creates an evaluator job, and a worker picks it up:

- the worker takes a **lease** on the job, for five minutes, so two workers never grade the same answer;
- a failed attempt is **retried** once, a minute later, then marked as failed;
- each job has a **budget**: one model call, at most 4,000 input tokens and 1,000 output tokens.

An attempt is always in a named state — submitted, evaluating, evaluated or evaluation failed — so a stuck model shows up as a failure, not a spinner that never ends.

## Any model with an OpenAI-compatible endpoint

The evaluator talks to `/v1/chat/completions`, with a base URL, an API key and a model name set as environment variables. That covers hosted providers and local servers alike. Without them, everything else in Agonara works; open answers simply wait.

## What it adds up to

None of these pieces is clever by itself. Together they let a model take on the slow part of teaching — reading an answer and saying what is missing — while what counts as correct stays with a person, and a misbehaving model costs a retry rather than a confused student.

That closes the series on Agonara. The code, with every module described here, is at [github.com/igor1309/agonara](https://github.com/igor1309/agonara).
