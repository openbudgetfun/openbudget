import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Sets one envelope's goal: one [EnvelopeGoalKind] and one amount, plus a
/// target date for `targetByDate`.
class SetGoalDialog extends HookConsumerWidget {
  const SetGoalDialog({
    required this.monthEnvelope,
    required this.entityId,
    required this.currencyCode,
    required this.month,
    super.key,
  });

  /// The envelope and its month figures; carries the existing goal.
  final EnvelopeMonthView monthEnvelope;
  final String entityId;
  final String currencyCode;

  /// The month being budgeted, as yyyymm.
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final existingGoal = monthEnvelope.goal;
    final initialKind = existingGoal?.kind ?? EnvelopeGoalKind.monthlyFunding;
    final kind = useState(initialKind);
    final amountInput = useState(
      existingGoal != null
          ? budgetAmountInputFromMinor(
              minor: existingGoal.amountMinor,
              currencyCode: currencyCode,
            )
          : '',
    );
    final dueDate = useState<DateTime>(
      existingGoal?.targetDate ??
          DateTime(
            month ~/ 100 + (month % 100 == 12 ? 1 : 0),
            month % 100 == 12 ? 1 : month % 100 + 1,
          ).add(const Duration(days: 30)),
    );
    final isSubmitting = useState(false);
    final amountMinor =
        parseBudgetAmountInputToMinor(
          input: amountInput.value,
          currencyCode: currencyCode,
        ) ??
        0;
    final canSave = amountMinor > 0;

    final palette = Theme.of(context).ob;

    return Dialog.fullscreen(
      backgroundColor: palette.canvas,
      child: Scaffold(
        backgroundColor: palette.canvas,
        appBar: AppBar(
          backgroundColor: palette.canvas,
          surfaceTintColor: palette.canvas,
          leadingWidth: 96,
          leading: TextButton(
            onPressed: isSubmitting.value
                ? null
                : () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.flag,
                size: 16,
                color: palette.brand,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Flexible(
                child: Text(
                  monthEnvelope.envelope.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.lg,
            ),
            children: [
              _GoalCard(
                child: Column(
                  children: [
                    SegmentedButton<EnvelopeGoalKind>(
                      segments: [
                        ButtonSegment(
                          value: EnvelopeGoalKind.monthlyFunding,
                          label: Text(l10n.setGoalCadenceMonthly),
                          icon: const SkribbleIcon(
                            data: OpenBudgetIcons.recurring,
                            size: 16,
                          ),
                        ),
                        ButtonSegment(
                          value: EnvelopeGoalKind.targetBalance,
                          label: Text(l10n.setGoalTargetBalanceLabel),
                          icon: const SkribbleIcon(
                            data: OpenBudgetIcons.flag,
                            size: 16,
                          ),
                        ),
                        ButtonSegment(
                          value: EnvelopeGoalKind.targetByDate,
                          label: Text(l10n.setGoalCadenceCustom),
                          icon: const SkribbleIcon(
                            data: OpenBudgetIcons.calendarMonth,
                            size: 16,
                          ),
                        ),
                      ],
                      selected: {kind.value},
                      onSelectionChanged: (selection) =>
                          kind.value = selection.first,
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      child: BudgetAmountField(
                        labelText: l10n.setGoalAmount,
                        currencyCode: currencyCode,
                        inputValue: amountInput.value,
                        hintText: formatBudgetAmountInputForField(
                          input: '0',
                          currencyCode: currencyCode,
                        ),
                        prefixIcon: ObFieldIcon(
                          data: OpenBudgetIcons.payment,
                          color: palette.brand,
                        ),
                        enabled: !isSubmitting.value,
                        onTap: () async {
                          final nextInput = await showBudgetAmountKeypadSheet(
                            context: context,
                            currencyCode: currencyCode,
                            initialInput: amountInput.value,
                            title: l10n.setGoalAmount,
                            allowNegative: false,
                          );
                          if (nextInput != null) {
                            amountInput.value = nextInput;
                          }
                        },
                      ),
                    ),
                    if (kind.value == EnvelopeGoalKind.targetByDate) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: SkribbleIcon(
                          data: OpenBudgetIcons.event,
                          color: palette.brand,
                        ),
                        title: Text(l10n.setGoalDueOn),
                        subtitle: Text(
                          DateFormat.yMMMd().format(dueDate.value),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: dueDate.value,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dueDate.value = picked;
                          }
                        },
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: SkribbleIcon(
                        data: kind.value == EnvelopeGoalKind.monthlyFunding
                            ? OpenBudgetIcons.recurring
                            : OpenBudgetIcons.adjust,
                        color: palette.brand,
                      ),
                      title: Text(
                        kind.value == EnvelopeGoalKind.monthlyFunding
                            ? l10n.setGoalSetAsideMonthlyLabel
                            : kind.value == EnvelopeGoalKind.targetBalance
                            ? l10n.setGoalTargetBalanceLabel
                            : l10n.setGoalTargetByDateLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                      subtitle: Text(
                        kind.value == EnvelopeGoalKind.monthlyFunding
                            ? l10n.setGoalSetAsideAnother(
                                formatMinorForCode(amountMinor, currencyCode),
                              )
                            : l10n.setGoalHaveAmount(
                                formatMinorForCode(amountMinor, currencyCode),
                              ),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.md,
          ),
          child: Row(
            children: [
              if (existingGoal != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting.value
                        ? null
                        : () => _deleteGoal(context, ref, existingGoal, isSubmitting),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.overspent,
                    ),
                    child: Text(l10n.goalRemove),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: !canSave || isSubmitting.value
                      ? null
                      : () => _submit(
                          context,
                          ref,
                          kind: kind.value,
                          amountMinor: amountMinor,
                          dueDate: dueDate.value,
                          isSubmitting: isSubmitting,
                        ),
                  icon: isSubmitting.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SkribbleIcon(data: OpenBudgetIcons.checkCircle),
                  label: Text(l10n.setGoalSaveTarget),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref, {
    required EnvelopeGoalKind kind,
    required int amountMinor,
    required DateTime dueDate,
    required ValueNotifier<bool> isSubmitting,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (amountMinor <= 0) return;
    isSubmitting.value = true;
    final navigator = Navigator.of(context);

    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .upsertGoal(
            envelopeId: monthEnvelope.envelope.id?.toString() ?? '',
            kind: kind,
            amountMinor: amountMinor,
            targetDate: kind == EnvelopeGoalKind.targetByDate ? dueDate : null,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.goalSaved,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.goalError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    EnvelopeGoal existingGoal,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .deleteGoal(goalId: existingGoal.id?.toString() ?? '');
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.goalRemoved,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.goalError,
        variant: AppToastVariant.error,
      );
    }
  }
}

class _GoalCard extends HookWidget {
  const _GoalCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ObCard(child: child);
}
