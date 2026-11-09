import 'dart:math' as math;

import 'package:openbudget_core/src/budgeting/month_key.dart';

/// One sparse month's allocation and activity for one envelope.
typedef EnvelopeMonthAmounts = ({int allocatedMinor, int activityMinor});

/// The derived balance of an envelope for the requested month.
typedef EnvelopeMonthBalance = ({
  int carryoverMinor,
  int allocatedMinor,
  int activityMinor,
  int availableMinor,
});

/// Results of the envelope fold, including hidden envelopes supplied as inputs.
class EnvelopeFoldResult {
  const EnvelopeFoldResult({
    required this.envelopes,
    required this.readyToAssignMinor,
    required this.assignedInFutureMinor,
    required this.overspentLastMonthMinor,
  });
  final Map<String, EnvelopeMonthBalance> envelopes;
  final int readyToAssignMinor;
  final int assignedInFutureMinor;
  final int overspentLastMonthMinor;
}

/// Derives envelope balances and zero-sum Ready to Assign from sparse aggregates.
EnvelopeFoldResult foldEnvelopeMonths({
  required int month,
  required Map<String, Map<int, EnvelopeMonthAmounts>> envelopes,
  required Map<int, int> flows,
}) {
  MonthKey.validate(month);
  final balances = <String, EnvelopeMonthBalance>{};
  var allocatedThrough = 0;
  var future = 0;
  var overspentBefore = 0;
  var overspentLast = 0;
  var flowThrough = 0;
  for (final entry in flows.entries) {
    MonthKey.validate(entry.key);
    if (entry.key <= month) flowThrough += entry.value;
  }
  for (final envelope in envelopes.entries) {
    var first = month;
    for (final entry in envelope.value.entries) {
      MonthKey.validate(entry.key);
      first = math.min(first, entry.key);
      if (entry.key <= month) {
        allocatedThrough += entry.value.allocatedMinor;
      } else {
        future += entry.value.allocatedMinor;
      }
    }
    var carryover = 0;
    var current = first;
    while (true) {
      final amounts =
          envelope.value[current] ?? (allocatedMinor: 0, activityMinor: 0);
      final available =
          carryover + amounts.allocatedMinor + amounts.activityMinor;
      if (current == month) {
        balances[envelope.key] = (
          carryoverMinor: carryover,
          allocatedMinor: amounts.allocatedMinor,
          activityMinor: amounts.activityMinor,
          availableMinor: available,
        );
        break;
      }
      final overspent = math.max(-available, 0);
      overspentBefore += overspent;
      if (MonthKey.next(current) == month) overspentLast += overspent;
      carryover = math.max(available, 0);
      current = MonthKey.next(current);
    }
  }
  return EnvelopeFoldResult(
    envelopes: balances,
    readyToAssignMinor:
        flowThrough - allocatedThrough - overspentBefore - future,
    assignedInFutureMinor: future,
    overspentLastMonthMinor: overspentLast,
  );
}
