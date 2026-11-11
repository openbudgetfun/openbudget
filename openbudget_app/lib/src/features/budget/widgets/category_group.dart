import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CategoryGroup extends HookConsumerWidget {
  const CategoryGroup({
    required this.categoryWithEnvelopes,
    required this.currencyCode,
    required this.onAddEnvelope,
    required this.onDeleteCategory,
    required this.onEditCategory,
    required this.onEditEnvelope,
    required this.onDeleteEnvelope,
    this.onQuickBudget,
    this.onShowActivity,
    this.onReorderEnvelopes,
    this.onToggleHideCategory,
    this.onToggleHideEnvelope,
    this.onToggleCollapsed,
    this.showHidden = false,
    this.collapsed = false,
    this.goalsMap = const {},
    this.selectedEnvelopeId,
    super.key,
  });

  final CategoryWithEnvelopes categoryWithEnvelopes;
  final String currencyCode;
  final VoidCallback onAddEnvelope;
  final VoidCallback onDeleteCategory;
  final VoidCallback onEditCategory;
  final void Function(Envelope envelope) onEditEnvelope;
  final void Function(Envelope envelope) onDeleteEnvelope;
  final void Function(Envelope envelope)? onQuickBudget;
  final void Function(Envelope envelope, MonthlyEnvelopeData?, EnvelopeGoal?)?
  onShowActivity;
  final void Function(List<String> envelopeIds)? onReorderEnvelopes;
  final void Function({required bool isHidden})? onToggleHideCategory;
  final void Function(Envelope envelope, {required bool isHidden})?
  onToggleHideEnvelope;
  final VoidCallback? onToggleCollapsed;
  final bool showHidden;
  final bool collapsed;
  final Map<String, EnvelopeGoal> goalsMap;
  final String? selectedEnvelopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final envelopes = categoryWithEnvelopes.envelopes;
    final theme = Theme.of(context);
    final palette = theme.ob;
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final isReorderingEnvelopes = useState(false);
    final orderedEnvelopes = useState(List.of(envelopes));

    useEffect(() {
      orderedEnvelopes.value = List.of(envelopes);
      return null;
    }, [envelopes]);

    final totalAvailable = categoryWithEnvelopes.totalAvailableMinor;
    final availableTone = totalAvailable < 0
        ? ObTone.overspent
        : totalAvailable > 0
        ? ObTone.funded
        : ObTone.neutral;

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: isReorderingEnvelopes.value
                  ? () => isReorderingEnvelopes.value = false
                  : onToggleCollapsed,
              onLongPress: () =>
                  _showCategoryMenu(context, isReorderingEnvelopes),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Opacity(
                opacity: (category.isHidden ?? false) ? 0.55 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.sm,
                  ),
                  decoration: ObRoughDecoration(
                    color: palette.highlight,
                    radius: 10,
                    seed: 17,
                  ),
                  child: Row(
                    children: [
                      SkribbleIcon(
                        data: collapsed
                            ? OpenBudgetIcons.chevronRight
                            : OpenBudgetIcons.chevronDown,
                        size: 18,
                        color: palette.mutedInk,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      if (category.isHidden ?? false) ...[
                        SkribbleIcon(
                          data: OpenBudgetIcons.hidden,
                          size: 16,
                          color: palette.mutedInk,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                      ],
                      Expanded(
                        child: Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.ink,
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.budgetColumnAvailable,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
                          ObAmount(
                            hideAmounts
                                ? hiddenAmountPlaceholder
                                : formatMinorForCode(
                                    totalAvailable,
                                    currencyCode,
                                  ),
                            tone: availableTone,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      IconButton(
                        onPressed: onEditCategory,
                        tooltip: l10n.budgetEditCategoryTitle,
                        icon: SkribbleIcon(
                          data: OpenBudgetIcons.edit,
                          size: 20,
                          color: palette.brand,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (collapsed)
            const SizedBox.shrink()
          else if (isReorderingEnvelopes.value) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              child: Row(
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.info,
                    size: 16,
                    color: palette.mutedInk,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      l10n.envelopeReorderHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => isReorderingEnvelopes.value = false,
                    child: Text(l10n.budgetReorderDone),
                  ),
                ],
              ),
            ),
            ...orderedEnvelopes.value.asMap().entries.map((entry) {
              final index = entry.key;
              final envelope = entry.value;
              return ListTile(
                key: ValueKey(envelope.id),
                dense: true,
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.drag,
                  color: palette.mutedInk,
                ),
                title: Text(
                  envelope.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.chevronUp,
                        size: 20,
                      ),
                      tooltip: l10n.editPlanMoveUp,
                      onPressed: index > 0
                          ? () => _swapEnvelopes(
                              orderedEnvelopes,
                              index,
                              index - 1,
                            )
                          : null,
                    ),
                    IconButton(
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.chevronDown,
                        size: 20,
                      ),
                      tooltip: l10n.editPlanMoveDown,
                      onPressed: index < orderedEnvelopes.value.length - 1
                          ? () => _swapEnvelopes(
                              orderedEnvelopes,
                              index,
                              index + 1,
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ] else
            ...envelopes.asMap().entries.expand((entry) sync* {
              final envelope = entry.value;
              final envelopeId = envelope.id?.toString() ?? '';
              final monthlyData =
                  categoryWithEnvelopes.monthlyEnvelopes.isNotEmpty &&
                      entry.key < categoryWithEnvelopes.monthlyEnvelopes.length
                  ? categoryWithEnvelopes.monthlyEnvelopes[entry.key]
                  : null;
              final envelopeGoal = goalsMap[envelopeId];
              yield EnvelopeRow(
                envelope: envelope,
                currencyCode: currencyCode,
                isSelected: selectedEnvelopeId == envelopeId,
                monthlyData: monthlyData,
                goal: envelopeGoal,
                hideAmounts: hideAmounts,
                hideProgressBars: hideProgressBars,
                onTap: onShowActivity != null
                    ? () => onShowActivity!(envelope, monthlyData, envelopeGoal)
                    : () => onEditEnvelope(envelope),
                onLongPress: () => _showEnvelopeMenu(
                  context,
                  envelope,
                  isReorderingEnvelopes,
                ),
                onQuickBudget: onQuickBudget != null
                    ? () => onQuickBudget!(envelope)
                    : null,
              );
              if (entry.key < envelopes.length - 1) {
                yield Divider(height: 1, color: palette.line);
              }
            }),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.xs,
                SpacingTokens.md,
                SpacingTokens.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.budgetCategoryTotal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onAddEnvelope,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.add,
                      size: 18,
                      color: palette.brand,
                    ),
                    label: Text(l10n.budgetAddEnvelope),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryMenu(
    BuildContext context,
    ValueNotifier<bool> isReorderingEnvelopes,
  ) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final category = categoryWithEnvelopes.category;
    final isHidden = category.isHidden ?? false;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.edit,
                  color: palette.brand,
                ),
                title: Text(l10n.budgetEditCategoryTitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onEditCategory();
                },
              ),
              if (onReorderEnvelopes != null &&
                  categoryWithEnvelopes.envelopes.length > 1)
                ListTile(
                  leading: SkribbleIcon(
                    data: OpenBudgetIcons.sort,
                    color: palette.ink,
                  ),
                  title: Text(l10n.envelopeReorderHint),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    isReorderingEnvelopes.value = true;
                  },
                ),
              if (onToggleHideCategory != null)
                ListTile(
                  leading: SkribbleIcon(
                    data: isHidden
                        ? OpenBudgetIcons.visible
                        : OpenBudgetIcons.hidden,
                    color: palette.ink,
                  ),
                  title: Text(
                    isHidden
                        ? l10n.budgetUnhideCategory
                        : l10n.budgetHideCategory,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onToggleHideCategory!(isHidden: !isHidden);
                  },
                ),
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.delete,
                  color: palette.overspent,
                ),
                title: Text(
                  l10n.deleteConfirmButton,
                  style: TextStyle(color: palette.overspent),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onDeleteCategory();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnvelopeMenu(
    BuildContext context,
    Envelope envelope,
    ValueNotifier<bool> isReorderingEnvelopes,
  ) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final isHidden = envelope.isHidden ?? false;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.edit,
                  color: palette.brand,
                ),
                title: Text(l10n.editEnvelopeTitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onEditEnvelope(envelope);
                },
              ),
              if (onQuickBudget != null)
                ListTile(
                  leading: SkribbleIcon(
                    data: OpenBudgetIcons.quick,
                    color: palette.brand,
                  ),
                  title: Text(l10n.quickBudgetTitle),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onQuickBudget!(envelope);
                  },
                ),
              if (onReorderEnvelopes != null &&
                  categoryWithEnvelopes.envelopes.length > 1)
                ListTile(
                  leading: SkribbleIcon(
                    data: OpenBudgetIcons.sort,
                    color: palette.ink,
                  ),
                  title: Text(l10n.envelopeReorderHint),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    isReorderingEnvelopes.value = true;
                  },
                ),
              if (onToggleHideEnvelope != null)
                ListTile(
                  leading: SkribbleIcon(
                    data: isHidden
                        ? OpenBudgetIcons.visible
                        : OpenBudgetIcons.hidden,
                    color: palette.ink,
                  ),
                  title: Text(
                    isHidden
                        ? l10n.budgetUnhideEnvelope
                        : l10n.budgetHideEnvelope,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onToggleHideEnvelope!(envelope, isHidden: !isHidden);
                  },
                ),
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.delete,
                  color: palette.overspent,
                ),
                title: Text(
                  l10n.deleteConfirmButton,
                  style: TextStyle(color: palette.overspent),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onDeleteEnvelope(envelope);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _swapEnvelopes(
    ValueNotifier<List<Envelope>> orderedEnvelopes,
    int from,
    int to,
  ) {
    final list = List.of(orderedEnvelopes.value);
    final item = list.removeAt(from);
    list.insert(to, item);
    orderedEnvelopes.value = list;

    final envelopeIds = list
        .map((e) => e.id?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();

    onReorderEnvelopes?.call(envelopeIds);
  }
}
