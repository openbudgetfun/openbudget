// The § 108 Abs. 3 AO roll-forward: a filing deadline that falls on a
// Saturday, Sunday or public holiday moves to the next working day. The
// day-of-week and holiday vectors are the ones in the germany-tax skill
// (`references/test-vectors.md`, `references/vat-payroll-deadlines.md`).
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:test/test.dart';

/// A UTC date, spelled out so the test vectors read like the skill's table.
DateTime de(int year, int month, int day) => DateTime.utc(year, month, day);

void main() {
  group('filing deadlines', () {
    test('VZ 2025 self-filer stays on Friday 31 Jul 2026', () {
      expect(deFilingDeadline(2025), de(2026, 7, 31));
    });

    test('VZ 2025 advised rolls from Sunday 28 Feb to Monday 1 Mar 2027', () {
      expect(deAdvisorFilingDeadline(2025), de(2027, 3, 1));
    });

    test(
      'VZ 2026 self-filer rolls from Saturday 31 Jul to Monday 2 Aug 2027',
      () {
        expect(deFilingDeadline(2026), de(2027, 8, 2));
      },
    );

    test('VZ 2026 advised stays on Tuesday 29 Feb 2028', () {
      expect(deAdvisorFilingDeadline(2026), de(2028, 2, 29));
    });

    test('VZ 2024 advised stays on Thursday 30 Apr 2026', () {
      expect(deAdvisorFilingDeadline(2024), de(2026, 4, 30));
    });
  });

  group('§ 108 Abs. 3 AO roll-forward', () {
    test('moves a Saturday to Monday', () {
      expect(deRollForward(de(2026, 10, 3)), de(2026, 10, 5));
    });

    test('moves a Sunday to Monday', () {
      expect(deRollForward(de(2027, 2, 28)), de(2027, 3, 1));
    });

    test('moves a Saturday that is also a Feiertag past the weekend', () {
      // 25 Dec 2026 is the first Weihnachtstag (Friday); 26 Dec is Saturday
      // and the second Weihnachtstag; 27 Dec is Sunday.
      expect(deRollForward(de(2026, 12, 25)), de(2026, 12, 28));
    });

    test('moves Karfreitag past Ostermontag', () {
      // Good Friday 26 Mar 2027 and Easter Monday 29 Mar 2027 are both
      // nationwide Feiertage.
      expect(deRollForward(de(2027, 3, 26)), de(2027, 3, 30));
    });

    test('moves Pfingstmontag to Tuesday', () {
      expect(deRollForward(de(2027, 5, 17)), de(2027, 5, 18));
    });

    test('moves Neujahr over the weekend', () {
      // 1 Jan 2027 is a Friday and a Feiertag.
      expect(deRollForward(de(2027, 1, 1)), de(2027, 1, 4));
    });

    test('leaves a working day untouched', () {
      expect(deRollForward(de(2026, 11, 5)), de(2026, 11, 5));
    });
  });
}
