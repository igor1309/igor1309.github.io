---
date: 2022-09-01 15:15
description: fastlane snapshot to automate taking localized screenshots for iOS and tvOS apps on every device
tags: App Store, fastlane, snapshot, screenshots
---
# fastlane: snapshot

1. Create dedicated UI Test Target and Scheme (enable `Run` option for the Test Target) for snapshots.

2. Run

```sh
$ bundle exec fastlane snapshot init
```

3. Add `SnapshotHelper.swift` to Test Target.

4. Add UI tests for snapshots.

5. Edit `Snapfile` - select devices and languages.

6. Run
```sh
$ bundle exec fastlane snapshot
```

For more see [snapshot - fastlane docs](https://docs.fastlane.tools/actions/snapshot/), [Screenshots - fastlane docs](https://docs.fastlane.tools/getting-started/ios/screenshots/), and [Creating perfect App Store Screenshots of your iOS App · Felix Krause](https://krausefx.com/blog/creating-perfect-app-store-screenshots-of-your-ios-app).

## References

* [Fastlane for iOS, Episode 30: Snapshot | raywenderlich.com](https://www.raywenderlich.com/1259223-fastlane-for-ios/lessons/30)
