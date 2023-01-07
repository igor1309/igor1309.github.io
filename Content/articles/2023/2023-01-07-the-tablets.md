---
date: 2023-01-07 23:33
description:
tags: Best Practices
---
# The Tablets

## Bug fixes

### North Star

- create a test to reproduce the bug
- change code to fix the bug
- keep the test in the codebase to prevent regressions

### Worst case

If test setup is really difficult/complex and cost-benefit is not favorable, fix the bug without test.

Try to make changed code better.

## Changing existing code

### North Star

_See “New features…” section_

### Worst case

Try to leave the code you’ve changed in a better shape.
Better means: readable, clear

## New features/services/components

Make separate module or modules.

Every UI component should be snapshot-tested
- use dump views that render state, move the logic to the (view) models
- snapshot different state values

Full unit-test suite for non-UI components.
