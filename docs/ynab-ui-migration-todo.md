# OpenBudget UI Migration Tracker (from `~/Downloads/ynab-ui`)

Last updated: 2026-02-24 (Add Accounts bank-search filtering polish)

## Scope

- Source inspiration: `~/Downloads/ynab-ui`
- Product target: **OpenBudget branding and language only** (no YNAB naming in shipped UI)
- Goal: reach parity for core budgeting flows, then polish edge-case and advanced flows

## Progress Snapshot

- Overall migration progress: **~99.9%**
- Core plan/settings/auth/navigation flows: **implemented**
- Advanced accounts/transactions flows: **implemented**
- Reports/appearance polish flows: **implemented**

## Screenflow Checkpoints

- 2026-02-24: Reflect -> Spending Breakdown -> Preset mode now aggregates multi-month data from the selected month backward (`Last 3/6/12 Months`) with visible range label (`Month YYYY–Month YYYY`) and outflow-only category totals.
- 2026-02-24: Reflect -> Spending Breakdown (Preset) now shows both controls used in the reference flow: `Preset Range` selector and month anchor row (`< Month YYYY >`) for range pivoting.
- 2026-02-24: Reflect and Spending Breakdown report screens now use theme-aware surfaces/backgrounds/dividers for dark appearance parity instead of fixed light palette tokens.
- 2026-02-24: Patrol flow updated to assert preset range rendering in integration coverage (`openbudget_app/integration_test/reports_flow_test.dart`).
- 2026-02-24: Patrol flow expanded to assert deterministic preset month-pivot ranges (`December 2025–February 2026` then `November 2025–January 2026`) and aggregated totals.
- 2026-02-24: Patrol flow expanded to assert dark-mode scaffold background parity for Spending Breakdown.
- 2026-02-24: Appearance preference notifiers now persist theme/app-icon/privacy formatting state to local UI preferences and hydrate on launch.
- 2026-02-24: Settings -> App Icon screen updated to use theme-aware surface/background tokens for dark-mode parity.
- 2026-02-24: App icon previews now resolve by current theme brightness (`light`/`dark`) across Settings -> App Icon and Login branding mark.
- 2026-02-24: Added dedicated Patrol integration coverage for app icon dark-mode preview asset + style persistence (`integration_test/app_icon_flow_test.dart`).
- 2026-02-24: Patrol screenshot capture now falls back to render-tree capture when `IntegrationTestWidgetsFlutterBinding.takeScreenshot` is unavailable (e.g., `flutter-tester`), writing PNG artifacts instead of skipping.
- 2026-02-24: Recent Moves list rows now use improved day-heading typography (relative label + date split) and divider-backed spacing for closer parity.
- 2026-02-24: Add Accounts flow now includes staged loading states (`Loading...` then `Loading institutions...`) with OpenBudget-branded logo treatment before bank search.
- 2026-02-24: Add Accounts bank search now supports live filtering, empty-state messaging, and richer institution tile styling for parity with the reference flow.
- 2026-02-24: PR screenshot artifacts policy active: every migration PR must include at least one runtime screenshot link in PR body/comments.
- 2026-02-24: PR #127 artifact screenshot (Preset mode): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr127/reports-preset-mode.png
- 2026-02-24: PR #129 artifact screenshot (Preset range + month anchor): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr129/reports-preset-range-month-anchor.png
- 2026-02-24: PR #130 artifact screenshot (Dark-mode spending breakdown): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr130/reports-dark-mode-runtime.png
- 2026-02-24: PR #131 artifact screenshot (Dark-mode app icon settings): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr131/settings-app-icon-dark.png
- 2026-02-24: PR #132 artifact screenshot (App icon dark-preview parity): https://f002.backblazeb2.com/file/openbudget/screenshots/2026-02-24-pr132/settings-app-icon-dark-parity.png

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
- [x] Reorder categories flow parity
- [x] Edit Plan setup flow:
  - [x] Cost-to-be-me header and monthly targets/income card
  - [x] New Group and Reorder controls
  - [x] Category-group details sheet with hide/delete actions
  - [x] Add Target entry from edit-plan category rows
- [x] Reflect dashboard parity:
  - [x] Spending Breakdown preview card
  - [x] Net Worth preview card
  - [x] Age of Money preview card
