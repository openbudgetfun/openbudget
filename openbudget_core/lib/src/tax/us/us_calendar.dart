import 'package:openbudget_core/src/tax/tax_calendar.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/us/us_profile.dart';

final Uri _whenToFile = Uri.parse(
  'https://www.irs.gov/filing/individuals/when-to-file',
);
final Uri _estimatedTaxes = Uri.parse(
  'https://www.irs.gov/businesses/small-businesses-self-employed/estimated-taxes',
);
final Uri _pub505 = Uri.parse('https://www.irs.gov/publications/p505');
final Uri _fbar = Uri.parse(
  'https://www.irs.gov/newsroom/how-to-report-foreign-bank-and-financial-accounts',
);
final Uri _pub54 = Uri.parse('https://www.irs.gov/publications/p54');
final Uri _pub15 = Uri.parse('https://www.irs.gov/publications/p15');
final Uri _form940 = Uri.parse('https://www.irs.gov/instructions/i940');
final Uri _form1120 = Uri.parse('https://www.irs.gov/instructions/i1120');

/// The `n`th `weekday` of [month] in [year], counted from 1.
DateTime _nthWeekday(int year, int month, int weekday, int n) {
  final first = DateTime.utc(year, month);
  final offset = (weekday - first.weekday) % 7;
  return DateTime.utc(year, month, 1 + offset + 7 * (n - 1));
}

/// The last `weekday` of [month] in [year].
DateTime _lastWeekday(int year, int month, int weekday) {
  final last = lastDayOfTaxMonth(year, month);
  return DateTime.utc(year, month, last.day - (last.weekday - weekday) % 7);
}

/// A fixed-date holiday and the weekday it is observed on: a Saturday
/// holiday is observed on the Friday before, a Sunday one on the Monday
/// after.
DateTime _observed(int year, int month, int day) {
  final date = DateTime.utc(year, month, day);
  return switch (date.weekday) {
    DateTime.saturday => addTaxDays(date, -1),
    DateTime.sunday => addTaxDays(date, 1),
    _ => date,
  };
}

/// The legal holidays that move an IRS due date (Internal Revenue Code
/// § 7503): the federal holidays and, because the IRS sits there, the
/// District of Columbia's Emancipation Day on 16 April.
///
/// A holiday that falls on a weekend counts on the weekday it is observed.
/// The holiday list is statute knowledge, not read from a page, so the
/// pack's caveat names it as unverified.
Set<DateTime> usLegalHolidays(int year) => {
  _observed(year, 1, 1),
  _observed(year + 1, 1, 1), // New Year's Day observed on 31 December.
  _nthWeekday(year, 1, DateTime.monday, 3), // Martin Luther King Jr. Day
  _nthWeekday(year, 2, DateTime.monday, 3), // Washington's Birthday
  _lastWeekday(year, 5, DateTime.monday), // Memorial Day
  _observed(year, 6, 19), // Juneteenth
  _observed(year, 7, 4),
  _nthWeekday(year, 9, DateTime.monday, 1), // Labor Day
  _nthWeekday(year, 10, DateTime.monday, 2), // Columbus Day
  _observed(year, 11, 11), // Veterans Day
  _nthWeekday(year, 11, DateTime.thursday, 4), // Thanksgiving
  _observed(year, 12, 25),
  _observed(year, 4, 16), // DC Emancipation Day
};

/// Whether an IRS deadline cannot fall on [day]: a weekend or a legal
/// holiday.
bool usIsRestDay(DateTime day) =>
    isWeekend(day) || usLegalHolidays(day.year).contains(day);

/// [date], or the next business day when it is a weekend or legal holiday,
/// as § 7503 moves it.
DateTime usRollForward(DateTime date) => rollForwardTaxDate(date, usIsRestDay);

