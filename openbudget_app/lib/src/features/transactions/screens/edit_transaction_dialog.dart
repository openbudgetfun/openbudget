import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditTransactionDialog extends HookConsumerWidget {
  const EditTransactionDialog({
    required this.transaction,
    required this.budgetId,
    required this.currencyCode,
    super.key,
  });

  final Transaction transaction;
  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final descriptionController = useTextEditingController(
      text: transaction.description,
    );
    final amountController = useTextEditingController(
      text: (transaction.amountCents.abs() / _pow10(currencyCode.decimals))
          .toStringAsFixed(currencyCode.decimals),
    );
    final selectedDate = useState(transaction.transactionDate);
    final isSubmitting = useState(false);
    final isIncome = transaction.amountCents > 0;

    return AlertDialog(
      title: Text(l10n.transactionEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.transactionDescriptionLabel,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: l10n.transactionAmountLabel,
                prefixIcon: const Icon(Icons.attach_money_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: SpacingTokens.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded),
              title: Text(
                '${selectedDate.value.year}-'
                '${selectedDate.value.month.toString().padLeft(2, '0')}-'
                '${selectedDate.value.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate.value = picked;
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
              : () async {
                  final description = descriptionController.text.trim();
                  final amountText = amountController.text.trim();
                  final amount = double.tryParse(amountText) ?? 0;
                  if (description.isEmpty || amount <= 0) return;

                  final amountCents = (amount * _pow10(currencyCode.decimals))
                      .round();
                  final signedAmount = isIncome ? amountCents : -amountCents;

                  isSubmitting.value = true;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref
                        .read(transactionActionsProvider.notifier)
                        .updateTransaction(
                          transactionId: transaction.id?.toString() ?? '',
                          budgetId: budgetId,
                          description: description,
                          amountCents: signedAmount,
                          transactionDate: selectedDate.value,
                        );
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.transactionEditSuccess)),
                    );
                    navigator.pop();
                  } on Exception catch (_) {
                    isSubmitting.value = false;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.transactionEditError),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
          child: isSubmitting.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogSave),
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
