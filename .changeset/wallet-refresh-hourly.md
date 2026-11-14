---
openbudget_server: feat
---

# Add the hourly wallet refresh future call

`WalletRefreshFutureCall` registers as `wallet-refresh-hourly` beside `fx-refresh-hourly`. Each run reads due wallets by plan (free every 24 hours, Plus every 6 hours, oldest due first, capped per run) and revalues every other wallet from cached prices with no provider call. Manual syncs are throttled to one per 5 minutes per wallet using the wallet row's timestamp, consistent across server instances, and the in-memory preview rate limiter keeps its clock seam.
