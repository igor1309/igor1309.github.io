---
date: 2022-08-24 10:10
description: Re-watch and recap of Point-Free series on Protocol Witnesses
tags: Point-Free, Protocol Witness
---

# Protocol Witnesses

## [Episode #33: Protocol Witnesses: Part 1](https://www.pointfree.co/episodes/ep33-protocol-witnesses-part-1)

Episode #33 • Oct 15, 2018 • Subscriber-Only

Protocols are a great tool for abstraction, but aren’t the only one. This week we begin to explore the tradeoffs of using protocols by highlighting a few areas in which they fall short in order to demonstrate how we can recover from these problems using a different tool and different tradeoffs.

> ... protocols are quite rigid in that a type can conform to a given protocol in only one single way. Sometimes it’s completely valid and even technically correct to allow a type to conform to a protocol in multiple ways.


## [Episode #34: Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep34-protocol-witnesses-part-2)

Episode #34 • Oct 22, 2018 • Subscriber-Only

Last time we covered some basics with protocols, and demonstrated one of their biggest pitfalls: types can only conform to a protocol a single time. Sometimes it’s valid and correct for a type to conform to a protocol in many ways. We show how to remedy this by demonstrating that one can scrap any protocol in favor of a simple datatype, and in doing so opens up a whole world of composability.

> What’s the point of going through the motions of translating protocols to structs when Swift has given us protocols ...?

> First, this process of translating protocols into structs and then passing around explicit witnesses is literally what the Swift compiler is doing under the hood. It’s nice to know that there isn’t any real magic happening behind the scenes, and that the concepts are super simple.

> Second, explicit witnesses give us a whole new level composability with our conformances that was impossible to see when we are dealing with protocols.

Using `contramap`.


## [Episode #35: Advanced Protocol Witnesses: Part 1](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1)

Episode #35 • Oct 29, 2018 • Subscriber-Only

Now that we know it’s possible to replace protocols with concrete datatypes, and now that we’ve seen how that opens up new ways to compose things that were previously hidden from us, let’s go a little deeper. We will show how to improve the ergonomics of writing Swift in this way, and show what Swift’s powerful conditional conformance feature is represented by just plain functions.

Rename `contramap` to `pullback`.


## [Episode #36: Advanced Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep36-advanced-protocol-witnesses-part-2)

Episode #36 • Nov 5, 2018 • Subscriber-Only

We complete our dictionary for translating Swift protocol concepts into concrete datatypes and functions. This includes protocol inheritance, protocol extensions, default implementations and protocols with associated types. Along the way we will also show how concrete types can express things that are currently impossible with Swift protocols.

> translating protocols to concrete datatypes has revealed just how simple some of these seemingly complex features are. We could clear away the fog and see that a protocol feature is really just functions and composition and generics in disguise! Even the dreaded “Self or associated type” error becomes much less dreadful when you realize that it’s just a couple hidden generics.


## [Episode #37: Protocol-Oriented Library Design: Part 1](https://www.pointfree.co/episodes/ep37-protocol-oriented-library-design-part-1)

Episode #37 • Nov 12, 2018 • Subscriber-Only

Perhaps the most popular approach to code reuse and extensibility in Swift is to liberally adopt protocol-oriented programming, and many Swift libraries are designed with protocol-heavy APIs. In today’s episode we refactor a sample library to use protocols and examine the pros and cons of this approach.


## [Episode #38: Protocol-Oriented Library Design: Part 2](https://www.pointfree.co/episodes/ep38-protocol-oriented-library-design-part-2)

Episode #38 • Nov 19, 2018 • Subscriber-Only

With our library fully generalized using protocols, we show off the flexibility of our abstraction by adding new conformances and functionality. In fleshing out our library we find out why protocols may not be the right tool for the job.


Snapshotting views as strings.


## [Episode #39: Witness-Oriented Library Design](https://www.pointfree.co/episodes/ep39-witness-oriented-library-design)

Episode #39 • Nov 26, 2018 • Subscriber-Only

We previously refactored a library using protocols to make it more flexible and extensible but found that it wasn’t quite as flexible or extensible as we wanted it to be. This week we re-refactor our protocols away to concrete datatypes using our learnings from earlier in the series.

## [Episode #40: Async Functional Refactoring](https://www.pointfree.co/episodes/ep40-async-functional-refactoring)

Episode #40 • Dec 17, 2018 • Subscriber-Only

The snapshot testing library we have been designing over the past few weeks has a serious problem: it can’t snapshot asynchronous values, like web views and anything that uses delegates or callbacks. Today we embark on a no-regret refactor to fix this problem with the help of a well-studied and well-understood functional type that we have discussed numerous times before.

Sync snapshotting web views fails, need async.

Async snapshotting. `Parallel` type.

Async pullback.


## [Episode #41: A Tour of Snapshot Testing](https://www.pointfree.co/episodes/ep41-a-tour-of-snapshot-testing)

Episode #41 • Dec 18, 2018 • Free Episode

Our snapshot testing library is now officially open source! In order to show just how easy it is to integrate the library into any existing code base, we add some snapshot tests to a popular open source library for attributed strings. This gives us the chance to see how easy it is to write all new, domain-specific snapshot strategies from scratch.


## [Episode #86: SwiftUI Snapshot Testing](https://www.pointfree.co/episodes/ep86-swiftui-snapshot-testing)

Episode #86 • Dec 23, 2019 • Free Episode

In this week’s free holiday episode we show what it looks like to snapshot test a SwiftUI application in our architecture and compare this style of integration testing against XCTest’s UI testing tools.


Snapshotting alerts (UIWindow, hosting application @11:44)


`windowedImage` snapshotting strategy

Turning animation off and on. Not working for alerts.

...play a simple user script by sending actions to the store and then take screenshots of what the application looks like at each step of the way









