---
openbudget_server: fix
---

# Wallet revaluation uses configured price credentials and records honest quality

The hourly refresh and `WalletService.revalue` now pass the session's
passwords and the process environment to `PriceService`, which also defaults
to them. A `coingeckoProApiKey` therefore reaches `pro-api.coingecko.com`
instead of silently falling back to the demo host.

`PriceService.resolveDetailed` reports whether each price was already cached
in `AssetPrice` or fetched during the call, so revaluation records a cached
price as `PriceQuality.cached` with `Confidence.low` and a fresh one as
`PriceQuality.live` with `Confidence.high`. When no source quotes an asset and
its stored price is over seven days old, revaluation clears the value, unit
price and quality so the holding stays unpriced and out of the account
valuation.
