import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('CurrencyCode', () {
    test('codes are unique ISO 4217 style codes', () {
      final codes = CurrencyCode.values.map((currency) => currency.code);
      expect(codes.toSet(), hasLength(CurrencyCode.values.length));
      expect(codes, everyElement(matches(RegExp(r'^[A-Z]{3}$'))));
    });

    test('USD has correct properties', () {
      expect(CurrencyCode.usd.code, 'USD');
      expect(CurrencyCode.usd.displayName, 'US Dollar');
      expect(CurrencyCode.usd.symbol, r'$');
      expect(CurrencyCode.usd.decimals, 2);
    });

    test('BTC has 8 decimal places', () {
      expect(CurrencyCode.btc.decimals, 8);
    });

    test('JPY has 0 decimal places', () {
      expect(CurrencyCode.jpy.decimals, 0);
    });
  });

  group('CurrencyCode.tryParse', () {
    test('finds supported codes in any case', () {
      expect(CurrencyCode.tryParse('NGN'), CurrencyCode.ngn);
      expect(CurrencyCode.tryParse('eur'), CurrencyCode.eur);
    });

    test('returns null for unsupported codes instead of guessing', () {
      expect(CurrencyCode.tryParse('XYZ'), isNull);
    });

    test('every tax jurisdiction currency is supported', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        expect(CurrencyCode.tryParse(jurisdiction.currencyCode), isNotNull);
      }
    });

    test('zero-decimal currencies keep whole minor units', () {
      expect(CurrencyCode.krw.decimals, 0);
      expect(CurrencyCode.ngn.decimals, 2);
    });
  });
}
