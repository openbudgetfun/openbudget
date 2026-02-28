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

## 2026-02-28 - Solana P&L Foundation (Issue #162) In Progress

### Schema + Protocol Progress

- Added estimated P&L fields to Solana wallet models:
  - holdings: `estimatedCostBasis`, `estimatedUnrealizedPnl`, `estimatedUnrealizedPnlPercent`, `estimatedRealizedPnl`, `pnlCurrency`, `pnlAsOf`
  - transactions: `estimatedCostBasis`, `estimatedProceeds`, `estimatedRealizedPnl`, `pnlCurrency`, `taxYear`
- Regenerated Serverpod protocol/client artifacts.
- Created migration:
  - `openbudget_server/migrations/20260228190201911`

### Backend Engine Progress

- Added first-pass estimated cost basis engine in `SolanaWalletService`:
  - computes wallet token net flow from `tokenTransfersJson`
  - tracks running per-asset basis state
  - writes transaction-level estimated realized P&L and tax year
  - writes holding-level estimated basis/unrealized/realized values
  - runs after holdings sync in wallet sync pipeline
- Added warning paths for partial estimates (for example missing price or disposal exceeding tracked basis quantity).

### App Surfacing Progress

- Wallet detail now surfaces estimated P&L:
  - summary metric cards include realized/unrealized P&L totals.
  - holding cards show basis + unrealized P&L (with percent when available).
  - transaction cards show realized P&L chip and tax-year chip when present.
- Updated wallet widget test fixtures/assertions for the new metadata rendering.

### Validation Completed

- `flutter test` regression slice passed:
  - `account_detail_screen_test.dart`
  - `login_screen_test.dart`
  - `add_account_screen_test.dart`
- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.

### Validation Note

- `dart test` in `openbudget_server` currently exits during integration suite loading in this environment (no per-test assertion output). App/server compile and targeted widget suites are still passing.

## 2026-02-28 - Solana FIFO Lots + Tax-Year Summary Surfacing

### Backend Engine Progress

- Refactored estimated basis logic in `SolanaWalletService` from aggregate-average state to FIFO lot tracking:
  - introduced per-asset FIFO lots for acquisition/disposal matching.
  - disposal events now consume lots in FIFO order.
  - holding-level basis estimation now derives from remaining lots, with warnings when on-chain balances diverge from tracked lots.
- Added tax-year summary API:
  - protocol model: `SolanaWalletTaxYearSummary`.
  - endpoint/service method: `solanaWallet.listTaxYearSummaries(budgetId, walletId)`.
  - server/client generated protocol artifacts updated.

### App Surfacing Progress

- Added `solanaWalletTaxYearSummariesProvider` and integrated it into the Solana wallet detail UI.
- Added a dedicated wallet section: `Tax Year P&L (estimated)` with per-year cards (disposals, proceeds, basis, realized P&L).
- Wallet dashboard tests updated for the new section and revised scroll/assertion behavior.

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- Targeted widget regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured fresh Android device screenshots during this cycle:
  - `docs/research/screenshots/2026-02-28/solana-tax-year-cycle-login.png`
  - `docs/research/screenshots/2026-02-28/solana-tax-year-cycle-login-email-focus.png`

## 2026-02-28 - Pricing Quality Metadata + Cached Fallback (Issue #163)

### Backend Progress

- Extended `SolanaWalletHolding` pricing metadata:
  - `priceQuality` (`provider`, `derived`, `stale_cache`, `unpriced`)
  - `isPriceStale` (cached fallback indicator)
- Added fallback valuation behavior in holdings sync:
  - primary: direct Helius DAS token price.
  - derived: if `pricePerToken` is missing but `totalPrice` exists, derive unit price.
  - cached fallback: when provider returns no fresh price, reuse prior stored price for the same asset and mark stale.
- Preserved valuation currency flow while surfacing warnings for cached/unpriced assets.
- Added migration:
  - `openbudget_server/migrations/20260228201106267`

### App Progress

