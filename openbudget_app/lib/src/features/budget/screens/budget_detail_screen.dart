import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/add_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/add_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/envelope_activity_sheet.dart';
import 'package:openbudget_app/src/features/budget/screens/move_money_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_app/src/features/budget/widgets/credit_card_section.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetDetailScreen extends HookConsumerWidget {
  const BudgetDetailScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final ccPayments = ref.watch(creditCardPaymentsProvider(budgetId));
    final goalsAsync = ref.watch(budgetGoalsProvider(budgetId));
    final dueCountAsync = ref.watch(recurringDueCountProvider(budgetId));
    final isPosting = useState(false);
    final isReordering = useState(false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return summaryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(homePath),
          ),
          title: Text(l10n.appTitle),
        ),
        body: Center(
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
                l10n.budgetLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
      data: (summary) {
        final currencyCode = CurrencyCode.values.firstWhere(
          (c) => c.code == summary.budget.currencyCode,
          orElse: () => CurrencyCode.usd,
        );
        final goalsMap = goalsAsync.hasValue
            ? goalsAsync.value!
            : <String, EnvelopeGoal>{};

        // Compute total overspent cents across all categories.
        var totalOverspentCents = 0;
        for (final cat in summary.categories) {
          if (cat.totalAvailableCents < 0) {
            totalOverspentCents += cat.totalAvailableCents.abs();
          }
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(homePath),
            ),
            title: Text(summary.budget.name),
            actions: [
              if (isReordering.value)
                TextButton(
                  onPressed: () => isReordering.value = false,
                  child: Text(l10n.budgetReorderDone),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.swap_vert_rounded),
                  tooltip: l10n.budgetReorderCategories,
                  onPressed: () => isReordering.value = true,
                ),
                IconButton(
                  icon: const Icon(Icons.account_balance_rounded),
                  tooltip: l10n.budgetViewAccounts,
                  onPressed: () => context.go('/budgets/$budgetId/accounts'),
                ),
                IconButton(
                  icon: const Icon(Icons.store_rounded),
                  tooltip: l10n.payeeListTitle,
                  onPressed: () => context.go('/budgets/$budgetId/payees'),
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  tooltip: l10n.reportsTitle,
                  onPressed: () => context.go('/budgets/$budgetId/reports'),
                ),
                IconButton(
                  icon: const Icon(Icons.receipt_long_rounded),
                  tooltip: l10n.transactionListTitle,
                  onPressed: () =>
                      context.go('/budgets/$budgetId/transactions'),
                ),
              ],
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              final selectedMonth = ref.read(selectedMonthProvider(budgetId));
              ref
                ..invalidate(budgetDetailProvider(budgetId))
                ..invalidate(categoryListProvider(budgetId))
                ..invalidate(transactionListProvider(budgetId))
                ..invalidate(budgetSummaryProvider(budgetId))
                ..invalidate(budgetMonthlySummaryProvider(budgetId))
                ..invalidate(budgetGoalsProvider(budgetId))
                ..invalidate(recurringDueCountProvider(budgetId))
                ..invalidate(
                  monthlyAllocationsProvider(
                    budgetId,
                    selectedMonth.year,
                    selectedMonth.month,
                  ),
                )
                ..invalidate(
                  monthlyTransactionsProvider(
                    budgetId,
                    selectedMonth.year,
                    selectedMonth.month,
                  ),
                );
            },
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                BudgetHeader(
                  readyToAssignCents: summary.readyToAssignCents,
                  currencyCode: currencyCode,
                  budgetId: budgetId,
                  year: summary.year,
                  month: summary.month,
                  totalOverspentCents: totalOverspentCents,
                ),
                const SizedBox(height: SpacingTokens.md),
                if (dueCountAsync.hasValue && dueCountAsync.value! > 0)
                  _DueBanner(
                    count: dueCountAsync.value!,
                    isPosting: isPosting.value,
                    onPost: () => _postDueTransactions(context, ref, isPosting),
                  ),
                if (ccPayments.hasValue && ccPayments.value!.isNotEmpty) ...[
                  CreditCardSection(
                    payments: ccPayments.value!,
                    currencyCode: currencyCode,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (summary.categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xl,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            l10n.budgetEmptyTitle,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            l10n.budgetEmptySubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (isReordering.value && summary.categories.isNotEmpty)
                  _ReorderableCategoryList(
                    categories: summary.categories,
                    budgetId: budgetId,
                  ),
                if (!isReordering.value)
                  ...summary.categories.map(
                    (catWithEnvelopes) => Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                      child: CategoryGroup(
                        categoryWithEnvelopes: catWithEnvelopes,
                        currencyCode: currencyCode,
                        goalsMap: goalsMap,
                        onAddEnvelope: () => _showAddEnvelopeDialog(
                          context,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onDeleteCategory: () => _confirmDeleteCategory(
                          context,
                          ref,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          catWithEnvelopes.category.name,
                        ),
                        onEditEnvelope: (envelope) => _showEditEnvelopeDialog(
                          context,
                          envelope,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onDeleteEnvelope: (envelope) => _confirmDeleteEnvelope(
                          context,
                          ref,
                          envelope.id?.toString() ?? '',
                          catWithEnvelopes.category.id?.toString() ?? '',
                          envelope.name,
                        ),
                        onQuickBudget: (envelope) => _showQuickBudgetDialog(
                          context,
                          envelope,
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onShowActivity: (envelope, monthlyData, goal) =>
                            _showEnvelopeActivity(
                              context,
                              envelope,
                              currencyCode,
                              monthlyData: monthlyData,
                              goal: goal,
                            ),
                      ),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.sm),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddCategoryDialog(
                      context,
                      summary.categories.length,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.budgetAddCategory),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.go('/budgets/$budgetId/income/add'),
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text(l10n.budgetAddIncome),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          context.go('/budgets/$budgetId/expenses/add'),
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(l10n.budgetAddExpense),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  IconButton.filled(
                    onPressed: () =>
                        context.go('/budgets/$budgetId/expenses/split'),
                    icon: const Icon(Icons.call_split_rounded),
                    tooltip: l10n.splitTransactionTitle,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  IconButton.filled(
                    onPressed: () => context.go('/budgets/$budgetId/import'),
                    icon: const Icon(Icons.upload_file_rounded),
                    tooltip: l10n.importTitle,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  IconButton.filled(
                    onPressed: () => _showMoveMoneyDialog(
                      context,
                      summary.categories,
                      year: summary.year,
                      month: summary.month,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: l10n.moveMoneyTitle,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEnvelopeActivity(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode, {
    MonthlyEnvelopeData? monthlyData,
    EnvelopeGoal? goal,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.lg),
        ),
      ),
      builder: (_) => EnvelopeActivitySheet(
        envelope: envelope,
        budgetId: budgetId,
        currencyCode: currencyCode,
        monthlyData: monthlyData,
        goal: goal,
      ),
    );
  }

  void _showMoveMoneyDialog(
    BuildContext context,
    List<CategoryWithEnvelopes> categories, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => MoveMoneyDialog(
        budgetId: budgetId,
        year: year,
        month: month,
        categories: categories,
      ),
    );
  }

  void _showQuickBudgetDialog(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => QuickBudgetDialog(
        budgetId: budgetId,
        envelopeId: envelope.id?.toString() ?? '',
        envelopeName: envelope.name,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, int nextSortOrder) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          AddCategoryDialog(budgetId: budgetId, nextSortOrder: nextSortOrder),
    );
  }

  void _showAddEnvelopeDialog(
    BuildContext context,
    String categoryId,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => AddEnvelopeDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    Envelope envelope,
    String categoryId,
    CurrencyCode currencyCode, {
    required int year,
    required int month,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => EditEnvelopeDialog(
        envelope: envelope,
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    String categoryId,
    String categoryName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"$categoryName"'),
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
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, budgetId: budgetId);
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

  Future<void> _postDueTransactions(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isPosting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isPosting.value = true;
    try {
      final count = await ref
          .read(recurringAutoPostActionsProvider.notifier)
          .postDue(budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recurringPostSuccess(count))),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recurringPostError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> _confirmDeleteEnvelope(
    BuildContext context,
    WidgetRef ref,
    String envelopeId,
    String categoryId,
    String envelopeName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"$envelopeName"'),
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
          .read(envelopeActionsProvider.notifier)
          .deleteEnvelope(
            envelopeId: envelopeId,
            categoryId: categoryId,
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
}

class _DueBanner extends HookWidget {
  const _DueBanner({
    required this.count,
    required this.isPosting,
    required this.onPost,
  });

  final int count;
  final bool isPosting;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: ColorTokens.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(color: ColorTokens.primary.withAlpha(60)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 20,
              color: ColorTokens.primary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                l10n.recurringDueBanner(count),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorTokens.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            FilledButton.icon(
              onPressed: isPosting ? null : onPost,
              icon: isPosting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 16),
              label: Text(
                isPosting ? l10n.recurringPosting : l10n.recurringPostDue,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: ColorTokens.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.xs,
                ),
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderableCategoryList extends HookConsumerWidget {
  const _ReorderableCategoryList({
    required this.categories,
    required this.budgetId,
  });

  final List<CategoryWithEnvelopes> categories;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orderedCategories = useState(List.of(categories));

    // Sync with provider state when categories change.
    useEffect(() {
      orderedCategories.value = List.of(categories);
      return null;
    }, [categories]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                l10n.budgetReorderHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...orderedCategories.value.asMap().entries.map((entry) {
          final index = entry.key;
          final cat = entry.value;
          return _ReorderableCategoryTile(
            key: ValueKey(cat.category.id),
            category: cat,
            index: index,
            total: orderedCategories.value.length,
            onMoveUp: index > 0
                ? () => _swap(orderedCategories, index, index - 1, ref)
                : null,
            onMoveDown: index < orderedCategories.value.length - 1
                ? () => _swap(orderedCategories, index, index + 1, ref)
                : null,
          );
        }),
      ],
    );
  }

  Future<void> _swap(
    ValueNotifier<List<CategoryWithEnvelopes>> orderedCategories,
    int from,
    int to,
    WidgetRef ref,
  ) async {
    final list = List.of(orderedCategories.value);
    final item = list.removeAt(from);
    list.insert(to, item);
    orderedCategories.value = list;

    final categoryIds = list
        .map((c) => c.category.id?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .reorderCategories(budgetId: budgetId, categoryIds: categoryIds);
    } on Exception catch (_) {
      // Revert on error handled by provider re-fetch.
    }
  }
}

class _ReorderableCategoryTile extends HookWidget {
  const _ReorderableCategoryTile({
    required this.category,
    required this.index,
    required this.total,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  final CategoryWithEnvelopes category;
  final int index;
  final int total;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ListTile(
        leading: Icon(
          Icons.drag_handle_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          category.category.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.envelopes.length} envelopes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded),
              onPressed: onMoveUp,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_downward_rounded),
              onPressed: onMoveDown,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
