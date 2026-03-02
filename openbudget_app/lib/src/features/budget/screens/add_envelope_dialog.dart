import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddEnvelopeDialog extends HookConsumerWidget {
  const AddEnvelopeDialog({
    required this.categoryId,
    required this.budgetId,
    required this.currencyCode,
    required this.year,
    required this.month,
    super.key,
  });

  final String categoryId;
  final String budgetId;
  final CurrencyCode currencyCode;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nameController = useTextEditingController();
    final amountInput = useState('');
    final isSubmitting = useState(false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(
        l10n.budgetAddEnvelope,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
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
          BudgetAmountField(
            labelText: l10n.budgetEnvelopeAmountLabel,
            currencyCode: currencyCode,
            inputValue: amountInput.value,
            hintText: formatBudgetAmountInputForField(
              input: '0',
              currencyCode: currencyCode,
            ),
            prefixIcon: const Icon(Icons.payments_outlined),
            enabled: !isSubmitting.value,
            onTap: () async {
              final nextInput = await showBudgetAmountKeypadSheet(
                context: context,
                currencyCode: currencyCode,
                initialInput: amountInput.value,
                title: l10n.budgetEnvelopeAmountLabel,
              );
              if (nextInput != null) {
                amountInput.value = nextInput;
              }
            },
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
                  amountInput.value,
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
    String amountInput,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final amountCents =
        parseBudgetAmountInputToCents(
          input: amountInput,
          currencyCode: currencyCode,
        ) ??
        0;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      final envelope = await ref
          .read(envelopeActionsProvider.notifier)
          .createEnvelope(
            name: name,
            categoryId: categoryId,
            budgetedAmountCents: amountCents,
            currencyCode: currencyCode.code,
            budgetId: budgetId,
          );
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .upsertAllocation(
            envelopeId: envelope.id?.toString() ?? '',
            budgetId: budgetId,
            year: year,
            month: month,
            allocatedCents: amountCents,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetEnvelopeCreated,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetEnvelopeCreateError,
        variant: AppToastVariant.error,
      );
    }
  }
}
