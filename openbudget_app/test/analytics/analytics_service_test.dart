import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/analytics/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService();
    });

    test('screen is a no-op in debug mode', () async {
      // Should not throw even though PostHog is not configured.
      await expectLater(service.screen('home'), completes);
    });

    test('capture is a no-op in debug mode', () async {
      await expectLater(
        service.capture('test_event', properties: {'key': 'value'}),
        completes,
      );
    });

    test('identify is a no-op in debug mode', () async {
      await expectLater(service.identify('user-123'), completes);
    });

    test('reset is a no-op in debug mode', () async {
      await expectLater(service.reset(), completes);
    });

    test('init is a no-op in debug mode', () async {
      await expectLater(service.init(), completes);
    });
  });
}
