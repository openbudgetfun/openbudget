import 'dart:async';

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
    final palette = theme.ob;
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
    final availableTone = available > 0
        ? ObTone.funded
        : available < 0
        ? ObTone.overspent
        : ObTone.neutral;
    final isOverspent = available < 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: Container(
              width: 40,
              height: 4,
              decoration: ObRoughDecoration(
                color: palette.line,
                seed: 67,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.md,
                  SpacingTokens.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ObEnvelopeGauge(
                          fraction: _fundingFraction(
                            goal: goal,
                            budgetedCents: budgeted,
                            spentCents: spent,
                            availableCents: available,
                          ),
                          semanticLabel: l10n.budgetEnvelopeProgress(
                            (_fundingFraction(
                                      goal: goal,
                                      budgetedCents: budgeted,
                                      spentCents: spent,
                                      availableCents: available,
                                    ) *
                                    100)
                                .round(),
                          ),
                          overspent: isOverspent,
                          seed: 4,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: Text(
                            envelope.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: palette.ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10n.envelopeAvailable,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                            ObAmount(
                              hideAmounts
                                  ? hiddenAmountPlaceholder
                                  : formatCents(available, currencyCode),
                              tone: availableTone,
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    _BalanceGrid(
                      carryover: carryover,
                      assigned: budgeted,
                      activity: spent,
                      available: available,
                      currencyCode: currencyCode,
                      availableTone: availableTone,
                      hideAmounts: hideAmounts,
                    ),
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
                      ObCard(
                        tone: ObTone.neutral,
                        padding: const EdgeInsets.all(SpacingTokens.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkribbleIcon(
                              data: OpenBudgetIcons.note,
                              size: 16,
                              color: palette.mutedInk,
                            ),
                            const SizedBox(width: SpacingTokens.xs),
                            Expanded(
                              child: Text(
                                envelope.note!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    _ActionButtonRow(
                      onMoveMoney: () => _showMoveMoney(context),
                      onSetGoal: () => _showSetGoal(context),
                      onEditEnvelope: () => _showEditEnvelope(context),
                    ),
                    ObSectionHeader(
                      title: l10n.envelopeActivityTitle,
                      padding: const EdgeInsets.only(top: SpacingTokens.sm),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              loading: () =>
                  Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: ObStatePanel.problem(
                  title: l10n.transactionLoadError,
                ),
              ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                            child: WiredDoodle(
                              kind: WiredDoodleKind.moon,
                              size: 48,
                              seed: 11,
                              color: palette.mutedInk,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            l10n.envelopeNoActivity,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
                        ],
                      ),
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
                    final tone = isIncome ? ObTone.funded : ObTone.overspent;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xs,
                      ),
                      child: Row(
                        children: [
                          SkribbleIcon(
                            data: isIncome
                                ? OpenBudgetIcons.inflow
                                : OpenBudgetIcons.outflow,
                            color: palette.hue(tone),
                            size: 18,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: palette.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _formatDate(tx.transactionDate),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ObAmount(
                            hideAmounts
                                ? hiddenAmountPlaceholder
                                : formatCents(tx.amountCents, currencyCode),
                            tone: tone,
                            style: theme.textTheme.bodyMedium,
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
      ),
    );
  }

  double _fundingFraction({
    required EnvelopeGoal? goal,
    required int budgetedCents,
    required int spentCents,
    required int availableCents,
  }) {
    if (goal != null) {
      return computeFundingProgress(
        goal: goal,
        budgetedCents: budgetedCents,
        availableCents: availableCents,
      );
    }
    if (budgetedCents <= 0) return 0;
    return spentCents / budgetedCents;
  }

  void _showMoveMoney(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => MoveMoneyDialog(
          budgetId: budgetId,
          year: year,
          month: month,
          categories: categories,
        ),
      ),
    );
  }

  void _showSetGoal(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => SetGoalDialog(
          envelopeId: envelope.id?.toString() ?? '',
          budgetId: budgetId,
          currencyCode: currencyCode,
          existingGoal: goal,
          envelopeName: envelope.name,
        ),
      ),
    );
  }

  void _showEditEnvelope(BuildContext context) {
    unawaited(
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
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _BalanceGrid extends HookWidget {
  const _BalanceGrid({
    required this.carryover,
    required this.assigned,
    required this.activity,
    required this.available,
    required this.currencyCode,
    required this.availableTone,
    required this.hideAmounts,
  });

  final int carryover;
  final int assigned;
  final int activity;
  final int available;
  final CurrencyCode currencyCode;
  final ObTone availableTone;
  final bool hideAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String amount(int cents) => hideAmounts
        ? hiddenAmountPlaceholder
        : formatCents(cents, currencyCode);

    return ObCard(
      tone: ObTone.neutral,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _BalanceGridCell(
              label: l10n.envelopeFromLastMonth,
              amount: amount(carryover),
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: _BalanceGridCell(
              label: l10n.envelopeAssigned,
              amount: amount(assigned),
              tone: ObTone.brand,
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: _BalanceGridCell(
              label: l10n.envelopeActivityTitle,
              amount: amount(activity),
              tone: ObTone.overspent,
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: _BalanceGridCell(
              label: l10n.envelopeAvailable,
              amount: amount(available),
              tone: availableTone,
            ),
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
    this.tone = ObTone.neutral,
  });

  final String label;
  final String amount;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.mutedInk,
          ),
        ),
        const SizedBox(height: 2),
        ObAmount(amount, tone: tone, style: theme.textTheme.titleMedium),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final progress = computeFundingProgress(
      goal: goal,
      budgetedCents: budgetedCents,
      availableCents: availableCents,
    );
    final underfunded = computeUnderfundedCents(
      goal: goal,
      budgetedCents: budgetedCents,
      availableCents: availableCents,
    );

    final goalTone = progress >= 1.0
        ? ObTone.funded
        : progress >= 0.5
        ? ObTone.underfunded
        : ObTone.overspent;

    final formattedAmount = hideAmounts
        ? hiddenAmountPlaceholder
        : formatCents(goal.targetAmountCents, currencyCode);
    final goalLabel = switch (goal.goalType) {
      'monthly_funding' => l10n.budgetGoalMonthly(
        hideAmounts
            ? hiddenAmountPlaceholder
            : formatCents(
                goal.monthlyFundingCents ?? goal.targetAmountCents,
                currencyCode,
              ),
      ),
      'target_by_date' => l10n.budgetGoalTargetBy(
        formattedAmount,
        goal.targetDate == null
            ? ''
            : '${goal.targetDate!.year}-'
                  '${goal.targetDate!.month.toString().padLeft(2, '0')}',
      ),
      _ => l10n.budgetGoalTarget(formattedAmount),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkribbleIcon(
              data: OpenBudgetIcons.flag,
              size: 16,
              color: palette.hue(goalTone),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                goalLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.hue(goalTone),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (underfunded > 0) ...[
              const Spacer(),
              Text(
                l10n.envelopeUnderfunded(
                  hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatCents(underfunded, currencyCode),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.overspent,
                ),
              ),
            ],
          ],
        ),
        if (!hideProgressBars) ...[
          const SizedBox(height: SpacingTokens.xs),
          ObEnvelopeGauge(
            fraction: progress,
            semanticLabel: l10n.budgetEnvelopeProgress(
              (progress.clamp(0.0, 1.0) * 100).round(),
            ),
            tone: goalTone == ObTone.overspent ? ObTone.underfunded : goalTone,
            width: 38,
            seed: 9,
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
            icon: OpenBudgetIcons.moveMoney,
            label: l10n.envelopeActionMoveMoney,
            onTap: onMoveMoney,
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _ActionButton(
            icon: OpenBudgetIcons.flag,
            label: l10n.envelopeActionSetGoal,
            onTap: onSetGoal,
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _ActionButton(
            icon: OpenBudgetIcons.edit,
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

  final WiredSvgIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.sm,
            horizontal: SpacingTokens.xs,
          ),
          decoration: ObRoughDecoration(
            color: palette.surface,
            outline: palette.quietPen,
            radius: 10,
            seed: 71,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkribbleIcon(data: icon, size: 20, color: palette.brand),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.brand,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
