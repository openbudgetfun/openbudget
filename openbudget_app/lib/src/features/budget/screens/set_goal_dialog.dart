import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _GoalCadence { weekly, monthly, yearly, custom }

enum _RepeatUnit { month, year }

class SetGoalDialog extends HookConsumerWidget {
  const SetGoalDialog({
    required this.envelopeId,
    required this.budgetId,
    required this.currencyCode,
    this.existingGoal,
    this.envelopeName = '',
    super.key,
  });

  final String envelopeId;
  final String budgetId;
  final CurrencyCode currencyCode;
  final EnvelopeGoal? existingGoal;
  final String envelopeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final initialCadence = _initialCadence(existingGoal);
    final cadence = useState(initialCadence);
    final dueDay = useState<int?>(null);
    final amountInput = useState(
      existingGoal != null
          ? budgetAmountInputFromCents(
              cents:
                  existingGoal!.monthlyFundingCents ??
                  existingGoal!.targetAmountCents,
              currencyCode: currencyCode,
            )
          : '',
    );
    final dueDate = useState<DateTime>(
      existingGoal?.targetDate ?? DateTime.now().add(const Duration(days: 30)),
    );
    final repeats = useState(
      initialCadence == _GoalCadence.custom &&
          existingGoal?.goalType == 'monthly_funding',
    );
    final repeatEvery = useState(1);
    final repeatUnit = useState(_RepeatUnit.month);
    final isSubmitting = useState(false);
    final amountCents =
        parseBudgetAmountInputToCents(
          input: amountInput.value,
          currencyCode: currencyCode,
        ) ??
        0;
    final canSave = amountCents > 0;
    final monthlyContribution = _monthlyContributionFor(
      cadence.value,
      amountCents,
      repeatEvery.value,
      repeatUnit.value,
    );

