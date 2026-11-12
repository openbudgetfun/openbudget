import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_figures.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Income and spending month by month, as a drawn ledger. Figures come
/// from the server's month views in the entity's base currency.
class SpendingTrendsScreen extends HookConsumerWidget {
  const SpendingTrendsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trendsAsync = ref.watch(spendingTrendsProvider(entityId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spendingTrendsTitle)),
      body: trendsAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.spendingTrendsLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (data) {
          if (data.months.every(
            (m) => m.totalIncome == 0 && m.totalExpenses == 0,
          )) {
            return ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                ObStatePanel.empty(
                  title: l10n.spendingTrendsEmptyTitle,
                  message: l10n.spendingTrendsEmptySubtitle,
                  doodle: WiredDoodleKind.comet,
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Row(
                  children: [
                    Expanded(
                      child: ReportFigure(
                        label: l10n.spendingTrendsAvgIncome,
                        amount: formatMinorForCode(
                          data.averageIncome,
                          data.currencyCode,
                        ),
                        tone: ObTone.funded,
                      ),
                    ),
                    Expanded(
                      child: ReportFigure(
                        label: l10n.spendingTrendsAvgExpenses,
                        amount: formatMinorForCode(
                          data.averageExpenses,
                          data.currencyCode,
                        ),
                        tone: ObTone.overspent,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.spendingTrendsMonthly,
                padding: const EdgeInsets.fromLTRB(
                  0,
                  SpacingTokens.lg,
                  0,
                  SpacingTokens.sm,
                ),
              ),
              _MonthlyChart(
                months: data.months,
                currencyCode: data.currencyCode,
              ),
              ObSectionHeader(
                title: l10n.spendingTrendsBreakdown,
                padding: const EdgeInsets.fromLTRB(
                  0,
                  SpacingTokens.lg,
                  0,
                  SpacingTokens.sm,
                ),
              ),
              for (final month in data.months.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: _MonthSummaryTile(
                    month: month,
                    currencyCode: data.currencyCode,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyChart extends HookWidget {
  const _MonthlyChart({required this.months, required this.currencyCode});

  final List<MonthlyTrend> months;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final series = reportSeriesColors(theme);
    String format(int minor) => formatMinorForCode(minor, currencyCode);
    final columns = [
      for (final month in months)
        ReportChartColumn(
          label: reportYyyymmAxisLabel(l10n, month.month),
          values: [
            ReportChartDatum(
              label: l10n.reportsIncome,
              amountLabel: format(month.totalIncome),
              value: month.totalIncome,
              color: series[1],
            ),
            ReportChartDatum(
              label: l10n.reportsExpenses,
              amountLabel: format(month.totalExpenses),
              value: month.totalExpenses,
              color: series[3],
            ),
          ],
        ),
    ];

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          ReportColumnChart(
            height: 150,
            columns: columns,
            semanticsLabel: reportChartSummary(
              l10n,
              title: l10n.spendingTrendsMonthly,
              entries: [
                for (final month in months)
                  (
                    reportYyyymmLabel(l10n, month.month),
                    '${l10n.reportsIncome} ${format(month.totalIncome)}, '
                        '${l10n.reportsExpenses} ${format(month.totalExpenses)}',
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          ReportChartLegend(
            entries: [
              ReportChartDatum(
                label: l10n.reportsIncome,
                amountLabel: '',
                value: 0,
                color: series[1],
              ),
              ReportChartDatum(
                label: l10n.reportsExpenses,
                amountLabel: '',
                value: 0,
                color: series[3],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthSummaryTile extends HookWidget {
  const _MonthSummaryTile({
    required this.month,
    required this.currencyCode,
  });

  final MonthlyTrend month;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final netTone = month.netIncome >= 0 ? ObTone.funded : ObTone.overspent;
    String format(int minor) => formatMinorForCode(minor, currencyCode);

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reportYyyymmLabel(l10n, month.month),
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      monthKeyParts(month.month).year.toString(),
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
                  Text(
                    l10n.reportsNetIncome,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  ObAmount(
                    '${month.netIncome >= 0 ? '+' : ''}${format(month.netIncome)}',
                    tone: netTone,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: ReportFigure(
                  label: l10n.reportsIncome,
                  amount: '+${format(month.totalIncome)}',
                  tone: ObTone.funded,
                ),
              ),
              Expanded(
                child: ReportFigure(
                  label: l10n.reportsExpenses,
                  amount: '-${format(month.totalExpenses)}',
                  tone: ObTone.overspent,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
