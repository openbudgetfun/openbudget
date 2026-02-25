import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('DisplayCurrencyConverter', () {
    late DisplayCurrencyConverter converter;

    setUp(() {
      converter = const DisplayCurrencyConverter(
        displayCurrency: CurrencyCode.eur,
        baseCurrencyCode: 'USD',
        ratesByCode: {
          'USD': 1.0,
          'EUR': 0.8,
          'GBP': 0.7,
          'JPY': 150.0,
          'BTC': 0.00002,
        },
      );
    });

    test('same currency conversion is passthrough', () {
      final result = converter.convertCents(
        amountCents: 12345,
        sourceCurrency: CurrencyCode.eur,
      );

      expect(result, 12345);
    });

    test('converts between USD, EUR, and GBP using provider rates', () {
      final usdToEur = converter.convertCents(
        amountCents: 10000,
        sourceCurrency: CurrencyCode.usd,
      );
      expect(usdToEur, 8000);

      final gbpToEur = converter.convertCents(
        amountCents: 10000,
        sourceCurrency: CurrencyCode.gbp,
      );
      // 100.00 GBP -> (100 / 0.7) * 0.8 = 114.2857 EUR
      expect(gbpToEur, 11429);
    });

    test('respects JPY and BTC precision rules', () {
      final jpyToEur = converter.convertCents(
        amountCents: 12345,
        sourceCurrency: CurrencyCode.jpy,
      );
      // 12,345 JPY -> (12,345 / 150) * 0.8 = 65.84 EUR
      expect(jpyToEur, 6584);

      const btcDisplay = DisplayCurrencyConverter(
        displayCurrency: CurrencyCode.btc,
        baseCurrencyCode: 'USD',
        ratesByCode: {'USD': 1.0, 'BTC': 0.00002},
      );
      final usdToBtc = btcDisplay.convertCents(
        amountCents: 123,
        sourceCurrency: CurrencyCode.usd,
      );
      // 1.23 USD -> 0.00002460 BTC -> 2460 sats
      expect(usdToBtc, 2460);
    });

    test('returns null and formats native amount when rate is missing', () {
      const missingRateConverter = DisplayCurrencyConverter(
        displayCurrency: CurrencyCode.eur,
        baseCurrencyCode: 'USD',
        ratesByCode: {'USD': 1.0},
      );

      final converted = missingRateConverter.convertCents(
        amountCents: 10000,
        sourceCurrency: CurrencyCode.gbp,
      );
      expect(converted, isNull);
      expect(
        missingRateConverter.formatAmount(
          amountCents: 10000,
          sourceCurrency: CurrencyCode.gbp,
        ),
        '\u00A3100.00',
      );
    });
  });
}
