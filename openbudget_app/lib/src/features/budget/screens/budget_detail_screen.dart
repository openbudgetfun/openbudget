import 'package:flutter/material.dart';
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
import 'package:openbudget_app/src/features/budget/screens/move_money_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_app/src/features/budget/widgets/credit_card_section.dart';
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
                onPressed: () => context.go('/budgets/$budgetId/transactions'),
              ),
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
