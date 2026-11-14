// Nigerian filing and payment dates from the nigeria-tax skill. The skill
// found no guidance on weekends, so no date moves.
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

const NgTaxRules _pack = NgTaxRules();

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

List<TaxDeadline> _for(
  int startYear,
  EntityKind kind, {
  bool vat = false,
}) => _pack.deadlines(
  _pack.taxYear(startYear),
  NgTaxProfile(entityKind: kind, salesTaxRegistered: vat),
);

TaxDeadline _only(List<TaxDeadline> deadlines, String id) =>
    deadlines.singleWhere((deadline) => deadline.id == id);

List<DateTime> _dues(List<TaxDeadline> deadlines, String id) => [
  for (final deadline in deadlines)
    if (deadline.id == id) deadline.dueDate,
];

void main() {
  group('personal income tax', () {
    test('2025 income is due 31 March 2026, on a secondary source', () {
      final deadline = _only(
        _for(2025, EntityKind.individual),
        'ng.pit.annual-return',
      );
      expect(deadline.dueDate, d(2026, 3, 31));
      expect(deadline.grade, TaxEvidenceGrade.secondary);
      expect(deadline.kind, TaxDeadlineKind.filingAndPayment);
    });

    test('2026 income defaults to 31 March 2027 and says it is inferred', () {
      final deadline = _only(
        _for(2026, EntityKind.soleTrader),
        'ng.pit.annual-return',
      );
      expect(deadline.dueDate, d(2027, 3, 31));
      expect(deadline.grade, TaxEvidenceGrade.inferred);
      expect(deadline.note, contains('default'));
    });

    test('a company has no personal return', () {
      expect(
        _for(2026, EntityKind.company).where(
          (deadline) => deadline.id == 'ng.pit.annual-return',
        ),
        isEmpty,
      );
    });
  });

  group('company income tax', () {
    test('a calendar-year company files and pays by 30 June', () {
      final deadline = _only(
        _for(2026, EntityKind.company),
        'ng.cit.annual-return',
      );
      expect(deadline.dueDate, d(2027, 6, 30));
      expect(deadline.grade, TaxEvidenceGrade.primary);
      expect(deadline.citation, contains('s. 11(5)'));
    });
  });

  group('employer and sales-tax dates', () {
    test('the employer return is due 31 January after the year', () {
      expect(
        _only(
          _for(2025, EntityKind.soleTrader),
          'ng.paye.employer-return',
        ).dueDate,
        d(2026, 1, 31),
      );
    });

    test('PAYE is remitted by the 10th of each following month', () {
      final dues = _dues(
        _for(2026, EntityKind.company),
        'ng.paye.monthly-remittance',
      );
      expect(dues, hasLength(12));
      expect(dues.first, d(2026, 2, 10));
      expect(dues.last, d(2027, 1, 10));
    });

    test('withholding tax is remitted by the 21st of the next month', () {
      final dues = _dues(
        _for(2026, EntityKind.company),
        'ng.wht.monthly-remittance',
      );
      expect(dues.first, d(2026, 2, 21));
      expect(dues.last, d(2027, 1, 21));
    });

    test('VAT is filed and paid by the 21st, only when registered', () {
      expect(
        _for(2026, EntityKind.company).where(
          (deadline) => deadline.id == 'ng.vat.monthly-return',
        ),
        isEmpty,
      );
      final deadlines = _for(2026, EntityKind.company, vat: true);
      final dues = _dues(deadlines, 'ng.vat.monthly-return');
      expect(dues, hasLength(12));
      expect(dues.first, d(2026, 2, 21));
      expect(dues.last, d(2027, 1, 21));
      expect(
        deadlines
            .firstWhere((deadline) => deadline.id == 'ng.vat.monthly-return')
            .dependsOnProfile,
        isTrue,
      );
    });

    test('no date moves for a weekend', () {
      final deadlines = _for(2026, EntityKind.company, vat: true);
      expect(d(2026, 2, 21).weekday, DateTime.saturday);
      expect(
        deadlines.every((deadline) => deadline.rolledFrom == null),
        isTrue,
      );
    });

    test('an individual has no employer dates', () {
      expect(
        _for(2026, EntityKind.individual).where(
          (deadline) =>
              deadline.id.contains('paye') || deadline.id.contains('wht'),
        ),
        isEmpty,
      );
    });
  });
}
