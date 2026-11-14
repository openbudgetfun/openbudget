import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/models/wallet_holdings_view.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The holdings of one wallet account, grouped by chain.
///
/// One section per network: the chain stamp, the network's subtotal and
/// when it was last read. Staked and unclaimed positions sit under their
/// asset, old prices wear a chip, a network that could not be read says so
/// in its own section, and everything that does not count (hidden by the
/// person, suspected spam, no price) folds into one collapsed Hidden group
/// at the bottom, where each row can be shown or hidden.
///
/// [now] is the moment ages are measured from; it defaults to the clock.
class WalletHoldingsSection extends HookConsumerWidget {
  const WalletHoldingsSection({
    required this.walletId,
    required this.fallbackCurrencyCode,
    this.now,
    super.key,
  });

  final String walletId;
  final String fallbackCurrencyCode;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = useState(false);
    // The cached providers, not hand-rolled client calls: reading the
    // client from a hook's init state crashes with "Cannot listen to
    // inherited widgets inside HookState.initState", and the providers are
    // what tests override.
    final holdingsAsync = ref.watch(walletHoldingsProvider(walletId));
    // A failed read-state call only costs the "read 2 hours ago" lines.
    final states =
        ref.watch(walletNetworkStatesProvider(walletId)).value ??
        const <WalletNetworkState>[];
    final holdings = holdingsAsync.value;
    if (holdings == null) return const SizedBox.shrink();

    final view = buildWalletHoldingsView(
      holdings: holdings,
      networkStates: states,
      fallbackCurrencyCode: fallbackCurrencyCode,
    );
    if (view.isEmpty) return const SizedBox.shrink();

    final clock = now ?? DateTime.now();

    Future<void> setVerdict(
      List<WalletHolding> targets,
      SpamVerdict verdict,
      String name,
    ) async {
      busy.value = true;
      try {
        await ref
            .read(walletActionsProvider.notifier)
            .setHoldingVerdicts(
              walletId: walletId,
              holdingIds: [
                for (final holding in targets) ?holding.id,
              ],
              verdict: verdict,
            );
      } on Exception catch (_) {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.walletHoldingsVerdictFailed(name),
            variant: AppToastVariant.error,
          );
        }
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: SpacingTokens.md),
        ObSectionHeader(
          title: l10n.accountDetailHoldingsTitle,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        ),
        for (final section in view.sections) ...[
          _NetworkSection(
            section: section,
            now: clock,
            busy: busy.value,
            onHide: (group) => setVerdict(
              group.holdings,
              SpamVerdict.hiddenByUser,
              _holdingName(group.primary),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        if (view.hidden.isNotEmpty)
          _HiddenGroup(
            view: view,
            busy: busy.value,
            onShow: (holding) => setVerdict(
              [holding],
              SpamVerdict.allowedByUser,
              _holdingName(holding),
            ),
            onHide: (holding) => setVerdict(
              [holding],
              SpamVerdict.hiddenByUser,
              _holdingName(holding),
            ),
          ),
      ],
    );
  }
}

/// The width an icon button takes, reserved by rows without one.
const double _hideButtonWidth = 48;

/// Whether the reader's text size is large enough that figures and names
/// cannot share a row without squeezing each other to nothing.
bool _isLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;

String _holdingName(WalletHolding holding) =>
    holding.symbol ?? holding.name ?? holding.assetId;

/// One network: its header, a note if it could not be read, and its assets.
class _NetworkSection extends HookWidget {
  const _NetworkSection({
    required this.section,
    required this.now,
    required this.busy,
    required this.onHide,
  });