- Wallet holding cards now display pricing quality chips and stale/unpriced states:
  - quality chip from `priceQuality`
  - stale chip when cached valuation is used
  - unpriced warning chip + text when no valuation source is available

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- Targeted widget regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/pricing-quality-cycle-login.png`

## 2026-02-28 - Wallet Valuation Coverage Metrics (Issue #164)

### Backend Progress

- Extended `SolanaWalletSyncResult` API payload with valuation coverage fields:
  - `pricedHoldingCount`
  - `staleHoldingCount`
  - `unpricedHoldingCount`
  - `valuationCoverageRatio`
- Updated holdings sync summary accounting in `SolanaWalletService` to classify each synced holding as:
  - priced (fresh)
  - stale-priced (cached fallback)
  - unpriced

### App Progress

- Updated sync success snackbar to include coverage counts and unpriced tally.
- Added wallet dashboard summary cards:
  - `Valuation Coverage`
  - `Unpriced Assets`
- Expanded wallet snapshot aggregation logic to compute coverage metrics from holdings.

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- Targeted widget regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/coverage-metrics-cycle-login.png`

## 2026-02-28 - Wallet-Centric Transaction Interpretation Enrichment

### Backend Progress

- Updated fallback transaction description synthesis to incorporate wallet-centric flow direction:
  - counts inbound/outbound SOL and token transfers relative to the tracked wallet address.
  - maps common activity text to clearer user language (`Token swap`, `Trade on Pump.fun`, `SOL transfer sent/received`, `Token transfer sent/received`, `NFT activity`).
- Added source/program context chaining to preserve protocol visibility while improving readability.
- Opened follow-up issue for deeper protocol template coverage:
  - `#165` Expand Solana transaction interpretation matrix with protocol templates.

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- Targeted widget regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/transaction-interpretation-cycle-login.png`

## 2026-02-28 - Interpretation Confidence Metadata (Issue #165)

### Backend Progress

- Added `interpretationConfidence` to `SolanaWalletTransaction` protocol/table model.
- Updated fallback interpretation engine to return structured output:
  - `description`
  - `confidence` (`high`, `medium`, `low`)
- Confidence assignment policy:
  - `high` for provider direct descriptions and strong protocol matches (for example Jupiter/Pump.fun/NFT marketplace signals).
  - `medium` for wallet-flow directional heuristics (sent/received patterns).
  - `low` for generic type/source fallbacks.
- Added migration:
  - `openbudget_server/migrations/20260228202406907`

### App Progress

- Transaction cards now show an interpretation confidence chip when available.

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- Targeted widget regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/interpretation-confidence-cycle-login.png`

## 2026-02-28 - Interpreter Module Extraction + Fixture Tests

### Backend Progress

- Extracted fallback interpretation logic into a dedicated module:
  - `openbudget_server/lib/src/solana_wallets/solana_transaction_interpreter.dart`
- Updated `SolanaWalletService` to delegate interpretation to this module.
- Added focused unit tests for interpreter behavior:
  - `openbudget_server/test/unit/solana_wallets/solana_transaction_interpreter_test.dart`
- Fixture coverage currently includes:
  - provider-direct descriptions
  - Jupiter swap
  - Pump.fun trade
  - directional SOL transfer
  - generic low-confidence fallback

### Validation Completed

- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- New unit suite passed:
  - `dart test openbudget_server/test/unit/solana_wallets/solana_transaction_interpreter_test.dart`
