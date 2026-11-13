import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/account_kind_labels.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/date_labels.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Net worth: the headline in the reporting currency, a trust line saying
/// where the rates came from, the history chart, and the breakdown in
/// three tabs. Every converted figure comes from the server; incomplete
/// currencies are listed, never guessed.
class NetWorthScreen extends HookConsumerWidget {
  const NetWorthScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final viewAsync = ref.watch(netWorthProvider);
    final historyRange = useState(NetWorthRange.threeMonths);
    final breakdownTab = useState(_NetWorthTab.byEntity);

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        backgroundColor: palette.canvas,
        surfaceTintColor: palette.canvas,
        title: Text(l10n.netWorthTitle),
      ),
      body: viewAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.netWorthLoadError,
              message: error.toString(),
              action: ObStateAction(
                label: l10n.homeRetry,
                onPressed: () => ref.invalidate(netWorthProvider),
              ),
            ),
          ],
        ),
        data: (view) => ObReadableWidth(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          builder: (context, padding) => ListView(
            padding: padding,
            children: [
              _NetWorthHeadline(view: view),
              if (!view.isComplete) ...[
                const SizedBox(height: SpacingTokens.lg),
                _IncompleteCurrenciesCard(view: view),
              ],
              const SizedBox(height: SpacingTokens.lg),
              _HistoryCard(
                range: historyRange.value,
                onRangeChanged: (range) {
                  historyRange.value = range;
                },
              ),
              const SizedBox(height: SpacingTokens.lg),
              _BreakdownTabs(
                selected: breakdownTab.value,
                onSelected: (tab) => breakdownTab.value = tab,
              ),
              const SizedBox(height: SpacingTokens.md),
              switch (breakdownTab.value) {
                _NetWorthTab.byEntity => _ByEntityTab(view: view),
                _NetWorthTab.byCurrency => _ByCurrencyTab(view: view),
                _NetWorthTab.byAccount => _ByAccountTab(view: view),
              },
            ],
          ),
        ),
      ),
    );
  }
}

enum _NetWorthTab { byEntity, byCurrency, byAccount }

/// Sorts converted rows largest first and puts rows with no rate last: an
/// unconverted native figure is in another unit, so it never competes with
/// converted ones for the top of the list.
int _byConvertedThenUnconverted(int? aConverted, int? bConverted) {
  if (aConverted == null && bConverted == null) return 0;
  if (aConverted == null) return 1;
  if (bConverted == null) return -1;
  return bConverted.compareTo(aConverted);
}

/// The headline: the combined figure under the highlighter, the currency
/// chip that changes the reporting currency in place, assets against
/// liabilities, and the trust line saying how fresh the rates are, kept on
/// the same card as the number it vouches for.
class _NetWorthHeadline extends HookConsumerWidget {
  const _NetWorthHeadline({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final reportingCurrency = ref.watch(reportingCurrencyProvider).value ?? '';
    final positive = view.netWorthMinor >= 0;

    return ObCard(
      key: const Key('net-worth-headline'),
      raised: true,
      shadow: palette.overprint,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.netWorthHeadlineEyebrow,
                  style: ObTextStyles.eyebrow(
                    theme.textTheme.labelSmall,
                  ).copyWith(color: palette.mutedInk),
                ),
              ),
              _ReportingCurrencyChip(currencyCode: reportingCurrency),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // The highlighter marks the figure the screen is about; a
          // negative total is set in its hue instead, never highlighted.
          if (positive)
            ObHighlighter(
              child: ObHeroAmount(
                formatMinorForCode(view.netWorthMinor, view.currencyCode),
                style: theme.textTheme.displaySmall,
              ),
            )
          else
            ObHeroAmount(
              formatMinorForCode(view.netWorthMinor, view.currencyCode),
              tone: ObTone.overspent,
              style: theme.textTheme.displaySmall,
            ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _HeadlineMetric(
                  icon: OpenBudgetIcons.coins,
                  label: l10n.netWorthAssets,
                  amount: formatMinorForCode(
                    view.assetsMinor,
                    view.currencyCode,
                  ),
                  tone: ObTone.funded,
                ),
              ),
              Container(
                width: 1.4,
                height: 36,
                margin: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                ),
                color: palette.line,
              ),
              Expanded(
                child: _HeadlineMetric(
                  icon: OpenBudgetIcons.creditCard,
                  label: l10n.netWorthLiabilities,
                  amount: formatMinorForCode(
                    view.liabilitiesMinor,
                    view.currencyCode,
                  ),
                  tone: ObTone.overspent,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Divider(height: 1, thickness: 1.4, color: palette.line),
          const SizedBox(height: SpacingTokens.sm),
          _TrustLine(view: view),
        ],
      ),
    );
  }
}

