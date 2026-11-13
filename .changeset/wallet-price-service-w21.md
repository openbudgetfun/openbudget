---
openbudget_core: feat
openbudget_server: feat
---

# CoinGecko and DefiLlama price service (W2.1)

Adds CoinGecko `/simple/price` and `/simple/token_price/{platform}` clients (chunked at 515, pro host with `x-cg-pro-api-key` when `coingeckoProApiKey` is set, otherwise demo host with `x-cg-demo-api-key`) and a DefiLlama `prices/current` client (no key). `PriceService` resolves `(network, assetId)` pairs through the `asset_price` cache (15-minute expiry), then CoinGecko, then DefiLlama, writing the cache. CoinGecko native and platform ids are pinned into the core chain catalogue (marked unverified until the manual `--check` tool confirms them). `PriceSource` already carries `coingecko` and `defillama`. Both CoinGecko keys are documented in `passwords.example.yaml` with environment fallbacks.
