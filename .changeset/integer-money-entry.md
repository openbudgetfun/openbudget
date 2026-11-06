---
openbudget_app: fix
---

# Parse typed money amounts in integer minor units

Typed amounts were converted with `double.tryParse` and `(value * factor).round()`, so every entry round-tripped through binary floating point before it reached the ledger.

- A new `parseMoneyInput` / `moneyInputError` pair in `openbudget_app/lib/src/utils/money_input.dart` wraps core's integer-only `parseMinorUnits`, with an explicit `allowNegative` flag that accepts a single leading `-`.
- All typed-amount sites in the app now use it: add/income expense, split expense, edit transaction, transfers, recurring create/edit, add/edit account, the reconcile and loan-target dialogs, and CSV import. Invalid or over-precise text shows the field's validation error (`amountInvalidFormat`) instead of silently becoming 0 or a rounded figure.
- Reverse conversions that put minor units back into an editable field use `formatMinorUnits`, replacing the `/ factor` + `toStringAsFixed` copies of `_pow10` in the transaction dialog, account dialog, recurring dialog, loan-target dialog, budget amount keypad hint and goal dialog.
- CSV import still skips rows whose amount cannot be represented exactly, and still accepts negative bank amounts. Fields that only ever accepted positive amounts (expense, income, transfer, split, recurring, edit account, loan target) continue to refuse negatives; account balances, the reconcile statement balance and imported rows still accept them.
- `ObTextField` gained an optional `errorText` so amount fields can surface the new validation message.
