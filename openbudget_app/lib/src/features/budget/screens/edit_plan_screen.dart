import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
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

/// The plan's edit mode: reorder categories, add groups and envelopes, and
/// set one goal per envelope. Targets come from the month view's goals.
class EditPlanScreen extends HookConsumerWidget {
  const EditPlanScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));
    final viewAsync = ref.watch(budgetMonthProvider(entityId));

    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;

    return groupsAsync.when(
      loading: () => Scaffold(
        backgroundColor: palette.canvas,
        appBar: _EditPlanAppBar(entityId: entityId),
        body: Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: palette.canvas,
        appBar: _EditPlanAppBar(entityId: entityId),
        body: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.editPlanTitle,
            message: l10n.editPlanLoadError,
          ),
        ),
      ),
      data: (groups) {
        final view = viewAsync.value;
        final currencyCode = view?.currencyCode ?? '';

        return _EditPlanContent(
          entityId: entityId,
          groups: groups,
          summary: view?.summary,
          currencyCode: currencyCode,
        );
      },
    );
  }
}

class _EditPlanContent extends HookConsumerWidget {
  const _EditPlanContent({
    required this.entityId,
    required this.groups,
    required this.summary,
    required this.currencyCode,
  });

  final String entityId;
  final List<CategoryMonthGroup> groups;
  final BudgetMonthSummary? summary;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isReordering = useState(false);
    final isSavingReorder = useState(false);
    final orderedCategories = useState(_visibleCategories(groups));

    useEffect(() {
      orderedCategories.value = _visibleCategories(groups);
      return null;
    }, [groups]);

