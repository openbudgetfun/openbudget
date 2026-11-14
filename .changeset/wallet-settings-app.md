---
openbudget_app: feat
---

# Wallet settings on account detail

A wallet account gets a "Wallet settings" sheet (`WalletSettingsSheet`) that renames the account, edits the networks an EVM wallet reads, and disconnects it. The chain editor reuses the add-wallet picker's `ObChainStampToggle` stamps (inked when read, outline when not) with each chain's value from the holdings; dropping a chain that holds value asks in the page what leaves net worth before it calls `wallet.setScanNetworks`. "Look for assets on other chains" runs `wallet.preview` again through `WalletLookAhead`, picks the chains it finds, and says so when nothing new turns up.

Account detail now shows the settings button and the holdings for wallet accounts that track by value, which is every account the server creates for a wallet; before, only the transaction branch drew them. `AccountActions` is kept alive so its invalidations land, and renaming refreshes `accountDetailProvider`. The add-wallet refusal card uses a lock for secrets, and `addAccountSuccessAddAnother` reads "Add another".
