import 'package:openbudget_core/src/generated/recurrence_frequency.dart';
import 'package:openbudget_core/src/time/civil_date.dart';

/// First occurrence strictly after [after], retaining the original anchor day.
DateTime nextOccurrence(
  RecurrenceFrequency frequency,
  DateTime anchor,
  DateTime after,
) {
  if (!isCivilDate(anchor) || !isCivilDate(after)) {
    throw ArgumentError('Recurrence requires civil dates.');
  }
  if (after.isBefore(anchor)) return anchor;
  switch (frequency) {
    case RecurrenceFrequency.daily:
    case RecurrenceFrequency.weekly:
    case RecurrenceFrequency.biweekly:
      final days = switch (frequency) {
        RecurrenceFrequency.daily => 1,
        RecurrenceFrequency.weekly => 7,
        _ => 14,
      };
      return anchor.add(
        Duration(days: (after.difference(anchor).inDays ~/ days + 1) * days),
      );
    case RecurrenceFrequency.monthly:
    case RecurrenceFrequency.yearly:
      final step = frequency == RecurrenceFrequency.monthly ? 1 : 12;
      var offset =
          ((after.year - anchor.year) * 12 + after.month - anchor.month) ~/
          step *
          step;
      while (true) {
        final first = DateTime.utc(anchor.year, anchor.month + offset);
        final lastDay = DateTime.utc(first.year, first.month + 1, 0).day;
        final candidate = DateTime.utc(
          first.year,
          first.month,
          anchor.day > lastDay ? lastDay : anchor.day,
        );
        if (candidate.isAfter(after)) return candidate;
        offset += step;
      }
  }
}
