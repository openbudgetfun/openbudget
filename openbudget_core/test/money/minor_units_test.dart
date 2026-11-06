import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('parseMinorUnits', () {
    test('parses whole and fractional amounts exactly', () {
      expect(parseMinorUnits('12.34', 2), 1234);
      expect(parseMinorUnits('1,200.00', 2), 120000);
      expect(parseMinorUnits(' 42.5 ', 2), 4250);
      expect(parseMinorUnits('.5', 2), 50);
      expect(parseMinorUnits('7', 0), 7);
      expect(parseMinorUnits('1.234', 3), 1234);
    });

    test('refuses input it would have to round or guess', () {
      expect(parseMinorUnits('', 2), isNull);
      expect(parseMinorUnits('.', 2), isNull);
      expect(parseMinorUnits('twelve', 2), isNull);
      expect(parseMinorUnits('-1', 2), isNull);
      expect(parseMinorUnits('1.2.3', 2), isNull);
      expect(parseMinorUnits('12.345', 2), isNull);
      expect(parseMinorUnits('1.5', 0), isNull);
      expect(parseMinorUnits('1e3', 2), isNull);
    });
  });

  group('formatMinorUnits', () {
    test('renders minor units as a plain figure', () {
      expect(formatMinorUnits(1234, 2), '12.34');
      expect(formatMinorUnits(5, 2), '0.05');
      expect(formatMinorUnits(-1250, 2), '-12.50');
      expect(formatMinorUnits(7, 0), '7');
      expect(formatMinorUnits(1234, 3), '1.234');
    });

    test('round-trips through parseMinorUnits', () {
      for (final minor in [0, 1, 99, 100, 123456789]) {
        expect(parseMinorUnits(formatMinorUnits(minor, 2), 2), minor);
      }
    });
  });
}
