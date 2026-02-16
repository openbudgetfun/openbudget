import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _StatusFilter { all, uncleared, cleared, reconciled }

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

    final isSearching = useState(false);
    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final statusFilter = useState(_StatusFilter.all);

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
        title: isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.accountDetailSearchHint,
                  border: InputBorder.none,
                ),
                onChanged: (value) => searchQuery.value = value,
              )
            : Text(accountData?.name ?? l10n.accountListTitle),
        actions: [
          IconButton(
            icon: Icon(
              isSearching.value ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              isSearching.value = !isSearching.value;
              if (!isSearching.value) {
                searchController.clear();
                searchQuery.value = '';
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: l10n.reconcileButton,
            onPressed: txnAsync.hasValue
                ? () => _reconcile(context, ref, txnAsync.value!, currencyCode)
                : null,
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
          // Status filter chips.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              children: [
                for (final filter in _StatusFilter.values) ...[
                  if (filter != _StatusFilter.values.first)
                    const SizedBox(width: SpacingTokens.xs),
                  ChoiceChip(
                    label: Text(switch (filter) {
                      _StatusFilter.all => l10n.accountFilterAll,
                      _StatusFilter.uncleared => l10n.accountFilterUncleared,
                      _StatusFilter.cleared => l10n.accountFilterCleared,
                      _StatusFilter.reconciled => l10n.accountFilterReconciled,
                    }),
                    selected: statusFilter.value == filter,
                    onSelected: (_) => statusFilter.value = filter,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
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
                // Build payee and envelope name lookup maps.
                final payeeAsync = ref.watch(payeeListProvider(budgetId));
                final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
                final payeeMap = <String, String>{};
                if (payeeAsync.hasValue) {
                  for (final payee in payeeAsync.value!) {
                    final id = payee.id?.toString();
                    if (id != null) payeeMap[id] = payee.name;
                  }
                }
                final envelopeMap = <String, String>{};
                if (summaryAsync.hasValue && summaryAsync.value != null) {
                  for (final cat in summaryAsync.value!.categories) {
                    for (final env in cat.envelopes) {
                      final id = env.id?.toString();
                      if (id != null) envelopeMap[id] = env.name;
                    }
                  }
                }

                // Apply search filter.
                var filtered = transactions;
                if (searchQuery.value.isNotEmpty) {
                  final query = searchQuery.value.toLowerCase();
                  filtered = filtered
                      .where(
                        (t) =>
                            t.description.toLowerCase().contains(query) ||
                            (t.memo?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
                }

                // Apply status filter.
                filtered = switch (statusFilter.value) {
                  _StatusFilter.all => filtered,
                  _StatusFilter.uncleared =>
                    filtered.where((t) => !t.cleared && !t.reconciled).toList(),
                  _StatusFilter.cleared =>
                    filtered.where((t) => t.cleared && !t.reconciled).toList(),
                  _StatusFilter.reconciled =>
                    filtered.where((t) => t.reconciled).toList(),
                };

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.value.isNotEmpty
                          ? l10n.transactionNoResults
                          : l10n.transactionEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // Compute running balances on full list, then map to filtered.
                final startingBalance = accountData?.balanceCents ?? 0;
                final totalTxnAmount = transactions.fold<int>(
                  0,
                  (sum, t) => sum + t.amountCents,
                );
                final currentBalance = startingBalance + totalTxnAmount;
                final balanceMap = <String, int>{};
                var balance = currentBalance;
                for (var i = 0; i < transactions.length; i++) {
                  balanceMap[transactions[i].id?.toString() ?? '$i'] = balance;
                  balance -= transactions[i].amountCents;
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final txn = filtered[index];
                      final runningBalance =
                          balanceMap[txn.id?.toString() ?? '$index'] ?? 0;
                      final payeeName = txn.payeeId != null
                          ? payeeMap[txn.payeeId.toString()]
                          : null;
                      final envelopeName = txn.envelopeId != null
                          ? envelopeMap[txn.envelopeId.toString()]
                          : null;
                      return _TransactionRow(
                        transaction: txn,
                        currencyCode: currencyCode,
                        runningBalanceCents: runningBalance,
                        payeeName: payeeName,
                        envelopeName: envelopeName,
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

  Future<void> _reconcile(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    CurrencyCode currencyCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Compute cleared balance from transactions.
    var clearedBalanceCents = 0;
    for (final txn in transactions) {
      if (txn.reconciled || txn.cleared) {
        clearedBalanceCents += txn.amountCents;
      }
    }

    final result = await showDialog<int>(
      context: context,
      builder: (_) => _ReconcileDialog(
        clearedBalanceCents: clearedBalanceCents,
        currencyCode: currencyCode,
      ),
    );

    if (result == null || !context.mounted) return;

    try {
      final response = await ref
          .read(accountTransactionActionsProvider.notifier)
          .reconcileWithBalance(
            accountId: accountId,
            budgetId: budgetId,
            statementBalanceCents: result,
          );
      if (context.mounted) {
        final count = response[0];
        final adjustment = response[1];
        if (adjustment != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.reconcileSuccessWithAdjustment(
                  count,
                  formatCents(adjustment, currencyCode),
                ),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.reconcileSuccess(count))));
        }
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
    required this.runningBalanceCents,
    this.payeeName,
    this.envelopeName,
    this.onToggleCleared,
  });

  final Transaction transaction;
  final CurrencyCode currencyCode;
  final int runningBalanceCents;
  final String? payeeName;
  final String? envelopeName;
  final VoidCallback? onToggleCleared;

  String get _detailLine {
    final parts = <String>[];
    if (payeeName != null && payeeName!.isNotEmpty) parts.add(payeeName!);
    if (envelopeName != null && envelopeName!.isNotEmpty) {
      parts.add(envelopeName!);
    }
    return parts.join(' \u2022 ');
  }

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
                  if (_detailLine.isNotEmpty)
                    Text(
                      _detailLine,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCents(transaction.amountCents, currencyCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isInflow ? ColorTokens.secondary : colorScheme.error,
                  ),
                ),
                Text(
                  formatCents(runningBalanceCents, currencyCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: runningBalanceCents >= 0
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.error,
                  ),
                ),
              ],
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

class _ReconcileDialog extends HookWidget {
  const _ReconcileDialog({
    required this.clearedBalanceCents,
    required this.currencyCode,
  });

  final int clearedBalanceCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = useTextEditingController();
    final enteredCents = useState<int?>(null);

    final differenceCents = enteredCents.value != null
        ? enteredCents.value! - clearedBalanceCents
        : null;

    return AlertDialog(
      title: Text(l10n.reconcileTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reconcileClearedBalance,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                formatCents(clearedBalanceCents, currencyCode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.reconcileBalanceLabel,
              hintText: l10n.reconcileBalanceHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              enteredCents.value = parsed != null
                  ? (parsed * 100).round()
                  : null;
            },
          ),
          if (differenceCents != null) ...[
            const SizedBox(height: SpacingTokens.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.reconcileDifference,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  formatCents(differenceCents, currencyCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: differenceCents != 0
                        ? colorScheme.error
                        : ColorTokens.secondary,
                  ),
                ),
              ],
            ),
            if (differenceCents != 0) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                l10n.reconcileAdjustmentNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: enteredCents.value != null
              ? () => Navigator.of(context).pop(enteredCents.value)
              : null,
          child: Text(l10n.reconcileButton),
        ),
      ],
    );
  }
}
