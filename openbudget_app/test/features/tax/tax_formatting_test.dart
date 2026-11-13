import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('formatRateBasisPoints', () {
    test('writes whole rates without decimals', () {
      expect(formatRateBasisPoints(2000), '20');
      expect(formatRateBasisPoints(4500), '45');
    });

    test('keeps fractional rates', () {
      expect(formatRateBasisPoints(850), '8.50');
      expect(formatRateBasisPoints(333), '3.33');
    });
  });

  group('formatRatePerMillion', () {
    test("writes Quebec's QST exactly, never through a double", () {
      expect(formatRatePerMillion(99750), '9.975');
    });

    test('drops trailing zeros and keeps whole rates whole', () {
      expect(formatRatePerMillion(160000), '16');
      expect(formatRatePerMillion(175000), '17.5');
      expect(formatRatePerMillion(50000), '5');
    });

    test('keeps every digit down to a millionth of a percent point', () {
      expect(formatRatePerMillion(5000), '0.5');
      expect(formatRatePerMillion(1), '0.0001');
      expect(formatRatePerMillion(10001), '1.0001');
      expect(formatRatePerMillion(0), '0');
    });

    test('writes a negative rate with its sign', () {
      expect(formatRatePerMillion(-25000), '-2.5');
    });

    test("uses the reader's decimal separator", () {
      expect(formatRatePerMillion(99750, decimalSeparator: ','), '9,975');
    });
  });

  group('ratesInForce', () {
    IndirectTaxRate rate(DateTime from, DateTime? to) => IndirectTaxRate(
      label: 'standard',
      ratePerMillion: 160000,
      from: from,
      to: to,
      source: 0,
    );

    test('includes the first day and excludes the day the rate ends', () {
      final rates = [rate(DateTime.utc(2021), DateTime.utc(2023, 7))];

      expect(ratesInForce(rates, DateTime.utc(2021)), hasLength(1));
      expect(ratesInForce(rates, DateTime.utc(2023, 6, 30)), hasLength(1));
      expect(ratesInForce(rates, DateTime.utc(2023, 7)), isEmpty);
      expect(ratesInForce(rates, DateTime.utc(2020, 12, 31)), isEmpty);
    });

    test('keeps a rate with no end date in force', () {
      final rates = [rate(DateTime.utc(2021), null)];

      expect(ratesInForce(rates, DateTime.utc(2040)), hasLength(1));
    });

    test('compares by calendar day, ignoring the time of day', () {
      final rates = [rate(DateTime.utc(2021), DateTime.utc(2023, 7))];

      expect(
        ratesInForce(rates, DateTime.utc(2023, 6, 30, 23, 59)),
        hasLength(1),
      );
    });
  });

  group('webLink', () {
    test('accepts http and https addresses', () {
      expect(
        webLink('https://www.kra.go.ke'),
        Uri.parse('https://www.kra.go.ke'),
      );
      expect(webLink('http://localhost:8082/x'), isNotNull);
    });

    test('rejects anything else', () {
      expect(webLink('javascript:alert(1)'), isNull);
      expect(webLink('mailto:someone@example.com'), isNull);
      expect(webLink('www.kra.go.ke'), isNull);
      expect(webLink(''), isNull);
    });
  });

  group('currentTaxYearStart', () {
    test('uses the UK year that contains 6 April', () {
      expect(
        currentTaxYearStart(TaxJurisdiction.gb, now: DateTime.utc(2026, 4, 5)),
        2025,
      );
      expect(
        currentTaxYearStart(TaxJurisdiction.gb, now: DateTime.utc(2026, 4, 6)),
        2026,
      );
    });

    test('uses the calendar year for US, Nigeria, and Germany', () {
      expect(
        currentTaxYearStart(TaxJurisdiction.us, now: DateTime.utc(2026, 2)),
        2026,
      );
      expect(
        currentTaxYearStart(TaxJurisdiction.ng, now: DateTime.utc(2026, 2)),
        2026,
      );
      expect(
        currentTaxYearStart(TaxJurisdiction.de, now: DateTime.utc(2026, 2)),
        2026,
      );
    });
  });

  group('parseTaxProfileJson', () {
    test('returns the typed profile', () {
      final profile = parseTaxProfileJson(
        '{"jurisdiction":"US","entityKind":"individual",'
        '"salesTaxRegistered":true,"filingStatus":"headOfHousehold"}',
      );

      expect(profile, isA<UsTaxProfile>());
      expect(profile?.salesTaxRegistered, isTrue);
      expect(
        (profile! as UsTaxProfile).filingStatus,
        UsFilingStatus.headOfHousehold,
      );
    });

    test('returns null for malformed payloads', () {
      expect(parseTaxProfileJson('not json'), isNull);
      expect(parseTaxProfileJson('[]'), isNull);
      expect(
        parseTaxProfileJson('{"jurisdiction":"ZZ","entityKind":"individual"}'),
        isNull,
      );
    });
  });

  group('taxErrorMessage', () {
    test('shows the server validation text', () {
      expect(
        taxErrorMessage(ValidationException(message: 'bad rent'), 'fallback'),
        'bad rent',
      );
    });

    test('falls back for other server errors', () {
      expect(
        taxErrorMessage(NotFoundException(message: 'missing'), 'fallback'),
        'fallback',
      );
    });

    test('falls back for local errors', () {
      expect(
        taxErrorMessage(Exception('socket closed'), 'fallback'),
        'fallback',
      );
    });
  });
  group('shortSourceLabel', () {
    SourceInfo source(String title, String url) => SourceInfo(
      title: title,
      url: url,
      grade: SourceGrade.secondary,
      retrievedOn: DateTime.utc(2026, 11, 13),
    );

    test('is the website, without www', () {
      expect(
        shortSourceLabel(
          source(
            'afriref: Kenya — VAT standard rate',
            'https://afriref.dev/ke',
          ),
        ),
        'afriref.dev',
      );
      expect(
        shortSourceLabel(source('HMRC', 'https://www.gov.uk/vat-rates')),
        'gov.uk',
      );
    });

    test('falls back to the title before the first dash or colon', () {
      expect(
        shortSourceLabel(source('Tax Act — s. 4: rates', 'not a url')),
        'Tax Act',
      );
      expect(
        shortSourceLabel(source('Tax Act: rates — s. 4', 'not a url')),
        'Tax Act',
      );
      expect(
        shortSourceLabel(source('Plain title', 'not a url')),
        'Plain title',
      );
    });
  });
}
