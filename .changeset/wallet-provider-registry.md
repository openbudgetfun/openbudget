---
openbudget_server: feat
---

# Resolve wallet providers through a per-family registry

`WalletProvider` now takes one `WalletReadRequest` — the wallet's home network, the networks to read, the address and, for HD wallets later, the sealed descriptor — and returns per-network results: holdings carry their `network` and `position`, and the snapshot reports which networks it read, which failed with a plain-words reason, and which history cursors it reached. A new `WalletProviderRegistry` maps each `ChainFamily` to its provider factory and reports a family as unsupported while its secret is missing, following the password-plus-environment fallback pattern. Solana's provider is the first registration and behaves exactly as before, and a regression test pins that no provider call happens inside the sync's database transaction.
