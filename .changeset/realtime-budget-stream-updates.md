---
default: patch
---

Add budget-level realtime updates so clients receive instant refreshes when shared budget data changes. Mutating server endpoints now publish budget change events, `budgetStream` maintains live subscriptions, and the app budget shell listens for stream updates and invalidates budget-scoped providers to refresh accounts, categories, envelopes, transactions, allocations, and related views.