  final WalletNetworkSection section;
  final DateTime now;
  final bool busy;
  final ValueChanged<WalletAssetGroup> onHide;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final groups = section.groups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NetworkHeader(section: section, now: now),
        if (section.failed) ...[
          const SizedBox(height: SpacingTokens.sm),
          _FailedNetworkNote(
            section: section,
            now: now,
            hasAmounts: groups.isNotEmpty,
          ),
        ],
        if (groups.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          ObCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (index, group) in groups.indexed) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: SpacingTokens.md,
                      endIndent: SpacingTokens.md,
                      color: palette.line,
                    ),
                  WalletHoldingTile(
                    holding: group.primary,
                    priceCurrencyCode:
                        group.primary.priceCurrencyCode ?? section.currencyCode,
                    now: now,
                    onHide: busy ? null : () => onHide(group),
                  ),
                  for (final position in group.positions)
                    WalletHoldingTile(
                      holding: position,
                      priceCurrencyCode:
                          position.priceCurrencyCode ?? section.currencyCode,
                      now: now,
                      nested: true,
                    ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The chain stamp, the subtotal as the figure, and the read status under it.
///
/// A screen reader hears one header: network, subtotal and status.
class _NetworkHeader extends HookWidget {
  const _NetworkHeader({required this.section, required this.now});

  final WalletNetworkSection section;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final network = walletNetworkLabel(l10n, section.network);
    final subtotal = section.subtotalMinor;
    final total = subtotal == null
        ? l10n.walletHoldingsNothingCounted
        : formatMinorForCode(subtotal, section.currencyCode);
    final readAt = section.lastReadAt;
    final status = switch ((readAt, section.hasReadState)) {
      (final DateTime at, _) => l10n.walletHoldingsReadAgo(
        walletAgeLabel(l10n, at, now),
      ),
      (null, true) when !section.failed => l10n.walletHoldingsNeverRead,
      _ => null,
    };

    final stamp = ObChainStamp(family: section.network.family, label: network);
    final header = ObSectionHeader(
      title: total,
      subtitle: status,
      padding: EdgeInsets.zero,
    );

    return Semantics(
      header: true,
      container: true,
      label: [network, total, ?status].join(', '),
      excludeSemantics: true,
      child: _isLargeText(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stamp,
                const SizedBox(height: SpacingTokens.sm),
                header,
              ],
            )
          : Row(
              children: [
                stamp,
                const SizedBox(width: SpacingTokens.md),
                Expanded(child: header),
              ],
            ),
    );
  }
}

/// Why a network could not be read, in its own section.
///
/// With amounts to show it is a quiet warning card ("Showing amounts from 2
/// hours ago"); with none it is the full problem panel.
class _FailedNetworkNote extends HookWidget {
  const _FailedNetworkNote({
    required this.section,
    required this.now,
    required this.hasAmounts,
  });

  final WalletNetworkSection section;
  final DateTime now;
  final bool hasAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final network = walletNetworkLabel(l10n, section.network);
    final readAt = section.lastReadAt;
    final reason = section.lastError;

    if (!hasAmounts || readAt == null) {
      return ObStatePanel.problem(
        title: l10n.walletHoldingsReadFailedWithoutAmounts(network),
        message: reason,
      );
    }

    return ObCard(
      tone: ObTone.underfunded,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.warning,
            size: 20,
            color: palette.hue(ObTone.underfunded),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.walletHoldingsReadFailedWithAmounts(
                    network,
                    walletAgeLabel(l10n, readAt, now),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.ink,
                  ),
                ),
                if (reason != null && reason.isNotEmpty)
                  Text(
                    reason,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One wallet holding: name, symbol and quantity in the asset's decimals on
/// the left; value and unrealised P&L in the price currency on the right.
/// Unrealised P&L is `valueMinor − costBasisMinor`, computed here from the
/// sync's stored figures, and a holding with no cost basis says "Cost
/// unknown".
///
/// A staked or unclaimed position wears a chip, and a cached price wears
/// the old-price chip. A [nested] tile is a further position of the asset
/// above it: it leads with its chip instead of the asset's name. Pass
/// [onHide] to show the hide button.
class WalletHoldingTile extends HookWidget {
  const WalletHoldingTile({
    required this.holding,
    required this.priceCurrencyCode,
    required this.now,
    this.nested = false,
    this.onHide,
    super.key,
  });

  final WalletHolding holding;
  final String priceCurrencyCode;
  final DateTime now;
  final bool nested;
  final VoidCallback? onHide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final valueMinor = holding.valueMinor;
    final costMinor = holding.costBasisMinor;
    final pnlMinor = valueMinor != null && costMinor != null
        ? valueMinor - costMinor
        : null;
    final name = holding.name ?? holding.symbol ?? holding.assetId;
    final symbol = holding.name != null ? holding.symbol : null;
    final pnlTone = switch (pnlMinor) {
      null || 0 => ObTone.neutral,
      > 0 => ObTone.funded,
      _ => ObTone.overspent,
    };
    final chips = _chips(l10n);
    // The chips span the whole tile, so a long one ("Price from 3 days
    // ago") is never squeezed by the figures beside the name.
    final chipRow = chips.isEmpty
        ? null
        : Padding(
            padding: EdgeInsets.only(top: nested ? 0 : SpacingTokens.xs),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xs,
                children: chips,
              ),
            ),
          );
    final quantity = Text(
      l10n.accountHoldingsQuantityLabel(formatHoldingQuantity(holding)),
      style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
    );

