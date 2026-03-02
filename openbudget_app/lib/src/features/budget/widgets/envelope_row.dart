import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
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
    this.hideAmounts = false,
    this.hideProgressBars = false,
    this.isSelected = false,
    super.key,
  });

  final Envelope envelope;
  final CurrencyCode currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final MonthlyEnvelopeData? monthlyData;
  final VoidCallback? onQuickBudget;
  final EnvelopeGoal? goal;
  final bool hideAmounts;
  final bool hideProgressBars;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgeted =
        monthlyData?.allocatedCents ?? envelope.budgetedAmountCents;
    final spent = monthlyData?.spentCents ?? envelope.spentAmountCents;
    final available = monthlyData?.availableCents ?? (budgeted - spent);
    final carryover = monthlyData?.carryoverCents ?? 0;
    final balanceStyle = ref.watch(balanceStyleProvider);
    final availableColor = available > 0
        ? ColorTokens.secondary
        : available < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;
    final shouldDifferentiateWithoutColor =
        balanceStyle == BalanceStyle.differentiateWithoutColor &&
        available != 0;
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? OpenBudgetPalette.bgAccentFor(Theme.of(context)).withAlpha(85)
          : OpenBudgetPalette.transparentFor(Theme.of(context)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (onQuickBudget != null)
                    GestureDetector(
                      onTap: onQuickBudget,
                      child: Padding(
                        padding: EdgeInsets.only(right: SpacingTokens.xs),
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                envelope.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (carryover != 0)
                              Tooltip(
                                message: l10n.envelopeCarryover(
                                  hideAmounts
                                      ? hiddenAmountPlaceholder
                                      : formatCents(carryover, currencyCode),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: SpacingTokens.xs,
                                  ),
                                  child: Icon(
                                    carryover > 0
                                        ? Icons.arrow_forward_rounded
                                        : Icons.arrow_back_rounded,
                                    size: 12,
                                    color: carryover > 0
                                        ? OpenBudgetPalette.fgSuccessFor(
                                            Theme.of(context),
                                          )
                                        : OpenBudgetPalette.fgErrorFor(
                                            Theme.of(context),
                                          ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (envelope.note != null && envelope.note!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 10,
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  envelope.note!,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: OpenBudgetPalette.fgSecondaryFor(
                                      Theme.of(context),
                                    ),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.sm + 2,
                      vertical: SpacingTokens.xs,
                    ),
                    decoration: BoxDecoration(
                      color: availableColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(999),
                      border: shouldDifferentiateWithoutColor
                          ? Border.all(
                              color: availableColor.withAlpha(160),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (shouldDifferentiateWithoutColor) ...[
                          Icon(
                            available < 0
                                ? Icons.remove_rounded
                                : Icons.add_rounded,
                            size: 12,
                            color: availableColor,
                          ),
                          const SizedBox(width: 2),
                        ],
                        Text(
                          hideAmounts
                              ? hiddenAmountPlaceholder
                              : formatCents(available, currencyCode),
                          maxLines: 1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: availableColor,
                            fontWeight: FontWeight.w700,
                            decoration:
                                shouldDifferentiateWithoutColor && available < 0
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              if (goal != null && !hideProgressBars)
                _GoalProgressBar(
                  goal: goal!,
                  budgetedCents: budgeted,
                  availableCents: available,
                  currencyCode: currencyCode,
                  hideAmounts: hideAmounts,
                )
              else if (budgeted > 0 && !hideProgressBars)
                _SpendingProgressBar(
                  budgetedCents: budgeted,
                  spentCents: spent,
                ),
              if (goal == null && budgeted > 0) ...[
                const SizedBox(height: 3),
                Text(
                  available < 0 ? 'Overspent' : 'Funded',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: available < 0
                        ? OpenBudgetPalette.fgErrorFor(Theme.of(context))
                        : OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingProgressBar extends HookWidget {
  const _SpendingProgressBar({
    required this.budgetedCents,
    required this.spentCents,
  });

  final int budgetedCents;
  final int spentCents;

  @override
  Widget build(BuildContext context) {
    final ratio = budgetedCents > 0 ? spentCents / budgetedCents : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);

    final Color barColor;
    if (ratio > 1.0) {
      barColor = OpenBudgetPalette.fgErrorFor(Theme.of(context));
    } else if (ratio >= 0.8) {
      barColor = ColorTokens.tertiary;
    } else {
      barColor = OpenBudgetPalette.fgSuccessFor(Theme.of(context));
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
                value: clampedRatio,
                minHeight: 4,
                backgroundColor: barColor.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressBar extends HookWidget {
  const _GoalProgressBar({
    required this.goal,
    required this.budgetedCents,
    required this.availableCents,
    required this.currencyCode,
    required this.hideAmounts,
  });

  final EnvelopeGoal goal;
  final int budgetedCents;
  final int availableCents;
  final CurrencyCode currencyCode;
  final bool hideAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      barColor = OpenBudgetPalette.fgSuccessFor(Theme.of(context));
    } else if (progress >= 0.5) {
      barColor = ColorTokens.tertiary;
    } else {
      barColor = OpenBudgetPalette.fgErrorFor(Theme.of(context));
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
                minHeight: 4,
                backgroundColor: barColor.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          if (underfunded > 0) ...[
            const SizedBox(width: SpacingTokens.xs),
            Icon(Icons.warning_amber_rounded, size: 12, color: barColor),
            const SizedBox(width: 2),
            Text(
              l10n.envelopeUnderfunded(
                hideAmounts
                    ? hiddenAmountPlaceholder
                    : formatCents(underfunded, currencyCode),
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: barColor,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
