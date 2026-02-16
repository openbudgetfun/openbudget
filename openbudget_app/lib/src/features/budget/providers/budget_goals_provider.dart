import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_goal_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_goals_provider.g.dart';

/// Fetches all envelope goals for a budget and returns them as a map
/// keyed by envelope ID string for quick lookup.
@riverpod
Future<Map<String, EnvelopeGoal>> budgetGoals(Ref ref, String budgetId) async {
  final categories = await ref.watch(categoryListProvider(budgetId).future);
  final allEnvelopeIds = <String>[];

  for (final category in categories) {
    final categoryId = category.id?.toString() ?? '';
    final envelopes = await ref.watch(envelopeListProvider(categoryId).future);
    for (final envelope in envelopes) {
      final id = envelope.id?.toString();
      if (id != null) {
        allEnvelopeIds.add(id);
      }
    }
  }

  if (allEnvelopeIds.isEmpty) return {};

  final goals = await ref.watch(envelopeGoalsProvider(allEnvelopeIds).future);
  final map = <String, EnvelopeGoal>{};
  for (final goal in goals) {
    map[goal.envelopeId.toString()] = goal;
  }
  return map;
}

/// Computes the underfunded amount in cents for an envelope given its goal.
///
/// Returns 0 if fully funded, or a positive number representing how many
/// cents still need to be assigned.
int computeUnderfundedCents({
  required EnvelopeGoal goal,
  required int budgetedCents,
  required int availableCents,
}) {
  switch (goal.goalType) {
    case 'target_balance':
      final needed = goal.targetAmountCents - availableCents;
      return needed > 0 ? needed : 0;

    case 'monthly_funding':
      final target = goal.monthlyFundingCents ?? goal.targetAmountCents;
      final needed = target - budgetedCents;
      return needed > 0 ? needed : 0;

    case 'target_by_date':
      if (goal.targetDate == null) {
        final needed = goal.targetAmountCents - availableCents;
        return needed > 0 ? needed : 0;
      }
      final now = DateTime.now();
      final target = goal.targetDate!;
      if (target.isBefore(now)) {
        final needed = goal.targetAmountCents - availableCents;
        return needed > 0 ? needed : 0;
      }
      final remainingMonths =
          (target.year - now.year) * 12 + (target.month - now.month);
      if (remainingMonths <= 0) {
        final needed = goal.targetAmountCents - availableCents;
        return needed > 0 ? needed : 0;
      }
      final totalNeeded = goal.targetAmountCents - availableCents;
      if (totalNeeded <= 0) return 0;
      final monthlyNeeded = (totalNeeded / remainingMonths).ceil();
      final needed = monthlyNeeded - budgetedCents;
      return needed > 0 ? needed : 0;

    default:
      return 0;
  }
}

/// Computes the funding progress as a fraction (0.0 to 1.0+).
double computeFundingProgress({
  required EnvelopeGoal goal,
  required int budgetedCents,
  required int availableCents,
}) {
  switch (goal.goalType) {
    case 'target_balance':
      if (goal.targetAmountCents <= 0) return 1;
      return availableCents / goal.targetAmountCents;

    case 'monthly_funding':
      final target = goal.monthlyFundingCents ?? goal.targetAmountCents;
      if (target <= 0) return 1;
      return budgetedCents / target;

    case 'target_by_date':
      if (goal.targetAmountCents <= 0) return 1;
      return availableCents / goal.targetAmountCents;

    default:
      return 1;
  }
}
