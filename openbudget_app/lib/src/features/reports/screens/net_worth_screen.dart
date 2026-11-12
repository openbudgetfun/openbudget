import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/account_kind_labels.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
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
        title: Text(
          l10n.netWorthTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
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
        data: (view) => ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          children: [
            _NetWorthHeadline(view: view),
            const SizedBox(height: SpacingTokens.sm),
            _TrustLine(view: view),
            if (!view.isComplete) ...[
              const SizedBox(height: SpacingTokens.sm),
              _IncompleteCurrenciesCard(view: view),
            ],
            const SizedBox(height: SpacingTokens.md),
            _HistoryCard(
              range: historyRange.value,
              onRangeChanged: (range) {
                historyRange.value = range;
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            _BreakdownTabs(
              selected: breakdownTab.value,
              onSelected: (tab) => breakdownTab.value = tab,
            ),
            const SizedBox(height: SpacingTokens.sm),
            switch (breakdownTab.value) {
              _NetWorthTab.byEntity => _ByEntityTab(view: view),
              _NetWorthTab.byCurrency => _ByCurrencyTab(view: view),
              _NetWorthTab.byAccount => _ByAccountTab(view: view),
            },
          ],
        ),
      ),
    );
  }
}

enum _NetWorthTab { byEntity, byCurrency, byAccount }

