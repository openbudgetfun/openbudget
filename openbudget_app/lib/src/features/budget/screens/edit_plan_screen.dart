import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/add_category_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/add_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditPlanScreen extends HookConsumerWidget {
  const EditPlanScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final goalsAsync = ref.watch(budgetGoalsProvider(budgetId));

    return summaryAsync.when(
      loading: () => Scaffold(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        appBar: _EditPlanAppBar(budgetId: budgetId),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        appBar: _EditPlanAppBar(budgetId: budgetId),
        body: Center(
          child: Text(AppLocalizations.of(context).editPlanLoadError),
        ),
      ),
      data: (summary) {
        final goalsMap = goalsAsync.asData?.value ?? <String, EnvelopeGoal>{};
        final currencyCode = CurrencyCode.values.firstWhere(
          (currency) => currency.code == summary.budget.currencyCode,
          orElse: () => CurrencyCode.usd,
        );

        return _EditPlanContent(
          budgetId: budgetId,
          summary: summary,
          goalsMap: goalsMap,
          currencyCode: currencyCode,
        );
      },
    );
  }
}

class _EditPlanContent extends HookConsumerWidget {
  const _EditPlanContent({
    required this.budgetId,
    required this.summary,
    required this.goalsMap,
    required this.currencyCode,
  });

  final String budgetId;
  final BudgetSummary summary;
  final Map<String, EnvelopeGoal> goalsMap;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isReordering = useState(false);
    final isSavingReorder = useState(false);
    final orderedCategories = useState(_visibleCategories(summary.categories));

    useEffect(() {
      orderedCategories.value = _visibleCategories(summary.categories);
      return null;
    }, [summary.categories]);

    final monthlyTargetsCents = _computeMonthlyTargets(
      categories: orderedCategories.value,
      goalsMap: goalsMap,
    );
    final monthlyIncomeCents = summary.totalIncomeCents;
    final monthlyTargetsProgress = monthlyIncomeCents <= 0
        ? 0.0
        : (monthlyTargetsCents / monthlyIncomeCents).clamp(0.0, 1.0);

