import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_last_envelope_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_match_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddExpenseScreen extends HookConsumerWidget {
  const AddExpenseScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final memoController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedDate = useState(DateTime.now());
    final selectedEnvelopeId = useState<String?>(null);
    final selectedCategoryId = useState<String?>(null);
    final selectedPayeeId = useState<String?>(null);
    final autoAssignedByRule = useState(false);
    final duplicateCount = useState(0);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final theme = Theme.of(context);
    final palette = theme.ob;
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => normalizeCurrencyCode(budget.currencyCode),
        ) ??
        '';

    useValueListenable(amountController);

    Future<void> checkDuplicates() async {
      final budget = budgetAsync.value;
      if (budget == null) return;
      final amountText = amountController.text.trim();
      final amount = double.tryParse(amountText) ?? 0;
      if (amount <= 0) {
        duplicateCount.value = 0;
        return;
      }
      final amountCents =
          (amount * _pow10(currencyDecimalsForCode(budgetCurrency))).round();
      try {
        final duplicates = await ref.read(
          duplicateCheckProvider(
            budgetId,
            -amountCents,
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
    if (summaryAsync.hasValue) {
      for (final catEnv in summaryAsync.value!.categories) {
        for (final envelope in catEnv.envelopes) {
          envelopeItems.add(
            DropdownMenuItem<String>(
              value: envelope.id?.toString() ?? '',
              child: Text('${catEnv.category.name} / ${envelope.name}'),
            ),
          );
        }
      }
    }

    void updateCategoryForEnvelope(String envId) {
      if (envId.isNotEmpty && summaryAsync.hasValue) {
        for (final catEnv in summaryAsync.value!.categories) {
          for (final envelope in catEnv.envelopes) {
            if (envelope.id?.toString() == envId) {
              selectedCategoryId.value = catEnv.category.id?.toString();
              return;
            }
          }
        }
      }
      selectedCategoryId.value = null;
    }

    final amountText = amountController.text.trim();
    final amountValue = double.tryParse(amountText) ?? 0;
    final amountCentsPreview =
        (amountValue * _pow10(currencyDecimalsForCode(budgetCurrency))).round();
    final formattedAmount = amountValue == 0
        ? '-${formatCentsForCode(0, budgetCurrency)}'
        : formatCentsForCode(-amountCentsPreview, budgetCurrency);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 88,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                context.goNamed(planRoute, pathParameters: {'id': budgetId}),
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
                                pathParameters: {'id': budgetId},
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
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
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
                            prefixIcon: const SkribbleIcon(
                              data: OpenBudgetIcons.money,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText:
                                '-${formatCentsForCode(0, budgetCurrency)}',
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
                              onChanged: (value) async {
                                final payId = value ?? '';
                                selectedPayeeId.value = payId.isEmpty
                                    ? null
                                    : payId;
                                autoAssignedByRule.value = false;

                                if (payId.isNotEmpty) {
                                  final ruleEnvelope = await ref.read(
                                    ruleMatchEnvelopeProvider(
                                      payId,
                                      budgetId,
                                    ).future,
                                  );
                                  if (ruleEnvelope != null) {
                                    selectedEnvelopeId.value = ruleEnvelope;
                                    updateCategoryForEnvelope(ruleEnvelope);
                                    autoAssignedByRule.value = true;
                                    return;
                                  }

                                  final lastEnvelope = await ref.read(
                                    payeeLastEnvelopeProvider(
                                      payId,
                                      budgetId,
                                    ).future,
                                  );
                                  if (lastEnvelope != null) {
                                    selectedEnvelopeId.value = lastEnvelope;
                                    updateCategoryForEnvelope(lastEnvelope);
                                  }
                                }
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
                                final envId = value ?? '';
                                selectedEnvelopeId.value = envId.isEmpty
                                    ? null
                                    : envId;
                                updateCategoryForEnvelope(envId);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      _ReadOnlyRow(
                        icon: OpenBudgetIcons.bank,
                        label: l10n.transactionAccountLabel,
                        value: budgetAsync.value?.name ?? l10n.accountListTitle,
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
                if (selectedPayeeId.value != null &&
                    selectedEnvelopeId.value != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: Text(
                      autoAssignedByRule.value
                          ? l10n.transactionRulesAutoAssigned
                          : l10n.payeeAutoEnvelopeHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: autoAssignedByRule.value
                            ? palette.brand
                            : palette.mutedInk,
                        fontStyle: FontStyle.italic,
                      ),
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
                        prefixIcon: const SkribbleIcon(
                          data: OpenBudgetIcons.document,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      TextField(
                        controller: memoController,
                        decoration: InputDecoration(
                          labelText: l10n.transactionMemoLabel,
                          prefixIcon: const SkribbleIcon(
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
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          final description = descriptionController.text.trim();
                          final amountText = amountController.text.trim();
                          final amount = double.tryParse(amountText) ?? 0;
                          if (description.isEmpty || amount <= 0) {
                            return;
                          }

                          final budget = budgetAsync.value;
                          if (budget == null) return;

                          final amountCents =
                              (amount *
                                      _pow10(
                                        currencyDecimalsForCode(budgetCurrency),
                                      ))
                                  .round();

                          isSubmitting.value = true;
                          final router = GoRouter.of(context);
                          try {
                            final memoText = memoController.text.trim();
                            await ref
                                .read(transactionActionsProvider.notifier)
                                .addExpense(
                                  description: description,
                                  amountCents: amountCents,
                                  currencyCode: budgetCurrency,
                                  budgetId: budgetId,
                                  date: selectedDate.value,
                                  envelopeId: selectedEnvelopeId.value,
                                  categoryId: selectedCategoryId.value,
                                  payeeId: selectedPayeeId.value,
                                  memo: memoText.isEmpty ? null : memoText,
                                );
                            if (!context.mounted) return;
                            showAppToast(
                              context,
                              message: l10n.transactionSuccess,
                              variant: AppToastVariant.success,
                            );
                            router.goNamed(
                              planRoute,
                              pathParameters: {'id': budgetId},
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
                SkribbleIcon(data: icon, size: 18, color: foreground),
                const SizedBox(width: SpacingTokens.xs),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
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

class _ReadOnlyRow extends HookWidget {
  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final WiredSvgIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Row(
      children: [
        SkribbleIcon(data: icon, size: 20, color: palette.brand),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
