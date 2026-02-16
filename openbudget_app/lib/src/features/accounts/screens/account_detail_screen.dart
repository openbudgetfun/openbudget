import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AccountDetailScreen extends HookConsumerWidget {
  const AccountDetailScreen({
    required this.budgetId,
    required this.accountId,
    super.key,
  });

  final String budgetId;
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountListProvider(budgetId));
    final txnAsync = ref.watch(
      accountTransactionsProvider(budgetId, accountId),
    );

    final accountData = accountsAsync
        .whenData(
          (accounts) =>
              accounts.where((a) => a.id?.toString() == accountId).firstOrNull,
        )
        .value;
    final currencyCode = accountData != null
        ? CurrencyCode.values.firstWhere(
            (c) => c.code == accountData.currencyCode,
            orElse: () => CurrencyCode.usd,
          )
        : CurrencyCode.usd;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId/accounts'),
        ),
        title: Text(accountData?.name ?? l10n.accountListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: l10n.reconcileButton,
            onPressed: () => _reconcile(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          if (accountData != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.md),
              color: colorScheme.primaryContainer.withAlpha(50),
              child: Column(
                children: [
                  Text(
                    l10n.accountDetailBalance,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    formatCents(accountData.balanceCents, currencyCode),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accountData.balanceCents >= 0
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusChip(
                        icon: Icons.circle_outlined,
                        label: l10n.transactionUncleared,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _StatusChip(
                        icon: Icons.check_circle_outline,
                        label: l10n.transactionCleared,
                        color: ColorTokens.secondary,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _StatusChip(
                        icon: Icons.lock_outline_rounded,
                        label: l10n.transactionReconciled,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: txnAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  l10n.transactionLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.transactionEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      accountTransactionsProvider(budgetId, accountId),
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.sm,
                    ),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      return _TransactionRow(
                        transaction: txn,
                        currencyCode: currencyCode,
                        onToggleCleared: txn.reconciled
                            ? null
                            : () => _toggleCleared(context, ref, txn),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCleared(
    BuildContext context,
    WidgetRef ref,
    Transaction txn,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(accountTransactionActionsProvider.notifier)
          .toggleCleared(
            transactionId: txn.id?.toString() ?? '',
            budgetId: budgetId,
            accountId: accountId,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionEditError)));
      }
    }
  }

  Future<void> _reconcile(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reconcileTitle),
        content: Text(l10n.reconcileMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.reconcileButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final count = await ref
          .read(accountTransactionActionsProvider.notifier)
          .reconcileAccount(accountId: accountId, budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.reconcileSuccess(count))));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reconcileError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }
}

class _StatusChip extends HookWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _TransactionRow extends HookWidget {
  const _TransactionRow({
    required this.transaction,
    required this.currencyCode,
    this.onToggleCleared,
  });

  final Transaction transaction;
  final CurrencyCode currencyCode;
  final VoidCallback? onToggleCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInflow = transaction.amountCents > 0;

    final statusIcon = transaction.reconciled
        ? Icons.lock_outline_rounded
        : transaction.cleared
        ? Icons.check_circle_outline
        : Icons.circle_outlined;
    final statusColor = transaction.reconciled
        ? colorScheme.primary
        : transaction.cleared
        ? ColorTokens.secondary
        : colorScheme.outline;

    return InkWell(
      onTap: onToggleCleared,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(statusIcon, size: 20, color: statusColor),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(transaction.transactionDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatCents(transaction.amountCents, currencyCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isInflow ? ColorTokens.secondary : colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
