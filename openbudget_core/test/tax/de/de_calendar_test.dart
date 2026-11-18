// German filing and payment dates from the germany-tax skill, with the
// § 149 AO deadlines and the § 108 Abs. 3 AO roll-forward vectors.
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:test/test.dart';

const DeTaxRules _pack = DeTaxRules();

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

List<TaxDeadline> _for(
  int startYear,
  EntityKind kind, {
  bool vat = false,
  bool exemption = true,
  DeEinkunftsArt art = DeEinkunftsArt.gewerblich,
}) => _pack.deadlines(
  _pack.taxYear(startYear),
  DeTaxProfile(
    entityKind: kind,
    salesTaxRegistered: vat,
    smallBusinessExemption: exemption,
    einkunftsArt: art,
  ),
);

TaxDeadline _only(List<TaxDeadline> deadlines, String id) =>
    deadlines.singleWhere((deadline) => deadline.id == id);

List<DateTime> _dues(List<TaxDeadline> deadlines, String id) => [
  for (final deadline in deadlines)
    if (deadline.id == id) deadline.dueDate,
];

void main() {
  group('the annual return', () {
    test('Veranlagungszeitraum 2025: 31 Jul 2026 self-filed, 1 Mar 2027 '
        'advised', () {
      final deadlines = _for(2025, EntityKind.individual);
      expect(_only(deadlines, 'de.erklaerung.abgabe').dueDate, d(2026, 7, 31));
      final advised = _only(deadlines, 'de.erklaerung.abgabe-beraten');
      expect(advised.dueDate, d(2027, 3, 1));
      expect(advised.rolledFrom, d(2027, 2, 28));
    });

    test('Veranlagungszeitraum 2026: Saturday 31 Jul 2027 rolls to Monday 2 '
        'Aug', () {
      final deadlines = _for(2026, EntityKind.individual);
      final self = _only(deadlines, 'de.erklaerung.abgabe');
      expect(d(2027, 7, 31).weekday, DateTime.saturday);
      expect(self.dueDate, d(2027, 8, 2));
      expect(self.rolledFrom, d(2027, 7, 31));
      final advised = _only(deadlines, 'de.erklaerung.abgabe-beraten');
      expect(advised.dueDate, d(2028, 2, 29));
      expect(advised.rolledFrom, isNull);
    });

    test('the pack agrees with the deadline functions it reuses', () {
      for (final year in [2025, 2026]) {
        final deadlines = _for(year, EntityKind.soleTrader);
        expect(
          _only(deadlines, 'de.erklaerung.abgabe').dueDate,
          deFilingDeadline(year),
        );
        expect(
          _only(deadlines, 'de.erklaerung.abgabe-beraten').dueDate,
          deAdvisorFilingDeadline(year),
        );
      }
    });

    test('the title names the returns of the kind of books', () {
      expect(
        _only(_for(2025, EntityKind.individual), 'de.erklaerung.abgabe').title,
        'Abgabe der Einkommensteuererklärung',
      );
      expect(
        _only(_for(2025, EntityKind.company), 'de.erklaerung.abgabe').title,
        contains('Körperschaftsteuer'),
      );
    });
  });

  group('prepayments', () {
    test('Einkommensteuer is paid on 10 Mar, 10 Jun, 10 Sep and 10 Dec', () {
      expect(
        _dues(_for(2026, EntityKind.soleTrader), 'de.est.vorauszahlung'),
        [d(2026, 3, 10), d(2026, 6, 10), d(2026, 9, 10), d(2026, 12, 10)],
      );
    });

    test('payments are not moved: § 108 AO moves deadlines, not due dates', () {
      final deadlines = _for(2026, EntityKind.soleTrader);
      expect(d(2026, 6, 10).weekday, DateTime.wednesday);
      for (final deadline in deadlines.where(
        (deadline) => deadline.kind == TaxDeadlineKind.payment,
      )) {
        expect(deadline.rolledFrom, isNull, reason: deadline.id);
      }
    });

    test('Gewerbesteuer is paid on 15 Feb, 15 May, 15 Aug and 15 Nov', () {
      expect(
        _dues(_for(2026, EntityKind.soleTrader), 'de.gewst.vorauszahlung'),
        [d(2026, 2, 15), d(2026, 5, 15), d(2026, 8, 15), d(2026, 11, 15)],
      );
    });

    test('a Freiberufler has no Gewerbesteuer dates; a company has them', () {
      expect(
        _for(
          2026,
          EntityKind.soleTrader,
          art: DeEinkunftsArt.freiberuflich,
        ).where((deadline) => deadline.id == 'de.gewst.vorauszahlung'),
        isEmpty,
      );
      expect(
        _dues(_for(2026, EntityKind.company), 'de.gewst.vorauszahlung'),
        hasLength(4),
      );
    });

    test('a company has no Einkommensteuer prepayments', () {
      expect(
        _for(2026, EntityKind.company).where(
          (deadline) => deadline.id == 'de.est.vorauszahlung',
        ),
        isEmpty,
      );
    });
  });

  group('Umsatzsteuer and Lohnsteuer', () {
    test('a Kleinunternehmer files no Voranmeldung', () {
      expect(
        _for(2026, EntityKind.soleTrader, vat: true).where(
          (deadline) => deadline.id == 'de.ust.voranmeldung',
        ),
        isEmpty,
      );
    });

    test('a registered business files quarterly on the 10th after', () {
      final deadlines = _for(
        2026,
        EntityKind.soleTrader,
        vat: true,
        exemption: false,
      );
      expect(_dues(deadlines, 'de.ust.voranmeldung'), [
        d(2026, 4, 10),
        d(2026, 7, 10),
        d(2026, 10, 10),
        d(2027, 1, 10),
      ]);
      final first = deadlines.firstWhere(
        (deadline) => deadline.id == 'de.ust.voranmeldung',
      );
      expect(first.dependsOnProfile, isTrue);
      expect(first.periodLabel, '1. Quartal 2026');
      expect(first.kind, TaxDeadlineKind.filingAndPayment);
    });

    test('a company reports payroll tax quarterly on the 10th after', () {
      expect(
        _dues(_for(2026, EntityKind.company), 'de.lohnsteuer.anmeldung'),
        [d(2026, 4, 10), d(2026, 7, 10), d(2026, 10, 10), d(2027, 1, 10)],
      );
    });
  });
}
