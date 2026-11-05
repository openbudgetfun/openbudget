import 'dart:async';

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
import 'package:openbudget_ui/openbudget_ui.dart';

class EditPlanScreen extends HookConsumerWidget {
  const EditPlanScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final goalsAsync = ref.watch(budgetGoalsProvider(budgetId));

    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;

    return summaryAsync.when(
      loading: () => Scaffold(
        backgroundColor: palette.canvas,
        appBar: _EditPlanAppBar(budgetId: budgetId),
        body: Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: palette.canvas,
        appBar: _EditPlanAppBar(budgetId: budgetId),
        body: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.editPlanTitle,
            message: l10n.editPlanLoadError,
          ),
        ),
      ),
      data: (summary) {
        final goalsMap = goalsAsync.asData?.value ?? <String, EnvelopeGoal>{};
        final currencyCode = summary.budget.currencyCode;

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
  final String currencyCode;

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

    final palette = theme.ob;

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: _EditPlanAppBar(budgetId: budgetId),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          ObCard(
            tone: ObTone.brand,
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              children: [
                ObAmount(
                  formatCentsForCode(monthlyTargetsCents, currencyCode),
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.editPlanCostToBeMe,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          ObCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              children: [
                _TargetRow(
                  label: l10n.editPlanMonthlyTargets,
                  amount: formatCentsForCode(monthlyTargetsCents, currencyCode),
                  fraction: monthlyTargetsProgress,
                  tone: ObTone.funded,
                ),
                const Divider(height: SpacingTokens.lg),
                _TargetRow(
                  label: l10n.editPlanMonthlyIncome,
                  amount: formatCentsForCode(monthlyIncomeCents, currencyCode),
                  fraction: 1,
                  tone: ObTone.neutral,
                  trailing: SkribbleIcon(
                    data: OpenBudgetIcons.edit,
                    size: 16,
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          ObCard(
            tone: ObTone.review,
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: ObRoughDecoration(
                    color: palette.surface,
                    outline: palette.quietPen,
                    seed: 59,
                  ),
                  child: SkribbleIcon(
                    data: OpenBudgetIcons.money,
                    color: palette.review,
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
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.editPlanCostPromptSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddCategoryDialog(
                    context,
                    summary.categories.length,
                  ),
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.newFolder,
                    size: 18,
                    color: palette.brand,
                  ),
                  label: Text(l10n.editPlanNewGroup),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSavingReorder.value
                      ? null
                      : () async {
                          if (isReordering.value) {
                            await saveCategoryOrder();
                            return;
                          }
                          isReordering.value = true;
                        },
                  icon: SkribbleIcon(
                    data: isReordering.value
                        ? OpenBudgetIcons.check
                        : OpenBudgetIcons.sort,
                    size: 18,
                    color: palette.brand,
                  ),
                  label: Text(
                    isReordering.value
                        ? l10n.budgetReorderDone
                        : l10n.editPlanReorder,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
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
                color: palette.mutedInk,
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
                onOpenTarget: (envelope, existingGoal) => _showSetGoalDialog(
                  context: context,
                  envelope: envelope,
                  existingGoal: existingGoal,
                ),
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
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) =>
            AddCategoryDialog(budgetId: budgetId, nextSortOrder: nextSortOrder),
      ),
    );
  }

  void _showAddEnvelopeDialog(
    BuildContext context,
    String categoryId,
    String currencyCode, {
    required int year,
    required int month,
  }) {
    if (categoryId.isEmpty) return;
    unawaited(
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
    final palette = theme.ob;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.canvas,
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
                    tooltip: MaterialLocalizations.of(
                      sheetContext,
                    ).closeButtonTooltip,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.close,
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                l10n.editPlanCategoryGroupName,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              ObCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm + 2,
                ),
                child: Text(
                  category.name,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        unawaited(
                          _confirmHideGroup(
                            context: context,
                            ref: ref,
                            categoryWithEnvelopes: categoryWithEnvelopes,
                          ),
                        );
                      },
                      icon: SkribbleIcon(
                        data: OpenBudgetIcons.hidden,
                        size: 18,
                        color: palette.brand,
                      ),
                      label: Text(l10n.editPlanHide),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        unawaited(
                          _confirmDeleteGroup(
                            context: context,
                            ref: ref,
                            categoryWithEnvelopes: categoryWithEnvelopes,
                          ),
                        );
                      },
                      icon: SkribbleIcon(
                        data: OpenBudgetIcons.delete,
                        size: 18,
                        color: palette.overspent,
                      ),
                      label: Text(l10n.editPlanDelete),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: palette.overspent,
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
    final allocated = formatCentsForCode(
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
  final String currencyCode;
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
    final palette = theme.ob;
    final categoryId = categoryWithEnvelopes.category.id?.toString() ?? '';

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.xs,
            ),
            decoration: ObRoughDecoration(
              color: palette.highlight,
              radius: 10,
              seed: 61,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categoryWithEnvelopes.category.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                ),
                if (reordering) ...[
                  IconButton(
                    onPressed: onMoveUp,
                    icon: const SkribbleIcon(
                      data: OpenBudgetIcons.chevronUp,
                    ),
                    tooltip: l10n.editPlanMoveUp,
                  ),
                  IconButton(
                    onPressed: onMoveDown,
                    icon: const SkribbleIcon(
                      data: OpenBudgetIcons.chevronDown,
                    ),
                    tooltip: l10n.editPlanMoveDown,
                  ),
                ] else ...[
                  IconButton(
                    onPressed: onAddEnvelope,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.addCircle,
                      color: palette.brand,
                    ),
                    tooltip: l10n.editPlanAddEnvelope,
                  ),
                  IconButton(
                    key: Key('edit-plan-group-menu-$categoryId'),
                    onPressed: onEditDetails,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.more,
                      color: palette.ink,
                    ),
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
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    SkribbleIcon(
                      data: OpenBudgetIcons.envelope,
                      size: 18,
                      color: palette.mutedInk,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        envelope.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    if (!reordering && targetCents == null)
                      TextButton.icon(
                        onPressed: () => onOpenTarget(envelope, goal),
                        icon: SkribbleIcon(
                          data: OpenBudgetIcons.addCircle,
                          size: 18,
                          color: palette.brand,
                        ),
                        label: Text(l10n.editPlanAddTarget),
                      ),
                    if (!reordering && targetCents != null)
                      ObAmount(
                        formatCentsForCode(targetCents, currencyCode),
                        style: theme.textTheme.titleMedium,
                      ),
                  ],
                ),
              ),
            );

            if (index < categoryWithEnvelopes.envelopes.length - 1) {
              yield Divider(height: 1, color: palette.line);
            }
          }),
        ],
      ),
    );
  }
}

