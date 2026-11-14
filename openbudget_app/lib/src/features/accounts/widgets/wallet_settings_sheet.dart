import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/models/add_wallet_state.dart';
import 'package:openbudget_app/src/features/accounts/models/wallet_holdings_view.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_look_ahead_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/utils/add_wallet_labels.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The "Wallet settings" button on account detail, for tests and Patrol page
/// objects.
const walletSettingsButtonKey = Key('wallet-settings-button');

/// The rename field.
const walletSettingsNameFieldKey = Key('wallet-settings-name-field');

/// "Save name".
const walletSettingsNameSaveKey = Key('wallet-settings-name-save');

/// "Save chains".
const walletSettingsSaveNetworksKey = Key('wallet-settings-save-networks');

/// "Look for assets on other chains".
const walletSettingsLookAheadKey = Key('wallet-settings-look-ahead');

/// "Stop reading", the in-page confirmation of removing a chain with value.
const walletSettingsRemoveConfirmKey = Key('wallet-settings-remove-confirm');

/// "Keep reading", which dismisses that confirmation.
const walletSettingsRemoveCancelKey = Key('wallet-settings-remove-cancel');

/// "Disconnect wallet".
const walletSettingsDisconnectKey = Key('wallet-settings-disconnect');

/// "Disconnect", the in-page confirmation of disconnecting.
const walletSettingsDisconnectConfirmKey = Key(
  'wallet-settings-disconnect-confirm',
);

/// The key of the stamp for [network] in the chain editor.
Key walletSettingsNetworkKey(WalletNetwork network) =>
    ValueKey('wallet-settings-network-${network.name}');

/// Opens the settings of the wallet that values [accountId] and, when the
/// wallet is disconnected there, says so on the page underneath.
Future<void> showWalletSettingsSheet(
  BuildContext context, {
  required String entityId,
  required String accountId,
}) async {
  final disconnected = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        WalletSettingsSheet(entityId: entityId, accountId: accountId),
  );
  if (disconnected != true || !context.mounted) return;
  showAppToast(
    context,
    message: AppLocalizations.of(context).walletSettingsDisconnected,
    variant: AppToastVariant.success,
  );
}

/// Rename a wallet, choose the chains it reads, and disconnect it.
///
/// Everything is edited in place. A chain that holds value is only dropped
/// after an in-page confirmation that says what leaves net worth, and a
/// disconnect asks the same way. The chain editor is the add-a-wallet
/// picker's layout: inked stamps for the chains that are read, outlines for
/// the ones that are not.
class WalletSettingsSheet extends HookConsumerWidget {
  const WalletSettingsSheet({
    required this.entityId,
    required this.accountId,
    super.key,
  });

  final String entityId;
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wallet = ref.watch(walletForAccountProvider(accountId)).value;
    final account = ref.watch(accountDetailProvider(accountId)).value;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.md,
        0,
        SpacingTokens.md,
        MediaQuery.viewInsetsOf(context).bottom + SpacingTokens.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.walletSettingsTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          if (wallet != null && account != null) ...[
            _NameSection(account: account, entityId: entityId),
            const _Rule(),
            if (wallet.network.family == ChainFamily.evm)
              _NetworksSection(
                wallet: wallet,
                entityId: entityId,
                accountId: accountId,
                currencyCode: account.currencyCode,
              )
            else
              _SingleChainSection(network: wallet.network),
            const _Rule(),
            _DisconnectSection(
              wallet: wallet,
              accountName: account.name,
              entityId: entityId,
              accountId: accountId,
            ),
          ] else
            ObLoadingPanel(label: l10n.walletSettingsTitle),
        ],
      ),
    );
  }
}

class _Rule extends HookWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
    child: Divider(height: 1, color: Theme.of(context).ob.line),
  );
}

/// A section's heading, announced as a header.
class _Heading extends HookWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

/// What just happened, in words, announced to a screen reader.
class _Note extends HookWidget {
  const _Note({required this.message, required this.tone});

