---
date: 2026-11-15 12:00
description: A microphone callback that grew with every buffer, a test suite that stopped together, and races that needed acknowledgements: finding failures in Audelin by measuring the work behind them.
tags: Audelin, Swift, macOS, Testing, Showcase
---

# Audelin: Crashes, Hangs and Growing Work

The call ended, and Audelin crashed. A second crash happened during a call, about nine minutes in. Both reports said the stack had overflowed through excessive recursion. One pointed at microphone cleanup; the other at audio delivery.

[Audelin](https://github.com/igor1309/audelin) records both sides of a call and transcribes them on the Mac. The interesting part of these failures was that an ordinary action, repeated often enough, changed the cost of the next one.

## One more wrapper per buffer

The microphone kept its receive closure directly inside a Swift `Mutex`. In this code path, accessing that closure through the lock's mutable value added another pair of forwarding wrappers. Each buffer left the next delivery with a longer chain to call through. Stopping capture released the same chain recursively.

That connected the two crash sites: delivery and destruction were walking what the call had accumulated.

The reproducer did not need a nine-minute recording. Feeding buffers in a loop grew the observed stack depth from 21 frames to 4,019 over 2,000 deliveries. Elapsed time was incidental; buffer count drove the failure.

The [native microphone adapter](https://github.com/igor1309/audelin/blob/d298806d44fe032a279a68998011dd925be5c57c/macos/Sources/MicrophoneCapture/NativeMicrophoneBinding.swift) now keeps the closure inside a small `Receiver` struct, with that value held by the mutex. The [regression test](https://github.com/igor1309/audelin/blob/d298806d44fe032a279a68998011dd925be5c57c/macos/Tests/MicrophoneCaptureTests/NativeMicrophoneConversionTests.swift) delivers 200 buffers through the real `NativeTap`, closes it, and checks that the first and last callback depths match.

A fake microphone above that adapter would have missed the bug. The test has to exercise the code that grew the chain. Flat depth proves that mechanism stays bounded; it does not establish that every possible long-call failure is gone.

## When unrelated tests stop together

Another failure looked like dozens of slow tests. In one CI run, 73 tests hit their one-minute limit, including tests with no audio work. Running the suite again could pass.

The clue was their timing: unrelated tests stopped making progress together and resumed together. Some real-audio tests synchronously waited for child processes or callbacks. On a runner with three cooperative-pool threads, enough such waits could occupy the workers needed by other tasks.

Making a function `async` does not make a synchronous wait suspend. The investigation led through child termination, file work, model loading and cleanup, rather than increasing the timeout. Follow-up work also made cancellation and child reaping explicit.

The public [player shutdown tests](https://github.com/igor1309/audelin/blob/d298806d44fe032a279a68998011dd925be5c57c/macos/Tests/CoreAudioProcessBindingTests/PlayerShutdownTests.swift) show the kind of boundary worth testing: shutdown must finish even when the process-exit path misbehaves. A passing rerun alone cannot explain a hang.

## Sent is different from received

A transcript test had a smaller race. One side ended its audio; the other continued producing words. The test assumed the final snapshot had arrived before allowing the next word through. Waiting for the send did not establish that order.

The [test fixture](https://github.com/igor1309/audelin/blob/d298806d44fe032a279a68998011dd925be5c57c/macos/Tests/CallTextTests/CallTextTests.swift) now waits for acknowledgement that the final snapshot was received. The ordering is part of the conversation between components, rather than a hope about task scheduling.

First-run model loading needed another explicit boundary. Concurrent recognizers could download into the same folder. A shared in-flight load now gives callers one result; [tests](https://github.com/igor1309/audelin/blob/d298806d44fe032a279a68998011dd925be5c57c/macos/Tests/ModelLoadingTests/SharedModelTests.swift) hold that load open, start eight callers, and assert one load, with a separate retry check after failure.

These fixes made the failure measurable: depth per delivery, progress across waits, acknowledgement before the next event, loads per concurrent group. Each gives the next regression somewhere concrete to fail.

The code and build instructions are in [Audelin's public repository](https://github.com/igor1309/audelin).
