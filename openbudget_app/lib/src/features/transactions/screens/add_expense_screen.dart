import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/widgets/fx_rate_line.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One expense: a required account, an amount in the account's currency, a
/// live FX line when the account is foreign, and an optional lines editor.
/// Lines save only when they sum to the amount exactly.
class AddExpenseScreen extends HookConsumerWidget {
  const AddExpenseScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final memoController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedDate = useState(DateTime.now());
    final selectedEnvelopeId = useState<String?>(null);
    final selectedPayeeId = useState<String?>(null);
    final selectedAccountId = useState<String?>(null);
    final manualRate = useState<String?>(null);
    final duplicateCount = useState(0);
    final accountsAsync = ref.watch(accountListProvider(entityId));
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final theme = Theme.of(context);
    final palette = theme.ob;
    final baseCurrency = entityAsync.value?.baseCurrencyCode ?? '';

    useValueListenable(amountController);

    final accounts = accountsAsync.value ?? const <Account>[];
    final onBudgetAccounts = accounts
        .where((a) => a.onBudget && a.closedAt == null)
        .toList(growable: false);
    final allAccounts = accounts
        .where((a) => a.closedAt == null)
        .toList(growable: false);

    // The account defaults to the last used on-budget account; without
    // history, the first on-budget account.
    final defaultAccountId = useMemoized(() {
      if (selectedAccountId.value != null) return selectedAccountId.value!;
      return onBudgetAccounts.firstOrNull?.id?.toString() ??
          allAccounts.firstOrNull?.id?.toString() ??
          '';
    }, [selectedAccountId.value, accountsAsync]);

    final selectedAccount = allAccounts
        .where((a) => a.id?.toString() == defaultAccountId)
        .firstOrNull;
    final accountCurrency = selectedAccount?.currencyCode ?? baseCurrency;
    final amountDecimals = currencyDecimalsForCode(accountCurrency);
    final amountText = amountController.text.trim();
    final amountMinor = parseMoneyInput(amountText, decimals: amountDecimals);
    final amountError = moneyInputError(
      amountText,
      decimals: amountDecimals,
      message: l10n.amountInvalidFormat(amountDecimals),
    );
    final isForeign =
        accountCurrency.isNotEmpty &&
        baseCurrency.isNotEmpty &&
        accountCurrency != baseCurrency;

    // A transaction with lines keeps the lines editor; a plain one has none.
    final lines = useState<List<_ExpenseLine>>(const []);
    final remainingMinor = amountMinor == null
        ? null
        : amountMinor -
              lines.value.fold<int>(0, (sum, line) => sum + line.amountMinor);
    final linesSumExact =
        lines.value.isEmpty ||
        (amountMinor != null &&
            remainingMinor == 0 &&
            !lines.value.any((line) => line.hasError));

    Future<void> checkDuplicates() async {
      if (defaultAccountId.isEmpty || amountMinor == null || amountMinor <= 0) {
        duplicateCount.value = 0;
        return;
      }
      try {
        final duplicates = await ref.read(
          duplicateCheckProvider(
            defaultAccountId,
            amountMinor,
            selectedDate.value,
          ).future,
        );
        duplicateCount.value = duplicates.length;
      } on Exception catch (_) {
        duplicateCount.value = 0;
      }
    }

