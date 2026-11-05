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

  group('plain minor units', () {
    test('round-trips a field value', () {
      expect(minorToPlainText(120000, 2), '1200.00');
      expect(parsePlainMinor('1,200.00', 2), 120000);
      expect(parsePlainMinor(' 42.5 ', 2), 4250);
    });

    test('rejects values that are not a non-negative number', () {
      expect(parsePlainMinor('', 2), isNull);
      expect(parsePlainMinor('twelve', 2), isNull);
      expect(parsePlainMinor('-1', 2), isNull);
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
}
