import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_goals_provider.g.dart';

/// All envelope goals of the entity, keyed by envelope id. The month view
/// already carries each envelope's goal; this covers screens that edit
/// goals across envelopes.
@riverpod
Future<Map<String, EnvelopeGoal>> budgetGoals(Ref ref, String entityId) async {
  final goals = await ref.watch(envelopeGoalsProvider(entityId).future);
  return {for (final goal in goals) goal.envelopeId.toString(): goal};
}

/// Presentation for a goal against its month view row. The arithmetic
/// itself lives in core `goal_math.dart`; the month view carries the
/// underfunded amount, so this only formats progress.
class GoalPresentation {
  const GoalPresentation({
    required this.underfundedMinor,
    required this.progress,
  });

  /// From `EnvelopeMonthView.goalUnderfundedMinor`.
  final int underfundedMinor;

  /// 0.0 to 1.0, how funded the goal is.
  final double progress;
}

GoalPresentation goalPresentation({
  required EnvelopeMonthView monthEnvelope,
}) {
  final goal = monthEnvelope.goal;
  if (goal == null || goal.amountMinor <= 0) {
    return const GoalPresentation(underfundedMinor: 0, progress: 1);
  }
  final underfunded = monthEnvelope.goalUnderfundedMinor;
  final funded = goal.amountMinor - underfunded;
  final progress = goal.amountMinor <= 0
      ? 1.0
      : (funded / goal.amountMinor).clamp(0.0, 1.0);
  return GoalPresentation(underfundedMinor: underfunded, progress: progress);
}

/// Builds the core funding record for the set-goal dialog's preview, so the
/// dialog can show what a goal would need without writing it.
int previewUnderfundedMinor({
  required EnvelopeGoalKind kind,
  required int amountMinor,
  required int month,
  required int carryoverMinor,
  required int allocatedMinor,
  required int activityMinor,
  DateTime? targetDate,
}) {
  final funding = (
    kind: kind.name,
    amountMinor: amountMinor,
    targetDate: targetDate,
  );
  return underfundedMinor(
    funding,
    month,
    carryoverMinor,
    allocatedMinor,
    activityMinor,
  );
}
