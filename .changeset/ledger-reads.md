---
openbudget_core: feat
openbudget_server: feat
openbudget_client: feat
---

# Ledger reads and integer-only amount parsing

`openbudget_server` adds two ledger reads, `listJournalLines(journalId)` and `getLockDate(budgetId)`. Both check ownership and require a ledger budget, and need no migration. `openbudget_core` adds `parseMinorUnits` and `formatMinorUnits`, which parse and render plain amounts with integers only and refuse input with more decimals than the currency has. The tax screens' `double`-based helpers are replaced by them, so a tax form now rejects `12.345` for a two-decimal currency instead of rounding it. `LedgerValidationIssue` gains `lineIndex`, the zero-based line an issue refers to.
