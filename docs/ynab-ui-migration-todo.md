# OpenBudget UI Migration Tracker (from `~/Downloads/ynab-ui`)

Last updated: 2026-02-23 (custom target editor parity + integration coverage)

## Scope

- Source inspiration: `~/Downloads/ynab-ui`
- Product target: **OpenBudget branding and language only** (no YNAB naming in shipped UI)
- Goal: reach parity for core budgeting flows, then polish edge-case and advanced flows

## Progress Snapshot

- Overall migration progress: **~95%**
- Core plan/settings/auth/navigation flows: **implemented**
- Advanced accounts/transactions/reports flows: **in progress**

## Completed Flows

- [x] Login screen parity with OpenBudget branding (social + email login layout)
- [x] Create plan onboarding welcome screen and personalize CTA
- [x] Plan onboarding account CTAs route directly to Add Account flow
- [x] Settings root screen structure and section grouping
- [x] Plan Settings screen
- [x] Currency screen
- [x] Display Options (theme + balance style)
- [x] Account settings flow:
  - [x] Account profile + login methods surface
  - [x] Delete account confirmation screen
  - [x] Post-delete success state
- [x] Plan screen categories tab baseline structure
- [x] Plan screen spotlight tab baseline structure
- [x] Plan month switching controls (previous/next month navigation)
- [x] Accounts list parity pass:
  - [x] Notifications banner
  - [x] All transactions entry point
  - [x] Top-right quick actions (add + overflow menu)
  - [x] In-list add-account CTA
  - [x] Add-accounts institution loading state
  - [x] Full-screen edit account form parity
  - [x] Loan account detail tabs (overview + activity)
  - [x] Loan target create/edit interaction on loan detail screen
  - [x] Unlinked account type selection validation before submit
- [x] Plan menu actions:
  - [x] Undo last move
  - [x] Route transitions after menu dismissal (prevents popup overlay artifacts)
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
  - [x] Undo integration from plan menu
  - [ ] Additional visual parity polish for row spacing/typography
- [x] Plan menu behavior polish for mobile transitions

## Pending Flows (Next Batches)

- [ ] Accounts flows
  - [x] Add account wizard parity
  - [x] Search bank flow
  - [x] Account details (cash flow baseline + overflow actions)
  - [x] Account details (loan overview + activity tabs)
  - [x] Reconcile account (from account detail menu)
  - [x] Delete account
- [ ] Transactions flows
  - [x] Transaction detail parity
  - [x] Edit/delete/clear transaction flows
  - [ ] Approve scheduled transaction
  - [x] Filtering transactions
- [ ] Budget/category advanced flows
  - [x] Add custom target flow
  - [x] Loan target flow
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
- [x] Integration coverage for Undo + recent-moves source chip drilldown
- [x] Integration coverage for onboarding account CTA routing
- [x] Integration coverage for plan month switching
- [x] Integration coverage for add-account wizard/search flow
- [x] Integration coverage for unlinked account type selection validation
- [x] Integration coverage for account detail overflow actions and uncleared filtering
- [x] Integration coverage for account detail edit form presentation
- [x] Integration coverage for loan account overview/activity tabs
- [x] Integration coverage for loan target create/edit interaction
- [x] Integration coverage for closed-account edit actions (delete/reopen visibility)
- [x] Integration coverage for account reconcile confirmation prompt (Yes/No/Cancel)
- [x] Integration coverage for transaction list filters + edit/flag interactions
- [x] Integration coverage for account settings -> delete account flow
- [x] Integration CI configured to fail on any individual integration test failure
- [x] Integration CI hardened to detect failure markers / no-tests-ran false-green output
- [x] Integration coverage for opening custom target editor and validating Save button enablement
- [ ] Expand integration tests for remaining pending batches above
