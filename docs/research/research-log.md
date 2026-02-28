# Research Log

## 2026-02-27 - Session Start

### Scope

- Deep research on project direction with emphasis on:
  - Multi-currency valuation behavior and gaps.
  - Digital asset support (Solana-first direction).
  - Tax and PnL tracking potential.
  - Flutter + Serverpod architecture readiness for growth.
  - Product opportunities valuable to broader users.

### Early Confirmed Findings

- Multi-currency fields exist across budget/account/transaction domain models.
- No exchange-rate service/model detected yet.
- Net worth and home views currently aggregate as per-currency breakdowns, not normalized base-currency valuation.
- No wallet/chain/token/tax-lot domain primitives detected yet.

### Source Pointers (initial)

- `openbudget_server/migrations/20260216174003700/definition.sql`
- `openbudget_core/lib/src/constants/currencies.dart`
- `openbudget_app/lib/src/features/reports/providers/net_worth_provider.dart`
- `openbudget_app/lib/src/features/home/screens/home_screen.dart`

## 2026-02-27 - Existing Direction Signals

### Existing Documentation Focus

- Existing docs primarily emphasize UI flow parity, migration status, and test hardening.
- There is no dedicated strategic product/architecture roadmap document for currency valuation, crypto assets, tax, or AI planning.

### Source Pointers

- `docs/openbudget-screenflows.md`
- `docs/openbudget-migration-progress.md`
- `docs/how-to-use-openbudget-plan-and-priorities.md`

## 2026-02-27 - Server Capability Surface (Current)

### Implemented Domains

- Budgets, categories, envelopes, monthly allocations, envelope goals.
- Accounts and transactions (including transfer, split, duplicate detection, reconcile, age-of-money).
- Payees and transaction rules.
- Recurring transactions.
- Budget templates and export.

### Notable Existing "Intelligence Primitives"

- Rule-based envelope auto-assignment per payee.
- Duplicate transaction detection (same amount within ±1 day window).
- Age-of-money metric and recurring posting.

### Source Pointers

- `openbudget_server/lib/src/transaction_rules/transaction_rule_service.dart`
- `openbudget_server/lib/src/transactions/transaction_service.dart`
- `openbudget_server/lib/src/recurring_transactions/recurring_transaction_service.dart`
- `openbudget_server/lib/src/budgets/budget_service.dart`

## 2026-02-27 - Architecture Notes In Progress

### App Layer Pattern

- App providers frequently call `serverpodClientProvider` directly from feature modules.
- Repository abstraction layer is not present at app level.

### Source Pointers

- `openbudget_app/lib/src/features/**/providers/*.dart`
- `openbudget_app/lib/src/providers/serverpod_client_provider.dart`

## 2026-02-27 - Deliverables Added

### New Documents

- `docs/research/architecture-and-capabilities.md`
- `docs/research/roadmap-and-opportunities.md`

### Additional Highlights Captured

- Clarified that current multi-currency behavior is record-level tagging + per-currency breakdown display, not base-currency valuation over time.
- Captured server-side gap where transfer currency parity is not enforced at service level.
- Captured placeholder account field behavior in income/expense forms and partial account-transaction decoupling.
- Captured existing intelligence primitives (rules, duplicate checks, recurring auto-post, age-of-money) as foundations for later AI work.

### Key Source Pointers Added

- `openbudget_app/lib/src/features/transfers/screens/create_transfer_screen.dart`
- `openbudget_server/lib/src/transactions/transaction_service.dart`
- `openbudget_app/lib/src/features/transactions/screens/add_income_screen.dart`
- `openbudget_app/lib/src/features/transactions/screens/add_expense_screen.dart`
- `openbudget_app/lib/src/features/transaction_rules/providers/rule_match_provider.dart`
- `openbudget_app/lib/src/features/transactions/providers/duplicate_check_provider.dart`

## 2026-02-27 - Execution Backlog Added

### New Document

- `docs/research/implementation-backlog.md`

### What It Adds

- Prioritized epics (P0/P1/P2).
- Concrete schema/API work slices.
- Acceptance criteria for each milestone.
- Recommended sequencing and initial RFC list.

## 2026-02-28 - Solana Kit Implementation Slice Started

### Completed in Branch `feat/solana-kit-integration`

- Added Serverpod Solana domain primitives:
  - `SolanaWallet`
  - `SolanaWalletTransaction`
  - `SolanaWalletHolding`
  - `SolanaWalletSyncResult`
- Added `SolanaWalletEndpoint` and `SolanaWalletService` with:
  - wallet attach/list/get
  - sync via `solana_kit_helius`
  - parsed transaction storage (`description`, `txType`, `source`, program IDs)
  - holdings storage with DAS metadata and valuation fields
  - user metadata editing for wallet transaction category/tags/memo
- Added migration:
  - `openbudget_server/migrations/20260228132306430`
- Integrated wallet account UX in app:
  - new account type: `cryptoWallet` (Solana Wallet)
  - wallet address capture in add-account flow
  - account creation path calls wallet attach + initial sync
  - account detail wallet view for holdings + transaction timeline + metadata edits
- Added flavor-aware app bootstrap:
  - `main_dev.dart`, `main_prod.dart`
  - centralized app environment config with dev/prod API defaults
  - removed hardcoded localhost from client provider
- Added Android flavor setup:
  - `dev` and `prod` product flavors
  - dev applicationId suffix and app name resource
- Added iOS shared schemes:
  - `dev.xcscheme`
  - `prod.xcscheme`

### Validation Completed

