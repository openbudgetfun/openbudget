import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum RecurringViewFilter { all, expenses, income, due }

/// Scheduled bills and income, written on a stack of paper slips.
class RecurringListScreen extends HookConsumerWidget {
  const RecurringListScreen({required this.entityId, super.key});

  /// Opens the add-recurring dialog.
  static const Key addButtonKey = ValueKey('recurring.add');

  /// Opens the schedule calendar.
  static const Key calendarButtonKey = ValueKey('recurring.calendar');

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recurringAsync = ref.watch(recurringListProvider(entityId));
    final currencyAsync = ref.watch(budgetMonthCurrencyProvider(entityId));
    final viewFilter = useState(RecurringViewFilter.all);
    final budgetCurrency = currencyAsync.value ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringListTitle),
        actions: [
          IconButton(
            key: calendarButtonKey,
            icon: const SkribbleIcon(data: OpenBudgetIcons.calendarMonth),
            tooltip: l10n.scheduledCalendarTitle,
            onPressed: () => context.pushNamed(
              recurringCalendarRoute,
              pathParameters: {'entityId': entityId},
            ),
          ),
          IconButton(
            key: addButtonKey,
            icon: const SkribbleIcon(data: OpenBudgetIcons.add),
            tooltip: l10n.recurringAddButton,
            onPressed: () => _showAddDialog(context, budgetCurrency),
          ),
        ],
      ),
      body: recurringAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.recurringLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.recurringLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                ObStatePanel.empty(
                  title: l10n.recurringEmptyTitle,
                  message: l10n.recurringEmptySubtitle,
                  doodle: WiredDoodleKind.sun,
                  action: ObStateAction(
                    label: l10n.recurringAddButton,
                    onPressed: () => _showAddDialog(context, budgetCurrency),
                  ),
                ),
              ],
            );
          }

          final accountsAsync = ref.watch(accountListProvider(entityId));
          final currencyByAccount = {
            for (final account in accountsAsync.value ?? const <Account>[])
              if (account.id != null)
                account.id!.toString(): account.currencyCode,
          };
          String currencyOf(RecurringTransaction item) =>
              currencyByAccount[item.accountId.toString()] ?? budgetCurrency;

          final now = DateTime.now();
          final activeItems = items.where((item) => item.isActive).toList();
          final dueCount = activeItems.where((item) {
            final dueDate = DateTime(
              item.nextDate.year,
              item.nextDate.month,
              item.nextDate.day,
            );
            final today = DateTime(now.year, now.month, now.day);
            return !dueDate.isAfter(today);
          }).length;
          final expenseTotals = aggregateMinorByCurrency(
            activeItems.where((item) => item.amountMinor < 0),
            currencyCodeOf: currencyOf,
            amountMinorOf: (item) => item.amountMinor.abs(),
          );
          final incomeTotals = aggregateMinorByCurrency(
            activeItems.where((item) => item.amountMinor > 0),
            currencyCodeOf: currencyOf,
            amountMinorOf: (item) => item.amountMinor,
          );
          final filteredItems = items
              .where(
                (item) => switch (viewFilter.value) {
                  RecurringViewFilter.all => true,
                  RecurringViewFilter.expenses => item.amountMinor < 0,
                  RecurringViewFilter.income => item.amountMinor > 0,
                  RecurringViewFilter.due =>
                    item.isActive && !item.nextDate.isAfter(now),
                },
              )
              .toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(recurringListProvider(entityId)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.xl,
              ),
              children: [
                _RecurringSummaryCard(
                  totalItems: items.length,
                  dueCount: dueCount,
                  totalExpenses: expenseTotals.isEmpty
                      ? formatMinorForCode(0, budgetCurrency)
                      : formatCurrencyBreakdown(
                          expenseTotals,
                          includeCurrencyCode: expenseTotals.length > 1,
                        ),
                  totalIncome: incomeTotals.isEmpty
                      ? formatMinorForCode(0, budgetCurrency)
                      : formatCurrencyBreakdown(
                          incomeTotals,
                          includeCurrencyCode: incomeTotals.length > 1,
                        ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Wrap(
                  spacing: SpacingTokens.sm,
                  runSpacing: SpacingTokens.sm,
                  children: [
                    _RecurringFilterChip(
                      label: l10n.transactionFilterAll,
                      selected: viewFilter.value == RecurringViewFilter.all,
                      onTap: () => viewFilter.value = RecurringViewFilter.all,
                    ),
                    _RecurringFilterChip(
                      label: l10n.transactionFilterExpense,
                      selected:
                          viewFilter.value == RecurringViewFilter.expenses,
                      onTap: () =>
                          viewFilter.value = RecurringViewFilter.expenses,
                    ),
                    _RecurringFilterChip(
                      label: l10n.transactionFilterIncome,
                      selected: viewFilter.value == RecurringViewFilter.income,
                      onTap: () =>
                          viewFilter.value = RecurringViewFilter.income,
                    ),
                    _RecurringFilterChip(
                      label: l10n.recurringDueLabel,
                      selected: viewFilter.value == RecurringViewFilter.due,
                      onTap: () => viewFilter.value = RecurringViewFilter.due,
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.md),
                if (filteredItems.isEmpty)
                  ObStatePanel.empty(
                    title: l10n.transactionNoResults,
                    doodle: WiredDoodleKind.scribble,
                    tone: ObTone.neutral,
                  ),
                ...filteredItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                    child: _RecurringTile(
                      recurring: item,
                      currencyCode: currencyOf(item),
                      onEdit: () =>
                          _showEditDialog(context, item, currencyOf(item)),
                      onDelete: () => _confirmDelete(context, ref, item),
                      onToggle: () => _toggleActive(ref, item),
                      onSkip: () => _skipOccurrence(context, ref, item),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, String currencyCode) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) =>
            _AddRecurringDialog(entityId: entityId, currencyCode: currencyCode),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    RecurringTransaction recurring,
    String currencyCode,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => _EditRecurringDialog(
          recurring: recurring,
          entityId: entityId,
          currencyCode: currencyCode,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction recurring,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n"${recurring.description}"',
        ),
        actions: [
          ObTextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          ObFilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .deleteRecurring(
            recurringId: recurring.id?.toString() ?? '',
            entityId: entityId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _skipOccurrence(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction recurring,
  ) async {
    final l10n = AppLocalizations.of(context);

    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .skipOccurrence(
            recurringId: recurring.id?.toString() ?? '',
            entityId: entityId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.recurringSkipSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.recurringSkipError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _toggleActive(
    WidgetRef ref,
    RecurringTransaction recurring,
  ) async {
    await ref
        .read(recurringActionsProvider.notifier)
        .updateRecurring(
          recurringId: recurring.id?.toString() ?? '',
          entityId: entityId,
          isActive: !recurring.isActive,
        );
  }
}

class _RecurringSummaryCard extends HookWidget {
  const _RecurringSummaryCard({
    required this.totalItems,
    required this.dueCount,
    required this.totalExpenses,
    required this.totalIncome,
  });

  final int totalItems;
  final int dueCount;
  final String totalExpenses;
  final String totalIncome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: ObRoughDecoration(
                    color: palette.brandWash,
                    outline: palette.quietPen,
                    radius: 10,
                    strokeWidth: 1.6,
                    seed: 5,
                  ),
                  child: Center(
                    child: SkribbleIcon(
                      data: OpenBudgetIcons.recurring,
                      size: 20,
                      color: palette.brand,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recurringSummaryTitle,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      l10n.recurringTotalCount(totalItems),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              if (dueCount > 0)
                ObToneChip(
                  label: l10n.recurringDueLabel,
                  tone: ObTone.overspent,
                  icon: const SkribbleIcon(
                    data: OpenBudgetIcons.schedule,
                    size: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: l10n.transactionFilterExpense,
                  value: totalExpenses,
                  tone: ObTone.overspent,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.transactionFilterIncome,
                  value: totalIncome,
                  tone: ObTone.funded,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _SummaryMetric(
                  label: l10n.recurringDueLabel,
                  value: '$dueCount',
                  tone: ObTone.underfunded,
                  isMoney: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends HookWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.tone,
    this.isMoney = true,
  });

  final String label;
  final String value;
  final ObTone tone;
  final bool isMoney;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
        const SizedBox(height: 2),
        if (isMoney)
          ObAmount(
            value,
            tone: tone,
            style: theme.textTheme.titleSmall,
          )
        else
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.hue(tone),
            ),
          ),
      ],
    );
  }
}

class _RecurringFilterChip extends HookWidget {
  const _RecurringFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}

class _RecurringTile extends HookWidget {
  const _RecurringTile({
    required this.recurring,
    required this.currencyCode,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onSkip,
  });

  final RecurringTransaction recurring;

  /// The account's currency; the recurring transaction carries no currency
  /// of its own.
  final String currencyCode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currency = normalizeCurrencyCode(currencyCode);
    final isIncome = recurring.amountMinor > 0;
    final frequencyLabel = switch (recurring.frequency) {
      RecurrenceFrequency.daily => l10n.recurringFreqDaily,
      RecurrenceFrequency.weekly => l10n.recurringFreqWeekly,
      RecurrenceFrequency.biweekly => l10n.recurringFreqBiweekly,
      RecurrenceFrequency.monthly => l10n.recurringFreqMonthly,
      RecurrenceFrequency.yearly => l10n.recurringFreqYearly,
    };

    final nextDate = recurring.nextDate;
    final isDue = recurring.isActive && !nextDate.isAfter(DateTime.now());
    final dateStr =
        '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(recurring.id),
      direction: DismissDirection.endToStart,
      background: DecoratedBox(
        decoration: ObRoughDecoration(
          color: palette.overspentWash,
          outline: palette.overspent,
          seed: 17,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.md),
            child: SkribbleIcon(
              data: OpenBudgetIcons.delete,
              color: palette.overspent,
            ),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ObCard(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.sm,
          SpacingTokens.md,
          SpacingTokens.xs,
        ),
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(
                  dimension: 40,
                  child: DecoratedBox(
                    decoration: ObRoughDecoration(
                      color: recurring.isActive
                          ? palette.brandWash
                          : palette.highlight,
                      outline: palette.quietPen,
                      radius: 10,
                      strokeWidth: 1.6,
                      seed: 19,
                    ),
                    child: Center(
                      child: SkribbleIcon(
                        data: OpenBudgetIcons.recurring,
                        size: 20,
                        color: recurring.isActive
                            ? palette.brand
                            : palette.mutedInk,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recurring.description,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.ink,
                          decoration: recurring.isActive
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '$frequencyLabel \u2022 ${l10n.recurringNextDate}: $dateStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                ObAmount(
                  isIncome
                      ? '+${formatMinorForCode(recurring.amountMinor, currency)}'
                      : formatMinorForCode(recurring.amountMinor, currency),
                  tone: isIncome ? ObTone.funded : ObTone.overspent,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.xs,
              children: [
                Semantics(
                  label: l10n.recurringActiveLabel,
                  child: Switch.adaptive(
                    value: recurring.isActive,
                    onChanged: (_) => onToggle(),
                  ),
                ),
                if (!recurring.isActive)
                  ObToneChip(
                    label: l10n.recurringPausedLabel,
                    icon: const SkribbleIcon(
                      data: OpenBudgetIcons.snooze,
                      size: 14,
                    ),
                  ),
                if (isDue)
                  ObToneChip(
                    label: l10n.recurringDueLabel,
                    tone: ObTone.overspent,
                    icon: const SkribbleIcon(
                      data: OpenBudgetIcons.schedule,
                      size: 14,
                    ),
                  ),
                if (isDue)
                  ObTextButton(
                    onPressed: onSkip,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SkribbleIcon(
                          data: OpenBudgetIcons.skip,
                          size: 18,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(l10n.recurringSkipButton),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRecurringDialog extends HookConsumerWidget {
  const _AddRecurringDialog({
    required this.entityId,
    required this.currencyCode,
  });

  final String entityId;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descController = useTextEditingController();
    final amountController = useTextEditingController();
    final frequency = useState(RecurrenceFrequency.monthly);
    final nextDate = useState(DateTime.now());
    final isExpense = useState(true);
    final isSubmitting = useState(false);
    final accountsAsync = ref.watch(accountListProvider(entityId));
    final accounts = accountsAsync.value ?? const <Account>[];
    final accountId = useState<String?>(null);

    useListenable(amountController);
    final amountDecimals = currencyDecimalsForCode(currencyCode);
    final amountError = moneyInputError(
      amountController.text,
      decimals: amountDecimals,
      message: l10n.amountInvalidFormat(amountDecimals),
    );

    return AlertDialog(
      title: Text(l10n.recurringAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ObDropdown<String>(
              value: accountId.value ?? '',
              labelText: l10n.transactionAccountLabel,
              items: [
                for (final account in accounts)
                  DropdownMenuItem(
                    value: account.id?.toString() ?? '',
                    child: Text(account.name),
                  ),
              ],
              onChanged: (value) {
                if (value != null && value.isNotEmpty) accountId.value = value;
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            ObTextField(
              controller: descController,
              labelText: l10n.transactionDescriptionLabel,
              prefixIcon: const ObFieldIcon(
                data: OpenBudgetIcons.document,
                size: 20,
              ),
              autofocus: true,
              onSubmitted: (_) => unawaited(
                _submit(
                  context,
                  ref,
                  descController,
                  amountController,
                  frequency,
                  nextDate,
                  isExpense,
                  currencyCode,
                  accountId,
                  isSubmitting,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObTextField(
              controller: amountController,
              labelText:
                  '${l10n.transactionAmountLabel} (${normalizeCurrencyCode(currencyCode)})',
              errorText: amountError,
              prefixText: '${currencySymbolForCode(currencyCode)} ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(l10n.transactionFilterExpense),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(l10n.transactionFilterIncome),
                ),
              ],
              selected: {isExpense.value},
              onSelectionChanged: (s) => isExpense.value = s.first,
            ),
            const SizedBox(height: SpacingTokens.md),
            ObDropdown<RecurrenceFrequency>(
              value: frequency.value,
              labelText: l10n.recurringFrequencyLabel,
              items: [
                for (final value in RecurrenceFrequency.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(
                      switch (value) {
                        RecurrenceFrequency.daily => l10n.recurringFreqDaily,
                        RecurrenceFrequency.weekly => l10n.recurringFreqWeekly,
                        RecurrenceFrequency.biweekly =>
                          l10n.recurringFreqBiweekly,
                        RecurrenceFrequency.monthly =>
                          l10n.recurringFreqMonthly,
                        RecurrenceFrequency.yearly => l10n.recurringFreqYearly,
                      },
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) frequency.value = v;
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recurringStartDate),
              subtitle: Text(
                '${nextDate.value.year}-${nextDate.value.month.toString().padLeft(2, '0')}-${nextDate.value.day.toString().padLeft(2, '0')}',
              ),
              trailing: const SkribbleIcon(data: OpenBudgetIcons.calendar),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: nextDate.value,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) nextDate.value = picked;
              },
            ),
          ],
        ),
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
          isLoading: isSubmitting.value,
          loadingLabel: l10n.recurringSavingLabel,
          onPressed: () => _submit(
            context,
            ref,
            descController,
            amountController,
            frequency,
            nextDate,
            isExpense,
            currencyCode,
            accountId,
            isSubmitting,
          ),
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController descController,
    TextEditingController amountController,
    ValueNotifier<RecurrenceFrequency> frequency,
    ValueNotifier<DateTime> nextDate,
    ValueNotifier<bool> isExpense,
    String currencyCode,
    ValueNotifier<String?> accountId,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final description = descController.text.trim();
    final account = accountId.value;
    if (description.isEmpty || account == null) return;

    final amountMinor = parseMoneyInput(
      amountController.text,
      decimals: currencyDecimalsForCode(currencyCode),
    );
    if (amountMinor == null || amountMinor <= 0) return;

    final signedMinor = isExpense.value ? -amountMinor : amountMinor;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .createRecurring(
            accountId: account,
            description: description,
            amountMinor: signedMinor,
            frequency: frequency.value,
            nextOccurrence: nextDate.value,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.recurringCreateSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.recurringCreateError,
        variant: AppToastVariant.error,
      );
    }
  }
}

class _EditRecurringDialog extends HookConsumerWidget {
  const _EditRecurringDialog({
    required this.recurring,
    required this.entityId,
    required this.currencyCode,
  });

  final RecurringTransaction recurring;
  final String entityId;

  /// The account's currency, resolved by the list.
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descController = useTextEditingController(
      text: recurring.description,
    );
    final currency = normalizeCurrencyCode(currencyCode);
    final currencyDecimals = currencyDecimalsForCode(currency);
    final amountMinor = recurring.amountMinor.abs();
    final amountController = useTextEditingController(
      text: formatMinorUnits(amountMinor, currencyDecimals),
    );
    final frequency = useState(recurring.frequency);
    final nextDate = useState(recurring.nextDate);
    final isSubmitting = useState(false);

    useListenable(amountController);
    final amountError = moneyInputError(
      amountController.text,
      decimals: currencyDecimals,
      message: l10n.amountInvalidFormat(currencyDecimals),
    );

    return AlertDialog(
      title: Text(l10n.recurringEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ObTextField(
              controller: descController,
              labelText: l10n.transactionDescriptionLabel,
              prefixIcon: const ObFieldIcon(
                data: OpenBudgetIcons.document,
                size: 20,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObTextField(
              controller: amountController,
              labelText: '${l10n.transactionAmountLabel} ($currency)',
              errorText: amountError,
              prefixText: '${currencySymbolForCode(currency)} ',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObDropdown<RecurrenceFrequency>(
              value: frequency.value,
              labelText: l10n.recurringFrequencyLabel,
              items: [
                for (final value in RecurrenceFrequency.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(
                      switch (value) {
                        RecurrenceFrequency.daily => l10n.recurringFreqDaily,
                        RecurrenceFrequency.weekly => l10n.recurringFreqWeekly,
                        RecurrenceFrequency.biweekly =>
                          l10n.recurringFreqBiweekly,
                        RecurrenceFrequency.monthly =>
                          l10n.recurringFreqMonthly,
                        RecurrenceFrequency.yearly => l10n.recurringFreqYearly,
                      },
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) frequency.value = v;
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.recurringNextDate),
              subtitle: Text(
                '${nextDate.value.year}-${nextDate.value.month.toString().padLeft(2, '0')}-${nextDate.value.day.toString().padLeft(2, '0')}',
              ),
              trailing: const SkribbleIcon(data: OpenBudgetIcons.calendar),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: nextDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) nextDate.value = picked;
              },
            ),
          ],
        ),
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
          isLoading: isSubmitting.value,
          loadingLabel: l10n.recurringSavingLabel,
          onPressed: () => _submit(
            context,
            ref,
            descController,
            amountController,
            frequency,
            nextDate,
            currency,
            isSubmitting,
          ),
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController descController,
    TextEditingController amountController,
    ValueNotifier<RecurrenceFrequency> frequency,
    ValueNotifier<DateTime> nextDate,
    String currency,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final description = descController.text.trim();
    if (description.isEmpty) return;

    final amountMinor = parseMoneyInput(
      amountController.text,
      decimals: currencyDecimalsForCode(currency),
    );
    if (amountMinor == null || amountMinor <= 0) return;

    final isExpense = recurring.amountMinor < 0;
    final signedMinor = isExpense ? -amountMinor : amountMinor;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .updateRecurring(
            recurringId: recurring.id?.toString() ?? '',
            entityId: entityId,
            description: description,
            amountMinor: signedMinor,
            frequency: frequency.value,
            nextOccurrence: nextDate.value,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.recurringEditSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.recurringEditError,
        variant: AppToastVariant.error,
      );
    }
  }
}
