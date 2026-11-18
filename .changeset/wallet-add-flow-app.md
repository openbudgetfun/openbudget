---
openbudget_app: feat
---

# Add a crypto wallet (W6.2)

The add-account screen's Solana-only "Connect wallet" step becomes
`AddWalletStep` (`features/accounts/widgets/add_wallet_step.dart`): one paste
field that runs the core `WalletAddressParser` as the person types and shows
the detected chain as an `ObChainStamp`. An EVM address is looked ahead at
through `wallet.preview` and offered as a picker of chain stamps, with the
networks that hold priced assets pre-selected; the home network (Ethereum) is
always read, because the server requires it. A `zpub`, `ypub` or `xpub` connects
as a Bitcoin HD wallet. A private key, `0x` plus 64 hex digits or recovery phrase
(including three or more words in a row) empties the field on the device, shows
the refusal in an `ObStatePanel.problem`, and sends nothing. The refused text is
never put in a provider state.

`AddWalletFlow` (Riverpod, `features/accounts/providers/add_wallet_provider.dart`)
holds the preview, the picked networks and the connect, with Freezed states in
`models/add_wallet_state.dart`. While the server reads the new wallet the screen
shows "Reading Ethereum, Base and Arbitrum One…"; a wallet whose every network
failed gets a retry through `wallet.sync`. The app passes a localised
`accountName` ("Ethereum wallet (0x5a…eAed)", "Bitcoin wallet, zpub"), and
success stamps an `ObPostmark`. `WalletActions.connect` now takes
`scanNetworks` and refreshes the account list, and `supportedWalletNetworks`
reads `wallet.supportedNetworks` so an unavailable chain is said so up front.
The unused Solana-only wallet strings are removed.
