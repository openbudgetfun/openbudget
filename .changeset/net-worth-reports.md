---
openbudget_server: feat
---

# Add combined and historical net worth reports

`NetWorthService` now returns one coherent current view and a chart-ready
history for the caller's entities. Every account is converted exactly once and
the same converted atoms feed the asset, liability, entity and currency
breakdowns, so rounding never makes the totals disagree. A missing quote leaves
the currency out of the totals and lists it instead of pretending a 1:1 rate.

History rebuilds balances from live transactions and valuations at up to 400
day, week or month points, with one batched fact query per source and one FX
query for the whole range. `ReportEndpoint` exposes only `netWorth` and
`netWorthHistory`; the remaining report methods land with their own service.
