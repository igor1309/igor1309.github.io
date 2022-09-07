---
date: 2022-08-25 10:10
description: Exploring the way of the Decorator Pattern implementation with Protocol and Protocol Witnesses
tags: Decorator Pattern, Protocol Witness
---
# The Decorator Pattern with Protocol and Protocol Witnesses

_Gang of Four Design Patterns_:

> Attach additional responsibilities to an object dynamically. Decorators provide a flexible alternative to subclassing for extending functionality.


_[Essential Developer: Design Patterns in iOS/Swift: Standing on the shoulder of giants | iOS Lead Essentials Podcast #014](https://www.essentialdeveloper.com/articles/design-patterns-in-ios-swift-standing-on-the-shoulder-of-giants-ios-lead-essentials-podcast-014?rq=Decorator)_:

> The Decorator pattern offers a way of adding behavior to an individual object and extending its functionality without subclassing or changing the object’s class.
><br/><br/>
> Decorators are useful when you want to add or alter the behavior of individual objects instead of an entire class of objects.
><br/><br/>
> To implement the Decorator pattern, you create a new object (decorator) that encloses and conforms to the interface of the component (decoratee) it decorates. The decorator class will contain the extended behavior and forward messages to the decoratee.
><br/><br/>
> By doing so, the decorator can be used by the clients of the interface, extending the behavior of the system without needing to alter any existing components.
><br/><br/>
> The Decorator pattern is supported by the SOLID principles, especially the Single Responsibility, Liskov Substitution, and Open/Closed Principles.
><br/><br/>
> You can use Decorators to add Cross-Cutting concerns such as Logging, Analytics, Threading, Security, etc. into your modules in a clean way while maintaining low coupling in your applications.



## Decorator with protocol

```swift
protocol Logger {
    func log(_ message: String)
}

final class PrintLogger: Logger {
    func log(_ message: String) {
        print(message)
    }
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
```

### Decorator

Let’s extend the functionally of the `DummySendMessageInput` class by logging:

To create `decorator` with protocols we need a new class, conforming to `SendMessageInput`, and initialized with `logger` and `decoratee`

```swift
final class DecoratedDummySendMessageInput: SendMessageInput {
    private let logger: Logger
    private let decoratee: DummySendMessageInput

    init(logger: Logger, decoratee: DummySendMessageInput) {
        self.logger = logger
        self.decoratee = decoratee
    }
}
```

Extended functionality

```swift
    func send(_ messageDetails: String, to channelID: String) throws {
        logger.log(“Started sending message.”)
        try self.send(messageDetails, to: channelID)
        logger.log(“Started sending message.”)
    }
}
```

## Decorator with Protocol Witness

Corresponds to protocol `Logger`

```swift
struct Logging {
    let log: (String) -> Void
}
```

Protocol witness

```swift
extension Logging {
    static let printLogging: Self = .init { print($0) }
}
```

Corresponds to protocol `SendMessageInput`

```swift
struct SendingMessageInput<MessageDetails, ChannelID> {
    let send: (MessageDetails, ChannelID) throws -> Void
}
```

Protocol witness, corresponds to `DummySendMessageInput`
```swift
extension SendingMessageInput
where MessageDetails == String,
      ChannelID == String {
    static var dummy: Self { .init { _, _ in } }
}
```

### Decorator

To create `decorator` with protocol witnesses we do not need a new type, just a function that extends existing type with injected instance of `Logging`

```swift
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

## References

* [Design Patterns in iOS/Swift: Standing on the shoulder of giants | iOS Lead Essentials Podcast #014 - Essential Developer](https://www.essentialdeveloper.com/articles/design-patterns-in-ios-swift-standing-on-the-shoulder-of-giants-ios-lead-essentials-podcast-014?rq=Decorator)

* [Testing code that uses DispatchQueue.main.async | iOS Lead Essentials Community Q&A — Essential Developer](https://www.essentialdeveloper.com/articles/testing-code-that-uses-dispatchqueue-main-async-ios-lead-essentials-community-qa?rq=Decorator)

* __Gang of Four (GoF) Design Patterns__: [Design Patterns: Elements of Reusable Object-Oriented Software](https://www.goodreads.com/book/show/85009.Design_Patterns) by Erich Gamma,  Ralph Johnson,  John Vlissides, Richard Helm

* [Gang of Four Design Patterns - Spring Framework Guru](https://springframework.guru/gang-of-four-design-patterns/)

* [Decorator Pattern - Spring Framework Guru](https://springframework.guru/gang-of-four-design-patterns/decorator-pattern/)

* [Episode #34: Protocol Witnesses: Part 2 (Subscriber-Only)](https://www.pointfree.co/episodes/ep34-protocol-witnesses-part-2)

* [Episode #35: Advanced Protocol Witnesses: Part 1 (Subscriber-Only)](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1)

* [Episode #36: Advanced Protocol Witnesses: Part 2 (Subscriber-Only)](https://www.pointfree.co/episodes/ep36-advanced-protocol-witnesses-part-2)
