import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
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
  final CurrencyCode currencyCode;
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
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final isReorderingEnvelopes = useState(false);
    final orderedEnvelopes = useState(List.of(envelopes));

    useEffect(() {
      orderedEnvelopes.value = List.of(envelopes);
      return null;
    }, [envelopes]);

    return Card(
      margin: EdgeInsets.zero,
      color: OpenBudgetPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: const BorderSide(color: OpenBudgetPalette.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isReorderingEnvelopes.value
                ? () => isReorderingEnvelopes.value = false
                : onToggleCollapsed ?? onEditCategory,
            onLongPress: () => _showCategoryMenu(context),
            child: Opacity(
              opacity: (category.isHidden ?? false) ? 0.5 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm + SpacingTokens.xs,
                ),
                decoration: const BoxDecoration(
                  color: OpenBudgetPalette.surfaceMuted,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(RadiusTokens.md),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      collapsed
                          ? Icons.chevron_right_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: OpenBudgetPalette.mutedText,
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    if (category.isHidden ?? false) ...[
                      const Icon(
                        Icons.visibility_off_rounded,
                        size: 14,
                        color: OpenBudgetPalette.mutedText,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                    ],
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.budgetColumnAvailable,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: OpenBudgetPalette.mutedText,
                          ),
                        ),
                        Text(
                          hideAmounts
                              ? hiddenAmountPlaceholder
                              : formatCents(
                                  categoryWithEnvelopes.totalAvailableCents,
                                  currencyCode,
                                ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _availableColor(
                              categoryWithEnvelopes.totalAvailableCents,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: OpenBudgetPalette.mutedText,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      l10n.envelopeReorderHint,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: OpenBudgetPalette.mutedText,
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
                leading: const Icon(
                  Icons.drag_handle_rounded,
                  color: OpenBudgetPalette.mutedText,
                ),
                title: Text(
                  envelope.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      onPressed: index > 0
                          ? () => _swapEnvelopes(
                              orderedEnvelopes,
                              index,
                              index - 1,
                            )
                          : null,
                      iconSize: 20,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded),
                      onPressed: index < orderedEnvelopes.value.length - 1
                          ? () => _swapEnvelopes(
                              orderedEnvelopes,
                              index,
                              index + 1,
                            )
                          : null,
                      iconSize: 20,
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
              yield Opacity(
                opacity: (envelope.isHidden ?? false) ? 0.5 : 1.0,
                child: EnvelopeRow(
                  envelope: envelope,
                  currencyCode: currencyCode,
                  isSelected: selectedEnvelopeId == envelopeId,
                  monthlyData: monthlyData,
                  goal: envelopeGoal,
                  hideAmounts: hideAmounts,
                  hideProgressBars: hideProgressBars,
                  onTap: onShowActivity != null
                      ? () =>
                            onShowActivity!(envelope, monthlyData, envelopeGoal)
                      : () => onEditEnvelope(envelope),
                  onLongPress: () => _showEnvelopeMenu(context, envelope),
                  onQuickBudget: onQuickBudget != null
                      ? () => onQuickBudget!(envelope)
                      : null,
                ),
              );
              if (entry.key < envelopes.length - 1) {
                yield const Divider(
                  height: 1,
                  color: OpenBudgetPalette.divider,
                );
              }
            }),
          if (!collapsed)
            Container(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.md,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: OpenBudgetPalette.divider),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.budgetCategoryTotal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: OpenBudgetPalette.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onAddEnvelope,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.budgetAddEnvelope),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OpenBudgetPalette.accentBlue,
                      side: const BorderSide(color: OpenBudgetPalette.divider),
                      backgroundColor: OpenBudgetPalette.surfaceMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm,
                        vertical: SpacingTokens.xs,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final isHidden = category.isHidden ?? false;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(l10n.budgetEditCategoryTitle),
              onTap: () {
                Navigator.of(ctx).pop();
                onEditCategory();
              },
            ),
            if (onReorderEnvelopes != null &&
                categoryWithEnvelopes.envelopes.length > 1)
              ListTile(
                leading: const Icon(Icons.swap_vert_rounded),
                title: Text(l10n.envelopeReorderHint),
                onTap: () {
                  Navigator.of(ctx).pop();
                  // Trigger reorder mode handled by parent.
                },
              ),
            if (onToggleHideCategory != null)
              ListTile(
                leading: Icon(
                  isHidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
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
              leading: const Icon(
                Icons.delete_rounded,
                color: ColorTokens.error,
              ),
              title: Text(
                l10n.deleteConfirmButton,
                style: const TextStyle(color: ColorTokens.error),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                onDeleteCategory();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEnvelopeMenu(BuildContext context, Envelope envelope) {
    final l10n = AppLocalizations.of(context);
    final isHidden = envelope.isHidden ?? false;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(l10n.editEnvelopeTitle),
              onTap: () {
                Navigator.of(ctx).pop();
                onEditEnvelope(envelope);
              },
            ),
            if (onQuickBudget != null)
              ListTile(
                leading: const Icon(Icons.flash_on_rounded),
                title: Text(l10n.quickBudgetTitle),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onQuickBudget!(envelope);
                },
              ),
            if (onToggleHideEnvelope != null)
              ListTile(
                leading: Icon(
                  isHidden
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
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
              leading: const Icon(
                Icons.delete_rounded,
                color: ColorTokens.error,
              ),
              title: Text(
                l10n.deleteConfirmButton,
                style: const TextStyle(color: ColorTokens.error),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                onDeleteEnvelope(envelope);
              },
            ),
          ],
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

  Color _availableColor(int cents) {
    if (cents > 0) return OpenBudgetPalette.progressGreen;
    if (cents < 0) return OpenBudgetPalette.negative;
    return OpenBudgetPalette.mutedText;
  }
}
