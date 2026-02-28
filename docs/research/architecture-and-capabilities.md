# OpenBudget Deep Research: Architecture and Capability Baseline

Date: 2026-02-27

## 1) Executive Summary

OpenBudget has a solid envelope-budgeting core with strong CRUD coverage across budgets, categories, envelopes, monthly allocations, recurring transactions, and payee-based rules. It is best described today as:

- Cloud-first budgeting with Serverpod + Flutter.
- Multi-currency aware at the record level.
- Limited automation primitives (rules, duplicate checks, age-of-money, recurring posting).

It is **not yet** a live multi-currency valuation platform, a digital-asset portfolio tracker, or a tax accounting engine.

## 2) Method and Scope

This research was performed by reading app/server/core/infra code and project docs directly in the repository.

Primary focus areas:

- Multi-currency behavior and correctness.
- Digital asset readiness (Solana direction).
- Tax/PnL foundation readiness.
- Architecture quality and scaling seams.
- Current feature surface and maturity indicators.

## 3) System Architecture Snapshot

### 3.1 Monorepo Layout

- `openbudget_app`: Flutter app (Riverpod + hooks).
- `openbudget_server`: Serverpod backend with PostgreSQL.
- `openbudget_client`: generated Serverpod client.
- `openbudget_core`: shared constants/logging utilities (includes currency enum).
- `infra`: Pulumi TypeScript for AWS (ECS) and GCP (Cloud Run).

### 3.2 Backend Domain Surface (Implemented)

Server services and endpoints exist for:

- Budgets
- Categories
- Envelopes
- Envelope goals
- Monthly allocations
- Accounts
- Transactions (transfer, split, duplicate check, reconcile, age-of-money, bulk import)
- Recurring transactions
- Payees
- Transaction rules
- Budget templates
- Budget export

Evidence:

- `openbudget_server/lib/src/*/*_service.dart`
- `openbudget_server/lib/src/*/*_endpoint.dart`
- `openbudget_server/lib/src/generated/endpoints.dart`

### 3.3 Security/Tenancy Pattern

Most service methods verify budget ownership (`BudgetService.getById(...)`) before operations. This is a strong base for multi-tenant safety.

## 4) Multi-Currency: Current State vs Target

### 4.1 What Exists

Currency code fields are present in core records:

- `account.currencyCode`
- `budget.currencyCode`
- `envelope.currencyCode`
- `transaction.currencyCode`
- `recurring_transaction.currencyCode`

Evidence:

- `openbudget_server/migrations/20260216174003700/definition.sql`
- `openbudget_server/lib/src/accounts/account.spy.yaml`
- `openbudget_server/lib/src/budgets/budget.spy.yaml`
- `openbudget_server/lib/src/envelopes/envelope.spy.yaml`
- `openbudget_server/lib/src/transactions/transaction.spy.yaml`
- `openbudget_server/lib/src/recurring_transactions/recurring_transaction.spy.yaml`

### 4.2 Current Limitations

1. Currency universe is constrained in app code.

- `CurrencyCode` enum only includes `USD`, `EUR`, `GBP`, `JPY`, `BTC`.
- Evidence: `openbudget_core/lib/src/constants/currencies.dart`

2. Unknown currency fallback silently defaults to USD.

- Evidence: `openbudget_app/lib/src/utils/currency_code_utils.dart`

3. No exchange-rate / FX model or service.

- No `fx`, `exchange rate`, `conversion`, `quote`, or valuation domain found in app/server/core source.

4. Multi-currency views are display buckets, not converted totals.

- Net worth and home aggregate by currency and show breakdown strings, not base-currency normalization.
- Evidence:
  - `openbudget_app/lib/src/features/reports/providers/net_worth_provider.dart`
  - `openbudget_app/lib/src/features/home/screens/home_screen.dart`

5. Reporting providers emit single budget currency labels.

- Spending report/payee/trends output budget currency code rather than FX-normalized valuation.
- Evidence:
  - `openbudget_app/lib/src/features/reports/providers/spending_report_provider.dart`
  - `openbudget_app/lib/src/features/reports/providers/spending_by_payee_provider.dart`
  - `openbudget_app/lib/src/features/reports/providers/spending_trends_provider.dart`

6. Transfer parity is enforced in UI, not in server transfer service.

- UI prevents cross-currency transfers.
- Server `createTransfer` does not assert source/destination currency match.
- Evidence:
  - `openbudget_app/lib/src/features/transfers/screens/create_transfer_screen.dart`
  - `openbudget_server/lib/src/transactions/transaction_service.dart`

7. Reconciliation adjustment uses budget currency.

- In account reconcile-with-balance, adjustment transaction uses `budget.currencyCode`.
- Evidence: `openbudget_server/lib/src/transactions/transaction_service.dart`

8. CSV import is single-currency per import operation.