/// The headline: net worth in the reporting currency with a chip that
/// changes the reporting currency in place, then assets and liabilities.
class _NetWorthHeadline extends HookConsumerWidget {
  const _NetWorthHeadline({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final reportingCurrency = ref.watch(reportingCurrencyProvider).value ?? '';

    return ObCard(
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.netWorthTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _ReportingCurrencyChip(currencyCode: reportingCurrency),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          ObAmount(
            formatMinorForCode(view.netWorthMinor, view.currencyCode),
            highlighted: view.netWorthMinor >= 0,
            tone: view.netWorthMinor >= 0 ? ObTone.neutral : ObTone.overspent,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.netWorthAssets,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    ObAmount(
                      formatMinorForCode(view.assetsMinor, view.currencyCode),
                      tone: ObTone.funded,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.netWorthLiabilities,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    ObAmount(
                      formatMinorForCode(
                        view.liabilitiesMinor,
                        view.currencyCode,
                      ),
                      tone: ObTone.overspent,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

/// The trust line: where the rates came from, with a Stale badge when the
/// server says the rates are old.
class _TrustLine extends HookWidget {
  const _TrustLine({required this.view});

  final NetWorthView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final dateLabel = DateFormat.yMd().format(view.asOf);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Row(
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.info,
            size: 14,
            color: palette.mutedInk,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Text(
              l10n.netWorthRatesFrom(dateLabel),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ),
          if (view.hasStaleRates)
            ObToneChip(
              label: l10n.fxRateStale,
              tone: ObTone.underfunded,
              icon: SkribbleIcon(
                data: OpenBudgetIcons.warning,
                size: 14,
                color: palette.underfunded,
              ),
            ),
        ],
      ),
    );
  }
}

/// The warning card for incomplete conversions: which currencies were left
/// out and how many accounts each holds.
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

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: ObRoughDecoration(
        color: palette.underfundedWash,
        radius: 10,
        seed: 31,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.warning,
                size: 16,
                color: palette.underfunded,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  l10n.netWorthIncompleteTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          for (final row in incomplete)
            Padding(
              padding: const EdgeInsets.only(top: 2),
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
    );
  }
}

/// The history card: 3M / 1Y / All toggles over the server's daily, weekly
/// and monthly points. Incomplete points are drawn hollow.
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

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.netWorthTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
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
              height: 140,
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
                  height: 140,
                  child: Center(
                    child: Text(
                      l10n.reportsEmptySubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ),
                );
              }
              final currencyCode = history.currencyCode;
              final first = points.first;
              final last = points.last;
              final up = last.netWorthMinor >= first.netWorthMinor;
              final tone = up ? ObTone.funded : ObTone.overspent;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _HistoryLinePainter(
                        points: points,
                        lineColor: palette.hue(tone),
                        inkColor: palette.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.MMMd().format(first.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatMinorForCode(
                              last.netWorthMinor,
                              currencyCode,
                            ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: palette.hue(tone),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          if (points.any((point) => !point.isComplete))
                            Tooltip(
                              message: l10n.netWorthIncompletePoint,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: palette.hue(tone),
                                    width: 1.6,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The hand-drawn line: one ink polyline, filled dots for complete points
/// and hollow rings for the incomplete ones.
class _HistoryLinePainter extends CustomPainter {
  const _HistoryLinePainter({
    required this.points,
    required this.lineColor,
    required this.inkColor,
  });

  final List<NetWorthPoint> points;
  final Color lineColor;
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final values = points.map((point) => point.netWorthMinor).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final span = maxValue - minValue == 0 ? 1 : maxValue - minValue;

    const leftPad = 6.0;
    const rightPad = 6.0;
    const topPad = 10.0;
    const bottomPad = 10.0;
    final drawableWidth = size.width - leftPad - rightPad;
    final drawableHeight = size.height - topPad - bottomPad;

    Offset pointAt(int index) {
      final x = leftPad + drawableWidth * index / (points.length - 1);
      final y =
          topPad + drawableHeight * (1 - (values[index] - minValue) / span);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Every sixth point gets a dot; incomplete ones stay hollow.
    for (var i = 0; i < points.length; i++) {
      final isSampled = i == 0 || i == points.length - 1 || i % 6 == 0;
      if (!isSampled) continue;
      final center = pointAt(i);
      final complete = points[i].isComplete;
      final dotPaint = Paint()
        ..color = lineColor
        ..style = complete ? PaintingStyle.fill : PaintingStyle.stroke;
      if (!complete) {
        dotPaint.strokeWidth = 1.8;
      }
      canvas.drawCircle(center, complete ? 3.2 : 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HistoryLinePainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.inkColor != inkColor;
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
              label: l10n.netWorthTabByEntity,
              selected: selected == _NetWorthTab.byEntity,
              onTap: () => onSelected(_NetWorthTab.byEntity),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: l10n.netWorthTabByCurrency,
              selected: selected == _NetWorthTab.byCurrency,
              onTap: () => onSelected(_NetWorthTab.byCurrency),
            ),
          ),
          Expanded(
            child: _TabButton(
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
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            decoration: ObRoughDecoration(
              color: selected ? palette.highlight : null,
              outline: selected ? palette.quietPen : null,
              radius: 8,
              strokeWidth: 1.4,
              seed: 73,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
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
                if (index > 0) Divider(height: 1, color: palette.line),
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
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                          if (!row.isComplete)
                            Text(
                              l10n.netWorthIncompletePoint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
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
        (a, b) => (b.convertedMinor ?? b.nativeMinor).compareTo(
          a.convertedMinor ?? a.nativeMinor,
        ),
      );

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) Divider(height: 1, color: palette.line),
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
                          Text(
                            '${l10n.netWorthRateLine(row.currencyCode, row.fxRate!, view.currencyCode)}'
                            '${row.fxRateDate == null ? '' : ' \u00b7 ${DateFormat.MMMd().format(row.fxRateDate!)}'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
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
                      if (row.isStale)
                        ObToneChip(
                          label: l10n.fxRateStale,
                          tone: ObTone.underfunded,
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
        (a, b) => (b.convertedMinor ?? b.balanceMinor).compareTo(
          a.convertedMinor ?? a.balanceMinor,
        ),
      );
    final liabilities = accounts.where((row) => row.isLiability).toList()
      ..sort(
        (a, b) => (b.convertedMinor ?? b.balanceMinor).compareTo(
          a.convertedMinor ?? a.balanceMinor,
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
                if (index > 0) Divider(height: 1, color: palette.line),
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
                                        DateFormat.MMMd().format(
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
