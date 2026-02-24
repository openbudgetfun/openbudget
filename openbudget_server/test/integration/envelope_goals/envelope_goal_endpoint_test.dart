import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EnvelopeGoalEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test('when listing goals for owned envelopes then returns goals', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Goal Budget',
        'USD',
      );
      final category = await endpoints.category.create(
        authedSession,
        'Needs',
        budget.id!,
        0,
      );
      final groceries = await endpoints.envelope.create(
        authedSession,
        'Groceries',
        category.id!,
        0,
        'USD',
      );
      final rent = await endpoints.envelope.create(
        authedSession,
        'Rent',
        category.id!,
        0,
        'USD',
      );

      await endpoints.envelopeGoal.upsert(
        authedSession,
        groceries.id!,
        'monthly_funding',
        50000,
        monthlyFundingCents: 50000,
      );
      await endpoints.envelopeGoal.upsert(
        authedSession,
        rent.id!,
        'target_by_date',
        250000,
        targetDate: DateTime(2026, 12),
      );

      final goals = await endpoints.envelopeGoal.listForEnvelopes(
        authedSession,
        [groceries.id!, rent.id!],
      );

      expect(goals, hasLength(2));
      final envelopeIds = goals.map((goal) => goal.envelopeId).toSet();
      expect(envelopeIds, equals({groceries.id!, rent.id!}));
    });

    test(
      'when listing goals with no envelope ids then returns empty',
      () async {
        final goals = await endpoints.envelopeGoal.listForEnvelopes(
          authedSession,
          const [],
        );

        expect(goals, isEmpty);
      },
    );

    test(
      "when listing goals with another user's envelope then throws not found",
      () async {
        final privateOwner = createAuthenticatedSession(sessionBuilder);
        final privateBudget = await endpoints.budget.create(
          privateOwner,
          'Private Budget',
          'USD',
        );
        final privateCategory = await endpoints.category.create(
          privateOwner,
          'Private Category',
          privateBudget.id!,
          0,
        );
        final privateEnvelope = await endpoints.envelope.create(
          privateOwner,
          'Private Envelope',
          privateCategory.id!,
          0,
          'USD',
        );
        await endpoints.envelopeGoal.upsert(
          privateOwner,
          privateEnvelope.id!,
          'monthly_funding',
          10000,
          monthlyFundingCents: 10000,
        );

        expect(
          () => endpoints.envelopeGoal.listForEnvelopes(authedSession, [
            privateEnvelope.id!,
          ]),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when listing mixed owned and foreign envelopes then throws and leaks nothing',
      () async {
        final ownBudget = await endpoints.budget.create(
          authedSession,
          'My Budget',
          'USD',
        );
        final ownCategory = await endpoints.category.create(
          authedSession,
          'Home',
          ownBudget.id!,
          0,
        );
        final ownEnvelope = await endpoints.envelope.create(
          authedSession,
          'Utilities',
          ownCategory.id!,
          0,
          'USD',
        );
        await endpoints.envelopeGoal.upsert(
          authedSession,
          ownEnvelope.id!,
          'monthly_funding',
          6000,
          monthlyFundingCents: 6000,
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);
        final foreignBudget = await endpoints.budget.create(
          otherSession,
          'Foreign Budget',
          'USD',
        );
        final foreignCategory = await endpoints.category.create(
          otherSession,
          'Foreign Category',
          foreignBudget.id!,
          0,
        );
        final foreignEnvelope = await endpoints.envelope.create(
          otherSession,
          'Foreign Envelope',
          foreignCategory.id!,
          0,
          'USD',
        );
        await endpoints.envelopeGoal.upsert(
          otherSession,
          foreignEnvelope.id!,
          'monthly_funding',
          7500,
          monthlyFundingCents: 7500,
        );

        expect(
          () => endpoints.envelopeGoal.listForEnvelopes(authedSession, [
            ownEnvelope.id!,
            foreignEnvelope.id!,
          ]),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