    final monthlyTargetsMinor = _computeMonthlyTargets(
      categories: orderedCategories.value,
    );
    final monthlyIncomeMinor = summary?.incomeMinor ?? 0;
    final monthlyTargetsProgress = monthlyIncomeMinor <= 0
        ? 0.0
        : (monthlyTargetsMinor / monthlyIncomeMinor).clamp(0.0, 1.0);
    final month = ref.watch(selectedYyyymmProvider(entityId));

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
              .reorderCategories(entityId: entityId, categoryIds: categoryIds);
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
      appBar: _EditPlanAppBar(entityId: entityId),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          ObCard(
            tone: ObTone.brand,
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              children: [
                ObAmount(
                  formatMinorForCode(monthlyTargetsMinor, currencyCode),
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
                  amount: formatMinorForCode(monthlyTargetsMinor, currencyCode),
                  fraction: monthlyTargetsProgress,
                  tone: ObTone.funded,
                ),
                const Divider(height: SpacingTokens.lg),
                _TargetRow(
                  label: l10n.editPlanMonthlyIncome,
                  amount: formatMinorForCode(monthlyIncomeMinor, currencyCode),
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
                    groups.length,
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
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.md),
              child: _EditPlanCategoryCard(
                group: group,
                currencyCode: currencyCode,
                reordering: isReordering.value,
                onMoveUp: () => _moveCategory(
                  orderedCategories,
                  group,
                  moveUp: true,
                ),
                onMoveDown: () => _moveCategory(
                  orderedCategories,
                  group,
                  moveUp: false,
                ),
                onAddEnvelope: () => _showAddEnvelopeDialog(
                  context,
                  group.category.id?.toString() ?? '',
                  currencyCode,
                  month: month,
                ),
                onEditDetails: () => _showCategoryDetailsSheet(
                  context: context,
                  ref: ref,
                  group: group,
                ),
                onOpenTarget: (monthEnvelope) => _showSetGoalDialog(
                  context: context,
                  monthEnvelope: monthEnvelope,
                  month: month,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<CategoryMonthGroup> _visibleCategories(
    List<CategoryMonthGroup> categories,
  ) => categories.where((entry) => !entry.category.isHidden).toList();

  /// The month's goal targets: every visible envelope's goal amount. A
  /// monthly-funding goal needs its amount each month; a target goal is
  /// the pot itself, so the headline is deliberately generous.
  int _computeMonthlyTargets({
    required List<CategoryMonthGroup> categories,
  }) {
    var total = 0;
    for (final group in categories) {
      for (final envelope in group.envelopes) {
        final goal = envelope.goal;
        if (goal == null) continue;
        total += goal.amountMinor;
      }
    }
    return total;
  }

  Future<void> _showSetGoalDialog({
    required BuildContext context,
    required EnvelopeMonthView monthEnvelope,
    required int month,
  }) async {
    final envelopeId = monthEnvelope.envelope.id?.toString();
    if (envelopeId == null || envelopeId.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (_) => SetGoalDialog(
        entityId: entityId,
        monthEnvelope: monthEnvelope,
        currencyCode: currencyCode,
        month: month,
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, int nextSortOrder) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) =>
            AddCategoryDialog(entityId: entityId, nextSortOrder: nextSortOrder),
      ),
    );
  }

  void _showAddEnvelopeDialog(
    BuildContext context,
    String categoryId,
    String currencyCode, {
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
          entityId: entityId,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  Future<void> _showCategoryDetailsSheet({
    required BuildContext context,
    required WidgetRef ref,
    required CategoryMonthGroup group,
  }) async {
    final l10n = AppLocalizations.of(context);
    final category = group.category;
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
                            group: group,
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
                            group: group,
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
    required CategoryMonthGroup group,
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

    final categoryId = group.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .toggleHidden(
            categoryId: categoryId,
            entityId: entityId,
            isHidden: true,
          );

      for (final envelope in group.envelopes) {
        final envelopeId = envelope.envelope.id?.toString() ?? '';
        if (envelopeId.isEmpty) continue;
        await ref
            .read(envelopeActionsProvider.notifier)
            .toggleHidden(
              envelopeId: envelopeId,
              entityId: entityId,
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
    required CategoryMonthGroup group,
  }) async {
    final l10n = AppLocalizations.of(context);
    final envelopeCount = group.envelopes.length;
    final envelopeSummary = envelopeCount == 1
        ? l10n.editPlanEnvelopeCount(1)
        : l10n.editPlanEnvelopeCount(envelopeCount);
    final allocated = formatMinorForCode(group.allocatedMinor, currencyCode);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(
          l10n.editPlanDeleteCategoryGroupConfirm(
            group.category.name,
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

    final categoryId = group.category.id?.toString() ?? '';
    if (categoryId.isEmpty) return;

    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, entityId: entityId);
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
    ValueNotifier<List<CategoryMonthGroup>> orderedCategories,
    CategoryMonthGroup category, {
    required bool moveUp,
  }) {
    final current = List.of(orderedCategories.value);
    final index = current.indexWhere(
      (entry) => entry.category.id == category.category.id,
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
    required this.group,
    required this.currencyCode,
    required this.reordering,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onAddEnvelope,
    required this.onEditDetails,
    required this.onOpenTarget,
  });

  final CategoryMonthGroup group;
  final String currencyCode;
  final bool reordering;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onAddEnvelope;
  final VoidCallback onEditDetails;
  final void Function(EnvelopeMonthView monthEnvelope) onOpenTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final categoryId = group.category.id?.toString() ?? '';

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
                    group.category.name,
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
          ...group.envelopes.asMap().entries.expand((entry) sync* {
            final index = entry.key;
            final monthEnvelope = entry.value;
            final goal = monthEnvelope.goal;
            final targetMinor = goal?.amountMinor;

            yield InkWell(
              onTap: reordering ? null : () => onOpenTarget(monthEnvelope),
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
                        monthEnvelope.envelope.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    if (!reordering && targetMinor == null)
                      TextButton.icon(
                        onPressed: () => onOpenTarget(monthEnvelope),
                        icon: SkribbleIcon(
                          data: OpenBudgetIcons.addCircle,
                          size: 18,
                          color: palette.brand,
                        ),
                        label: Text(l10n.editPlanAddTarget),
                      ),
                    if (!reordering && targetMinor != null)
                      ObAmount(
                        formatMinorForCode(targetMinor, currencyCode),
                        style: theme.textTheme.titleMedium,
                      ),
                  ],
                ),
              ),
            );

            if (index < group.envelopes.length - 1) {
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
  const _EditPlanAppBar({required this.entityId});

  final String entityId;

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
            context.goNamed(planRoute, pathParameters: {'entityId': entityId}),
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
          onPressed: () => context.goNamed(
            planRoute,
            pathParameters: {'entityId': entityId},
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
