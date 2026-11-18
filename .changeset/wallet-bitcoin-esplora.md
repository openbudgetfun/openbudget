---
openbudget_server: feat
---

# Add an Esplora Bitcoin provider for single addresses

`EsploraClient` reads single Bitcoin addresses from mempool.space with Blockstream as fallback, throttling to five requests a second per host, honouring `Retry-After` on 429 and failing over between hosts. `BitcoinWalletProvider` maps confirmed plus mempool balance (`chain_stats` and `mempool_stats`, funded minus spent txo sums) to one satoshi quantity with eight decimals, and is registered for the Bitcoin family without a secret. Extended keys (`xpub`/`zpub`) are reported as not yet supported.
