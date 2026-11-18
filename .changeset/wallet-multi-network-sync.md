---
openbudget_server: feat
openbudget_client: feat
---

# Sync wallets per network and add the preview and network endpoints

A wallet sync now commits per network: holdings are replaced only for the networks the provider read, a failed network keeps its stored quantities and is re-priced from cache, and `wallet_network_state` records when each network was last read and why the last read failed — in plain words, with no URL, key or address. The sync is `synced` when at least one network read and `failed` (last facts kept) when none did, and `WalletSyncResult` reports `readNetworks` and `failedNetworks`. `connect` validates addresses through the shared core parser (refusing private keys, recovery phrases and testnet forms before anything is stored) and takes `scanNetworks` for EVM wallets. New endpoint methods: `wallet.preview` (rate limited to 20 reads an hour per user), `wallet.supportedNetworks`, `wallet.setScanNetworks` and `wallet.listNetworkStates`.
