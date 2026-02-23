# OpenBudget UI Migration Tracker (from `~/Downloads/ynab-ui`)

Last updated: 2026-02-23

## Scope

- Source inspiration: `~/Downloads/ynab-ui`
- Product target: **OpenBudget branding and language only** (no YNAB naming in shipped UI)
- Goal: reach parity for core budgeting flows, then polish edge-case and advanced flows

## Progress Snapshot

- Overall migration progress: **~62%**
- Core plan/settings/auth/navigation flows: **implemented**
- Advanced accounts/transactions/reports flows: **in progress**

## Completed Flows

- [x] Login screen parity with OpenBudget branding (social + email login layout)
- [x] Create plan onboarding welcome screen and personalize CTA
- [x] Settings root screen structure and section grouping
- [x] Plan Settings screen
- [x] Currency screen
- [x] Display Options (theme + balance style)
- [x] Plan screen categories tab baseline structure
- [x] Plan screen spotlight tab baseline structure
- [x] Plan menu actions:
  - [x] Collapse/Expand category groups
  - [x] Hide progress bars
  - [x] Hide amounts
  - [x] Open Recent Moves
- [x] Recent Moves screen:
  - [x] Tabs (`All`, `Moved`, `Assigned`)
  - [x] Intro coach dialog
  - [x] Empty state
  - [x] Non-empty grouped list
- [x] Moves detail screen for envelope history
- [x] Category quick inline amount editor with keypad
- [x] Category detail screen:
  - [x] Underfunded target state
  - [x] Target-met state
  - [x] Notes
  - [x] Rename/Hide/Delete actions
  - [x] Snooze toggle

## In Progress

- [ ] Screenshot capture pipeline stabilization across integration runtimes (`flutter-tester` cannot capture screenshots via plugin)
- [ ] Recent Moves interaction polish:
  - [x] Destination chip navigation
  - [x] Source chip navigation
  - [ ] Additional visual parity polish for row spacing/typography
- [ ] Plan menu behavior polish for mobile transitions

## Pending Flows (Next Batches)

- [ ] Accounts flows
  - [ ] Add account wizard parity
  - [ ] Search bank flow
  - [ ] Account details (cash/loan)
  - [ ] Reconcile account
  - [ ] Delete account
- [ ] Transactions flows
  - [ ] Transaction detail parity
  - [ ] Edit/delete/clear transaction flows
  - [ ] Approve scheduled transaction
  - [ ] Filtering transactions
- [ ] Budget/category advanced flows
  - [ ] Add custom target flow
  - [ ] Loan target flow
  - [ ] Cover overspending flow
  - [ ] Reorder categories flow parity
  - [ ] Hide category flow polish
- [ ] Reports and analysis parity
  - [ ] Net worth visual parity
  - [ ] Spending breakdown parity
- [ ] Appearance/system flows
  - [ ] Dark mode parity pass
  - [ ] App icon switching parity pass

## Validation Status

- [x] Widget tests for major migrated screens
- [x] Integration flow coverage for plan/settings/auth/more/navigation
- [x] Integration CI configured to fail on any individual integration test failure
- [ ] Expand integration tests for remaining pending batches above
