import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditEnvelopeDialog extends HookConsumerWidget {
  const EditEnvelopeDialog({
    required this.envelope,
    required this.categoryId,
    required this.budgetId,
    required this.currencyCode,
    required this.year,
    required this.month,
    super.key,
  });

  final Envelope envelope;
  final String categoryId;
  final String budgetId;
  final CurrencyCode currencyCode;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nameController = useTextEditingController(text: envelope.name);
    final amountController = useTextEditingController(
      text: _formatInitialAmount(envelope.budgetedAmountCents, currencyCode),
    );
    final noteController = useTextEditingController(text: envelope.note ?? '');
    final isSubmitting = useState(false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(
        l10n.editEnvelopeTitle,
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
                    noteController,
                    isSubmitting,
                  ),
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: noteController,
            decoration: InputDecoration(
              labelText: l10n.envelopeNoteLabel,
              hintText: l10n.envelopeNoteHint,
              prefixIcon: const Icon(Icons.note_outlined),
            ),
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: SpacingTokens.md),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _showGoalDialog(context, ref);
            },
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: Text(l10n.goalSetGoal),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting.value
              ? null
              : () => _delete(context, ref, isSubmitting),
          child: Text(
            l10n.deleteConfirmButton,
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
                  nameController,
                  amountController,
                  noteController,
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

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"${envelope.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    isSubmitting.value = true;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .deleteEnvelope(
            envelopeId: envelope.id?.toString() ?? '',
            categoryId: categoryId,
            budgetId: budgetId,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
      if (context.mounted) Navigator.of(context).pop();
    } on Exception {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.deleteError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController amountController,
    TextEditingController noteController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    final amountCents = (amount * _pow10(currencyCode.decimals)).round();
    final note = noteController.text.trim();

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .updateEnvelope(
            envelopeId: envelope.id?.toString() ?? '',
            categoryId: categoryId,
            budgetId: budgetId,
            name: name,
            budgetedAmountCents: amountCents,
            note: note.isEmpty ? null : note,
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.editEnvelopeSaved)));
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.editEnvelopeError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.read(
      envelopeGoalProvider(envelope.id?.toString() ?? ''),
    );
    final existingGoal = goalAsync.whenOrNull(data: (g) => g);

    showDialog<void>(
      context: context,
      builder: (_) => SetGoalDialog(
        envelopeId: envelope.id?.toString() ?? '',
        budgetId: budgetId,
        currencyCode: currencyCode,
        existingGoal: existingGoal,
        envelopeName: envelope.name,
      ),
    );
  }

  String _formatInitialAmount(int cents, CurrencyCode currency) {
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
