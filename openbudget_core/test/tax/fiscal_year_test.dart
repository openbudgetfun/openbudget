import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('defaultFiscalYearEnd', () {
    test('GB companies end on 31 March', () {
      expect(defaultFiscalYearEnd('GB', EntityKind.company), (
        month: 3,
        day: 31,
      ));
    });

    test('GB individuals end on 5 April', () {
      expect(
        defaultFiscalYearEnd('GB', EntityKind.individual),
        (month: 4, day: 5),
      );
      expect(
        defaultFiscalYearEnd('GB', EntityKind.soleTrader),
        (month: 4, day: 5),
      );
    });

    test('US, NG and DE use the calendar year for every entity kind', () {
      for (final code in ['US', 'NG', 'DE']) {
        for (final kind in EntityKind.values) {
          expect(defaultFiscalYearEnd(code, kind), (month: 12, day: 31));
        }
      }
    });

    test('individuals end the day before the country tax year starts', () {
      expect(defaultFiscalYearEnd('KE', EntityKind.individual), (
        month: 12,
        day: 31,
      ));
      // Australia's tax year starts on 1 July, so it ends on 30 June.
      expect(defaultFiscalYearEnd('AU', EntityKind.individual), (
        month: 6,
        day: 30,
      ));
      expect(defaultFiscalYearEnd('AU', EntityKind.soleTrader), (
        month: 6,
        day: 30,
      ));
      // India's tax year starts on 1 April, so it ends on 31 March.
      expect(defaultFiscalYearEnd('IN', EntityKind.individual), (
        month: 3,
        day: 31,
      ));
    });

    test('a company keeps its own year end, not the individual one', () {
      expect(defaultFiscalYearEnd('AU', EntityKind.company), (
        month: 6,
        day: 30,
      ));
      expect(defaultFiscalYearEnd('KE', EntityKind.company), (
        month: 12,
        day: 31,
      ));
    });

    test('non-Gregorian tax years fall back to the calendar year', () {
      for (final code in ['AF', 'ET', 'NP', 'SA']) {
        expect(defaultFiscalYearEnd(code, EntityKind.individual), (
          month: 12,
          day: 31,
        ));
      }
    });

    test('countries with no tax year in the dataset use the calendar year', () {
      for (final code in ['AX', 'IO', 'PM', 'SH', 'SJ', 'SS']) {
        expect(defaultFiscalYearEnd(code, EntityKind.individual), (
          month: 12,
          day: 31,
        ));
      }
    });

    test('is case-insensitive on the country code', () {
      expect(defaultFiscalYearEnd('gb', EntityKind.company), (
        month: 3,
        day: 31,
      ));
    });

    test('unknown countries use the calendar year', () {
      for (final kind in EntityKind.values) {
        expect(defaultFiscalYearEnd('ZZ', kind), (month: 12, day: 31));
        expect(defaultFiscalYearEnd('', kind), (month: 12, day: 31));
      }
    });
  });
}
