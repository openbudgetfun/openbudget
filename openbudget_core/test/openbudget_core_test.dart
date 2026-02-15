import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('CurrencyCode', () {
    test('has five initial currencies', () {
      expect(CurrencyCode.values, hasLength(5));
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
}