    Future<void> saveCategoryOrder() async {
      if (!isReordering.value || isSavingReorder.value) return;
      final categoryIds = orderedCategories.value
          .map((entry) => entry.category.id?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      isSavingReorder.value = true;
      try {
        if (categoryIds.isNotEmpty) {
          await ref
              .read(categoryActionsProvider.notifier)
              .reorderCategories(budgetId: budgetId, categoryIds: categoryIds);
        }
        isReordering.value = false;
      } on Exception catch (_) {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.budgetReorderError,
          variant: AppToastVariant.error,
        );
      } finally {
        isSavingReorder.value = false;
      }
    }

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: _EditPlanAppBar(budgetId: budgetId),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xxl,
            ),
            child: Column(
              children: [
                Text(
                  formatCents(monthlyTargetsCents, currencyCode),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: OpenBudgetPalette.fgOnBrandFor(Theme.of(context)),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.editPlanCostToBeMe,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: OpenBudgetPalette.fgOnBrandFor(
                      Theme.of(context),
                    ).withAlpha(240),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -SpacingTokens.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: OpenBudgetPalette.bgSecondaryFor(
                        Theme.of(context),
                      ),
                      borderRadius: BorderRadius.circular(RadiusTokens.lg),
                      border: Border.all(
                        color: OpenBudgetPalette.borderSubtleFor(
                          Theme.of(context),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: OpenBudgetPalette.fgPrimaryFor(
                            theme,
                          ).withAlpha(20),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.editPlanMonthlyTargets,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                formatCents(monthlyTargetsCents, currencyCode),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: OpenBudgetPalette.fgSuccessFor(
                                    Theme.of(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.sm,
                            ),
                            child: LinearProgressIndicator(
                              value: monthlyTargetsProgress,
                              minHeight: 12,
                              backgroundColor:
                                  OpenBudgetPalette.borderSubtleFor(
                                    Theme.of(context),
                                  ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                OpenBudgetPalette.fgSuccessFor(
                                  Theme.of(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Row(
                            children: [
                              Text(
                                l10n.editPlanMonthlyIncome,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.xs),
                              Text(
                                formatCents(monthlyIncomeCents, currencyCode),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingTokens.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.sm,
                            ),
                            child: LinearProgressIndicator(
                              value: 1,
                              minHeight: 12,
                              backgroundColor:
                                  OpenBudgetPalette.borderSubtleFor(
                                    Theme.of(context),
                                  ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                OpenBudgetPalette.borderSubtleFor(
                                  Theme.of(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: OpenBudgetPalette.bgAccentFor(
                        Theme.of(context),
                      ).withAlpha(50),
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                      border: Border.all(
                        color: OpenBudgetPalette.borderSubtleFor(
                          Theme.of(context),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: OpenBudgetPalette.bgBrandFor(
                                Theme.of(context),
                              ),
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.xl,
                              ),
                            ),
                            child: Icon(
                              Icons.attach_money_rounded,
                              color: OpenBudgetPalette.fgOnBrandFor(
                                Theme.of(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.editPlanCostPromptTitle,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: SpacingTokens.xs),
                                Text(
                                  l10n.editPlanCostPromptSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: OpenBudgetPalette.fgSecondaryFor(
                                      Theme.of(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _showAddCategoryDialog(
                            context,
                            summary.categories.length,
                          ),
                          icon: const Icon(Icons.create_new_folder_rounded),
                          label: Text(l10n.editPlanNewGroup),
                          style: FilledButton.styleFrom(
                            backgroundColor: OpenBudgetPalette.bgTertiaryFor(
                              Theme.of(context),
                            ),
                            foregroundColor:
                                OpenBudgetPalette.fgPrimaryEmphasisFor(theme),
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isSavingReorder.value
                              ? null
                              : () async {
                                  if (isReordering.value) {
                                    await saveCategoryOrder();
                                    return;
                                  }
                                  isReordering.value = true;
                                },
                          icon: isReordering.value
                              ? const Icon(Icons.check_rounded)
                              : const Icon(Icons.swap_vert_rounded),
                          label: Text(
                            isReordering.value
                                ? l10n.budgetReorderDone
                                : l10n.editPlanReorder,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: OpenBudgetPalette.bgTertiaryFor(
                              Theme.of(context),
                            ),
                            foregroundColor:
                                OpenBudgetPalette.fgPrimaryEmphasisFor(theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isReordering.value) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      l10n.budgetReorderHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: OpenBudgetPalette.fgSecondaryFor(
                          Theme.of(context),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  ...orderedCategories.value.map(
                    (categoryWithEnvelopes) => Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                      child: _EditPlanCategoryCard(
                        categoryWithEnvelopes: categoryWithEnvelopes,
                        goalsMap: goalsMap,
                        currencyCode: currencyCode,
                        reordering: isReordering.value,
                        onMoveUp: () => _moveCategory(
                          orderedCategories,
                          categoryWithEnvelopes,
                          moveUp: true,
                        ),
                        onMoveDown: () => _moveCategory(
                          orderedCategories,
                          categoryWithEnvelopes,
                          moveUp: false,
                        ),
                        onAddEnvelope: () => _showAddEnvelopeDialog(
                          context,
                          categoryWithEnvelopes.category.id?.toString() ?? '',
                          currencyCode,
                          year: summary.year,
                          month: summary.month,
                        ),
                        onEditDetails: () => _showCategoryDetailsSheet(
                          context: context,
                          ref: ref,
                          categoryWithEnvelopes: categoryWithEnvelopes,
                        ),
                        onOpenTarget: (envelope, existingGoal) =>
                            _showSetGoalDialog(
                              context: context,
                              envelope: envelope,
                              existingGoal: existingGoal,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<CategoryWithEnvelopes> _visibleCategories(
    List<CategoryWithEnvelopes> categories,
  ) =>
      categories.where((entry) => !(entry.category.isHidden ?? false)).toList();

  int _computeMonthlyTargets({
    required List<CategoryWithEnvelopes> categories,
    required Map<String, EnvelopeGoal> goalsMap,
  }) {
    var total = 0;
    for (final categoryWithEnvelopes in categories) {
      for (final envelope in categoryWithEnvelopes.envelopes) {
        final envelopeId = envelope.id?.toString();
        if (envelopeId == null) continue;
        final goal = goalsMap[envelopeId];
        if (goal == null) continue;
        total += _goalTargetCents(goal);
      }
    }
    return total;
  }

  int _goalTargetCents(EnvelopeGoal goal) => switch (goal.goalType) {
      'monthly_funding' => goal.monthlyFundingCents ?? goal.targetAmountCents,
      _ => goal.targetAmountCents,
    };

  Future<void> _showSetGoalDialog({
    required BuildContext context,
    required Envelope envelope,
    required EnvelopeGoal? existingGoal,
  }) async {
    final envelopeId = envelope.id?.toString();
    if (envelopeId == null || envelopeId.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (_) => SetGoalDialog(
        budgetId: budgetId,
        envelopeId: envelopeId,
        existingGoal: existingGoal,
        envelopeName: envelope.name,
        currencyCode: currencyCode,
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
    if (categoryId.isEmpty) return;
    showDialog<void>(
      context: context,
      barrierColor: OpenBudgetPalette.overlayScrimFor(
        Theme.of(context),
      ).withAlpha(210),
      builder: (_) => AddEnvelopeDialog(
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  Future<void> _showCategoryDetailsSheet({
    required BuildContext context,
    required WidgetRef ref,
    required CategoryWithEnvelopes categoryWithEnvelopes,
  }) async {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.editPlanDetails,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  l10n.editPlanCategoryGroupName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                    border: Border.all(
                      color: OpenBudgetPalette.borderSubtleFor(
                        Theme.of(context),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm + 2,
                    ),
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _confirmHideGroup(
                            context: context,
                            ref: ref,
                            categoryWithEnvelopes: categoryWithEnvelopes,
                          );
                        },
                        icon: const Icon(Icons.visibility_off_rounded),
                        label: Text(l10n.editPlanHide),
                        style: FilledButton.styleFrom(
                          backgroundColor: OpenBudgetPalette.bgTertiaryFor(
                            Theme.of(context),
                          ),
                          foregroundColor: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _confirmDeleteGroup(
                            context: context,
                            ref: ref,
                            categoryWithEnvelopes: categoryWithEnvelopes,
                          );
                        },
                        icon: const Icon(Icons.delete_rounded),
                        label: Text(l10n.editPlanDelete),
                        style: FilledButton.styleFrom(
                          backgroundColor: OpenBudgetPalette.bgTertiaryFor(
                            Theme.of(context),
                          ),
                          foregroundColor: OpenBudgetPalette.fgErrorFor(
                            Theme.of(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<void> _confirmHideGroup({
    required BuildContext context,
    required WidgetRef ref,
    required CategoryWithEnvelopes categoryWithEnvelopes,
  }) async {
    final l10n = AppLocalizations.of(context);
    final shouldHide = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.editPlanHideGroupDialogDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.editPlanHideGroupAndCategories),
          ),
        ],
      ),
    );
    if (shouldHide != true || !context.mounted) return;

    final categoryId = categoryWithEnvelopes.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .toggleHidden(
            categoryId: categoryId,
            budgetId: budgetId,
            isHidden: true,
          );

      for (final envelope in categoryWithEnvelopes.envelopes) {
        final envelopeId = envelope.id?.toString() ?? '';
        if (envelopeId.isEmpty) continue;
        await ref
            .read(envelopeActionsProvider.notifier)
            .toggleHidden(
              envelopeId: envelopeId,
              categoryId: categoryId,
              budgetId: budgetId,
              isHidden: true,
            );
      }

      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.editPlanCategoryGroupHidden,
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.editPlanHideGroupError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _confirmDeleteGroup({
    required BuildContext context,
    required WidgetRef ref,
    required CategoryWithEnvelopes categoryWithEnvelopes,
  }) async {
    final l10n = AppLocalizations.of(context);
    final envelopeCount = categoryWithEnvelopes.envelopes.length;
    final envelopeSummary = envelopeCount == 1
        ? l10n.editPlanEnvelopeCount(1)
        : l10n.editPlanEnvelopeCount(envelopeCount);
    final allocated = formatCents(
      categoryWithEnvelopes.totalBudgetedCents,
      currencyCode,
    );
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          l10n.editPlanDeleteCategoryGroupConfirm(
            categoryWithEnvelopes.category.name,
            envelopeSummary,
            allocated,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.editPlanDelete),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    final categoryId = categoryWithEnvelopes.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, budgetId: budgetId);
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.editPlanDeleteGroupError,
        variant: AppToastVariant.error,
      );
    }
  }

  void _moveCategory(
    ValueNotifier<List<CategoryWithEnvelopes>> orderedCategories,
    CategoryWithEnvelopes category, {
    required bool moveUp,
  }) {
    final current = List.of(orderedCategories.value);
    final index = current.indexWhere(
      (entry) => entry.category == category.category,
    );
    if (index == -1) return;
    if (moveUp && index == 0) return;
    if (!moveUp && index == current.length - 1) return;
    final targetIndex = moveUp ? index - 1 : index + 1;
    final moving = current.removeAt(index);
    current.insert(targetIndex, moving);
    orderedCategories.value = current;
  }
}

class _EditPlanCategoryCard extends HookWidget {
  const _EditPlanCategoryCard({
    required this.categoryWithEnvelopes,
    required this.goalsMap,
    required this.currencyCode,
    required this.reordering,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onAddEnvelope,
    required this.onEditDetails,
    required this.onOpenTarget,
  });

  final CategoryWithEnvelopes categoryWithEnvelopes;
  final Map<String, EnvelopeGoal> goalsMap;
  final CurrencyCode currencyCode;
  final bool reordering;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onAddEnvelope;
  final VoidCallback onEditDetails;
  final void Function(Envelope envelope, EnvelopeGoal? existingGoal)
  onOpenTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categoryId = categoryWithEnvelopes.category.id?.toString() ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm + 2,
            ),
            decoration: BoxDecoration(
              color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(RadiusTokens.md),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categoryWithEnvelopes.category.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (reordering) ...[
                  IconButton(
                    onPressed: onMoveUp,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    tooltip: l10n.editPlanMoveUp,
                  ),
                  IconButton(
                    onPressed: onMoveDown,
                    icon: const Icon(Icons.arrow_downward_rounded),
                    tooltip: l10n.editPlanMoveDown,
                  ),
                ] else ...[
                  IconButton(
                    onPressed: onAddEnvelope,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    tooltip: l10n.editPlanAddEnvelope,
                  ),
                  IconButton(
                    key: Key('edit-plan-group-menu-$categoryId'),
                    onPressed: onEditDetails,
                    icon: const Icon(Icons.more_horiz_rounded),
                    tooltip: l10n.editPlanGroupDetails,
                  ),
                ],
              ],
            ),
          ),
          ...categoryWithEnvelopes.envelopes.asMap().entries.expand((
            entry,
          ) sync* {
            final index = entry.key;
            final envelope = entry.value;
            final envelopeId = envelope.id?.toString() ?? '';
            final goal = envelopeId.isEmpty ? null : goalsMap[envelopeId];
            final targetCents = goal == null
                ? null
                : switch (goal.goalType) {
                    'monthly_funding' =>
                      goal.monthlyFundingCents ?? goal.targetAmountCents,
                    _ => goal.targetAmountCents,
                  };

            yield InkWell(
              onTap: reordering ? null : () => onOpenTarget(envelope, goal),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm + 1,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_rounded,
                      size: 16,
                      color: OpenBudgetPalette.fgSecondaryFor(
                        Theme.of(context),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        envelope.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!reordering)
                      targetCents == null
                          ? TextButton.icon(
                              onPressed: () => onOpenTarget(envelope, goal),
                              icon: const Icon(Icons.add_circle, size: 16),
                              label: Text(l10n.editPlanAddTarget),
                              style: TextButton.styleFrom(
                                foregroundColor: OpenBudgetPalette.bgBrandFor(
                                  Theme.of(context),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpacingTokens.xs,
                                ),
                              ),
                            )
                          : Text(
                              formatCents(targetCents, currencyCode),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                            ),
                  ],
                ),
              ),
            );

            if (index < categoryWithEnvelopes.envelopes.length - 1) {
              yield Divider(
                height: 1,
                color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
              );
            }
          }),
        ],
      ),
    );
  }
}

class _EditPlanAppBar extends HookWidget implements PreferredSizeWidget {
  const _EditPlanAppBar({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
      foregroundColor: OpenBudgetPalette.fgOnBrandFor(Theme.of(context)),
      leadingWidth: 102,
      leading: TextButton.icon(
        onPressed: () =>
            context.goNamed(planRoute, pathParameters: {'id': budgetId}),
        style: TextButton.styleFrom(
          foregroundColor: OpenBudgetPalette.fgOnBrandFor(Theme.of(context)),
        ),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        label: Text(l10n.planTitle),
      ),
      centerTitle: true,
      title: Text(
        l10n.editPlanTitle,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              context.goNamed(planRoute, pathParameters: {'id': budgetId}),
          style: TextButton.styleFrom(
            foregroundColor: OpenBudgetPalette.fgOnBrandFor(Theme.of(context)),
          ),
          child: Text(l10n.dialogNext),
        ),
        const SizedBox(width: SpacingTokens.xs),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
