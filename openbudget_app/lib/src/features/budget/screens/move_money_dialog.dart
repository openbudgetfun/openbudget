import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Moves money between envelopes, or from Ready to Assign into one. Sends
/// one `budget.moveMoney`; a null envelope id means Ready to Assign.
class MoveMoneyDialog extends HookConsumerWidget {
  const MoveMoneyDialog({
    required this.entityId,
    required this.currencyCode,
    required this.groups,
    super.key,
  });

  final String entityId;
  final String currencyCode;
  final List<CategoryMonthGroup> groups;

  /// The dropdown sentinel for Ready to Assign, which `moveMoney` takes as
  /// a null envelope id.
  static const _readyToAssign = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final amountInput = useState('');
    final fromEnvelopeId = useState<String?>(null);
    final toEnvelopeId = useState<String?>(null);
    final isSubmitting = useState(false);

    // Ready to Assign first, then every envelope under its category label.
    final envelopeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: _readyToAssign,
        child: Text(l10n.budgetReadyToAssign),
      ),
      for (final group in groups)
        for (final view in group.envelopes)
          DropdownMenuItem(
            value: view.envelope.id?.toString() ?? '',
            child: Text('${group.category.name} > ${view.envelope.name}'),
          ),
    ];

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
                prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.outflow),
              ),
              items: envelopeItems,
              onChanged: (v) => fromEnvelopeId.value = v,
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              initialValue: toEnvelopeId.value,
              decoration: InputDecoration(
                labelText: l10n.moveMoneyTo,
                prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.inflow),
              ),
              items: envelopeItems,
              onChanged: (v) => toEnvelopeId.value = v,
            ),
            const SizedBox(height: SpacingTokens.md),
            BudgetAmountField(
              labelText: '${l10n.transactionAmountLabel} ($currencyCode)',
              currencyCode: currencyCode,
              inputValue: amountInput.value,
              hintText: formatBudgetAmountInputForField(
                input: '0',
                currencyCode: currencyCode,
              ),
              prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.payment),
              enabled: !isSubmitting.value,
              onTap: () async {
                final nextInput = await showBudgetAmountKeypadSheet(
                  context: context,
                  currencyCode: currencyCode,
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
                  fromEnvelopeId.value,
                  toEnvelopeId.value,
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
    String? fromEnvelopeId,
    String? toEnvelopeId,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (fromEnvelopeId == null || toEnvelopeId == null) return;
    if (fromEnvelopeId == toEnvelopeId) {
      showAppToast(
        context,
        message: l10n.moveMoneySameError,
        variant: AppToastVariant.error,
      );
      return;
    }

    final amountMinor =
        parseBudgetAmountInputToMinor(
          input: amountInput,
          currencyCode: currencyCode,
        ) ??
        0;
    if (amountMinor <= 0) return;
    isSubmitting.value = true;

    try {
      await ref
          .read(budgetMonthActionsProvider.notifier)
          .moveMoney(
            entityId: entityId,
            fromEnvelopeId: fromEnvelopeId == _readyToAssign
                ? null
                : fromEnvelopeId,
            toEnvelopeId: toEnvelopeId == _readyToAssign ? null : toEnvelopeId,
            amountMinor: amountMinor,
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
