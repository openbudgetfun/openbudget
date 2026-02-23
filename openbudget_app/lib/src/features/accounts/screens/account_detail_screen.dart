import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _StatusFilter { all, uncleared }

enum _AccountMenuAction { reconcile, hideReconciled, editAccount, linkAccount }

enum _LoanDetailTab { overview, activity }

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

    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final statusFilter = useState(_StatusFilter.all);
    final hideReconciled = useState(false);
    final loanDetailTab = useState(_LoanDetailTab.overview);

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
    final isLoanAccount =
        accountData != null && _isLoanStyleAccount(accountData);
    final unclearedCount = txnAsync.whenOrNull(
      data: (txns) => txns.where((t) => !t.cleared && !t.reconciled).length,
    );

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(
            accountListRoute,
            pathParameters: {'id': budgetId},
          ),
        ),
        title: Column(
          children: [
            Text(
              accountData?.name ?? l10n.accountListTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (accountData != null)
              Text(
                accountData.onBudget ? 'Budget Account' : 'Tracking Account',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpenBudgetPalette.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: isLoanAccount
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openEditAccount(context, accountData),
                ),
              ]
            : [
                TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    foregroundColor: OpenBudgetPalette.accentBlue,
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Select'),
                ),
                PopupMenuButton<_AccountMenuAction>(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (action) {
                    switch (action) {
                      case _AccountMenuAction.reconcile:
                        if (txnAsync.hasValue) {
                          _reconcile(
                            context,
                            ref,
                            txnAsync.value!,
                            currencyCode,
                          );
                        }
                      case _AccountMenuAction.hideReconciled:
                        hideReconciled.value = !hideReconciled.value;
                      case _AccountMenuAction.editAccount:
                        if (accountData != null) {
                          _openEditAccount(context, accountData);
                        }
                      case _AccountMenuAction.linkAccount:
                        _showLinkAccountComingSoon(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.reconcile,
                      enabled: txnAsync.hasValue,
                      child: Text(l10n.reconcileButton),
                    ),
                    CheckedPopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.hideReconciled,
                      checked: hideReconciled.value,
                      child: const Text('Hide Reconciled'),
                    ),
                    PopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.editAccount,
                      enabled: accountData != null,
                      child: Text(l10n.accountEditTitle),
                    ),
                    const PopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.linkAccount,
                      child: Text('Link Account'),
                    ),
                  ],
                ),
              ],
      ),
      body: isLoanAccount
          ? txnAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text(
                  l10n.transactionLoadError,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
              data: (transactions) => _LoanAccountDetailBody(
                accountData: accountData,
                transactions: transactions,
                currencyCode: currencyCode,
                selectedTab: loanDetailTab.value,
                onTabChanged: (tab) => loanDetailTab.value = tab,
              ),
            )
          : Column(
              children: [
                if (accountData != null)
                  _BalanceHeader(
                    accountData: accountData,
                    currencyCode: currencyCode,
                    transactions: txnAsync.whenOrNull(data: (txns) => txns),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.sm,
                    SpacingTokens.md,
                    SpacingTokens.xs,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.accountDetailSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onChanged: (value) => searchQuery.value = value,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Material(
                        color: OpenBudgetPalette.surface,
                        borderRadius: BorderRadius.circular(RadiusTokens.md),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.md,
                            ),
                            side: const BorderSide(
                              color: OpenBudgetPalette.divider,
                            ),
                          ),
                          title: Text(
                            'Show ${unclearedCount ?? 0} '
                            '${l10n.accountFilterUncleared.toLowerCase()} '
                            'transactions',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => statusFilter.value =
                              statusFilter.value == _StatusFilter.uncleared
                              ? _StatusFilter.all
                              : _StatusFilter.uncleared,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: txnAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
                      final summaryAsync = ref.watch(
                        budgetSummaryProvider(budgetId),
                      );
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
                                  (t.memo?.toLowerCase().contains(query) ??
                                      false) ||
                                  (payeeMap[t.payeeId?.toString()]
                                          ?.toLowerCase()
                                          .contains(query) ??
                                      false) ||
                                  (envelopeMap[t.envelopeId?.toString()]
                                          ?.toLowerCase()
                                          .contains(query) ??
                                      false),
                            )
                            .toList();
                      }

                      if (hideReconciled.value) {
                        filtered = filtered
                            .where((t) => !t.reconciled)
                            .toList();
                      }

                      filtered = switch (statusFilter.value) {
                        _StatusFilter.all => filtered,
                        _StatusFilter.uncleared =>
                          filtered
                              .where((t) => !t.cleared && !t.reconciled)
                              .toList(),
                      };

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            searchQuery.value.isNotEmpty
                                ? l10n.transactionNoResults
                                : l10n.transactionEmpty,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: OpenBudgetPalette.mutedText,
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
                        balanceMap[transactions[i].id?.toString() ?? '$i'] =
                            balance;
                        balance -= transactions[i].amountCents;
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(
                            accountTransactionsProvider(budgetId, accountId),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            SpacingTokens.md,
                            SpacingTokens.xs,
                            SpacingTokens.md,
                            SpacingTokens.lg,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final txn = filtered[index];
                            final prevTxn = index > 0
                                ? filtered[index - 1]
                                : null;
                            final showDateHeader =
                                prevTxn == null ||
                                !_isSameDay(
                                  prevTxn.transactionDate,
                                  txn.transactionDate,
                                );
                            final runningBalance =
                                balanceMap[txn.id?.toString() ?? '$index'] ?? 0;
                            final payeeName = txn.payeeId != null
                                ? payeeMap[txn.payeeId.toString()]
                                : null;
                            final envelopeName = txn.envelopeId != null
                                ? envelopeMap[txn.envelopeId.toString()]
                                : null;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : SpacingTokens.md,
                                      bottom: SpacingTokens.xs,
                                    ),
                                    child: Text(
                                      _formatDayHeader(txn.transactionDate),
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: OpenBudgetPalette.mutedText,
                                          ),
                                    ),
                                  ),
                                _TransactionRow(
                                  transaction: txn,
                                  currencyCode: currencyCode,
                                  runningBalanceCents: runningBalance,
                                  payeeName: payeeName,
                                  envelopeName: envelopeName,
                                  onToggleCleared: txn.reconciled
                                      ? null
                                      : () => _toggleCleared(context, ref, txn),
                                ),
                              ],
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

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatDayHeader(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  static bool _isLoanStyleAccount(Account account) {
    final name = account.name.toLowerCase();
    return !account.isClosed &&
        !account.onBudget &&
        (account.accountType == 'other' || name.contains('loan')) &&
        account.balanceCents <= 0;
  }

  void _openEditAccount(BuildContext context, Account account) {
    showDialog<void>(
      context: context,
      builder: (_) => EditAccountDialog(
        account: account,
        budgetId: budgetId,
        onDeleted: () =>
            context.goNamed(accountListRoute, pathParameters: {'id': budgetId}),
      ),
    );
  }

  void _showLinkAccountComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bank linking for OpenBudget is coming soon. '
          'Use unlinked accounts for now.',
        ),
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

    final useClearedBalance = await showDialog<bool>(
      context: context,
      builder: (_) => _ReconcileMatchDialog(
        clearedBalanceCents: clearedBalanceCents,
        currencyCode: currencyCode,
      ),
    );

    if (useClearedBalance == null || !context.mounted) return;

    if (useClearedBalance) {
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
      return;
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

class _BalanceHeader extends HookWidget {
  const _BalanceHeader({
    required this.accountData,
    required this.currencyCode,
    this.transactions,
  });

  final Account accountData;
  final CurrencyCode currencyCode;
  final List<Transaction>? transactions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    var clearedCents = 0;
    var unclearedCents = 0;
    if (transactions != null) {
      for (final txn in transactions!) {
        if (txn.reconciled || txn.cleared) {
          clearedCents += txn.amountCents;
        } else {
          unclearedCents += txn.amountCents;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xs,
      ),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: OpenBudgetPalette.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.divider),
      ),
      child: Column(
        children: [
          Text(
            l10n.accountDetailBalance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            formatCents(accountData.balanceCents, currencyCode),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: accountData.balanceCents >= 0
                  ? OpenBudgetPalette.progressGreen
                  : OpenBudgetPalette.negative,
            ),
          ),
          if (transactions != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BalanceChip(
                  icon: Icons.check_circle_outline,
                  label: l10n.accountBalanceCleared,
                  amount: formatCents(clearedCents, currencyCode),
                  color: OpenBudgetPalette.progressGreen,
                ),
                const SizedBox(width: SpacingTokens.lg),
                _BalanceChip(
                  icon: Icons.circle_outlined,
                  label: l10n.accountBalanceUncleared,
                  amount: formatCents(unclearedCents, currencyCode),
                  color: OpenBudgetPalette.mutedText,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceChip extends HookWidget {
  const _BalanceChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
    final isInflow = transaction.amountCents > 0;

    final statusIcon = transaction.reconciled
        ? Icons.lock_outline_rounded
        : transaction.cleared
        ? Icons.check_circle_outline
        : Icons.circle_outlined;
    final statusColor = transaction.reconciled
        ? OpenBudgetPalette.accentBlue
        : transaction.cleared
        ? OpenBudgetPalette.progressGreen
        : OpenBudgetPalette.mutedText;

    return InkWell(
      onTap: onToggleCleared,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: Ink(
        decoration: BoxDecoration(
          color: OpenBudgetPalette.surface,
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          border: Border.all(color: OpenBudgetPalette.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          child: Row(
            children: [
              Icon(statusIcon, size: 18, color: statusColor),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_detailLine.isNotEmpty)
                      Text(
                        _detailLine,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: OpenBudgetPalette.mutedText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (transaction.memo != null &&
                        transaction.memo!.trim().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: OpenBudgetPalette.surfaceMuted,
                          borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        ),
                        child: Text(
                          transaction.memo!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: OpenBudgetPalette.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCents(transaction.amountCents, currencyCode),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isInflow
                          ? OpenBudgetPalette.progressGreen
                          : OpenBudgetPalette.negative,
                    ),
                  ),
                  Text(
                    formatCents(runningBalanceCents, currencyCode),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: runningBalanceCents >= 0
                          ? OpenBudgetPalette.mutedText
                          : OpenBudgetPalette.negative,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoanAccountDetailBody extends StatelessWidget {
  const _LoanAccountDetailBody({
    required this.accountData,
    required this.transactions,
    required this.currencyCode,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final Account accountData;
  final List<Transaction> transactions;
  final CurrencyCode currencyCode;
  final _LoanDetailTab selectedTab;
  final ValueChanged<_LoanDetailTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);

    final sortedTransactions = [...transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final monthTransactions = sortedTransactions
        .where(
          (txn) =>
              !txn.transactionDate.isBefore(monthStart) &&
              txn.transactionDate.isBefore(monthEnd),
        )
        .toList();

    final paidThisMonthCents = monthTransactions
        .where((txn) => txn.amountCents > 0)
        .fold<int>(0, (sum, txn) => sum + txn.amountCents);
    final chargedThisMonthCents = monthTransactions
        .where((txn) => txn.amountCents < 0)
        .fold<int>(0, (sum, txn) => sum + txn.amountCents);
    final totalBorrowedCents = sortedTransactions
        .where((txn) => txn.amountCents < 0)
        .fold<int>(0, (sum, txn) => sum + (-txn.amountCents));
    final currentDebtCents = accountData.balanceCents < 0
        ? -accountData.balanceCents
        : 0;
    final paidOffRatio = totalBorrowedCents <= 0
        ? (currentDebtCents == 0 ? 1.0 : 0.0)
        : ((totalBorrowedCents - currentDebtCents) / totalBorrowedCents).clamp(
            0.0,
            1.0,
          );
    final paidOffPercent = (paidOffRatio * 100).toStringAsFixed(1);
    final monthlyPaymentBaseline = paidThisMonthCents > 0
        ? paidThisMonthCents
        : 35000;
    final monthsToPayoff = currentDebtCents == 0
        ? 0
        : (currentDebtCents / monthlyPaymentBaseline).ceil();
    final debtFreeDate = DateTime(now.year, now.month + monthsToPayoff);

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: OpenBudgetPalette.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _LoanTabButton(
                  label: 'Overview',
                  selected: selectedTab == _LoanDetailTab.overview,
                  onTap: () => onTabChanged(_LoanDetailTab.overview),
                ),
              ),
              Expanded(
                child: _LoanTabButton(
                  label: 'Activity',
                  selected: selectedTab == _LoanDetailTab.activity,
                  onTap: () => onTabChanged(_LoanDetailTab.activity),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.lg,
            ),
            children: selectedTab == _LoanDetailTab.overview
                ? [
                    _LoanSummaryGrid(
                      entries: [
                        _LoanSummaryEntry(
                          label: 'Balance',
                          value: formatCents(
                            accountData.balanceCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          positive: accountData.balanceCents >= 0,
                        ),
                        _LoanSummaryEntry(
                          label: 'Paid',
                          value: formatCents(paidThisMonthCents, currencyCode),
                          emphasized: true,
                          positive: true,
                        ),
                        _LoanSummaryEntry(
                          label: DateFormat.MMMM().format(now),
                          value: formatCents(
                            chargedThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: false,
                          positive: chargedThisMonthCents >= 0,
                        ),
                        _LoanSummaryEntry(
                          label: 'Total Borrowed',
                          value: formatCents(-totalBorrowedCents, currencyCode),
                          emphasized: false,
                          positive: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Center(
                      child: SizedBox(
                        width: 144,
                        height: 144,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: paidOffRatio,
                                strokeWidth: 10,
                                color: OpenBudgetPalette.accentBlue,
                                backgroundColor: OpenBudgetPalette.surfaceMuted,
                              ),
                            ),
                            Text(
                              '$paidOffPercent%\nPaid Off',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    const _LoanSectionTitle(title: 'Loan Payoff Overview'),
                    _LoanCard(
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(SpacingTokens.md),
                              decoration: BoxDecoration(
                                color: OpenBudgetPalette.surfaceMuted,
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.md,
                                ),
                              ),
                              child: Text(
                                "You'll pay off your loan in "
                                '${monthsToPayoff == 1 ? '1 month' : '$monthsToPayoff months'} '
                                'if you pay the minimum every month.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            _LoanDetailRow(
                              label: 'Monthly Target',
                              value: formatCents(
                                monthlyPaymentBaseline,
                                currencyCode,
                              ),
                            ),
                            const Divider(height: 1),
                            const _LoanDetailRow(
                              label: 'Due Every',
                              value: 'Monthly',
                            ),
                            const Divider(height: 1),
                            _LoanDetailRow(
                              label: 'Debt Free Date',
                              value: DateFormat.yMMM().format(debtFreeDate),
                              emphasize: true,
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            FilledButton(
                              onPressed: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Loan target editing is coming soon to OpenBudget.',
                                      ),
                                    ),
                                  ),
                              child: const Text('Create Target'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    const _LoanSectionTitle(title: 'Loan Details'),
                    _LoanCard(
                      child: Column(
                        children: [
                          const _LoanDetailRow(
                            label: 'Interest Rate',
                            value: '3%',
                          ),
                          const Divider(height: 1),
                          _LoanDetailRow(
                            label: 'Monthly Minimum',
                            value: formatCents(
                              monthlyPaymentBaseline,
                              currencyCode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                : [
                    _LoanSummaryGrid(
                      entries: [
                        _LoanSummaryEntry(
                          label: 'Balance',
                          value: formatCents(
                            accountData.balanceCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          positive: accountData.balanceCents >= 0,
                        ),
                        _LoanSummaryEntry(
                          label: 'Paid',
                          value: formatCents(paidThisMonthCents, currencyCode),
                          emphasized: true,
                          positive: true,
                        ),
                        _LoanSummaryEntry(
                          label: 'In ${DateFormat.MMMM().format(now)}',
                          value: formatCents(
                            chargedThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          positive: chargedThisMonthCents >= 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _LoanActivityList(
                      transactions: sortedTransactions,
                      currencyCode: currencyCode,
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

class _LoanTabButton extends StatelessWidget {
  const _LoanTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? OpenBudgetPalette.accentBlue
        : OpenBudgetPalette.mutedText;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? OpenBudgetPalette.accentBlue
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LoanSectionTitle extends StatelessWidget {
  const _LoanSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: SpacingTokens.sm,
        left: SpacingTokens.xs,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.divider),
      ),
      child: child,
    );
  }
}

class _LoanDetailRow extends StatelessWidget {
  const _LoanDetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _LoanSummaryEntry {
  const _LoanSummaryEntry({
    required this.label,
    required this.value,
    required this.emphasized,
    required this.positive,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool positive;
}

class _LoanSummaryGrid extends StatelessWidget {
  const _LoanSummaryGrid({required this.entries});

  final List<_LoanSummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _LoanCard(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Wrap(
          spacing: SpacingTokens.md,
          runSpacing: SpacingTokens.md,
          children: entries
              .map(
                (entry) => SizedBox(
                  width:
                      (MediaQuery.sizeOf(context).width -
                          (SpacingTokens.md * 4)) /
                      2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: OpenBudgetPalette.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: entry.emphasized
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: entry.positive
                              ? OpenBudgetPalette.progressGreen
                              : OpenBudgetPalette.negative,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LoanActivityList extends StatelessWidget {
  const _LoanActivityList({
    required this.transactions,
    required this.currencyCode,
  });

  final List<Transaction> transactions;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Text(
            'No loan activity yet',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: OpenBudgetPalette.mutedText),
          ),
        ),
      );
    }

    final grouped = <String, List<Transaction>>{};
    for (final txn in transactions) {
      final key = DateFormat.yMMMM().format(txn.transactionDate);
      grouped.putIfAbsent(key, () => []).add(txn);
    }
    final orderedKeys = grouped.keys.toList()
      ..sort(
        (a, b) =>
            DateFormat.yMMMM().parse(b).compareTo(DateFormat.yMMMM().parse(a)),
      );

    return _LoanCard(
      child: Column(
        children: [
          for (final key in orderedKeys) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.sm,
              ),
              color: OpenBudgetPalette.surfaceMuted,
              child: Text(
                key,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final txn in grouped[key]!) ...[
              _LoanActivityRow(transaction: txn, currencyCode: currencyCode),
              if (txn != grouped[key]!.last) const Divider(height: 1),
            ],
            if (key != orderedKeys.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _LoanActivityRow extends StatelessWidget {
  const _LoanActivityRow({
    required this.transaction,
    required this.currencyCode,
  });

  final Transaction transaction;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final isPayment = transaction.amountCents > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  isPayment ? 'Payments' : 'Other Activity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OpenBudgetPalette.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatCents(transaction.amountCents, currencyCode),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isPayment
                  ? OpenBudgetPalette.progressGreen
                  : OpenBudgetPalette.negative,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
                  ? (parsed * _pow10(currencyCode.decimals)).round()
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

  double _pow10(int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}

class _ReconcileMatchDialog extends HookWidget {
  const _ReconcileMatchDialog({
    required this.clearedBalanceCents,
    required this.currencyCode,
  });

  final int clearedBalanceCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Your cleared balance in OpenBudget is '
        '${formatCents(clearedBalanceCents, currencyCode)}',
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Does this match your bank balance?',
        style: theme.textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
