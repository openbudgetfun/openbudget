import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_figures.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Income and spending month by month, as a drawn ledger.
class SpendingTrendsScreen extends HookConsumerWidget {
  const SpendingTrendsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trendsAsync = ref.watch(spendingTrendsProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

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
          final sourceCurrency = data.currencyCode;

          if (data.months.every((m) => m.transactionCount == 0)) {
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
                        amount:
                            converter?.formatAmount(
                              amountCents: data.averageIncome,
                              currencyCode: sourceCurrency,
                            ) ??
                            formatCentsForCode(
                              data.averageIncome,
                              sourceCurrency,
                            ),
                        tone: ObTone.funded,
                      ),
                    ),
                    Expanded(
                      child: ReportFigure(
                        label: l10n.spendingTrendsAvgExpenses,
                        amount:
                            converter?.formatAmount(
                              amountCents: data.averageExpenses,
                              currencyCode: sourceCurrency,
                            ) ??
                            formatCentsForCode(
                              data.averageExpenses,
                              sourceCurrency,
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
                sourceCurrency: sourceCurrency,
                converter: converter,
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
                    sourceCurrency: sourceCurrency,
                    converter: converter,
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
  const _MonthlyChart({
    required this.months,
    required this.sourceCurrency,
    required this.converter,
  });

  final List<MonthlyTrend> months;
  final String sourceCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final series = reportSeriesColors(theme);
    String format(int cents) =>
        converter?.formatAmount(
          amountCents: cents,
          currencyCode: sourceCurrency,
        ) ??
        formatCentsForCode(cents, sourceCurrency);
    final columns = [
      for (final month in months)
        ReportChartColumn(
          label: reportMonthAxisLabel(l10n, month.month),
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
                    reportMonthLabel(l10n, month.month, month.year),
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
    required this.sourceCurrency,
    required this.converter,
  });

  final MonthlyTrend month;
  final String sourceCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final netTone = month.netIncome >= 0 ? ObTone.funded : ObTone.overspent;
    String format(int cents) =>
        converter?.formatAmount(
          amountCents: cents,
          currencyCode: sourceCurrency,
        ) ??
        formatCentsForCode(cents, sourceCurrency);

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
                      reportMonthName(l10n, month.month),
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      month.year.toString(),
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
