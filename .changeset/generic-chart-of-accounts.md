---
openbudget_core: feat
---

# Generic chart of accounts for countries without a tax pack

`LedgerChartTemplate.forBooks` now falls back to a country-neutral, IFRS-style starter chart for sole-trader and company books in any country without a chart of its own, instead of returning nothing, so ledger mode works everywhere the later country batches add. The generic charts carry every system role the ledger machinery needs (including `bankClearing`) with no country-specific tax accounts beyond a generic indirect-tax control account, and the existing GB, US, NG and DE charts are byte-for-byte unchanged, pinned by snapshot tests.