- [x] Spending Breakdown detail parity pass:
  - [x] Month/Preset controls
  - [x] Category distribution strip and list
  - [x] Positive inflow summary
- [x] Net Worth detail visual parity pass:
  - [x] Current total + assets/liabilities summary
  - [x] Understanding Net Worth explainer block

## In Progress

- [x] Screenshot capture pipeline stabilization across integration runtimes (`flutter-tester` cannot capture screenshots via plugin)
- [ ] Recent Moves interaction polish:
  - [x] Destination chip navigation
  - [x] Source chip navigation
  - [x] Undo integration from plan menu
  - [x] Additional visual parity polish for row spacing/typography
- [x] Plan menu behavior polish for mobile transitions

## Pending Flows (Next Batches)

- [x] Accounts flows
  - [x] Add account wizard parity
  - [x] Search bank flow
  - [x] Account details (cash flow baseline + overflow actions)
  - [x] Account details (loan overview + activity tabs)
  - [x] Reconcile account (from account detail menu)
  - [x] Delete account
- [x] Transactions flows
  - [x] Transaction detail parity
  - [x] Edit/delete/clear transaction flows
  - [x] Approve scheduled transaction / review queue flow
  - [x] Filtering transactions
- [x] Budget/category advanced flows
  - [x] Add custom target flow
  - [x] Loan target flow
  - [x] Cover overspending flow
  - [x] Reorder categories flow parity
  - [x] Hide category flow polish (edit-plan details dialog + confirmation)
- [x] Reports and analysis parity
  - [x] Net worth visual parity
  - [x] Spending breakdown parity
  - [x] Multi-month/preset advanced analytics polish
- [ ] Appearance/system flows
  - [x] Dark mode parity pass
  - [x] App icon switching parity pass

## Validation Status

- [x] Widget tests for major migrated screens
- [x] Integration flow coverage for plan/settings/auth/more/navigation
- [x] Integration coverage for Undo + recent-moves source chip drilldown
- [x] Integration coverage for onboarding account CTA routing
- [x] Integration coverage for plan month switching
- [x] Integration coverage for add-account wizard/search flow
- [x] Integration coverage for add-account live-search filtering results
- [x] Integration coverage for unlinked account type selection validation
- [x] Integration coverage for account detail overflow actions and uncleared filtering
- [x] Integration coverage for account detail edit form presentation
- [x] Integration coverage for loan account overview/activity tabs
- [x] Integration coverage for loan target create/edit interaction
- [x] Integration coverage for closed-account edit actions (delete/reopen visibility)
- [x] Integration coverage for account reconcile confirmation prompt (Yes/No/Cancel)
- [x] Integration coverage for unlinked-account submit success flow
- [x] Integration coverage for transaction list filters + edit/flag interactions
- [x] Integration coverage for review-transactions sheet (select, approve, empty state)
- [x] Integration coverage for overspending coverage sheet opening
- [x] Integration coverage for category reorder interactions
- [x] Integration coverage for account settings -> delete account flow
- [x] Integration CI configured to fail on any individual integration test failure
- [x] Integration CI hardened to detect failure markers / no-tests-ran false-green output
- [x] Integration tests migrated to Patrol (`patrolWidgetTest`) across all flow files
- [x] Integration coverage for opening custom target editor and validating Save button enablement
- [x] Integration coverage for Reflect dashboard -> Spending Breakdown + Net Worth flows
- [x] Integration coverage for dark-mode report surfaces (Reflect -> Spending Breakdown)
- [x] Unit coverage for persisted appearance preference hydration/write behavior
- [x] Integration coverage for app-icon dark-mode preview + selection persistence
- [x] Integration CI enforces per-file timeout for stuck integration files with explicit timeout errors
- [x] Integration screenshot capture persists runtime PNG artifacts on `flutter-tester` via repaint fallback
- [ ] Expand integration tests for remaining pending batches above

## Deletion Criteria

- [ ] All remaining `Pending Flows` checkboxes are complete
- [ ] Remaining `Validation Status` checkboxes are complete
- [ ] Final OpenBudget branding review confirms no YNAB labels in shipped UI

When every item above is checked, this migration tracker can be safely deleted.
