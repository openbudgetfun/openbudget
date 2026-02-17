import 'package:logging/logging.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('ObLogger', () {
    test('init sets source and log level', () {
      ObLogger.init(source: 'test-source', minLevel: Level.WARNING);

      expect(ObLogger.source, 'test-source');
      expect(Logger.root.level, Level.WARNING);
    });

    test('logs messages at correct levels', () {
      ObLogger.init(source: 'test');

      final log = ObLogger('TestLogger');
      final records = <LogRecord>[];
      Logger.root.onRecord.listen(records.add);

      log
        ..info('info message')
        ..warning('warning message')
        ..severe('severe message')
        ..fine('fine message')
        ..config('config message');

      expect(records, hasLength(5));
      expect(records[0].level, Level.INFO);
      expect(records[0].message, 'info message');
      expect(records[1].level, Level.WARNING);
      expect(records[2].level, Level.SEVERE);
      expect(records[3].level, Level.FINE);
      expect(records[4].level, Level.CONFIG);
    });

    test('passes error and stackTrace to severe', () {
      ObLogger.init(source: 'test');

      final log = ObLogger('TestLogger');
      final records = <LogRecord>[];
      Logger.root.onRecord.listen(records.add);

      final error = Exception('test error');
      final stackTrace = StackTrace.current;
      log.severe('failed', error, stackTrace);

      expect(records, hasLength(1));
      expect(records.first.error, error);
      expect(records.first.stackTrace, stackTrace);
    });

    tearDown(Logger.root.clearListeners);
  });
}
