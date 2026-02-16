import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/category_trends_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CategoryTrendsScreen extends HookConsumerWidget {
  const CategoryTrendsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trendsAsync = ref.watch(categoryTrendsProvider(budgetId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryTrendsTitle)),
      body: trendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
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
                l10n.categoryTrendsLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data.categories.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 48,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.categoryTrendsEmptyTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      l10n.categoryTrendsEmptySubtitle,
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

          final currency = CurrencyCode.values.firstWhere(
            (c) => c.code == data.currencyCode,
            orElse: () => CurrencyCode.usd,
          );

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _MonthHeaders(months: data.months, l10n: l10n),
              const SizedBox(height: SpacingTokens.sm),
              ...data.categories.map(
                (cat) => _CategoryTrendRow(
                  category: cat,
                  months: data.months,
                  currency: currency,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthHeaders extends HookWidget {
  const _MonthHeaders({required this.months, required this.l10n});

  final List<MonthLabel> months;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(width: 120),
        ...months.map(
          (m) => Expanded(
            child: Text(
              _shortMonth(m.month),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 72),
      ],
    );
  }

  String _shortMonth(int month) {
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

class _CategoryTrendRow extends HookWidget {
  const _CategoryTrendRow({
    required this.category,
    required this.months,
    required this.currency,
  });

  final CategoryTrendLine category;
  final List<MonthLabel> months;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxCents = category.monthlyCents.fold<int>(0, math.max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.categoryName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatCents(category.totalCents, currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: [
                for (var i = 0; i < category.monthlyCents.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: _MiniBar(
                      value: category.monthlyCents[i],
                      maxValue: maxCents,
                      currency: currency,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBar extends HookWidget {
  const _MiniBar({
    required this.value,
    required this.maxValue,
    required this.currency,
    required this.colorScheme,
  });

  final int value;
  final int maxValue;
  final CurrencyCode currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxValue > 0 ? value / maxValue : 0.0;

    return Tooltip(
      message: formatCents(value, currency),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fraction.clamp(0.05, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: value > 0
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value > 0 ? formatCents(value, currency) : '-',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
