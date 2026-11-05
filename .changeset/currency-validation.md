---
openbudget_app: fix
openbudget_server: fix
---

# Reject unsupported currency codes and stop guessing USD

- `CurrencyCode.tryParse` now trims whitespace as well as upper-casing, so `" gbp "` resolves to `GBP`.
- The server validates every currency written through the budget, account, transaction, transfer, split, bulk import, recurring transaction, and envelope paths. Unsupported codes throw `ValidationException` with `Unsupported currency: XYZ`; supported codes are stored normalized. Display-currency overrides are validated too.
- The app replaces `parseCurrencyCode` with `CurrencyCode.tryParse`, formats unsupported codes as a raw code plus a plain two-decimal amount (`XYZ 12.50`), and keys currency aggregations by the raw code so unknown currencies stay separate from USD.
- Wallet assets and Plaid-provided account currencies are untouched: those paths carry asset symbols or external currency data, not user-entered budgeting currencies.
