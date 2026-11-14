import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/add_wallet_labels.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The key of the stamp for [network] in the network picker, for tests.
Key walletNetworkStampKey(WalletNetwork network) =>
    ValueKey('add-wallet-network-${network.name}');

/// The EVM network picker: one stamp per network the preview read.
///
/// A network with priced holdings is inked with its value in tabular
/// figures; an empty one is an outline that says so. Tap a stamp to include
/// the network or leave it out. The wallet's home network is always read, so
/// its stamp is fixed, and the caption says why.
class WalletNetworkPicker extends HookWidget {
  const WalletNetworkPicker({
    required this.preview,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final WalletPreview preview;
  final List<WalletNetwork> selected;
  final void Function(WalletNetwork network, {required bool selected}) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final words = walletStampWords(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.walletAddPickerTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final row in preview.networks)
              if (row.network == preview.network)
                // Always read, so it is a fixed stamp, not a toggle.
                ObChainStamp(
                  key: walletNetworkStampKey(row.network),
                  family: row.network.family,
                  label: walletNetworkLabel(l10n, row.network),
                  value: _foundLabel(l10n, row),
                  words: walletStampWords(
                    l10n,
                    inked: l10n.walletAddStampIncluded,
                  ),
                )
              else
                ObChainStampToggle(
                  key: walletNetworkStampKey(row.network),
                  family: row.network.family,
                  label: walletNetworkLabel(l10n, row.network),
                  value: _foundLabel(l10n, row),
                  selected: selected.contains(row.network),
                  words: words,
                  onChanged: (on) => onToggle(row.network, selected: on),
                ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.walletAddPickerSelectedCount(selected.length),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.ob.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          l10n.walletAddPickerHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.ob.mutedInk,
          ),
        ),
      ],
    );
  }

  static String _foundLabel(
    AppLocalizations l10n,
    WalletPreviewNetwork row,
  ) {
    final value = row.valueMinor;
    if (row.readError != null) return l10n.walletAddNetworkUnreadable;
    if (row.pricedHoldingCount > 0 && value != null) {
      return formatMinorForCode(value, row.valueCurrencyCode ?? 'USD');
    }
    if (row.holdingCount > 0) return l10n.walletAddNetworkNoPrice;
    return l10n.walletAddNetworkNothing;
  }
}

/// The question for an address more than one chain could own: which chain
/// is it on? One stamp per candidate, one chosen at a time.
class WalletCandidateQuestion extends HookWidget {
  const WalletCandidateQuestion({
    required this.candidates,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<WalletAddressCandidate> candidates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final words = walletStampWords(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.walletAddWhichChain,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final (index, candidate) in candidates.indexed)
              ObChainStampToggle(
                key: ValueKey('add-wallet-candidate-$index'),
                family: candidate.family,
                label: walletNetworkLabel(l10n, candidate.networks.first),
                selected: index == selectedIndex,
                words: words,
                // A question has exactly one answer, so a tap only ever
                // chooses; tapping the chosen stamp keeps it chosen.
                onChanged: (_) => onSelected(index),
              ),
          ],
        ),
      ],
    );
  }
}

/// The first read of a new wallet: the chains being read, inked, and what
/// is happening in words.
class WalletReadingView extends HookWidget {
  const WalletReadingView({required this.networks, super.key});

  final List<WalletNetwork> networks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          alignment: WrapAlignment.center,
          children: [
            for (final network in networks)
              ObChainStamp(
                family: network.family,
                label: walletNetworkLabel(l10n, network),
                words: walletStampWords(l10n),
              ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        ObLoadingPanel(
          label: l10n.walletAddReading(walletNetworkListLabel(l10n, networks)),
        ),
        Text(
          l10n.walletAddReadingHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.ob.mutedInk),
        ),
      ],
    );
  }
}

/// Every network failed on the first read: the wallet exists, and the person
/// can try again or carry on.
class WalletUnreadableView extends HookWidget {
  const WalletUnreadableView({
    required this.networks,
    required this.onRetry,
    required this.onDone,
    this.reason,
    super.key,
  });

  final List<WalletNetwork> networks;

  /// The server's plain-words reason, when it gave one.
  final String? reason;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final why = reason?.trim();
    final message = [
      l10n.walletAddUnreadableMessage(walletNetworkListLabel(l10n, networks)),
      if (why != null && why.isNotEmpty) why,
    ].join('\n');
    return ObStatePanel.problem(
      title: l10n.walletAddUnreadableTitle,
      message: message,
      action: ObStateAction(label: l10n.walletAddRetry, onPressed: onRetry),
      secondaryAction: ObStateAction(
        label: l10n.dialogDone,
        onPressed: onDone,
      ),
    );
  }
}

/// The wallet is in: an ADDED postmark lands on a sticker card.
class WalletAddedView extends HookWidget {
  const WalletAddedView({
    required this.accountName,
    required this.networks,
    required this.onDone,
    required this.onAddAnother,
    super.key,
  });

  final String accountName;
  final List<WalletNetwork> networks;
  final VoidCallback onDone;
  final VoidCallback onAddAnother;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // A postmark is a few letters: the coin's ticker for one chain, a count
    // for several.
    final detail = networks.length > 1
        ? l10n.walletAddedPostmarkChains(networks.length)
        : networks.first.nativeSymbol;
    return ObCard(
      raised: true,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
      ),
      child: Column(
        children: [
          ObPostmark(
            label: l10n.walletAddedPostmark,
            detail: detail,
            tone: ObTone.funded,
            size: 136,
          ),
          const SizedBox(height: SpacingTokens.md),
          Semantics(
            header: true,
            child: Text(
              l10n.walletAddedTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.ob.ink,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.walletAddedMessage(accountName),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.ob.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              FilledButton(
                key: const Key('add-wallet-done'),
                onPressed: onDone,
                child: Text(l10n.dialogDone),
              ),
              OutlinedButton(
                key: const Key('add-wallet-add-another'),
                onPressed: onAddAnother,
                child: Text(l10n.addAccountSuccessAddAnother),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
