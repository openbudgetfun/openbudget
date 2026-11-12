import 'dart:convert';

import 'package:openbudget_server/src/fx_rates/fx_provider_client.dart';
import 'package:test/test.dart';

void main() {
  group('parseProviderRate', () {
    test('accepts positive numbers and expands exponent notation', () {
      expect(parseProviderRate(1), '1');
      expect(parseProviderRate(0.9), '0.9');
      expect(parseProviderRate(1e-7), '0.0000001');
      expect(parseProviderRate('0.307'), '0.307');
      expect(parseProviderRate('150'), '150');
      expect(parseProviderRate('1e-7'), '0.0000001');
      expect(parseProviderRate(' 123456.789 '), '123456.789');
    });

    test('rejects zero, negative, non-finite and malformed values', () {
      for (final value in <Object?>[
        null,
        0,
        0.0,
        -1,
        -0.5,
        double.nan,
        double.infinity,
        double.negativeInfinity,
        '0',
        '-1',
        'NaN',
        'Infinity',
        '',
        '   ',
        'abc',
        true,
      ]) {
        expect(parseProviderRate(value), isNull, reason: '$value');
      }
    });
  });

  group('parseCurrencyApiResponse', () {
    test('keeps supported valid rates and skips malformed ones', () {
      final body = jsonEncode({
        'meta': {'last_updated_at': '2026-03-09T10:00:00Z'},
        'data': {
          'USD': {'value': 1},
          'EUR': {'value': 0.9},
          'GBP': {'value': '0.8'},
          'JPY': {'value': 0},
          'KWD': {'value': -0.3},
          'CHF': {'value': 'not-a-rate'},
          'ZZZ': {'value': 4},
        },
      });

      final result = parseCurrencyApiResponse(body);

      expect(result.fetchedAt, DateTime.utc(2026, 3, 9, 10));
      expect(result.rates, {'USD': '1', 'EUR': '0.9', 'GBP': '0.8'});
    });

    test('throws when the provider has no usable rate', () {
      final body = jsonEncode({
        'data': {
          'USD': {'value': 1},
          'EUR': {'value': 0},
          'GBP': {'value': -1},
        },
      });

      expect(
        () => parseCurrencyApiResponse(body),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('no usable rates'),
          ),
        ),
      );
    });

    test('throws for an invalid payload', () {
      expect(
        () => parseCurrencyApiResponse(jsonEncode(['nope'])),
        throwsA(isA<Exception>()),
      );
      expect(
        () => parseCurrencyApiResponse(jsonEncode({'data': <Object?>[]})),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('historical provider URL carries the exact calendar date', () {
    final uri = currencyApiUri(
      baseUrl: 'https://example.test/v3/',
      path: 'historical',
      apiKey: 'key',
      baseCurrencyCode: 'USD',
      currencies: const ['USD', 'GBP'],
      date: DateTime.utc(2026, 3, 9),
    );

    expect(uri.path, '/v3/historical');
    expect(uri.queryParameters['date'], '2026-03-09');
    expect(uri.queryParameters['base_currency'], 'USD');
    expect(uri.queryParameters['currencies'], 'USD,GBP');
    expect(uri.queryParameters['apikey'], 'key');
  });
}
