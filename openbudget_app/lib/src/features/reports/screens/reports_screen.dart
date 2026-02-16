import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class ReportsScreen extends HookConsumerWidget {
  const ReportsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final selectedYear = useState(now.year);
    final selectedMonth = useState(now.month);

    final reportAsync = ref.watch(
      spendingReportProvider(budgetId, selectedYear.value, selectedMonth.value),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            tooltip: l10n.categoryTrendsTitle,
            onPressed: () => context.pushNamed(
              categoryTrendsRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.store_rounded),
            tooltip: l10n.spendingByPayeeTitle,
            onPressed: () => context.pushNamed(
              spendingByPayeeRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            tooltip: l10n.netWorthTitle,
            onPressed: () => context.pushNamed(
              netWorthRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.trending_up_rounded),
            tooltip: l10n.spendingTrendsTitle,
            onPressed: () => context.pushNamed(
              spendingTrendsRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (selectedMonth.value == 1) {
                      selectedMonth.value = 12;
                      selectedYear.value--;
                    } else {
                      selectedMonth.value--;
                    }
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _monthName(l10n, selectedMonth.value, selectedYear.value),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () {
                    if (selectedMonth.value == 12) {
                      selectedMonth.value = 1;
                      selectedYear.value++;
                    } else {
                      selectedMonth.value++;
                    }
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.reportsLoadError,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              data: (report) {
                final currency = CurrencyCode.values.firstWhere(
                  (c) => c.code == report.currencyCode,
                  orElse: () => CurrencyCode.usd,
                );

                return ListView(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  children: [
                    _SummaryCard(
                      report: report,
                      currency: currency,
                      l10n: l10n,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    if (report.categorySpending.isNotEmpty)
                      ...[
                        Text(
                          l10n.reportsSpendingByCategory,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        ...report.categorySpending.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)),
                      ].map((entry) {
                        if (entry is MapEntry<String, int>) {
                          return _CategorySpendingBar(
                            categoryName: entry.key,
                            amountCents: entry.value,
                            maxCents: report.totalExpenses,
                            currency: currency,
                            colorScheme: colorScheme,
                          );
                        }
                        return entry as Widget;
                      }),
                    if (report.categorySpending.isEmpty &&
                        report.transactionCount == 0)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.xl,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 48,
                                color: colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: SpacingTokens.md),
                              Text(
                                l10n.reportsEmptyTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: SpacingTokens.sm),
                              Text(
                                l10n.reportsEmptySubtitle,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(AppLocalizations l10n, int month, int year) {
    final name = switch (month) {
      1 => l10n.budgetMonthJanuary,
      2 => l10n.budgetMonthFebruary,
      3 => l10n.budgetMonthMarch,
      4 => l10n.budgetMonthApril,
      5 => l10n.budgetMonthMay,
      6 => l10n.budgetMonthJune,
      7 => l10n.budgetMonthJuly,
      8 => l10n.budgetMonthAugust,
      9 => l10n.budgetMonthSeptember,
      10 => l10n.budgetMonthOctober,
      11 => l10n.budgetMonthNovember,
      12 => l10n.budgetMonthDecember,
      _ => '',
    };
    return '$name $year';
  }
}

class _SummaryCard extends HookWidget {
  const _SummaryCard({
    required this.report,
    required this.currency,
    required this.l10n,
  });

  final SpendingReport report;
  final CurrencyCode currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final divisor = _pow10(currency.decimals);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.reportsIncome,
                    value:
                        '${currency.symbol}${(report.totalIncome / divisor).toStringAsFixed(currency.decimals)}',
                    color: colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: l10n.reportsExpenses,
                    value:
                        '${currency.symbol}${(report.totalExpenses / divisor).toStringAsFixed(currency.decimals)}',
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.reportsNetIncome,
                    value:
                        '${report.netIncome >= 0 ? '+' : '-'}${currency.symbol}${(report.netIncome.abs() / divisor).toStringAsFixed(currency.decimals)}',
                    color: report.netIncome >= 0
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: l10n.reportsTransactions,
                    value: report.transactionCount.toString(),
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends HookWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CategorySpendingBar extends HookWidget {
  const _CategorySpendingBar({
    required this.categoryName,
    required this.amountCents,
    required this.maxCents,
    required this.currency,
    required this.colorScheme,
  });

  final String categoryName;
  final int amountCents;
  final int maxCents;
  final CurrencyCode currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divisor = _pow10(currency.decimals);
    final fraction = maxCents > 0 ? amountCents / maxCents : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(categoryName, style: theme.textTheme.bodyMedium),
              Text(
                '${currency.symbol}${(amountCents / divisor).toStringAsFixed(currency.decimals)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
