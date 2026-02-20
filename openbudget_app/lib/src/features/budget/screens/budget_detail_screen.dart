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
import 'package:openbudget_app/src/features/budget/screens/budget_template_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/envelope_activity_sheet.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_header.dart';
import 'package:openbudget_app/src/features/budget/widgets/category_group.dart';
import 'package:openbudget_app/src/features/budget/widgets/credit_card_section.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/ynab_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
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
    final hasAutoPosted = useState(false);
    final isReordering = useState(false);
    final showHidden = useState(false);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final isSearching = useState(false);
    final showSpotlight = useState(false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auto-post due recurring transactions when the budget opens.
    useEffect(() {
      if (hasAutoPosted.value) return null;
      if (!dueCountAsync.hasValue || dueCountAsync.value! <= 0) return null;
      if (!summaryAsync.hasValue) return null;

      hasAutoPosted.value = true;

      Future.microtask(() async {
        isPosting.value = true;
        try {
          final count = await ref
              .read(recurringAutoPostActionsProvider.notifier)
              .postDue(budgetId: budgetId);
          if (context.mounted && count > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.recurringAutoPosted(count))),
            );
          }
        } on Exception catch (_) {
          hasAutoPosted.value = false;
        } finally {
          isPosting.value = false;
        }
      });

      return null;
    }, [dueCountAsync, summaryAsync]);

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

        // Compute total overspent and total activity cents.
        var totalOverspentCents = 0;
        var totalActivityCents = 0;
        for (final cat in summary.categories) {
          if (cat.totalAvailableCents < 0) {
            totalOverspentCents += cat.totalAvailableCents.abs();
          }
          totalActivityCents += cat.totalSpentCents;
        }

        var hiddenCount = 0;
        for (final cat in summary.categories) {
          if (cat.category.isHidden ?? false) {
            hiddenCount++;
          }
          for (final env in cat.envelopes) {
            if (env.isHidden ?? false) hiddenCount++;
          }
        }
        final filteredCategories = _filterCategories(
          summary.categories,
          searchQuery.value,
          showHidden: showHidden.value,
        );

        return Scaffold(
          backgroundColor: YnabPalette.appBackground,
          appBar: AppBar(
            backgroundColor: YnabPalette.appBackground,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(homePath),
            ),
            title: Text(
              summary.budget.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              if (isReordering.value)
                TextButton(
                  onPressed: () => isReordering.value = false,
                  child: Text(l10n.budgetReorderDone),
                )
              else ...[
                IconButton(
                  icon: Icon(
                    isSearching.value
                        ? Icons.search_off_rounded
                        : Icons.search_rounded,
                  ),
                  tooltip: l10n.budgetSearchHint,
                  onPressed: () {
                    isSearching.value = !isSearching.value;
                    if (!isSearching.value) {
                      searchController.clear();
                      searchQuery.value = '';
                    }
                  },
                ),
                IconButton(
                  icon: Badge(
                    isLabelVisible: !showHidden.value && hiddenCount > 0,
                    label: Text('$hiddenCount'),
                    child: Icon(
                      showHidden.value
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                  tooltip: showHidden.value
                      ? l10n.budgetShowHidden
                      : hiddenCount > 0
                      ? l10n.budgetHiddenCount(hiddenCount)
                      : l10n.budgetShowHidden,
                  onPressed: () => showHidden.value = !showHidden.value,
                ),
                IconButton(
                  icon: const Icon(Icons.swap_vert_rounded),
                  tooltip: l10n.budgetReorderCategories,
                  onPressed: () => isReordering.value = true,
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border_rounded),
                  tooltip: l10n.templateTitle,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => BudgetTemplateDialog(budgetId: budgetId),
                  ),
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
                _BudgetViewToggle(
                  showSpotlight: showSpotlight.value,
                  onChanged: (value) => showSpotlight.value = value,
                ),
                const SizedBox(height: SpacingTokens.sm),
                BudgetHeader(
                  readyToAssignCents: summary.readyToAssignCents,
                  currencyCode: currencyCode,
                  budgetId: budgetId,
                  year: summary.year,
                  month: summary.month,
                  totalOverspentCents: totalOverspentCents,
                  totalIncomeCents: summary.totalIncomeCents,
                  totalBudgetedCents: summary.totalBudgetedCents,
                  totalActivityCents: totalActivityCents,
                  onCopyLastMonth: () => _confirmCopyLastMonth(
                    context,
                    ref,
                    budgetId,
                    summary.year,
                    summary.month,
                  ),
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
                if (showSpotlight.value)
                  _SpotlightSummaryCard(
                    totalIncomeCents: summary.totalIncomeCents,
                    totalBudgetedCents: summary.totalBudgetedCents,
                    totalActivityCents: totalActivityCents,
                    totalOverspentCents: totalOverspentCents,
                    currencyCode: currencyCode,
                  ),
                if (!showSpotlight.value && isSearching.value) ...[
                  TextField(
                    controller: searchController,
                    onChanged: (value) => searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: l10n.budgetSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (!showSpotlight.value && summary.categories.isEmpty)
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
                if (!showSpotlight.value &&
                    isSearching.value &&
                    searchQuery.value.isNotEmpty &&
                    filteredCategories.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xl,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            l10n.budgetSearchNoResults,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!showSpotlight.value &&
                    isReordering.value &&
                    summary.categories.isNotEmpty)
                  _ReorderableCategoryList(
                    categories: summary.categories,
                    budgetId: budgetId,
                  ),
                if (!showSpotlight.value && !isReordering.value)
                  ...filteredCategories.map(
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
                        onEditCategory: () => _showEditCategoryDialog(
                          context,
                          catWithEnvelopes.category.id?.toString() ?? '',
                          catWithEnvelopes.category.name,
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
                              categories: summary.categories,
                              categoryId:
                                  catWithEnvelopes.category.id?.toString() ??
                                  '',
                              year: summary.year,
                              month: summary.month,
                              monthlyData: monthlyData,
                              goal: goal,
                            ),
                        onReorderEnvelopes: (envelopeIds) async {
                          try {
                            await ref
                                .read(envelopeActionsProvider.notifier)
                                .reorderEnvelopes(
                                  categoryId:
                                      catWithEnvelopes.category.id
                                          ?.toString() ??
                                      '',
                                  budgetId: budgetId,
                                  envelopeIds: envelopeIds,
                                );
                          } on Exception catch (_) {
                            // Handled by provider re-fetch.
                          }
                        },
                        showHidden: showHidden.value,
                        onToggleHideCategory: ({required isHidden}) async {
                          try {
                            await ref
                                .read(categoryActionsProvider.notifier)
                                .toggleHidden(
                                  categoryId:
                                      catWithEnvelopes.category.id
                                          ?.toString() ??
                                      '',
                                  budgetId: budgetId,
                                  isHidden: isHidden,
                                );
                          } on Exception catch (_) {
                            // Handled by provider re-fetch.
                          }
                        },
                        onToggleHideEnvelope:
                            (envelope, {required isHidden}) async {
                              try {
                                await ref
                                    .read(envelopeActionsProvider.notifier)
                                    .toggleHidden(
                                      envelopeId: envelope.id?.toString() ?? '',
                                      categoryId:
                                          catWithEnvelopes.category.id
                                              ?.toString() ??
                                          '',
                                      budgetId: budgetId,
                                      isHidden: isHidden,
                                    );
                              } on Exception catch (_) {
                                // Handled by provider re-fetch.
                              }
                            },
                      ),
                    ),
                  ),
                if (!showSpotlight.value) ...[
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
                ],
                const SizedBox(height: SpacingTokens.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  List<CategoryWithEnvelopes> _filterCategories(
    List<CategoryWithEnvelopes> categories,
    String query, {
    required bool showHidden,
  }) {
    var result = categories;

    // Filter hidden categories and envelopes.
    if (!showHidden) {
      final visible = <CategoryWithEnvelopes>[];
      for (final cat in result) {
        if (cat.category.isHidden ?? false) continue;

        final visibleEnvelopeIndices = <int>[];
        for (var i = 0; i < cat.envelopes.length; i++) {
          if (!(cat.envelopes[i].isHidden ?? false)) {
            visibleEnvelopeIndices.add(i);
          }
        }

        visible.add(
          CategoryWithEnvelopes(
            category: cat.category,
            envelopes: visibleEnvelopeIndices
                .map((i) => cat.envelopes[i])
                .toList(),
            monthlyEnvelopes: visibleEnvelopeIndices
                .where((i) => i < cat.monthlyEnvelopes.length)
                .map((i) => cat.monthlyEnvelopes[i])
                .toList(),
            totalBudgetedCents: cat.totalBudgetedCents,
            totalSpentCents: cat.totalSpentCents,
            totalAvailableCents: cat.totalAvailableCents,
          ),
        );
      }
      result = visible;
    }

    if (query.isEmpty) return result;

    final lowerQuery = query.toLowerCase();
    final filtered = <CategoryWithEnvelopes>[];

    for (final cat in result) {
      // Check if category name matches.
      final categoryMatches = cat.category.name.toLowerCase().contains(
        lowerQuery,
      );

      // Filter matching envelopes.
      final matchingEnvelopeIndices = <int>[];
      for (var i = 0; i < cat.envelopes.length; i++) {
        if (cat.envelopes[i].name.toLowerCase().contains(lowerQuery)) {
          matchingEnvelopeIndices.add(i);
        }
      }

      if (categoryMatches || matchingEnvelopeIndices.isNotEmpty) {
        if (categoryMatches) {
          // Show all envelopes when category name matches.
          filtered.add(cat);
        } else {
          // Only show matching envelopes.
          filtered.add(
            CategoryWithEnvelopes(
              category: cat.category,
              envelopes: matchingEnvelopeIndices
                  .map((i) => cat.envelopes[i])
                  .toList(),
              monthlyEnvelopes: matchingEnvelopeIndices
                  .where((i) => i < cat.monthlyEnvelopes.length)
                  .map((i) => cat.monthlyEnvelopes[i])
                  .toList(),
              totalBudgetedCents: cat.totalBudgetedCents,
              totalSpentCents: cat.totalSpentCents,
              totalAvailableCents: cat.totalAvailableCents,
            ),
          );
        }
      }
    }

    return filtered;
  }

  void _showEnvelopeActivity(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode, {
    required List<CategoryWithEnvelopes> categories,
    required String categoryId,
    required int year,
    required int month,
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
        categories: categories,
        categoryId: categoryId,
        year: year,
        month: month,
        monthlyData: monthlyData,
        goal: goal,
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

  void _showEditCategoryDialog(
    BuildContext context,
    String categoryId,
    String currentName,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => EditCategoryDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currentName: currentName,
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
      final deleted = await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteSuccess),
            action: SnackBarAction(
              label: l10n.undoAction,
              onPressed: () => _undoDeleteCategory(context, ref, deleted, l10n),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
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

  Future<void> _undoDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category deleted,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .undoDeleteCategory(deletedCategory: deleted, budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.undoDeleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.undoDeleteError),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  Future<void> _confirmCopyLastMonth(
    BuildContext context,
    WidgetRef ref,
    String budgetId,
    int year,
    int month,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetCopyLastMonth),
        content: Text(l10n.budgetCopyLastMonthConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.content_copy_rounded, size: 16),
            label: Text(l10n.budgetCopyLastMonth),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .copyPreviousMonth(
            budgetId: budgetId,
            currentYear: year,
            currentMonth: month,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.budgetCopyLastMonthSuccess)),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.budgetCopyLastMonthError),
            backgroundColor: Theme.of(context).colorScheme.error,
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
      final deleted = await ref
          .read(envelopeActionsProvider.notifier)
          .deleteEnvelope(
            envelopeId: envelopeId,
            categoryId: categoryId,
            budgetId: budgetId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteSuccess),
            action: SnackBarAction(
              label: l10n.undoAction,
              onPressed: () =>
                  _undoDeleteEnvelope(context, ref, deleted, categoryId, l10n),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
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

  Future<void> _undoDeleteEnvelope(
    BuildContext context,
    WidgetRef ref,
    Envelope deleted,
    String categoryId,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(envelopeActionsProvider.notifier)
          .undoDeleteEnvelope(
            deletedEnvelope: deleted,
            categoryId: categoryId,
            budgetId: budgetId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.undoDeleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.undoDeleteError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _BudgetViewToggle extends HookWidget {
  const _BudgetViewToggle({
    required this.showSpotlight,
    required this.onChanged,
  });

  final bool showSpotlight;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: YnabPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: YnabPalette.divider),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Categories',
              selected: !showSpotlight,
              onTap: () => onChanged(false),
              theme: theme,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Spotlight',
              selected: showSpotlight,
              onTap: () => onChanged(true),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends HookWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? YnabPalette.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : YnabPalette.mutedText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightSummaryCard extends HookWidget {
  const _SpotlightSummaryCard({
    required this.totalIncomeCents,
    required this.totalBudgetedCents,
    required this.totalActivityCents,
    required this.totalOverspentCents,
    required this.currencyCode,
  });

  final int totalIncomeCents;
  final int totalBudgetedCents;
  final int totalActivityCents;
  final int totalOverspentCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: YnabPalette.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: YnabPalette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spotlight',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _SpotlightRow(
            label: 'Income',
            value: formatCents(totalIncomeCents, currencyCode),
            valueColor: YnabPalette.progressGreen,
          ),
          _SpotlightRow(
            label: 'Budgeted',
            value: formatCents(totalBudgetedCents, currencyCode),
          ),
          _SpotlightRow(
            label: 'Spent',
            value: formatCents(totalActivityCents, currencyCode),
            valueColor: totalActivityCents > 0
                ? YnabPalette.negative
                : YnabPalette.mutedText,
          ),
          _SpotlightRow(
            label: 'Overspent',
            value: formatCents(totalOverspentCents, currencyCode),
            valueColor: totalOverspentCents > 0
                ? YnabPalette.negative
                : YnabPalette.mutedText,
          ),
        ],
      ),
    );
  }
}

class _SpotlightRow extends HookWidget {
  const _SpotlightRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: YnabPalette.mutedText,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
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
