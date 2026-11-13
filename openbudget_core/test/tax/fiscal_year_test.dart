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