/// Assets or liabilities under the headline: a small glyph and label over
/// the figure in its tone.
class _HeadlineMetric extends HookWidget {
  const _HeadlineMetric({
    required this.icon,
    required this.label,
    required this.amount,
    required this.tone,
  });

  final WiredSvgIconData icon;
  final String label;
  final String amount;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkribbleIcon(data: icon, size: 14, color: palette.hue(tone)),
            const SizedBox(width: SpacingTokens.xs),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: ObAmount(
            amount,
            tone: tone,
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

/// The sticker chip that switches the reporting currency; the server
/// re-converts everything, the app never does.
class _ReportingCurrencyChip extends HookConsumerWidget {
  const _ReportingCurrencyChip({required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = Theme.of(context).ob;
    return InkWell(
      key: const Key('net-worth-currency-chip'),
      onTap: () => unawaited(_pickCurrency(context, ref)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        decoration: ObRoughDecoration(
          color: palette.brandWash,
          outline: palette.quietPen,
          radius: 8,
          strokeWidth: 1.4,
          seed: 53,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyCode.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.brand,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            SkribbleIcon(
              data: OpenBudgetIcons.chevronDown,
              size: 14,
              color: palette.brand,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          children: [
            for (final currency in CurrencyCode.values)
              ListTile(
                leading: Text(
                  currency.code,
                  style: Theme.of(sheetContext).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(sheetContext).ob.ink,
                  ),
                ),
                title: Text(currency.name),
                trailing: currency.code == currencyCode.toUpperCase()
                    ? const SkribbleIcon(data: OpenBudgetIcons.check)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(currency.code),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == currencyCode) return;
    await ref
        .read(reportingCurrencyActionsProvider.notifier)
        .setReportingCurrency(selected);
    // Converted figures are re-queried; nothing is converted locally.
    ref
      ..invalidate(netWorthProvider)
      ..invalidate(netWorthForEntitiesProvider)
      ..invalidate(netWorthHistoryProvider);
  }
}

/// The trust line: the date the rates are from, with a Stale badge when
/// the server says the rates are old.
class _TrustLine extends HookWidget {
  const _TrustLine({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Row(
      children: [
        SkribbleIcon(
          data: OpenBudgetIcons.info,
          size: 14,
          color: palette.mutedInk,
        ),
        const SizedBox(width: SpacingTokens.xs),
        Expanded(
          child: Text(
            l10n.netWorthRatesFrom(DateLabels.full(context, view.asOf)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
        ),
        if (view.hasStaleRates)
          ObToneChip(
            key: const Key('net-worth-stale-badge'),
            label: l10n.fxRateStale,
            tone: ObTone.underfunded,
            icon: SkribbleIcon(
              data: OpenBudgetIcons.warning,
              size: 14,
              color: palette.underfunded,
            ),
          ),
      ],
    );
  }
}

/// The note for incomplete conversions: which currencies were left out of
/// the figure above and how many accounts each holds.
class _IncompleteCurrenciesCard extends HookWidget {
  const _IncompleteCurrenciesCard({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final incomplete = view.currencies
        .where((row) => row.convertedMinor == null)
        .toList();

    return ObCard(
      key: const Key('net-worth-incomplete-card'),
      tone: ObTone.underfunded,
      seed: 31,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.warning,
            size: 20,
            color: palette.underfunded,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.netWorthIncompleteTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                for (final row in incomplete)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: Text(
                      l10n.netWorthIncompleteLine(
                        row.accountCount,
                        row.currencyCode,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.ink,
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

/// The history card: 3M / 1Y / All toggles over the server's daily, weekly
/// and monthly points, the change across the range, and the chart with its
/// high and low marked. Incomplete stretches are drawn dashed and hollow.
class _HistoryCard extends HookConsumerWidget {
  const _HistoryCard({required this.range, required this.onRangeChanged});

  final NetWorthRange range;
  final ValueChanged<NetWorthRange> onRangeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final historyAsync = ref.watch(netWorthHistoryProvider(range));
    final mutedSmall = theme.textTheme.bodySmall?.copyWith(
      color: palette.mutedInk,
    );

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.netWorthHistoryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final (index, candidate) in NetWorthRange.values.indexed)
                Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? SpacingTokens.xs : 0,
                  ),
                  child: _RangeToggle(
                    label: switch (candidate) {
                      NetWorthRange.threeMonths => l10n.netWorthHistory3M,
                      NetWorthRange.oneYear => l10n.netWorthHistory1Y,
                      NetWorthRange.all => l10n.netWorthHistoryAll,
                    },
                    selected: candidate == range,
                    onTap: () => onRangeChanged(candidate),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          historyAsync.when(
            loading: () => SizedBox(
              height: 168,
              child: Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
            ),
            error: (error, _) => ObStatePanel.problem(
              title: l10n.netWorthLoadError,
              message: error.toString(),
            ),
            data: (history) {
              final points = history.points;
              if (points.length < 2) {
                return SizedBox(
                  height: 168,
                  child: Center(
                    child: Text(l10n.reportsEmptySubtitle, style: mutedSmall),
                  ),
                );
              }
              final currencyCode = history.currencyCode;
              final first = points.first;
              final last = points.last;
              // Same currency, exact minor units: a subtraction, not a
              // conversion.
              final changeMinor = last.netWorthMinor - first.netWorthMinor;
              final up = changeMinor >= 0;
              final tone = up ? ObTone.funded : ObTone.overspent;
              final values = points.map((point) => point.netWorthMinor);
              final high = values.reduce(math.max);
              final low = values.reduce(math.min);
              final hasIncomplete = points.any((point) => !point.isComplete);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkribbleIcon(
                        data: up
                            ? OpenBudgetIcons.trendingUp
                            : OpenBudgetIcons.trendingDown,
                        size: 18,
                        color: palette.hue(tone),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      ObAmount(
                        formatMinorForCode(changeMinor.abs(), currencyCode),
                        tone: tone,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Flexible(
                        child: Text(
                          l10n.netWorthChangeSince(
                            DateLabels.short(context, first.date),
                          ),
                          style: mutedSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  SizedBox(
                    height: 168,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HistoryLinePainter(
                              points: points,
                              lineColor: palette.hue(tone),
                              washColor: palette.wash(tone),
                              gridColor: palette.line,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          child: Text(
                            formatMinorForCode(high, currencyCode),
                            style: mutedSmall,
                          ),
                        ),
                        PositionedDirectional(
                          bottom: 0,
                          start: 0,
                          child: Text(
                            formatMinorForCode(low, currencyCode),
                            style: mutedSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    children: [
                      Text(
                        DateLabels.short(context, first.date),
                        style: mutedSmall,
                      ),
                      const Spacer(),
                      Text(
                        DateLabels.short(context, last.date),
                        style: mutedSmall,
                      ),
                    ],
                  ),
                  if (hasIncomplete) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var dash = 0; dash < 3; dash++)
                              Container(
                                width: 5,
                                height: 2.6,
                                margin: const EdgeInsetsDirectional.only(
                                  end: 3,
                                ),
                                color: palette.hue(tone),
                              ),
                          ],
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            l10n.netWorthIncompleteLegend,
                            style: mutedSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The history line over a wash of its own tone, with faint rules at the
/// high and low. Complete stretches are one solid line; a stretch ending in
/// an incomplete point is dashed, and the last point is a dot, hollow when
/// it is incomplete.
class _HistoryLinePainter extends CustomPainter {
  const _HistoryLinePainter({
    required this.points,
    required this.lineColor,
    required this.washColor,
    required this.gridColor,
  });

  final List<NetWorthPoint> points;
  final Color lineColor;
  final Color washColor;
  final Color gridColor;

  // Room at the top and bottom for the high and low labels.
  static const _labelBand = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final values = points.map((point) => point.netWorthMinor).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    const sidePad = 6.0;
    const top = _labelBand;
    final bottom = size.height - _labelBand;
    final drawableWidth = size.width - sidePad * 2;
    final drawableHeight = bottom - top;

    Offset pointAt(int index) {
      final x = sidePad + drawableWidth * index / (points.length - 1);
      final y = top + drawableHeight * (1 - (values[index] - minValue) / span);
      return Offset(x, y);
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(const Offset(0, top), Offset(size.width, top), gridPaint)
      ..drawLine(Offset(0, bottom), Offset(size.width, bottom), gridPaint);

    final line = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    final wash = Path.from(line)
      ..lineTo(pointAt(points.length - 1).dx, bottom)
      ..lineTo(pointAt(0).dx, bottom)
      ..close();
    canvas.drawPath(wash, Paint()..color = washColor);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Complete stretches are one solid path; each run of segments ending
    // in an incomplete point is one dashed path, so the dashes keep their
    // rhythm across the run however dense the points are.
    final solid = Path();
    Path? incompleteRun;
    for (var i = 1; i < points.length; i++) {
      final from = pointAt(i - 1);
      final to = pointAt(i);
      if (points[i].isComplete) {
        if (incompleteRun != null) {
          _drawDashed(canvas, incompleteRun, linePaint);
          incompleteRun = null;
        }
        solid
          ..moveTo(from.dx, from.dy)
          ..lineTo(to.dx, to.dy);
      } else {
        (incompleteRun ??= Path()..moveTo(from.dx, from.dy)).lineTo(
          to.dx,
          to.dy,
        );
      }
    }
    if (incompleteRun != null) _drawDashed(canvas, incompleteRun, linePaint);
    canvas.drawPath(solid, linePaint);

    final end = pointAt(points.length - 1);
    final endComplete = points.last.isComplete;
    canvas.drawCircle(
      end,
      endComplete ? 4.2 : 4.6,
      Paint()
        ..color = endComplete ? lineColor : washColor
        ..style = PaintingStyle.fill,
    );
    if (!endComplete) {
      canvas.drawCircle(
        end,
        4.6,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 7.0;
    const gap = 5.0;
    for (final metric in path.computeMetrics()) {
      var travelled = 0.0;
      while (travelled < metric.length) {
        final end = math.min(travelled + dash, metric.length);
        canvas.drawPath(metric.extractPath(travelled, end), paint);
        travelled = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HistoryLinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.washColor != washColor ||
      oldDelegate.gridColor != gridColor;
}

class _RangeToggle extends HookWidget {
  const _RangeToggle({
    required this.label,
    required this.selected,
    required this.onTap,
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
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.xs,
            ),
            decoration: ObRoughDecoration(
              color: selected ? palette.highlight : null,
              outline: selected ? palette.brand : null,
              radius: 8,
              strokeWidth: 1.4,
              seed: 67,
            ),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? palette.ink : palette.mutedInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The three-way tab switch over the breakdown.
class _BreakdownTabs extends HookWidget {
  const _BreakdownTabs({required this.selected, required this.onSelected});

  final _NetWorthTab selected;
  final ValueChanged<_NetWorthTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ObCard(
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              key: const Key('net-worth-tab-by-entity'),
              label: l10n.netWorthTabByEntity,
              selected: selected == _NetWorthTab.byEntity,
              onTap: () => onSelected(_NetWorthTab.byEntity),
            ),
          ),
          Expanded(
            child: _TabButton(
              key: const Key('net-worth-tab-by-currency'),
              label: l10n.netWorthTabByCurrency,
              selected: selected == _NetWorthTab.byCurrency,
              onTap: () => onSelected(_NetWorthTab.byCurrency),
            ),
          ),
          Expanded(
            child: _TabButton(
              key: const Key('net-worth-tab-by-account'),
              label: l10n.netWorthTabByAccount,
              selected: selected == _NetWorthTab.byAccount,
              onTap: () => onSelected(_NetWorthTab.byAccount),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends HookWidget {
  const _TabButton({
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
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: ObRoughDecoration(
              color: selected ? palette.highlighter : null,
              outline: selected ? palette.ink : null,
              radius: 8,
              strokeWidth: 1.4,
              seed: 73,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.xs,
              vertical: SpacingTokens.sm,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? palette.ink : palette.mutedInk,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// By entity: chips include or exclude entities, and a changed set
/// re-queries the server.
class _ByEntityTab extends HookConsumerWidget {
  const _ByEntityTab({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final entitiesAsync = ref.watch(entityListProvider);
    final included = useState(<String>{
      for (final entity in view.entities) entity.entityId.toString(),
    });
    final scopedAsync = ref.watch(
      netWorthForEntitiesProvider(included.value),
    );
    final rows = scopedAsync.value?.entities ?? view.entities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entitiesAsync.hasValue)
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              for (final entity in entitiesAsync.value!)
                _EntityFilterChip(
                  entityId: entity.id?.toString() ?? '',
                  label: entity.name,
                  included: included.value.contains(
                    entity.id?.toString() ?? '',
                  ),
                  onChanged: (include) {
                    final next = Set<String>.from(included.value);
                    final id = entity.id?.toString() ?? '';
                    if (id.isEmpty) return;
                    if (include) {
                      next.add(id);
                    } else {
                      if (next.length <= 1) return;
                      next.remove(id);
                    }
                    included.value = next;
                  },
                ),
            ],
          ),
        const SizedBox(height: SpacingTokens.sm),
        ObCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: SpacingTokens.md,
                    endIndent: SpacingTokens.md,
                    color: palette.line,
                  ),
                Padding(
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
                              row.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: palette.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              switch (row.kind) {
                                EntityKind.individual =>
                                  l10n.entityKindPersonal,
                                EntityKind.soleTrader =>
                                  l10n.entityKindSoleTrader,
                                EntityKind.company => l10n.entityKindCompany,
                              },
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                            // Under the name, not beside the amount: there
                            // it squeezed the name to a few letters.
                            if (!row.isComplete)
                              Row(
                                children: [
                                  SkribbleIcon(
                                    data: OpenBudgetIcons.warning,
                                    size: 12,
                                    color: palette.underfunded,
                                  ),
                                  const SizedBox(width: SpacingTokens.xs),
                                  Flexible(
                                    child: Text(
                                      l10n.netWorthEntityIncomplete,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: palette.underfunded,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      ObAmount(
                        formatMinorForCode(
                          row.netWorthMinor,
                          view.currencyCode,
                        ),
                        tone: row.netWorthMinor >= 0
                            ? ObTone.funded
                            : ObTone.overspent,
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EntityFilterChip extends HookWidget {
  const _EntityFilterChip({
    required this.entityId,
    required this.label,
    required this.included,
    required this.onChanged,
  });

  final String entityId;
  final String label;
  final bool included;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return FilterChip(
      key: ValueKey('net-worth-entity-$entityId'),
      avatar: SkribbleIcon(
        data: included ? OpenBudgetIcons.check : OpenBudgetIcons.hidden,
        size: 16,
        color: included ? palette.brand : palette.mutedInk,
      ),
      label: Text(label),
      selected: included,
      onSelected: onChanged,
    );
  }
}

/// By currency: each currency's native total, its converted total in the
/// reporting currency, and the rate line that produced it.
class _ByCurrencyTab extends HookWidget {
  const _ByCurrencyTab({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final rows = [...view.currencies]
      ..sort(
        (a, b) => _byConvertedThenUnconverted(
          a.convertedMinor,
          b.convertedMinor,
        ),
      );

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: SpacingTokens.md,
                endIndent: SpacingTokens.md,
                color: palette.line,
              ),
            Padding(
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
                          row.currencyCode,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.ink,
                          ),
                        ),
                        Text(
                          l10n.netWorthAccountsCount(row.accountCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                        if (row.convertedMinor != null &&
                            row.currencyCode != view.currencyCode &&
                            row.fxRate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Wrap(
                              spacing: SpacingTokens.xs,
                              runSpacing: SpacingTokens.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  _rateLine(context, row, view.currencyCode),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                                if (row.isStale)
                                  ObToneChip(
                                    label: l10n.fxRateStale,
                                    tone: ObTone.underfunded,
                                  ),
                              ],
                            ),
                          ),
                        if (row.convertedMinor == null)
                          _NoRateNote(currencyCode: row.currencyCode),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ObAmount(
                        formatMinorForCode(row.nativeMinor, row.currencyCode),
                        style: theme.textTheme.titleSmall,
                      ),
                      if (row.convertedMinor != null &&
                          row.currencyCode != view.currencyCode)
                        ObAmount(
                          formatMinorForCode(
                            row.convertedMinor!,
                            view.currencyCode,
                          ),
                          tone: ObTone.brand,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// By account: assets and liabilities grouped by kind, with the valuation
/// date on the accounts the server values directly.
class _ByAccountTab extends HookWidget {
  const _ByAccountTab({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final accounts = view.accounts;
    final assets = accounts.where((row) => !row.isLiability).toList()
      ..sort(
        (a, b) => _byConvertedThenUnconverted(
          a.convertedMinor,
          b.convertedMinor,
        ),
      );
    final liabilities = accounts.where((row) => row.isLiability).toList()
      ..sort(
        (a, b) => _byConvertedThenUnconverted(
          a.convertedMinor,
          b.convertedMinor,
        ),
      );

    if (accounts.isEmpty) {
      return ObStatePanel.empty(
        title: l10n.netWorthEmptyTitle,
        message: l10n.netWorthEmptySubtitle,
        doodle: WiredDoodleKind.leaf,
        tone: ObTone.neutral,
      );
    }

    Widget group(String title, List<NetWorthAccountRow> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSectionHeader(
          title: title,
          padding: const EdgeInsets.only(
            left: SpacingTokens.xs,
            bottom: SpacingTokens.xs,
          ),
        ),
        ObCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final (index, row) in rows.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    indent: SpacingTokens.md,
                    endIndent: SpacingTokens.md,
                    color: palette.line,
                  ),
                Padding(
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
                              row.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: palette.ink,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    accountKindLabel(row.kind, l10n),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: palette.mutedInk,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (row.valuationDate != null) ...[
                                  const SizedBox(width: SpacingTokens.xs),
                                  Flexible(
                                    child: Text(
                                      l10n.netWorthValuedOn(
                                        DateLabels.short(
                                          context,
                                          row.valuationDate!,
                                        ),
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: palette.mutedInk,
                                            fontStyle: FontStyle.italic,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (row.convertedMinor == null)
                              _NoRateNote(currencyCode: row.currencyCode),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ObAmount(
                            formatMinorForCode(
                              row.balanceMinor,
                              row.currencyCode,
                            ),
                            style: theme.textTheme.titleSmall,
                          ),
                          if (row.convertedMinor != null &&
                              row.currencyCode != view.currencyCode)
                            ObAmount(
                              formatMinorForCode(
                                row.convertedMinor!,
                                view.currencyCode,
                              ),
                              tone: ObTone.brand,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assets.isNotEmpty) group(l10n.netWorthAssets, assets),
        if (assets.isNotEmpty && liabilities.isNotEmpty)
          const SizedBox(height: SpacingTokens.md),
        if (liabilities.isNotEmpty)
          group(l10n.netWorthLiabilities, liabilities),
      ],
    );
  }
}

/// "1 USD = 0.79 GBP · Nov 1": the rate behind a converted figure and the
/// day it is from.
String _rateLine(
  BuildContext context,
  NetWorthCurrencyRow row,
  String reportingCurrencyCode,
) {
  final l10n = AppLocalizations.of(context);
  final rateLine = l10n.netWorthRateLine(
    row.currencyCode,
    row.fxRate!,
    reportingCurrencyCode,
  );
  final rateDate = row.fxRateDate;
  if (rateDate == null) return rateLine;
  return l10n.netWorthRateDated(rateLine, DateLabels.short(context, rateDate));
}

/// The note on a row the server could not convert: its figure stays in
/// its own currency and is left out of the total.
class _NoRateNote extends HookWidget {
  const _NoRateNote({required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.warning,
            size: 12,
            color: palette.underfunded,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(
            child: Text(
              l10n.netWorthNoRate(currencyCode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.underfunded,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
