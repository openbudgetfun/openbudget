import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The Crypto section of net worth: one overprint bar with the entity's
/// wallets split into slices in spot inks, the slices as rows with their value
/// and share, and a switch between chains and assets.
///
/// Every figure comes from `report.cryptoBreakdown`; the app only draws it.
/// The section is hidden while loading and when the entity has no wallets.
/// Both groupings are requested up front, so the switch is instant.
class CryptoBreakdownSection extends HookConsumerWidget {
  const CryptoBreakdownSection({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final grouping = useState(CryptoBreakdownGrouping.byChain);
    final byChain = ref.watch(
      cryptoBreakdownProvider(entityId, CryptoBreakdownGrouping.byChain),
    );
    final byAsset = ref.watch(
      cryptoBreakdownProvider(entityId, CryptoBreakdownGrouping.byAsset),
    );
    final selected = switch (grouping.value) {
      CryptoBreakdownGrouping.byChain => byChain,
      CryptoBreakdownGrouping.byAsset => byAsset,
    };

    return selected.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(top: SpacingTokens.lg),
        child: ObStatePanel.problem(
          title: l10n.cryptoBreakdownLoadError,
          message: error.toString(),
          action: ObStateAction(
            label: l10n.homeRetry,
            onPressed: () => ref
              ..invalidate(cryptoBreakdownProvider(entityId, grouping.value))
              ..invalidate(
                cryptoBreakdownProvider(
                  entityId,
                  CryptoBreakdownGrouping.byChain,
                ),
              )
              ..invalidate(
                cryptoBreakdownProvider(
                  entityId,
                  CryptoBreakdownGrouping.byAsset,
                ),
              ),
          ),
        ),
      ),
      data: (view) => view.walletCount == 0
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.lg),
              child: _CryptoCard(
                view: view,
                grouping: grouping.value,
                onGroupingChanged: (next) => grouping.value = next,
              ),
            ),
    );
  }
}

/// One slice of the bar and its row, ready to draw.
@immutable
class _Slice {
  const _Slice({
    required this.rowKey,
    required this.title,
    required this.subtitle,
    required this.ink,
    required this.valueMinor,
    required this.shareBasisPoints,
  });

  final String rowKey;
  final String title;
  final String? subtitle;
  final Color ink;
  final int valueMinor;
  final int shareBasisPoints;
}

List<_Slice> _slicesOf(
  BuildContext context,
  CryptoBreakdownView view,
  ObPalette palette,
) {
  final l10n = AppLocalizations.of(context);
  final byChain = view.grouping == CryptoBreakdownGrouping.byChain;
  var inkIndex = 0;
  return [
    for (final row in view.rows)
      _Slice(
        rowKey: row.key,
        title: byChain
            ? row.networks.first.displayName
            : _assetTitle(l10n, row),
        subtitle: byChain
            ? l10n.cryptoBreakdownChainHoldings(row.holdingCount)
            : row.isOther
            ? l10n.cryptoBreakdownOtherHoldings(row.holdingCount)
            : _networksLine(l10n, row.networks),
        // A chain keeps the ink its stamp prints in everywhere. Assets span
        // chains, so they take the spot inks in rank order, and the words
        // beside each slice carry the meaning, never the ink.
        ink: byChain
            ? ObChainStamp.inkOf(row.networks.first.family, palette)
            : row.isOther
            ? palette.line
            : palette.spot(inkIndex++),
        valueMinor: row.valueMinor,
        shareBasisPoints: row.shareBasisPoints,
      ),
  ];
}

String _assetTitle(AppLocalizations l10n, CryptoBreakdownRow row) {
  if (row.isOther) return l10n.cryptoBreakdownOther;
  final label = row.symbol ?? row.name;
  if (label != null && label.trim().isNotEmpty) return label;
  final id = row.assetId;
  if (id == null || id.length <= 12) return id ?? row.key;
  return '${id.substring(0, 6)}…${id.substring(id.length - 4)}';
}

/// "Ethereum", "Ethereum, Base", or "Ethereum, Base +3".
String _networksLine(
  AppLocalizations l10n,
  List<WalletNetwork> networks,
) {
  final names = networks.map((network) => network.displayName).toList();
  if (names.length <= 2) return names.join(', ');
  return l10n.cryptoBreakdownNetworksMore(
    names.take(2).join(', '),
    names.length - 2,
  );
}

