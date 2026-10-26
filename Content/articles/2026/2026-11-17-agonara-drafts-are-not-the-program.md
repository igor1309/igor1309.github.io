---
date: 2026-11-17 12:00
description: In Agonara, model suggestions and curator drafts never become program content by themselves, accepted content is kept as revisions, and a student's answers are pinned to the revision they answered. How the modules keep their own data apart.
tags: Agonara, Node.js, Architecture, SQLite, Showcase
---

# Agonara: Drafts Are Not the Program

A learning program changes all the time. A curator rewrites an explanation, splits a concept in two, replaces a check that turned out to be ambiguous. Meanwhile students are reading it and answering it. And with an agent in the loop, there is a steady stream of suggestions that may or may not be any good.

The [previous post](/articles/2026/2026-11-15-agonara-a-learning-program-your-own-agent-can-work-on) introduced [Agonara](https://github.com/igor1309/agonara). This one is about how it keeps all of that from turning into one tangled table.

## Three stages for every piece of content

Content moves through three places, each owned by a different module:

1. **A suggestion.** A model, asked by a curator, proposes a draft topic, material or check. Suggestions live in the **Curator Workspace** and can be listed, read, accepted or rejected there.
2. **A candidate.** Accepting a suggestion does not publish it. It turns the suggestion into a draft candidate — the same kind of draft a curator writes by hand. The candidate still has to be reviewed.
3. **An accepted revision.** When a curator accepts a candidate, the **Corpus** records a new revision of that topic, concept, material or check: its title and body, its sources, the rationale, who accepted it and when.

So a model's output is two deliberate steps away from a student. Each step checks that the person is a curator of that program, and each acceptance, or refusal, is written to the audit trail.

## Revisions, not overwrites

When a curator edits accepted content, the Corpus does not change it in place. It adds a revision and moves the entity's "current" pointer to it. Earlier revisions stay.

That matters most for students. A student's attempt records the exact revision of the check they answered, and an evaluation is made against the exact revisions of the criteria. If the curator later rewrites the check, the student's old answer still points at the question they actually saw. Their answers, attempts and progress belong to the **Student Workspace**, and a change to the program never edits them.

## Ask, don't read

Who takes part in a program — curators, students, invitations, recovery — is decided by **Program Membership**. Other modules do not read its tables to find out. They ask it: "is this identity an effective curator of this program?" The rules for invitations and lapsed access live in one place, and changing them does not ripple through the curator and student code.

The same goes for the **Admin**. Admin is an operational role for the instance: identities, credentials, the audit trail. It does not own program content, and being an Admin does not make you a curator.

## One file

All of this sits in a single SQLite file. Every module takes part in backup and restore, so a backup is the whole instance — accepted content and its history, drafts, memberships and every student's work — not a set of exports that may or may not agree.

For a system with one operator, that is the right size: no database server to run, and a backup is one file.

The last post in this series is about the part that needs the most care: letting a model grade a student's answer.