  final String message;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final icon = switch (tone) {
      ObTone.funded => OpenBudgetIcons.checkCircle,
      ObTone.overspent => OpenBudgetIcons.error,
      _ => OpenBudgetIcons.warning,
    };
    return Semantics(
      liveRegion: true,
      container: true,
      child: ObCard(
        tone: tone,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkribbleIcon(data: icon, size: 20, color: palette.hue(tone)),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: palette.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rename
// ---------------------------------------------------------------------------

class _NameSection extends HookConsumerWidget {
  const _NameSection({required this.account, required this.entityId});

  final Account account;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = useTextEditingController(text: account.name);
    // Rebuild as the person types, so Save follows what the field holds.
    useListenable(controller);
    final busy = useState(false);
    final note = useState<_NoteState?>(null);
    final typed = controller.text.trim();
    final canSave = !busy.value && typed.isNotEmpty && typed != account.name;

    Future<void> save() async {
      busy.value = true;
      note.value = null;
      try {
        await ref
            .read(accountActionsProvider.notifier)
            .updateAccount(
              accountId: account.id!.uuid,
              entityId: entityId,
              name: typed,
            );
        note.value = _NoteState(l10n.walletSettingsNameSaved, ObTone.funded);
      } on Exception {
        note.value = _NoteState(
          l10n.walletSettingsNameFailed,
          ObTone.overspent,
        );
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.walletSettingsNameLabel),
        TextField(
          key: walletSettingsNameFieldKey,
          controller: controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (canSave) unawaited(save());
          },
          decoration: InputDecoration(
            labelText: l10n.walletSettingsNameLabel,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: walletSettingsNameSaveKey,
            onPressed: canSave ? save : null,
            child: Text(l10n.walletSettingsNameSave),
          ),
        ),
        if (note.value case final shown?) ...[
          const SizedBox(height: SpacingTokens.sm),
          _Note(message: shown.message, tone: shown.tone),
        ],
      ],
    );
  }
}

class _NoteState {
  const _NoteState(this.message, this.tone);

  final String message;
  final ObTone tone;
}

// ---------------------------------------------------------------------------
// Chains
// ---------------------------------------------------------------------------

/// The networks an EVM wallet reads now: its scan list, or its home network.
List<WalletNetwork> _readNetworksOf(Wallet wallet) {
  final scan = wallet.scanNetworks;
  return scan == null || scan.isEmpty ? [wallet.network] : scan;
}

/// The networks the preview found assets on that the wallet does not read.
List<WalletNetwork> _foundNetworks(
  WalletPreview preview, {
  required List<WalletNetwork> reading,
  required List<WalletNetwork>? supported,
}) => [
  for (final row in preview.networks)
    if (row.network.family == ChainFamily.evm &&
        !reading.contains(row.network) &&
        (supported == null || supported.contains(row.network)) &&
        row.readError == null &&
        row.holdingCount > 0)
      row.network,
];

/// A wallet that is not on an EVM chain reads its one chain: nothing to pick.
class _SingleChainSection extends HookWidget {
  const _SingleChainSection({required this.network});

  final WalletNetwork network;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.walletSettingsNetworksTitle),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ObChainStamp(
            key: walletSettingsNetworkKey(network),
            family: network.family,
            label: walletNetworkLabel(l10n, network),
            words: walletStampWords(l10n, inked: l10n.walletAddStampIncluded),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          l10n.walletSettingsSingleChain(walletNetworkLabel(l10n, network)),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.ob.mutedInk),
        ),
      ],
    );
  }
}

class _NetworksSection extends HookConsumerWidget {
  const _NetworksSection({
    required this.wallet,
    required this.entityId,
    required this.accountId,
    required this.currencyCode,
  });

  final Wallet wallet;
  final String entityId;
  final String accountId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final walletId = wallet.id!.uuid;

