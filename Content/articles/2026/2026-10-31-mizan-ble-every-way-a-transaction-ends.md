---
date: 2026-10-31 12:00
description: A payment over Bluetooth has one way to succeed and many ways to stop. How Mizan BLE splits each side into a chain of state machines, why the countdown stops once the amount is sent, and how an iPad ends a link it is not allowed to close.
tags: Mizan BLE, Swift, Core Bluetooth, iOS, Showcase
---

# Mizan BLE: Every Way a Transaction Ends

The [first post](/articles/2026/2026-10-24-mizan-ble-a-payment-between-an-ipad-and-an-iphone) walked through a payment that goes well: lock, connect, amount, confirm, result. Most of the specifying went into the other paths: the payer walks away, the operator changes their mind, Bluetooth drops halfway. Both screens have to say what happened, and they have to agree.

## The endings

The user-level spec of [Mizan BLE](https://github.com/igor1309/mizan-ble) lists fifteen scenarios. Besides success and failure, a transaction can end because:

- **The payer declines.** Both screens say so, and nothing is charged.
- **No one connects in time.** The host's countdown runs out; it stops advertising and returns to the keypad.
- **The operator cancels.** The host sends a sealed end message, and the phone says the host cancelled.
- **The handshake breaks off.** The link drops after the host has the phone's key but before it sends the amount. Both say the handshake failed; the operator can broadcast again.
- **The link drops while the payment is processed.** The payer has confirmed, the operator has not picked an outcome. The phone says the result is unknown; the iPad says the payer was not told.
- **Bluetooth is off, or not allowed** for the app. No payment starts, and the screen says which.

There are also failures one side sees and the other does not. If the link drops before the host has the phone's key, the host never knew anyone was there: its amount stays on air and its countdown keeps running.

## One deadline, and then none

The host's countdown is a deadline for the handshake, not for the payment. Once the amount has been handed to the radio, the countdown stops, and nothing after that times out: the payer reads the amount and the operator picks the outcome in their own time. A confirm is never refused for being slow.

The phone has its own deadline: ten seconds from tapping Start to a secure link, so a host that goes quiet mid-handshake does not leave the payer staring at a spinner.

## A link the iPad cannot close

Core Bluetooth gives a central `cancelPeripheralConnection`. A peripheral has nothing like it: the iPad cannot hang up on a phone. So the host ends a link by removing its service. It first sends whatever is queued, such as the result or the end message, then retires the service, and the phone sees the service go. The other direction is cleaner: the host learns the phone is gone when it unsubscribes from To client.

Each radio reports a dropped link, a vanished service or Bluetooth turned off as the same thing, a lost link, so each flow has one loss to handle rather than three.

## A chain of state machines

Each side is a chain of small machines. On the host, amount entry types the amount, host broadcast takes it to a secure link, and host payment takes it to a result. On the client, find chooses the host, connect opens the secure link, review takes the payer's decision, and payment waits for the result. The split falls where the work changes: once the link is secure, the countdown and the signal strength stop mattering.

Each machine is a pure reducer, `(State, Event) -> (State, Effect?)`, and an effect handler that hands each effect to an injected dependency and returns its results as events. The reducer never touches the radio, the clock or CryptoKit, so every ending above is a table of events in and states out, tested with no Bluetooth at all.

The machine that started a transaction, host broadcast or client find, does not end when it hands over. It waits, and when the transaction ends it is told and goes back to its start. That way the code that wires the machines together keeps no state of its own about where to return.

## Rehearsing without a radio

The simulator has no Bluetooth, but each ending still needs to be seen on a screen. A rehearsal build of the app swaps the radios for a scripted other side, read from a JSON file, that plays the real protocol, with real keys and sealed messages. Fifteen [Maestro](https://maestro.dev) lanes drive it through every scenario, check the screens, and read the app's log to confirm that no amount, key or device identifier was ever written to it.

The real devices then only had to confirm what the lanes already showed, and they did: confirm, fail, decline and a host left alone all ended as specified on an iPad and an iPhone.

The last post in this series is about the part that did not go as specified: choosing the nearest till by signal strength.