    final payeeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(value: '', child: Text(l10n.payeeNone)),
    ];
    if (payeesAsync.hasValue) {
      for (final payee in payeesAsync.value!) {
        payeeItems.add(
          DropdownMenuItem<String>(
            value: payee.id?.toString() ?? '',
            child: Text(payee.name),
          ),
        );
      }
    }

    final envelopeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '',
        child: Text(l10n.transactionUnassigned),
      ),
    ];
    if (groupsAsync.hasValue) {
      for (final group in groupsAsync.value!) {
        for (final envelope in group.envelopes) {
          final id = envelope.envelope.id?.toString() ?? '';
          if (id.isEmpty) continue;
          envelopeItems.add(
            DropdownMenuItem<String>(
              value: id,
              child: Text(
                '${group.category.name} / ${envelope.envelope.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }
    }

    final formattedAmount = amountMinor == null || amountMinor == 0
        ? '-${formatMinorForCode(0, accountCurrency)}'
        : formatMinorForCode(-amountMinor, accountCurrency);

    void openManualRateSheet({String? explanation}) {
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (sheetContext) => ManualRateSheet(
            fromCurrencyCode: accountCurrency,
            toCurrencyCode: baseCurrency,
            initialRate: manualRate.value,
            explanation: explanation,
            onRateChosen: (rate) => manualRate.value = rate,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 88,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => context.goNamed(
              planRoute,
              pathParameters: {'entityId': entityId},
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.dialogCancel),
          ),
        ),
        title: Text(l10n.addTransactionSheetTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ObCard(
                  tone: ObTone.overspent,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ModeChip(
                              label: l10n.addTransactionExpense,
                              icon: OpenBudgetIcons.outflow,
                              selected: true,
                            ),
                          ),
                          Expanded(
                            child: _ModeChip(
                              label: l10n.addTransactionIncome,
                              icon: OpenBudgetIcons.inflow,
                              selected: false,
                              tone: ObTone.funded,
                              onTap: () => context.goNamed(
                                addIncomeRoute,
                                pathParameters: {'entityId': entityId},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            unawaited(checkDuplicates());
                          }
                        },
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: amountDecimals > 0,
                          ),
                          textAlign: TextAlign.center,
                          style:
                              ObTextStyles.amount(
                                theme.textTheme.displaySmall,
                              ).copyWith(
                                color: palette.overspent,
                                fontWeight: FontWeight.w800,
                              ),
                          decoration: InputDecoration(
                            labelText: l10n.transactionAmountLabel,
                            errorText: amountError,
                            prefixIcon: const ObFieldIcon(
                              data: OpenBudgetIcons.money,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText:
                                '-${formatMinorForCode(0, accountCurrency)}',
                            hintStyle:
                                ObTextStyles.amount(
                                  theme.textTheme.displaySmall,
                                ).copyWith(
                                  color: palette.overspent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.transactionAddExpense,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      if (amountText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ObAmount(
                            formattedAmount,
                            tone: ObTone.overspent,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                      if (isForeign && amountMinor != null && amountMinor > 0)
                        FxRateLine(
                          key: const Key('expense-fx-line'),
                          fromCurrencyCode: accountCurrency,
                          toCurrencyCode: baseCurrency,
                          date: selectedDate.value,
                          amountMinor: amountMinor,
                          onSetRate: openManualRateSheet,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SkribbleIcon(
                            data: OpenBudgetIcons.bank,
                            size: 20,
                            color: palette.brand,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: ObDropdown<String>(
                              value: defaultAccountId,
                              items: [
                                for (final account in allAccounts)
                                  DropdownMenuItem<String>(
                                    value: account.id?.toString() ?? '',
                                    child: Text(
                                      '${account.name} '
                                      '(${account.currencyCode})',
                                    ),
                                  ),
                              ],
                              labelText: l10n.transactionAccountLabel,
                              onChanged: (value) {
                                selectedAccountId.value = value;
                                manualRate.value = null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Row(
                        children: [
                          SkribbleIcon(
                            data: OpenBudgetIcons.store,
                            size: 20,
                            color: palette.brand,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: ObDropdown<String>(
                              value: selectedPayeeId.value ?? '',
                              items: payeeItems,
                              labelText: l10n.payeeLabel,
                              onChanged: (value) {
                                selectedPayeeId.value = (value ?? '').isEmpty
                                    ? null
                                    : value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Row(
                        children: [
                          SkribbleIcon(
                            data: OpenBudgetIcons.envelope,
                            size: 20,
                            color: palette.brand,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: ObDropdown<String>(
                              value: selectedEnvelopeId.value ?? '',
                              items: envelopeItems,
                              labelText: l10n.transactionUnassigned,
                              onChanged: (value) {
                                selectedEnvelopeId.value = (value ?? '').isEmpty
                                    ? null
                                    : value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const SkribbleIcon(
                          data: OpenBudgetIcons.calendar,
                        ),
                        title: Text(l10n.transactionDateLabel),
                        subtitle: Text(_formatDate(selectedDate.value)),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate.value,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate.value = picked;
                            await checkDuplicates();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ObTextField(
                        controller: descriptionController,
                        labelText: l10n.transactionDescriptionLabel,
                        prefixIcon: const ObFieldIcon(
                          data: OpenBudgetIcons.document,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      TextField(
                        controller: memoController,
                        decoration: InputDecoration(
                          labelText: l10n.transactionMemoLabel,
                          prefixIcon: const ObFieldIcon(
                            data: OpenBudgetIcons.note,
                          ),
                          hintText: l10n.transactionMemoHint,
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                _LinesEditor(
                  lines: lines.value,
                  amountMinor: amountMinor,
                  currencyCode: accountCurrency,
                  envelopeItems: envelopeItems,
                  onChanged: (updated) => lines.value = updated,
                ),
                if (lines.value.isNotEmpty &&
                    remainingMinor != null &&
                    remainingMinor != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: Text(
                      l10n.linesEditorRemaining(
                        formatMinorForCode(remainingMinor, accountCurrency),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.overspent,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (duplicateCount.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.sm),
                    child: ObCard(
                      tone: ObTone.overspent,
                      padding: const EdgeInsets.all(SpacingTokens.sm),
                      child: Row(
                        children: [
                          SkribbleIcon(
                            data: OpenBudgetIcons.warning,
                            color: palette.overspent,
                            size: 20,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Text(
                              l10n.duplicateWarning(duplicateCount.value),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.md),
                ObFilledButton(
                  onPressed:
                      isSubmitting.value ||
                          defaultAccountId.isEmpty ||
                          amountMinor == null ||
                          amountMinor <= 0 ||
                          !linesSumExact
                      ? null
                      : () async {
                          final description = descriptionController.text.trim();
                          if (description.isEmpty) return;

                          isSubmitting.value = true;
                          final router = GoRouter.of(context);
                          try {
                            final memoText = memoController.text.trim();
                            final lineInputs = lines.value.isEmpty
                                ? <TransactionLineInput>[
                                    if (selectedEnvelopeId.value != null)
                                      TransactionLineInput(
                                        amountMinor: -amountMinor,
                                        envelopeId: UuidValue.fromString(
                                          selectedEnvelopeId.value!,
                                        ),
                                      ),
                                  ]
                                : lines.value
                                      .map(
                                        (line) => TransactionLineInput(
                                          amountMinor: -line.amountMinor,
                                          envelopeId: line.envelopeId.isEmpty
                                              ? null
                                              : UuidValue.fromString(
                                                  line.envelopeId,
                                                ),
                                        ),
                                      )
                                      .toList();
                            await ref
                                .read(transactionActionsProvider.notifier)
                                .create(
                                  entityId: entityId,
                                  input: TransactionInput(
                                    accountId: UuidValue.fromString(
                                      defaultAccountId,
                                    ),
                                    date: DateTime.utc(
                                      selectedDate.value.year,
                                      selectedDate.value.month,
                                      selectedDate.value.day,
                                    ),
                                    amountMinor: -amountMinor,
                                    fxRate: manualRate.value,
                                    payeeId: selectedPayeeId.value == null
                                        ? null
                                        : UuidValue.fromString(
                                            selectedPayeeId.value!,
                                          ),
                                    description: description,
                                    memo: memoText.isEmpty ? null : memoText,
                                    lines: lineInputs,
                                  ),
                                );
                            if (!context.mounted) return;
                            showAppToast(
                              context,
                              message: l10n.transactionSuccess,
                              variant: AppToastVariant.success,
                            );
                            router.goNamed(
                              planRoute,
                              pathParameters: {'entityId': entityId},
                            );
                          } on Exception catch (_) {
                            isSubmitting.value = false;
                            if (!context.mounted) return;
                            showAppToast(
                              context,
                              message: l10n.transactionError,
                              variant: AppToastVariant.error,
                            );
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSubmitting.value)
                        WiredLoadingIndicator(size: 18, color: palette.mutedInk)
                      else
                        const SkribbleIcon(
                          data: OpenBudgetIcons.checkCircle,
                          size: 18,
                        ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(l10n.transactionSave),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// One line of the split.
class _ExpenseLine {
  const _ExpenseLine({
    required this.amountMinor,
    this.envelopeId = '',
    this.hasError = false,
  });

  final int amountMinor;
  final String envelopeId;

  /// True while the typed text is not an exact amount; the line keeps its
  /// last valid value and the form refuses to save.
  final bool hasError;
}

/// The lines editor: shows every line, adds and removes them, and exposes
/// the remaining unallocated amount. Saving is enabled only when the lines
/// sum to the amount exactly.
class _LinesEditor extends HookWidget {
  const _LinesEditor({
    required this.lines,
    required this.amountMinor,
    required this.currencyCode,
    required this.envelopeItems,
    required this.onChanged,
  });

  final List<_ExpenseLine> lines;
  final int? amountMinor;
  final String currencyCode;
  final List<DropdownMenuItem<String>> envelopeItems;
  final ValueChanged<List<_ExpenseLine>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final decimals = currencyDecimalsForCode(currencyCode);

    if (lines.isEmpty) {
      return OutlinedButton.icon(
        onPressed: amountMinor == null || amountMinor == 0
            ? null
            : () {
                final total = amountMinor;
                if (total == null || total == 0) return;
                onChanged([_ExpenseLine(amountMinor: total)]);
              },
        icon: const SkribbleIcon(data: OpenBudgetIcons.split),
        label: Text(l10n.linesEditorSplit),
      );
    }

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.split,
                size: 18,
                color: palette.brand,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.linesEditorTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (var i = 0; i < lines.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      key: ValueKey('line-amount-$i'),
                      initialValue: formatMinorUnits(
                        lines[i].amountMinor,
                        decimals,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: decimals > 0,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.linesEditorLineAmount(i + 1),
                        prefixText: '$currencyCode ',
                        errorText: lines[i].hasError
                            ? l10n.amountInvalidFormat(decimals)
                            : null,
                      ),
                      onChanged: (text) {
                        final value = parseMoneyInput(
                          text,
                          decimals: decimals,
                        );
                        final updated = [...lines];
                        updated[i] = _ExpenseLine(
                          amountMinor: value ?? updated[i].amountMinor,
                          envelopeId: updated[i].envelopeId,
                          hasError: value == null && text.trim().isNotEmpty,
                        );
                        onChanged(updated);
                      },
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: lines[i].envelopeId.isEmpty
                          ? ''
                          : lines[i].envelopeId,
                      isExpanded: true,
                      items: envelopeItems,
                      decoration: InputDecoration(
                        labelText: l10n.transactionUnassigned,
                      ),
                      onChanged: (value) {
                        final updated = [...lines];
                        updated[i] = _ExpenseLine(
                          amountMinor: updated[i].amountMinor,
                          envelopeId: value ?? '',
                        );
                        onChanged(updated);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () => onChanged([
                      for (var j = 0; j < lines.length; j++)
                        if (j != i) lines[j],
                    ]),
                    icon: const SkribbleIcon(data: OpenBudgetIcons.remove),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: () => onChanged(<_ExpenseLine>[
              ...lines,
              const _ExpenseLine(amountMinor: 0),
            ]),
            icon: const SkribbleIcon(data: OpenBudgetIcons.add),
            label: Text(l10n.linesEditorAddLine),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends HookWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.tone = ObTone.neutral,
    this.onTap,
  });

  final String label;
  final WiredSvgIconData icon;
  final bool selected;
  final ObTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final foreground = selected ? palette.onAction : palette.hue(tone);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const ObRoughBorder(),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            decoration: ObRoughDecoration(
              color: selected ? palette.action : null,
              outline: palette.quietPen,
              radius: RadiusTokens.sm,
              strokeWidth: 1.6,
              seed: 31,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkribbleIcon(data: icon, size: 16, color: foreground),
                const SizedBox(width: SpacingTokens.xs),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
