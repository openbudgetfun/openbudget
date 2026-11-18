/// Calendar months encoded as yyyymm for storage and ordering.
abstract final class MonthKey {
  /// Whether the year and month fall in the supported calendar range.
  static bool isValid(int month) =>
      month >= 190001 &&
      month <= 999912 &&
      month % 100 >= 1 &&
      month % 100 <= 12;

  /// Rejects an invalid month at an input boundary.
  static void validate(int month) {
    if (!isValid(month)) throw ArgumentError.value(month, 'month');
  }

  /// Encodes the calendar fields of a date.
  static int fromDate(DateTime date) {
    final month = date.year * 100 + date.month;
    validate(month);
    return month;
  }

  /// The first civil day of the month.
  static DateTime toFirstDate(int month) {
    validate(month);
    return DateTime.utc(month ~/ 100, month % 100);
  }

  /// The final civil day of the month.
  static DateTime toLastDate(int month) {
    validate(month);
    return DateTime.utc(month ~/ 100, month % 100 + 1, 0);
  }

  /// The next month, including across December.
  static int next(int month) {
    final date = toFirstDate(month);
    return fromDate(DateTime.utc(date.year, date.month + 1));
  }

  /// The previous month, including across January.
  static int previous(int month) {
    final date = toFirstDate(month);
    return fromDate(DateTime.utc(date.year, date.month - 1));
  }
}