    final reading = _readNetworksOf(wallet);
    final supported = ref.watch(supportedWalletNetworksProvider).value;
    final holdings =
        ref.watch(walletHoldingsProvider(walletId)).value ??
        const <WalletHolding>[];
    final states =
        ref.watch(walletNetworkStatesProvider(walletId)).value ??
        const <WalletNetworkState>[];
    final view = buildWalletHoldingsView(
      holdings: holdings,
      networkStates: states,
      fallbackCurrencyCode: currencyCode,
    );
    final lookAhead = ref.watch(walletLookAheadProvider(walletId));

    final draft = useState<Set<WalletNetwork>>(reading.toSet());
    final saving = useState(false);
    final confirming = useState(false);
    final note = useState<_NoteState?>(null);

    // A saved change makes the new list the one being edited.
    useEffect(() {
      draft.value = reading.toSet();
      return null;
    }, [reading.join(',')]);

    // Anything the look-ahead finds is picked, so saving reads it.
    ref.listen(walletLookAheadProvider(walletId), (previous, next) {
      if (next is! WalletPreviewLoaded || previous is WalletPreviewLoaded) {
        return;
      }
      final found = _foundNetworks(
        next.preview,
        reading: reading,
        supported: supported,
      );
      if (found.isNotEmpty) draft.value = {...draft.value, ...found};
    });

    final offered = [
      for (final network in WalletNetwork.values)
        if (network.family == ChainFamily.evm &&
            !network.isTestnet &&
            (reading.contains(network) ||
                draft.value.contains(network) ||
                (supported?.contains(network) ?? false)))
          network,
    ];
    final picked = [
      for (final network in offered)
        if (network == wallet.network || draft.value.contains(network)) network,
    ];
    final removed = [
      for (final network in reading)
        if (!picked.contains(network)) network,
    ];
    final changed = !_sameSet(picked, reading);

    // What leaves net worth with the chains being dropped, by currency.
    final sectionOf = {
      for (final section in view.sections) section.network: section,
    };
    final leaving = <String, int>{};
    for (final network in removed) {
      final section = sectionOf[network];
      final subtotal = section?.subtotalMinor;
      if (section == null || subtotal == null || subtotal <= 0) continue;
      leaving.update(
        section.currencyCode,
        (sum) => sum + subtotal,
        ifAbsent: () => subtotal,
      );
    }
    final removedWithValue = [
      for (final network in removed)
        if ((sectionOf[network]?.subtotalMinor ?? 0) > 0) network,
    ];

    // Editing the list again withdraws a pending confirmation.
    useEffect(() {
      confirming.value = false;
      return null;
    }, [picked.join(',')]);

    String valueLabel(WalletNetwork network) {
      if (reading.contains(network)) {
        final section = sectionOf[network];
        final subtotal = section?.subtotalMinor;
        if (section == null || subtotal == null) {
          return l10n.walletAddNetworkNothing;
        }
        return formatMinorForCode(subtotal, section.currencyCode);
      }
      if (lookAhead case WalletPreviewLoaded(:final preview)) {
        for (final row in preview.networks) {
          if (row.network == network) return walletPreviewRowLabel(l10n, row);
        }
      }
      return l10n.walletSettingsNotRead;
    }

    Future<void> apply() async {
      saving.value = true;
      confirming.value = false;
      note.value = null;
      try {
        final result = await ref
            .read(walletActionsProvider.notifier)
            .setScanNetworks(
              walletId: walletId,
              entityId: entityId,
              accountId: accountId,
              networks: picked,
            );
        ref.invalidate(walletLookAheadProvider(walletId));
        note.value = result.syncStatus == SyncStatus.failed
            ? _NoteState(
                l10n.walletSettingsNetworksReadFailed(
                  walletNetworkListLabel(l10n, picked),
                ),
                ObTone.underfunded,
              )
            : _NoteState(l10n.walletSettingsNetworksSaved, ObTone.funded);
      } on Exception {
        note.value = _NoteState(
          l10n.walletSettingsNetworksFailed,
          ObTone.overspent,
        );
      } finally {
        if (context.mounted) saving.value = false;
      }
    }

