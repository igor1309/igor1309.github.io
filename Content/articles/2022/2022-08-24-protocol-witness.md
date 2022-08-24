---
date: 2022-08-24 10:10
description: Re-watch and recap of Point-Free series on Protocol Witnesses
tags: Point-Free, Protocol Witness
---
# Protocol Witnesses

[Episode #33: Protocol Witnesses: Part 1](https://www.pointfree.co/episodes/ep33-protocol-witnesses-part-1)

Episode #33 • Oct 15, 2018 • Subscriber-Only

Protocols are a great tool for abstraction, but aren’t the only one. This week we begin to explore the tradeoffs of using protocols by highlighting a few areas in which they fall short in order to demonstrate how we can recover from these problems using a different tool and different tradeoffs.

> ... protocols are quite rigid in that a type can conform to a given protocol in only one single way. Sometimes it’s completely valid and even technically correct to allow a type to conform to a protocol in multiple ways.


[Episode #34: Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep34-protocol-witnesses-part-2)

Episode #34 • Oct 22, 2018 • Subscriber-Only

Last time we covered some basics with protocols, and demonstrated one of their biggest pitfalls: types can only conform to a protocol a single time. Sometimes it’s valid and correct for a type to conform to a protocol in many ways. We show how to remedy this by demonstrating that one can scrap any protocol in favor of a simple datatype, and in doing so opens up a whole world of composability.

> What’s the point of going through the motions of translating protocols to structs when Swift has given us protocols ...?

> First, this process of translating protocols into structs and then passing around explicit witnesses is literally what the Swift compiler is doing under the hood. It’s nice to know that there isn’t any real magic happening behind the scenes, and that the concepts are super simple.

> Second, explicit witnesses give us a whole new level composability with our conformances that was impossible to see when we are dealing with protocols.

Using `contramap`.


[Episode #35: Advanced Protocol Witnesses: Part 1](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1)

Episode #35 • Oct 29, 2018 • Subscriber-Only

Now that we know it’s possible to replace protocols with concrete datatypes, and now that we’ve seen how that opens up new ways to compose things that were previously hidden from us, let’s go a little deeper. We will show how to improve the ergonomics of writing Swift in this way, and show what Swift’s powerful conditional conformance feature is represented by just plain functions.

Rename `contramap` to `pullback`.


[Episode #36: Advanced Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep36-advanced-protocol-witnesses-part-2)

Episode #36 • Nov 5, 2018 • Subscriber-Only

We complete our dictionary for translating Swift protocol concepts into concrete datatypes and functions. This includes protocol inheritance, protocol extensions, default implementations and protocols with associated types. Along the way we will also show how concrete types can express things that are currently impossible with Swift protocols.

> translating protocols to concrete datatypes has revealed just how simple some of these seemingly complex features are. We could clear away the fog and see that a protocol feature is really just functions and composition and generics in disguise! Even the dreaded “Self or associated type” error becomes much less dreadful when you realize that it’s just a couple hidden generics.


## Exercise: Decorator pattern with Protocol Witness

```swift
/// [Episode #34: Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep34-protocol-witnesses-part-2)
/// [Episode #35: Advanced Protocol Witnesses: Part 1](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1)
/// [Episode #36: Advanced Protocol Witnesses: Part 2](https://www.pointfree.co/episodes/ep36-advanced-protocol-witnesses-part-2)

protocol Logger {
    func log(_ message: String)
}

final class PrintLogger: Logger {
    func log(_ message: String) {
        print(message)
    }
}

/// Corresponds to protocol `Logger`
struct Logging {
    let log: (String) -> Void
}

extension Logging {
    static let printLogging: Self = .init { print($0) }
}

protocol SendMessageInput {
    associatedtype MessageDetails
    associatedtype ChannelID
    
    func send(_ messageDetails: MessageDetails, to channelID: ChannelID) throws
}

final class DummySendMessageInput: SendMessageInput {
    typealias MessageDetails = String
    typealias ChannelID = Int
    
    func send(_ messageDetails: MessageDetails, to channelID: ChannelID) throws {
        // do nothing
    }
}

/// To create `decorator` with protocols we need a new class, conforming to `SendMessageInput`, and initialized with `logger` and `decoratee`
final class DecoratedDummySendMessageInput: SendMessageInput {
    private let logger: Logger
    private let decoratee: DummySendMessageInput
    
    init(logger: Logger, decoratee: DummySendMessageInput) {
        self.logger = logger
        self.decoratee = decoratee
    }
    
    func send(_ messageDetails: String, to channelID: String) throws {
        logger.log(“Started sending message.”)
        try self.send(messageDetails, to: channelID)
        logger.log(“Started sending message.”)
    }
}

/// Corresponds to protocol `SendMessageInput`
struct SendingMessageInput<MessageDetails, ChannelID> {
    let send: (MessageDetails, ChannelID) throws -> Void
}

extension SendingMessageInput {
    static var dummy: Self { .init { _, _ in } }
}

/// Protocol witness, corresponds to `DummySendMessageInput`
extension SendingMessageInput
where MessageDetails == String,
      ChannelID == String {
    static let stringDummy: Self = .dummy
}

/// To create `decorator` with protocol witnesses we do not need a new type, just a function that extends existing type with injected instance of `Logging`
extension SendingMessageInput {
    func decorated(with logger: Logging) -> Self {
        .init { messageDetails, channelID in
            logger.log(“Started sending message.”)
            try send(messageDetails, channelID)
            logger.log(“Started sending message.”)
        }
    }
}

let decoratedStringDummy: SendingMessageInput = .stringDummy.decorated(with: .printLogging)
```


[Episode #37: Protocol-Oriented Library Design: Part 1](https://www.pointfree.co/episodes/ep37-protocol-oriented-library-design-part-1)

Episode #37 • Nov 12, 2018 • Subscriber-Only

Perhaps the most popular approach to code reuse and extensibility in Swift is to liberally adopt protocol-oriented programming, and many Swift libraries are designed with protocol-heavy APIs. In today’s episode we refactor a sample library to use protocols and examine the pros and cons of this approach.







