import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/ynab_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddIncomeScreen extends HookConsumerWidget {
  const AddIncomeScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final memoController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedDate = useState(DateTime.now());
    final selectedPayeeId = useState<String?>(null);
    final duplicateCount = useState(0);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => parseCurrencyCode(budget.currencyCode),
        ) ??
        CurrencyCode.usd;

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
      final amountCents = (amount * _pow10(budgetCurrency.decimals)).round();
      try {
        final duplicates = await ref.read(
          duplicateCheckProvider(
            budgetId,
            amountCents,
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

    final amountText = amountController.text.trim();
    final amountValue = double.tryParse(amountText) ?? 0;
    final amountCentsPreview = (amountValue * _pow10(budgetCurrency.decimals))
        .round();
    final formattedAmount = amountValue == 0
        ? formatCents(0, budgetCurrency)
        : formatCents(amountCentsPreview, budgetCurrency);

    return Scaffold(
      backgroundColor: YnabPalette.appBackground,
      appBar: AppBar(
        backgroundColor: YnabPalette.appBackground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  decoration: BoxDecoration(
                    color: YnabPalette.accentGreen,
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(120),
                          borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ModeChip(
                                label: l10n.addTransactionExpense,
                                icon: Icons.arrow_upward_rounded,
                                selected: false,
                                color: YnabPalette.mutedText,
                                onTap: () => context.goNamed(
                                  addExpenseRoute,
                                  pathParameters: {'id': budgetId},
                                ),
                              ),
                            ),
                            Expanded(
                              child: _ModeChip(
                                label: l10n.addTransactionIncome,
                                icon: Icons.arrow_downward_rounded,
                                selected: true,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            checkDuplicates();
                          }
                        },
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.transactionAmountLabel,
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: formatCents(0, budgetCurrency),
                            hintStyle: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.black.withAlpha(120),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.transactionAddIncome,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (amountText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            formattedAmount,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.black.withAlpha(150),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Card(
                  color: YnabPalette.surface,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: selectedPayeeId.value ?? '',
                          items: payeeItems,
                          onChanged: (value) {
                            selectedPayeeId.value =
                                (value != null && value.isNotEmpty)
                                ? value
                                : null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.payeeLabel,
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                          isExpanded: true,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        const _ReadOnlyRow(
                          icon: Icons.savings_rounded,
                          label: 'Category',
                          value: 'Ready to Assign',
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        _ReadOnlyRow(
                          icon: Icons.account_balance_rounded,
                          label: 'Account',
                          value:
                              budgetAsync.value?.name ?? l10n.accountListTitle,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today_rounded),
                          title: const Text('Date'),
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
                ),
                const SizedBox(height: SpacingTokens.md),
                Card(
                  color: YnabPalette.surface,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: l10n.transactionDescriptionLabel,
                            prefixIcon: const Icon(Icons.description_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        TextField(
                          controller: memoController,
                          decoration: InputDecoration(
                            labelText: l10n.transactionMemoLabel,
                            prefixIcon: const Icon(Icons.note_outlined),
                            hintText: l10n.transactionMemoHint,
                          ),
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                if (duplicateCount.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.sm),
                    child: Card(
                      color: colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.sm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Text(
                                l10n.duplicateWarning(duplicateCount.value),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.md),
                FilledButton.icon(
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
                              (amount * _pow10(budgetCurrency.decimals))
                                  .round();

                          isSubmitting.value = true;
                          final messenger = ScaffoldMessenger.of(context);
                          final router = GoRouter.of(context);
                          try {
                            final memoText = memoController.text.trim();
                            await ref
                                .read(transactionActionsProvider.notifier)
                                .addIncome(
                                  description: description,
                                  amountCents: amountCents,
                                  currencyCode: budgetCurrency.code,
                                  budgetId: budgetId,
                                  date: selectedDate.value,
                                  memo: memoText.isEmpty ? null : memoText,
                                );
                            messenger.showSnackBar(
                              SnackBar(content: Text(l10n.transactionSuccess)),
                            );
                            router.goNamed(
                              planRoute,
                              pathParameters: {'id': budgetId},
                            );
                          } on Exception catch (_) {
                            isSubmitting.value = false;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(l10n.transactionError),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        },
                  icon: isSubmitting.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(l10n.transactionSave),
                  style: FilledButton.styleFrom(
                    backgroundColor: YnabPalette.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ModeChip extends HookWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: YnabPalette.accentBlue),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: YnabPalette.mutedText,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
