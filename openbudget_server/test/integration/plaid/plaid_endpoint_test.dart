import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given PlaidEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when exchanging a blank public token then throws ValidationException',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Plaid Budget',
          'USD',
        );

        await expectLater(
          endpoints.plaid.exchangePublicToken(authedSession, budget.id!, '   '),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'when syncing unknown connection then throws NotFoundException',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Sync Budget',
          'USD',
        );

        await expectLater(
          endpoints.plaid.syncConnection(
            authedSession,
            budget.id!,
            UuidValue.fromString('20000000-0000-4000-a000-000000000001'),
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when syncing a connection with mismatched budget then throws NotFoundException',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Budget',
          'USD',
        );
        final secondaryBudget = await endpoints.budget.create(
          authedSession,
          'Secondary Budget',
          'USD',
        );

        final session = authedSession.build();
        try {
          final connection = await PlaidConnection.db.insertRow(
            session,
            PlaidConnection(
              budgetId: primaryBudget.id!,
              plaidItemId: 'item-test-1',
              accessToken: 'access-sandbox-token',
            ),
          );

          await expectLater(
            endpoints.plaid.syncConnection(
              authedSession,
              secondaryBudget.id!,
              connection.id!,
            ),
            throwsA(isA<NotFoundException>()),
          );
        } finally {
          await session.close();
        }
      },
    );

    test(
      "when creating link token for another user's budget then throws NotFoundException",
      () async {
        final ownerBudget = await endpoints.budget.create(
          authedSession,
          'Owner Budget',
          'USD',
        );
        final otherUserSession = createAuthenticatedSession(sessionBuilder);

        await expectLater(
          endpoints.plaid.createLinkToken(otherUserSession, ownerBudget.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
