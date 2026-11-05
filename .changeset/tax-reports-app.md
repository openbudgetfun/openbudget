---
openbudget_app: feat
---

# Add the tax profile, categorisation, and report app flow

Wire the app to the existing tax API. A `TaxRepository` interface keeps the Serverpod calls testable, `taxProfile`, `taxReport`, and `taxCategories` providers expose read state, and `TaxActions` writes profiles and categorisation before invalidating the report.

- `taxOverview` and `taxProfile` routes under `/budgets/:id/tax`, a More tab entry, an envelope detail row, and a transaction edit row.
- Overview with a tax-year switcher, balance or refund hero, expandable band cards, report lines with return references, opportunities, workings, and a persistent guidance disclaimer.
- Profile form for GB, US, NG, and DE options with inline validation and a linked personal budget for sole traders and companies.
- Category sheet with search, grouping, a clear option, business-use percentage, and sales tax for transactions.
- Provider, widget, and Patrol coverage, including refund wording, unsupported years, band expansion, and per-country save payloads.
