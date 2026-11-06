import 'dart:async';
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
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
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
    final palette = theme.ob;
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
    final currencyCode = accountData?.currencyCode ?? '';
    final isLoanAccount =
        accountData != null && _isLoanStyleAccount(accountData);
    final isSolanaWalletAccount = accountData?.accountType == 'cryptoWallet';
    final unclearedCount = txnAsync.whenOrNull(
      data: (txns) => txns.where((t) => !t.cleared && !t.reconciled).length,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
          tooltip: l10n.accountsBackAction,
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
                color: palette.ink,
              ),
            ),
            if (accountData != null)
              Text(
                accountData.onBudget
                    ? l10n.accountDetailBudgetAccount
                    : l10n.accountDetailTrackingAccount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: isLoanAccount
            ? [
                IconButton(
                  icon: const SkribbleIcon(data: OpenBudgetIcons.edit),
                  tooltip: l10n.accountEditTitle,
                  onPressed: () => _openEditAccount(context, accountData),
                ),
              ]
            : [
                TextButton(
                  onPressed: null,
                  child: Text(l10n.accountDetailSelect),
                ),
                PopupMenuButton<_AccountMenuAction>(
                  icon: const SkribbleIcon(data: OpenBudgetIcons.more),
                  tooltip: l10n.accountsMoreActions,
                  onSelected: (action) {
                    switch (action) {
                      case _AccountMenuAction.reconcile:
                        if (txnAsync.hasValue) {
                          unawaited(
                            _reconcile(
                              context,
                              ref,
                              txnAsync.value!,
                              currencyCode,
                            ),
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
                      child: Text(l10n.accountDetailHideReconciled),
                    ),
                    PopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.editAccount,
                      enabled: accountData != null,
                      child: Text(l10n.accountEditTitle),
                    ),
                    PopupMenuItem<_AccountMenuAction>(
                      value: _AccountMenuAction.linkAccount,
                      enabled: false,
                      child: Text(l10n.accountDetailLinkAccountUnavailable),
                    ),
                  ],
                ),
              ],
      ),
      body: isLoanAccount
          ? txnAsync.when(
              loading: () => Center(
                child: ObLoadingPanel(label: l10n.loadingTitle),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: ObStatePanel.problem(
                    title: l10n.transactionLoadError,
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
                          prefixIcon: const SkribbleIcon(
                            data: OpenBudgetIcons.search,
                          ),
                        ),
                        onChanged: (value) => searchQuery.value = value,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      ObCard(
                        child: ListTile(
                          title: Text(
                            l10n.accountsShowUnclearedTransactions(
                              unclearedCount ?? 0,
                            ),
                          ),
                          trailing: const SkribbleIcon(
                            data: OpenBudgetIcons.chevronRight,
                            size: 20,
                          ),
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
                    loading: () => Center(
                      child: ObLoadingPanel(label: l10n.loadingTitle),
                    ),
                    error: (error, _) => Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(SpacingTokens.lg),
                        child: ObStatePanel.problem(
                          title: l10n.transactionLoadError,
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
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(SpacingTokens.lg),
                            child: ObStatePanel.empty(
                              title: searchQuery.value.isNotEmpty
                                  ? l10n.transactionNoResults
                                  : l10n.transactionEmpty,
                              doodle: searchQuery.value.isNotEmpty
                                  ? WiredDoodleKind.cloud
                                  : WiredDoodleKind.sun,
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
                                            color: palette.mutedInk,
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

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatDayHeader(DateTime date) =>
      DateFormat.yMMMMd().format(date);

  static bool _isLoanStyleAccount(Account account) {
    final name = account.name.toLowerCase();
    return !account.isClosed &&
        !account.onBudget &&
        (account.accountType == 'other' || name.contains('loan')) &&
        account.balanceCents <= 0;
  }

  void _openEditAccount(BuildContext context, Account account) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => EditAccountDialog(
          account: account,
          budgetId: budgetId,
          onDeleted: () => context.goNamed(
            accountListRoute,
            pathParameters: {'id': budgetId},
          ),
        ),
      ),
    );
  }

  void _showLinkAccountUnavailable(BuildContext context) {
    showAppToast(
      context,
      message: AppLocalizations.of(context).accountsLinkUnavailableMessage,
      variant: AppToastVariant.warning,
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
        showAppToast(
          context,
          message: l10n.transactionEditError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _reconcile(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    String currencyCode,
  ) async {
    final l10n = AppLocalizations.of(context);

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
          showAppToast(
            context,
            message: l10n.reconcileSuccess(count),
            variant: AppToastVariant.success,
          );
        }
      } on Exception catch (_) {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.reconcileError,
            variant: AppToastVariant.error,
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
          showAppToast(
            context,
            message: l10n.reconcileSuccessWithAdjustment(
              count,
              formatCentsForCode(adjustment, currencyCode),
            ),
            variant: AppToastVariant.success,
          );
        } else {
          showAppToast(
            context,
            message: l10n.reconcileSuccess(count),
            variant: AppToastVariant.success,
          );
        }
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.reconcileError,
          variant: AppToastVariant.error,
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
  final String currencyCode;
  final List<Transaction>? transactions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

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

    return ObCard(
      margin: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xs,
      ),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          Text(
            l10n.accountDetailBalance,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          ObAmount(
            formatCentsForCode(accountData.balanceCents, currencyCode),
            tone: accountData.balanceCents >= 0
                ? ObTone.funded
                : ObTone.overspent,
            style: theme.textTheme.headlineLarge,
          ),
          if (transactions != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: SpacingTokens.md,
              runSpacing: SpacingTokens.xs,
              children: [
                _BalanceStat(
                  icon: OpenBudgetIcons.checkCircle,
                  label: l10n.accountBalanceCleared,
                  amount: formatCentsForCode(clearedCents, currencyCode),
                  tone: ObTone.funded,
                ),
                _BalanceStat(
                  icon: OpenBudgetIcons.circle,
                  label: l10n.accountBalanceUncleared,
                  amount: formatCentsForCode(unclearedCents, currencyCode),
                  tone: ObTone.neutral,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceStat extends HookWidget {
  const _BalanceStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.tone,
  });

  final WiredSvgIconData icon;
  final String label;
  final String amount;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: 6,
      ),
      decoration: ObRoughDecoration(
        color: palette.wash(tone),
        outline: palette.quietPen,
        radius: RadiusTokens.sm,
        seed: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkribbleIcon(data: icon, size: 16, color: palette.hue(tone)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ObAmount(
                amount,
                tone: tone,
                style: theme.textTheme.bodySmall,
              ),
            ],
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
  final String currencyCode;
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
    final palette = theme.ob;
    final isInflow = transaction.amountCents > 0;

    final statusIcon = transaction.reconciled
        ? OpenBudgetIcons.lock
        : transaction.cleared
        ? OpenBudgetIcons.checkCircle
        : OpenBudgetIcons.circle;
    final statusTone = transaction.reconciled
        ? ObTone.brand
        : transaction.cleared
        ? ObTone.funded
        : ObTone.neutral;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      onTap: onToggleCleared,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          SkribbleIcon(
            data: statusIcon,
            size: 18,
            color: palette.hue(statusTone),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_detailLine.isNotEmpty)
                  Text(
                    _detailLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (transaction.memo != null &&
                    transaction.memo!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm,
                        vertical: 2,
                      ),
                      decoration: ObRoughDecoration(
                        color: palette.highlight,
                        outline: palette.quietPen,
                        radius: RadiusTokens.sm,
                        seed: 31,
                      ),
                      child: Text(
                        transaction.memo!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: palette.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ObAmount(
                formatCentsForCode(transaction.amountCents, currencyCode),
                tone: isInflow ? ObTone.funded : ObTone.overspent,
                style: theme.textTheme.titleMedium,
              ),
              ObAmount(
                formatCentsForCode(runningBalanceCents, currencyCode),
                tone: runningBalanceCents >= 0
                    ? ObTone.neutral
                    : ObTone.overspent,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoanAccountDetailBody extends HookWidget {
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
  final String currencyCode;
  final int? monthlyTargetCents;
  final ValueChanged<int> onMonthlyTargetChanged;
  final _LoanDetailTab selectedTab;
  final ValueChanged<_LoanDetailTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xs,
          ),
          child: SegmentedButton<_LoanDetailTab>(
            segments: [
              ButtonSegment(
                value: _LoanDetailTab.overview,
                label: Text(l10n.accountDetailLoanOverview),
              ),
              ButtonSegment(
                value: _LoanDetailTab.activity,
                label: Text(l10n.accountDetailLoanActivity),
              ),
            ],
            selected: {selectedTab},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => onTabChanged(selection.first),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.lg,
            ),
            children: selectedTab == _LoanDetailTab.overview
                ? [
                    _LoanSummaryGrid(
                      entries: [
                        _LoanSummaryEntry(
                          label: l10n.accountDetailLoanBalance,
                          value: formatCentsForCode(
                            accountData.balanceCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          tone: accountData.balanceCents >= 0
                              ? ObTone.funded
                              : ObTone.overspent,
                        ),
                        _LoanSummaryEntry(
                          label: l10n.accountDetailLoanPaid,
                          value: formatCentsForCode(
                            paidThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          tone: ObTone.funded,
                        ),
                        _LoanSummaryEntry(
                          label: DateFormat.MMMM().format(now),
                          value: formatCentsForCode(
                            chargedThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: false,
                          tone: chargedThisMonthCents >= 0
                              ? ObTone.funded
                              : ObTone.overspent,
                        ),
                        _LoanSummaryEntry(
                          label: l10n.accountDetailLoanTotalBorrowed,
                          value: formatCentsForCode(
                            -totalBorrowedCents,
                            currencyCode,
                          ),
                          emphasized: false,
                          tone: ObTone.overspent,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Center(
                      child: SizedBox(
                        width: 156,
                        height: 156,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 132,
                              height: 132,
                              child: CircularProgressIndicator(
                                value: paidOffRatio,
                                strokeWidth: 10,
                                color: palette.hue(ObTone.brand),
                                backgroundColor: palette.highlight,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(SpacingTokens.lg),
                              child: Text(
                                l10n.accountDetailLoanPaidOff(paidOffPercent),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: palette.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    ObSectionHeader(
                      title: l10n.accountDetailLoanPayoffOverview,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    ),
                    ObCard(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SpacingTokens.md),
                            decoration: ObRoughDecoration(
                              color: palette.highlight,
                              outline: palette.quietPen,
                              seed: 53,
                            ),
                            child: Text(
                              l10n.accountDetailLoanPayoffEstimate(
                                monthsToPayoff == 1
                                    ? l10n.accountDetailLoanOneMonth
                                    : l10n.accountDetailLoanManyMonths(
                                        monthsToPayoff,
                                      ),
                              ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: palette.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          _LoanDetailRow(
                            label: l10n.accountDetailLoanMonthlyTarget,
                            value: formatCentsForCode(
                              monthlyPaymentBaseline,
                              currencyCode,
                            ),
                          ),
                          const Divider(height: 1),
                          _LoanDetailRow(
                            label: l10n.accountDetailLoanDueEvery,
                            value: l10n.accountDetailLoanMonthly,
                          ),
                          const Divider(height: 1),
                          _LoanDetailRow(
                            label: l10n.accountDetailLoanDebtFreeDate,
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
                                  ? l10n.accountDetailLoanCreateTarget
                                  : l10n.accountDetailLoanEditTarget,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    ObSectionHeader(
                      title: l10n.accountDetailLoanDetails,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    ),
                    ObCard(
                      child: Column(
                        children: [
                          _LoanDetailRow(
                            label: l10n.accountDetailLoanInterestRate,
                            value: l10n.accountDetailLoanInterestRateValue,
                          ),
                          const Divider(height: 1),
                          _LoanDetailRow(
                            label: l10n.accountDetailLoanMonthlyMinimum,
                            value: formatCentsForCode(
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
                          label: l10n.accountDetailLoanBalance,
                          value: formatCentsForCode(
                            accountData.balanceCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          tone: accountData.balanceCents >= 0
                              ? ObTone.funded
                              : ObTone.overspent,
                        ),
                        _LoanSummaryEntry(
                          label: l10n.accountDetailLoanPaid,
                          value: formatCentsForCode(
                            paidThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          tone: ObTone.funded,
                        ),
                        _LoanSummaryEntry(
                          label: l10n.accountDetailLoanInMonth(
                            DateFormat.MMMM().format(now),
                          ),
                          value: formatCentsForCode(
                            chargedThisMonthCents,
                            currencyCode,
                          ),
                          emphasized: true,
                          tone: chargedThisMonthCents >= 0
                              ? ObTone.funded
                              : ObTone.overspent,
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

class _LoanDetailRow extends HookWidget {
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
    final theme = Theme.of(context);
    final palette = theme.ob;
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: palette.ink,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: palette.ink,
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
    required this.tone,
  });

  final String label;
  final String value;
  final bool emphasized;
  final ObTone tone;
}

class _LoanSummaryGrid extends HookWidget {
  const _LoanSummaryGrid({required this.entries});

  final List<_LoanSummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Wrap(
        spacing: SpacingTokens.md,
        runSpacing: SpacingTokens.md,
        children: entries
            .map(
              (entry) => SizedBox(
                width:
                    (MediaQuery.sizeOf(context).width -
                        (SpacingTokens.md * 4) -
                        SpacingTokens.md) /
                    2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ObAmount(
                      entry.value,
                      tone: entry.tone,
                      style: entry.emphasized
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LoanActivityList extends HookWidget {
  const _LoanActivityList({
    required this.transactions,
    required this.currencyCode,
  });

  final List<Transaction> transactions;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    if (transactions.isEmpty) {
      return ObStatePanel.empty(
        title: l10n.accountsNoLoanActivity,
        doodle: WiredDoodleKind.balloon,
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

    return ObCard(
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
              color: palette.highlight,
              child: Text(
                key,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
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

class _LoanActivityRow extends HookWidget {
  const _LoanActivityRow({
    required this.transaction,
    required this.currencyCode,
  });

  final Transaction transaction;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final isPayment = transaction.amountCents > 0;
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
                Text(
                  isPayment
                      ? l10n.accountsLoanPayments
                      : l10n.accountsLoanOtherActivity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          ObAmount(
            formatCentsForCode(transaction.amountCents, currencyCode),
            tone: isPayment ? ObTone.funded : ObTone.overspent,
            style: theme.textTheme.titleMedium,
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final isSyncing = useState(false);
    final hideDustAssets = useState(true);
    final transactionSearchController = useTextEditingController();
    final showNeedsCategoryOnly = useState(false);

    useListenable(transactionSearchController);

    if (account == null) {
      return Center(
        child: ObStatePanel.problem(title: l10n.accountDetailNotFound),
      );
    }

    final walletAsync = ref.watch(
      accountSolanaWalletProvider(budgetId, accountId),
    );
    return walletAsync.when(
      loading: () => Center(
        child: ObLoadingPanel(label: l10n.loadingTitle),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.accountDetailWalletLoadError,
          ),
        ),
      ),
      data: (wallet) {
        if (wallet == null || wallet.id == null) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: ObStatePanel.empty(
                title: l10n.accountDetailWalletNotAttached,
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
            final coveredNfts =
                result.pricedNftHoldingCount + result.staleNftHoldingCount;
            showAppToast(
              context,
              message: l10n.accountDetailWalletSyncSummary(
                result.insertedTransactions + result.updatedTransactions,
                result.holdingCount,
                coveredHoldings,
                coveragePercent == null ? '' : ' ($coveragePercent%)',
                result.unpricedHoldingCount,
                coveredNfts,
                result.nftHoldingCount,
                result.unpricedNftHoldingCount,
                result.holdingCount,
              ),
              variant: AppToastVariant.success,
            );
          } on Exception catch (_) {
            if (!context.mounted) return;
            showAppToast(
              context,
              message: l10n.accountDetailWalletSyncFailed,
              variant: AppToastVariant.error,
            );
          } finally {
            if (context.mounted) {
              isSyncing.value = false;
            }
          }
        }

        final statusLabel = _toLabel(wallet.syncStatus, l10n);
        final statusTone = _statusTone(wallet.syncStatus);
        final metrics = <_WalletMetricData>[
          _WalletMetricData(
            label: l10n.accountDetailWalletFungibleAssets,
            value: snapshot.fungibleAssets.toString(),
            icon: OpenBudgetIcons.coins,
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletNftAssets,
            value: snapshot.nftAssets.toString(),
            icon: OpenBudgetIcons.image,
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletValuationCoverage,
            value: _formatCoverage(snapshot, l10n),
            icon: OpenBudgetIcons.verified,
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletUnpricedAssets,
            value: snapshot.unpricedHoldings.toString(),
            icon: OpenBudgetIcons.warning,
            tone: snapshot.unpricedHoldings > 0
                ? ObTone.overspent
                : ObTone.neutral,
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletUnrealizedPnl,
            value: _formatSignedUsd(snapshot.totalUnrealizedPnl),
            icon: OpenBudgetIcons.trendingUp,
            tone: _pnlTone(snapshot.totalUnrealizedPnl),
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletRealizedPnl,
            value: _formatSignedUsd(snapshot.totalRealizedPnl),
            icon: OpenBudgetIcons.barChart,
            tone: _pnlTone(snapshot.totalRealizedPnl),
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletTaggedTransactions,
            value: snapshot.taggedTransactions.toString(),
            icon: OpenBudgetIcons.label,
          ),
          _WalletMetricData(
            label: l10n.accountDetailWalletLastActivity,
            value: snapshot.lastActivity == null
                ? l10n.accountDetailWalletNoActivity
                : DateFormat.yMMMd().format(snapshot.lastActivity!),
            icon: OpenBudgetIcons.history,
          ),
        ];

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
              ObCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: ObRoughDecoration(
                            color: palette.wash(ObTone.brand),
                            outline: palette.quietPen,
                            seed: 17,
                          ),
                          child: SkribbleIcon(
                            data: OpenBudgetIcons.wallet,
                            color: palette.hue(ObTone.brand),
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
                                  color: palette.ink,
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.xs),
                              Text(
                                _shortAddress(wallet.address),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.mutedInk,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.xs),
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
                              : const SkribbleIcon(
                                  data: OpenBudgetIcons.sync,
                                  size: 18,
                                ),
                          label: Text(
                            isSyncing.value
                                ? l10n.accountDetailWalletSyncing
                                : l10n.accountDetailWalletSync,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Wrap(
                      spacing: SpacingTokens.xs,
                      runSpacing: SpacingTokens.xs,
                      children: [
                        _MetadataChip(
                          icon: OpenBudgetIcons.network,
                          label: _toLabel(wallet.cluster, l10n),
                        ),
                        _MetadataChip(
                          icon: OpenBudgetIcons.verified,
                          label: statusLabel,
                          tone: statusTone,
                        ),
                        if (wallet.lastSyncedAt != null)
                          _MetadataChip(
                            icon: OpenBudgetIcons.schedule,
                            label: DateFormat.yMMMd().add_jm().format(
                              wallet.lastSyncedAt!,
                            ),
                          ),
                        _MetadataChip(
                          icon: OpenBudgetIcons.tree,
                          label: l10n.accountDetailWalletTxCount(
                            snapshot.transactions,
                          ),
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
                                l10n.accountDetailWalletEstimatedValue,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.mutedInk,
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.xs),
                              ObAmount(
                                _formatUsd(snapshot.totalValueUsd),
                                style: theme.textTheme.headlineSmall,
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
                              showAppToast(
                                context,
                                message: l10n.accountDetailWalletAddressCopied,
                                variant: AppToastVariant.success,
                              );
                            }
                          },
                          icon: const SkribbleIcon(
                            data: OpenBudgetIcons.copy,
                            size: 18,
                          ),
                          label: Text(l10n.accountDetailWalletCopy),
                        ),
                      ],
                    ),
                  ],
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
                        for (final metric in metrics)
                          SizedBox(
                            width: cardWidth,
                            child: _WalletMetricCard(metric: metric),
                          ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      for (final (index, metric) in metrics.indexed) ...[
                        if (index > 0) const SizedBox(height: gap),
                        _WalletMetricCard(metric: metric),
                      ],
                    ],
                  );
                },
              ),
              ObSectionHeader(
                title: l10n.accountDetailWalletTaxYearPnl,
                subtitle: l10n.accountDetailWalletEstimated,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              taxYearSummariesAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  child: ObLoadingPanel(
                    label: l10n.accountDetailWalletTaxYearPnl,
                  ),
                ),
                error: (error, _) => Text(
                  l10n.accountDetailWalletTaxYearLoadError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.hue(ObTone.overspent),
                  ),
                ),
                data: (summaries) {
                  if (summaries.isEmpty) {
                    return ObStatePanel.empty(
                      title: l10n.accountDetailWalletNoDisposalsYet,
                      message: l10n.accountDetailWalletNoDisposalsHint,
                      doodle: WiredDoodleKind.sun,
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
              ObSectionHeader(
                title: l10n.accountDetailWalletHoldings,
                subtitle: l10n.accountDetailWalletHoldingsHint,
                trailing: Text(
                  '(${snapshot.holdings})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: hideDustAssets.value,
                  onSelected: (value) => hideDustAssets.value = value,
                  label: Text(l10n.accountDetailWalletHideDustAssets),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              holdingsAsync.when(
                loading: () => ObLoadingPanel(
                  label: l10n.accountDetailWalletHoldings,
                ),
                error: (error, _) => Text(
                  l10n.accountDetailWalletHoldingsLoadError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.hue(ObTone.overspent),
                  ),
                ),
                data: (holdings) {
                  if (holdings.isEmpty) {
                    return ObStatePanel.empty(
                      title: l10n.accountDetailWalletNoHoldingsFound,
                      message: l10n.accountDetailWalletNoHoldingsHint,
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
                    return ObStatePanel.empty(
                      title: l10n.accountDetailWalletOnlyDustAssets,
                      message: l10n.accountDetailWalletOnlyDustAssetsHint,
                      doodle: WiredDoodleKind.leaf,
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
              ObSectionHeader(
                title: l10n.accountDetailWalletTransactionHistory,
                subtitle: l10n.accountDetailWalletTransactionHistoryHint,
                trailing: Text(
                  '(${snapshot.transactions})',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              TextField(
                controller: transactionSearchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.accountDetailWalletTransactionSearchHint,
                  prefixIcon: const SkribbleIcon(
                    data: OpenBudgetIcons.search,
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  selected: showNeedsCategoryOnly.value,
                  onSelected: (value) => showNeedsCategoryOnly.value = value,
                  label: Text(l10n.accountDetailWalletNeedsCategory),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              transactionsAsync.when(
                loading: () => ObLoadingPanel(
                  label: l10n.accountDetailWalletTransactionHistory,
                ),
                error: (error, _) => Text(
                  l10n.accountDetailWalletTransactionsLoadError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.hue(ObTone.overspent),
                  ),
                ),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return ObStatePanel.empty(
                      title: l10n.accountDetailWalletNoTransactionsYet,
                      message: l10n.accountDetailWalletNoTransactionsHint,
                      doodle: WiredDoodleKind.balloon,
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
                          _suggestedCategoryForWalletTransaction(tx, l10n) ??
                              '',
                          tx.tagsCsv ?? '',
                          tx.memo ?? '',
                        ].join(' ').toLowerCase();
                        return haystack.contains(query);
                      })
                      .toList(growable: false);
                  if (visibleTransactions.isEmpty) {
                    return ObStatePanel.empty(
                      title: l10n.accountDetailWalletNoTransactionsMatch,
                      message: l10n.accountDetailWalletNoTransactionsMatchHint,
                      doodle: WiredDoodleKind.cloud,
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
    final l10n = AppLocalizations.of(context);
    if (transaction.id == null) return;
    final suggestedCategory = _suggestedCategoryForWalletTransaction(
      transaction,
      l10n,
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
        title: Text(l10n.accountDetailWalletEditMetadataTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: l10n.transactionCategoryLabel,
                ),
              ),
              if (suggestedCategory != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.accountDetailWalletSuggestedCategory(
                      suggestedCategory,
                    ),
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: l10n.accountDetailWalletTagsCommaSeparated,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              TextField(
                controller: memoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.transactionMemoLabel,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.dialogSave),
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
        showAppToast(
          context,
          message: l10n.accountDetailWalletMetadataUpdated,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.accountDetailWalletMetadataUpdateError,
          variant: AppToastVariant.error,
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

  static String _toLabel(String value, AppLocalizations l10n) {
    final normalized = value.trim();
    if (normalized.isEmpty) return l10n.accountsUnknown;
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

  static String _formatCoverage(
    _SolanaWalletSnapshot snapshot,
    AppLocalizations l10n,
  ) {
    final ratio = snapshot.valuationCoverageRatio;
    if (snapshot.holdings == 0 || ratio == null) {
      return l10n.accountsNoHoldings;
    }
    final covered = snapshot.pricedHoldings + snapshot.stalePricedHoldings;
    final percent = (ratio * 100).round();
    return '$percent% ($covered/${snapshot.holdings})';
  }

  static ObTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return ObTone.funded;
      case 'error':
        return ObTone.overspent;
      case 'pending':
        return ObTone.underfunded;
      default:
        return ObTone.neutral;
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

class _WalletMetricData {
  const _WalletMetricData({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = ObTone.neutral,
  });

  final String label;
  final String value;
  final WiredSvgIconData icon;
  final ObTone tone;
}

class _WalletMetricCard extends HookWidget {
  const _WalletMetricCard({required this.metric});

  final _WalletMetricData metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SkribbleIcon(
            data: metric.icon,
            size: 20,
            color: palette.hue(ObTone.brand),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                ObAmount(
                  metric.value,
                  tone: metric.tone,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxYearSummaryCard extends HookWidget {
  const _TaxYearSummaryCard({required this.summary});

  final SolanaWalletTaxYearSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final pnlTone = _pnlTone(summary.estimatedRealizedPnl);
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ObRoughDecoration(
              color: palette.wash(ObTone.brand),
              outline: palette.quietPen,
              radius: RadiusTokens.sm,
              seed: 61,
            ),
            child: SkribbleIcon(
              data: OpenBudgetIcons.calendar,
              size: 18,
              color: palette.hue(ObTone.brand),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountsTaxYear(summary.taxYear),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.accountsTaxableTransactions(summary.transactionCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ObAmount(
                _formatSignedUsd(summary.estimatedRealizedPnl),
                tone: pnlTone,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                l10n.accountsProceeds(
                  NumberFormat.currency(
                    symbol: r'$',
                  ).format(summary.estimatedProceeds),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
              Text(
                l10n.accountsBasis(
                  NumberFormat.currency(
                    symbol: r'$',
                  ).format(summary.estimatedCostBasis),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HoldingCard extends HookWidget {
  const _HoldingCard({required this.holding});

  final SolanaWalletHolding holding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final title = holding.symbol ?? holding.name ?? holding.assetId;
    final valueText = holding.totalValue == null
        ? '-'
        : NumberFormat.currency(
            locale: 'en_US',
            symbol: r'$',
            decimalDigits: holding.totalValue!.abs() >= 1000 ? 0 : 2,
          ).format(holding.totalValue);

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ObRoughDecoration(
              color: palette.highlight,
              outline: palette.quietPen,
              radius: RadiusTokens.sm,
              seed: 71,
            ),
            child: SkribbleIcon(
              data: holding.isNft
                  ? OpenBudgetIcons.image
                  : OpenBudgetIcons.coins,
              color: palette.hue(ObTone.brand),
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
                    color: palette.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.accountDetailWalletUnits(holding.balanceUi),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Wrap(
                  spacing: SpacingTokens.xs,
                  runSpacing: SpacingTokens.xs,
                  children: [
                    if (holding.isNft)
                      _MetadataChip(
                        icon: OpenBudgetIcons.image,
                        label: l10n.accountDetailWalletNft,
                      ),
                    _MetadataChip(
                      icon: OpenBudgetIcons.tree,
                      label: _programLabel(holding.tokenProgram, l10n),
                    ),
                    if (holding.priceSource != null &&
                        holding.priceSource!.trim().isNotEmpty)
                      _MetadataChip(
                        icon: OpenBudgetIcons.priceChange,
                        label: _SolanaWalletAccountBody._toLabel(
                          holding.priceSource!,
                          l10n,
                        ),
                      ),
                    if (holding.priceQuality != null &&
                        holding.priceQuality!.trim().isNotEmpty)
                      _MetadataChip(
                        icon: OpenBudgetIcons.verified,
                        label: _SolanaWalletAccountBody._toLabel(
                          holding.priceQuality!,
                          l10n,
                        ),
                      ),
                    if (holding.priceConfidence != null &&
                        holding.priceConfidence!.trim().isNotEmpty)
                      _MetadataChip(
                        icon: OpenBudgetIcons.speed,
                        label: l10n.accountDetailWalletConfidence(
                          _SolanaWalletAccountBody._toLabel(
                            holding.priceConfidence!,
                            l10n,
                          ),
                        ),
                      ),
                    if (holding.isPriceStale ?? false)
                      _MetadataChip(
                        icon: OpenBudgetIcons.schedule,
                        label: l10n.accountDetailWalletStalePrice,
                        tone: ObTone.underfunded,
                      ),
                    if (holding.totalValue == null)
                      _MetadataChip(
                        icon: OpenBudgetIcons.warning,
                        label: l10n.accountDetailWalletUnpriced,
                        tone: ObTone.overspent,
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
              ObAmount(valueText, style: theme.textTheme.titleSmall),
              if (holding.totalValue == null)
                Text(
                  l10n.accountDetailWalletNoValuationSource,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.hue(ObTone.overspent),
                  ),
                ),
              if (holding.estimatedCostBasis != null)
                Text(
                  l10n.accountDetailWalletBasis(
                    NumberFormat.currency(
                      symbol: r'$',
                    ).format(holding.estimatedCostBasis),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              if (holding.estimatedUnrealizedPnl != null)
                ObAmount(
                  l10n.accountDetailWalletPnl(
                    _formatSignedUsd(holding.estimatedUnrealizedPnl!),
                    holding.estimatedUnrealizedPnlPercent == null
                        ? ''
                        : ' (${holding.estimatedUnrealizedPnlPercent!.toStringAsFixed(1)}%)',
                  ),
                  tone: _pnlTone(holding.estimatedUnrealizedPnl!),
                  style: theme.textTheme.bodySmall,
                ),
              if (holding.pricePerToken != null)
                Text(
                  l10n.accountDetailWalletPricePerToken(
                    NumberFormat.currency(
                      symbol: r'$',
                    ).format(holding.pricePerToken),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends HookWidget {
  const _TransactionCard({required this.transaction, required this.onEdit});

  final SolanaWalletTransaction transaction;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final tags = _parseTags(transaction.tagsCsv);
    final programs = _parsePrograms(
      transaction.programsJson,
    ).map((program) => _programLabel(program, l10n)).toSet().toList();
    final suggestedCategory = _suggestedCategoryForWalletTransaction(
      transaction,
      l10n,
    );
    final hasCategory = transaction.category?.trim().isNotEmpty ?? false;
    final confidence = transaction.interpretationConfidence?.trim();
    final occurredText = transaction.occurredAt == null
        ? null
        : DateFormat.yMMMd().add_jm().format(transaction.occurredAt!);

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: ObRoughDecoration(
                  color: palette.highlight,
                  outline: palette.quietPen,
                  radius: RadiusTokens.sm,
                  seed: 79,
                ),
                child: SkribbleIcon(
                  data: _transactionIcon(transaction.txType),
                  size: 18,
                  color: palette.hue(ObTone.brand),
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
                        color: palette.ink,
                      ),
                    ),
                    if (occurredText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.xs),
                        child: Text(
                          occurredText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const SkribbleIcon(data: OpenBudgetIcons.editNote),
                tooltip: l10n.accountDetailWalletEditMetadataTooltip,
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
                icon: OpenBudgetIcons.category,
                label: _SolanaWalletAccountBody._toLabel(
                  transaction.txType,
                  l10n,
                ),
              ),
              _MetadataChip(
                icon: OpenBudgetIcons.network,
                label: _SolanaWalletAccountBody._toLabel(
                  transaction.source,
                  l10n,
                ),
              ),
              if (confidence != null && confidence.isNotEmpty)
                _MetadataChip(
                  icon: OpenBudgetIcons.brain,
                  label: l10n.accountDetailWalletConfidence(
                    _SolanaWalletAccountBody._toLabel(confidence, l10n),
                  ),
                ),
              for (final program in programs.take(4))
                _MetadataChip(
                  icon: OpenBudgetIcons.extension,
                  label: program,
                ),
              if (hasCategory)
                _MetadataChip(
                  icon: OpenBudgetIcons.folder,
                  label: transaction.category!.trim(),
                ),
              if (!hasCategory && suggestedCategory != null)
                _MetadataChip(
                  icon: OpenBudgetIcons.sparkle,
                  label: l10n.accountDetailWalletSuggestedCategory(
                    suggestedCategory,
                  ),
                  tone: ObTone.brand,
                ),
              if (transaction.estimatedRealizedPnl != null)
                _MetadataChip(
                  icon: OpenBudgetIcons.trendingUp,
                  label: l10n.accountDetailWalletPnlValue(
                    _formatSignedUsd(transaction.estimatedRealizedPnl!),
                  ),
                  tone: _pnlTone(transaction.estimatedRealizedPnl!),
                ),
              if (transaction.taxYear != null)
                _MetadataChip(
                  icon: OpenBudgetIcons.calendar,
                  label: l10n.accountDetailWalletTaxYear(
                    transaction.taxYear!,
                  ),
                ),
              for (final tag in tags.take(4))
                _MetadataChip(icon: OpenBudgetIcons.label, label: tag),
            ],
          ),
          if (transaction.memo?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              transaction.memo!.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static WiredSvgIconData _transactionIcon(String txType) {
    final normalized = txType.toLowerCase();
    if (normalized.contains('swap')) return OpenBudgetIcons.transfer;
    if (normalized.contains('nft')) return OpenBudgetIcons.image;
    if (normalized.contains('stake')) return OpenBudgetIcons.lockClock;
    if (normalized.contains('transfer')) return OpenBudgetIcons.moveMoney;
    return OpenBudgetIcons.receipt;
  }
}

class _MetadataChip extends HookWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    this.tone = ObTone.neutral,
  });

  final WiredSvgIconData icon;
  final String label;
  final ObTone tone;

  @override
  Widget build(BuildContext context) => ObToneChip(
    label: label,
    tone: tone,
    icon: SkribbleIcon(data: icon, size: 16),
  );
}

String _programLabel(String? id, AppLocalizations l10n) {
  if (id == null || id.trim().isEmpty) {
    return l10n.accountsUnknownProgram;
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

ObTone _pnlTone(double amount) {
  if (amount > 0) return ObTone.funded;
  if (amount < 0) return ObTone.overspent;
  return ObTone.neutral;
}

String? _suggestedCategoryForWalletTransaction(
  SolanaWalletTransaction tx,
  AppLocalizations l10n,
) {
  final type = tx.txType.toLowerCase();
  final source = tx.source.toLowerCase();
  final programs = _parsePrograms(
    tx.programsJson,
  ).map((program) => program.toLowerCase());

  bool containsSignal(String signal) =>
      type.contains(signal) ||
      source.contains(signal) ||
      programs.any((program) => program.contains(signal));

  if (containsSignal('swap') ||
      containsSignal('jupiter') ||
      containsSignal('raydium') ||
      containsSignal('whirlpool') ||
      containsSignal('orca') ||
      containsSignal('pump')) {
    return l10n.accountsSuggestedSwaps;
  }
  if (containsSignal('stake')) return l10n.accountsSuggestedStaking;
  if (containsSignal('nft') ||
      containsSignal('magiceden') ||
      containsSignal('tensor') ||
      containsSignal('metaplex')) {
    return l10n.accountsSuggestedNft;
  }
  if (containsSignal('lend') ||
      containsSignal('borrow') ||
      containsSignal('margin')) {
    return l10n.accountsSuggestedLending;
  }
  if (containsSignal('airdrop') || containsSignal('claim')) {
    return l10n.accountsSuggestedIncome;
  }
  if (containsSignal('transfer') || containsSignal('system_program')) {
    return l10n.accountsSuggestedTransfers;
  }
  return null;
}

Future<int?> _showLoanTargetDialog(
  BuildContext context, {
  required String currencyCode,
  required int? monthlyTargetCents,
}) => showDialog<int>(
  context: context,
  builder: (_) => _LoanTargetDialog(
    currencyCode: currencyCode,
    monthlyTargetCents: monthlyTargetCents,
  ),
);

class _LoanTargetDialog extends HookWidget {
  const _LoanTargetDialog({
    required this.currencyCode,
    this.monthlyTargetCents,
  });

  final String currencyCode;
  final int? monthlyTargetCents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decimals = currencyDecimalsForCode(currencyCode);
    final controller = useTextEditingController(
      text: monthlyTargetCents == null
          ? ''
          : formatMinorUnits(monthlyTargetCents!, decimals),
    );
    useValueListenable(controller);
    final targetCents = parseMoneyInput(controller.text, decimals: decimals);
    final errorText = moneyInputError(
      controller.text,
      decimals: decimals,
      message: l10n.amountInvalidFormat(decimals),
    );

    return AlertDialog(
      title: Text(l10n.accountDetailLoanTarget),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: l10n.accountDetailLoanMonthlyPayment,
          errorText: errorText,
          prefixText: '${currencySymbolForCode(currencyCode)} ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: targetCents != null && targetCents > 0
              ? () => Navigator.of(context).pop(targetCents)
              : null,
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }
}

class _ReconcileDialog extends HookWidget {
  const _ReconcileDialog({
    required this.clearedBalanceCents,
    required this.currencyCode,
  });

  final int clearedBalanceCents;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final controller = useTextEditingController();
    useValueListenable(controller);
    final enteredCents = useState<int?>(null);
    final decimals = currencyDecimalsForCode(currencyCode);

    final differenceCents = enteredCents.value != null
        ? enteredCents.value! - clearedBalanceCents
        : null;
    final errorText = moneyInputError(
      controller.text,
      decimals: decimals,
      allowNegative: true,
      message: l10n.amountInvalidFormat(decimals),
    );

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
              ObAmount(
                formatCentsForCode(clearedBalanceCents, currencyCode),
                style: theme.textTheme.bodyMedium,
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
              errorText: errorText,
            ),
            onChanged: (value) {
              enteredCents.value = parseMoneyInput(
                value,
                decimals: decimals,
                allowNegative: true,
              );
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
                ObAmount(
                  formatCentsForCode(differenceCents, currencyCode),
                  tone: differenceCents != 0 ? ObTone.overspent : ObTone.funded,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (differenceCents != 0) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                l10n.reconcileAdjustmentNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
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

class _ReconcileMatchDialog extends HookWidget {
  const _ReconcileMatchDialog({
    required this.clearedBalanceCents,
    required this.currencyCode,
  });

  final int clearedBalanceCents;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        l10n.accountDetailReconcileMatchTitle(
          formatCentsForCode(clearedBalanceCents, currencyCode),
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        l10n.accountDetailReconcileMatchQuestion,
        style: theme.textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.dialogYes),
        ),
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.dialogNo),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
      ],
    );
  }
}
