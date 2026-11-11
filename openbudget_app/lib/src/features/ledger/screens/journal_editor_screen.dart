import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/ledger_formatting.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_actions_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One editable journal line in the editor.
///
/// The [controller] is shared across copies so text edits never rebuild the
/// field from scratch; [amountText] mirrors it so totals recompute.
class JournalEditorLine {
  JournalEditorLine({
    TextEditingController? controller,
    this.accountId,
    this.isDebit = true,
    String amountText = '',
  }) : controller = controller ?? TextEditingController(text: amountText),
       amountText = amountText;

  final TextEditingController controller;
  final String? accountId;
  final bool isDebit;
  final String amountText;

  JournalEditorLine copyWith({
    Object? accountId = _unset,
    bool? isDebit,
    String? amountText,
  }) => JournalEditorLine(
    controller: controller,
    accountId: accountId == _unset ? this.accountId : accountId as String?,
    isDebit: isDebit ?? this.isDebit,
    amountText: amountText ?? this.amountText,
  );

  static const _unset = Object();
}

/// The full-screen journal entry form for a new draft, or, when [journalId]
/// is set, for an existing draft whose stored lines fill the rows on open.
///
/// Validation runs live against the core draft rules in the budget's
/// functional currency: every line converts at a rate of exactly one.
class JournalEditorScreen extends HookConsumerWidget {
  const JournalEditorScreen({
    required this.entityId,
    this.journalId,
    super.key,
  });

  final String entityId;
  final String? journalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final editingId = journalId;
    final budgetAsync = ref.watch(budgetDetailProvider(entityId));
    final accountsAsync = ref.watch(ledgerAccountsProvider(entityId));
    final storedLinesAsync = editingId == null
        ? null
        : ref.watch(ledgerJournalLinesProvider(editingId));
    final storedJournalAsync = editingId == null
        ? null
        : ref.watch(ledgerJournalsProvider(entityId));
    final currency =
        budgetAsync.whenOrNull(
          data: (budget) => normalizeCurrencyCode(budget.currencyCode),
        ) ??
        '';
    final decimals = currencyDecimalsForCode(currency);

    final date = useState(ledgerCalendarDate(DateTime.now()));
    final referenceController = useTextEditingController();
    final narrationController = useTextEditingController();
    final isSubmitting = useState(false);
    final createdControllers = useMemoized(
      () => <TextEditingController>[],
      const [],
    );

    JournalEditorLine newLine() {
      final line = JournalEditorLine();
      createdControllers.add(line.controller);
      return line;
    }

    final lines = useState<List<JournalEditorLine>>([newLine(), newLine()]);

    useEffect(
      () => () {
        for (final controller in createdControllers) {
          controller.dispose();
        }
      },
      const [],
    );

    // Fill the rows once with the draft's stored lines. Waiting for the
    // budget currency keeps the amounts formatted with the right decimals.
    final storedLines = storedLinesAsync?.value;
    final linesFilled = useRef(false);
    useEffect(() {
      if (editingId == null || linesFilled.value || currency.isEmpty) {
        return null;
      }
      final stored = storedLines;
      if (stored == null) return null;
      linesFilled.value = true;
      JournalEditorLine lineFrom(JournalLine line) {
        final isDebit = line.debitMinor > 0;
        final editorLine = JournalEditorLine(
          accountId: line.ledgerAccountId.toString(),
          isDebit: isDebit,
          amountText: formatMinorUnits(
            isDebit ? line.debitMinor : line.creditMinor,
            decimals,
          ),
        );
        createdControllers.add(editorLine.controller);
        return editorLine;
      }

      lines.value = [for (final line in stored) lineFrom(line)];
      return null;
    }, [storedLines, currency]);

    // Restore the draft's own date, reference and narration so a re-save
    // does not blank them.
    final storedJournal = storedJournalAsync?.value
        ?.where((j) => j.id?.toString() == editingId)
        .firstOrNull;
    final metadataFilled = useRef(false);
    useEffect(() {
      if (editingId == null || metadataFilled.value) return null;
      final stored = storedJournal;
      if (stored == null) return null;
      metadataFilled.value = true;
      date.value = ledgerCalendarDate(stored.date);
      referenceController.text = stored.reference;
      narrationController.text = stored.narration ?? '';
      return null;
    }, [storedJournal]);