- `dart pub get` (workspace) succeeded.
- `serverpod_cli generate` succeeded.
- `serverpod_cli create-migration` succeeded.
- `dart analyze openbudget_app openbudget_server` succeeded.
- Targeted account Flutter tests passed (`37` tests, `0` failures).
- Android device launch validation passed:
  - `flutter run --flavor dev -t lib/main_dev.dart -d SM02E4060324957 --no-resident`
  - built + installed + launched successfully.
- Android production flavor launch validation passed:
  - `flutter run --flavor prod -t lib/main_prod.dart -d SM02E4060324957 --no-resident`
  - built + installed + launched successfully.
- Resolved Android toolchain blocker by upgrading AGP from `8.7.3` to `8.9.1`.

### Tooling Note

- `mcp__dart__launch_app` currently fails in this environment with:
  - `ProcessException: No such file or directory`
  - command path: `/Users/ifiokjr/fvm/versions/3.41.1/bin/flutter run ...`
- Direct `flutter run` invocation succeeds, so this appears to be an MCP launcher environment issue, not an app build issue.

### Work Tracking Issues Created

- https://github.com/openbudgetfun/openbudget/issues/154
- https://github.com/openbudgetfun/openbudget/issues/155
- https://github.com/openbudgetfun/openbudget/issues/156
- https://github.com/openbudgetfun/openbudget/issues/157
- https://github.com/openbudgetfun/openbudget/issues/158
- https://github.com/openbudgetfun/openbudget/issues/159

## 2026-02-28 - Wallet UX Polish + Mobile MCP Validation

### Product/UX Progress

- Upgraded Solana account detail experience from basic list tiles to a structured wallet dashboard:
  - wallet hero card with sync state, cluster/status chips, estimated value, quick copy.
  - summary metrics (fungible assets, NFT assets, tagged transactions, last activity).
  - holdings cards with clearer hierarchy, program tags, valuation emphasis.
  - transaction cards with source/type/program chips and metadata edit flow.
- Improved wallet creation UX in add-account:
  - wallet-specific helper card and guidance.
  - monospaced wallet-address entry and clearer validation hint copy.
- Improved backend fallback description synthesis for wallet transactions:
  - appends recognized program context (for example SPL Token, Token-2022, Jupiter, Pump.fun) when direct provider descriptions are missing.

### Tooling and Runflow Progress

- Added Flutter `default-flavor: dev` in `openbudget_app/pubspec.yaml`.
  - Fixes `flutter run` without explicit `--flavor` in local tooling that cannot pass flavor args.
  - Enables `mcp__dart__launch_app` for Android dev build path.
- Mobile MCP validation now succeeds:
  - `mcp__dart__launch_app` on device `SM02E4060324957` with `lib/main_dev.dart` succeeded.
  - Build output confirmed `assembleDevDebug`.
  - App started and attached to DTD.
  - `mcp__dart__get_runtime_errors` returned none.
- Observed and handled expected install conflict once (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`) due existing signature mismatch on `com.openbudget.app.dev`; tool uninstalled and reinstalled successfully.
- Added Mobile MCP screenshot workflow:
  - driver-enabled entrypoint at `openbudget_app/test_driver/main_driver.dart`.
  - captured Android screenshots and posted them to PR comments.

### Verification Completed

- `dart analyze openbudget_app openbudget_server` -> clean.
- Widget tests passed after UX updates:
  - `add_account_screen_test.dart`
  - `account_detail_screen_test.dart`

## 2026-02-28 - Login UX Refresh + Screenshot Cycle

### Product/UX Progress

- Refined the login screen visual structure:
  - layered backdrop accents for depth.
  - elevated auth card with cleaner hierarchy.
  - stronger title/subtitle treatment and form spacing.
- Added resilient app-mark rendering:
  - `_OpenBudgetMark` now uses an icon fallback if branding image assets are missing.
  - prevents widget-test/runtime crashes when icon preview assets are unavailable in test bundles.

### Validation Completed

- `flutter test openbudget_app/test/features/auth/screens/login_screen_test.dart` passed.
- `flutter test` regression slice passed:
  - `login_screen_test.dart`
  - `account_detail_screen_test.dart`
  - `add_account_screen_test.dart`
- `dart analyze openbudget_app openbudget_server` returned no issues.

### Mobile MCP + Screenshot Evidence

- Launched app on Android device `SM02E4060324957` via `mcp__dart__launch_app` using `test_driver/main_driver.dart`.
- Connected through DTD and captured verification screenshot via `mcp__dart__flutter_driver` (`screenshot` command).
- Captured additional deterministic PNG evidence from the same device state and saved in repo:
  - `docs/research/screenshots/2026-02-28/login-redesign-initial.png`
  - `docs/research/screenshots/2026-02-28/login-redesign-email-focus.png`
  - `docs/research/screenshots/2026-02-28/login-redesign-filled.png`

## 2026-02-28 - Solana Auto-Category Suggestions (UI)

### Product/UX Progress

- Added automatic category suggestion heuristics for uncategorized Solana wallet transactions.
- Suggestions are derived from parsed transaction signals (`txType`, `source`, and program IDs), with current mappings including:
  - Swaps
  - Transfers
  - Staking
  - NFT
  - Lending
  - Income
- UI behavior:
  - transaction cards now show a `Suggested: ...` chip when no user category exists.
  - metadata edit dialog pre-fills category field with the suggestion (still fully editable).
  - search now includes suggested category text for uncategorized transactions.
- Important semantics retained:
  - `Needs category` filter still keys off user-managed category only (suggestions do not mark a transaction as categorized).

### Validation Completed

- `flutter test openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart` passed.
- Regression test slice passed:
  - `login_screen_test.dart`
  - `account_detail_screen_test.dart`
  - `add_account_screen_test.dart`
- `dart analyze openbudget_app` returned no issues.
