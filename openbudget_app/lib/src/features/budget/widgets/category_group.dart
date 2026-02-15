import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CategoryGroup extends HookConsumerWidget {
  const CategoryGroup({
    required this.categoryWithEnvelopes,
    required this.currencyCode,
    required this.onAddEnvelope,
    super.key,
  });

  final CategoryWithEnvelopes categoryWithEnvelopes;
  final CurrencyCode currencyCode;
  final VoidCallback onAddEnvelope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = categoryWithEnvelopes.category;
    final envelopes = categoryWithEnvelopes.envelopes;

    return WiredCard(
      height: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: ColorTokens.primary.withAlpha(25),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.budgetColumnBudgeted,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.budgetColumnSpent,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.budgetColumnAvailable,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          const WiredDivider(),
          ...envelopes.map(
            (envelope) =>
                EnvelopeRow(envelope: envelope, currencyCode: currencyCode),
          ),
          if (envelopes.isNotEmpty) const WiredDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.budgetCategoryTotal,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatCents(
                      categoryWithEnvelopes.totalBudgetedCents,
                      currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatCents(
                      categoryWithEnvelopes.totalSpentCents,
                      currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    formatCents(
                      categoryWithEnvelopes.totalAvailableCents,
                      currencyCode,
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: WiredButton(
                onPressed: onAddEnvelope,
                child: Text(l10n.budgetAddEnvelope),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
