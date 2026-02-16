import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SetGoalDialog extends HookConsumerWidget {
  const SetGoalDialog({
    required this.envelopeId,
    required this.budgetId,
    required this.currencyCode,
    this.existingGoal,
    super.key,
  });

  final String envelopeId;
  final String budgetId;
  final CurrencyCode currencyCode;
  final EnvelopeGoal? existingGoal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final goalType = useState(existingGoal?.goalType ?? 'target_balance');
    final amountController = useTextEditingController(
      text: existingGoal != null
          ? _formatCents(existingGoal!.targetAmountCents, currencyCode)
          : '',
    );
    final targetDate = useState<DateTime?>(existingGoal?.targetDate);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.goalSetTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.goalTypeLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: SpacingTokens.sm),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'target_balance',
                  label: Text(l10n.goalTypeBalance),
                ),
                ButtonSegment(
                  value: 'target_by_date',
                  label: Text(l10n.goalTypeByDate),
                ),
                ButtonSegment(
                  value: 'monthly_funding',
                  label: Text(l10n.goalTypeMonthly),
                ),
              ],
              selected: {goalType.value},
              onSelectionChanged: (selected) => goalType.value = selected.first,
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: l10n.goalAmountLabel,
                prefixText: '${currencyCode.symbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            if (goalType.value == 'target_by_date') ...[
              const SizedBox(height: SpacingTokens.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.goalDateLabel),
                subtitle: Text(
                  targetDate.value != null
                      ? '${targetDate.value!.year}-${targetDate.value!.month.toString().padLeft(2, '0')}-${targetDate.value!.day.toString().padLeft(2, '0')}'
                      : l10n.goalDateSelect,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: targetDate.value ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    targetDate.value = picked;
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (existingGoal != null)
          TextButton(
            onPressed: isSubmitting.value
                ? null
                : () => _deleteGoal(context, ref, isSubmitting),
            child: Text(
              l10n.goalRemove,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
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
                  goalType,
                  targetDate,
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
    TextEditingController amountController,
    ValueNotifier<String> goalType,
    ValueNotifier<DateTime?> targetDate,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    final amountCents = (amount * _pow10(currencyCode.decimals)).round();

    if (amountCents <= 0) return;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .upsertGoal(
            envelopeId: envelopeId,
            goalType: goalType.value,
            targetAmountCents: amountCents,
            budgetId: budgetId,
            targetDate: goalType.value == 'target_by_date'
                ? targetDate.value
                : null,
            monthlyFundingCents: goalType.value == 'monthly_funding'
                ? amountCents
                : null,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.goalSaved)));
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.goalError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .deleteGoal(
            goalId: existingGoal!.id?.toString() ?? '',
            envelopeId: envelopeId,
            budgetId: budgetId,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.goalRemoved)));
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.goalError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  String _formatCents(int cents, CurrencyCode currency) {
    final divisor = _pow10(currency.decimals);
    final value = cents / divisor;
    return value.toStringAsFixed(currency.decimals);
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
