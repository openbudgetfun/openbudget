---
openbudget_server: fix
---

# Let `serverpod generate` run again

`WalletRefreshFutureCall` exposed a public `run` method that returned a report, and Serverpod requires every future-call method to return `Future<void>`, so code generation failed. The refresh pass now lives in `WalletRefreshRunner`, and the future call keeps only `refresh`.
