---
openbudget_server: feat
openbudget_client: feat
---

# Build tax-ready summaries for every country

`tax.getSummary(entityId, startYear)` now returns a `TaxSummaryView` for any entity and year, from `TaxSummaryService.build` (docs/tax-jurisdictions.md, section 8.7). A pack country uses its pack's tax year and reports totals under the pack's own category codes; any other country uses the universal tax year, and a company uses its own financial year. The view carries a header (period, base currency, rules version or verified-on date, disclaimer key), income, expense, relief and tax-paid totals by category after business-use share, VAT/GST collected and paid by rate and by quarter from the lines' sales-tax fields, wallet disposals with their stored FIFO estimates, method and caveats, FX notes with the exact rate facts each converted line used, and the count of uncategorised lines. No table or migration is added. Wallet figures keep their stored P&L currency and are never converted.
