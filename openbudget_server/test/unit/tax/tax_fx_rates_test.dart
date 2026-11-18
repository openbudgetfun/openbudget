import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_fx_rates.dart';
import 'package:test/test.dart';

final _gbp = DateTime.utc(2026, 1, 15);

FxDailyRate _rate(String code, DateTime date, String rate) => FxDailyRate(
  currencyCode: code,
  rateDate: date,
  rate: rate,
  fetchedAt: date.add(const Duration(hours: 2)),
);

TaxFxRates _rates(List<FxDailyRate> rows) =>
    TaxFxRates(rates: rows, evaluatedAt: DateTime.utc(2026, 1, 16));

void main() {
  group('Given exact tax FX rates', () {
    test('when the codes match then identity needs no stored rate', () {
      final rates = _rates(const []);

      expect(
        rates.convert(
          amountMinor: 12345,
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        12345,
      );
    });

    test('when converting both directions then the cross rate is exact', () {
      final rates = _rates([
        _rate('USD', DateTime.utc(2026, 1, 14), '1'),
        _rate('GBP', DateTime.utc(2026, 1, 14), '0.8'),
      ]);

      expect(
        rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        8000,
      );
      expect(
        rates.convert(
          amountMinor: 8000,
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'USD',
          date: _gbp,
        ),
        10000,
      );
    });

    test('when JPY has no minor unit then cents and yen rescale exactly', () {
      final rates = _rates([
        _rate('JPY', DateTime.utc(2026, 1, 14), '150'),
        _rate('GBP', DateTime.utc(2026, 1, 14), '0.8'),
      ]);

      expect(
        rates.convert(
          amountMinor: 15000,
          fromCurrencyCode: 'JPY',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        8000,
      );
      expect(
        rates.convert(
          amountMinor: 8000,
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'JPY',
          date: _gbp,
        ),
        15000,
      );
    });

    test('when KWD has three decimals then rounding happens once', () {
      final rates = _rates([
        _rate('KWD', DateTime.utc(2026, 1, 14), '0.307'),
        _rate('GBP', DateTime.utc(2026, 1, 14), '0.8'),
      ]);

      // 10.000 KWD is 32.5733 USD and 26.0586 GBP; half up gives 2606 pence.
      expect(
        rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'KWD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        2606,
      );
    });

    test('when a newer row is inside the window then it wins', () {
      final rates = _rates([
        _rate('USD', DateTime.utc(2026, 1, 10), '1'),
        _rate('GBP', DateTime.utc(2026, 1, 10), '0.8'),
        _rate('GBP', DateTime.utc(2026, 1, 14), '0.9'),
      ]);

      expect(
        rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        9000,
      );
    });

    test('when a row is exactly seven days old then it is outside', () {
      final rates = _rates([
        _rate('USD', DateTime.utc(2026, 1, 8), '1'),
        _rate('GBP', DateTime.utc(2026, 1, 8), '0.8'),
      ]);
      final request = TaxFxRequest(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: _gbp,
      );

      expect(rates.missingFor([request]), [request]);
    });

    test('when only a future row exists then no quote is invented', () {
      final rates = _rates([
        _rate('USD', DateTime.utc(2026, 1, 16), '1'),
        _rate('GBP', DateTime.utc(2026, 1, 16), '0.8'),
      ]);
      final request = TaxFxRequest(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: _gbp,
      );

      expect(rates.missingFor([request]), [request]);
      expect(
        () => rates.convert(
          amountMinor: 10000,
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        throwsA(
          isA<FxRateUnavailableException>().having(
            (error) => error.date,
            'date',
            _gbp,
          ),
        ),
      );
    });

    test('when one side is missing then it never becomes 1:1', () {
      final rates = _rates([_rate('GBP', DateTime.utc(2026, 1, 14), '0.8')]);
      final request = TaxFxRequest(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: _gbp,
      );

      expect(rates.missingFor([request]), [request]);
    });

    test('when a stored rate is zero then it is ignored', () {
      final rates = _rates([
        _rate('USD', DateTime.utc(2026, 1, 14), '0'),
        _rate('GBP', DateTime.utc(2026, 1, 14), '0.8'),
      ]);
      final request = TaxFxRequest(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        date: _gbp,
      );

      expect(rates.missingFor([request]), [request]);
    });

    test('when requests repeat then missing dates are deduplicated', () {
      final rates = _rates(const []);
      final requests = [
        TaxFxRequest(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        TaxFxRequest(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        TaxFxRequest(
          fromCurrencyCode: 'EUR',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
        TaxFxRequest(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: DateTime.utc(2026, 1, 16),
        ),
        TaxFxRequest(
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'GBP',
          date: _gbp,
        ),
      ];

      expect(rates.missingFor(requests), hasLength(3));
    });
  });
}
