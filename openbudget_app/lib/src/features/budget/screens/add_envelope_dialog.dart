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

    return WiredDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.budgetAddEnvelope,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          WiredInput(
            controller: nameController,
            hintText: l10n.budgetEnvelopeNameLabel,
          ),
          const SizedBox(height: 12),
          WiredInput(
            controller: amountController,
            hintText: l10n.budgetEnvelopeAmountLabel,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WiredButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.dialogCancel),
              ),
              const SizedBox(width: 12),
              WiredButton(
                onPressed: isSubmitting.value
                    ? () {}
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;

                        final amountText = amountController.text.trim();
                        final amount = double.tryParse(amountText) ?? 0;
                        final amountCents =
                            (amount * _pow10(currencyCode.decimals)).round();

                        isSubmitting.value = true;
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
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.budgetEnvelopeCreated),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } on Exception catch (_) {
                          isSubmitting.value = false;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.budgetEnvelopeCreateError),
                                backgroundColor: ColorTokens.error,
                              ),
                            );
                          }
                        }
                      },
                child: Text(
                  isSubmitting.value ? l10n.dialogSaving : l10n.dialogSave,
                ),
              ),
            ],
          ),
        ],
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