- Existing app regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/interpreter-fixtures-cycle-login.png`

## 2026-02-28 - Protocol Template Expansion (Issue #165) Continued

### Backend Progress

- Expanded interpreter protocol matching coverage for additional high-signal sources:
  - Raydium swap pattern
  - Orca swap pattern
  - NFT marketplace buy/sell flow heuristics for Magic Eden / Tensor
- Added wallet-flow amount context:
  - tracks native lamports in/out per interpreted transaction
  - appends SOL amount summary to fallback descriptions (for example `SOL out 1.5 SOL`)
- Added lower-confidence generalized classifications for emerging non-transfer types:
  - staking activity
  - liquidity position updates

### Test Coverage Added

- Extended `solana_transaction_interpreter_test.dart` with new fixture-style cases:
  - Raydium swap (`high` confidence)
  - Orca swap (`high` confidence)
  - NFT purchase flow on Magic Eden (`high` confidence + SOL amount context assertion)
  - SOL transfer summary assertion includes amount text

### Validation Completed

- `dart test openbudget_server/test/unit/solana_wallets/solana_transaction_interpreter_test.dart` passed.
- `flutter test` targeted regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`
- `dart analyze openbudget_server openbudget_app openbudget_client` returned no issues in this cycle.

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/protocol-templates-cycle-login.png`

## 2026-02-28 - Multi-Source Pricing: Jupiter Fallback (Issue #163)

### Backend Progress

- Added a dedicated Jupiter pricing client:
  - `openbudget_server/lib/src/solana_wallets/jupiter_price_client.dart`
  - fetches USD prices from Jupiter Price API v3 (`lite-api.jup.ag`) in batches.
  - supports multiple response shapes (`data.price`, `usdPrice`, scalar values) to remain resilient during API payload transitions.
- Wired Jupiter as a fallback source in holdings sync:
  - when Helius DAS price is unavailable for fungible tokens, sync now attempts Jupiter price lookup by mint.
  - successful fallback is persisted with pricing metadata:
    - `priceSource = jupiter_price_v3`
    - `priceQuality = provider`
    - `priceCurrency = USD`
- Existing stale-cache behavior remains in place for tokens that remain unpriced after external provider attempts.

### Test Coverage Added

- Added parser-focused unit coverage:
  - `openbudget_server/test/unit/solana_wallets/jupiter_price_client_test.dart`
  - validates both wrapped (`data`) and legacy (`usdPrice`) response structures.
  - validates filtering of invalid/non-positive price entries.

### Validation Completed

- `dart test openbudget_server/test/unit/solana_wallets/jupiter_price_client_test.dart openbudget_server/test/unit/solana_wallets/solana_transaction_interpreter_test.dart` passed.
- `flutter test` targeted regression slice passed:
  - `openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart`
  - `openbudget_app/test/features/auth/screens/login_screen_test.dart`
  - `openbudget_app/test/features/accounts/screens/add_account_screen_test.dart`
- `dart analyze openbudget_server openbudget_app openbudget_client` returned no issues.

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/jupiter-pricing-fallback-cycle-login.png`

## 2026-02-28 - iOS Flavor Parity and Side-by-Side Install (Issue #161)

### Platform Progress

- Added full iOS flavor build configuration matrix:
  - `Debug-dev`, `Release-dev`, `Profile-dev`
  - `Debug-prod`, `Release-prod`, `Profile-prod`
- Updated iOS schemes to map to flavor-specific build configs:
  - `dev.xcscheme` -> `*-dev` configs
  - `prod.xcscheme` -> `*-prod` configs
- Added flavor-specific iOS bundle/display separation:
  - Dev: `com.openbudget.app.dev` / `OpenBudget Dev`
  - Prod: `com.openbudget.app` / `OpenBudget`
- Added flavor-specific iOS xcconfig wiring and Podfile configuration mapping for dev/prod build variants.

### Validation Completed

- `pod install` succeeded after flavor config expansion.
- `flutter run --flavor dev -t lib/main_dev.dart -d 63886201-1983-42F2-8DEA-51FBF6C0191C --no-resident` succeeded.
- `flutter run --flavor prod -t lib/main_prod.dart -d 63886201-1983-42F2-8DEA-51FBF6C0191C --no-resident` succeeded.
- Simulator app list confirms both bundle IDs present concurrently:
  - `com.openbudget.app`
  - `com.openbudget.app.dev`

### Documentation Updates

- Updated flavor runbook and README references:
  - `docs/solana-and-flavors-setup.md`
  - `README.md`
  - `openbudget_app/README.md`

### Mobile Evidence

- Captured additional iOS simulator screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/ios-flavor-parity-dev-login.png`

## 2026-02-28 - NFT Coverage Metrics in Sync Response (Issue #164 Continuation)

### Backend Progress

- Extended `SolanaWalletSyncResult` protocol payload with NFT-specific coverage fields:
  - `nftHoldingCount`
  - `pricedNftHoldingCount`
  - `staleNftHoldingCount`
  - `unpricedNftHoldingCount`
- Updated holdings sync aggregation in `SolanaWalletService` to track NFT coverage counts alongside overall coverage counts.
- Regenerated Serverpod protocol/client artifacts after schema update.

### App Progress

- Updated Solana wallet sync snackbar copy to include NFT coverage/unpriced counts from the sync response.

### Validation Completed

- `serverpod generate` completed successfully.
- `dart analyze openbudget_app openbudget_server openbudget_client` returned no issues.
- `flutter test openbudget_app/test/features/accounts/screens/account_detail_screen_test.dart` passed.
- `dart test` unit slices passed:
  - `openbudget_server/test/unit/solana_wallets/jupiter_price_client_test.dart`
  - `openbudget_server/test/unit/solana_wallets/solana_transaction_interpreter_test.dart`

### Mobile Evidence

- Captured additional Android screenshot in this cycle:
  - `docs/research/screenshots/2026-02-28/nft-coverage-metrics-cycle-login.png`
