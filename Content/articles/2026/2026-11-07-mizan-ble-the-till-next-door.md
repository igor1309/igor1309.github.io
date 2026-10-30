---
date: 2026-11-07 12:00
description: A phone that pays at a till must never pay the till next door. How Mizan BLE picks the nearest host by smoothed signal strength, what a real iPad and iPhone measured, why the first picker flickered at arm's length, and what iOS does not let a Bluetooth payment do.
tags: Mizan BLE, Swift, Core Bluetooth, iOS, Showcase
---

# Mizan BLE: the Till Next Door

A shop has more than one till. When the payer holds out their phone, [Mizan BLE](https://github.com/igor1309/mizan-ble) has to pick the till in front of them, not the one a metre to the left, and never guess. The only evidence the phone has is how loud each till sounds: the received signal strength, RSSI, in dBm.

## The picker

The phone scans for the Mizan service with duplicates allowed, so each host keeps reporting a fresh reading rather than appearing once. A reading of 127 means "not available" and is dropped. Each host's readings are smoothed with an exponential moving average, `ema = α·rssi + (1 − α)·ema`, with α at 0.3. A host not heard for two seconds leaves the list.

After at least a second and five readings, the phone offers the strongest host if its average is above a floor, −65 dBm, and leads the runner-up by a margin, 6 dB. Otherwise it says "Hold your phone closer to the till" and keeps scanning.

The picker is a pure type. It takes timestamped readings and a clock and answers with a host, "keep scanning" or nothing, so its tests cover one host, two close ones, a host that fades out and the 127 reading without a radio.

## What the devices measured

On an iPad Pro and an iPhone 15 Pro, the smoothed signal read −40 to −55 dBm with the phone beside the iPad, −60 to −66 at arm's length, and −66 to −77 a few steps away. So the −65 floor fell where a payer actually stands. That part of the guess was right.

The rest was not. With the phone held still, the average moved 5 to 13 dB within a second. At arm's length, the screen flipped between the host and "hold closer" two to eight times a second, because the picker chose a host and dropped it at the same line. Any value of the floor would have had its own arm's length.

## Choosing is not holding

The fix was to split the question in two. The picker still says what the signal shows right now. A second component, host choice, decides what to offer over time. Once a host is offered, it is kept while it still leads by the margin and its average stays above a drop line 6 dB under the floor, or dips under that line for less than a second. It is dropped at once for a clear rival or when it fades out.

Choosing at one line and dropping at a lower one is hysteresis, the way a thermostat avoids switching on and off every few seconds. The phone now keeps the host it offered through short dips instead of flickering. The phone also draws the signal as bars and dBm while it scans, so a payer asked to hold closer can see why.

A second iPad was not at hand, so choosing between two real tills waits for the next version; scripted rehearsal lanes cover it meanwhile.

## What iOS does not allow

Some limits are not in the app's code at all.

- **A peripheral cannot hang up.** As the [second post](/articles/2026/2026-10-31-mizan-ble-every-way-a-transaction-ends) described, the iPad ends a link by removing its service.
- **The iPad never learns the phone's signal.** RSSI is something a central reads; the host has no way to tell how near the payer is.
- **Message size is negotiated.** A link left at Bluetooth's default 23-byte MTU could not carry the 41-byte amount in one write. Current iPhones and iPads negotiate more, and every sender checks its limit before sending; a message that does not fit fails the transaction rather than being split.
- **Scanning with duplicates works only in the foreground,** and iOS may slow it over time even there.
- **No payment can start in the background.** Core Bluetooth's background modes can keep a session going that the person started, but they do not offer continuous discovery or a dependable launch when a till comes near. A payment that starts with the phone in a pocket needs another trigger, such as a QR code or an NFC tag that opens the app, with Bluetooth carrying the rest.

## Where it stands

Version 0.0.1 is done: payments confirm, fail and decline on a real iPad and iPhone, a host left alone times out, and the logs from every device run hold no amount, key or identifier. The next versions test the limits above: two tills side by side and a payment with no manual step but the payer's confirm, then how close iOS lets a payment come to starting without the app open.

The code, the tests and the rehearsal lanes are at [github.com/igor1309/mizan-ble](https://github.com/igor1309/mizan-ble).
