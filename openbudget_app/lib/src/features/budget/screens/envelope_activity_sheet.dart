import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/move_money_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EnvelopeActivitySheet extends HookConsumerWidget {
  const EnvelopeActivitySheet({
    required this.envelope,
    required this.budgetId,
    required this.currencyCode,
    required this.categories,
    required this.categoryId,
    required this.year,
    required this.month,
    this.monthlyData,
    this.goal,
    super.key,
  });

  final Envelope envelope;
  final String budgetId;
  final CurrencyCode currencyCode;
  final List<CategoryWithEnvelopes> categories;
  final String categoryId;
  final int year;
  final int month;
  final MonthlyEnvelopeData? monthlyData;
  final EnvelopeGoal? goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedMonth = ref.watch(selectedMonthProvider(budgetId));
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final transactionsAsync = ref.watch(
      monthlyTransactionsProvider(
        budgetId,
        selectedMonth.year,
        selectedMonth.month,
      ),
    );

    final carryover = monthlyData?.carryoverCents ?? 0;
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
      initialChildSize: 0.7,
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
            // Header: Name + Available pill
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.md,
                SpacingTokens.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Envelope name + Available pill
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          envelope.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      _AvailablePill(
                        amount: hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(available, currencyCode),
                        color: availableColor,
                      ),
                    ],
                  ),
                  // Note (if present)
                  if (envelope.note != null && envelope.note!.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            envelope.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  // Balance breakdown grid (2x2)
                  _BalanceGrid(
                    carryover: carryover,
                    assigned: budgeted,
                    activity: spent,
                    available: available,
                    currencyCode: currencyCode,
                    availableColor: availableColor,
                    hideAmounts: hideAmounts,
                  ),
                  // Goal progress bar (if goal set)
                  if (goal != null) ...[
                    const SizedBox(height: SpacingTokens.md),
                    _GoalSummary(
                      goal: goal!,
                      budgetedCents: budgeted,
                      availableCents: available,
                      currencyCode: currencyCode,
                      hideAmounts: hideAmounts,
                      hideProgressBars: hideProgressBars,
                    ),
                  ],
                  if (envelope.note != null && envelope.note!.isNotEmpty) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(SpacingTokens.sm),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          80,
                        ),
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: SpacingTokens.xs),
                          Expanded(
                            child: Text(
                              envelope.note!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  // Action button row
                  _ActionButtonRow(
                    onMoveMoney: () => _showMoveMoney(context),
                    onSetGoal: () => _showSetGoal(context),
                    onEditEnvelope: () => _showEditEnvelope(context),
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
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final showIcon = constraints.maxHeight >= 72;
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showIcon) ...[
                                Icon(
                                  Icons.receipt_long_rounded,
                                  size: 40,
                                  color: colorScheme.outlineVariant,
                                ),
                                const SizedBox(height: SpacingTokens.sm),
                              ],
                              Text(
                                l10n.envelopeNoActivity,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
                              hideAmounts
                                  ? hiddenAmountPlaceholder
                                  : formatCents(tx.amountCents, currencyCode),
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

  void _showMoveMoney(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => MoveMoneyDialog(
        budgetId: budgetId,
        year: year,
        month: month,
        categories: categories,
      ),
    );
  }

  void _showSetGoal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => SetGoalDialog(
        envelopeId: envelope.id?.toString() ?? '',
        budgetId: budgetId,
        currencyCode: currencyCode,
        existingGoal: goal,
        envelopeName: envelope.name,
      ),
    );
  }

  void _showEditEnvelope(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => EditEnvelopeDialog(
        envelope: envelope,
        categoryId: categoryId,
        budgetId: budgetId,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AvailablePill extends HookWidget {
  const _AvailablePill({required this.amount, required this.color});

  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            l10n.envelopeAvailable,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceGrid extends HookWidget {
  const _BalanceGrid({
    required this.carryover,
    required this.assigned,
    required this.activity,
    required this.available,
    required this.currencyCode,
    required this.availableColor,
    required this.hideAmounts,
  });

  final int carryover;
  final int assigned;
  final int activity;
  final int available;
  final CurrencyCode currencyCode;
  final Color availableColor;
  final bool hideAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BalanceGridCell(
                  label: l10n.envelopeFromLastMonth,
                  amount: hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(carryover, currencyCode),
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _BalanceGridCell(
                  label: l10n.envelopeAssigned,
                  amount: hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(assigned, currencyCode),
                  color: ColorTokens.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: _BalanceGridCell(
                  label: l10n.envelopeActivityTitle,
                  amount: hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(activity, currencyCode),
                  color: ColorTokens.error,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _BalanceGridCell(
                  label: l10n.envelopeAvailable,
                  amount: hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(available, currencyCode),
                  color: availableColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceGridCell extends HookWidget {
  const _BalanceGridCell({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _GoalSummary extends HookWidget {
  const _GoalSummary({
    required this.goal,
    required this.budgetedCents,
    required this.availableCents,
    required this.currencyCode,
    required this.hideAmounts,
    required this.hideProgressBars,
  });

  final EnvelopeGoal goal;
  final int budgetedCents;
  final int availableCents;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final bool hideProgressBars;

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
        'Target: ${hideAmounts ? hiddenAmountPlaceholder : formatCents(goal.targetAmountCents, currencyCode)}',
      'monthly_funding' =>
        'Monthly: ${hideAmounts ? hiddenAmountPlaceholder : formatCents(goal.monthlyFundingCents ?? goal.targetAmountCents, currencyCode)}',
      'target_by_date' =>
        'Target: ${hideAmounts ? hiddenAmountPlaceholder : formatCents(goal.targetAmountCents, currencyCode)}${goal.targetDate != null ? ' by ${goal.targetDate!.year}-${goal.targetDate!.month.toString().padLeft(2, '0')}' : ''}',
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
                '${hideAmounts ? hiddenAmountPlaceholder : formatCents(underfunded, currencyCode)} needed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorTokens.error,
                ),
              ),
            ],
          ],
        ),
        if (!hideProgressBars) ...[
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
      ],
    );
  }
}

class _ActionButtonRow extends HookWidget {
  const _ActionButtonRow({
    required this.onMoveMoney,
    required this.onSetGoal,
    required this.onEditEnvelope,
  });

  final VoidCallback onMoveMoney;
  final VoidCallback onSetGoal;
  final VoidCallback onEditEnvelope;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.swap_horiz_rounded,
            label: l10n.envelopeActionMoveMoney,
            onTap: onMoveMoney,
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _ActionButton(
            icon: Icons.flag_rounded,
            label: l10n.envelopeActionSetGoal,
            onTap: onSetGoal,
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_rounded,
            label: l10n.envelopeActionEditEnvelope,
            onTap: onEditEnvelope,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends HookWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
