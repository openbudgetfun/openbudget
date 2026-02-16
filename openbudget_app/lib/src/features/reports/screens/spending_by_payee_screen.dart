import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_by_payee_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SpendingByPayeeScreen extends HookConsumerWidget {
  const SpendingByPayeeScreen({required this.budgetId, super.key});

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
      spendingByPayeeProvider(
        budgetId,
        selectedYear.value,
        selectedMonth.value,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.spendingByPayeeTitle)),
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
                if (report.entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.store_rounded,
                          size: 48,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          l10n.spendingByPayeeEmptyTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          l10n.spendingByPayeeEmptySubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final currency = CurrencyCode.values.firstWhere(
                  (c) => c.code == report.currencyCode,
                  orElse: () => CurrencyCode.usd,
                );

                return ListView(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  children: [
                    _TotalCard(
                      totalCents: report.totalSpentCents,
                      payeeCount: report.entries.length,
                      currency: currency,
                      l10n: l10n,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.spendingByPayeeBreakdown,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    ...report.entries.map(
                      (entry) => _PayeeSpendingRow(
                        entry: entry,
                        maxCents: report.totalSpentCents,
                        currency: currency,
                        colorScheme: colorScheme,
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

class _TotalCard extends HookWidget {
  const _TotalCard({
    required this.totalCents,
    required this.payeeCount,
    required this.currency,
    required this.l10n,
  });

  final int totalCents;
  final int payeeCount;
  final CurrencyCode currency;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    l10n.spendingByPayeeTotalSpent,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    formatCents(totalCents, currency),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    l10n.spendingByPayeePayeeCount,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    payeeCount.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
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
}

class _PayeeSpendingRow extends HookWidget {
  const _PayeeSpendingRow({
    required this.entry,
    required this.maxCents,
    required this.currency,
    required this.colorScheme,
  });

  final PayeeSpendingEntry entry;
  final int maxCents;
  final CurrencyCode currency;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = maxCents > 0 ? entry.totalCents / maxCents : 0.0;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.payeeName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.spendingByPayeeTransactionCount(
                        entry.transactionCount,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCents(entry.totalCents, currency),
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
