import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/add_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/add_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
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
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));

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
          child: Text(
            l10n.budgetLoadError,
            style: const TextStyle(color: ColorTokens.error),
          ),
        ),
      ),
      data: (summary) {
        final currencyCode = CurrencyCode.values.firstWhere(
          (c) => c.code == summary.budget.currencyCode,
          orElse: () => CurrencyCode.usd,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(homePath),
            ),
            title: Text(summary.budget.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                tooltip: l10n.transactionListTitle,
                onPressed: () => context.go('/budgets/$budgetId/transactions'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(budgetDetailProvider(budgetId))
                ..invalidate(categoryListProvider(budgetId))
                ..invalidate(transactionListProvider(budgetId))
                ..invalidate(budgetSummaryProvider(budgetId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                BudgetHeader(
                  readyToAssignCents: summary.readyToAssignCents,
                  currencyCode: currencyCode,
                ),
                const SizedBox(height: 16),
                if (summary.categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text(
                            l10n.budgetEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.budgetEmptySubtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ...summary.categories.map(
                  (catWithEnvelopes) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CategoryGroup(
                      categoryWithEnvelopes: catWithEnvelopes,
                      currencyCode: currencyCode,
                      onAddEnvelope: () => _showAddEnvelopeDialog(
                        context,
                        catWithEnvelopes.category.id?.toString() ?? '',
                        currencyCode,
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
                      ),
                      onDeleteEnvelope: (envelope) => _confirmDeleteEnvelope(
                        context,
                        ref,
                        envelope.id?.toString() ?? '',
                        catWithEnvelopes.category.id?.toString() ?? '',
                        envelope.name,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: WiredButton(
                    onPressed: () => _showAddCategoryDialog(
                      context,
                      summary.categories.length,
                    ),
                    child: Text(l10n.budgetAddCategory),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WiredButton(
                      onPressed: () =>
                          context.go('/budgets/$budgetId/income/add'),
                      child: Text(l10n.budgetAddIncome),
                    ),
                    WiredButton(
                      onPressed: () =>
                          context.go('/budgets/$budgetId/expenses/add'),
                      child: Text(l10n.budgetAddExpense),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
    CurrencyCode currencyCode,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => AddEnvelopeDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    Envelope envelope,
    String categoryId,
    CurrencyCode currencyCode,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => EditEnvelopeDialog(
        envelope: envelope,
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.deleteConfirmButton,
              style: const TextStyle(color: ColorTokens.error),
            ),
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
            backgroundColor: ColorTokens.error,
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.deleteConfirmButton,
              style: const TextStyle(color: ColorTokens.error),
            ),
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
            backgroundColor: ColorTokens.error,
          ),
        );
      }
    }
  }
}