    void save() {
      if (removedWithValue.isEmpty) {
        unawaited(apply());
      } else {
        confirming.value = true;
      }
    }

    final words = walletStampWords(l10n);
    final foundNow = lookAhead is WalletPreviewLoaded
        ? _foundNetworks(
            lookAhead.preview,
            reading: reading,
            supported: supported,
          )
        : const <WalletNetwork>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.walletSettingsNetworksTitle),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final network in offered)
              if (network == wallet.network)
                // Always read, so it is a fixed stamp, not a toggle.
                ObChainStamp(
                  key: walletSettingsNetworkKey(network),
                  family: network.family,
                  label: walletNetworkLabel(l10n, network),
                  value: valueLabel(network),
                  words: walletStampWords(
                    l10n,
                    inked: l10n.walletAddStampIncluded,
                  ),
                )
              else
                ObChainStampToggle(
                  key: walletSettingsNetworkKey(network),
                  family: network.family,
                  label: walletNetworkLabel(l10n, network),
                  value: valueLabel(network),
                  selected: picked.contains(network),
                  words: words,
                  onChanged: saving.value
                      ? null
                      : (on) {
                          note.value = null;
                          draft.value = on
                              ? {...draft.value, network}
                              : ({...draft.value}..remove(network));
                        },
                ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.walletAddPickerSelectedCount(picked.length),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.ob.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          l10n.walletAddPickerHint,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.ob.mutedInk),
        ),
        const SizedBox(height: SpacingTokens.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: walletSettingsLookAheadKey,
            onPressed: saving.value || lookAhead is WalletPreviewLoading
                ? null
                : () => unawaited(
                    ref
                        .read(walletLookAheadProvider(walletId).notifier)
                        .look(entityId: entityId, address: wallet.address),
                  ),
            icon: const SkribbleIcon(data: OpenBudgetIcons.search, size: 18),
            label: Text(l10n.walletSettingsLookAhead),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        switch (lookAhead) {
          WalletPreviewIdle() => const SizedBox.shrink(),
          WalletPreviewLoading() => ObLoadingPanel(
            label: l10n.walletAddPreviewLoading(
              walletNetworkListLabel(l10n, [
                for (final network in offered)
                  if (!reading.contains(network)) network,
              ]),
            ),
          ),
          WalletPreviewLoaded(:final preview) => _LookAheadResult(
            found: foundNow,
            checked: [
              for (final row in preview.networks)
                if (!reading.contains(row.network) &&
                    (supported?.contains(row.network) ?? true))
                  row.network,
            ].length,
          ),
          WalletPreviewFailed(:final reason) => _Note(
            message: switch (reason) {
              WalletPreviewFailure.rateLimited =>
                l10n.walletSettingsLookAheadRateLimited,
              WalletPreviewFailure.unavailable =>
                l10n.walletSettingsLookAheadFailedMessage,
            },
            tone: ObTone.overspent,
          ),
        },
        const SizedBox(height: SpacingTokens.md),
        if (saving.value)
          ObLoadingPanel(
            label: l10n.walletAddReading(
              walletNetworkListLabel(l10n, picked),
            ),
          )
        else if (confirming.value)
          _RemoveConfirmation(
            networks: removedWithValue,
            amount: [
              for (final entry in leaving.entries)
                formatMinorForCode(entry.value, entry.key),
            ].join(' + '),
            onConfirm: apply,
            onCancel: () => confirming.value = false,
          )
        else
          FilledButton(
            key: walletSettingsSaveNetworksKey,
            onPressed: changed ? save : null,
            child: Text(l10n.walletSettingsNetworksSave),
          ),
        if (note.value case final shown? when !saving.value) ...[
          const SizedBox(height: SpacingTokens.sm),
          _Note(message: shown.message, tone: shown.tone),
        ],
      ],
    );
  }

  static bool _sameSet(List<WalletNetwork> a, List<WalletNetwork> b) =>
      a.length == b.length && a.toSet().containsAll(b);
}

