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

/// The summary totals for one month of a folded range.
typedef EnvelopeMonthTotals = ({
  int allocatedMinor,
  int activityMinor,
  int overspentLastMonthMinor,
  int assignedInFutureMinor,
  int readyToAssignMinor,
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

/// Every month's totals from one walk through the same sparse aggregates.
class EnvelopeMonthRangeResult {
  const EnvelopeMonthRangeResult({
    required this.months,
    required this.envelopes,
  });

  /// One entry per month from the requested first month to last month.
  final Map<int, EnvelopeMonthTotals> months;

  /// Each envelope's derived balance for the final month.
  final Map<String, EnvelopeMonthBalance> envelopes;
}

const EnvelopeMonthBalance _zeroEnvelopeBalance = (
  carryoverMinor: 0,
  allocatedMinor: 0,
  activityMinor: 0,
  availableMinor: 0,
);

/// Derives envelope balances and zero-sum Ready to Assign from sparse aggregates.
EnvelopeFoldResult foldEnvelopeMonths({
  required int month,
  required Map<String, Map<int, EnvelopeMonthAmounts>> envelopes,
  required Map<int, int> flows,
}) {
  final range = foldEnvelopeMonthRange(
    fromMonth: month,
    toMonth: month,
    envelopes: envelopes,
    flows: flows,
  );
  final totals = range.months[month]!;
  return EnvelopeFoldResult(
    envelopes: range.envelopes,
    readyToAssignMinor: totals.readyToAssignMinor,
    assignedInFutureMinor: totals.assignedInFutureMinor,
    overspentLastMonthMinor: totals.overspentLastMonthMinor,
  );
}

/// Folds every month in [fromMonth] to [toMonth] in one pass.
///
/// Each envelope walks from its own first month to [toMonth], carrying its
/// non-negative balance forward. Totals for a month are derived from the same
/// cumulative figures as [foldEnvelopeMonths], so the range result and a
/// sequence of single-month folds are identical.
EnvelopeMonthRangeResult foldEnvelopeMonthRange({
  required int fromMonth,
  required int toMonth,
  required Map<String, Map<int, EnvelopeMonthAmounts>> envelopes,
  required Map<int, int> flows,
}) {
  MonthKey.validate(fromMonth);
  MonthKey.validate(toMonth);
  if (toMonth < fromMonth) {
    throw ArgumentError.value(
      toMonth,
      'toMonth',
      'must be on or after fromMonth',
    );
  }

  final allocationByMonth = <int, int>{};
  final activityByMonth = <int, int>{};
  var totalAllocations = 0;
  for (final months in envelopes.values) {
    for (final entry in months.entries) {
      MonthKey.validate(entry.key);
      allocationByMonth[entry.key] =
          (allocationByMonth[entry.key] ?? 0) + entry.value.allocatedMinor;
      activityByMonth[entry.key] =
          (activityByMonth[entry.key] ?? 0) + entry.value.activityMinor;
      totalAllocations += entry.value.allocatedMinor;
    }
  }
  flows.keys.forEach(MonthKey.validate);

  final availableByMonth = <int, int>{};
  final overspentByMonth = <int, int>{};
  final finalBalances = <String, EnvelopeMonthBalance>{};
  for (final entry in envelopes.entries) {
    final months = entry.value;
    if (months.isEmpty) {
      finalBalances[entry.key] = _zeroEnvelopeBalance;
      continue;
    }

    final first = months.keys.reduce(math.min);
    if (first > toMonth) {
      finalBalances[entry.key] = _zeroEnvelopeBalance;
      continue;
    }

    var carryover = 0;
    var current = first;
    while (true) {
      final amounts = months[current] ?? (allocatedMinor: 0, activityMinor: 0);
      final available =
          carryover + amounts.allocatedMinor + amounts.activityMinor;
      availableByMonth[current] = (availableByMonth[current] ?? 0) + available;
      final overspent = math.max(-available, 0);
      if (overspent > 0) {
        overspentByMonth[current] =
            (overspentByMonth[current] ?? 0) + overspent;
      }
      if (current == toMonth) {
        finalBalances[entry.key] = (
          carryoverMinor: carryover,
          allocatedMinor: amounts.allocatedMinor,
          activityMinor: amounts.activityMinor,
          availableMinor: available,
        );
        break;
      }
      carryover = math.max(available, 0);
      current = MonthKey.next(current);
    }
  }

  final result = <int, EnvelopeMonthTotals>{};
  var month = fromMonth;
  while (true) {
    final allocatedThrough = _sumThrough(allocationByMonth, month);
    final assignedInFuture = totalAllocations - allocatedThrough;
    final previous = _previousMonth(month);
    result[month] = (
      allocatedMinor: allocationByMonth[month] ?? 0,
      activityMinor: activityByMonth[month] ?? 0,
      overspentLastMonthMinor: previous == null
          ? 0
          : overspentByMonth[previous] ?? 0,
      assignedInFutureMinor: assignedInFuture,
      readyToAssignMinor:
          _sumThrough(flows, month) -
          allocatedThrough -
          _sumBefore(overspentByMonth, month) -
          assignedInFuture,
      availableMinor: availableByMonth[month] ?? 0,
    );
    if (month == toMonth) break;
    month = MonthKey.next(month);
  }

  return EnvelopeMonthRangeResult(months: result, envelopes: finalBalances);
}

int? _previousMonth(int month) =>
    month <= 190001 ? null : MonthKey.previous(month);

int _sumThrough(Map<int, int> values, int month) {
  var sum = 0;
  for (final entry in values.entries) {
    if (entry.key <= month) sum += entry.value;
  }
  return sum;
}

int _sumBefore(Map<int, int> values, int month) {
  var sum = 0;
  for (final entry in values.entries) {
    if (entry.key < month) sum += entry.value;
  }
  return sum;
}
