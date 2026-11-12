import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_envelope_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/quick_budget_dialog.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_category_row.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One envelope's detail: balance, goal, notes and lifecycle actions. All
/// figures come from the server's month view for the selected month.
class CategoryDetailScreen extends HookConsumerWidget {
  const CategoryDetailScreen({
    required this.entityId,
    required this.categoryId,
    required this.envelopeId,
    super.key,
  });

  final String entityId;
  final String categoryId;
  final String envelopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final monthEnvelopeAsync = ref.watch(
      budgetMonthEnvelopeProvider(entityId, envelopeId),
    );
    final hideAmounts = ref.watch(hideAmountsProvider);
    final hideProgressBars = ref.watch(hideProgressBarsProvider);
    final isSnoozed = useState(false);

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        backgroundColor: palette.canvas,
        surfaceTintColor: palette.canvas,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: palette.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: monthEnvelopeAsync.when(
        loading: () => Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.appTitle,
            message: l10n.budgetLoadError,
          ),
        ),
        data: (monthEnvelope) {
          final currencyCode = ref.watch(
            budgetMonthCurrencyProvider(entityId),
          ).value ??
          '';
          final goal = monthEnvelope.goal;
          final carryover = monthEnvelope.carryoverMinor;
          final assigned = monthEnvelope.allocatedMinor;
          final spent = monthEnvelope.activityMinor.abs();
          final available = monthEnvelope.availableMinor;
          final availableTone = available > 0
              ? ObTone.funded
              : available < 0
              ? ObTone.overspent
              : ObTone.neutral;
          final envelope = monthEnvelope.envelope;
          final month = ref.watch(selectedYyyymmProvider(entityId));

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              Text(
                envelope.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
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
                          : formatMinorForCode(carryover, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeAssigned,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(assigned, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeActivityTitle,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(-spent, currencyCode),
                    ),
                    const Divider(height: 1),
                    _DetailRow(
                      label: l10n.envelopeAvailable,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(available, currencyCode),
                      tone: availableTone,
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
                    child: FilledButton.icon(
                      onPressed: () => _showSetGoalDialog(
                        context,
                        monthEnvelope,
                        currencyCode,
                        month,
                      ),
                      icon: SkribbleIcon(
                        data: OpenBudgetIcons.flag,
                        size: 18,
                        color: palette.onAction,
                      ),
                      label: Text(l10n.goalSetGoal),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                )
              else ...[
                _GoalCard(
                  monthEnvelope: monthEnvelope,
                  currencyCode: currencyCode,
                  hideAmounts: hideAmounts,
                  hideProgressBars: hideProgressBars,
                  onAssign: () => _showQuickBudgetDialog(
                    context,
                    envelope,
                    currencyCode,
                    month,
                  ),
                  onEditGoal: () => _showSetGoalDialog(
                    context,
                    monthEnvelope,
                    currencyCode,
                    month,
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
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.snooze,
                      color: palette.mutedInk,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: SpacingTokens.lg),
              _SectionTitle(title: l10n.categoryDetailNotesTitle),
              _Card(
                child: ListTile(
                  title: Text(
                    (envelope.note?.isNotEmpty ?? false)
                        ? envelope.note!
                        : l10n.envelopeNoteHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (envelope.note?.isNotEmpty ?? false)
                          ? palette.ink
                          : palette.mutedInk,
                    ),
                  ),
                  trailing: IconButton(
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.edit,
                      color: palette.brand,
                    ),
                    tooltip: l10n.editEnvelopeTitle,
                    onPressed: () => _showEditEnvelopeDialog(
                      context,
                      monthEnvelope,
                      currencyCode,
                      month,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              _Card(
                child: EnvelopeTaxCategoryRow(
                  entityId: entityId,
                  envelope: envelope,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.tonal(
                onPressed: () => _showEditEnvelopeDialog(
                  context,
                  monthEnvelope,
                  currencyCode,
                  month,
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
                        entityId: entityId,
                        isHidden: !envelope.isHidden,
                      );
                },
                child: Text(
                  envelope.isHidden
                      ? l10n.categoryDetailUnhideEnvelope
                      : l10n.categoryDetailHideEnvelope,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.tonal(
                onPressed: () => _confirmDeleteEnvelope(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.overspentWash,
                  foregroundColor: palette.overspent,
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
    String currencyCode,
    int month,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => QuickBudgetDialog(
          entityId: entityId,
          envelopeId: envelope.id?.toString() ?? '',
          envelopeName: envelope.name,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  void _showSetGoalDialog(
    BuildContext context,
    EnvelopeMonthView monthEnvelope,
    String currencyCode,
    int month,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => SetGoalDialog(
          monthEnvelope: monthEnvelope,
          entityId: entityId,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  void _showEditEnvelopeDialog(
    BuildContext context,
    EnvelopeMonthView monthEnvelope,
    String currencyCode,
    int month,
  ) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => EditEnvelopeDialog(
          monthEnvelope: monthEnvelope,
          categoryId: categoryId,
          entityId: entityId,
          currencyCode: currencyCode,
          month: month,
        ),
      ),
    );
  }

  void _confirmDeleteEnvelope(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    unawaited(
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
                    .deleteEnvelope(envelopeId: envelopeId);
                if (context.mounted) {
                  context.pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: palette.overspent,
                foregroundColor: palette.onAction,
              ),
              child: Text(l10n.deleteConfirmButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// The one envelope's row of the month view, or null when it is hidden
/// this month (it has no allocation row until it is budgeted).
/// The one envelope's row of the month view, or null when it is hidden
/// this month (it has no allocation row until it is budgeted).
class _GoalCard extends HookWidget {
  const _GoalCard({
    required this.monthEnvelope,
    required this.currencyCode,
    required this.hideAmounts,
    required this.hideProgressBars,
    required this.onAssign,
    required this.onEditGoal,
  });

  final EnvelopeMonthView monthEnvelope;
  final String currencyCode;
  final bool hideAmounts;
  final bool hideProgressBars;
  final VoidCallback onAssign;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final goal = monthEnvelope.goal!;
    final presentation = goalPresentation(monthEnvelope: monthEnvelope);
    final progress = presentation.progress;
    final underfunded = presentation.underfundedMinor;
    final amountToAssignThisMonth = switch (goal.kind) {
      EnvelopeGoalKind.monthlyFunding => goal.amountMinor,
      _ => monthEnvelope.allocatedMinor + underfunded,
    };

    final isComplete = underfunded <= 0;

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            if (!hideProgressBars)
              ObEnvelopeGauge(
                fraction: progress,
                semanticLabel: l10n.budgetEnvelopeProgress(
                  (progress.clamp(0.0, 1.0) * 100).round(),
                ),
                width: 76,
                seed: 11,
              ),
            if (!hideProgressBars) const SizedBox(height: SpacingTokens.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: ObRoughDecoration(
                color: isComplete
                    ? palette.fundedWash
                    : palette.underfundedWash,
                radius: 10,
                seed: 47,
              ),
              child: Text(
                isComplete
                    ? l10n.categoryDetailTargetMet
                    : l10n.categoryDetailAssignMore(
                        hideAmounts
                            ? hiddenAmountPlaceholder
                            : formatMinorForCode(underfunded, currencyCode),
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.ink,
                ),
              ),
            ),
            if (!isComplete) ...[
              const SizedBox(height: SpacingTokens.md),
              FilledButton(
                onPressed: onAssign,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
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
                  : formatMinorForCode(amountToAssignThisMonth, currencyCode),
            ),
            _DetailRow(
              label: l10n.categoryDetailAssignedSoFar,
              value: hideAmounts
                  ? hiddenAmountPlaceholder
                  : formatMinorForCode(
                      monthEnvelope.allocatedMinor,
                      currencyCode,
                    ),
            ),
            _DetailRow(
              label: l10n.categoryDetailToGo,
              value: hideAmounts
                  ? hiddenAmountPlaceholder
                  : formatMinorForCode(underfunded, currencyCode),
              tone: isComplete ? ObTone.funded : ObTone.underfunded,
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
  Widget build(BuildContext context) => ObSectionHeader(
    title: title,
    padding: const EdgeInsets.only(
      left: SpacingTokens.xs,
      bottom: SpacingTokens.xs,
    ),
  );
}

class _Card extends HookWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ObCard(child: child);
}

class _DetailRow extends HookWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.tone = ObTone.neutral,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final ObTone tone;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
            ),
          ),
          ObAmount(
            value,
            tone: tone,
            style: emphasize
                ? theme.textTheme.titleLarge
                : theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
