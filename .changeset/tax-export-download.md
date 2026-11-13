---
openbudget_server: feat
openbudget_client: feat
---

# Build the signed tax summary export download

`tax.createExportLink(entityId, startYear)` returns an absolute URL to a new Relic route, `GET /tax/export/<token>.zip`, which serves the tax-ready summary as a ZIP of `summary.csv`, `lines.csv` and `README.txt`. The link is an HMAC-SHA256 token over the owner's user id, the entity id, the year and an expiry — ten minutes, no table, and no name, email or entity name in the URL — with the signing key derived from the existing Serverpod service secret (`openbudget.tax-export.v1` context) and signatures compared in constant time. The download re-verifies the signature, expiry and the entity's stored owner, then rebuilds the summary through `TaxSummaryService` (now via `buildForExport`, which keeps the per-line provenance and accepts a `SystemEntityOwner` for the web session). Amounts are decimal strings at the currency's exponent, and every refusal answers a bare 404 with the reason only in the server log. `TaxSummaryService.defaultStartYear` resolves a link without a year through the same period rule as `getSummary`, and the shared tax-line query gained the payee and envelope names for the lines.csv columns. The `archive` package is a new direct dependency of `openbudget_server`.
