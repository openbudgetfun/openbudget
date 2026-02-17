import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/logging/log_relay_service.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  group('LogRelayService', () {
    late Client client;
    late LogRelayService service;

    setUp(() {
      client = Client('http://localhost:8080/');
      service = LogRelayService(client: client);
    });

    tearDown(() {
      service.dispose();
    });

    test('can add entries without crashing', () {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        level: 'INFO',
        source: 'flutter:test',
        message: 'Test message',
        loggerName: 'TestLogger',
      );

      // Should not throw even if server is unreachable.
      expect(() => service.add(entry), returnsNormally);
    });

    test('flush does not throw when buffer is empty', () {
      expect(() => service.flush(), returnsNormally);
    });

    test('dispose clears the buffer', () {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        level: 'INFO',
        source: 'flutter:test',
        message: 'Test message',
        loggerName: 'TestLogger',
      );

      service
        ..add(entry)
        ..dispose();

      // After dispose, flush should be a no-op.
      expect(() => service.flush(), returnsNormally);
    });
  });
}
