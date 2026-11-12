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

    test('falls back to UTC for other countries', () {
      expect(defaultTimeZone('FR'), 'UTC');
      expect(defaultTimeZone(''), 'UTC');
    });
  });

  group('timeZoneChoices', () {
    test('offers the US zones with the default first', () {
      final choices = timeZoneChoices('US');
      expect(choices.first, 'America/New_York');
      expect(choices, contains('America/Los_Angeles'));
      expect(choices.length, greaterThan(1));
    });

    test('single-zone countries list one choice', () {
      expect(timeZoneChoices('GB'), ['Europe/London']);
      expect(timeZoneChoices('XX'), ['UTC']);
    });
  });
}
