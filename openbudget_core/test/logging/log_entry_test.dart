import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('LogEntry', () {
    test('serializes to JSON and back', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'INFO',
        source: 'server',
        message: 'Created budget id=abc',
        loggerName: 'BudgetService',
      );

      final json = entry.toJson();
      final restored = LogEntry.fromJson(json);

      expect(restored, entry);
    });

    test('includes error and stackTrace when present', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'SEVERE',
        source: 'server',
        message: 'Failed to create budget',
        loggerName: 'BudgetService',
        error: 'DatabaseException: connection refused',
        stackTrace: '#0 main (test.dart:1)',
      );

      final json = jsonDecode(jsonEncode(entry.toJson()));
      final restored = LogEntry.fromJson(json as Map<String, dynamic>);

      expect(restored.error, 'DatabaseException: connection refused');
      expect(restored.stackTrace, '#0 main (test.dart:1)');
    });

    test('copyWith works', () {
      final entry = LogEntry(
        timestamp: DateTime.utc(2026, 2, 17, 10, 30),
        level: 'INFO',
        source: 'server',
        message: 'original',
        loggerName: 'Test',
      );

      final updated = entry.copyWith(message: 'updated');

      expect(updated.message, 'updated');
      expect(updated.level, 'INFO');
    });
  });
}
