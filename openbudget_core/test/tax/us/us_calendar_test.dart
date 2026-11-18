// US federal filing and payment dates, with the vectors in the
// us-federal-tax skill. A date on a weekend or legal holiday moves to the
// next business day (Internal Revenue Code § 7503).
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_core/src/tax/us/us_calendar.dart';
import 'package:test/test.dart';

const UsTaxRules _pack = UsTaxRules();

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

List<TaxDeadline> _for(
  int startYear,
  EntityKind kind, {
  int exclusionMinor = 0,
}) => _pack.deadlines(
  _pack.taxYear(startYear),
  UsTaxProfile(
    entityKind: kind,
    foreignEarnedIncomeExclusionMinor: exclusionMinor,
  ),
);

List<DateTime> _dues(List<TaxDeadline> deadlines, String id) => [
  for (final deadline in deadlines)
    if (deadline.id == id) deadline.dueDate,
];

DateTime _due(List<TaxDeadline> deadlines, String id) =>
    _dues(deadlines, id).single;

void main() {
  group('the business-day rule', () {
    test('15 June 2025 is a Sunday and moves to Monday 16 June', () {
      expect(d(2025, 6, 15).weekday, DateTime.sunday);
      expect(usRollForward(d(2025, 6, 15)), d(2025, 6, 16));
    });

    test('15 January 2028 is a Saturday followed by Martin Luther King '
        'Jr. Day, so it moves to Tuesday 18 January', () {
      expect(d(2028, 1, 15).weekday, DateTime.saturday);
      expect(usRollForward(d(2028, 1, 15)), d(2028, 1, 18));
    });

    test('Emancipation Day moves 15 April 2022, the observed day, to 18 '
        'April', () {
      expect(usRollForward(d(2022, 4, 15)), d(2022, 4, 18));
    });

    test('a weekday that is not a holiday stays', () {
      expect(usRollForward(d(2026, 4, 15)), d(2026, 4, 15));
      expect(usRollForward(d(2026, 9, 15)), d(2026, 9, 15));
    });

    test('the federal holidays of 2026 are the statute days', () {
      expect(
        usLegalHolidays(2026),
        containsAll([
          d(2026, 1, 1),
          d(2026, 1, 19),
          d(2026, 2, 16),
          d(2026, 5, 25),
          d(2026, 6, 19),
          d(2026, 7, 3), // 4 July is a Saturday, observed on Friday
          d(2026, 9, 7),
          d(2026, 10, 12),
          d(2026, 11, 11),
          d(2026, 11, 26),
          d(2026, 12, 25),
          d(2026, 4, 16),
        ]),
      );
    });
  });

  group('estimated tax', () {
    test('tax year 2025 pays on 15 Apr, 16 Jun, 15 Sep 2025 and 15 Jan '
        '2026', () {
      expect(
        _dues(
          _for(2025, EntityKind.individual),
          'us.1040-es.estimated-payment',
        ),
        [d(2025, 4, 15), d(2025, 6, 16), d(2025, 9, 15), d(2026, 1, 15)],
      );
    });

    test('tax year 2026 pays on 15 Apr, 15 Jun, 15 Sep 2026 and 15 Jan '
        '2027', () {
      expect(
        _dues(
          _for(2026, EntityKind.individual),
          'us.1040-es.estimated-payment',
        ),
        [d(2026, 4, 15), d(2026, 6, 15), d(2026, 9, 15), d(2027, 1, 15)],
      );
    });

    test('a moved date keeps the date it was moved from', () {
      final second = _for(2025, EntityKind.individual).firstWhere(
        (deadline) =>
            deadline.id == 'us.1040-es.estimated-payment' &&
            deadline.dueDate == d(2025, 6, 16),
      );
      expect(second.rolledFrom, d(2025, 6, 15));
    });

    test('a corporation pays on the 15th of months 4, 6, 9 and 12', () {
      expect(
        _dues(_for(2026, EntityKind.company), 'us.1120.estimated-payment'),
        [d(2026, 4, 15), d(2026, 6, 15), d(2026, 9, 15), d(2026, 12, 15)],
      );
    });
  });

  group('returns', () {
    test('the 2025 and 2026 individual returns are due 15 April', () {
      expect(
        _due(_for(2025, EntityKind.individual), 'us.1040.return'),
        d(2026, 4, 15),
      );
      expect(
        _due(_for(2026, EntityKind.individual), 'us.1040.return'),
        d(2027, 4, 15),
      );
    });

    test('an extension runs to 15 October', () {
      expect(
        _due(_for(2025, EntityKind.individual), 'us.1040.extended-return'),
        d(2026, 10, 15),
      );
      expect(
        _due(_for(2026, EntityKind.individual), 'us.fbar.extended-report'),
        d(2027, 10, 15),
      );
    });

    test('a taxpayer abroad gets 15 June and 15 December', () {
      final deadlines = _for(
        2026,
        EntityKind.individual,
        exclusionMinor: 13290000,
      );
      expect(_due(deadlines, 'us.1040.abroad-return'), d(2027, 6, 15));
      expect(
        _due(deadlines, 'us.1040.abroad-letter-extension'),
        d(2027, 12, 15),
      );
      final abroad = deadlines.firstWhere(
        (deadline) => deadline.id == 'us.1040.abroad-return',
      );
      expect(abroad.dependsOnProfile, isTrue);
    });

    test('a profile without a foreign exclusion has no abroad dates', () {
      expect(
        _for(2026, EntityKind.individual).where(
          (deadline) => deadline.id.contains('abroad'),
        ),
        isEmpty,
      );
    });

    test('the FBAR is due 15 April, filed apart from the return', () {
      final fbar = _for(2026, EntityKind.individual).firstWhere(
        (deadline) => deadline.id == 'us.fbar.report',
      );
      expect(fbar.dueDate, d(2027, 4, 15));
      expect(fbar.kind, TaxDeadlineKind.filing);
    });

    test(
      'a corporation files on 15 April, six months later with Form 7004',
      () {
        final deadlines = _for(2025, EntityKind.company);
        expect(_due(deadlines, 'us.1120.return'), d(2026, 4, 15));
        expect(_due(deadlines, 'us.1120.extended-return'), d(2026, 10, 15));
      },
    );

    test('1120-S is not produced: the S election is not in the profile', () {
      for (final kind in EntityKind.values) {
        expect(
          _for(2025, kind).where((deadline) => deadline.id.contains('1120s')),
          isEmpty,
        );
      }
    });
  });

  group('employer dates', () {
    test('Form 941 falls on 30 April, 31 July, 31 October and 31 January', () {
      expect(
        _dues(_for(2026, EntityKind.soleTrader), 'us.941.quarterly-return'),
        [d(2026, 4, 30), d(2026, 7, 31), d(2026, 11, 2), d(2027, 2, 1)],
      );
    });

    test('31 October 2026 is a Saturday and moves to Monday 2 November', () {
      final third = _for(2026, EntityKind.soleTrader).firstWhere(
        (deadline) =>
            deadline.id == 'us.941.quarterly-return' &&
            deadline.periodLabel == 'third quarter 2026',
      );
      expect(third.dueDate, d(2026, 11, 2));
      expect(third.rolledFrom, d(2026, 10, 31));
    });

    test('31 January 2026 is a Saturday: W-2, 940 and 1099-NEC move to 2 '
        'February 2026', () {
      final deadlines = _for(2025, EntityKind.soleTrader);
      for (final id in [
        'us.w2.wage-statements',
        'us.940.annual-return',
        'us.1099-nec.nonemployee-compensation',
      ]) {
        expect(_due(deadlines, id), d(2026, 2, 2), reason: id);
      }
    });

    test('31 January 2027 is a Sunday: 1099-NEC moves to 1 February', () {
      expect(
        _due(
          _for(2026, EntityKind.soleTrader),
          'us.1099-nec.nonemployee-compensation',
        ),
        d(2027, 2, 1),
      );
    });

    test('1099-MISC goes to the IRS 28 February on paper, 31 March online', () {
      final deadlines = _for(2026, EntityKind.soleTrader);
      expect(_due(deadlines, 'us.1099-misc.payee-copy'), d(2027, 2, 1));
      expect(_due(deadlines, 'us.1099-misc.irs-paper'), d(2027, 3, 1));
      expect(_due(deadlines, 'us.1099-misc.irs-electronic'), d(2027, 3, 31));
    });

    test('an individual has no employer dates; a corporation runs payroll', () {
      expect(
        _for(2026, EntityKind.individual).where(
          (deadline) => deadline.id.startsWith('us.94'),
        ),
        isEmpty,
      );
      expect(
        _for(2026, EntityKind.company).where(
          (deadline) => deadline.id.startsWith('us.94'),
        ),
        isNotEmpty,
      );
    });
  });
}
