---
openbudget_core: feat
openbudget_server: feat
---

# Share the `WalletNetwork` model with the chain catalogue

Moves `WalletNetwork` from the server to `openbudget_core` with every launch value from `docs/multichain-wallets.md` section 7.1 (Bitcoin, seven EVM networks, Tron, the XRP Ledger, Hyperliquid, Dogecoin, Litecoin, Cardano, TON, Sui and Aptos beside Solana), so the server, the client and the app share one definition. Values are stored by name, so no database migration is needed; existing Solana rows and serialisation are unchanged.

Core gains `ChainFamily` (one integration per family, Hyperliquid kept its own family per the plan's validation table), the `WalletNetworkRules` extension (family, testnet flag, native symbol and decimals, display name, EVM chain id, catalogue entry) and a `ChainCatalog` of canonical assets per network — the native coin plus USDT, USDC, DAI, WETH and WBTC where a citable canonical deployment exists. Every token contract is cited from its issuer's or chain's own documentation; price ids are deliberately left for W2.1. `wallet.connect` now rejects networks that have no reader yet instead of silently accepting any future value.
