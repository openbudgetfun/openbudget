import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EnvelopeActivitySheet extends HookConsumerWidget {
  const EnvelopeActivitySheet({
    required this.envelope,
    required this.budgetId,
    required this.currencyCode,
    this.monthlyData,
    this.goal,
    super.key,
  });

  final Envelope envelope;
  final String budgetId;
  final CurrencyCode currencyCode;
  final MonthlyEnvelopeData? monthlyData;
  final EnvelopeGoal? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider(budgetId));
    final transactionsAsync = ref.watch(
      monthlyTransactionsProvider(
        budgetId,
        selectedMonth.year,
        selectedMonth.month,
      ),
    );

    final budgeted =
        monthlyData?.allocatedCents ?? envelope.budgetedAmountCents;
    final spent = monthlyData?.spentCents ?? envelope.spentAmountCents;
    final available = monthlyData?.availableCents ?? (budgeted - spent);
    final availableColor = available > 0
        ? ColorTokens.secondary
        : available < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: SpacingTokens.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    envelope.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (goal != null) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    _GoalSummary(
                      goal: goal!,
                      budgetedCents: budgeted,
                      availableCents: available,
                      currencyCode: currencyCode,
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  // Budget summary row
                  Row(
                    children: [
                      _SummaryChip(
                        label: l10n.budgetColumnBudgeted,
                        amount: formatCents(budgeted, currencyCode),
                        color: ColorTokens.primary,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _SummaryChip(
                        label: l10n.budgetColumnSpent,
                        amount: formatCents(spent, currencyCode),
                        color: ColorTokens.error,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _SummaryChip(
                        label: l10n.budgetColumnAvailable,
                        amount: formatCents(available, currencyCode),
                        color: availableColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.envelopeActivityTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Transaction list
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    Center(child: Text(l10n.transactionLoadError)),
                data: (allTransactions) {
                  final envelopeId = envelope.id?.toString();
                  final transactions =
                      allTransactions
                          .where((t) => t.envelopeId?.toString() == envelopeId)
                          .toList()
                        ..sort(
                          (a, b) =>
                              b.transactionDate.compareTo(a.transactionDate),
                        );

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 40,
                            color: colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            l10n.envelopeNoActivity,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                    ),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isIncome = tx.amountCents > 0;
                      final color = isIncome
                          ? ColorTokens.secondary
                          : ColorTokens.error;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.xs,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isIncome
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: color,
                              size: 16,
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description,
                                    style: theme.textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _formatDate(tx.transactionDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatCents(tx.amountCents, currencyCode),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _GoalSummary extends HookWidget {
  const _GoalSummary({
    required this.goal,
    required this.budgetedCents,
    required this.availableCents,
    required this.currencyCode,
  });

  final EnvelopeGoal goal;
  final int budgetedCents;
  final int availableCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = computeFundingProgress(
      goal: goal,
      budgetedCents: budgetedCents,
      availableCents: availableCents,
    );
    final clampedProgress = progress.clamp(0.0, 1.0);
    final underfunded = computeUnderfundedCents(
      goal: goal,
      budgetedCents: budgetedCents,
      availableCents: availableCents,
    );

    final Color barColor;
    if (progress >= 1.0) {
      barColor = ColorTokens.secondary;
    } else if (progress >= 0.5) {
      barColor = ColorTokens.tertiary;
    } else {
      barColor = ColorTokens.error;
    }

    final goalLabel = switch (goal.goalType) {
      'target_balance' =>
        'Target: ${formatCents(goal.targetAmountCents, currencyCode)}',
      'monthly_funding' =>
        'Monthly: ${formatCents(goal.monthlyFundingCents ?? goal.targetAmountCents, currencyCode)}',
      'target_by_date' =>
        'Target: ${formatCents(goal.targetAmountCents, currencyCode)}${goal.targetDate != null ? ' by ${goal.targetDate!.year}-${goal.targetDate!.month.toString().padLeft(2, '0')}' : ''}',
      _ => '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag_rounded, size: 14, color: barColor),
            const SizedBox(width: 4),
            Text(
              goalLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (underfunded > 0) ...[
              const Spacer(),
              Text(
                '${formatCents(underfunded, currencyCode)} needed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorTokens.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: clampedProgress,
            minHeight: 6,
            backgroundColor: barColor.withAlpha(30),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends HookWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.xs,
          horizontal: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withAlpha(180),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
