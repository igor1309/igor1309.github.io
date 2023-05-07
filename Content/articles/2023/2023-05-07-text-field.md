---
date: 2023-05-07 12:30
description: 
tags: SwiftUI, TextField, Links
---

# SwiftUI: Expandable `TextField`

SerialCoder.dev talks about a “present from the fourth revision of SwiftUI (iOS 16 and macOS 13 (Ventura))” to create an [expandable and scrollable text field](https://serialcoder.dev/presenting-expandable-textfields-in-swiftui/) and adjust the displayed number of lines.
The only downside is a lack of backwards compatibility.

I often forget that `lineLimit()` modifier also works with [ClosedRange](https://developer.apple.com/documentation/swiftui/text/linelimit(_:)-6xchl), [PartialRangeThrough](https://developer.apple.com/documentation/swiftui/text/linelimit(_:)-2fysr), and [PartialRangeFrom](https://developer.apple.com/documentation/swiftui/text/linelimit(_:)-rli5) ranges and has an overload with [reservesSpace](https://developer.apple.com/documentation/swiftui/text/linelimit(_:reservesspace:)) parameter.
