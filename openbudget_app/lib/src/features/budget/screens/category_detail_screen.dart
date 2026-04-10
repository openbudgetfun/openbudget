import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CategoryDetailScreen extends HookConsumerWidget {
  const CategoryDetailScreen({
    required this.budgetId,
    required this.categoryId,
    required this.envelopeId,
    super.key,
  });

  final String budgetId;
  final String categoryId;
  final String envelopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final goalsAsync = ref.watch(budgetGoalsProvider(budgetId));
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final isSnoozed = useState(false);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.budgetLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        data: (summary) {
          final currencyCode = CurrencyCode.values.firstWhere(
            (code) => code.code == summary.budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          );

          Envelope? envelope;
          MonthlyEnvelopeData? monthlyData;

          for (final group in summary.categories) {
            if (group.category.id?.toString() != categoryId) {
              continue;
            }
            for (var index = 0; index < group.envelopes.length; index++) {
              final current = group.envelopes[index];
              if (current.id?.toString() == envelopeId) {
                envelope = current;
                if (index < group.monthlyEnvelopes.length) {
                  monthlyData = group.monthlyEnvelopes[index];
                }
                break;
              }
            }
          }

          if (envelope == null) {
            return Center(
              child: Text(
                l10n.budgetSearchNoResults,
                style: theme.textTheme.bodyLarge,
              ),
            );
          }
          final selectedEnvelope = envelope;

          final goal = goalsAsync.whenOrNull(
            data: (goals) => goals[envelopeId],
          );
          final carryover = monthlyData?.carryoverCents ?? 0;
          final assigned =
              monthlyData?.allocatedCents ??
              selectedEnvelope.budgetedAmountCents;
          final spent =
              monthlyData?.spentCents ?? selectedEnvelope.spentAmountCents;
          final available = monthlyData?.availableCents ?? (assigned - spent);
          final availableColor = available >= 0
              ? OpenBudgetPalette.fgSuccessFor(Theme.of(context))
              : OpenBudgetPalette.fgErrorFor(Theme.of(context));

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              0,
              SpacingTokens.md,
              SpacingTokens.md,
            ),
            children: [
              Text(
                selectedEnvelope.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              _SectionTitle(title: l10n.categoryDetailBalanceTitle),
              _Card(
                child: Column(
                  children: [
                    _DetailRow(
                      label: l10n.envelopeFromLastMonth,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatCents(carryover, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeAssigned,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatCents(assigned, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeActivityTitle,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatCents(-spent, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeAvailable,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatCents(available, currencyCode),
                      valueColor: availableColor,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.categoryDetailTargetTitle),
              if (goal == null)
                _Card(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: FilledButton(
                      onPressed: () => _showSetGoalDialog(
                        context,
                        selectedEnvelope,
                        currencyCode,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(l10n.goalSetGoal),
                    ),
                  ),
                )
              else ...[
                _GoalCard(
                  goal: goal,
                  budgetedCents: assigned,
                  availableCents: available,
                  currencyCode: currencyCode,
                  hideAmounts: hideAmounts,
                  hideProgressBars: hideProgressBars,
                  onAssign: () => _showQuickBudgetDialog(
                    context,
                    selectedEnvelope,
                    currencyCode,
                    summary.year,
                    summary.month,
                  ),
                  onEditGoal: () => _showSetGoalDialog(
                    context,
                    selectedEnvelope,
                    currencyCode,
                    goal,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                _Card(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                    ),
                    value: isSnoozed.value,
                    onChanged: (value) => isSnoozed.value = value,
                    title: Text(l10n.categoryDetailSnoozeGoal),
                    secondary: Icon(
                      Icons.snooze_rounded,
                      color: OpenBudgetPalette.fgSecondaryFor(
                        Theme.of(context),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.categoryDetailNotesTitle),
              _Card(
                child: ListTile(
                  title: Text(
                    (selectedEnvelope.note?.isNotEmpty ?? false)
                        ? selectedEnvelope.note!
                        : l10n.envelopeNoteHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (selectedEnvelope.note?.isNotEmpty ?? false)
                          ? null
                          : OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => _showEditEnvelopeDialog(
                      context,
                      selectedEnvelope,
                      currencyCode,
                      summary.year,
                      summary.month,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.tonal(
                onPressed: () => _showEditEnvelopeDialog(
                  context,
                  selectedEnvelope,
                  currencyCode,
                  summary.year,
                  summary.month,
                ),
                child: Text(l10n.categoryDetailEditEnvelope),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.tonal(
                onPressed: () async {
                  await ref
                      .read(envelopeActionsProvider.notifier)
                      .toggleHidden(
                        envelopeId: envelopeId,
                        categoryId: categoryId,
                        budgetId: budgetId,
                        isHidden: !(selectedEnvelope.isHidden ?? false),
                      );
                },
                child: Text(
                  (selectedEnvelope.isHidden ?? false)
                      ? l10n.categoryDetailUnhideEnvelope
                      : l10n.categoryDetailHideEnvelope,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.tonal(
                onPressed: () => _confirmDeleteEnvelope(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: OpenBudgetPalette.fgErrorFor(
                    Theme.of(context),
                  ).withAlpha(24),
                  foregroundColor: OpenBudgetPalette.fgErrorFor(
                    Theme.of(context),
                  ),
                ),
                child: Text(l10n.categoryDetailDeleteEnvelope),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQuickBudgetDialog(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode,
    int year,
    int month,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => QuickBudgetDialog(
        budgetId: budgetId,
        envelopeId: envelope.id?.toString() ?? '',
        envelopeName: envelope.name,
        currencyCode: currencyCode,
        year: year,
        month: month,
      ),
    );
  }

  void _showSetGoalDialog(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode, [
    EnvelopeGoal? existingGoal,
  ]) {
    showDialog<void>(
      context: context,
      builder: (_) => SetGoalDialog(
        envelopeId: envelope.id?.toString() ?? '',
        budgetId: budgetId,
        currencyCode: currencyCode,
        existingGoal: existingGoal,
        envelopeName: envelope.name,
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    Envelope envelope,
    CurrencyCode currencyCode,
    int year,
    int month,
  ) {
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

  void _confirmDeleteEnvelope(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.categoryDetailDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(envelopeActionsProvider.notifier)
                  .deleteEnvelope(
                    envelopeId: envelopeId,
                    categoryId: categoryId,
                    budgetId: budgetId,
                  );
              if (context.mounted) {
                context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: OpenBudgetPalette.fgErrorFor(Theme.of(context)),
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends HookWidget {
  const _GoalCard({
    required this.goal,
    required this.budgetedCents,
    required this.availableCents,
    required this.currencyCode,
    required this.hideAmounts,
    required this.hideProgressBars,
    required this.onAssign,
    required this.onEditGoal,
  });

  final EnvelopeGoal goal;
  final int budgetedCents;
  final int availableCents;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final bool hideProgressBars;
  final VoidCallback onAssign;
  final VoidCallback onEditGoal;

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
    final amountToAssignThisMonth = switch (goal.goalType) {
      'monthly_funding' => goal.monthlyFundingCents ?? goal.targetAmountCents,
      _ => budgetedCents + underfunded,
    };

    final isComplete = underfunded <= 0;
    final statusColor = isComplete
        ? OpenBudgetPalette.fgSuccessFor(Theme.of(context))
        : OpenBudgetPalette.bgWarningFor(Theme.of(context));

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            if (!hideProgressBars)
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: clampedProgress,
                      strokeWidth: 8,
                      color: statusColor,
                      backgroundColor: OpenBudgetPalette.borderSubtleFor(
                        Theme.of(context),
                      ),
                    ),
                    Center(
                      child: isComplete
                          ? Icon(
                              Icons.check_rounded,
                              color: OpenBudgetPalette.fgSuccessFor(
                                Theme.of(context),
                              ),
                              size: 36,
                            )
                          : Text(
                              '${(clampedProgress * 100).round()}%',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            if (!hideProgressBars) const SizedBox(height: SpacingTokens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(38),
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Text(
                isComplete
                    ? l10n.categoryDetailTargetMet
                    : l10n.categoryDetailAssignMore(
                        hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatCents(underfunded, currencyCode),
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!isComplete) ...[
              const SizedBox(height: SpacingTokens.md),
              FilledButton(
                onPressed: onAssign,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: OpenBudgetPalette.bgBrandFor(
                    Theme.of(context),
                  ),
                ),
                child: Text(l10n.budgetAssignMoney),
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            const Divider(height: 1),
            const SizedBox(height: SpacingTokens.md),
            _DetailRow(
              label: l10n.categoryDetailAmountToAssignThisMonth,
              value: hideAmounts
                  ? hiddenAmountPlaceholder
                  : formatCents(amountToAssignThisMonth, currencyCode),
            ),
            _DetailRow(
              label: l10n.categoryDetailAssignedSoFar,
              value: hideAmounts
                  ? hiddenAmountPlaceholder
                  : formatCents(budgetedCents, currencyCode),
            ),
            _DetailRow(
              label: l10n.categoryDetailToGo,
              value: hideAmounts
                  ? hiddenAmountPlaceholder
                  : formatCents(underfunded, currencyCode),
            ),
            const SizedBox(height: SpacingTokens.md),
            FilledButton.tonal(
              onPressed: onEditGoal,
              child: Text(l10n.goalSetGoal),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends HookWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.xs,
        bottom: SpacingTokens.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Card extends HookWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(
          color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
        ),
      ),
      child: child,
    );
}

class _DetailRow extends HookWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
          Container(
            padding: emphasize
                ? const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: 2,
                  )
                : EdgeInsets.zero,
            decoration: emphasize
                ? BoxDecoration(
                    color:
                        (valueColor ??
                                OpenBudgetPalette.bgBrandFor(Theme.of(context)))
                            .withAlpha(32),
                    borderRadius: BorderRadius.circular(999),
                  )
                : null,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
