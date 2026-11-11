import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart' hide Protocol;
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given PlaidEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late Session rawSession;

    setUp(() {
      authedSession = createAuthenticatedSession(sessionBuilder);
      rawSession = sessionBuilder.build();
    });

    Future<Entity> createEntity([String name = 'Plaid Entity']) =>
        endpoints.entity.create(
          authedSession,
          name,
          EntityKind.individual,
          'GB',
          'GBP',
          'Europe/London',
        );

    test(
      'when exchanging a blank public token then throws ValidationException',
      () async {
        final entity = await createEntity();

        await expectLater(
          endpoints.plaid.exchangePublicToken(authedSession, entity.id!, '   '),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'when syncing unknown connection then throws NotFoundException',
      () async {
        await createEntity();

        await expectLater(
          endpoints.plaid.syncConnection(
            authedSession,
            UuidValue.fromString('20000000-0000-4000-a000-000000000001'),
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when removing an unknown connection then throws NotFoundException',
      () async {
        await createEntity();

        await expectLater(
          endpoints.plaid.removeConnection(
            authedSession,
            UuidValue.fromString('20000000-0000-4000-a000-000000000002'),
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when syncing another owner connection then it is not found',
      () async {
        final entity = await createEntity();

        final connection = await PlaidConnection.db.insertRow(
          rawSession,
          PlaidConnection(
            entityId: entity.id!,
            plaidItemId: 'item-port-test-1',
            accessTokenCiphertext: 'ciphertext',
            accessTokenNonce: 'nonce',
          ),
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);
        await expectLater(
          endpoints.plaid.syncConnection(otherSession, connection.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.plaid.removeConnection(otherSession, connection.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      "when creating a link token for another user's entity then it is not found",
      () async {
        final entity = await createEntity('Owner Entity');
        final otherSession = createAuthenticatedSession(sessionBuilder);

        await expectLater(
          endpoints.plaid.createLinkToken(otherSession, entity.id!),
          throwsA(isA<ForbiddenException>()),
        );
      },
    );

    test('when listing connections then only the entity rows return', () async {
      final entity = await createEntity();
      final other = await createEntity('Other');
      final mine = await PlaidConnection.db.insertRow(
        rawSession,
        PlaidConnection(
          entityId: entity.id!,
          plaidItemId: 'item-port-list-1',
          accessTokenCiphertext: 'ciphertext',
          accessTokenNonce: 'nonce',
        ),
      );
      await PlaidConnection.db.insertRow(
        rawSession,
        PlaidConnection(
          entityId: other.id!,
          plaidItemId: 'item-port-list-2',
          accessTokenCiphertext: 'ciphertext',
          accessTokenNonce: 'nonce',
        ),
      );

      final rows = await endpoints.plaid.listConnections(
        authedSession,
        entity.id!,
      );
      expect(rows, hasLength(1));
      expect(rows.single.id, mine.id);
      expect(rows.single.plaidItemId, 'item-port-list-1');
    });

    test(
      'when a connection payload lacks the sealed fields then it still decodes',
      () async {
        final connection = await PlaidConnection.db.insertRow(
          rawSession,
          PlaidConnection(
            entityId: (await createEntity()).id!,
            plaidItemId: 'item-port-secrecy-1',
            accessTokenCiphertext: 'not-a-real-ciphertext',
            accessTokenNonce: 'not-a-real-nonce',
            transactionsCursor: 'cursor-1',
          ),
        );

        // The stored row keeps the sealed pair and the cursor.
        expect(connection.accessTokenCiphertext, 'not-a-real-ciphertext');
        expect(connection.accessTokenNonce, 'not-a-real-nonce');

        // A payload without the server-only fields is a valid connection:
        // the generated client can never produce or carry them.
        final protocol = Protocol();
        final withoutSecrets = <String, Object?>{
          ...connection.toJson()
            ..remove('accessTokenCiphertext')
            ..remove('accessTokenNonce')
            ..remove('transactionsCursor'),
        };
        final decoded = protocol.decode<PlaidConnection>(
          jsonEncode(withoutSecrets),
        );
        expect(decoded.plaidItemId, 'item-port-secrecy-1');
        expect(decoded.accessTokenCiphertext, isNull);
        expect(decoded.accessTokenNonce, isNull);
        expect(decoded.transactionsCursor, isNull);
      },
    );
  });
}
