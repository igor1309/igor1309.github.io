---
date: 2023-02-23 16:16
description: How I've got 10% Build Time Improvement in a Real-world App
tags: Xcode
---
# 10% Build Time Improvement

1. Select DWARF (without dSYM) for Debug Information Format (Debug config only).

2. Remove ` == true`, and replace ` == false` with condition negation, fast and simple for non-optional conditions only.

3. Simplify expressions to help the compiler.

Notes:

1. [`==` operator has a lots of overloads slowing compiler time](https://forums.swift.org/t/swift-equality-operator-takes-long-time-to-type-check/41226/9)

2. Xcode Find Navigator: Replace > Regular Expression > `(if|guard)(\s+)([\w|\.]+) == false` with `$1$2!$3`

3. Check expressions with long comple time using swift-flags: Build Settings ➔ Swift Compiler - Custom Flags ➔ Other Swift Flags:
```
-Xfrontend -warn-long-function-bodies=<limit>
-Xfrontend -warn-long-expression-type-checking=<limit>
```
Start with `limit` of 500 or 1000 milliseconds and move down to 100.

## References:

- [Swift equality operator takes long time to type check - Using Swift - Swift Forums](https://forums.swift.org/t/swift-equality-operator-takes-long-time-to-type-check/41226/9)

- [Build performance analysis for speeding up Xcode builds - SwiftLee](https://www.avanderlee.com/optimization/analysing-build-performance-xcode/)
