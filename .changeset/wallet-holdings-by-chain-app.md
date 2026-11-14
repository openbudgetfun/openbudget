---
openbudget_app: feat
---

# Wallet holdings grouped by chain (W6.3)

`WalletHoldingsSection` replaces the private `_WalletHoldingsSection` and
`_HoldingRow` in `account_detail_screen.dart`. It is a `HookConsumerWidget`
under `features/accounts/widgets/`, fed by `buildWalletHoldingsView` (Freezed
`WalletHoldingsView`, `WalletNetworkSection`, `WalletAssetGroup` and
`HiddenHolding` in `features/accounts/models/`). It draws one section per
network with an `ObChainStamp`, the counted subtotal and "Read 2 hours ago"
from `wallet.listNetworkStates`, groups staked and unclaimed positions under
their asset with `ObToneChip`s, marks `cached` prices, shows a failed network's
note and `lastError`, and folds `suspected`, `hiddenByUser` and `unpriced`
holdings into a collapsed Hidden group.

`walletNetworkStatesProvider` and `WalletActions.setHoldingVerdicts` (which
calls `wallet.setHoldingVerdict` per holding and refreshes the holdings) are
new. `WalletActions` is now `keepAlive`: as an auto-disposed notifier it was
already unmounted when its post-await `ref.invalidate` calls ran, so neither
`sync` nor the new verdict calls refreshed anything.

A holding counts only when `priceQuality` is not `unpriced`, it has a
`valueMinor`, and its verdict is `clean` or `allowedByUser`, the same rule the
server's valuation uses.
