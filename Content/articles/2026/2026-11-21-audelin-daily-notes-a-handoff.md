---
date: 2026-11-21 19:00
description: Audelin's new Daily notes template turns a stand-up into a handoff for the next meeting. It has a spec, a check against real calls, and a rule that real calls are backed up before any test touches them.
tags: Audelin, macOS, AI, Showcase
---

# Audelin: Daily Notes as a Handoff

[Audelin](https://github.com/igor1309/audelin) writes notes for a call from a template: a short file of instructions the model follows. Its new template, Daily, is for stand-ups. A template is easy to treat as a prompt you tweak until the output looks right. Daily was treated as a product instead: it got a spec first, and then a check that runs it on real calls.

## A template with a spec

The reader of Daily notes is the user, usually the next morning, looking for what to pick up. So the notes are actionable, not a recap. There is no speaker-by-speaker account; who said what matters only as who owns what.

The spec puts this in five scenarios. Daily notes say what to continue, who does what, the blockers with their planned fixes, and the meetings planned. They tell an agreed action from a suggestion. They say when an owner is unclear, when a blocker's fix is unclear, and when blockers were not discussed at all.

## Saying gaps instead of filling them

The last three scenarios share one rule: gaps are said, never filled. A model asked for an owner will happily name the person who spoke last. A model asked for blockers will write "none" when nobody raised any. Both read as facts, and both are made up.

So Daily writes what the call left open. An owner or a date that nobody stated reads as unclear. A topic nobody raised reads as not discussed, which is different from "no blockers". The handoff is only useful if the reader can trust that a name in it was actually said.

## Checking against real calls

A spec does not prove the template meets it. Daily was first remade inside the installed app on real dailies, and the notes were read against the five scenarios. That run became a content check: it sends the shipped template through the app's notes path, with the real model, on a fixed set of transcripts, and checks each scenario.

The check runs whenever the template or its code changes, and once a week. It had to learn that a model does not word things the same way twice. It accepts translated labels and paraphrases, so "owner unclear" can come back in Russian in several forms. A call that fails gets one new sample before the check fails, and the report says it was retried; a row that fails twice is a real regression. Two scenarios, the unclear owner and the unclear fix, depend too much on one sample's wording, so they are reported but never block a change.

Driving the app on real calls means touching the user's own data. So the drivers that can change real data follow a written rule. Before acting on a call, a driver copies that call's notes files outside the calls folder, compares every copy byte for byte, and stops if anything is missing. It prints a restore command that puts the files back exactly. After the run it reports, per call, whether the earlier notes were preserved or lost, and fails on a loss.

## Keeping untouched copies current

Templates live as files the user can edit, which raises a quieter problem. A user who never touched their copy of Daily or Default would keep an old text forever after an update. Now an unedited copy that still holds an earlier shipped text is rewritten with the current one, the way Debian treats a configuration file nobody changed. A copy with even one word edited is the user's, and stays as it is.

The templates and the notes path are in [Audelin's public repository](https://github.com/igor1309/audelin).
