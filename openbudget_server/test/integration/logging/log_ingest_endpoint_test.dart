import 'dart:convert';

import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/logging/log_ingest_endpoint.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given LogIngestEndpoint', (sessionBuilder, endpoints) {
    test('when user is unauthenticated then ingest is rejected', () async {
      expect(
        () => endpoints.logIngest.ingest(sessionBuilder, '[]'),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test(
      'when payload exceeds max size then throws ValidationException',
      () async {
        final authedSession = createAuthenticatedSession(sessionBuilder);
        final oversizedPayload = 'x' * (LogIngestEndpoint.maxPayloadBytes + 1);

        expect(
          () => endpoints.logIngest.ingest(authedSession, oversizedPayload),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'when authenticated and payload is valid then ingest succeeds',
      () async {
        final authedSession = createAuthenticatedSession(sessionBuilder);
        final payload = jsonEncode([
          {
            'timestamp': DateTime.utc(2026).toIso8601String(),
            'level': 'INFO',
            'source': 'flutter:test',
            'message': 'hello from test',
            'loggerName': 'log_ingest_endpoint_test',
          },
        ]);

        await endpoints.logIngest.ingest(authedSession, payload);
      },
    );
  }, applyMigrations: false);
}
