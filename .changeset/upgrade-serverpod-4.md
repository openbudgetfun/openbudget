---
openbudget_server: chore
openbudget_client: chore
openbudget_app: chore
---

# Upgrade to Serverpod 4.1 and Flutter 3.47

Move the workspace to Flutter 3.47.7, Dart 3.13, and Serverpod 4.1.0, with refreshed application and development dependencies. Regenerate the protocol and providers, migrate descending database queries, and update the analyzer plugin for the new SDK. Apply the single migration for Serverpod's updated module schemas; it recreates the transient auth rate-limit attempt table. Patrol keeps its `integration_test` directory, and native Apple builds retain CocoaPods with a macOS 12 minimum required by Flutter.
