import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  CountryInfo country(String code) => Countries.byCode(code)!;

  group('displayName', () {
    test('uses hand-kept names where IANA is terse', () {
      expect(country('GB').displayName, 'United Kingdom');
      expect(country('KR').displayName, 'South Korea');
      expect(country('CD').displayName, 'Democratic Republic of the Congo');
      expect(country('VG').displayName, 'British Virgin Islands');
    });

    test('spells out St and ampersands', () {
      expect(country('LC').displayName, 'Saint Lucia');
      expect(country('KN').displayName, 'Saint Kitts and Nevis');
      expect(country('TT').displayName, 'Trinidad and Tobago');
    });

    test('leaves ordinary names alone', () {
      for (final code in ['US', 'NG', 'DE', 'KE', 'CI']) {
        expect(country(code).displayName, country(code).name);
      }
    });

    test('no display name keeps an IANA abbreviation', () {
      for (final c in Countries.all) {
        expect(c.displayName, isNot(contains(' & ')), reason: c.code);
        expect(c.displayName, isNot(startsWith('St ')), reason: c.code);
        expect(c.displayName, isNot(contains(' Rep.')), reason: c.code);
      }
    });

    test('every override names a real country', () {
      for (final code in [
        'AS', 'BL', 'BQ', 'CD', 'CF', 'CG', 'GB', 'KP', 'KR', 'MF', 'MM', //
        'PM', 'ST', 'SX', 'SZ', 'TC', 'TF', 'TL', 'UM', 'VC', 'VG', 'VI',
        'WS',
      ]) {
        expect(Countries.byCode(code), isNotNull, reason: code);
      }
    });
  });

  group('searchAliases', () {
    test('knows what people call the big ones', () {
      expect(country('GB').searchAliases, contains('UK'));
      expect(country('US').searchAliases, contains('USA'));
      expect(country('CI').searchAliases, contains('Ivory Coast'));
    });

    test('is empty when there is nothing to add', () {
      expect(country('KE').searchAliases, isEmpty);
    });
  });
}
