import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// The dates a net worth history chart has points for.
///
/// A point is the last day of each period in the closed range, plus the range
/// end when it falls inside a period. Points are unique and ascending, so a
/// partial final period never creates a second point on the same date.
abstract final class NetWorthPeriods {
  /// A day range may span at most 92 days.
  static const int maxDaySpan = 92;

  /// A week range may span at most two calendar years.
  static const int maxWeekYears = 2;

  /// A month range has at most 400 monthly points.
  static const int maxMonthSpan = 399;

  /// No history response carries more points than this.
  static const int maxPoints = 400;

  /// Validates the range and returns its ascending, unique points.
  static List<DateTime> points({
    required DateTime fromDate,
    required DateTime toDate,
    required NetWorthGranularity granularity,
  }) {
    _requireDate(fromDate, 'fromDate');
    _requireDate(toDate, 'toDate');
    if (fromDate.isAfter(toDate)) {
      throw ValidationException(
        message: 'fromDate must be on or before toDate',
      );
    }

    final points = switch (granularity) {
      NetWorthGranularity.day => _dayPoints(fromDate, toDate),
      NetWorthGranularity.week => _weekPoints(fromDate, toDate),
      NetWorthGranularity.month => _monthPoints(fromDate, toDate),
    };

    if (points.length > maxPoints) {
      throw ValidationException(
        message: 'Net worth history is limited to $maxPoints points',
      );
    }
    return points;
  }

  static List<DateTime> _dayPoints(DateTime fromDate, DateTime toDate) {
    if (toDate.difference(fromDate).inDays > maxDaySpan) {
      throw ValidationException(
        message: 'Day history is limited to $maxDaySpan days',
      );
    }

    final points = <DateTime>[];
    for (
      var date = fromDate;
      !date.isAfter(toDate);
      date = date.add(const Duration(days: 1))
    ) {
      points.add(date);
    }
    return points;
  }

  static List<DateTime> _weekPoints(DateTime fromDate, DateTime toDate) {
    if (toDate.isAfter(_addYears(fromDate, maxWeekYears))) {
      throw ValidationException(
        message: 'Week history is limited to $maxWeekYears years',
      );
    }

    final points = <DateTime>[];
    final daysUntilSunday = (DateTime.sunday - fromDate.weekday) % 7;
    var date = fromDate.add(Duration(days: daysUntilSunday));
    while (!date.isAfter(toDate)) {
      points.add(date);
      date = date.add(const Duration(days: 7));
    }
    _appendEnd(points, toDate);
    return points;
  }

  static List<DateTime> _monthPoints(DateTime fromDate, DateTime toDate) {
    final months =
        (toDate.year - fromDate.year) * 12 + toDate.month - fromDate.month;
    if (months > maxMonthSpan) {
      throw ValidationException(
        message: 'Month history is limited to ${maxMonthSpan + 1} months',
      );
    }

    final points = <DateTime>[];
    var year = fromDate.year;
    var month = fromDate.month;
    while (true) {
      final monthEnd = DateTime.utc(year, month + 1, 0);
      if (monthEnd.isAfter(toDate)) break;
      if (!monthEnd.isBefore(fromDate)) points.add(monthEnd);

      if (month == 12) {
        year += 1;
        month = 1;
      } else {
        month += 1;
      }
    }
    _appendEnd(points, toDate);
    return points;
  }

  static void _appendEnd(List<DateTime> points, DateTime toDate) {
    if (points.isEmpty || points.last != toDate) points.add(toDate);
  }

  static DateTime _addYears(DateTime date, int years) {
    final year = date.year + years;
    final lastDay = DateTime.utc(year, date.month + 1, 0).day;
    return DateTime.utc(
      year,
      date.month,
      date.day > lastDay ? lastDay : date.day,
    );
  }

  static void _requireDate(DateTime date, String field) {
    if (!isCivilDate(date) || date.year < 1900 || date.year > 9999) {
      throw ValidationException(
        message: '$field must be a UTC calendar date between 1900 and 9999',
      );
    }
  }
}
