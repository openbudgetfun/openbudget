---
app: minor
wired: patch
---

Deliver end-to-end social and wallet authentication updates:
- initialize and harden Google sign-in flow in app runtime
- keep Apple sign-in available on iOS/web but hide it on Android
- add Android Solana Mobile Wallet Adapter login with signed challenge exchange using `solana_kit_mobile_wallet_adapter`
- add backend `solanaWalletAuth` endpoint and persistence for wallet auth accounts/challenges
