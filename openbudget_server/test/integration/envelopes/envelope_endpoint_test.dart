import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EnvelopeEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test('when creating an envelope then returns created envelope', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Food',
        budget.id!,
        0,
      );

      final envelope = await endpoints.envelope.create(
        authedSession,
        'Groceries',
        category.id!,
        50000,
        'USD',
      );
      expect(envelope.name, 'Groceries');
      expect(envelope.budgetedAmountCents, 50000);
      expect(envelope.spentAmountCents, 0);
      expect(envelope.currencyCode, 'USD');
    });

    test('when listing envelopes then returns all for category', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Food',
        budget.id!,
        0,
      );

      await endpoints.envelope.create(
        authedSession,
        'Groceries',
        category.id!,
        50000,
        'USD',
      );
      await endpoints.envelope.create(
        authedSession,
        'Dining Out',
        category.id!,
        20000,
        'USD',
      );

      final envelopes = await endpoints.envelope.list(
        authedSession,
        category.id!,
      );
      expect(envelopes, hasLength(2));
    });

    test('when updating an envelope then returns updated envelope', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Food',
        budget.id!,
        0,
      );
      final envelope = await endpoints.envelope.create(
        authedSession,
        'Groceries',
        category.id!,
        50000,
        'USD',
      );

      final updated = await endpoints.envelope.update(
        authedSession,
        envelope.id!,
        budgetedAmountCents: 60000,
      );
      expect(updated.budgetedAmountCents, 60000);
    });

    test('when deleting an envelope then it is removed', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Food',
        budget.id!,
        0,
      );
      final envelope = await endpoints.envelope.create(
        authedSession,
        'Delete Me',
        category.id!,
        50000,
        'USD',
      );

      await endpoints.envelope.delete(authedSession, envelope.id!);

      expect(
        () => endpoints.envelope.get(authedSession, envelope.id!),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      "when accessing envelope in another user's budget then throws",
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Private Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Private Category',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Private Envelope',
          category.id!,
          50000,
          'USD',
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);

        expect(
          () => endpoints.envelope.get(otherSession, envelope.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
