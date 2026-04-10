import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum RecurringViewFilter { all, expenses, income, due }

class RecurringListScreen extends HookConsumerWidget {
  const RecurringListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recurringAsync = ref.watch(recurringListProvider(budgetId));
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewFilter = useState(RecurringViewFilter.all);
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => parseCurrencyCode(budget.currencyCode),
        ) ??
        CurrencyCode.usd;

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
        scrolledUnderElevation: 0,
        title: Text(l10n.recurringListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: l10n.scheduledCalendarTitle,
            onPressed: () => context.pushNamed(
              recurringCalendarRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.recurringAddButton,
            onPressed: () => _showAddDialog(context, budgetCurrency),
          ),
        ],
      ),
      body: recurringAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                l10n.recurringLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(SpacingTokens.lg),
                color: OpenBudgetPalette.bgSecondaryFor(theme),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  side: BorderSide(
                    color: OpenBudgetPalette.borderSubtleFor(theme),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 48,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Text(
                        l10n.recurringEmptyTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        l10n.recurringEmptySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                      FilledButton.icon(
                        onPressed: () =>
                            _showAddDialog(context, budgetCurrency),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.recurringAddButton),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final now = DateTime.now();
          final activeItems = items.where((item) => item.isActive).toList();
          final dueCount = activeItems.where((item) {
            final dueDate = DateTime(
              item.nextOccurrence.year,
              item.nextOccurrence.month,
              item.nextOccurrence.day,
            );
            final today = DateTime(now.year, now.month, now.day);
            return !dueDate.isAfter(today);
          }).length;
          final expenseTotals = aggregateCentsByCurrency(
            activeItems.where((item) => item.amountCents < 0),
            currencyCodeOf: (item) => item.currencyCode,
            amountCentsOf: (item) => item.amountCents.abs(),
          );
          final incomeTotals = aggregateCentsByCurrency(
            activeItems.where((item) => item.amountCents > 0),
            currencyCodeOf: (item) => item.currencyCode,
            amountCentsOf: (item) => item.amountCents,
          );
          final filteredItems = items
              .where(
                (item) => switch (viewFilter.value) {
                  RecurringViewFilter.all => true,
                  RecurringViewFilter.expenses => item.amountCents < 0,
                  RecurringViewFilter.income => item.amountCents > 0,
                  RecurringViewFilter.due =>
                    item.isActive && !item.nextOccurrence.isAfter(now),
                },
              )
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recurringListProvider(budgetId));
            },
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                _RecurringSummaryCard(
                  totalItems: items.length,
                  dueCount: dueCount,
                  totalExpenses: expenseTotals.isEmpty
                      ? formatCents(0, budgetCurrency)
                      : formatCurrencyBreakdown(
                          expenseTotals,
                          includeCurrencyCode: expenseTotals.length > 1,
                        ),
                  totalIncome: incomeTotals.isEmpty
                      ? formatCents(0, budgetCurrency)
                      : formatCurrencyBreakdown(
                          incomeTotals,
                          includeCurrencyCode: incomeTotals.length > 1,
                        ),
                ),
                const SizedBox(height: SpacingTokens.md),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _RecurringFilterChip(
                        label: l10n.transactionFilterAll,
                        selected: viewFilter.value == RecurringViewFilter.all,
                        onTap: () => viewFilter.value = RecurringViewFilter.all,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _RecurringFilterChip(
                        label: l10n.transactionFilterExpense,
                        selected:
                            viewFilter.value == RecurringViewFilter.expenses,
                        onTap: () =>
                            viewFilter.value = RecurringViewFilter.expenses,
                        color: OpenBudgetPalette.fgErrorFor(theme),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _RecurringFilterChip(
                        label: l10n.transactionFilterIncome,
                        selected:
                            viewFilter.value == RecurringViewFilter.income,
                        onTap: () =>
                            viewFilter.value = RecurringViewFilter.income,
                        color: OpenBudgetPalette.fgSuccessFor(theme),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _RecurringFilterChip(
                        label: l10n.recurringDueLabel,
                        selected: viewFilter.value == RecurringViewFilter.due,
                        onTap: () => viewFilter.value = RecurringViewFilter.due,
                        color: OpenBudgetPalette.bgBrandFor(theme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                if (filteredItems.isEmpty)
                  Card(
                    margin: EdgeInsets.zero,
                    color: OpenBudgetPalette.bgSecondaryFor(theme),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      side: BorderSide(
                        color: OpenBudgetPalette.borderSubtleFor(theme),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Text(
                        l10n.transactionNoResults,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: OpenBudgetPalette.fgSecondaryFor(theme),
                        ),
                      ),
                    ),
                  ),
                ...filteredItems.map(
                  (item) => _RecurringTile(
                    recurring: item,
                    budgetId: budgetId,
                    onEdit: () => _showEditDialog(context, item),
                    onDelete: () => _confirmDelete(context, ref, item),
                    onToggle: () => _toggleActive(ref, item),
                    onSkip: () => _skipOccurrence(context, ref, item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, CurrencyCode currencyCode) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          _AddRecurringDialog(budgetId: budgetId, currencyCode: currencyCode),
    );
  }

  void _showEditDialog(BuildContext context, RecurringTransaction recurring) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          _EditRecurringDialog(recurring: recurring, budgetId: budgetId),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransaction recurring,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n"${recurring.description}"',
        ),
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

    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .deleteRecurring(
            recurringId: recurring.id?.toString() ?? '',
            budgetId: budgetId,
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
            budgetId: budgetId,
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
          budgetId: budgetId,
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

    return Card(
      margin: EdgeInsets.zero,
      color: OpenBudgetPalette.bgSecondaryFor(theme),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: BorderSide(color: OpenBudgetPalette.borderSubtleFor(theme)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgAccentFor(theme),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.recurringListTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    l10n.recurringTotalCount(totalItems),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: OpenBudgetPalette.fgSecondaryFor(theme),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: l10n.transactionFilterExpense,
                    value: totalExpenses,
                    color: OpenBudgetPalette.fgErrorFor(theme),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _SummaryMetric(
                    label: l10n.transactionFilterIncome,
                    value: totalIncome,
                    color: OpenBudgetPalette.fgSuccessFor(theme),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _SummaryMetric(
                    label: l10n.recurringDueLabel,
                    value: '$dueCount',
                    color: OpenBudgetPalette.bgBrandFor(theme),
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

class _SummaryMetric extends HookWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringFilterChip extends HookWidget {
  const _RecurringFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? OpenBudgetPalette.bgBrandFor(theme);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: OpenBudgetPalette.bgSecondaryFor(theme),
      selectedColor: chipColor.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        side: BorderSide(
          color: selected
              ? chipColor.withAlpha(130)
              : OpenBudgetPalette.borderSubtleFor(theme),
        ),
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? chipColor : OpenBudgetPalette.fgSecondaryFor(theme),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}

class _RecurringTile extends HookWidget {
  const _RecurringTile({
    required this.recurring,
    required this.budgetId,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onSkip,
  });

  final RecurringTransaction recurring;
  final String budgetId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currency = CurrencyCode.values.firstWhere(
      (c) => c.code == recurring.currencyCode,
      orElse: () => CurrencyCode.usd,
    );
    final amount = recurring.amountCents / _pow10(currency.decimals);
    final isIncome = recurring.amountCents > 0;
    final formattedAmount =
        '${currency.symbol}${amount.abs().toStringAsFixed(currency.decimals)}';

    final frequencyLabel = switch (recurring.frequency) {
      'daily' => l10n.recurringFreqDaily,
      'weekly' => l10n.recurringFreqWeekly,
      'biweekly' => l10n.recurringFreqBiweekly,
      'monthly' => l10n.recurringFreqMonthly,
      'yearly' => l10n.recurringFreqYearly,
      _ => recurring.frequency,
    };

    final nextDate = recurring.nextOccurrence;
    final isDue = recurring.isActive && !nextDate.isAfter(DateTime.now());
    final dateStr =
        '${nextDate.year}-${nextDate.month.toString().padLeft(2, '0')}-${nextDate.day.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(recurring.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.md),
        decoration: BoxDecoration(
          color: OpenBudgetPalette.fgErrorFor(theme),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Icon(Icons.delete, color: OpenBudgetPalette.fgOnBrandFor(theme)),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        color: OpenBudgetPalette.bgSecondaryFor(theme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          side: BorderSide(color: OpenBudgetPalette.borderSubtleFor(theme)),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: recurring.isActive
                    ? OpenBudgetPalette.bgAccentFor(theme).withAlpha(90)
                    : OpenBudgetPalette.bgTertiaryFor(theme),
                child: Icon(
                  Icons.repeat_rounded,
                  color: recurring.isActive
                      ? OpenBudgetPalette.bgBrandFor(theme)
                      : OpenBudgetPalette.fgSecondaryFor(theme),
                  size: 18,
                ),
              ),
              title: Text(
                recurring.description,
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: recurring.isActive
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '$frequencyLabel \u2022 ${l10n.recurringNextDate}: $dateStr',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: OpenBudgetPalette.fgSecondaryFor(theme),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? OpenBudgetPalette.fgSuccessFor(theme).withAlpha(26)
                          : OpenBudgetPalette.fgErrorFor(theme).withAlpha(18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isIncome ? '+$formattedAmount' : '-$formattedAmount',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isIncome
                            ? OpenBudgetPalette.fgSuccessFor(theme)
                            : OpenBudgetPalette.fgErrorFor(theme),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Switch.adaptive(
                    value: recurring.isActive,
                    onChanged: (_) => onToggle(),
                    activeTrackColor: OpenBudgetPalette.bgBrandFor(theme),
                  ),
                ],
              ),
              onTap: onEdit,
            ),
            if (isDue)
              Padding(
                padding: const EdgeInsets.only(
                  left: SpacingTokens.md,
                  right: SpacingTokens.md,
                  bottom: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: OpenBudgetPalette.bgBrandFor(theme),
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        l10n.recurringDueLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: OpenBudgetPalette.bgBrandFor(theme),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onSkip,
                      icon: const Icon(Icons.skip_next_rounded, size: 18),
                      label: Text(l10n.recurringSkipButton),
                      style: TextButton.styleFrom(
                        foregroundColor: OpenBudgetPalette.fgSecondaryFor(
                          theme,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddRecurringDialog extends HookConsumerWidget {
  const _AddRecurringDialog({
    required this.budgetId,
    required this.currencyCode,
  });

  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descController = useTextEditingController();
    final amountController = useTextEditingController();
    final frequency = useState('monthly');
    final nextDate = useState(DateTime.now());
    final isExpense = useState(true);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.recurringAddTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: l10n.transactionDescriptionLabel,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText:
                    '${l10n.transactionAmountLabel} (${currencyCode.code})',
                prefixText: '${currencyCode.symbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
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
            DropdownButtonFormField<String>(
              initialValue: frequency.value,
              decoration: InputDecoration(
                labelText: l10n.recurringFrequencyLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: 'daily',
                  child: Text(l10n.recurringFreqDaily),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text(l10n.recurringFreqWeekly),
                ),
                DropdownMenuItem(
                  value: 'biweekly',
                  child: Text(l10n.recurringFreqBiweekly),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Text(l10n.recurringFreqMonthly),
                ),
                DropdownMenuItem(
                  value: 'yearly',
                  child: Text(l10n.recurringFreqYearly),
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
              trailing: const Icon(Icons.calendar_today),
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
                  descController,
                  amountController,
                  frequency,
                  nextDate,
                  isExpense,
                  currencyCode,
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
    TextEditingController descController,
    TextEditingController amountController,
    ValueNotifier<String> frequency,
    ValueNotifier<DateTime> nextDate,
    ValueNotifier<bool> isExpense,
    CurrencyCode currencyCode,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final description = descController.text.trim();
    if (description.isEmpty) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final amountCents = (amount * _pow10(currencyCode.decimals)).round();
    final signedCents = isExpense.value ? -amountCents : amountCents;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .createRecurring(
            description: description,
            amountCents: signedCents,
            currencyCode: currencyCode.code,
            budgetId: budgetId,
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
  const _EditRecurringDialog({required this.recurring, required this.budgetId});

  final RecurringTransaction recurring;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descController = useTextEditingController(
      text: recurring.description,
    );
    final currency = parseCurrencyCode(recurring.currencyCode);
    final amountCents = recurring.amountCents.abs();
    final amountController = useTextEditingController(
      text: (amountCents / _pow10(currency.decimals)).toStringAsFixed(
        currency.decimals,
      ),
    );
    final frequency = useState(recurring.frequency);
    final nextDate = useState(recurring.nextOccurrence);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.recurringEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: descController,
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
                labelText: '${l10n.transactionAmountLabel} (${currency.code})',
                prefixText: '${currency.symbol} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              initialValue: frequency.value,
              decoration: InputDecoration(
                labelText: l10n.recurringFrequencyLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: 'daily',
                  child: Text(l10n.recurringFreqDaily),
                ),
                DropdownMenuItem(
                  value: 'weekly',
                  child: Text(l10n.recurringFreqWeekly),
                ),
                DropdownMenuItem(
                  value: 'biweekly',
                  child: Text(l10n.recurringFreqBiweekly),
                ),
                DropdownMenuItem(
                  value: 'monthly',
                  child: Text(l10n.recurringFreqMonthly),
                ),
                DropdownMenuItem(
                  value: 'yearly',
                  child: Text(l10n.recurringFreqYearly),
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
              trailing: const Icon(Icons.calendar_today),
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
                  descController,
                  amountController,
                  frequency,
                  nextDate,
                  currency,
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
    TextEditingController descController,
    TextEditingController amountController,
    ValueNotifier<String> frequency,
    ValueNotifier<DateTime> nextDate,
    CurrencyCode currency,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final description = descController.text.trim();
    if (description.isEmpty) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final amountCents = (amount * _pow10(currency.decimals)).round();
    final isExpense = recurring.amountCents < 0;
    final signedCents = isExpense ? -amountCents : amountCents;

    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .updateRecurring(
            recurringId: recurring.id?.toString() ?? '',
            budgetId: budgetId,
            description: description,
            amountCents: signedCents,
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

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
