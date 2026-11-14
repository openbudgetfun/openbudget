---
openbudget_server: security
---

# Privacy and cost guards for wallet providers

Wallet provider failure paths no longer leak addresses, API keys, descriptors or request URLs in logs or error messages, and outbound vendor requests are pinned to the address, network and key. A per-vendor request counter (`wallet.vendor.requests vendor=... count=...`) is available for the Bitcoin scale threshold, and the privacy notice now lists every vendor that receives addresses.
