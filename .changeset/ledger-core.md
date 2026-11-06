---
"openbudget_core": feat
"openbudget_server": feat
"openbudget_client": feat
---

# Double-entry ledger foundation: core model, posting service and trial balance

`openbudget_core` gains a pure-Dart ledger module: the five account types with their normal balances, the stable system-role set (bank, AR/AP, VAT control, payroll liabilities, directors' loan, retained earnings, opening-balance equity, suspense, rounding, realised/unrealised FX, owner drawings), draft-journal validation (at least two one-sided positive lines, exact-decimal FX conversion with the per-currency exponent, balance in the functional currency and per transaction currency for single-foreign-currency journals), trial-balance computation with a hard error on imbalance, and starter charts of accounts for GB/US/NG/DE companies and sole traders (SKR04-style German numbers marked unverified).

`openbudget_server` adds the `ledger_account`, `journal`, `journal_line`, `ledger_period_lock` and `ledger_audit_event` tables, an `accountingMode` field on `Budget`, and a `LedgerEndpoint` with ownership checks on every call: `enableLedger` (validates the budget's tax-profile entity kind is soleTrader or company and seeds the chart from the jurisdiction template), account listing/creation/archival, draft save/edit/delete, posting, reversal (posted journals are immutable — corrections are reversal journals), journal listing with date filters, `setLockDate` (posting or reversing on or before the lock is rejected) and `trialBalance(asOf)`. Every post, reversal, lock change and mode switch writes an audit event row. One Serverpod migration ships with this change; generated client protocol is committed.
