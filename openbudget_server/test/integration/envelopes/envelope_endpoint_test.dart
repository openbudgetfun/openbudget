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

    test('when reordering envelopes then sort order is updated', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Reorder Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Utilities',
        budget.id!,
        0,
      );

      final first = await endpoints.envelope.create(
        authedSession,
        'First',
        category.id!,
        1000,
        'USD',
      );
      final second = await endpoints.envelope.create(
        authedSession,
        'Second',
        category.id!,
        2000,
        'USD',
      );
      final third = await endpoints.envelope.create(
        authedSession,
        'Third',
        category.id!,
        3000,
        'USD',
      );

      final reordered = await endpoints.envelope.reorder(
        authedSession,
        category.id!,
        [third.id!.toString(), first.id!.toString(), second.id!.toString()],
      );
      expect(reordered.map((envelope) => envelope.name), [
        'Third',
        'First',
        'Second',
      ]);

      final listed = await endpoints.envelope.list(authedSession, category.id!);
      expect(listed.map((envelope) => envelope.name), [
        'Third',
        'First',
        'Second',
      ]);
    });

    test(
      'when reordering with envelope from another category then throws',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Mixed Category Budget',
          'USD',
        );
        final primaryCategory = await endpoints.category.create(
          authedSession,
          'Primary Category',
          budget.id!,
          0,
        );
        final otherCategory = await endpoints.category.create(
          authedSession,
          'Other Category',
          budget.id!,
          1,
        );

        final primaryA = await endpoints.envelope.create(
          authedSession,
          'Primary A',
          primaryCategory.id!,
          1000,
          'USD',
        );
        final primaryB = await endpoints.envelope.create(
          authedSession,
          'Primary B',
          primaryCategory.id!,
          2000,
          'USD',
        );
        final foreign = await endpoints.envelope.create(
          authedSession,
          'Foreign Envelope',
          otherCategory.id!,
          5000,
          'USD',
        );

        await expectLater(
          endpoints.envelope.reorder(authedSession, primaryCategory.id!, [
            primaryA.id!.toString(),
            foreign.id!.toString(),
            primaryB.id!.toString(),
          ]),
          throwsA(isA<NotFoundException>()),
        );

        final primaryListed = await endpoints.envelope.list(
          authedSession,
          primaryCategory.id!,
        );
        expect(primaryListed.map((envelope) => envelope.name), [
          'Primary A',
          'Primary B',
        ]);

        final foreignEnvelope = await endpoints.envelope.get(
          authedSession,
          foreign.id!,
        );
        expect(foreignEnvelope.sortOrder, 0);
      },
    );
  });
}