String _shareLabel(BuildContext context, int basisPoints) {
  if (basisPoints < 100) {
    return AppLocalizations.of(context).cryptoBreakdownShareUnderOne;
  }
  return NumberFormat.percentPattern(
    Localizations.localeOf(context).toString(),
  ).format(basisPoints / 10000);
}

class _CryptoCard extends HookWidget {
  const _CryptoCard({
    required this.view,
    required this.grouping,
    required this.onGroupingChanged,
  });

  final CryptoBreakdownView view;
  final CryptoBreakdownGrouping grouping;
  final ValueChanged<CryptoBreakdownGrouping> onGroupingChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final slices = _slicesOf(context, view, palette);
    final groupingLabel = switch (grouping) {
      CryptoBreakdownGrouping.byChain => l10n.cryptoBreakdownByChain,
      CryptoBreakdownGrouping.byAsset => l10n.cryptoBreakdownByAsset,
    };
    final mutedSmall = theme.textTheme.bodySmall?.copyWith(
      color: palette.mutedInk,
    );

    return ObCard(
      key: const Key('crypto-breakdown-section'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The toggle drops under the title when the card is too narrow.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.xs,
            children: [
              Text(
                l10n.cryptoBreakdownTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: _GroupingToggle(
                      key: const Key('crypto-breakdown-toggle-by-chain'),
                      label: l10n.cryptoBreakdownByChain,
                      selected: grouping == CryptoBreakdownGrouping.byChain,
                      onTap: () =>
                          onGroupingChanged(CryptoBreakdownGrouping.byChain),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Flexible(
                    child: _GroupingToggle(
                      key: const Key('crypto-breakdown-toggle-by-asset'),
                      label: l10n.cryptoBreakdownByAsset,
                      selected: grouping == CryptoBreakdownGrouping.byAsset,
                      onTap: () =>
                          onGroupingChanged(CryptoBreakdownGrouping.byAsset),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: ObAmount(
                  formatMinorForCode(view.totalMinor, view.currencyCode),
                  key: const Key('crypto-breakdown-total'),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                child: Text(
                  l10n.cryptoBreakdownWallets(view.walletCount),
                  style: mutedSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          if (slices.isEmpty)
            Text(
              l10n.cryptoBreakdownEmpty,
              key: const Key('crypto-breakdown-empty'),
              style: mutedSmall,
            )
          else ...[
            _OverprintBar(
              key: ValueKey('crypto-breakdown-bar-${grouping.name}'),
              slices: slices,
              semanticLabel: l10n.cryptoBreakdownBarLabel(
                groupingLabel,
                slices
                    .map(
                      (slice) => l10n.cryptoBreakdownBarShare(
                        slice.title,
                        _shareLabel(context, slice.shareBasisPoints),
                      ),
                    )
                    .join(', '),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            for (final (index, slice) in slices.indexed) ...[
              if (index > 0)
                Divider(height: 1, thickness: 1, color: palette.line),
              _SliceRow(slice: slice, currencyCode: view.currencyCode),
            ],
          ],
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.cryptoBreakdownFootnote, style: mutedSmall),
          if (!view.isComplete) ...[
            const SizedBox(height: SpacingTokens.xs),
            Row(
              key: const Key('crypto-breakdown-missing-rates'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.warning,
                  size: 14,
                  color: palette.underfunded,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: Text(
                    l10n.cryptoBreakdownMissingRates(
                      view.missingCurrencyCodes.join(', '),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.underfunded,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One slice as a row: its ink swatch, name and where it lives, then its
/// value in the reporting currency over its share of the total.
class _SliceRow extends HookWidget {
  const _SliceRow({required this.slice, required this.currencyCode});

  final _Slice slice;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final subtitle = slice.subtitle;
    return Padding(
      key: ValueKey('crypto-breakdown-row-${slice.rowKey}'),
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: slice.ink,
                border: Border.all(color: palette.ink, width: 1.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slice.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ObAmount(
                formatMinorForCode(slice.valueMinor, currencyCode),
                style: theme.textTheme.titleSmall,
              ),
              Text(
                _shareLabel(context, slice.shareBasisPoints),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupingToggle extends HookWidget {
  const _GroupingToggle({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
              ),
              decoration: ObRoughDecoration(
                color: selected ? palette.highlight : null,
                outline: selected ? palette.brand : null,
                radius: 8,
                strokeWidth: 1.4,
                seed: 83,
              ),
              // Centred in the 44 point target without stretching its width.
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? palette.ink : palette.mutedInk,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The overprint bar: the slices side by side in their spot inks, divided by
/// ink strokes so neighbours of one ink stay apart, inside a hand-drawn
/// outline. The teal second print lands a few points down and to the right of
/// the bar, off-register, the way the mark's does. The bar inks in from the
/// left unless the system asks for reduced motion.
class _OverprintBar extends HookWidget {
  const _OverprintBar({
    required this.slices,
    required this.semanticLabel,
    super.key,
  });

  final List<_Slice> slices;
  final String semanticLabel;

  static const double _height = 32;
  static const Offset _registerOffset = Offset(3, 3);

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final controller = useAnimationController(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 520),
    );
    useEffect(() {
      controller.forward();
      return null;
    }, const []);
    final progress = useAnimation(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: _height + _registerOffset.dy,
        width: double.infinity,
        child: CustomPaint(
          painter: _OverprintBarPainter(
            slices: slices,
            progress: reduceMotion ? 1 : progress,
            paper: palette.surface,
            ink: palette.ink,
            secondPrint: palette.overprint,
            registerOffset: _registerOffset,
          ),
        ),
      ),
    );
  }
}

class _OverprintBarPainter extends CustomPainter {
  const _OverprintBarPainter({
    required this.slices,
    required this.progress,
    required this.paper,
    required this.ink,
    required this.secondPrint,
    required this.registerOffset,
  });

  final List<_Slice> slices;
  final double progress;
  final Color paper;
  final Color ink;
  final Color secondPrint;
  final Offset registerOffset;

  static const double _radius = 6;
  static const double _penWidth = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = Rect.fromLTWH(
      0,
      0,
      size.width - registerOffset.dx,
      size.height - registerOffset.dy,
    );
    if (bar.isEmpty) return;
    final outer = RRect.fromRectAndRadius(bar, const Radius.circular(_radius));
    // The ink fills up to the centre of the pen line, like every sticker.
    final fill = bar.deflate(ObPen.inset(strokeWidth: _penWidth));
    final shape = RRect.fromRectAndRadius(
      fill,
      const Radius.circular(_radius - 2),
    );

    // The second print first: the whole bar again in teal, off-register.
    canvas
      ..drawRRect(outer.shift(registerOffset), Paint()..color = secondPrint)
      ..drawRRect(outer, Paint()..color = paper)
      ..save()
      ..clipRRect(shape);

    final total = slices.fold<int>(
      0,
      (sum, slice) => sum + slice.shareBasisPoints,
    );
    final divider = Paint()
      ..color = ink
      ..strokeWidth = 1.4;
    var accumulated = 0;
    final reveal = fill.left + fill.width * progress.clamp(0.0, 1.0);
    for (final slice in slices) {
      final left = fill.left + fill.width * accumulated / total;
      accumulated += slice.shareBasisPoints;
      final right = fill.left + fill.width * accumulated / total;
      final visibleRight = right < reveal ? right : reveal;
      if (visibleRight > left) {
        canvas.drawRect(
          Rect.fromLTRB(left, fill.top, visibleRight, fill.bottom),
          Paint()..color = slice.ink,
        );
      }
      if (accumulated < total && right <= reveal) {
        canvas.drawLine(
          Offset(right, fill.top),
          Offset(right, fill.bottom),
          divider,
        );
      }
    }
    canvas.restore();

    ObPen.outline(
      canvas,
      bar.size,
      color: ink,
      radius: _radius,
      strokeWidth: _penWidth,
      seed: 41,
    );
  }

  @override
  bool shouldRepaint(_OverprintBarPainter oldDelegate) =>
      oldDelegate.slices != slices ||
      oldDelegate.progress != progress ||
      oldDelegate.paper != paper ||
      oldDelegate.ink != ink ||
      oldDelegate.secondPrint != secondPrint;
}
