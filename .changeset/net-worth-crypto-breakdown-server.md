---
openbudget_server: feat
openbudget_client: feat
---

# Crypto breakdown report for net worth (W6.4)

`report.cryptoBreakdown(entityId, grouping, {currencyCode})` returns a
`CryptoBreakdownView` of `CryptoBreakdownRow`s: what an entity's wallets are
worth today, by chain (`byChain`, one row per network) or by asset (`byAsset`).
Only counted holdings are summed: priced, with a spam verdict of `clean` or
`allowedByUser`. Each wallet's value in one currency is converted once with
the daily FX the net worth report uses and shared over its holdings by largest
remainder, so the rows, the total and net worth's figure for the same wallets
agree to the minor unit and no double touches a sum. By asset, natives and the
catalogue's canonical tokens merge across networks (all USDC is one row);
every other token is one row per network and asset, with the top eight listed
and the rest as "Other". A currency with no rate is reported in
`missingCurrencyCodes` and left out, never guessed. A foreign entity is
`Forbidden`. No migration: the views are not tables.
