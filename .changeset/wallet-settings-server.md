---
openbudget_server: feat
openbudget_client: feat
---

# Reading a wallet again when its networks change

`wallet.setScanNetworks` now reads the wallet at once when the set of networks changed: an added network shows its holdings, a removed one loses its holdings, and the account valuation follows, before the call answers. A read that fails on every network is recorded per network and does not undo the change. The commit also deletes the `wallet_network_state` row of a network that left the scan set, so it no longer shows as a stale section. No migration. The generated client carries the updated documentation.