    final accounts = accountsAsync.value ?? const <LedgerAccount>[];
    final usableAccounts = accounts.where((a) => !a.archived).toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    final draftIssues = _validateDraft(lines.value, currency, decimals);
    final missingAccounts = lines.value
        .asMap()
        .entries
        .where((entry) => entry.value.accountId == null)
        .map((entry) => entry.key + 1)
        .toList();
    final canSubmit =
        draftIssues.isEmpty &&
        missingAccounts.isEmpty &&
        !lines.value.any((line) => line.controller.text.trim().isEmpty) &&
        !isSubmitting.value &&
        currency.isNotEmpty;
    final totals = _totals(lines.value, decimals);

    Widget editorForm() => ListView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              key: const Key('journal-date-button'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  date.value = ledgerCalendarDate(picked);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.journalDateLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  Text(
                    key: const Key('journal-date-label'),
                    DateFormat.yMMMd().format(date.value),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: ObTextField(
                key: const Key('journal-reference-field'),
                controller: referenceController,
                labelText: l10n.journalReferenceLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        ObTextField(
          key: const Key('journal-narration-field'),
          controller: narrationController,
          labelText: l10n.journalNarrationLabel,
        ),
        const SizedBox(height: SpacingTokens.lg),
        if (accountsAsync.isLoading)
          const Padding(
            padding: EdgeInsets.all(SpacingTokens.md),
            child: Center(child: WiredLoadingIndicator()),
          ),
        for (final (index, line) in lines.value.indexed) ...[
          _EditorLineCard(
            index: index,
            line: line,
            accounts: usableAccounts,
            decimals: decimals,
            currency: currency,
            canRemove: lines.value.length > 2,
            onChanged: (updated) {
              final next = [...lines.value];
              next[index] = updated;
              lines.value = next;
            },
            onRemove: () {
              final next = [...lines.value]..removeAt(index);
              lines.value = next;
            },
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('journal-add-line'),
            onPressed: () {
              lines.value = [...lines.value, newLine()];
            },
            icon: const SkribbleIcon(data: OpenBudgetIcons.add, size: 18),
            label: Text(l10n.journalAddLine),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        _TotalsCard(
          debits: totals.debit,
          credits: totals.credit,
          difference: totals.difference,
          decimals: decimals,
          currency: currency,
          issues: [
            for (final issue in draftIssues) ledgerIssueMessage(l10n, issue),
          ],
          missingAccountLines: missingAccounts,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editingId == null ? l10n.journalNewTitle : l10n.journalEditTitle,
        ),
      ),
      body: budgetAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.booksTabJournals),
        ),
        error: (error, _) => Center(
          child: ObStatePanel.problem(
            title: l10n.booksTabJournals,
            message: ledgerErrorMessage(error, l10n.booksTabJournals),
          ),
        ),
        data: (_) {
          final gateId = editingId;
          final gate = storedLinesAsync;
          if (gate == null || gateId == null) return editorForm();
          return gate.when(
            loading: () => KeyedSubtree(
              key: const Key('journal-lines-loading'),
              child: Center(
                child: ObLoadingPanel(label: l10n.booksTabJournals),
              ),
            ),
            error: (error, _) => KeyedSubtree(
              key: const Key('journal-lines-error'),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: ObStatePanel.problem(
                    title: l10n.journalEditTitle,
                    message: ledgerErrorMessage(
                      error,
                      l10n.journalLinesLoadError,
                    ),
                    action: ObStateAction(
                      label: l10n.ledgerRetry,
                      onPressed: () =>
                          ref.invalidate(ledgerJournalLinesProvider(gateId)),
                    ),
                  ),
                ),
              ),
            ),
            data: (_) => editorForm(),
          );
        },
      ),
      bottomNavigationBar: _EditorActionBar(
        canSubmit: canSubmit,
        isSubmitting: isSubmitting.value,
        onSave: () => _submit(
          context,
          ref,
          date: date.value,
          referenceController: referenceController,
          narrationController: narrationController,
          lines: lines.value,
          currency: currency,
          decimals: decimals,
          post: false,
          journalId: editingId,
          isSubmitting: isSubmitting,
        ),
        onPost: () => _post(
          context,
          ref,
          date: date.value,
          referenceController: referenceController,
          narrationController: narrationController,
          lines: lines.value,
          currency: currency,
          decimals: decimals,
          journalId: editingId,
          isSubmitting: isSubmitting,
        ),
        l10n: l10n,
        palette: palette,
      ),
    );
  }

  Future<void> _post(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required TextEditingController referenceController,
    required TextEditingController narrationController,
    required List<JournalEditorLine> lines,
    required String currency,
    required int decimals,
    required String? journalId,
    required ValueNotifier<bool> isSubmitting,
  }) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('journal-post-dialog'),
        title: Text(l10n.journalPostConfirmTitle),
        content: Text(l10n.journalPostConfirmBody),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            key: const Key('journal-post-confirm'),
            onPressed: () => dialogContext.pop(true),
            child: Text(l10n.journalPostConfirmAction),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    if (!context.mounted) return;
    await _submit(
      context,
      ref,
      date: date,
      referenceController: referenceController,
      narrationController: narrationController,
      lines: lines,
      currency: currency,
      decimals: decimals,
      post: true,
      journalId: journalId,
      isSubmitting: isSubmitting,
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref, {
    required DateTime date,
    required TextEditingController referenceController,
    required TextEditingController narrationController,
    required List<JournalEditorLine> lines,
    required String currency,
    required int decimals,
    required bool post,
    required String? journalId,
    required ValueNotifier<bool> isSubmitting,
  }) async {
    final l10n = AppLocalizations.of(context);
    final lineInputs = <JournalLineInput>[];
    for (final line in lines) {
      final amount = parseMinorUnits(line.controller.text, decimals);
      final accountId = line.accountId;
      if (amount == null || amount == 0 || accountId == null) return;
      lineInputs.add(
        JournalLineInput(
          ledgerAccountId: UuidValue.fromString(accountId),
          currencyCode: currency,
          debitMinor: line.isDebit ? amount : 0,
          creditMinor: line.isDebit ? 0 : amount,
          functionalDebitMinor: line.isDebit ? amount : 0,
          functionalCreditMinor: line.isDebit ? 0 : amount,
          exchangeRate: '1',
          rateDate: date,
          rateSource: 'manual',
        ),
      );
    }

    isSubmitting.value = true;
    final actions = ref.read(ledgerActionsProvider.notifier);
    try {
      final draft = await actions.saveDraftJournal(
        entityId: entityId,
        date: date,
        lines: lineInputs,
        journalId: journalId,
        reference: referenceController.text.trim(),
        narration: narrationController.text.trim().isEmpty
            ? null
            : narrationController.text.trim(),
      );
      if (post) {
        await actions.postJournal(
          entityId: entityId,
          journalId: draft.id!.toString(),
        );
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.journalPostedToast,
          variant: AppToastVariant.success,
        );
      } else {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.journalDraftSavedToast,
          variant: AppToastVariant.success,
        );
      }
      if (context.mounted) context.pop();
    } on Exception catch (error) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: ledgerErrorMessage(
          error,
          post ? l10n.journalPostError : l10n.journalSaveError,
        ),
        variant: AppToastVariant.error,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}

