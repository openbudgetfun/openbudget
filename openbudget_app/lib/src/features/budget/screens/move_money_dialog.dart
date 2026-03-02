import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class MoveMoneyDialog extends HookConsumerWidget {
  const MoveMoneyDialog({
    required this.budgetId,
    required this.year,
    required this.month,
    required this.categories,
    super.key,
  });

  final String budgetId;
  final int year;
  final int month;
  final List<CategoryWithEnvelopes> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final amountInput = useState('');
    final fromEnvelopeId = useState<String?>(null);
    final toEnvelopeId = useState<String?>(null);
    final isSubmitting = useState(false);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final currency =
        budgetAsync.whenOrNull(
          data: (budget) => parseCurrencyCode(budget.currencyCode),
        ) ??
        CurrencyCode.usd;

    // Build a flat list of envelopes with category labels.
    final envelopeItems = <DropdownMenuItem<String>>[];
    for (final cat in categories) {
      for (final me in cat.monthlyEnvelopes) {
        final envId = me.envelope.id?.toString() ?? '';
        envelopeItems.add(
          DropdownMenuItem(
            value: envId,
            child: Text('${cat.category.name} > ${me.envelope.name}'),
          ),
        );
      }
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(l10n.moveMoneyTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: fromEnvelopeId.value,
              decoration: InputDecoration(
                labelText: l10n.moveMoneyFrom,
                prefixIcon: const Icon(Icons.arrow_upward_rounded),
              ),
              items: envelopeItems,
              onChanged: (v) => fromEnvelopeId.value = v,
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              initialValue: toEnvelopeId.value,
              decoration: InputDecoration(
                labelText: l10n.moveMoneyTo,
                prefixIcon: const Icon(Icons.arrow_downward_rounded),
              ),
              items: envelopeItems,
              onChanged: (v) => toEnvelopeId.value = v,
            ),
            const SizedBox(height: SpacingTokens.md),
            BudgetAmountField(
              labelText: '${l10n.transactionAmountLabel} (${currency.code})',
              currencyCode: currency,
              inputValue: amountInput.value,
              hintText: formatBudgetAmountInputForField(
                input: '0',
                currencyCode: currency,
              ),
              prefixIcon: const Icon(Icons.payments_outlined),
              enabled: !isSubmitting.value,
              onTap: () async {
                final nextInput = await showBudgetAmountKeypadSheet(
                  context: context,
                  currencyCode: currency,
                  initialInput: amountInput.value,
                  title: l10n.moveMoneyTitle,
                  allowNegative: false,
                );
                if (nextInput != null) {
                  amountInput.value = nextInput;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: isSubmitting.value
              ? null
              : () => _submit(
                  context,
                  ref,
                  amountInput.value,
                  fromEnvelopeId,
                  toEnvelopeId,
                  currency,
                  isSubmitting,
                ),
          child: isSubmitting.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.moveMoneyButton),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    String amountInput,
    ValueNotifier<String?> fromEnvelopeId,
    ValueNotifier<String?> toEnvelopeId,
    CurrencyCode currency,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (fromEnvelopeId.value == null || toEnvelopeId.value == null) return;
    if (fromEnvelopeId.value == toEnvelopeId.value) {
      showAppToast(
        context,
        message: l10n.moveMoneySameError,
        variant: AppToastVariant.error,
      );
      return;
    }

    final amountCents =
        parseBudgetAmountInputToCents(
          input: amountInput,
          currencyCode: currency,
        ) ??
        0;
    if (amountCents <= 0) return;
    isSubmitting.value = true;

    try {
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .moveMoney(
            fromEnvelopeId: fromEnvelopeId.value!,
            toEnvelopeId: toEnvelopeId.value!,
            budgetId: budgetId,
            year: year,
            month: month,
            amountCents: amountCents,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.moveMoneySuccess,
        variant: AppToastVariant.success,
      );
      if (context.mounted) Navigator.of(context).pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.moveMoneyError,
        variant: AppToastVariant.error,
      );
    }
  }
}
