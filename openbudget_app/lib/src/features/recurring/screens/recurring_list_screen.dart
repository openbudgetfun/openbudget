import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

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
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => parseCurrencyCode(budget.currencyCode),
        ) ??
        CurrencyCode.usd;

    return Scaffold(
      appBar: AppBar(
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
                    onPressed: () => _showAddDialog(context, budgetCurrency),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.recurringAddButton),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recurringListProvider(budgetId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(SpacingTokens.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _RecurringTile(
                  recurring: item,
                  budgetId: budgetId,
                  onEdit: () => _showEditDialog(context, item),
                  onDelete: () => _confirmDelete(context, ref, item),
                  onToggle: () => _toggleActive(ref, item),
                  onSkip: () => _skipOccurrence(context, ref, item),
                );
              },
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteError),
            backgroundColor: colorScheme.error,
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref
          .read(recurringActionsProvider.notifier)
          .skipOccurrence(
            recurringId: recurring.id?.toString() ?? '',
            budgetId: budgetId,
          );
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.recurringSkipSuccess)),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.recurringSkipError),
            backgroundColor: colorScheme.error,
          ),
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
    final colorScheme = theme.colorScheme;
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
        color: colorScheme.error,
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                recurring.isActive
                    ? Icons.repeat_rounded
                    : Icons.repeat_rounded,
                color: recurring.isActive
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              title: Text(
                recurring.description,
                style: TextStyle(
                  decoration: recurring.isActive
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '$frequencyLabel \u2022 ${l10n.recurringNextDate}: $dateStr',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isIncome ? '+$formattedAmount' : '-$formattedAmount',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isIncome ? colorScheme.primary : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Switch(
                    value: recurring.isActive,
                    onChanged: (_) => onToggle(),
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
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Expanded(
                      child: Text(
                        l10n.recurringDueLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onSkip,
                      icon: const Icon(Icons.skip_next_rounded, size: 18),
                      label: Text(l10n.recurringSkipButton),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
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
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.recurringCreateSuccess)),
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.recurringCreateError),
          backgroundColor: colorScheme.error,
        ),
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
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.recurringEditSuccess)),
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.recurringEditError),
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
