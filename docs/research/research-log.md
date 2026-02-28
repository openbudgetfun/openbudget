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
