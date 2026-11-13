---
openbudget_app: test
openbudget_test_utils: test
---

# Keep every test off the live API

All `openbudget_app` widget and Patrol integration tests now install an HTTP guard from `openbudget_test_utils`: the moment a request tries to leave the test (including to `api.openbudget.app`) it throws a `StateError` naming the Serverpod endpoint inside the test that caused it. Un-guarded, such a request hung until the harness cancelled it and failed the run after completion (`SocketException: Connection attempt cancelled`), which flaked the `integration-test` CI job. The flows that still reached un-faked providers now answer them with local fixtures: the Plaid link fake covers `createLinkToken` on mobile targets, and the reporting-currency, cross-currency-transfer, net-worth-fx, settings and reports flows fake `userSettingsProvider`, `entityListProvider`, `netWorthForEntitiesProvider`, `netWorthHistoryProvider`, `institutionCatalogProvider` and `budgetMonthGroupsProvider`.
