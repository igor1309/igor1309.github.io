---
date: 2026-08-08 12:00
description: RexLab's behaviour is specified in 87 Gherkin feature files with about 640 scenarios. Why specs come first when AI agents write the code, and what the tests check beyond game rules.
tags: RexLab, BDD, Gherkin, Testing, AI Agents, Showcase
---

# RexLab: 640 Scenarios Before Code

[RexLab](https://rexlab.enoa.ai) is a small children's app, yet its repository has 87 Gherkin feature files with about 640 scenarios in [`docs/features/`](https://github.com/igor1309/rexlab/tree/main/docs/features), and more than 130 Vitest test files. That ratio looks excessive for a dinosaur game. It is the reason the game could be built with AI coding agents at all.

## Specs as the contract with the agent

An agent is fast and tireless, and it will happily build exactly what it guessed you meant. The cheapest place to remove the guessing is a written behaviour, in words the owner can read and the agent can test against. In RexLab every behaviour starts as a scenario:

```gherkin
Scenario Outline: The child's own choice in a game wins until the setting changes
  Given the age level is <setting>
  And a game with all three modes, in which the child chose <choice>
  When I close and reopen the app
  And the game starts again
  Then it plays its <choice> mode
  When a parent chooses <next> in the age level menu
  ...
```

This one settles a real product question: when a parent sets the level to Explorer and the child switches a game to Hatchling, who wins, and for how long? Without a scenario that is a judgement call the agent makes silently. With one, it is a rule both of us can point at.

Feature files also reference each other. The level-choice feature names every game that has a level switch and the shared rule they follow. That turns the folder into a map of the product, not a pile of tests.

## Tests that check more than rules

Game rules are the easy part. The tests also check things that usually live in a designer's head:

- **Fit.** Each screen is rendered at the window sizes listed in `tests/windowSizes.ts` — a 9.7" iPad and an iPad mini in Safari and full screen, a 13" iPad Pro, and two Mac windows — and must fit without scrolling.
- **Tap safety.** Small hands double-tap, rest a palm on the screen and drag when they mean to tap. Those cases have their own tests (the next post is about them).
- **Architecture.** `tests/architecture.test.ts` builds the import graph of `src/` and fails when one game imports another, or when a screen reaches into a module it should not know about.

The last one matters most with agents. An agent under pressure to make a test pass will take the shortest path, and the shortest path often crosses a boundary. A test that reads the import graph turns "please keep games independent" into a failing build.

## The loop

Work on a feature went roughly like this: write or revise scenarios; have an agent turn them into failing tests; have an agent make them pass; review the diff and the screenshots on real window sizes. `sh scripts/test.sh` runs the whole check from a clean install — typecheck, tests and build — so "done" means the same thing for me and for the agent.

None of this is new. It is ordinary BDD and TDD. What changed is the economics: writing a scenario is now most of the cost of a feature, and that is where my attention should go.

Code and specs: [github.com/igor1309/rexlab](https://github.com/igor1309/rexlab). The app: [rexlab.enoa.ai](https://rexlab.enoa.ai).
