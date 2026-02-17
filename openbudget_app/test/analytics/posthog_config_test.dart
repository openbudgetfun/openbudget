import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/analytics/posthog_config.dart';

void main() {
  group('PosthogConfig', () {
    test('apiKey is empty by default (no dart-define)', () {
      expect(PosthogConfig.apiKey, isEmpty);
    });

    test('host has a default value', () {
      expect(PosthogConfig.host, 'https://us.i.posthog.com');
    });

    test('isEnabled is false in debug mode', () {
      // In tests, kDebugMode is true, so isEnabled should be false.
      expect(PosthogConfig.isEnabled, isFalse);
    });
  });
}
