import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
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
                return _TransactionTile(
                  transaction: tx,
                  budgetId: budgetId,
                  currencyCode: currency,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends HookConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.budgetId,
    required this.currencyCode,
  });

  final Transaction transaction;
  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.amountCents > 0;
    final color = isIncome ? ColorTokens.secondary : ColorTokens.error;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.lg),
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context, l10n, colorScheme),
      onDismissed: (_) => _deleteTransaction(context, ref, l10n, colorScheme),
      child: Card(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        child: ListTile(
          onTap: () => _showEditDialog(context),
          leading: CircleAvatar(
            backgroundColor: color.withAlpha(25),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            transaction.description,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatDate(transaction.transactionDate),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Text(
            formatCents(transaction.amountCents, currencyCode),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n"${transaction.description}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .deleteTransaction(
            transactionId: transaction.id?.toString() ?? '',
            budgetId: budgetId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => EditTransactionDialog(
        transaction: transaction,
        budgetId: budgetId,
        currencyCode: currencyCode,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
