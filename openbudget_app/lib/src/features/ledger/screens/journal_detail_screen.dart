import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_actions_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/ledger/widgets/journal_status_chip.dart';
import 'package:openbudget_app/src/features/ledger/widgets/ledger_amount_row.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One journal, read-only: a draft can be edited and deleted, a posted
/// journal can be reversed, and a reversed journal shows what undid it.
///
/// Every journal shows its stored lines under the header fields, formatted
/// in each line's own currency.
class JournalDetailScreen extends HookConsumerWidget {
  const JournalDetailScreen({
    required this.entityId,
    required this.journalId,
    super.key,
  });

  final String entityId;
  final String journalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final journalsAsync = ref.watch(ledgerJournalsProvider(entityId));
    final linesAsync = ref.watch(ledgerJournalLinesProvider(journalId));
    final accountsAsync = ref.watch(ledgerAccountsProvider(entityId));
    final accounts = accountsAsync.value ?? const <LedgerAccount>[];
    final isWorking = useState(false);

    final journals = journalsAsync.value ?? const <Journal>[];
    final journal = journals
        .where((j) => j.id?.toString() == journalId)
        .firstOrNull;
    final status = journal?.status;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.journalDetailTitle)),
      body: journalsAsync.when(
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
                onPressed: () =>
                    ref.invalidate(ledgerJournalsProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (journals) {
          final journal = journals
              .where((j) => j.id?.toString() == journalId)
              .firstOrNull;
          if (journal == null) {
            return Center(
              child: ObStatePanel.empty(
                title: l10n.booksJournalEmptyTitle,
                message: l10n.booksJournalEmptyMessage,
              ),
            );
          }

          final status = journal.status;
          final reversal = status == JournalStatus.reversed
              ? journals
                    .where(
                      (j) => j.reversalOfJournalId?.toString() == journalId,
                    )
                    .firstOrNull
              : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObCard(
                key: const Key('journal-detail-card'),
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        JournalStatusChip(status: status),
                        const Spacer(),
                        Text(
                          DateFormat.yMMMd().format(journal.date),
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    _Field(
                      label: l10n.journalReferenceLabel,
                      value: journal.reference,
                    ),
                    _Field(
                      label: l10n.journalNarrationLabel,
                      value: journal.narration ?? '',
                    ),
                    if (journal.postedAt != null)
                      _Note(
                        l10n.journalPostedAtLabel(
                          DateFormat.yMMMd().format(
                            journal.postedAt!.toLocal(),
                          ),
                        ),
                      ),
                    if (reversal != null)
                      _Note(
                        l10n.journalReversalOfLabel(
                          reversal.reference.isEmpty
                              ? DateFormat.yMMMd().format(reversal.date)
                              : reversal.reference,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              linesAsync.when(
                loading: () => const KeyedSubtree(
                  key: Key('journal-detail-lines-loading'),
                  child: Padding(
                    padding: EdgeInsets.all(SpacingTokens.md),
                    child: Center(child: WiredLoadingIndicator()),
                  ),
                ),
                error: (error, _) => KeyedSubtree(
                  key: const Key('journal-detail-lines-error'),
                  child: ObStatePanel.problem(
                    title: l10n.journalLinesHeader,
                    message: ledgerErrorMessage(
                      error,
                      l10n.journalLinesLoadError,
                    ),
                    action: ObStateAction(
                      label: l10n.ledgerRetry,
                      onPressed: () =>
                          ref.invalidate(ledgerJournalLinesProvider(journalId)),
                    ),
                  ),
                ),
                data: (lines) => _LinesCard(
                  lines: lines,
                  accounts: accounts,
                ),
              ),
              if (status == JournalStatus.posted) ...[
                const SizedBox(height: SpacingTokens.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xs,
                  ),
                  child: Text(
                    key: const Key('journal-readonly-note'),
                    l10n.journalReadOnlyBanner,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar:
          status == JournalStatus.draft || status == JournalStatus.posted
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(top: BorderSide(color: palette.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.sm,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      if (status == JournalStatus.draft) ...[
                        Expanded(
                          child: FilledButton(
                            key: const Key('journal-edit-button'),
                            onPressed: () => context.pushNamed(
                              journalEditRoute,
                              pathParameters: {
                                'id': entityId,
                                'journalId': journalId,
                              },
                            ),
                            child: Text(l10n.journalEditAction),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('journal-delete-button'),
                            onPressed: isWorking.value
                                ? null
                                : () => _deleteDraft(context, ref, isWorking),
                            child: Text(l10n.journalDeleteAction),
                          ),
                        ),
                      ],
                      if (status == JournalStatus.posted)
                        Expanded(
                          child: FilledButton(
                            key: const Key('journal-reverse-button'),
                            onPressed: isWorking.value
                                ? null
                                : () => _reverse(context, ref, isWorking),
                            child: Text(l10n.journalReverse),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _deleteDraft(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isWorking,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('journal-delete-dialog'),
        title: Text(l10n.journalDeleteTitle),
        content: Text(l10n.journalDeleteBody),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            key: const Key('journal-delete-confirm'),
            onPressed: () => dialogContext.pop(true),
            child: Text(l10n.journalDeleteAction),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    isWorking.value = true;
    try {
      await ref
          .read(ledgerActionsProvider.notifier)
          .deleteDraftJournal(entityId: entityId, journalId: journalId);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.journalDeletedToast,
        variant: AppToastVariant.success,
      );
      if (context.mounted) context.pop();
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: ledgerErrorMessage(error, l10n.journalDeleteError),
        variant: AppToastVariant.error,
      );
    } finally {
      isWorking.value = false;
    }
  }

  Future<void> _reverse(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isWorking,
  ) async {
    final l10n = AppLocalizations.of(context);

    final reversalDate = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => HookBuilder(
        builder: (dialogContext) {
          final chosen = useState(ledgerCalendarDate(DateTime.now()));
          return AlertDialog(
            key: const Key('journal-reverse-dialog'),
            title: Text(l10n.journalReverseConfirmTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.journalReverseConfirmBody),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  l10n.journalReverseDateLabel,
                  style: Theme.of(dialogContext).textTheme.labelSmall?.copyWith(
                    color: Theme.of(dialogContext).ob.mutedInk,
                  ),
                ),
                TextButton(
                  key: const Key('journal-reverse-date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: chosen.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      chosen.value = ledgerCalendarDate(picked);
                    }
                  },
                  child: Text(
                    key: const Key('journal-reverse-date-label'),
                    DateFormat.yMMMd().format(chosen.value),
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
                key: const Key('journal-reverse-confirm'),
                onPressed: () => dialogContext.pop(chosen.value),
                child: Text(l10n.journalReverseAction),
              ),
            ],
          );
        },
      ),
    );
    if (reversalDate == null) return;

    isWorking.value = true;
    try {
      await ref
          .read(ledgerActionsProvider.notifier)
          .reverseJournal(
            entityId: entityId,
            journalId: journalId,
            date: reversalDate,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.journalReversedToast,
        variant: AppToastVariant.success,
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: ledgerErrorMessage(error, l10n.journalReverseError),
        variant: AppToastVariant.error,
      );
    } finally {
      isWorking.value = false;
    }
  }
}

class _Field extends HookWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width line of narrative, such as when the journal was posted.
class _Note extends HookWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.xs),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }
}

/// The journal's stored lines: one row per line with the account, the
/// transaction-currency debit and credit, then totals per currency.
class _LinesCard extends HookWidget {
  const _LinesCard({required this.lines, required this.accounts});

  final List<JournalLine> lines;
  final List<LedgerAccount> accounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final labelsByAccountId = <String, (String, String)>{
      for (final account in accounts)
        if (account.id != null)
          account.id!.toString(): (account.code, account.name),
    };
    (String, String) accountParts(UuidValue accountId) =>
        labelsByAccountId[accountId.toString()] ?? ('', accountId.toString());

    final totalsByCurrency = <String, ({int debit, int credit})>{};
    for (final line in lines) {
      final current =
          totalsByCurrency[line.currencyCode] ?? (debit: 0, credit: 0);
      totalsByCurrency[line.currencyCode] = (
        debit: current.debit + line.debitMinor,
        credit: current.credit + line.creditMinor,
      );
    }
    final currencyCodes = totalsByCurrency.keys.toList()..sort();

    return ObCard(
      key: const Key('journal-detail-lines'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: Column(
        children: [
          LedgerAmountRow(
            code: '',
            name: '',
            debit: l10n.ledgerColumnDebit,
            credit: l10n.ledgerColumnCredit,
            isHeader: true,
          ),
          const Divider(height: 1),
          for (final (index, line) in lines.indexed) ...[
            if (index > 0) const Divider(height: 1),
            LedgerAmountRow(
              key: Key('journal-detail-line-$index'),
              code: accountParts(line.ledgerAccountId).$1,
              name: accountParts(line.ledgerAccountId).$2,
              debit: line.debitMinor == 0
                  ? ''
                  : formatMinorForCode(line.debitMinor, line.currencyCode),
              credit: line.creditMinor == 0
                  ? ''
                  : formatMinorForCode(line.creditMinor, line.currencyCode),
            ),
          ],
          const Divider(height: 1),
          for (final (index, code) in currencyCodes.indexed)
            LedgerAmountRow(
              key: Key('journal-detail-totals-$index'),
              code: '',
              name: l10n.ledgerTotalsLabel,
              debit: formatMinorForCode(totalsByCurrency[code]!.debit, code),
              credit: formatMinorForCode(totalsByCurrency[code]!.credit, code),
              isTotals: true,
            ),
        ],
      ),
    );
  }
}
