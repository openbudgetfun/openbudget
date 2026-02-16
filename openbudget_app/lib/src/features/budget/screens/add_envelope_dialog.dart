import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddEnvelopeDialog extends HookConsumerWidget {
  const AddEnvelopeDialog({
    required this.categoryId,
    required this.budgetId,
    required this.currencyCode,
    super.key,
  });

  final String categoryId;
  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController();
    final amountController = useTextEditingController();
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.budgetAddEnvelope),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: l10n.budgetEnvelopeNameLabel,
              prefixIcon: const Icon(Icons.mail_outlined),
            ),
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: l10n.budgetEnvelopeAmountLabel,
              prefixText: '${currencyCode.symbol} ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: isSubmitting.value
                ? null
                : (_) => _submit(
                    context,
                    ref,
                    nameController,
                    amountController,
                    isSubmitting,
                  ),
          ),
        ],
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
                  nameController,
                  amountController,
                  isSubmitting,
                ),
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

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController amountController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    final amountCents = (amount * _pow10(currencyCode.decimals)).round();

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .createEnvelope(
            name: name,
            categoryId: categoryId,
            budgetedAmountCents: amountCents,
            currencyCode: currencyCode.code,
            budgetId: budgetId,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.budgetEnvelopeCreated)),
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.budgetEnvelopeCreateError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