    // At large text sizes the figures drop beneath the name.
    final stacked = _isLargeText(context);
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!nested) _AssetTitle(name: name, symbol: symbol),
        quantity,
      ],
    );
    final figures = Column(
      crossAxisAlignment: stacked
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (valueMinor != null)
          ObAmount(
            formatMinorForCode(valueMinor, priceCurrencyCode),
            semanticsLabel: l10n.accountHoldingsValueLabel(
              formatMinorForCode(valueMinor, priceCurrencyCode),
            ),
            style: theme.textTheme.titleSmall,
          )
        else
          Text(
            l10n.accountHoldingsUnpriced,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
        if (pnlMinor != null)
          Text(
            l10n.accountHoldingsPnlLabel(
              formatMinorForCode(pnlMinor, priceCurrencyCode),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.hue(pnlTone),
              fontWeight: FontWeight.w600,
            ),
          )
        else if (valueMinor != null)
          Text(
            l10n.accountHoldingsCostUnknown,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
      ],
    );
    final hideButton = onHide == null
        ? null
        : IconButton(
            tooltip: l10n.walletHoldingsHideSemantics(_holdingName(holding)),
            onPressed: onHide,
            icon: SkribbleIcon(
              data: OpenBudgetIcons.hidden,
              size: 20,
              color: palette.mutedInk,
            ),
          );

    final figuresRow = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              details,
              const SizedBox(height: SpacingTokens.xs),
              Row(
                children: [
                  Expanded(child: figures),
                  ?hideButton,
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(child: details),
              const SizedBox(width: SpacingTokens.sm),
              figures,
              // Reserve the button's width so every row's figures line up.
              hideButton ?? const SizedBox(width: _hideButtonWidth),
            ],
          );

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: nested ? SpacingTokens.lg : SpacingTokens.md,
        end: SpacingTokens.xs,
        top: SpacingTokens.sm,
        bottom: SpacingTokens.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A position's chip leads its tile; an asset's chips close it.
          if (nested) ?chipRow,
          figuresRow,
          if (!nested) ?chipRow,
        ],
      ),
    );
  }

  List<Widget> _chips(AppLocalizations l10n) {
    final asOf = holding.priceAsOf;
    return [
      switch (holding.position) {
        HoldingPosition.available => null,
        HoldingPosition.staked => ObToneChip(
          label: l10n.walletHoldingsStaked,
          tone: ObTone.brand,
          seed: 31,
        ),
        HoldingPosition.unclaimedRewards => ObToneChip(
          label: l10n.walletHoldingsRewards,
          tone: ObTone.funded,
          seed: 37,
        ),
      },
      if (holding.priceQuality == PriceQuality.cached)
        ObToneChip(
          label: asOf == null
              ? l10n.walletHoldingsOldPriceUndated
              : l10n.walletHoldingsOldPrice(walletAgeLabel(l10n, asOf, now)),
          tone: ObTone.underfunded,
          seed: 41,
        ),
    ].nonNulls.toList();
  }
}

/// Renders `quantityRaw` (a BigInt of base units) with the asset's
/// decimals. No floating point touches the quantity.
String formatHoldingQuantity(WalletHolding holding) {
  final decimals = holding.decimals;
  final raw = holding.quantityRaw.toString();
  if (decimals <= 0) return raw;
  final padded = raw.padLeft(decimals + 1, '0');
  final whole = padded.substring(0, padded.length - decimals);
  final fraction = padded.substring(padded.length - decimals);
  final trimmed = fraction.replaceAll(RegExp(r'0+$'), '');
  return trimmed.isEmpty ? whole : '$whole.$trimmed';
}

/// The collapsed Hidden group: a count and its breakdown, and on opening a
/// row per holding with Show or Hide.
class _HiddenGroup extends HookWidget {
  const _HiddenGroup({
    required this.view,
    required this.busy,
    required this.onShow,
    required this.onHide,
  });

