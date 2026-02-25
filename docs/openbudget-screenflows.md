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
  - Desktop Add Accounts empty-search-results guidance parity
  - Desktop Add Accounts helper guidance parity (helper text remains visible before and after search queries)
  - Search submit stays in Add Accounts filtering mode (no accidental jump into unlinked flow)
  - Desktop guardrails for linked-bank loading overlay and account-menu reconcile/edit states
  - Desktop unlinked-account form and success-step parity coverage
  - Desktop unlinked-account step-reset hardening (scroll position reset when returning from account type and after add-another)
  - Add Accounts unlinked step hardening (independent per-step scroll state + keyed controls for reliable mobile/desktop interactions)
- Transactions
  - Add expense/income/transfer, filtering, edit and action sheets, review queue approval flow
- Reflect and reports
  - Spending Breakdown (month and preset ranges), Net Worth detail, dark-mode parity
  - Spending Breakdown preset selector regression coverage (3/6/12 range recalculation)
  - Desktop Spending Breakdown preset parity coverage for six-month range totals
- Recent Moves
  - Tabs, coach dialog, empty and populated states, source/destination drilldowns
  - Desktop modal/tab-switch parity coverage for All and Moved tabs

## Verification Gates

- Widget and unit tests for major migrated screens.
- Patrol integration suites under `/openbudget_app/integration_test`.
- CI hardening for integration reliability:
  - Per-file timeout enforcement
  - Failure-marker detection and per-file failure accounting to prevent false-green runs
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
- Spending Breakdown desktop last-six-months preset: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr146/reports-spending-breakdown-last-six-months-desktop-screen.png
- Add Accounts desktop linked-bank loading overlay: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr145/add-accounts-loading-overlay-desktop-screen.png
- Accounts desktop reconcile dialog: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr145/accounts-reconcile-dialog-desktop-screen.png
- Accounts desktop edit account form: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr145/accounts-edit-account-desktop-screen.png
- Add Unlinked Account desktop form: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr148/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr148/add-unlinked-account-desktop-success-screen.png
- Recent Moves desktop (All tab): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr149/recent-moves-desktop-screen.png
- Recent Moves desktop (Moved tab): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr149/recent-moves-desktop-moved-screen.png
- Add Account type selection (stability pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr150/add-account-type-selection.png
- Add Accounts desktop linked-bank loading overlay (stability pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr150/add-accounts-loading-overlay-desktop-screen.png
- Add Accounts desktop filtered results (stability pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr150/add-accounts-search-desktop-citi-results-screen.png
- Add Unlinked Account desktop form (stability pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr150/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (stability pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr150/add-unlinked-account-desktop-success-screen.png
- Add Account type selection (Patrol rerun): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr163/add-account-type-selection.png
- Add Accounts desktop linked-bank loading overlay (Patrol rerun): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr163/add-accounts-loading-overlay-desktop-screen.png
- Add Accounts desktop filtered results (Patrol rerun): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr163/add-accounts-search-desktop-citi-results-screen.png
- Add Unlinked Account desktop form (Patrol rerun): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr163/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (Patrol rerun): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr163/add-unlinked-account-desktop-success-screen.png
- Add Accounts desktop filtered results (targeted capture stabilization): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr151/add-accounts-search-desktop-citi-results-screen.png
- Add Account type selection (targeted capture stabilization): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr151/add-account-type-selection.png
- Add Unlinked Account desktop form (targeted capture stabilization): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr151/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (targeted capture stabilization): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-pr151/add-unlinked-account-desktop-success-screen.png
- Add Unlinked Account desktop form (main `a13e4e5` layout parity fix): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-a13e4e5/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (main `a13e4e5` layout parity fix): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-a13e4e5/add-unlinked-account-desktop-success-screen.png
- Add Account type selection (desktop gating regression coverage): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-gating/add-account-type-selection.png
- Add Unlinked Account desktop form (desktop gating regression coverage): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-gating/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (desktop gating regression coverage): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-gating/add-unlinked-account-desktop-success-screen.png
- Add Accounts desktop bank search (clean fallback backend): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-screenshot-backend/add-accounts-search-desktop-screen.png
- Add Unlinked Account desktop form (clean fallback backend): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-screenshot-backend/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop success (clean fallback backend): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-screenshot-backend/add-unlinked-account-desktop-success-screen.png
- Add Accounts desktop bank search (scroll-reset regression pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-scroll-reset/add-accounts-search-desktop-screen.png
- Add Unlinked Account desktop form (scroll-reset regression pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-scroll-reset/add-unlinked-account-desktop-form-screen.png
- Add Unlinked Account desktop reset state (scroll-reset regression pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-scroll-reset/add-unlinked-account-desktop-reset-screen.png
- Add Unlinked Account desktop success (scroll-reset regression pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-unlinked-scroll-reset/add-unlinked-account-desktop-success-screen.png
- Add Accounts desktop empty results guidance: https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-empty-results/add-accounts-search-desktop-empty-results-screen.png
- Add Accounts desktop bank search (helper-guidance parity pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-empty-results-helper-text/add-accounts-search-desktop-screen.png
- Add Accounts desktop empty results (helper-guidance parity pass): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-25-main-empty-results-helper-text/add-accounts-search-desktop-empty-results-screen.png
