import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EnvelopeRow extends HookConsumerWidget {
  const EnvelopeRow({
    required this.envelope,
    required this.currencyCode,
    required this.onTap,
    required this.onLongPress,
    this.monthlyData,
    this.onQuickBudget,
    this.goal,
    super.key,
  });

  final Envelope envelope;
  final CurrencyCode currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final MonthlyEnvelopeData? monthlyData;
  final VoidCallback? onQuickBudget;
  final EnvelopeGoal? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgeted =
        monthlyData?.allocatedCents ?? envelope.budgetedAmountCents;
    final spent = monthlyData?.spentCents ?? envelope.spentAmountCents;
    final available = monthlyData?.availableCents ?? (budgeted - spent);
    final availableColor = available > 0
        ? ColorTokens.secondary
        : available < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm + SpacingTokens.xs,
          vertical: SpacingTokens.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (onQuickBudget != null)
                  GestureDetector(
                    onTap: onQuickBudget,
                    child: Padding(
                      padding: const EdgeInsets.only(right: SpacingTokens.xs),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: theme.colorScheme.primary.withAlpha(150),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  flex: 4,
                  child: Text(
                    envelope.name,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatCents(budgeted, currencyCode),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatCents(spent, currencyCode),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: spent > 0 ? ColorTokens.error : null,
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
                    color: availableColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    formatCents(available, currencyCode),
                    maxLines: 1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: availableColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (goal != null)
              _GoalProgressBar(
                goal: goal!,
                budgetedCents: budgeted,
                availableCents: available,
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalProgressBar extends HookWidget {
  const _GoalProgressBar({
    required this.goal,
    required this.budgetedCents,
    required this.availableCents,
  });

  final EnvelopeGoal goal;
  final int budgetedCents;
  final int availableCents;

  @override
  Widget build(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 3,
                backgroundColor: barColor.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          if (underfunded > 0) ...[
            const SizedBox(width: SpacingTokens.xs),
            Icon(Icons.warning_amber_rounded, size: 12, color: barColor),
          ],
        ],
      ),
    );
  }
}