    return Dialog.fullscreen(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      child: Scaffold(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        appBar: AppBar(
          backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
          surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
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
              Icon(
                Icons.flag_rounded,
                size: 16,
                color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                envelopeName.isEmpty ? l10n.goalSetTitle : envelopeName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                    SegmentedButton<_GoalCadence>(
                      segments: const [
                        ButtonSegment(
                          value: _GoalCadence.weekly,
                          label: Text('Weekly'),
                        ),
                        ButtonSegment(
                          value: _GoalCadence.monthly,
                          label: Text('Monthly'),
                        ),
                        ButtonSegment(
                          value: _GoalCadence.yearly,
                          label: Text('Yearly'),
                        ),
                        ButtonSegment(
                          value: _GoalCadence.custom,
                          label: Text('Custom'),
                        ),
                      ],
                      selected: {cadence.value},
                      onSelectionChanged: (selection) {
                        cadence.value = selection.first;
                        if (selection.first != _GoalCadence.custom) {
                          repeats.value = false;
                        }
                      },
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      child: BudgetAmountField(
                        labelText: cadence.value == _GoalCadence.custom
                            ? 'Amount'
                            : 'I need',
                        currencyCode: currencyCode,
                        inputValue: amountInput.value,
                        hintText: formatBudgetAmountInputForField(
                          input: '0',
                          currencyCode: currencyCode,
                        ),
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                        enabled: !isSubmitting.value,
                        onTap: () async {
                          final nextInput = await showBudgetAmountKeypadSheet(
                            context: context,
                            currencyCode: currencyCode,
                            initialInput: amountInput.value,
                            title: 'Amount',
                            allowNegative: false,
                          );
                          if (nextInput != null) {
                            amountInput.value = nextInput;
                          }
                        },
                      ),
                    ),
                    if (cadence.value != _GoalCadence.custom) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.md,
                          vertical: SpacingTokens.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: OpenBudgetPalette.bgBrandFor(
                                Theme.of(context),
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'By',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color:
                                              OpenBudgetPalette.fgSecondaryFor(
                                                Theme.of(context),
                                              ),
                                        ),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<int?>(
                                      value: dueDay.value,
                                      isDense: true,
                                      isExpanded: true,
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          child: Text('Last Day of the Month'),
                                        ),
                                        for (var day = 31; day >= 1; day--)
                                          DropdownMenuItem<int?>(
                                            value: day,
                                            child: Text(_ordinalDay(day)),
                                          ),
                                      ],
                                      onChanged: (value) =>
                                          dueDay.value = value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.repeat_rounded,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                        title: Text(
                          'Next month I want to',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                        ),
                        subtitle: Text(
                          'Set aside another ${_formatCents(monthlyContribution, currencyCode)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ] else ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.adjust_rounded,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                        title: Text(
                          'I want to',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                        ),
                        subtitle: Text(
                          'Set aside another ${_formatCents(amountCents, currencyCode)}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ],
                ),
              ),
              if (cadence.value == _GoalCadence.custom) ...[
                const SizedBox(height: SpacingTokens.md),
                _GoalCard(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.event_outlined,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                        title: const Text('Due on'),
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
                      const Divider(height: 1),
                      SwitchListTile.adaptive(
                        secondary: Icon(
                          Icons.repeat_rounded,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                        title: const Text('Repeats'),
                        value: repeats.value,
                        onChanged: (value) => repeats.value = value,
                      ),
                      if (repeats.value) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpacingTokens.md,
                            SpacingTokens.sm,
                            SpacingTokens.md,
                            SpacingTokens.md,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: OpenBudgetPalette.bgBrandFor(
                                  Theme.of(context),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Every',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color:
                                                OpenBudgetPalette.fgSecondaryFor(
                                                  Theme.of(context),
                                                ),
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        DropdownButton<int>(
                                          value: repeatEvery.value,
                                          items: [
                                            for (var i = 1; i <= 12; i++)
                                              DropdownMenuItem<int>(
                                                value: i,
                                                child: Text('$i'),
                                              ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              repeatEvery.value = value;
                                            }
                                          },
                                        ),
                                        const SizedBox(width: SpacingTokens.sm),
                                        DropdownButton<_RepeatUnit>(
                                          value: repeatUnit.value,
                                          items: const [
                                            DropdownMenuItem(
                                              value: _RepeatUnit.month,
                                              child: Text('Month'),
                                            ),
                                            DropdownMenuItem(
                                              value: _RepeatUnit.year,
                                              child: Text('Year'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              repeatUnit.value = value;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                        : () => _deleteGoal(context, ref, isSubmitting),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OpenBudgetPalette.fgErrorFor(
                        Theme.of(context),
                      ),
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
                          cadence: cadence.value,
                          amountCents: amountCents,
                          dueDate: dueDate.value,
                          repeats: repeats.value,
                          repeatEvery: repeatEvery.value,
                          repeatUnit: repeatUnit.value,
                          isSubmitting: isSubmitting,
                        ),
                  icon: isSubmitting.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: const Text('Save Target'),
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
    required _GoalCadence cadence,
    required int amountCents,
    required DateTime dueDate,
    required bool repeats,
    required int repeatEvery,
    required _RepeatUnit repeatUnit,
    required ValueNotifier<bool> isSubmitting,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (amountCents <= 0) return;
    isSubmitting.value = true;
    final navigator = Navigator.of(context);

    final payload = _buildGoalPayload(
      cadence: cadence,
      amountCents: amountCents,
      dueDate: dueDate,
      repeats: repeats,
      repeatEvery: repeatEvery,
      repeatUnit: repeatUnit,
    );

    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .upsertGoal(
            envelopeId: envelopeId,
            goalType: payload.goalType,
            targetAmountCents: payload.targetAmountCents,
            budgetId: budgetId,
            targetDate: payload.targetDate,
            monthlyFundingCents: payload.monthlyFundingCents,
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
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(envelopeGoalActionsProvider.notifier)
          .deleteGoal(
            goalId: existingGoal!.id?.toString() ?? '',
            envelopeId: envelopeId,
            budgetId: budgetId,
          );
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

  String _formatCents(int cents, CurrencyCode currency) {
    final divisor = _pow10(currency.decimals);
    final value = cents / divisor;
    return value.toStringAsFixed(currency.decimals);
  }

  _GoalCadence _initialCadence(EnvelopeGoal? goal) {
    if (goal == null) return _GoalCadence.monthly;
    return switch (goal.goalType) {
      'target_by_date' => _GoalCadence.custom,
      _ => _GoalCadence.monthly,
    };
  }

  int _monthlyContributionFor(
    _GoalCadence cadence,
    int amountCents,
    int repeatEvery,
    _RepeatUnit repeatUnit,
  ) {
    return switch (cadence) {
      _GoalCadence.weekly => ((amountCents * 52) / 12).round(),
      _GoalCadence.monthly => amountCents,
      _GoalCadence.yearly => (amountCents / 12).round(),
      _GoalCadence.custom => switch (repeatUnit) {
        _RepeatUnit.month => (amountCents / repeatEvery).round(),
        _RepeatUnit.year => (amountCents / (repeatEvery * 12)).round(),
      },
    };
  }

  _GoalPayload _buildGoalPayload({
    required _GoalCadence cadence,
    required int amountCents,
    required DateTime dueDate,
    required bool repeats,
    required int repeatEvery,
    required _RepeatUnit repeatUnit,
  }) {
    if (cadence == _GoalCadence.custom && !repeats) {
      return _GoalPayload(
        goalType: 'target_by_date',
        targetAmountCents: amountCents,
        targetDate: dueDate,
      );
    }

    final monthlyFunding = _monthlyContributionFor(
      cadence,
      amountCents,
      repeatEvery,
      repeatUnit,
    );
    return _GoalPayload(
      goalType: 'monthly_funding',
      targetAmountCents: amountCents,
      monthlyFundingCents: monthlyFunding,
      targetDate: cadence == _GoalCadence.custom ? dueDate : null,
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

String _ordinalDay(int day) {
  final suffix = switch (day % 10) {
    1 when day % 100 != 11 => 'st',
    2 when day % 100 != 12 => 'nd',
    3 when day % 100 != 13 => 'rd',
    _ => 'th',
  };
  return '$day$suffix';
}

class _GoalPayload {
  const _GoalPayload({
    required this.goalType,
    required this.targetAmountCents,
    this.targetDate,
    this.monthlyFundingCents,
  });

  final String goalType;
  final int targetAmountCents;
  final DateTime? targetDate;
  final int? monthlyFundingCents;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      child: child,
    );
  }
}
