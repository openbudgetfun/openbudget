import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_group_names.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_figures.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The Reflect tab: hand-drawn statements about the month and the totals.
class ReportsScreen extends HookConsumerWidget {
  const ReportsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final selectedMonth = useState(MonthKey.fromDate(DateTime.now()));

    final reportAsync = ref.watch(
      spendingReportProvider(entityId, selectedMonth.value),
    );
    final netWorthAsync = ref.watch(netWorthProvider);
    final monthLabel = reportYyyymmLabel(l10n, selectedMonth.value);

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(title: Text(l10n.tabReflect)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.sm,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          _ReflectCard(
            title: l10n.spendingByPayeeBreakdown,
            icon: OpenBudgetIcons.pieChart,
            onTap: () => context.pushNamed(
              spendingByPayeeRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: reportAsync.when(
              loading: () => ObLoadingPanel(label: l10n.reportsLoading),
              error: (error, _) => _PreviewProblem(error: error),
              data: (report) => _SpendingBreakdownPreview(
                report: report,
                monthLabel: monthLabel,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _ReflectCard(
            title: l10n.netWorthTitle,
            icon: OpenBudgetIcons.scale,
            onTap: () => context.pushNamed(
              netWorthRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: netWorthAsync.when(
              loading: () => ObLoadingPanel(label: l10n.reportsLoading),
              error: (error, _) => _PreviewProblem(error: error),
              data: (data) => _NetWorthPreview(data: data),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObOutlinedButton(
            onPressed: () => context.pushNamed(
              spendingTrendsRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkribbleIcon(data: OpenBudgetIcons.barChart, size: 18),
                const SizedBox(width: SpacingTokens.sm),
                Text(l10n.spendingTrendsTitle),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObOutlinedButton(
            onPressed: () => context.pushNamed(
              multiMonthComparisonRoute,
              pathParameters: {'entityId': entityId},
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SkribbleIcon(data: OpenBudgetIcons.scale, size: 18),
                const SizedBox(width: SpacingTokens.sm),
                Text(l10n.comparisonTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable paper card with a pen heading over one live figure.
class _ReflectCard extends HookWidget {
  const _ReflectCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onTap,
  });

  final String title;
  final WiredSvgIconData icon;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkribbleIcon(data: icon, size: 20, color: palette.brand),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: palette.ink,
                  ),
                ),
              ),
              SkribbleIcon(
                data: OpenBudgetIcons.chevronRight,
                size: 18,
                color: palette.mutedInk,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          child,
        ],
      ),
    );
  }
}

/// A preview that could not load, said plainly inside its card.
class _PreviewProblem extends HookWidget {
  const _PreviewProblem({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ObStatePanel.problem(
      title: l10n.reportsLoadError,
      message: error.toString(),
    );
  }
}

/// The month's spending as one drawn bar and a labelled legend.
class _SpendingBreakdownPreview extends HookWidget {
  const _SpendingBreakdownPreview({
    required this.report,
    required this.monthLabel,
  });

  final SpendingReport report;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final series = reportSeriesColors(theme);
    final sortedEntries = report.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categories = sortedEntries.take(6).toList();
    final currencyCode = report.currencyCode;
    final listedTotal = categories.fold<int>(
      0,
      (sum, item) => sum + item.value,
    );
    final otherTotal = report.totalExpenses - listedTotal;

    String format(int minor) => formatMinorForCode(minor, currencyCode);

    final segments = [
      for (final (index, entry) in categories.indexed)
        ReportChartDatum(
          label: reportGroupLabel(l10n, entry.key),
          amountLabel: format(entry.value),
          value: entry.value,
          color: series[index % series.length],
        ),
      if (otherTotal > 0)
        ReportChartDatum(
          label: l10n.reportsOtherCategories,
          amountLabel: format(otherTotal),
          value: otherTotal,
          color: palette.mutedInk,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.mutedInk,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        ObAmount(
          format(report.totalExpenses),
          style: theme.textTheme.headlineMedium,
        ),
        if (segments.isEmpty) ...[
          const SizedBox(height: SpacingTokens.md),
          ObStatePanel.empty(
            title: l10n.reportsEmptyTitle,
            message: l10n.reportsEmptySubtitle,
            doodle: WiredDoodleKind.sparkle,
            tone: ObTone.neutral,
          ),
        ] else ...[
          const SizedBox(height: SpacingTokens.md),
          ObSectionHeader(
            title: l10n.reportsSpendingByCategory,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: SpacingTokens.sm),
          ReportShareBar(
            segments: segments,
            semanticsLabel: reportChartSummary(
              l10n,
              title: l10n.reportsSpendingByCategory,
              entries: [
                for (final segment in segments)
                  (segment.label, segment.amountLabel),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          ReportChartLegend(entries: segments),
        ],
      ],
    );
  }
}

/// Net worth with its two drawn columns, in the reporting currency the
/// server already converted for us.
class _NetWorthPreview extends HookWidget {
  const _NetWorthPreview({required this.data});

  final NetWorthView data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currencyCode = data.currencyCode;
    final assets = data.assetsMinor;
    final liabilities = data.liabilitiesMinor;
    final netWorth = data.netWorthMinor;
    final series = reportSeriesColors(theme);
    final assetsLabel = formatMinorForCode(assets, currencyCode);
    final liabilitiesLabel = formatMinorForCode(liabilities, currencyCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObAmount(
          formatMinorForCode(netWorth, currencyCode),
          tone: netWorth >= 0 ? ObTone.funded : ObTone.overspent,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: ReportFigure(
                label: l10n.netWorthAssets,
                amount: assetsLabel,
                tone: ObTone.funded,
              ),
            ),
            Expanded(
              child: ReportFigure(
                label: l10n.netWorthLiabilities,
                amount: liabilitiesLabel,
                tone: ObTone.overspent,
                alignEnd: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.md),
        ReportColumnChart(
          height: 72,
          columns: [
            ReportChartColumn(
              label: l10n.netWorthAssets,
              values: [
                ReportChartDatum(
                  label: l10n.netWorthAssets,
                  amountLabel: assetsLabel,
                  value: assets.abs(),
                  color: series[1],
                ),
              ],
            ),
            ReportChartColumn(
              label: l10n.netWorthLiabilities,
              values: [
                ReportChartDatum(
                  label: l10n.netWorthLiabilities,
                  amountLabel: liabilitiesLabel,
                  value: liabilities.abs(),
                  color: series[3],
                ),
              ],
            ),
          ],
          semanticsLabel: reportChartSummary(
            l10n,
            title: l10n.netWorthTitle,
            entries: [
              (l10n.netWorthAssets, assetsLabel),
              (l10n.netWorthLiabilities, liabilitiesLabel),
            ],
          ),
        ),
      ],
    );
  }
}
