---
openbudget_server: feat
---

# Add Money guide read tools (G7)

`get_spending_summary`, `get_tax_calendar` and `get_tax_summary` are registered in `AgentToolRegistry` and exposed over MCP. `get_spending_summary` aggregates up to 12 months of income and spending per envelope and category group with totals, monthly averages and a spending trend. `get_tax_calendar` returns the next pack deadlines (capped at 10) or the universal tax-year end. `get_tax_summary` returns the U8 tax-ready summary totals for any country with `citeAs`. All three carry the `guidance` block and enforce ownership. `get_crypto_tax_summary` is left out pending C9.