class _EditorLineCard extends HookWidget {
  const _EditorLineCard({
    required this.index,
    required this.line,
    required this.accounts,
    required this.decimals,
    required this.currency,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final JournalEditorLine line;
  final List<LedgerAccount> accounts;
  final int decimals;
  final String currency;
  final bool canRemove;
  final ValueChanged<JournalEditorLine> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      key: ValueKey('journal-line-$index'),
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: Key('journal-line-account-$index'),
                  initialValue: line.accountId,
                  decoration: InputDecoration(
                    labelText: l10n.journalLineAccountLabel,
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(l10n.journalLinePickAccount),
                  items: [
                    for (final account in accounts)
                      DropdownMenuItem<String>(
                        value: account.id?.toString(),
                        child: Text('${account.code} ${account.name}'),
                      ),
                  ],
                  onChanged: (value) =>
                      onChanged(line.copyWith(accountId: value)),
                ),
              ),
              if (canRemove)
                IconButton(
                  key: Key('journal-line-remove-$index'),
                  tooltip: l10n.journalRemoveLineTooltip,
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.removeCircle,
                    color: palette.mutedInk,
                  ),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  key: Key('journal-line-side-$index'),
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(l10n.journalLineSideDebit),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.journalLineSideCredit),
                    ),
                  ],
                  selected: {line.isDebit},
                  onSelectionChanged: (selection) =>
                      onChanged(line.copyWith(isDebit: selection.first)),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: ObTextField(
                  key: Key('journal-line-amount-$index'),
                  controller: line.controller,
                  labelText: l10n.journalLineAmountLabel,
                  prefixText: currencySymbolForCode(currency),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (text) =>
                      onChanged(line.copyWith(amountText: text)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends HookWidget {
  const _TotalsCard({
    required this.debits,
    required this.credits,
    required this.difference,
    required this.decimals,
    required this.currency,
    required this.issues,
    required this.missingAccountLines,
  });

  final int debits;
  final int credits;
  final int difference;
  final int decimals;
  final String currency;
  final List<String> issues;
  final List<int> missingAccountLines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      key: const Key('journal-totals'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TotalRow(
            label: l10n.journalDebitsLabel,
            amount: formatMinorUnits(debits, decimals),
          ),
          _TotalRow(
            label: l10n.journalCreditsLabel,
            amount: formatMinorUnits(credits, decimals),
          ),
          _TotalRow(
            label: l10n.journalDifferenceLabel,
            amount: formatMinorUnits(difference, decimals),
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (issues.isEmpty && missingAccountLines.isEmpty)
            ObToneChip(
              key: const Key('journal-balanced-chip'),
              label: l10n.journalBalancedLabel,
              tone: ObTone.funded,
              icon: const SkribbleIcon(
                data: OpenBudgetIcons.checkCircle,
                size: 16,
              ),
            )
          else ...[
            if (difference != 0)
              ObToneChip(
                key: const Key('journal-unbalanced-chip'),
                label: l10n.journalUnbalancedLabel(
                  formatMinorForCode(difference.abs(), currency),
                ),
                tone: ObTone.overspent,
                icon: const SkribbleIcon(
                  data: OpenBudgetIcons.warning,
                  size: 16,
                ),
              ),
            for (final line in missingAccountLines)
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.xs),
                child: Text(
                  key: Key('journal-missing-account-$line'),
                  l10n.journalLinePickAccount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                  ),
                ),
              ),
            for (final (index, issue) in issues.indexed)
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.xs),
                child: Text(
                  key: Key('journal-issue-$index'),
                  issue,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends HookWidget {
  const _TotalRow({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorActionBar extends HookWidget {
  const _EditorActionBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSave,
    required this.onPost,
    required this.l10n,
    required this.palette,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final Future<void> Function() onSave;
  final Future<void> Function() onPost;
  final AppLocalizations l10n;
  final ObPalette palette;

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
            Expanded(
              child: OutlinedButton(
                key: const Key('journal-save-draft'),
                onPressed: canSubmit && !isSubmitting ? onSave : null,
                child: Text(l10n.journalSaveDraft),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: FilledButton(
                key: const Key('journal-post-button'),
                onPressed: canSubmit && !isSubmitting ? onPost : null,
                child: Text(l10n.journalPost),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

({int debit, int credit, int difference}) _totals(
  List<JournalEditorLine> lines,
  int decimals,
) {
  var debit = 0;
  var credit = 0;
  for (final line in lines) {
    final amount = parseMinorUnits(line.amountText, decimals) ?? 0;
    if (amount <= 0) continue;
    if (line.isDebit) {
      debit += amount;
    } else {
      credit += amount;
    }
  }
  return (debit: debit, credit: credit, difference: debit - credit);
}

/// Runs the core draft rules over the lines as typed.
///
/// Only the failures a single-currency editor can produce are expected:
/// line counts, one-sided amounts and the functional balance.
List<LedgerValidationIssue> _validateDraft(
  List<JournalEditorLine> lines,
  String currency,
  int decimals,
) {
  if (currency.isEmpty) return const [];
  final today = ledgerCalendarDate(DateTime.now());
  final functionalLines = <JournalLineDraft>[
    for (final line in lines)
      JournalLineDraft(
        accountCode: line.accountId ?? '',
        debitMinor: line.isDebit
            ? parseMinorUnits(line.amountText, decimals) ?? 0
            : 0,
        creditMinor: line.isDebit
            ? 0
            : parseMinorUnits(line.amountText, decimals) ?? 0,
        currencyCode: currency,
        functionalDebitMinor: line.isDebit
            ? parseMinorUnits(line.amountText, decimals) ?? 0
            : 0,
        functionalCreditMinor: line.isDebit
            ? 0
            : parseMinorUnits(line.amountText, decimals) ?? 0,
        exchangeRate: '1',
        rateDate: today,
        rateSource: 'manual',
      ),
  ];
  return JournalDraft(
    functionalCurrency: currency,
    lines: functionalLines,
  ).validate();
}
