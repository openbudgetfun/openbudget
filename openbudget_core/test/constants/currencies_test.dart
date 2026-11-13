import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// The ISO 4217 data the enum is generated from, parsed once.
final _Iso4217Data _iso4217 = _readIso4217();

void main() {
  group('iso4217.json', () {
    test('records the official list it was taken from', () {
      expect(_iso4217.publisher, contains('SIX'));
      expect(_iso4217.document, contains('ISO 4217'));
      expect(_iso4217.url, startsWith('https://www.six-group.com/'));
      expect(_iso4217.symbolSource, contains('CLDR'));

      final published = DateTime.tryParse(_iso4217.publishedOn);
      final retrieved = DateTime.tryParse(_iso4217.retrievedOn);
      expect(published, isNotNull, reason: _iso4217.publishedOn);
      expect(retrieved, isNotNull, reason: _iso4217.retrievedOn);
      expect(
        retrieved!.isBefore(published!),
        isFalse,
        reason: 'The list cannot be retrieved before it was published.',
      );
    });

    test('lists each code once', () {
      final codes = _iso4217.currencies.map((currency) => currency.code);
      expect(codes.toSet(), hasLength(_iso4217.currencies.length));
      expect(codes, everyElement(matches(RegExp(r'^[A-Z]{3}$'))));
    });

    test('names and draws every currency', () {
      for (final currency in _iso4217.currencies) {
        expect(currency.name.trim(), isNotEmpty, reason: currency.code);
        expect(currency.symbol, isNotEmpty, reason: currency.code);
      }
    });

    test('uses only the exponents ISO 4217 publishes', () {
      final published = {
        for (final currency in _iso4217.currencies)
          if (currency.isIso) currency.exponent,
      };
      expect(published, {0, 2, 3, 4});

      final fourDecimalPlaces = [
        for (final currency in _iso4217.currencies)
          if (currency.exponent == 4) currency.code,
      ];
      expect(
        fourDecimalPlaces,
        ['CLF', 'UYW'],
        reason: 'ISO 4217 publishes exponent 4 for these two funds only.',
      );
    });

    test('leaves out exactly the codes with no published minor unit', () {
      expect(_iso4217.excluded, _excludedCodes);
      for (final code in _iso4217.excluded) {
        expect(
          CurrencyCode.tryParse(code),
          isNull,
          reason: '$code has no minor unit, so it is not a currency here',
        );
      }
    });

    test('marks BTC as the one code outside ISO 4217', () {
      expect(_iso4217.currencies.last.code, 'BTC');
      expect(_iso4217.currencies.last.isIso, isFalse);
      expect(
        [
          for (final currency in _iso4217.currencies)
            if (!currency.isIso) currency.code,
        ],
        ['BTC'],
      );
    });
  });

  group('CurrencyCode', () {
    test('has a member for every listed currency', () {
      expect(CurrencyCode.values, hasLength(_iso4217.currencies.length));
      expect(CurrencyCode.values, hasLength(greaterThan(160)));
    });

    test('matches the generated data member by member', () {
      for (final currency in _iso4217.currencies) {
        final code = CurrencyCode.tryParse(currency.code);
        expect(code, isNotNull, reason: '${currency.code} is missing');
        expect(code!.code, currency.code);
        expect(code.displayName, currency.displayName, reason: currency.code);
        expect(code.symbol, currency.symbol, reason: currency.code);
        expect(code.decimals, currency.exponent, reason: currency.code);
      }
    });

    test('keeps the currencies it shipped with, in their original order', () {
      final shipped = [
        for (final currency in _originalCurrencies)
          if (currency.$1 != 'BTC') currency,
      ];
      expect(
        CurrencyCode.values
            .take(shipped.length)
            .map((currency) => currency.code),
        shipped.map((currency) => currency.$1),
      );
      expect(CurrencyCode.values.last, CurrencyCode.btc);
      for (final (code, name, symbol, decimals) in _originalCurrencies) {
        final currency = CurrencyCode.tryParse(code);
        expect(currency, isNotNull, reason: code);
        expect(currency!.displayName, name, reason: code);
        expect(currency.symbol, symbol, reason: code);
        expect(currency.decimals, decimals, reason: code);
      }
    });

    test('parses a known code whatever its case or padding', () {
      expect(CurrencyCode.tryParse('USD'), CurrencyCode.usd);
      expect(CurrencyCode.tryParse('kes'), CurrencyCode.kes);
      expect(CurrencyCode.tryParse('  try  '), CurrencyCode.try_);
    });

    test('returns null instead of guessing', () {
      expect(CurrencyCode.tryParse('XYZ'), isNull);
      expect(CurrencyCode.tryParse('US'), isNull);
      expect(CurrencyCode.tryParse(''), isNull);
    });
  });

  group('currencyapi.com', () {
    test('leaves exactly the currencies below without a price', () {
      final unpriced = [
        for (final currency in CurrencyCode.values)
          if (!_pricedByCurrencyApi.contains(currency.code)) currency.code,
      ]..sort();
      expect(unpriced, _unpricedByCurrencyApi);
    });

    test('classifies every currency as priced or unpriced, never both', () {
      final unpriced = _unpricedByCurrencyApi.toSet();
      expect(_pricedByCurrencyApi.intersection(unpriced), isEmpty);
      expect(
        {..._pricedByCurrencyApi, ...unpriced},
        unorderedEquals(CurrencyCode.values.map((currency) => currency.code)),
      );
    });

    test('none of the unpriced currencies blocks entity creation', () {
      // EntityService.create rejects a base currency only when
      // CurrencyCode.tryParse returns null, so parsing is the whole gate.
      for (final code in _unpricedByCurrencyApi) {
        final currency = CurrencyCode.tryParse(code);
        expect(
          currency,
          isNotNull,
          reason: '$code must parse so an entity can use it as its base',
        );
        expect(currency!.code, code);
      }
    });
  });
}

