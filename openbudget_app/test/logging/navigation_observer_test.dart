import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:openbudget_app/src/logging/navigation_observer.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('LoggingNavigationObserver', () {
    late LoggingNavigationObserver observer;
    late List<LogRecord> records;

    setUp(() {
      ObLogger.init(source: 'test');
      observer = LoggingNavigationObserver();
      records = [];
      Logger.root.onRecord.listen(records.add);
    });

    tearDown(Logger.root.clearListeners);

    test('logs push events', () {
      observer.didPush(
        MaterialPageRoute<void>(
          builder: (_) => const SizedBox(),
          settings: const RouteSettings(name: '/home'),
        ),
        null,
      );

      expect(records, hasLength(1));
      expect(records.first.message, contains('Push'));
      expect(records.first.message, contains('/home'));
    });

    test('logs pop events', () {
      observer.didPop(
        MaterialPageRoute<void>(
          builder: (_) => const SizedBox(),
          settings: const RouteSettings(name: '/settings'),
        ),
        null,
      );

      expect(records, hasLength(1));
      expect(records.first.message, contains('Pop'));
      expect(records.first.message, contains('/settings'));
    });
  });
}
