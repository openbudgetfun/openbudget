# OpenBudget Screenflows

Last updated: 2026-02-25

Progress checklist: `docs/openbudget-migration-progress.md`

## Status

- Migration from the reference `ynab-ui` set is complete for core and advanced flows.
- Shipped UI now follows OpenBudget branding and language standards.
- Patrol integration coverage is active for all critical user journeys.

## Implemented Flow Groups

- Auth and onboarding
  - Login, register, welcome, personalize plan, onboarding account CTAs
- Plan and budgeting
  - Categories and Spotlight tabs, month switching, quick amount editor, reorder, overspending coverage
- Settings and appearance
  - Settings root, plan settings, currency, display options, app icon switching (light/dark aware)
- Accounts
  - Add account wizard, institution search/filtering, unlinked account validation, account detail actions, reconcile, loan overview/activity, edit/close
  - Desktop/tablet Add Accounts search parity (search labeling, two-column institution grid, unlinked CTA alignment)
  - Search submit stays in Add Accounts filtering mode (no accidental jump into unlinked flow)
- Transactions
  - Add expense/income/transfer, filtering, edit and action sheets, review queue approval flow
- Reflect and reports
  - Spending Breakdown (month and preset ranges), Net Worth detail, dark-mode parity
  - Spending Breakdown preset selector regression coverage (3/6/12 range recalculation)
- Recent Moves
  - Tabs, coach dialog, empty and populated states, source/destination drilldowns

## Verification Gates

- Widget and unit tests for major migrated screens.
- Patrol integration suites under `/openbudget_app/integration_test`.
- CI hardening for integration reliability:
  - Per-file timeout enforcement
  - Failure-marker detection to prevent false-green runs
  - Shared dependency resolution + `--no-pub` Patrol file execution to reduce redundant setup time
  - Repaint fallback screenshot capture on `flutter-tester`
- Branding regression guard:
  - `/openbudget_app/test/branding/no_ynab_branding_test.dart`

## Runtime Artifacts (Recent)

- Add Accounts loading institutions: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr135/add-accounts-loading-institutions-screen.png
- Add Accounts bank search: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr136/add-accounts-search-screen.png
- Add Account type selection: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr137/add-account-type-selection.png
- Add Accounts desktop bank search: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr140/add-accounts-search-desktop-screen.png
- Add Accounts search-submit results state: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr141/add-accounts-search-submit-results.png
- Spending Breakdown last-six-months preset: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr142/reports-spending-breakdown-last-six-months.png
