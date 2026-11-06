---
openbudget_app: user_fix
---

# Amounts you type are saved exactly

When you type an amount like 12.34, it is now saved as exactly 12.34 instead of passing through a floating-point conversion. If you type more decimal places than the currency uses, the field tells you and asks for a correct amount rather than quietly rounding it. The same applies to accounts, transfers, recurring transactions, split expenses, reconciliation and imported transactions.