class _TargetRow extends HookWidget {
  const _TargetRow({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.tone,
    this.trailing,
  });

  final String label;
  final String amount;
  final double fraction;
  final ObTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Row(
      children: [
        ObEnvelopeGauge(
          fraction: fraction,
          semanticLabel: label,
          tone: tone,
          width: 46,
          seed: 7,
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
        ),
        if (trailing != null) ...[
          trailing!,
          const SizedBox(width: SpacingTokens.xs),
        ],
        ObAmount(amount, tone: tone, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _EditPlanAppBar extends HookWidget implements PreferredSizeWidget {
  const _EditPlanAppBar({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    return AppBar(
      backgroundColor: palette.canvas,
      foregroundColor: palette.ink,
      surfaceTintColor: palette.canvas,
      leadingWidth: 108,
      leading: TextButton.icon(
        onPressed: () =>
            context.goNamed(planRoute, pathParameters: {'id': budgetId}),
        style: TextButton.styleFrom(foregroundColor: palette.ink),
        icon: SkribbleIcon(
          data: OpenBudgetIcons.back,
          size: 16,
          color: palette.ink,
        ),
        label: Text(l10n.planTitle),
      ),
      centerTitle: true,
      title: Text(
        l10n.editPlanTitle,
        style: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              context.goNamed(planRoute, pathParameters: {'id': budgetId}),
          child: Text(l10n.dialogNext),
        ),
        const SizedBox(width: SpacingTokens.xs),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
