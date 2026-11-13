---
"openbudget_core": feat
---

# Parse wallet addresses across every launch chain

`openbudget_core` gains `WalletAddressParser.parse`, a pure-Dart parser that never throws and never touches the network. It covers Solana, Bitcoin (including `xpub`, `ypub` and `zpub` recognition from SLIP-132 version bytes only), EVM with EIP-55 checksums, Tron in Base58Check and 42-digit hex forms, and XRP Ledger classic and X-address forms.

The result is a Freezed sealed type: a match with one or more candidates, a refusal with a user-facing reason, or an invalid hint such as a checksum failure. A candidate carries the shared `ChainFamily` and the `WalletNetwork` values it can be read on, derived from `WalletNetworkRules`, so the parser adds no chain type of its own. Inputs are refused before anything leaves the device: recovery phrases, WIF and extended private keys, raw 64-byte keys, `0x` plus 64 hex digits, testnet Bitcoin, TON and X-address forms, multisig `Ypub` and `Zpub`, and X-addresses carrying a destination tag. `crypto` and `pointycastle` join the core dependencies.
