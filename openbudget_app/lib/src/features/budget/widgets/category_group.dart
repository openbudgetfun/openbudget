import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
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
    this.goalsMap = const {},
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
  final Map<String, EnvelopeGoal> goalsMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final envelopes = categoryWithEnvelopes.envelopes;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReorderingEnvelopes = useState(false);
    final orderedEnvelopes = useState(List.of(envelopes));

    useEffect(() {
      orderedEnvelopes.value = List.of(envelopes);
      return null;
    }, [envelopes]);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isReorderingEnvelopes.value
                ? () => isReorderingEnvelopes.value = false
                : onEditCategory,
            onLongPress: onReorderEnvelopes != null && envelopes.length > 1
                ? () => isReorderingEnvelopes.value = true
                : onDeleteCategory,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm + SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(80),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(RadiusTokens.md),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      category.name.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.budgetColumnBudgeted,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.budgetColumnSpent,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      l10n.budgetColumnAvailable,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          if (isReorderingEnvelopes.value) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      l10n.envelopeReorderHint,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
                leading: Icon(
                  Icons.drag_handle_rounded,
                  color: colorScheme.onSurfaceVariant,
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
            ...envelopes.asMap().entries.map((entry) {
              final envelope = entry.value;
              final envelopeId = envelope.id?.toString() ?? '';
              final monthlyData =
                  categoryWithEnvelopes.monthlyEnvelopes.isNotEmpty &&
                      entry.key < categoryWithEnvelopes.monthlyEnvelopes.length
                  ? categoryWithEnvelopes.monthlyEnvelopes[entry.key]
                  : null;
              final envelopeGoal = goalsMap[envelopeId];
              return EnvelopeRow(
                envelope: envelope,
                currencyCode: currencyCode,
                monthlyData: monthlyData,
                goal: envelopeGoal,
                onTap: onShowActivity != null
                    ? () => onShowActivity!(envelope, monthlyData, envelopeGoal)
                    : () => onEditEnvelope(envelope),
                onLongPress: () => onEditEnvelope(envelope),
                onQuickBudget: onQuickBudget != null
                    ? () => onQuickBudget!(envelope)
                    : null,
              );
            }),
          if (envelopes.isNotEmpty) const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm + SpacingTokens.xs,
              vertical: SpacingTokens.sm + 2,
            ),
            child: Row(
              children: [
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  flex: 4,
                  child: Text(
                    l10n.budgetCategoryTotal,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatCents(
                      categoryWithEnvelopes.totalBudgetedCents,
                      currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatCents(
                      categoryWithEnvelopes.totalSpentCents,
                      currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryWithEnvelopes.totalSpentCents > 0
                          ? ColorTokens.error
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _availableColor(
                      categoryWithEnvelopes.totalAvailableCents,
                    ).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (categoryWithEnvelopes.totalAvailableCents < 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: _availableColor(
                              categoryWithEnvelopes.totalAvailableCents,
                            ),
                          ),
                        ),
                      Text(
                        formatCents(
                          categoryWithEnvelopes.totalAvailableCents,
                          currencyCode,
                        ),
                        maxLines: 1,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _availableColor(
                            categoryWithEnvelopes.totalAvailableCents,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: SpacingTokens.md,
              bottom: SpacingTokens.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddEnvelope,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.budgetAddEnvelope),
              ),
            ),
          ),
        ],
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
    if (cents > 0) return ColorTokens.secondary;
    if (cents < 0) return ColorTokens.error;
    return ColorTokens.tertiary;
  }
}
