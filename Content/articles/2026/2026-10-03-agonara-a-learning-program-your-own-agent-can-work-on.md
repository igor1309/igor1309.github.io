---
date: 2026-10-03 12:00
description: Agonara is a bring-your-own-agent environment for learning programs. A curator builds a program from sources, students follow it and prove they understand, and the agent you already use does the drafting, quizzing and grading. What it is and why only a person accepts content.
tags: Agonara, Node.js, AI Agents, Learning, Showcase
---

# Agonara: a Learning Program Your Own Agent Can Work On

Learning something serious on your own usually looks like this: forty open tabs, a folder of PDFs, a few long chats with a model, and no clear sense of what you actually know. The material is there. What is missing is the structure: what to study in what order, how to check yourself, and where you are still weak.

AI agents are good at producing that structure — summaries, quizzes, feedback on an answer. They are also good at producing confident nonsense. [Agonara](https://agonara.enoa.ai/learn) is my attempt to get the first without the second. The code is at [github.com/igor1309/agonara](https://github.com/igor1309/agonara).

## Two roles and a program

Everything in Agonara happens inside a **program**: a structured course built from sources.

- A **Program Curator** builds it: topics, concepts, the materials that explain them, and the checks that test them. The curator also sees coverage gaps — concepts with no material, or no check that tests them.
- A **Student** joins a program, reads its accepted material, answers checks and sees where they are weak.

A program can be joined by invitation, and someone who lost access can be let back in. An **Admin** runs the instance itself — identities, roles, the audit trail — but has no say over program content.

## Bring your own agent

Agonara does not ship its own assistant. Curators and students point the agent they already use — Claude Code, Codex or any other — at their Agonara instance, through a set of [agent skills](https://github.com/igor1309/agonara-skills) and a documented HTTP API.

For a curator, the agent reads sources and drafts topics, concepts, materials and checks. For a student, it can quiz them and help them through the material. The web screens and the agents talk to the same API, so what an agent drafts lands in the same place a curator reviews it in the browser.

Using the agent you already have also means you pay for one subscription, not two, and keep the model you trust.

## Only a person accepts content

This is the one rule that shapes the rest. An agent can draft as much as it likes; nothing it writes reaches students until a curator accepts it. Suggestions and drafts live apart from the accepted program, and accepting one is a deliberate act by a named person, recorded with who and when.

The same holds for grading. Open answers can be evaluated by a model, but the model grades against criteria the curator accepted, and its output is checked before a student sees it. The third post in this series is about that.

## Try it

You need Docker:

```sh
git clone https://github.com/igor1309/agonara.git
cd agonara
AGONARA_BOOTSTRAP_SECRET=choose-a-secret docker compose up --build
```

Open `http://127.0.0.1:18080/admin`, create the first Admin with the bootstrap secret, then go to `/learn`. Everything runs without a model; grading open answers needs one behind an OpenAI-compatible endpoint, set with three environment variables described in the README.

## Status

Agonara runs as a private instance. Identity, membership, curation, reading, open-answer and Quick Check assessment, learner state, readiness checks, coverage gaps and model-assisted curation suggestions are implemented, each with its own screen. The code is public to read; it is not open source.

The next post looks at how Agonara keeps drafts, the accepted program and a student's progress apart.
