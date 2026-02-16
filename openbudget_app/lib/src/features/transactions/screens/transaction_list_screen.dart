import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class TransactionListScreen extends HookConsumerWidget {
  const TransactionListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionListProvider(budgetId));
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currency =
        budgetAsync.whenOrNull(
          data: (budget) => CurrencyCode.values.firstWhere(
            (c) => c.code == budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          ),
        ) ??
        CurrencyCode.usd;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId'),
        ),
        title: Text(l10n.transactionListTitle),
      ),
      body: transactionsAsync.when(
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
                l10n.transactionLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.transactionEmpty,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final sorted = List.of(transactions)
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(transactionListProvider(budgetId)),
            child: ListView.builder(
              padding: const EdgeInsets.all(SpacingTokens.md),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final tx = sorted[index];
                final isIncome = tx.amountCents > 0;
                final color = isIncome
                    ? ColorTokens.secondary
                    : ColorTokens.error;
                final icon = isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded;

                return Card(
                  margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(25),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      tx.description,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(tx.transactionDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Text(
                      formatCents(tx.amountCents, currency),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
