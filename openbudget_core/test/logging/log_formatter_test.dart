import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('LogFormatter', () {
    test('formats a basic log entry', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'INFO',
        source: 'server',
        message: 'Created budget id=abc',
        loggerName: 'BudgetService',
      );

      final result = LogFormatter.format(entry);

      expect(result, contains('[2026-02-17T10:30:00.000Z]'));
      expect(result, contains('[INFO   ]'));
      expect(result, contains('[server]'));
      expect(result, contains('[BudgetService]'));
      expect(result, contains('Created budget id=abc'));
    });

    test('formats entry with error', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'SEVERE',
        source: 'server',
        message: 'Failed',
        loggerName: 'Test',
        error: 'SomeException',
      );

      final result = LogFormatter.format(entry);

      expect(result, contains('[SEVERE ]'));
      expect(result, contains('error: SomeException'));
    });

    test('formats entry with error and stack trace', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'SEVERE',
        source: 'server',
        message: 'Failed',
        loggerName: 'Test',
        error: 'SomeException',
        stackTrace: '#0 main (test.dart:1)',
      );

      final result = LogFormatter.format(entry);

      expect(result, contains('error: SomeException'));
      expect(result, contains('stackTrace: #0 main (test.dart:1)'));
    });

    test('pads short level names', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'FINE',
        source: 'server',
        message: 'test',
        loggerName: 'Test',
      );

      final result = LogFormatter.format(entry);

      expect(result, contains('[FINE   ]'));
    });
  });
}
