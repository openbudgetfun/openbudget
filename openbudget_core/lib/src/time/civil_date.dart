/// A calendar day encoded as UTC midnight, without instant semantics.
DateTime civilDate(int year, int month, int day) {
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    throw ArgumentError('Invalid calendar date: $year-$month-$day');
  }
  return date;
}

/// Whether a date has the canonical calendar-day representation.
bool isCivilDate(DateTime date) =>
    date.isUtc &&
    date.hour == 0 &&
    date.minute == 0 &&
    date.second == 0 &&
    date.millisecond == 0 &&
    date.microsecond == 0;
