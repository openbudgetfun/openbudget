import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_app/src/features/ledger/ledger_labels.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_actions_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/ledger/widgets/journal_status_chip.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A budget's double-entry books: journals, chart of accounts and trial
/// balance.
class BooksScreen extends HookConsumerWidget {
  const BooksScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabController = useTabController(initialLength: 3);
    final lockDate = useState<DateTime?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.booksTitle),
        actions: [
          IconButton(
            key: const Key('books-lock-button'),
            tooltip: l10n.booksLockDateLabel,
            icon: const SkribbleIcon(data: OpenBudgetIcons.lockClock),
            onPressed: () => _showLockDialog(context, ref, lockDate),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('books-new-journal'),
        tooltip: l10n.booksNewJournalTooltip,
        onPressed: () => context.pushNamed(
          journalNewRoute,
          pathParameters: {'id': budgetId},
        ),
        child: const SkribbleIcon(data: OpenBudgetIcons.add),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: l10n.booksTabJournals),
              Tab(text: l10n.booksTabAccounts),
              Tab(text: l10n.booksTabTrialBalance),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _JournalsTab(budgetId: budgetId),
                _AccountsTab(budgetId: budgetId),
                _TrialBalanceTab(budgetId: budgetId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLockDialog(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<DateTime?> lockDate,
  ) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('books-lock-dialog'),
        title: Text(l10n.booksLockDateLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key: const Key('books-lock-current'),
              lockDate.value == null
                  ? l10n.booksLockDateNone
                  : DateFormat.yMMMd().format(lockDate.value!),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.booksLockDateHint,
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: Theme.of(dialogContext).ob.mutedInk,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            key: const Key('books-lock-set'),
            onPressed: () async {
              final picked = await _pickLockDate(dialogContext, lockDate);
              if (picked == null) return;
              if (dialogContext.mounted) dialogContext.pop();
              if (!context.mounted) return;
              await _setLockDate(context, ref, picked, lockDate);
            },
            child: Text(l10n.booksLockDateAction),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickLockDate(
    BuildContext context,
    ValueNotifier<DateTime?> lockDate,
  ) async {
    final today = ledgerCalendarDate(DateTime.now());
    return showDatePicker(
      context: context,
      initialDate: lockDate.value ?? today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _setLockDate(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    ValueNotifier<DateTime?> lockDate,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final lock = await ref
          .read(ledgerActionsProvider.notifier)
          .setLockDate(budgetId: budgetId, lockDate: ledgerCalendarDate(date));
      lockDate.value = ledgerCalendarDate(lock.lockDate);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.booksLockDateSavedToast(
          DateFormat.yMMMd().format(lock.lockDate),
        ),
        variant: AppToastVariant.success,
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: ledgerErrorMessage(error, l10n.booksLockDateError),
        variant: AppToastVariant.error,
      );
    }
  }
}

/// The posted and draft journals, newest first.
class _JournalsTab extends HookConsumerWidget {
  const _JournalsTab({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final journalsAsync = ref.watch(ledgerJournalsProvider(budgetId));

    return journalsAsync.when(
      loading: () => Center(
        child: ObLoadingPanel(label: l10n.booksTabJournals),
      ),
      error: (error, _) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.booksJournalsLoadError,
            message: ledgerErrorMessage(error, l10n.booksJournalsLoadError),
            action: ObStateAction(
              label: l10n.ledgerRetry,
              onPressed: () => ref.invalidate(ledgerJournalsProvider(budgetId)),
            ),
          ),
        ),
      ),
      data: (journals) => journals.isEmpty
          ? Center(
              child: ObStatePanel.empty(
                title: l10n.booksJournalEmptyTitle,
                message: l10n.booksJournalEmptyMessage,
                action: ObStateAction(
                  label: l10n.booksJournalEmptyAction,
                  onPressed: () => context.pushNamed(
                    journalNewRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(ledgerJournalsProvider(budgetId)),
              child: ListView.builder(
                key: const Key('books-journals-list'),
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.sm,
                  SpacingTokens.md,
                  SpacingTokens.xl,
                ),
                itemCount: journals.length,
                itemBuilder: (context, index) {
                  final journal = journals[index];
                  return _JournalCard(
                    journal: journal,
                    onTap: () => context.pushNamed(
                      journalDetailRoute,
                      pathParameters: {
                        'id': budgetId,
                        'journalId': journal.id!.toString(),
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _JournalCard extends HookWidget {
  const _JournalCard({required this.journal, required this.onTap});

  final Journal journal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final status = ledgerStatusFor(journal.status);

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(
          journal.reference.isEmpty
              ? DateFormat.yMMMd().format(journal.date)
              : journal.reference,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: journal.narration == null || journal.narration!.isEmpty
            ? Text(
                DateFormat.yMMMd().format(journal.date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              )
            : Text(
                journal.narration!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
        trailing: status == null ? null : JournalStatusChip(status: status),
      ),
    );
  }
}

/// The chart of accounts grouped by account type.
class _AccountsTab extends HookConsumerWidget {
  const _AccountsTab({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(ledgerAccountsProvider(budgetId));

    return accountsAsync.when(
      loading: () => Center(
        child: ObLoadingPanel(label: l10n.booksTabAccounts),
      ),
      error: (error, _) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.booksAccountsLoadError,
            message: ledgerErrorMessage(error, l10n.booksAccountsLoadError),
            action: ObStateAction(
              label: l10n.ledgerRetry,
              onPressed: () => ref.invalidate(ledgerAccountsProvider(budgetId)),
            ),
          ),
        ),
      ),
      data: (accounts) {
        final byType = <LedgerAccountType, List<LedgerAccount>>{};
        for (final account in accounts) {
          final type = ledgerAccountTypeFor(account.type);
          if (type == null) continue;
          byType.putIfAbsent(type, () => []).add(account);
        }

        if (accounts.isEmpty) {
          return Center(
            child: ObStatePanel.empty(
              title: l10n.booksAccountsEmptyTitle,
              message: l10n.booksAccountsEmptyMessage,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(ledgerAccountsProvider(budgetId)),
          child: ListView(
            key: const Key('books-accounts-list'),
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.xs,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              for (final type in ledgerAccountTypeOrder) ...[
                if (byType[type] case final group?) ...[
                  ObSectionHeader(
                    title: ledgerAccountTypeLabel(l10n, type),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      SpacingTokens.md,
                      0,
                      SpacingTokens.xs,
                    ),
                  ),
                  ObCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.xs,
                    ),
                    child: Column(
                      children: [
                        for (final (index, account) in group.indexed) ...[
                          if (index > 0) const Divider(height: 1),
                          _AccountRow(account: account),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AccountRow extends HookWidget {
  const _AccountRow({required this.account});

  final LedgerAccount account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              account.code,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Text(account.name, style: theme.textTheme.bodyMedium),
          ),
          if (account.archived)
            ObToneChip(
              key: const Key('ledger-account-archived'),
              label: AppLocalizations.of(context).ledgerAccountArchived,
            ),
        ],
      ),
    );
  }
}

/// The trial balance through a chosen as-of date.
class _TrialBalanceTab extends HookConsumerWidget {
  const _TrialBalanceTab({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final asOf = useState(ledgerCalendarDate(DateTime.now()));
    final reportAsync = ref.watch(
      ledgerTrialBalanceProvider(budgetId, asOf.value),
    );

    return reportAsync.when(
      loading: () => Center(
        child: ObLoadingPanel(label: l10n.booksTabTrialBalance),
      ),
      error: (error, _) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.booksTrialBalanceLoadError,
            message: ledgerErrorMessage(error, l10n.booksTrialBalanceLoadError),
            action: ObStateAction(
              label: l10n.ledgerRetry,
              onPressed: () => ref.invalidate(
                ledgerTrialBalanceProvider(budgetId, asOf.value),
              ),
            ),
          ),
        ),
      ),
      data: (report) {
        final balanced = report.totalDebitMinor == report.totalCreditMinor;

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(
            ledgerTrialBalanceProvider(budgetId, asOf.value),
          ),
          child: ListView(
            key: const Key('books-trial-list'),
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.xs,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              Row(
                children: [
                  Text(
                    l10n.ledgerTrialBalanceAsOfLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  TextButton(
                    key: const Key('trial-asof-button'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: asOf.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        asOf.value = ledgerCalendarDate(picked);
                      }
                    },
                    child: Text(
                      key: const Key('trial-asof-label'),
                      DateFormat.yMMMd().format(asOf.value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: balanced
                    ? ObToneChip(
                        key: const Key('trial-balanced-chip'),
                        label: l10n.ledgerTrialBalanceBalanced,
                        tone: ObTone.funded,
                        icon: const SkribbleIcon(
                          data: OpenBudgetIcons.checkCircle,
                          size: 16,
                        ),
                      )
                    : ObToneChip(
                        key: const Key('trial-unbalanced-chip'),
                        label: l10n.ledgerTrialBalanceUnbalanced(
                          formatCentsForCode(
                            (report.totalDebitMinor - report.totalCreditMinor)
                                .abs(),
                            report.currencyCode,
                          ),
                        ),
                        tone: ObTone.overspent,
                        icon: const SkribbleIcon(
                          data: OpenBudgetIcons.warning,
                          size: 16,
                        ),
                      ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              if (report.rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.lg,
                  ),
                  child: Text(
                    l10n.ledgerTrialBalanceEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                )
              else
                ObCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.xs,
                  ),
                  child: Column(
                    children: [
                      _TrialRow(
                        leading: '',
                        name: '',
                        debit: l10n.ledgerColumnDebit,
                        credit: l10n.ledgerColumnCredit,
                        isHeader: true,
                      ),
                      const Divider(height: 1),
                      for (final (index, row) in report.rows.indexed) ...[
                        if (index > 0) const Divider(height: 1),
                        _TrialRow(
                          leading: row.accountCode,
                          name: row.accountName,
                          debit: row.debitMinor == 0
                              ? ''
                              : formatCentsForCode(
                                  row.debitMinor,
                                  report.currencyCode,
                                ),
                          credit: row.creditMinor == 0
                              ? ''
                              : formatCentsForCode(
                                  row.creditMinor,
                                  report.currencyCode,
                                ),
                        ),
                      ],
                      const Divider(height: 1),
                      _TrialRow(
                        leading: '',
                        name: l10n.ledgerTotalsLabel,
                        debit: formatCentsForCode(
                          report.totalDebitMinor,
                          report.currencyCode,
                        ),
                        credit: formatCentsForCode(
                          report.totalCreditMinor,
                          report.currencyCode,
                        ),
                        isTotals: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TrialRow extends HookWidget {
  const _TrialRow({
    required this.leading,
    required this.name,
    required this.debit,
    required this.credit,
    this.isHeader = false,
    this.isTotals = false,
  });

  final String leading;
  final String name;
  final String debit;
  final String credit;
  final bool isHeader;
  final bool isTotals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final style = isHeader || isTotals
        ? theme.textTheme.labelMedium
        : theme.textTheme.bodyMedium;
    final headerStyle = isHeader
        ? style?.copyWith(color: palette.mutedInk)
        : isTotals
        ? style?.copyWith(fontWeight: FontWeight.w700)
        : style;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              leading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ),
          Expanded(
            child: Text(name, style: headerStyle),
          ),
          const SizedBox(width: SpacingTokens.sm),
          SizedBox(
            width: 96,
            child: Text(
              debit,
              textAlign: TextAlign.right,
              style: headerStyle?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(
            width: 96,
            child: Text(
              credit,
              textAlign: TextAlign.right,
              style: headerStyle?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