/// What "Look for assets on other chains" found.
class _LookAheadResult extends HookWidget {
  const _LookAheadResult({required this.found, required this.checked});

  final List<WalletNetwork> found;

  /// How many chains the wallet does not read were looked at.
  final int checked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final hasFound = found.isNotEmpty;
    final title = hasFound
        ? l10n.walletSettingsFoundTitle(walletNetworkListLabel(l10n, found))
        : l10n.walletSettingsNothingTitle;
    final message = hasFound
        ? l10n.walletSettingsFoundMessage
        : checked == 0
        ? l10n.walletSettingsAllRead
        : l10n.walletSettingsNothingMessage(checked);
    return Semantics(
      liveRegion: true,
      container: true,
      child: ObCard(
        tone: hasFound ? ObTone.funded : ObTone.neutral,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropping a chain that holds value asks first, in the page: what leaves
/// net worth, and a way to keep reading.
class _RemoveConfirmation extends HookWidget {
  const _RemoveConfirmation({
    required this.networks,
    required this.amount,
    required this.onConfirm,
    required this.onCancel,
  });

  final List<WalletNetwork> networks;
  final String amount;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final names = walletNetworkListLabel(l10n, networks);
    return Semantics(
      liveRegion: true,
      container: true,
      child: ObCard(
        tone: ObTone.underfunded,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.warning,
                  size: 20,
                  color: palette.hue(ObTone.underfunded),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.walletSettingsRemoveTitle(names),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.walletSettingsRemoveMessage(amount, names),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.sm,
              children: [
                FilledButton(
                  key: walletSettingsRemoveConfirmKey,
                  onPressed: onConfirm,
                  child: Text(l10n.walletSettingsRemoveConfirm),
                ),
                OutlinedButton(
                  key: walletSettingsRemoveCancelKey,
                  onPressed: onCancel,
                  child: Text(l10n.walletSettingsRemoveCancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Disconnect
// ---------------------------------------------------------------------------

class _DisconnectSection extends HookConsumerWidget {
  const _DisconnectSection({
    required this.wallet,
    required this.accountName,
    required this.entityId,
    required this.accountId,
  });

  final Wallet wallet;
  final String accountName;
  final String entityId;
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final confirming = useState(false);
    final busy = useState(false);
    final failed = useState(false);

    Future<void> disconnect() async {
      busy.value = true;
      failed.value = false;
      final navigator = Navigator.of(context);
      try {
        await ref
            .read(walletActionsProvider.notifier)
            .disconnect(
              walletId: wallet.id!.uuid,
              entityId: entityId,
              accountId: accountId,
            );
        if (context.mounted) navigator.pop(true);
      } on Exception {
        failed.value = true;
        if (context.mounted) busy.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.walletSettingsDisconnectTitle),
        if (!confirming.value) ...[
          Text(
            l10n.walletSettingsDisconnectHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              key: walletSettingsDisconnectKey,
              onPressed: () => confirming.value = true,
              child: Text(l10n.walletSettingsDisconnectButton),
            ),
          ),
        ] else
          Semantics(
            liveRegion: true,
            container: true,
            child: ObCard(
              tone: ObTone.overspent,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.walletSettingsDisconnectConfirmTitle(accountName),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    l10n.walletSettingsDisconnectConfirmMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Wrap(
                    spacing: SpacingTokens.sm,
                    runSpacing: SpacingTokens.sm,
                    children: [
                      FilledButton(
                        key: walletSettingsDisconnectConfirmKey,
                        onPressed: busy.value ? null : disconnect,
                        child: Text(l10n.walletSettingsDisconnectConfirm),
                      ),
                      OutlinedButton(
                        onPressed: busy.value
                            ? null
                            : () => confirming.value = false,
                        child: Text(l10n.walletSettingsDisconnectCancel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (failed.value) ...[
          const SizedBox(height: SpacingTokens.sm),
          _Note(
            message: l10n.walletSettingsDisconnectFailed,
            tone: ObTone.overspent,
          ),
        ],
      ],
    );
  }
}
