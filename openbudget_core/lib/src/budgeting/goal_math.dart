import 'dart:math' as math;

import 'package:openbudget_core/src/budgeting/month_key.dart';

/// Goal data needed by the pure funding calculation, independent of the ORM.
typedef FundingGoal = ({String kind, int amountMinor, DateTime? targetDate});

/// Amount still needed for the goal in [month], in entity base minor units.
int underfundedMinor(
  FundingGoal goal,
  int month,
  int carryoverMinor,
  int allocatedMinor,
  int activityMinor,
) {
  MonthKey.validate(month);
  final available = carryoverMinor + allocatedMinor + activityMinor;
  switch (goal.kind) {
    case 'targetBalance':
      return math.max(goal.amountMinor - available, 0);
    case 'monthlyFunding':
      return math.max(goal.amountMinor - allocatedMinor, 0);
    case 'targetByDate':
      final date = goal.targetDate;
      final remaining = date == null
          ? 0
          : (date.year - month ~/ 100) * 12 + date.month - month % 100;
      final total = math.max(goal.amountMinor - available, 0);
      if (remaining <= 0) return total;
      return math.max((total + remaining - 1) ~/ remaining - allocatedMinor, 0);
    default:
      throw ArgumentError.value(goal.kind, 'goal.kind');
  }
}