/// The filing and payment dates the calendar year [period] creates for a US
/// taxpayer, from the us-federal-tax skill.
///
/// Every date is moved to the next business day when it falls on a weekend
/// or legal holiday, and [TaxDeadline.rolledFrom] keeps the date before.
List<TaxDeadline> usDeadlines(TaxYear period, UsTaxProfile profile) {
  final year = period.startYear;
  final next = year + 1;
  final deadlines = <TaxDeadline>[];

  void add({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime nominal,
    required Uri source,
    required String citation,
    TaxEvidenceGrade grade = TaxEvidenceGrade.primary,
    String? note,
    bool dependsOnProfile = false,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
  }) {
    final due = usRollForward(nominal);
    deadlines.add(
      TaxDeadline(
        id: id,
        title: title,
        kind: kind,
        dueDate: due,
        periodStart: periodStart ?? period.start,
        periodEnd: periodEnd ?? period.end,
        periodLabel: periodLabel ?? period.label,
        source: source,
        citation: citation,
        grade: grade,
        dependsOnProfile: dependsOnProfile,
        note: note,
        rolledFrom: due == nominal ? null : nominal,
      ),
    );
  }

  final isPerson = profile.entityKind != EntityKind.company;
  final employs = profile.entityKind != EntityKind.individual;

  if (isPerson) {
    add(
      id: 'us.1040.return',
      title: 'Form 1040 return and payment',
      kind: TaxDeadlineKind.filingAndPayment,
      nominal: DateTime.utc(next, 4, 15),
      source: _whenToFile,
      citation: 'IRS when to file: 15 April',
    );
    add(
      id: 'us.1040.extended-return',
      title: 'Form 1040 return after an extension',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 10, 15),
      source: _whenToFile,
      citation: 'IRS Form 4868: six months, to 15 October',
      note:
          'Applies after a Form 4868 extension; the tax is still due in '
          'April.',
    );
    final estimateDates = [
      (DateTime.utc(year, 4, 15), 'First'),
      (DateTime.utc(year, 6, 15), 'Second'),
      (DateTime.utc(year, 9, 15), 'Third'),
      (DateTime.utc(next, 1, 15), 'Fourth'),
    ];
    for (final (nominal, ordinal) in estimateDates) {
      add(
        id: 'us.1040-es.estimated-payment',
        title: '$ordinal estimated tax payment',
        kind: TaxDeadlineKind.payment,
        nominal: nominal,
        source: _pub505,
        citation:
            'IRS Publication 505: 15 April, 15 June, 15 September and '
            '15 January',
        note:
            r'Applies when the expected balance is $1,000 or more. The '
            'January payment is not needed when the return is filed by '
            '31 January with the tax paid in full.',
      );
    }
    add(
      id: 'us.fbar.report',
      title: 'Foreign bank account report (FBAR)',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 4, 15),
      source: _fbar,
      citation: 'IRS FBAR: 15 April, filed with FinCEN, not the return',
      note:
          r'Applies when foreign accounts total over $10,000 at any time in '
          'the year.',
    );
    add(
      id: 'us.fbar.extended-report',
      title:
          'Foreign bank account report (FBAR) after the automatic '
          'extension',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 10, 15),
      source: _fbar,
      citation: 'IRS FBAR: automatic extension to 15 October with no request',
      note:
          r'Applies when foreign accounts total over $10,000 at any time in '
          'the year.',
    );
    if (profile.foreignEarnedIncomeExclusionMinor > 0) {
      add(
        id: 'us.1040.abroad-return',
        title: 'Form 1040 return for a taxpayer abroad',
        kind: TaxDeadlineKind.filing,
        nominal: DateTime.utc(next, 6, 15),
        source: _pub54,
        citation:
            'IRS Publication 54: automatic two-month extension to '
            '15 June',
        dependsOnProfile: true,
        note:
            'Applies to a taxpayer living abroad on 15 April; interest runs '
            'on tax unpaid after 15 April.',
      );
      add(
        id: 'us.1040.abroad-letter-extension',
        title:
            'Form 1040 return after a letter extension for a taxpayer '
            'abroad',
        kind: TaxDeadlineKind.filing,
        nominal: DateTime.utc(next, 12, 15),
        source: _pub54,
        citation:
            'IRS Publication 54: extension to 15 December by letter '
            'request',
        dependsOnProfile: true,
        note: 'Applies to a taxpayer abroad who asked for it by letter.',
      );
    }
  }

  if (employs) {
    const employerNote = 'Applies when the books pay employees.';
    final quarters = [
      (
        DateTime.utc(year, 4, 30),
        'First',
        DateTime.utc(year),
        DateTime.utc(year, 4),
      ),
      (
        DateTime.utc(year, 7, 31),
        'Second',
        DateTime.utc(year, 4),
        DateTime.utc(year, 7),
      ),
      (
        DateTime.utc(year, 10, 31),
        'Third',
        DateTime.utc(year, 7),
        DateTime.utc(year, 10),
      ),
      (
        DateTime.utc(next, 1, 31),
        'Fourth',
        DateTime.utc(year, 10),
        DateTime.utc(next),
      ),
    ];
    for (final (nominal, ordinal, start, end) in quarters) {
      add(
        id: 'us.941.quarterly-return',
        title: '$ordinal quarter Form 941',
        kind: TaxDeadlineKind.filing,
        nominal: nominal,
        source: _pub15,
        citation:
            'IRS Publication 15: 30 April, 31 July, 31 October and '
            '31 January',
        periodStart: start,
        periodEnd: end,
        periodLabel: '${ordinal.toLowerCase()} quarter $year',
        grade: TaxEvidenceGrade.inferred,
        note: employerNote,
      );
      add(
        id: 'us.940.futa-deposit',
        title: '$ordinal quarter federal unemployment tax deposit',
        kind: TaxDeadlineKind.payment,
        nominal: nominal,
        source: _form940,
        citation:
            'IRS Form 940 instructions: deposit by the end of the '
            r'month after the quarter when liability exceeds $500',
        periodStart: start,
        periodEnd: end,
        periodLabel: '${ordinal.toLowerCase()} quarter $year',
        grade: TaxEvidenceGrade.inferred,
        note:
            'Applies when the cumulative federal unemployment tax is over '
            r'$500 at the end of the quarter.',
      );
    }
    add(
      id: 'us.940.annual-return',
      title: 'Form 940 annual federal unemployment return',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 1, 31),
      source: _form940,
      citation:
          'IRS Form 940 instructions: 31 January, or 10 February when '
          'every deposit was on time',
      grade: TaxEvidenceGrade.inferred,
      note: employerNote,
    );
    add(
      id: 'us.w2.wage-statements',
      title: 'Forms W-2 and W-3',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 1, 31),
      source: _pub15,
      citation: 'IRS Publication 15: 31 January',
      grade: TaxEvidenceGrade.inferred,
      note: employerNote,
    );
    add(
      id: 'us.1099-nec.nonemployee-compensation',
      title: 'Form 1099-NEC',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 1, 31),
      source: _pub15,
      citation:
          'IRS information returns: 31 January, to the IRS and the '
          'payee',
      grade: TaxEvidenceGrade.inferred,
      note:
          r'Applies when $2,000 or more was paid to a contractor in the '
          r'year ($600 for 2025).',
    );
    add(
      id: 'us.1099-misc.payee-copy',
      title: 'Form 1099-MISC copy to the payee',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 1, 31),
      source: _pub15,
      citation: 'IRS information returns: 31 January',
      grade: TaxEvidenceGrade.inferred,
      note:
          'Applies when a reportable payment other than compensation was '
          'made.',
    );
    add(
      id: 'us.1099-misc.irs-paper',
      title: 'Form 1099-MISC paper return to the IRS',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 2, 28),
      source: _pub15,
      citation: 'IRS information returns: 28 February on paper',
      grade: TaxEvidenceGrade.inferred,
      note:
          'Applies when a reportable payment other than compensation was '
          'made.',
    );
    add(
      id: 'us.1099-misc.irs-electronic',
      title: 'Form 1099-MISC electronic return to the IRS',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 3, 31),
      source: _pub15,
      citation: 'IRS information returns: 31 March electronically',
      grade: TaxEvidenceGrade.inferred,
      note:
          'Applies when a reportable payment other than compensation was '
          'made.',
    );
  }

  if (profile.entityKind == EntityKind.company) {
    add(
      id: 'us.1120.return',
      title: 'Form 1120 return and payment',
      kind: TaxDeadlineKind.filingAndPayment,
      nominal: DateTime.utc(next, 4, 15),
      source: _form1120,
      citation:
          'IRS Form 1120 instructions: the 15th day of the fourth '
          'month',
      note: 'Assumes a calendar tax year.',
    );
    add(
      id: 'us.1120.extended-return',
      title: 'Form 1120 return after an extension',
      kind: TaxDeadlineKind.filing,
      nominal: DateTime.utc(next, 10, 15),
      source: _form1120,
      citation: 'IRS Form 7004: six months, to 15 October',
      grade: TaxEvidenceGrade.inferred,
      note:
          'Applies after a Form 7004 extension; the tax is still due in '
          'April.',
    );
    final estimates = [
      (DateTime.utc(year, 4, 15), 'First'),
      (DateTime.utc(year, 6, 15), 'Second'),
      (DateTime.utc(year, 9, 15), 'Third'),
      (DateTime.utc(year, 12, 15), 'Fourth'),
    ];
    for (final (nominal, ordinal) in estimates) {
      add(
        id: 'us.1120.estimated-payment',
        title: '$ordinal corporate estimated tax payment',
        kind: TaxDeadlineKind.payment,
        nominal: nominal,
        source: _estimatedTaxes,
        citation:
            'IRS estimated taxes: the 15th day of months 4, 6, 9 and '
            '12',
        note: r'Applies when the expected tax is $500 or more.',
      );
    }
  }

  return sortTaxDeadlines(deadlines);
}
