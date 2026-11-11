---
openbudget_server: fix
---

# Reject mixed-currency transfers and reconciliations

Transfers now require the source account, destination account, and amount to share one currency. Reconciliation sums only that account's currency, writes any statement adjustment in the account currency rather than the budget currency, and refuses to continue when the account already holds another currency.