/// One row of `data/iso4217.json`.
class _IsoCurrency {
  const _IsoCurrency({
    required this.code,
    required this.name,
    required this.displayName,
    required this.exponent,
    required this.symbol,
    required this.isIso,
  });

  factory _IsoCurrency.fromJson(Map<String, Object?> json) => _IsoCurrency(
    code: json['code']! as String,
    name: json['name']! as String,
    displayName: (json['displayName'] ?? json['name'])! as String,
    exponent: json['exponent']! as int,
    symbol: json['symbol']! as String,
    isIso: json['iso'] != false,
  );

  final String code;
  final String name;
  final String displayName;
  final int exponent;
  final String symbol;
  final bool isIso;
}

/// The provenance and rows read from `data/iso4217.json`.
class _Iso4217Data {
  const _Iso4217Data({
    required this.publisher,
    required this.document,
    required this.url,
    required this.publishedOn,
    required this.retrievedOn,
    required this.symbolSource,
    required this.excluded,
    required this.currencies,
  });

  final String publisher;
  final String document;
  final String url;
  final String publishedOn;
  final String retrievedOn;
  final String symbolSource;
  final List<String> excluded;
  final List<_IsoCurrency> currencies;
}

_Iso4217Data _readIso4217() {
  // `dart test` runs with the package root as the working directory.
  final json = jsonDecode(
    File('data/iso4217.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final source = json['source']! as Map<String, Object?>;
  final excluded = json['excluded']! as Map<String, Object?>;
  final symbolSource = json['symbolSource']! as Map<String, Object?>;
  return _Iso4217Data(
    publisher: source['publisher']! as String,
    document: source['document']! as String,
    url: source['url']! as String,
    publishedOn: source['publishedOn']! as String,
    retrievedOn: source['retrievedOn']! as String,
    symbolSource: symbolSource['document']! as String,
    excluded: [
      for (final code in excluded['codes']! as List<Object?>) code! as String,
    ],
    currencies: [
      for (final row in json['currencies']! as List<Object?>)
        _IsoCurrency.fromJson(row! as Map<String, Object?>),
    ],
  );
}

/// The formats the currencies OpenBudget shipped with: ISO code, display name,
/// symbol and minor unit, in enum order. They must never change.
///
/// BTC has always had 8 decimal places and is not an ISO 4217 code.
const _originalCurrencies = [
  ('USD', 'US Dollar', r'$', 2),
  ('EUR', 'Euro', '\u20AC', 2),
  ('GBP', 'British Pound', '\u00A3', 2),
  ('JPY', 'Japanese Yen', '\u00A5', 0),
  ('NGN', 'Nigerian Naira', '\u20A6', 2),
  ('CAD', 'Canadian Dollar', r'CA$', 2),
  ('AUD', 'Australian Dollar', r'A$', 2),
  ('NZD', 'New Zealand Dollar', r'NZ$', 2),
  ('CHF', 'Swiss Franc', 'CHF\u00A0', 2),
  ('SEK', 'Swedish Krona', 'kr\u00A0', 2),
  ('NOK', 'Norwegian Krone', 'kr\u00A0', 2),
  ('DKK', 'Danish Krone', 'kr\u00A0', 2),
  ('PLN', 'Polish Zloty', 'z\u0142\u00A0', 2),
  ('CNY', 'Chinese Yuan', 'CN\u00A5', 2),
  ('HKD', 'Hong Kong Dollar', r'HK$', 2),
  ('SGD', 'Singapore Dollar', r'S$', 2),
  ('KRW', 'South Korean Won', '\u20A9', 0),
  ('INR', 'Indian Rupee', '\u20B9', 2),
  ('AED', 'UAE Dirham', 'AED\u00A0', 2),
  ('ZAR', 'South African Rand', 'R\u00A0', 2),
  ('KES', 'Kenyan Shilling', 'KSh\u00A0', 2),
  ('GHS', 'Ghanaian Cedi', 'GH\u20B5', 2),
  ('BRL', 'Brazilian Real', r'R$', 2),
  ('MXN', 'Mexican Peso', r'MX$', 2),
  ('KWD', 'Kuwaiti Dinar', 'KWD ', 3),
  ('BHD', 'Bahraini Dinar', 'BHD ', 3),
  ('BTC', 'Bitcoin', '\u20BF', 8),
];

/// The 13 codes ISO 4217 publishes without a minor unit: precious metals,
/// units of account, the testing code and the no-currency code. No amount can
/// be written in them, so they are not currencies here.
const _excludedCodes = [
  'XAG',
  'XAU',
  'XBA',
  'XBB',
  'XBC',
  'XBD',
  'XDR',
  'XPD',
  'XPT',
  'XSU',
  'XTS',
  'XUA',
  'XXX',
];

/// The codes currencyapi.com lists on its Currency List page, read on
/// 2026-11-13. https://currencyapi.com/docs/currency-list
const _pricedByCurrencyApi = {
  'AED',
  'AFN',
  'ALL',
  'AMD',
  'AOA',
  'ARS',
  'AUD',
  'AWG',
  'AZN',
  'BAM',
  'BBD',
  'BDT',
  'BHD',
  'BIF',
  'BMD',
  'BND',
  'BOB',
  'BRL',
  'BSD',
  'BTC',
  'BTN',
  'BWP',
  'BYN',
  'BZD',
  'CAD',
  'CDF',
  'CHF',
  'CLF',
  'CLP',
  'CNY',
  'COP',
  'CRC',
  'CUP',
  'CVE',
  'CZK',
  'DJF',
  'DKK',
  'DOP',
  'DZD',
  'EGP',
  'ERN',
  'ETB',
  'EUR',
  'FJD',
  'FKP',
  'GBP',
  'GEL',
  'GHS',
  'GIP',
  'GMD',
  'GNF',
  'GTQ',
  'GYD',
  'HKD',
  'HNL',
  'HTG',
  'HUF',
  'IDR',
  'ILS',
  'INR',
  'IQD',
  'IRR',
  'ISK',
  'JMD',
  'JOD',
  'JPY',
  'KES',
  'KGS',
  'KHR',
  'KMF',
  'KPW',
  'KRW',
  'KWD',
  'KYD',
  'KZT',
  'LAK',
  'LBP',
  'LKR',
  'LRD',
  'LSL',
  'LYD',
  'MAD',
  'MDL',
  'MGA',
  'MKD',
  'MMK',
  'MNT',
  'MOP',
  'MRU',
  'MUR',
  'MVR',
  'MWK',
  'MXN',
  'MYR',
  'MZN',
  'NAD',
  'NGN',
  'NIO',
  'NOK',
  'NPR',
  'NZD',
  'OMR',
  'PAB',
  'PEN',
  'PGK',
  'PHP',
  'PKR',
  'PLN',
  'PYG',
  'QAR',
  'RON',
  'RSD',
  'RUB',
  'RWF',
  'SAR',
  'SBD',
  'SCR',
  'SDG',
  'SEK',
  'SGD',
  'SHP',
  'SLE',
  'SOS',
  'SRD',
  'STN',
  'SVC',
  'SYP',
  'SZL',
  'THB',
  'TJS',
  'TMT',
  'TND',
  'TOP',
  'TRY',
  'TTD',
  'TWD',
  'TZS',
  'UAH',
  'UGX',
  'USD',
  'UYU',
  'UZS',
  'VES',
  'VND',
  'VUV',
  'WST',
  'XAF',
  'XCD',
  'XCG',
  'XOF',
  'XPF',
  'YER',
  'ZAR',
  'ZMW',
  'ZWG',
};

/// The currencies currencyapi.com does not price, in code order. They work as
/// a base currency; a cross-currency write needs a manual rate.
const _unpricedByCurrencyApi = [
  'BOV',
  'CHE',
  'CHW',
  'COU',
  'MXV',
  'SSP',
  'USN',
  'UYI',
  'UYW',
  'VED',
  'XAD',
];
