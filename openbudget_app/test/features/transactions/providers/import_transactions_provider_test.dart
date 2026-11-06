import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/transactions/providers/import_transactions_provider.dart';

void main() {
  group('parseCsvText', () {
    test('parses typed amounts into exact minor units', () {
      final rows = parseCsvText(
        'Date,Description,Amount\n'
            '2026-01-15,Grocery,12.34\n'
            '2026-01-16,Salary,"1,200.05"\n',
        'USD',
      );

      expect(rows.map((row) => row.amountCents).toList(), [1234, 120005]);
    });

    test('keeps negative amounts from bank exports', () {
      final rows = parseCsvText(
        'Date,Description,Amount\n'
            '2026-01-15,Grocery,-45.50\n',
        'USD',
      );

      expect(rows.single.amountCents, -4550);
    });

    test('skips over-precise and malformed amounts instead of rounding', () {
      final rows = parseCsvText(
        'Date,Description,Amount\n'
            '2026-01-15,Grocery,12.345\n'
            '2026-01-16,Refund,-12.345\n'
            '2026-01-17,Broken,12.3.4\n'
            '2026-01-18,Exact,12.34\n',
        'USD',
      );

      expect(rows.map((row) => row.description).toList(), ['Exact']);
      expect(rows.single.amountCents, 1234);
    });

    test('uses the currency decimals when refusing precision', () {
      final rows = parseCsvText(
        'Date,Description,Amount\n'
            '2026-01-15,Yen,1200\n'
            '2026-01-16,Yen with cents,12.34\n',
        'JPY',
      );

      expect(rows.single.amountCents, 1200);
    });

    test('parses cryptocurrency precision', () {
      final rows = parseCsvText(
        'Date,Description,Amount\n'
            '2026-01-15,Buy,0.00000042\n',
        'BTC',
      );

      expect(rows.single.amountCents, 42);
    });
  });
}
