// UK filing and payment dates, with the vectors the uk-personal-tax,
// uk-company-tax and uk-vat-payroll skills work through. HMRC states fixed
// calendar days, so nothing here moves for a weekend.
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

const GbTaxRules _pack = GbTaxRules();

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

List<TaxDeadline> _for(
  int startYear,
  EntityKind kind, {
  int endMonth = 3,
  int endDay = 31,
  bool vat = false,
}) => _pack.deadlines(
  _pack.taxYear(startYear),
  GbTaxProfile(
    entityKind: kind,
    salesTaxRegistered: vat,
    accountingPeriodEndMonth: endMonth,
    accountingPeriodEndDay: endDay,
  ),
);

DateTime _due(List<TaxDeadline> deadlines, String id) =>
    deadlines.singleWhere((deadline) => deadline.id == id).dueDate;

List<DateTime> _dues(List<TaxDeadline> deadlines, String id) => [
  for (final deadline in deadlines)
    if (deadline.id == id) deadline.dueDate,
];

void main() {
  group('Self Assessment, 2025/26', () {
    final deadlines = _for(2025, EntityKind.individual);

    test('the return and the balancing payment fall on 31 January 2027', () {
      expect(_due(deadlines, 'gb.sa.online-return'), d(2027, 1, 31));
      expect(_due(deadlines, 'gb.sa.balancing-payment'), d(2027, 1, 31));
      expect(_due(deadlines, 'gb.sa.class2-voluntary'), d(2027, 1, 31));
    });

    test('31 January 2027 is a Sunday and does not move', () {
      expect(d(2027, 1, 31).weekday, DateTime.sunday);
      expect(
        deadlines.every((deadline) => deadline.rolledFrom == null),
        isTrue,
      );
    });

    test('the notice, paper and coding-out dates match the skill table', () {
      expect(_due(deadlines, 'gb.sa.notify'), d(2026, 10, 5));
      expect(_due(deadlines, 'gb.sa.paper-return'), d(2026, 10, 31));
      expect(_due(deadlines, 'gb.sa.coding-out'), d(2026, 12, 30));
    });

    test('the payments on account for the year fall on 31 Jan and 31 Jul', () {
      expect(_due(deadlines, 'gb.sa.payment-on-account-1'), d(2026, 1, 31));
      expect(_due(deadlines, 'gb.sa.payment-on-account-2'), d(2026, 7, 31));
    });

    test('an amendment is open for 12 months after the filing deadline', () {
      expect(_due(deadlines, 'gb.sa.amend'), d(2028, 1, 31));
    });

    test('the year before Making Tax Digital has no quarterly updates', () {
      expect(
        deadlines.where((deadline) => deadline.id.startsWith('gb.mtd')),
        isEmpty,
      );
    });
  });

  group('Making Tax Digital for Income Tax, 2026/27', () {
    final deadlines = _for(2026, EntityKind.soleTrader);

    test('the quarterly updates are due 7 Aug, 7 Nov, 7 Feb and 7 May', () {
      expect(_dues(deadlines, 'gb.mtd.quarterly-update'), [
        d(2026, 8, 7),
        d(2026, 11, 7),
        d(2027, 2, 7),
        d(2027, 5, 7),
      ]);
    });

    test('7 November 2026 is a Saturday and does not move', () {
      expect(d(2026, 11, 7).weekday, DateTime.saturday);
    });

    test('each update covers a quarter of the tax year', () {
      final updates = deadlines
          .where((deadline) => deadline.id == 'gb.mtd.quarterly-update')
          .toList();
      expect(updates.first.periodStart, d(2026, 4, 6));
      expect(updates.first.periodLabel, '6 April 2026 to 5 July 2026');
      expect(updates.last.periodEnd, d(2027, 4, 6));
    });

    test('the final declaration is due 31 January 2028', () {
      expect(_due(deadlines, 'gb.mtd.final-declaration'), d(2028, 1, 31));
    });

    test('the note carries the income threshold for the year', () {
      final update = deadlines.firstWhere(
        (deadline) => deadline.id == 'gb.mtd.quarterly-update',
      );
      expect(update.note, contains('£50,000'));
    });
  });

  group('Corporation Tax', () {
    test('a 31 March 2026 year end gives 1 Jan 2027 and 31 Mar 2027', () {
      final deadlines = _for(2025, EntityKind.company);
      expect(_due(deadlines, 'gb.ct.payment'), d(2027, 1, 1));
      expect(_due(deadlines, 'gb.ct.return'), d(2027, 3, 31));
      expect(_due(deadlines, 'gb.ct.s455'), d(2027, 1, 1));
    });

    test('a 31 December 2025 year end gives 1 Oct 2026 and 31 Dec 2026', () {
      final deadlines = _for(2025, EntityKind.company, endMonth: 12);
      expect(_due(deadlines, 'gb.ct.payment'), d(2026, 10, 1));
      expect(_due(deadlines, 'gb.ct.return'), d(2026, 12, 31));
      expect(_due(deadlines, 'gb.co.accounts'), d(2026, 9, 30));
    });

    test('a 30 June year end is due 1 April, nine months and a day on', () {
      final deadlines = _for(2025, EntityKind.company, endMonth: 6, endDay: 30);
      expect(_due(deadlines, 'gb.ct.payment'), d(2026, 4, 1));
      expect(_due(deadlines, 'gb.ct.return'), d(2026, 6, 30));
      expect(_due(deadlines, 'gb.co.accounts'), d(2026, 3, 31));
    });

    test('a 28 February year end is due 1 December', () {
      final deadlines = _for(2025, EntityKind.company, endMonth: 2, endDay: 28);
      expect(_due(deadlines, 'gb.ct.payment'), d(2026, 12, 1));
      expect(_due(deadlines, 'gb.ct.return'), d(2027, 2, 28));
      expect(_due(deadlines, 'gb.co.accounts'), d(2026, 11, 30));
    });

    test('the dates follow the profile and say so', () {
      final deadlines = _for(2025, EntityKind.company);
      for (final id in ['gb.ct.payment', 'gb.ct.return', 'gb.co.accounts']) {
        expect(
          deadlines
              .singleWhere((deadline) => deadline.id == id)
              .dependsOnProfile,
          isTrue,
          reason: id,
        );
      }
      expect(
        deadlines
            .singleWhere((deadline) => deadline.id == 'gb.ct.return')
            .periodLabel,
        'year to 31 March 2026',
      );
    });

    test('the Companies House date is graded as inferred', () {
      final accounts = _for(2025, EntityKind.company).singleWhere(
        (deadline) => deadline.id == 'gb.co.accounts',
      );
      expect(accounts.grade, TaxEvidenceGrade.inferred);
    });
  });

  group('VAT', () {
    test('only a registered business gets VAT dates', () {
      expect(
        _for(2026, EntityKind.soleTrader).where(
          (deadline) => deadline.id == 'gb.vat.return',
        ),
        isEmpty,
      );
      expect(
        _for(2026, EntityKind.soleTrader, vat: true).where(
          (deadline) => deadline.id == 'gb.vat.return',
        ),
        hasLength(4),
      );
    });

    test('a period ending 30 September 2026 is due 7 November 2026', () {
      final september = _for(2026, EntityKind.soleTrader, vat: true)
          .where((deadline) => deadline.id == 'gb.vat.return')
          .singleWhere(
            (deadline) => deadline.periodEnd == d(2026, 10, 1),
          );
      expect(september.dueDate, d(2026, 11, 7));
      expect(september.kind, TaxDeadlineKind.filingAndPayment);
      expect(september.rolledFrom, isNull, reason: 'weekends do not extend it');
      expect(september.dependsOnProfile, isTrue);
    });

    test('the four quarters are due 7 Aug, 7 Nov, 7 Feb and 7 May', () {
      expect(
        _dues(
          _for(2026, EntityKind.soleTrader, vat: true),
          'gb.vat.return',
        ),
        [d(2026, 8, 7), d(2026, 11, 7), d(2027, 2, 7), d(2027, 5, 7)],
      );
    });
  });

  group('payroll', () {
    final deadlines = _for(2026, EntityKind.company);

    test('the year-end forms are due 31 May, 6 July and 22 July', () {
      expect(_due(deadlines, 'gb.paye.p60'), d(2027, 5, 31));
      expect(_due(deadlines, 'gb.paye.p11d'), d(2027, 7, 6));
      expect(_due(deadlines, 'gb.paye.class-1a'), d(2027, 7, 22));
    });

    test('an EPS is due on the 19th after each tax month', () {
      final eps = _dues(deadlines, 'gb.paye.eps');
      expect(eps, hasLength(12));
      expect(eps.first, d(2026, 5, 19));
      expect(eps.last, d(2027, 4, 19));
    });

    test('pension contributions are due on the 22nd of the next month', () {
      final pension = _dues(deadlines, 'gb.paye.pension-contributions');
      expect(pension, hasLength(12));
      expect(pension.first, d(2026, 5, 22));
      expect(pension.last, d(2027, 4, 22));
    });

    test('a sole trader and an individual get no company payroll dates', () {
      for (final kind in [EntityKind.individual, EntityKind.soleTrader]) {
        expect(
          _for(2026, kind).where(
            (deadline) => deadline.id.startsWith('gb.paye'),
          ),
          isEmpty,
        );
      }
    });
  });
}
