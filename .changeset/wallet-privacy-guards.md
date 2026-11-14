---
openbudget_server: security
---

# Privacy and cost guards for wallet providers

Wallet provider failure paths no longer leak addresses, API keys, descriptors or request URLs in logs or error messages, and tests pin every outbound vendor request to the address, network and key. Each wallet sync and each hourly refresh run now logs one `wallet.vendor.requests vendor=<vendor> count=<n>` line per vendor, counted per operation, for the Bitcoin scale threshold. `docs/multichain-wallets.md` lists every vendor that receives wallet data, for the privacy notice.
