import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('defaultTimeZone', () {
    test('returns the primary zone for the shipped countries', () {
      expect(defaultTimeZone('GB'), 'Europe/London');
      expect(defaultTimeZone('US'), 'America/New_York');
      expect(defaultTimeZone('NG'), 'Africa/Lagos');
      expect(defaultTimeZone('DE'), 'Europe/Berlin');
    });

    test('is case-insensitive on the country code', () {
      expect(defaultTimeZone('gb'), 'Europe/London');
    });

    test('defaults every known country to its own zone', () {
      expect(defaultTimeZone('FR'), 'Europe/Paris');
      expect(defaultTimeZone('BR'), 'America/Sao_Paulo');
      expect(defaultTimeZone('IN'), 'Asia/Kolkata');
    });

    test('falls back to UTC for unknown codes', () {
      expect(defaultTimeZone('ZZ'), 'UTC');
      expect(defaultTimeZone(''), 'UTC');
    });
  });

  group('timeZoneChoices', () {
    test('offers the hand-kept US zones with the default first', () {
      expect(timeZoneChoices('US'), [
        'America/New_York',
        'America/Chicago',
        'America/Denver',
        'America/Phoenix',
        'America/Los_Angeles',
        'America/Anchorage',
        'Pacific/Honolulu',
      ]);
    });

    test('single-zone countries list one choice', () {
      expect(timeZoneChoices('GB'), ['Europe/London']);
      expect(timeZoneChoices('NG'), ['Africa/Lagos']);
    });

    test('Germany hides its Büsingen enclave zone', () {
      expect(timeZoneChoices('DE'), ['Europe/Berlin']);
    });

    test('multi-zone countries put the hand-kept default first', () {
      expect(timeZoneChoices('RU').first, 'Europe/Moscow');
      expect(timeZoneChoices('CA').first, 'America/Toronto');
    });

    test('unknown codes get the single UTC fallback', () {
      expect(timeZoneChoices('XX'), ['UTC']);
    });
  });
}
