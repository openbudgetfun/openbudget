/// Date arithmetic the rule packs' filing calendars share. Every value is a
/// date-only UTC [DateTime], as in `TaxYear`.
library;

import 'package:openbudget_core/src/tax/tax_model.dart';

/// The last day of [month] (1 to 12) in [year].
DateTime lastDayOfTaxMonth(int year, int month) =>
    DateTime.utc(year, month + 1, 0);

/// [date] moved [months] calendar months on, keeping the day of the month
/// and falling back to the last day of a shorter month: 31 August plus six
/// months is 28 February.
DateTime addTaxMonths(DateTime date, int months) {
  final index = date.year * 12 + (date.month - 1) + months;
  final year = index ~/ 12;
  final month = index % 12 + 1;
  final lastDay = lastDayOfTaxMonth(year, month).day;
  return DateTime.utc(year, month, date.day > lastDay ? lastDay : date.day);
}

/// [date] moved [days] days on.
DateTime addTaxDays(DateTime date, int days) =>
    DateTime.utc(date.year, date.month, date.day + days);

/// [date], or the first day after it that [isRestDay] rejects. A rule that
/// moves a deadline off a weekend or holiday calls this with its own rest
/// days.
DateTime rollForwardTaxDate(
  DateTime date,
  bool Function(DateTime day) isRestDay,
) {
  var day = DateTime.utc(date.year, date.month, date.day);
  while (isRestDay(day)) {
    day = addTaxDays(day, 1);
  }
  return day;
}

/// Whether [day] is a Saturday or a Sunday.
bool isWeekend(DateTime day) =>
    day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// `31 March 2027`, for the period labels of the English packs.
String englishTaxDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

/// `April 2027`, for a month period's label.
String englishTaxMonth(int year, int month) =>
    '${_monthNames[month - 1]} $year';

/// [deadlines] in the order a calendar shows them: by due date, then
/// identifier, then the period each covers.
List<TaxDeadline> sortTaxDeadlines(Iterable<TaxDeadline> deadlines) =>
    List.unmodifiable(
      deadlines.toList()..sort((a, b) {
        final byDate = a.dueDate.compareTo(b.dueDate);
        if (byDate != 0) {
          return byDate;
        }
        final byId = a.id.compareTo(b.id);
        return byId != 0 ? byId : a.periodStart.compareTo(b.periodStart);
      }),
    );
