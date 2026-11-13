---
openbudget_server: feat
openbudget_client: feat
---

# Take the wallet schema multichain

Wallets, holdings and on-chain transactions now carry their `WalletNetwork`, holdings carry a `position` (available, staked, unclaimed rewards) and a `spamVerdict`, and the new `wallet_network_state` table keeps per-network read state and history cursors for the multi-network sync. EVM wallets get `scanNetworks`, and HD wallets get a sealed descriptor slot. Existing Solana wallets, holdings and transactions are backfilled with their wallet's network by the migration — no data is dropped — and `PriceSource` adds `coingecko` and `defillama` for the next price work.
