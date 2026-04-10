import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_calendar_provider.g.dart';

class ScheduledOccurrence extends Equatable {
  const ScheduledOccurrence({
    required this.recurring,
    required this.date,
    required this.isDue,
  });

  final RecurringTransaction recurring;
  final DateTime date;
  final bool isDue;

  @override
  List<Object?> get props => [recurring, date, isDue];
}

/// Generates future occurrences for all active recurring transactions
/// within a given month.
@riverpod
Future<Map<int, List<ScheduledOccurrence>>> recurringCalendar(
  Ref ref,
  String budgetId,
  int year,
  int month,
) async {
  final recurrings = await ref.watch(recurringListProvider(budgetId).future);
  final active = recurrings.where((r) => r.isActive).toList();

  final now = DateTime.now();
  final monthStart = DateTime(year, month);
  final monthEnd = DateTime(year, month + 1);

  final dayMap = <int, List<ScheduledOccurrence>>{};

  for (final recurring in active) {
    final occurrences = _generateOccurrences(recurring, monthStart, monthEnd);

    for (final date in occurrences) {
      final day = date.day;
      final isDue = !date.isAfter(now);
      final occurrence = ScheduledOccurrence(
        recurring: recurring,
        date: date,
        isDue: isDue,
      );
      (dayMap[day] ??= []).add(occurrence);
    }
  }

  return dayMap;
}

/// Generates all occurrence dates for a recurring transaction within
/// [start, end).
List<DateTime> _generateOccurrences(
  RecurringTransaction recurring,
  DateTime start,
  DateTime end,
) {
  final results = <DateTime>[];
  final next = recurring.nextOccurrence;
  final endDate = recurring.endDate;

  // Start from the nextOccurrence and work forwards/backwards to fill the
  // month window.
  var current = next;

  // First, walk backward from nextOccurrence if it's after the month start.
  if (current.isAfter(start)) {
    var prev = current;
    while (prev.isAfter(start)) {
      prev = _subtractFrequency(prev, recurring.frequency);
    }
    // prev is now before or at start; walk forward from here.
    current = prev;
  } else {
    // Walk forward until we reach the start.
    while (current.isBefore(start)) {
      current = _addFrequency(current, recurring.frequency);
    }
  }

  // Now generate occurrences within [start, end).
  while (current.isBefore(end)) {
    if (endDate != null && current.isAfter(endDate)) break;
    if (!current.isBefore(start)) {
      results.add(current);
    }
    current = _addFrequency(current, recurring.frequency);
  }

  return results;
}

DateTime _addFrequency(DateTime date, String frequency) => switch (frequency) {
  'daily' => date.add(const Duration(days: 1)),
  'weekly' => date.add(const Duration(days: 7)),
  'biweekly' => date.add(const Duration(days: 14)),
  'monthly' => DateTime(date.year, date.month + 1, date.day),
  'yearly' => DateTime(date.year + 1, date.month, date.day),
  _ => date.add(const Duration(days: 30)),
};

DateTime _subtractFrequency(DateTime date, String frequency) =>
    switch (frequency) {
      'daily' => date.subtract(const Duration(days: 1)),
      'weekly' => date.subtract(const Duration(days: 7)),
      'biweekly' => date.subtract(const Duration(days: 14)),
      'monthly' => DateTime(date.year, date.month - 1, date.day),
      'yearly' => DateTime(date.year - 1, date.month, date.day),
      _ => date.subtract(const Duration(days: 30)),
    };
