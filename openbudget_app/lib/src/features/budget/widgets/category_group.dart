import 'package:flutter/material.dart';
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
    required this.onEditEnvelope,
    required this.onDeleteEnvelope,
    super.key,
  });

  final CategoryWithEnvelopes categoryWithEnvelopes;
  final CurrencyCode currencyCode;
  final VoidCallback onAddEnvelope;
  final VoidCallback onDeleteCategory;
  final void Function(Envelope envelope) onEditEnvelope;
  final void Function(Envelope envelope) onDeleteEnvelope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final envelopes = categoryWithEnvelopes.envelopes;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onLongPress: onDeleteCategory,
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
          ...envelopes.asMap().entries.map((entry) {
            final envelope = entry.value;
            final monthlyData =
                categoryWithEnvelopes.monthlyEnvelopes.isNotEmpty &&
                    entry.key < categoryWithEnvelopes.monthlyEnvelopes.length
                ? categoryWithEnvelopes.monthlyEnvelopes[entry.key]
                : null;
            return EnvelopeRow(
              envelope: envelope,
              currencyCode: currencyCode,
              monthlyData: monthlyData,
              onTap: () => onEditEnvelope(envelope),
              onLongPress: () => onDeleteEnvelope(envelope),
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

  Color _availableColor(int cents) {
    if (cents > 0) return ColorTokens.secondary;
    if (cents < 0) return ColorTokens.error;
    return ColorTokens.tertiary;
  }
}
