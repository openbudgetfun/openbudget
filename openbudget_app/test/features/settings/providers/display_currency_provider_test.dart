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
      final result = converter.convertMinor(
        amountMinor: 12345,
        sourceCurrency: CurrencyCode.eur,
      );

      expect(result, 12345);
    });

    test('converts between USD, EUR, and GBP using provider rates', () {
      final usdToEur = converter.convertMinor(
        amountMinor: 10000,
        sourceCurrency: CurrencyCode.usd,
      );
      expect(usdToEur, 8000);

      final gbpToEur = converter.convertMinor(
        amountMinor: 10000,
        sourceCurrency: CurrencyCode.gbp,
      );
      // 100.00 GBP -> (100 / 0.7) * 0.8 = 114.2857 EUR
      expect(gbpToEur, 11429);
    });

    test('respects JPY and BTC precision rules', () {
      final jpyToEur = converter.convertMinor(
        amountMinor: 12345,
        sourceCurrency: CurrencyCode.jpy,
      );
      // 12,345 JPY -> (12,345 / 150) * 0.8 = 65.84 EUR
      expect(jpyToEur, 6584);

      const btcDisplay = DisplayCurrencyConverter(
        displayCurrency: CurrencyCode.btc,
        baseCurrencyCode: 'USD',
        ratesByCode: {'USD': 1.0, 'BTC': 0.00002},
      );
      final usdToBtc = btcDisplay.convertMinor(
        amountMinor: 123,
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

      final converted = missingRateConverter.convertMinor(
        amountMinor: 10000,
        sourceCurrency: CurrencyCode.gbp,
      );
      expect(converted, isNull);
      expect(
        missingRateConverter.formatAmount(
          amountMinor: 10000,
          currencyCode: 'GBP',
        ),
        '\u00A3100.00',
      );
    });

    test(
      'formats unsupported codes with their raw code instead of dollars',
      () {
        expect(
          converter.formatAmount(amountMinor: 1250, currencyCode: 'XYZ'),
          'XYZ 12.50',
        );
      },
    );

    test('cannot convert totals containing an unsupported code', () {
      expect(
        converter.convertTotalsToDisplay({'USD': 10000, 'XYZ': 1250}),
        isNull,
      );
      expect(converter.convertTotalsToDisplay({'USD': 10000}), 8000);
    });
  });
}
