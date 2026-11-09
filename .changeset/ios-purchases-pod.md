---
openbudget_app: native
---

# Build iOS with a CocoaPods-resolvable RevenueCat SDK

`purchases_flutter` moves from 11.0.0 to 10.19.0. Version 11 needs
`PurchasesHybridCommon` 20.0.0, which has never been published to the
CocoaPods trunk CDN, so a clean `pod install` could not resolve the iOS
workspace. 10.19.0 is the newest release whose `PurchasesHybridCommon`
dependency (19.17.0) is on trunk, and its Dart API matches every call the
OpenBudget Plus flow makes, so billing behaviour is unchanged.

The iOS project now builds the `Pods-Runner` aggregate target as part of the
shared schemes, so Xcode compiles the plugin frameworks before
`GeneratedPluginRegistrant.m` imports them. The Podfile no longer excludes the
`x86_64` simulator slice, which lets the pods build for the same architectures
as the Runner app.

`ios/Podfile.lock` and `pubspec.lock` are refreshed, which also records the
`package_info_plus` and `solana_kit_mobile_wallet_adapter` pods that were
missing from the stale iOS lockfile.
