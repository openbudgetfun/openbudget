import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given TransactionRuleEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when creating and finding a matching rule then returns target envelope',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Rules Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Bills',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Internet',
          category.id!,
          0,
          'USD',
        );
        final payee = await endpoints.payee.create(
          authedSession,
          'ISP',
          budget.id!,
        );

        final rule = await endpoints.transactionRule.create(
          authedSession,
          budget.id!,
          payee.id!,
          envelope.id!,
        );

        expect(rule.budgetId, budget.id);
        expect(rule.payeeId, payee.id);
        expect(rule.targetEnvelopeId, envelope.id);

        final matchedEnvelopeId = await endpoints.transactionRule
            .findMatchingEnvelope(authedSession, budget.id!, payee.id!);

        expect(matchedEnvelopeId, envelope.id);
      },
    );

    test(
      'when creating rule with payee outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Rule Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Primary Category',
          primaryBudget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Primary Envelope',
          category.id!,
          0,
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Rule Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Payee',
          foreignBudget.id!,
        );

        await expectLater(
          endpoints.transactionRule.create(
            authedSession,
            primaryBudget.id!,
            foreignPayee.id!,
            envelope.id!,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final rules = await endpoints.transactionRule.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(rules, isEmpty);
      },
    );

    test(
      'when creating rule with envelope outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Envelope Rule Budget',
          'USD',
        );
        final primaryPayee = await endpoints.payee.create(
          authedSession,
          'Primary Payee',
          primaryBudget.id!,
        );

        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Envelope Rule Budget',
          'USD',
        );
        final foreignCategory = await endpoints.category.create(
          authedSession,
          'Foreign Category',
          foreignBudget.id!,
          0,
        );
        final foreignEnvelope = await endpoints.envelope.create(
          authedSession,
          'Foreign Envelope',
          foreignCategory.id!,
          0,
          'USD',
        );

        await expectLater(
          endpoints.transactionRule.create(
            authedSession,
            primaryBudget.id!,
            primaryPayee.id!,
            foreignEnvelope.id!,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final rules = await endpoints.transactionRule.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(rules, isEmpty);
      },
    );

    test(
      'when updating rule with envelope outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Update Rule Budget',
          'USD',
        );
        final primaryCategory = await endpoints.category.create(
          authedSession,
          'Primary Update Category',
          primaryBudget.id!,
          0,
        );
        final primaryEnvelope = await endpoints.envelope.create(
          authedSession,
          'Primary Update Envelope',
          primaryCategory.id!,
          0,
          'USD',
        );
        final payee = await endpoints.payee.create(
          authedSession,
          'Primary Update Payee',
          primaryBudget.id!,
        );

        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Update Rule Budget',
          'USD',
        );
        final foreignCategory = await endpoints.category.create(
          authedSession,
          'Foreign Update Category',
          foreignBudget.id!,
          0,
        );
        final foreignEnvelope = await endpoints.envelope.create(
          authedSession,
          'Foreign Update Envelope',
          foreignCategory.id!,
          0,
          'USD',
        );

        final rule = await endpoints.transactionRule.create(
          authedSession,
          primaryBudget.id!,
          payee.id!,
          primaryEnvelope.id!,
        );

        await expectLater(
          endpoints.transactionRule.update(
            authedSession,
            rule.id!,
            targetEnvelopeId: foreignEnvelope.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.transactionRule.get(
          authedSession,
          rule.id!,
        );
        expect(unchanged.targetEnvelopeId, primaryEnvelope.id);
      },
    );

    test(
      'when finding matching envelope with payee outside budget then throws',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Find Rule Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Find Rule Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Find Payee',
          foreignBudget.id!,
        );

        await expectLater(
          endpoints.transactionRule.findMatchingEnvelope(
            authedSession,
            primaryBudget.id!,
            foreignPayee.id!,
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