  final WalletHoldingsView view;
  final bool busy;
  final ValueChanged<WalletHolding> onShow;
  final ValueChanged<WalletHolding> onHide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final expanded = useState(false);
    final title = l10n.walletHoldingsHiddenTitle(view.hidden.length);
    final breakdown = [
      for (final (reason, text) in [
        (
          HiddenReason.unpriced,
          l10n.walletHoldingsHiddenUnpriced(
            view.hiddenCount(HiddenReason.unpriced),
          ),
        ),
        (
          HiddenReason.suspected,
          l10n.walletHoldingsHiddenSuspected(
            view.hiddenCount(HiddenReason.suspected),
          ),
        ),
        (
          HiddenReason.hiddenByUser,
          l10n.walletHoldingsHiddenByYou(
            view.hiddenCount(HiddenReason.hiddenByUser),
          ),
        ),
      ])
        if (view.hiddenCount(reason) > 0) text,
    ].join(', ');

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Semantics(
              button: true,
              expanded: expanded.value,
              child: InkWell(
                onTap: () => expanded.value = !expanded.value,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: palette.ink,
                                ),
                              ),
                              Text(
                                breakdown,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.mutedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SkribbleIcon(
                          data: expanded.value
                              ? OpenBudgetIcons.chevronUp
                              : OpenBudgetIcons.chevronDown,
                          size: 20,
                          color: palette.mutedInk,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (expanded.value)
            for (final entry in view.hidden) ...[
              Divider(
                height: 1,
                indent: SpacingTokens.md,
                endIndent: SpacingTokens.md,
                color: palette.line,
              ),
              _HiddenTile(
                entry: entry,
                busy: busy,
                onShow: () => onShow(entry.holding),
                onHide: () => onHide(entry.holding),
              ),
            ],
        ],
      ),
    );
  }
}

/// A holding in the Hidden group: its name, where it lives, why it is
/// hidden, and Show (or Hide, for a holding with no price to count).
class _HiddenTile extends HookWidget {
  const _HiddenTile({
    required this.entry,
    required this.busy,
    required this.onShow,
    required this.onHide,
  });

  final HiddenHolding entry;
  final bool busy;
  final VoidCallback onShow;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final holding = entry.holding;
    final name = holding.name ?? holding.symbol ?? holding.assetId;
    final symbol = holding.name != null ? holding.symbol : null;
    final valueMinor = holding.valueMinor;
    final currency = holding.priceCurrencyCode;
    final (reasonLabel, reasonTone) = switch (entry.reason) {
      HiddenReason.hiddenByUser => (
        l10n.walletHoldingsReasonHiddenByYou,
        ObTone.neutral,
      ),
      HiddenReason.suspected => (
        l10n.walletHoldingsReasonSuspected,
        ObTone.underfunded,
      ),
      HiddenReason.unpriced => (
        l10n.walletHoldingsReasonUnpriced,
        ObTone.neutral,
      ),
    };
    final showing = entry.reason != HiddenReason.unpriced;
    final shortName = _holdingName(holding);
    final value = valueMinor != null && currency != null
        ? Text(
            formatMinorForCode(valueMinor, currency),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          )
        : Text(
            l10n.accountHoldingsUnpriced,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          );

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: SpacingTokens.md,
        end: SpacingTokens.xs,
        top: SpacingTokens.sm,
        bottom: SpacingTokens.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLargeText(context)) ...[
            _AssetTitle(name: name, symbol: symbol),
            value,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AssetTitle(name: name, symbol: symbol),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: SpacingTokens.sm,
                  ),
                  child: value,
                ),
              ],
            ),
          Text(
            l10n.walletHoldingsHiddenDetail(
              walletNetworkLabel(l10n, holding.network),
              formatHoldingQuantity(holding),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          // A Wrap, so at a large text size the button drops under the chip.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ObToneChip(label: reasonLabel, tone: reasonTone, seed: 43),
                Tooltip(
                  message: showing
                      ? l10n.walletHoldingsShowSemantics(shortName)
                      : l10n.walletHoldingsHideSemantics(shortName),
                  child: TextButton(
                    onPressed: busy ? null : (showing ? onShow : onHide),
                    child: Text(
                      showing
                          ? l10n.walletHoldingsShow
                          : l10n.walletHoldingsHide,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An asset's name with its ticker beside it. Both shrink, then ellipsise at
/// two lines, so a long name or a scam ticker never overflows its row.
class _AssetTitle extends HookWidget {
  const _AssetTitle({required this.name, required this.symbol});

  final String name;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final ticker = symbol;
    return Text.rich(
      TextSpan(
        text: name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: palette.ink,
        ),
        children: [
          if (ticker != null)
            TextSpan(
              text: '  $ticker',
              style: ObTextStyles.stamp(
                theme.textTheme.labelSmall,
              ).copyWith(color: palette.brand),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
