import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SpendingTrendsScreen extends HookConsumerWidget {
  const SpendingTrendsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trendsAsync = ref.watch(spendingTrendsProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spendingTrendsTitle)),
      body: trendsAsync.when(
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
                l10n.spendingTrendsLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (data) {
          final sourceCurrency = parseCurrencyCode(data.currencyCode);
          final displayCurrency = converter?.displayCurrency ?? sourceCurrency;

          if (data.months.every((m) => m.transactionCount == 0)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 48,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.spendingTrendsEmptyTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      l10n.spendingTrendsEmptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              // Averages card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AverageTile(
                          label: l10n.spendingTrendsAvgIncome,
                          value:
                              converter?.formatAmount(
                                amountCents: data.averageIncome,
                                sourceCurrency: sourceCurrency,
                              ) ??
                              formatCents(data.averageIncome, sourceCurrency),
                          color: colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: _AverageTile(
                          label: l10n.spendingTrendsAvgExpenses,
                          value:
                              converter?.formatAmount(
                                amountCents: data.averageExpenses,
                                sourceCurrency: sourceCurrency,
                              ) ??
                              formatCents(data.averageExpenses, sourceCurrency),
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Monthly chart
              Text(
                l10n.spendingTrendsMonthly,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              _MonthlyChart(months: data.months, currency: displayCurrency),
              const SizedBox(height: SpacingTokens.lg),

              // Monthly breakdown list
              Text(
                l10n.spendingTrendsBreakdown,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              ...data.months.reversed.map(
                (month) => _MonthSummaryTile(
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

class _AverageTile extends HookWidget {
  const _AverageTile({
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

class _MonthlyChart extends HookWidget {
  const _MonthlyChart({required this.months, required this.currency});

  final List<MonthlyTrend> months;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final maxValue = months.fold<int>(
      0,
      (max, m) => math.max(max, math.max(m.totalIncome, m.totalExpenses)),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            for (final month in months) ...[
              _ChartRow(
                label: _shortMonthName(month.month),
                incomeValue: month.totalIncome,
                expenseValue: month.totalExpenses,
                maxValue: maxValue,
                currency: currency,
                colorScheme: colorScheme,
              ),
              if (month != months.last)
                const SizedBox(height: SpacingTokens.sm),
            ],
            const SizedBox(height: SpacingTokens.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                  color: colorScheme.primary,
                  label: AppLocalizations.of(context).reportsIncome,
                ),
                const SizedBox(width: SpacingTokens.lg),
                _LegendDot(
                  color: colorScheme.error,
                  label: AppLocalizations.of(context).reportsExpenses,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _shortMonthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

class _ChartRow extends HookWidget {
  const _ChartRow({
    required this.label,
    required this.incomeValue,
    required this.expenseValue,
    required this.maxValue,
    required this.currency,
    required this.colorScheme,
  });

  final String label;
  final int incomeValue;
  final int expenseValue;
  final int maxValue;
  final CurrencyCode currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeFraction = maxValue > 0 ? incomeValue / maxValue : 0.0;
    final expenseFraction = maxValue > 0 ? expenseValue / maxValue : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: incomeFraction,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: expenseFraction,
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends HookWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Text(label, style: theme.textTheme.labelSmall),
      ],
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
  final CurrencyCode sourceCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final netColor = month.netIncome >= 0
        ? colorScheme.primary
        : colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _monthName(month.month),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    month.year.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '+${converter?.formatAmount(amountCents: month.totalIncome, sourceCurrency: sourceCurrency) ?? formatCents(month.totalIncome, sourceCurrency)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Text(
                        '-${converter?.formatAmount(amountCents: month.totalExpenses, sourceCurrency: sourceCurrency) ?? formatCents(month.totalExpenses, sourceCurrency)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${month.netIncome >= 0 ? '+' : ''}${converter?.formatAmount(amountCents: month.netIncome, sourceCurrency: sourceCurrency) ?? formatCents(month.netIncome, sourceCurrency)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: netColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
