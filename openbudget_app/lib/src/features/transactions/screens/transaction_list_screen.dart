import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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

enum TransactionFilter { all, income, expense }

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

    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final filter = useState(TransactionFilter.all);

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

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
          // Filter out child split transactions (they have parentTransactionId).
          final childParentIds = transactions
              .where((tx) => tx.parentTransactionId != null)
              .map((tx) => tx.parentTransactionId.toString())
              .toSet();
          final topLevel = transactions
              .where((tx) => tx.parentTransactionId == null)
              .toList();
          final sorted = List.of(topLevel)
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

          final query = searchQuery.value.toLowerCase();
          final filtered = sorted.where((tx) {
            if (filter.value == TransactionFilter.income &&
                tx.amountCents <= 0) {
              return false;
            }
            if (filter.value == TransactionFilter.expense &&
                tx.amountCents >= 0) {
              return false;
            }
            if (query.isNotEmpty &&
                !tx.description.toLowerCase().contains(query)) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.sm,
                  SpacingTokens.md,
                  0,
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: l10n.transactionSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.transactionFilterAll,
                      selected: filter.value == TransactionFilter.all,
                      onSelected: () => filter.value = TransactionFilter.all,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _FilterChip(
                      label: l10n.transactionFilterIncome,
                      selected: filter.value == TransactionFilter.income,
                      onSelected: () => filter.value = TransactionFilter.income,
                      color: ColorTokens.secondary,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _FilterChip(
                      label: l10n.transactionFilterExpense,
                      selected: filter.value == TransactionFilter.expense,
                      onSelected: () =>
                          filter.value = TransactionFilter.expense,
                      color: ColorTokens.error,
                    ),
                    const Spacer(),
                    Text(
                      l10n.transactionResultCount(filtered.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
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
                          transactions.isEmpty
                              ? l10n.transactionEmpty
                              : l10n.transactionNoResults,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(transactionListProvider(budgetId)),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
                        final isSplit = childParentIds.contains(
                          tx.id?.toString(),
                        );
                        return _TransactionTile(
                          transaction: tx,
                          budgetId: budgetId,
                          currencyCode: currency,
                          isSplit: isSplit,
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends HookWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor.withAlpha(30),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? chipColor : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _TransactionTile extends HookConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.budgetId,
    required this.currencyCode,
    this.isSplit = false,
  });

  final Transaction transaction;
  final String budgetId;
  final CurrencyCode currencyCode;
  final bool isSplit;

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
    final statusTooltip = transaction.reconciled
        ? l10n.transactionReconciled
        : transaction.cleared
        ? l10n.transactionCleared
        : l10n.transactionUncleared;

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
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: statusTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(RadiusTokens.xl),
                  onTap: transaction.reconciled
                      ? null
                      : () => _toggleCleared(context, ref, l10n),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(statusIcon, size: 20, color: statusColor),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              CircleAvatar(
                backgroundColor: color.withAlpha(25),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSplit) ...[
                const SizedBox(width: SpacingTokens.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.splitLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(transaction.transactionDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (transaction.memo != null && transaction.memo!.isNotEmpty)
                Text(
                  transaction.memo!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
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

  Future<void> _toggleCleared(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .toggleCleared(
            transactionId: transaction.id?.toString() ?? '',
            budgetId: budgetId,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionEditError)));
      }
    }
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
