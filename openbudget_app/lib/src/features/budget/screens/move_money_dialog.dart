import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
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
    final amountController = useTextEditingController();
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
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: '${l10n.transactionAmountLabel} (${currency.code})',
                prefixText: '${currency.symbol} ',
                hintText: formatCents(0, currency),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
                  amountController,
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
    TextEditingController amountController,
    ValueNotifier<String?> fromEnvelopeId,
    ValueNotifier<String?> toEnvelopeId,
    CurrencyCode currency,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (fromEnvelopeId.value == null || toEnvelopeId.value == null) return;
    if (fromEnvelopeId.value == toEnvelopeId.value) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.moveMoneySameError),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final amountCents = (amount * _pow10(currency.decimals)).round();
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.moveMoneySuccess)));
      if (context.mounted) Navigator.of(context).pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.moveMoneyError),
          backgroundColor: colorScheme.error,
        ),
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
}
