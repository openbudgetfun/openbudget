import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/solana_wallet_provider.dart';
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
    final loanMonthlyTargetCents = useState<int?>(null);

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
    final isSolanaWalletAccount = accountData?.accountType == 'cryptoWallet';
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
                        _showLinkAccountUnavailable(context);
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
                      enabled: false,
                      child: Text('Link Account (Unavailable)'),
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
                monthlyTargetCents: loanMonthlyTargetCents.value,
                onMonthlyTargetChanged: (cents) {
                  loanMonthlyTargetCents.value = cents;
                },
                selectedTab: loanDetailTab.value,
                onTabChanged: (tab) => loanDetailTab.value = tab,
              ),
            )
          : isSolanaWalletAccount
          ? _SolanaWalletAccountBody(
              budgetId: budgetId,
              accountId: accountId,
              account: accountData,
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

  void _showLinkAccountUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bank connections are currently unavailable in this build. '
          'Use unlinked accounts instead.',
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
    required this.monthlyTargetCents,
    required this.onMonthlyTargetChanged,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final Account accountData;
  final List<Transaction> transactions;
  final CurrencyCode currencyCode;
  final int? monthlyTargetCents;
  final ValueChanged<int> onMonthlyTargetChanged;
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
    final monthlyPaymentBaseline =
        monthlyTargetCents ??
        (paidThisMonthCents > 0 ? paidThisMonthCents : 35000);
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
                              onPressed: () async {
                                final newTarget = await _showLoanTargetDialog(
                                  context,
                                  currencyCode: currencyCode,
                                  monthlyTargetCents: monthlyTargetCents,
                                );
                                if (newTarget == null) return;
                                onMonthlyTargetChanged(newTarget);
                              },
                              child: Text(
                                monthlyTargetCents == null
                                    ? 'Create Target'
                                    : 'Edit Target',
                              ),
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

class _SolanaWalletAccountBody extends HookConsumerWidget {
  const _SolanaWalletAccountBody({
    required this.budgetId,
    required this.accountId,
    required this.account,
  });

  final String budgetId;
  final String accountId;
  final Account? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSyncing = useState(false);
    final hideDustAssets = useState(true);
    final transactionSearchController = useTextEditingController();
    final showNeedsCategoryOnly = useState(false);

    useListenable(transactionSearchController);

    if (account == null) {
      return const Center(child: Text('Account not found.'));
    }

    final walletAsync = ref.watch(
      accountSolanaWalletProvider(budgetId, accountId),
    );
    return walletAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Failed to load wallet metadata.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
      data: (wallet) {
        if (wallet == null || wallet.id == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Text(
                'No Solana wallet is attached to this account yet.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final walletId = wallet.id!.toString();
        final holdingsAsync = ref.watch(
          solanaWalletHoldingsProvider(budgetId, walletId),
        );
        final transactionsAsync = ref.watch(
          solanaWalletTransactionsProvider(budgetId, walletId),
        );
        final taxYearSummariesAsync = ref.watch(
          solanaWalletTaxYearSummariesProvider(budgetId, walletId),
        );
        final snapshot = _SolanaWalletSnapshot.from(
          holdings: holdingsAsync.asData?.value ?? const [],
          transactions: transactionsAsync.asData?.value ?? const [],
        );

        Future<void> runSync() async {
          if (isSyncing.value) return;
          isSyncing.value = true;
          final messenger = ScaffoldMessenger.of(context);
          try {
            final result = await ref
                .read(solanaWalletActionsProvider.notifier)
                .syncWallet(budgetId: budgetId, walletId: walletId);
            if (!context.mounted) return;
            final coveredHoldings =
                result.pricedHoldingCount + result.staleHoldingCount;
            final coveragePercent = result.valuationCoverageRatio == null
                ? null
                : (result.valuationCoverageRatio! * 100).round();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Synced ${result.insertedTransactions + result.updatedTransactions}'
                  ' transactions and ${result.holdingCount} holdings. '
                  'Coverage $coveredHoldings/${result.holdingCount}'
                  '${coveragePercent == null ? '' : ' ($coveragePercent%)'}, '
                  '${result.unpricedHoldingCount} unpriced.',
                ),
              ),
            );
          } on Exception catch (_) {
            if (!context.mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Wallet sync failed. Check server logs.'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } finally {
            if (context.mounted) {
              isSyncing.value = false;
            }
          }
        }

        final statusLabel = _toLabel(wallet.syncStatus);
        final statusColor = _statusColor(wallet.syncStatus, colorScheme);

        return RefreshIndicator(
          onRefresh: runSync,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.tertiaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(RadiusTokens.lg),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SpacingTokens.sm),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withAlpha(200),
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.md,
                              ),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.label ?? account!.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.xs),
                                Text(
                                  _shortAddress(wallet.address),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: isSyncing.value ? null : runSync,
                            icon: isSyncing.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded),
                            label: Text(isSyncing.value ? 'Syncing' : 'Sync'),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Wrap(
                        spacing: SpacingTokens.xs,
                        runSpacing: SpacingTokens.xs,
                        children: [
                          _MetadataChip(
                            icon: Icons.hub_outlined,
                            label: _toLabel(wallet.cluster),
                          ),
                          _MetadataChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: statusLabel,
                            color: statusColor.withAlpha(35),
                            foregroundColor: statusColor,
                          ),
                          if (wallet.lastSyncedAt != null)
                            _MetadataChip(
                              icon: Icons.schedule_rounded,
                              label: DateFormat.yMMMd().add_jm().format(
                                wallet.lastSyncedAt!,
                              ),
                            ),
                          _MetadataChip(
                            icon: Icons.account_tree_outlined,
                            label: '${snapshot.transactions} tx',
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Value',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.xs),
                                Text(
                                  _formatUsd(snapshot.totalValueUsd),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: wallet.address),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Wallet address copied.'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = SpacingTokens.sm;
                  final isWide = constraints.maxWidth >= 700;
                  if (isWide) {
                    final cardWidth = (constraints.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Fungible Assets',
                            value: snapshot.fungibleAssets.toString(),
                            icon: Icons.scatter_plot_outlined,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'NFT Assets',
                            value: snapshot.nftAssets.toString(),
                            icon: Icons.image_outlined,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Valuation Coverage',
                            value: _formatCoverage(snapshot),
                            icon: Icons.verified_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Unpriced Assets',
                            value: snapshot.unpricedHoldings.toString(),
                            icon: Icons.warning_amber_rounded,
                            valueColor: snapshot.unpricedHoldings > 0
                                ? colorScheme.error
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Unrealized P&L',
                            value: _formatSignedUsd(
                              snapshot.totalUnrealizedPnl,
                            ),
                            valueColor: _pnlColor(
                              snapshot.totalUnrealizedPnl,
                              colorScheme,
                            ),
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Realized P&L',
                            value: _formatSignedUsd(snapshot.totalRealizedPnl),
                            valueColor: _pnlColor(
                              snapshot.totalRealizedPnl,
                              colorScheme,
                            ),
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Tagged Transactions',
                            value: snapshot.taggedTransactions.toString(),
                            icon: Icons.label_outline_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _WalletMetricCard(
                            label: 'Last Activity',
                            value: snapshot.lastActivity == null
                                ? 'No activity'
                                : DateFormat.yMMMd().format(
                                    snapshot.lastActivity!,
                                  ),
                            icon: Icons.history_rounded,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _WalletMetricCard(
                        label: 'Fungible Assets',
                        value: snapshot.fungibleAssets.toString(),
                        icon: Icons.scatter_plot_outlined,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'NFT Assets',
                        value: snapshot.nftAssets.toString(),
                        icon: Icons.image_outlined,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Valuation Coverage',
                        value: _formatCoverage(snapshot),
                        icon: Icons.verified_rounded,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Unpriced Assets',
                        value: snapshot.unpricedHoldings.toString(),
                        icon: Icons.warning_amber_rounded,
                        valueColor: snapshot.unpricedHoldings > 0
                            ? colorScheme.error
                            : null,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Unrealized P&L',
                        value: _formatSignedUsd(snapshot.totalUnrealizedPnl),
                        valueColor: _pnlColor(
                          snapshot.totalUnrealizedPnl,
                          colorScheme,
                        ),
                        icon: Icons.trending_up_rounded,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Realized P&L',
                        value: _formatSignedUsd(snapshot.totalRealizedPnl),
                        valueColor: _pnlColor(
                          snapshot.totalRealizedPnl,
                          colorScheme,
                        ),
                        icon: Icons.analytics_outlined,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Tagged Transactions',
                        value: snapshot.taggedTransactions.toString(),
                        icon: Icons.label_outline_rounded,
                      ),
                      const SizedBox(height: gap),
                      _WalletMetricCard(
                        label: 'Last Activity',
                        value: snapshot.lastActivity == null
                            ? 'No activity'
                            : DateFormat.yMMMd().format(snapshot.lastActivity!),
                        icon: Icons.history_rounded,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Text(
                    'Tax Year P&L',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    '(estimated)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              taxYearSummariesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(SpacingTokens.sm),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (error, _) => Text(
                  'Could not load tax-year summary.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
                data: (summaries) {
                  if (summaries.isEmpty) {
                    return const _EmptyStateCard(
                      title: 'No disposals yet',
                      subtitle:
                          'Tax-year summaries will appear after taxable disposal activity is detected.',
                      icon: Icons.calculate_outlined,
                    );
                  }
                  return Column(
                    children: [
                      for (final summary in summaries.take(3))
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: _TaxYearSummaryCard(summary: summary),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Text(
                    'Holdings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    '(${snapshot.holdings})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Token balances with current valuation and detected programs.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: hideDustAssets.value,
                  onSelected: (value) => hideDustAssets.value = value,
                  label: const Text(r'Hide dust assets (< $0.01)'),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              holdingsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(SpacingTokens.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(
                  'Failed to load holdings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (holdings) {
                  if (holdings.isEmpty) {
                    return const _EmptyStateCard(
                      title: 'No holdings found',
                      subtitle:
                          'Run a sync to fetch tokens and NFTs for this wallet.',
                      icon: Icons.inventory_2_outlined,
                    );
                  }
                  final sortedHoldings = [...holdings]
                    ..sort(
                      (a, b) =>
                          (b.totalValue ?? 0).compareTo(a.totalValue ?? 0),
                    );
                  final visibleHoldings = hideDustAssets.value
                      ? sortedHoldings
                            .where(
                              (holding) =>
                                  holding.isNft ||
                                  holding.totalValue == null ||
                                  holding.totalValue! >= 0.01,
                            )
                            .toList(growable: false)
                      : sortedHoldings;
                  if (visibleHoldings.isEmpty) {
                    return const _EmptyStateCard(
                      title: 'Only dust assets found',
                      subtitle:
                          'Turn off the dust filter to inspect very small-value token balances.',
                      icon: Icons.tune_rounded,
                    );
                  }
                  return Column(
                    children: [
                      for (final holding in visibleHoldings)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: _HoldingCard(holding: holding),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: [
                  Text(
                    'Transaction History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    '(${snapshot.transactions})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                'Parsed activity with program context and editable labels.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                controller: transactionSearchController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search description, category, tags, memo',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: showNeedsCategoryOnly.value,
                  onSelected: (value) => showNeedsCategoryOnly.value = value,
                  label: const Text('Needs category'),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              transactionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(SpacingTokens.md),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Text(
                  'Failed to load transactions.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const _EmptyStateCard(
                      title: 'No transactions yet',
                      subtitle:
                          'Run a sync to import transaction history from the wallet.',
                      icon: Icons.receipt_long_outlined,
                    );
                  }
                  final sortedTransactions = [...transactions]
                    ..sort((a, b) {
                      final aTime =
                          a.occurredAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      final bTime =
                          b.occurredAt ??
                          DateTime.fromMillisecondsSinceEpoch(0);
                      return bTime.compareTo(aTime);
                    });
                  final query = transactionSearchController.text
                      .trim()
                      .toLowerCase();
                  final visibleTransactions = sortedTransactions
                      .where((tx) {
                        if (showNeedsCategoryOnly.value &&
                            (tx.category?.trim().isNotEmpty ?? false)) {
                          return false;
                        }

                        if (query.isEmpty) return true;
                        final haystack = [
                          tx.description,
                          tx.txType,
                          tx.source,
                          tx.category ?? '',
                          _suggestedCategoryForWalletTransaction(tx) ?? '',
                          tx.tagsCsv ?? '',
                          tx.memo ?? '',
                        ].join(' ').toLowerCase();
                        return haystack.contains(query);
                      })
                      .toList(growable: false);
                  if (visibleTransactions.isEmpty) {
                    return const _EmptyStateCard(
                      title: 'No transactions match filters',
                      subtitle:
                          'Adjust search terms or disable the category filter.',
                      icon: Icons.filter_alt_off_rounded,
                    );
                  }
                  return Column(
                    children: [
                      for (final tx in visibleTransactions)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: _TransactionCard(
                            transaction: tx,
                            onEdit: () => _editTransactionMetadata(
                              context,
                              ref,
                              budgetId: budgetId,
                              walletId: walletId,
                              transaction: tx,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editTransactionMetadata(
    BuildContext context,
    WidgetRef ref, {
    required String budgetId,
    required String walletId,
    required SolanaWalletTransaction transaction,
  }) async {
    if (transaction.id == null) return;
    final suggestedCategory = _suggestedCategoryForWalletTransaction(
      transaction,
    );
    final existingCategory = transaction.category?.trim();
    final categoryController = TextEditingController(
      text: existingCategory == null || existingCategory.isEmpty
          ? (suggestedCategory ?? '')
          : existingCategory,
    );
    final tagsController = TextEditingController(text: transaction.tagsCsv);
    final memoController = TextEditingController(text: transaction.memo);

    final didSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Transaction Metadata'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              if (suggestedCategory != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Suggested: $suggestedCategory',
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                controller: memoController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Memo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (didSave != true) return;

    try {
      await ref
          .read(solanaWalletActionsProvider.notifier)
          .updateTransactionMetadata(
            budgetId: budgetId,
            transactionId: transaction.id!.toString(),
            walletId: walletId,
            category: _emptyToNull(categoryController.text),
            tagsCsv: _emptyToNull(tagsController.text),
            memo: _emptyToNull(memoController.text),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction metadata updated.')),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not update transaction metadata.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      categoryController.dispose();
      tagsController.dispose();
      memoController.dispose();
    }
  }

  static String? _emptyToNull(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static String _shortAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  static String _toLabel(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 'Unknown';
    return normalized
        .split(RegExp(r'[_\s]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String _formatUsd(double amount) {
    if (amount == 0) return r'$0.00';
    final decimals = amount.abs() >= 1000 ? 0 : 2;
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: decimals,
    ).format(amount);
  }

  static String _formatCoverage(_SolanaWalletSnapshot snapshot) {
    final ratio = snapshot.valuationCoverageRatio;
    if (snapshot.holdings == 0 || ratio == null) {
      return 'No holdings';
    }
    final covered = snapshot.pricedHoldings + snapshot.stalePricedHoldings;
    final percent = (ratio * 100).round();
    return '$percent% ($covered/${snapshot.holdings})';
  }

  static Color _statusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'success':
        return OpenBudgetPalette.progressGreen;
      case 'error':
        return colorScheme.error;
      case 'pending':
        return colorScheme.tertiary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

class _SolanaWalletSnapshot {
  const _SolanaWalletSnapshot({
    required this.totalValueUsd,
    required this.totalUnrealizedPnl,
    required this.totalRealizedPnl,
    required this.holdings,
    required this.pricedHoldings,
    required this.stalePricedHoldings,
    required this.unpricedHoldings,
    required this.valuationCoverageRatio,
    required this.fungibleAssets,
    required this.nftAssets,
    required this.transactions,
    required this.taggedTransactions,
    required this.lastActivity,
  });

  factory _SolanaWalletSnapshot.from({
    required List<SolanaWalletHolding> holdings,
    required List<SolanaWalletTransaction> transactions,
  }) {
    final totalValueUsd = holdings.fold<double>(
      0,
      (total, holding) => total + (holding.totalValue ?? 0),
    );
    final totalUnrealizedPnl = holdings.fold<double>(
      0,
      (total, holding) => total + (holding.estimatedUnrealizedPnl ?? 0),
    );
    final totalRealizedPnl = transactions.fold<double>(
      0,
      (total, transaction) => total + (transaction.estimatedRealizedPnl ?? 0),
    );
    final pricedHoldings = holdings.where((holding) {
      if (holding.totalValue == null) return false;
      return !(holding.isPriceStale ?? false);
    }).length;
    final stalePricedHoldings = holdings.where((holding) {
      if (holding.totalValue == null) return false;
      return holding.isPriceStale ?? false;
    }).length;
    final unpricedHoldings =
        holdings.length - pricedHoldings - stalePricedHoldings;
    final valuationCoverageRatio = holdings.isEmpty
        ? null
        : (pricedHoldings + stalePricedHoldings) / holdings.length;
    final nftAssets = holdings.where((holding) => holding.isNft).length;
    final fungibleAssets = holdings.length - nftAssets;
    final taggedTransactions = transactions.where((transaction) {
      final hasCategory = transaction.category?.trim().isNotEmpty ?? false;
      final hasTags = transaction.tagsCsv?.trim().isNotEmpty ?? false;
      return hasCategory || hasTags;
    }).length;
    DateTime? lastActivity;
    for (final transaction in transactions) {
      final occurredAt = transaction.occurredAt;
      if (occurredAt == null) continue;
      if (lastActivity == null || occurredAt.isAfter(lastActivity)) {
        lastActivity = occurredAt;
      }
    }
    return _SolanaWalletSnapshot(
      totalValueUsd: totalValueUsd,
      totalUnrealizedPnl: totalUnrealizedPnl,
      totalRealizedPnl: totalRealizedPnl,
      holdings: holdings.length,
      pricedHoldings: pricedHoldings,
      stalePricedHoldings: stalePricedHoldings,
      unpricedHoldings: unpricedHoldings,
      valuationCoverageRatio: valuationCoverageRatio,
      fungibleAssets: fungibleAssets,
      nftAssets: nftAssets,
      transactions: transactions.length,
      taggedTransactions: taggedTransactions,
      lastActivity: lastActivity,
    );
  }

  final double totalValueUsd;
  final double totalUnrealizedPnl;
  final double totalRealizedPnl;
  final int holdings;
  final int pricedHoldings;
  final int stalePricedHoldings;
  final int unpricedHoldings;
  final double? valuationCoverageRatio;
  final int fungibleAssets;
  final int nftAssets;
  final int transactions;
  final int taggedTransactions;
  final DateTime? lastActivity;
}

class _WalletMetricCard extends StatelessWidget {
  const _WalletMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: OpenBudgetPalette.surfaceFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.dividerFor(theme)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxYearSummaryCard extends StatelessWidget {
  const _TaxYearSummaryCard({required this.summary});

  final SolanaWalletTaxYearSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pnlColor = _pnlColor(summary.estimatedRealizedPnl, colorScheme);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax ${summary.taxYear}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    '${summary.transactionCount} taxable tx',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                  _formatSignedUsd(summary.estimatedRealizedPnl),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: pnlColor,
                  ),
                ),
                Text(
                  'Proceeds ${NumberFormat.currency(symbol: r'$').format(summary.estimatedProceeds)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Basis ${NumberFormat.currency(symbol: r'$').format(summary.estimatedCostBasis)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.holding});

  final SolanaWalletHolding holding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = holding.symbol ?? holding.name ?? holding.assetId;
    final valueText = holding.totalValue == null
        ? '-'
        : NumberFormat.currency(
            locale: 'en_US',
            symbol: r'$',
            decimalDigits: holding.totalValue!.abs() >= 1000 ? 0 : 2,
          ).format(holding.totalValue);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Icon(
                holding.isNft ? Icons.image_outlined : Icons.token_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    '${holding.balanceUi} units',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Wrap(
                    spacing: SpacingTokens.xs,
                    runSpacing: SpacingTokens.xs,
                    children: [
                      if (holding.isNft)
                        const _MetadataChip(
                          icon: Icons.image_outlined,
                          label: 'NFT',
                        ),
                      _MetadataChip(
                        icon: Icons.account_tree_outlined,
                        label: _programLabel(holding.tokenProgram),
                      ),
                      if (holding.priceSource != null &&
                          holding.priceSource!.trim().isNotEmpty)
                        _MetadataChip(
                          icon: Icons.price_change_outlined,
                          label: _SolanaWalletAccountBody._toLabel(
                            holding.priceSource!,
                          ),
                        ),
                      if (holding.priceQuality != null &&
                          holding.priceQuality!.trim().isNotEmpty)
                        _MetadataChip(
                          icon: Icons.verified_outlined,
                          label: _SolanaWalletAccountBody._toLabel(
                            holding.priceQuality!,
                          ),
                        ),
                      if (holding.isPriceStale ?? false)
                        const _MetadataChip(
                          icon: Icons.schedule_rounded,
                          label: 'Stale price',
                        ),
                      if (holding.totalValue == null)
                        _MetadataChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Unpriced',
                          color: colorScheme.errorContainer.withAlpha(153),
                          foregroundColor: colorScheme.onErrorContainer,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valueText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (holding.totalValue == null)
                  Text(
                    'No valuation source',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                if (holding.estimatedCostBasis != null)
                  Text(
                    'Basis ${NumberFormat.currency(symbol: r'$').format(holding.estimatedCostBasis)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (holding.estimatedUnrealizedPnl != null)
                  Text(
                    'P&L ${_formatSignedUsd(holding.estimatedUnrealizedPnl!)}'
                    '${holding.estimatedUnrealizedPnlPercent == null ? '' : ' (${holding.estimatedUnrealizedPnlPercent!.toStringAsFixed(1)}%)'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _pnlColor(
                        holding.estimatedUnrealizedPnl!,
                        colorScheme,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (holding.pricePerToken != null)
                  Text(
                    '@ ${NumberFormat.currency(symbol: r'$').format(holding.pricePerToken)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onEdit});

  final SolanaWalletTransaction transaction;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tags = _parseTags(transaction.tagsCsv);
    final programs = _parsePrograms(
      transaction.programsJson,
    ).map(_programLabel).toSet().toList();
    final suggestedCategory = _suggestedCategoryForWalletTransaction(
      transaction,
    );
    final hasCategory = transaction.category?.trim().isNotEmpty ?? false;
    final confidence = transaction.interpretationConfidence?.trim();
    final occurredText = transaction.occurredAt == null
        ? null
        : DateFormat.yMMMd().add_jm().format(transaction.occurredAt!);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  child: Icon(
                    _transactionIcon(transaction.txType),
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (occurredText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: SpacingTokens.xs),
                          child: Text(
                            occurredText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded),
                  tooltip: 'Edit metadata',
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Wrap(
              spacing: SpacingTokens.xs,
              runSpacing: SpacingTokens.xs,
              children: [
                _MetadataChip(
                  icon: Icons.category_outlined,
                  label: _SolanaWalletAccountBody._toLabel(transaction.txType),
                ),
                _MetadataChip(
                  icon: Icons.hub_outlined,
                  label: _SolanaWalletAccountBody._toLabel(transaction.source),
                ),
                if (confidence != null && confidence.isNotEmpty)
                  _MetadataChip(
                    icon: Icons.psychology_alt_outlined,
                    label:
                        '${_SolanaWalletAccountBody._toLabel(confidence)} confidence',
                  ),
                for (final program in programs.take(4))
                  _MetadataChip(icon: Icons.extension_outlined, label: program),
                if (hasCategory)
                  _MetadataChip(
                    icon: Icons.folder_open_rounded,
                    label: transaction.category!.trim(),
                  ),
                if (!hasCategory && suggestedCategory != null)
                  _MetadataChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Suggested: $suggestedCategory',
                    color: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                if (transaction.estimatedRealizedPnl != null)
                  _MetadataChip(
                    icon: Icons.query_stats_rounded,
                    label:
                        'P&L ${_formatSignedUsd(transaction.estimatedRealizedPnl!)}',
                    color: transaction.estimatedRealizedPnl! >= 0
                        ? OpenBudgetPalette.progressGreen.withAlpha(40)
                        : colorScheme.errorContainer,
                    foregroundColor: transaction.estimatedRealizedPnl! >= 0
                        ? OpenBudgetPalette.progressGreen
                        : colorScheme.onErrorContainer,
                  ),
                if (transaction.taxYear != null)
                  _MetadataChip(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tax ${transaction.taxYear}',
                  ),
                for (final tag in tags.take(4))
                  _MetadataChip(icon: Icons.tag_rounded, label: tag),
              ],
            ),
            if (transaction.memo?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                transaction.memo!.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _transactionIcon(String txType) {
    final normalized = txType.toLowerCase();
    if (normalized.contains('swap')) return Icons.swap_horiz_rounded;
    if (normalized.contains('nft')) return Icons.image_outlined;
    if (normalized.contains('stake')) return Icons.lock_clock_rounded;
    if (normalized.contains('transfer')) return Icons.compare_arrows_rounded;
    return Icons.receipt_long_outlined;
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    this.color,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        color ?? theme.colorScheme.surfaceContainerHighest.withAlpha(180);
    final textColor = foregroundColor ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            Icon(icon, size: 28, color: colorScheme.outline),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _programLabel(String? id) {
  if (id == null || id.trim().isEmpty) {
    return 'Unknown program';
  }
  final value = id.trim();
  if (value.startsWith('TokenkegQfe')) return 'SPL Token';
  if (value.startsWith('TokenzQd')) return 'Token-2022';
  if (value == '11111111111111111111111111111111') return 'System Program';
  if (value.startsWith('AToken')) return 'Associated Token';
  if (value.toLowerCase().contains('jupiter') || value.startsWith('JUP')) {
    return 'Jupiter';
  }
  if (value.toLowerCase().contains('pump')) return 'Pump.fun';
  if (value.length <= 12) return value;
  return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
}

List<String> _parsePrograms(String? programsJson) {
  if (programsJson == null || programsJson.trim().isEmpty) {
    return const [];
  }
  try {
    final decoded = jsonDecode(programsJson);
    if (decoded is List) {
      return decoded.whereType<String>().toList(growable: false);
    }
  } on FormatException {
    return const [];
  }
  return const [];
}

List<String> _parseTags(String? tagsCsv) {
  if (tagsCsv == null || tagsCsv.trim().isEmpty) {
    return const [];
  }
  return tagsCsv
      .split(',')
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);
}

String _formatSignedUsd(double amount) {
  final decimals = amount.abs() >= 1000 ? 0 : 2;
  final value = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: decimals,
  ).format(amount.abs());
  if (amount > 0) return '+$value';
  if (amount < 0) return '-$value';
  return value;
}

Color _pnlColor(double amount, ColorScheme colorScheme) {
  if (amount > 0) return OpenBudgetPalette.progressGreen;
  if (amount < 0) return colorScheme.error;
  return colorScheme.onSurface;
}

String? _suggestedCategoryForWalletTransaction(SolanaWalletTransaction tx) {
  final type = tx.txType.toLowerCase();
  final source = tx.source.toLowerCase();
  final programs = _parsePrograms(
    tx.programsJson,
  ).map((program) => program.toLowerCase());

  bool containsSignal(String signal) {
    return type.contains(signal) ||
        source.contains(signal) ||
        programs.any((program) => program.contains(signal));
  }

  if (containsSignal('swap') ||
      containsSignal('jupiter') ||
      containsSignal('raydium') ||
      containsSignal('whirlpool') ||
      containsSignal('orca') ||
      containsSignal('pump')) {
    return 'Swaps';
  }
  if (containsSignal('stake')) return 'Staking';
  if (containsSignal('nft') ||
      containsSignal('magiceden') ||
      containsSignal('tensor') ||
      containsSignal('metaplex')) {
    return 'NFT';
  }
  if (containsSignal('lend') ||
      containsSignal('borrow') ||
      containsSignal('margin')) {
    return 'Lending';
  }
  if (containsSignal('airdrop') || containsSignal('claim')) return 'Income';
  if (containsSignal('transfer') || containsSignal('system_program')) {
    return 'Transfers';
  }
  return null;
}

int _pow10Int(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

Future<int?> _showLoanTargetDialog(
  BuildContext context, {
  required CurrencyCode currencyCode,
  required int? monthlyTargetCents,
}) async {
  final factor = _pow10Int(currencyCode.decimals);
  final controller = TextEditingController(
    text: monthlyTargetCents == null
        ? ''
        : (monthlyTargetCents / factor).toStringAsFixed(currencyCode.decimals),
  );

  return showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Loan Target'),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Monthly payment',
          prefixText: '${currencyCode.symbol} ',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(controller.text.trim());
            if (value == null || value <= 0) return;
            Navigator.of(dialogContext).pop((value * factor).round());
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
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