- `bulkImport(budgetId, currencyCode, rows)` applies one currency for all rows.
- Evidence:
  - `openbudget_app/lib/src/features/transactions/providers/import_transactions_provider.dart`
  - `openbudget_server/lib/src/transactions/transaction_endpoint.dart`

## 5) Accounting Model Observations

### 5.1 Transactions and Accounts Are Partially Decoupled in UI

- Income/expense screens show an "Account" row but do not submit an account ID.
- Account value shown in those rows is budget name placeholder, not an account selector.
- Evidence:
  - `openbudget_app/lib/src/features/transactions/screens/add_income_screen.dart`
  - `openbudget_app/lib/src/features/transactions/screens/add_expense_screen.dart`

### 5.2 Account Balances as Stored Values

- Account list displays `account.balanceCents` directly.
- Transaction creation service does not update account balances.
- This indicates account balances are manually maintained and not guaranteed to be ledger-derived in all flows.
- Evidence:
  - `openbudget_app/lib/src/features/accounts/screens/account_list_screen.dart`
  - `openbudget_server/lib/src/transactions/transaction_service.dart`

## 6) Intelligence Primitives Already Present

These are useful foundations for future AI workflows:

1. Rule-based auto assignment.

- Payee -> envelope matching.
- Evidence:
  - `openbudget_server/lib/src/transaction_rules/transaction_rule_service.dart`
  - `openbudget_app/lib/src/features/transaction_rules/providers/rule_match_provider.dart`

2. Duplicate detection.

- Same amount, ±1 day, up to 5 matches.
- Evidence:
  - `openbudget_server/lib/src/transactions/transaction_service.dart`
  - `openbudget_app/lib/src/features/transactions/providers/duplicate_check_provider.dart`

3. Recurring auto-posting.

- Due recurring templates can be posted via endpoint.
- Evidence:
  - `openbudget_server/lib/src/recurring_transactions/recurring_transaction_service.dart`
  - `openbudget_app/lib/src/features/recurring/providers/recurring_auto_post_provider.dart`

4. Age-of-money metric.

- Exists server-side and consumed by app.
- Evidence:
  - `openbudget_server/lib/src/transactions/transaction_service.dart`
  - `openbudget_app/lib/src/features/budget/providers/age_of_money_provider.dart`

## 7) AI and Digital Asset Readiness

### 7.1 AI

Repository messaging claims "AI-first" / "AI-driven financial intelligence," but no LLM/agent workflow is implemented in app/server code.

Evidence:

- Marketing statements: `README.md`
- Implemented analytics only: `openbudget_app/lib/src/analytics/*`

### 7.2 Digital Assets / Solana

No first-class wallet/chain/token/lot/tax-event models exist yet.

Evidence:

- Protocol and endpoints include budgeting domains only.
- `openbudget_server/lib/src/generated/protocol.dart`
- `openbudget_server/lib/src/generated/endpoints.dart`

## 8) Architecture Quality and Scalability Notes

### 8.1 Positive Signals

- Clear bounded services in backend.
- Ownership checks are consistent.
- Good baseline test volume (app unit + integration, server integration).
- Infra supports AWS and GCP with Pulumi ESC secret management.

### 8.2 Scaling Friction

1. App provider layer is tightly coupled to transport (`serverpodClientProvider`) across many feature modules.

- Repository/domain abstraction is largely absent.

2. Evidence of N+1 fetch patterns in summary assembly.

- Category loop fetching envelopes per category.
- Evidence: `openbudget_app/lib/src/features/budget/providers/budget_summary_provider.dart`

3. Runtime configuration mismatch risk.

- App client provider hardcodes `http://localhost:8080/`.
- Server exposes dynamic config route for web app config.
- Evidence:
  - `openbudget_app/lib/src/providers/serverpod_client_provider.dart`
  - `openbudget_server/lib/src/web/routes/app_config_route.dart`
  - `openbudget_server/lib/server.dart`

4. Recurring posting is endpoint-driven, no server-side scheduler/orchestrator found.

- Evidence: no invocation beyond recurring endpoint/service.

## 9) Product Maturity Snapshot

Current docs and recent changes indicate heavy effort on:

- UI flow parity
- Regression coverage
- integration stability and screenshots

Evidence:

- `docs/openbudget-screenflows.md`
- `docs/openbudget-migration-progress.md`

Strategic planning artifacts for multi-currency valuation, crypto assets, tax engine, and AI workflows are currently missing.

## 10) Immediate Strategic Implications

1. The product already has the right structural seeds (currency fields, recurring/rules/dup checks, export), but not the valuation/tax substrate.
2. The next leap should be data-model-first on server side (rates/assets/lot events) before AI UX.
3. Cross-currency correctness must move to server invariants, not UI-only checks.
4. If digital assets are core strategy, account-transaction linkage and portfolio accounting semantics need to be first-class.
