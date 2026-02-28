import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given BudgetEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test('when creating a budget then returns created budget', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'My Budget',
        'USD',
      );
      expect(budget.name, 'My Budget');
      expect(budget.currencyCode, 'USD');
      expect(budget.id, isNotNull);
    });

    test('when listing budgets then returns only user budgets', () async {
      await endpoints.budget.create(authedSession, 'Budget 1', 'USD');
      await endpoints.budget.create(authedSession, 'Budget 2', 'EUR');

      final budgets = await endpoints.budget.list(authedSession);
      expect(budgets, hasLength(2));
    });

    test('when getting a budget by ID then returns the budget', () async {
      final created = await endpoints.budget.create(
        authedSession,
        'Get Me',
        'USD',
      );

      final fetched = await endpoints.budget.get(authedSession, created.id!);
      expect(fetched.name, 'Get Me');
      expect(fetched.id, created.id);
    });

    test('when updating a budget then returns updated budget', () async {
      final created = await endpoints.budget.create(
        authedSession,
        'Original',
        'USD',
      );

      final updated = await endpoints.budget.update(
        authedSession,
        created.id!,
        name: 'Updated',
      );
      expect(updated.name, 'Updated');
      expect(updated.currencyCode, 'USD');
      expect(updated.displayCurrencyCode, isNull);
    });

    test(
      'when setting and clearing display currency then value updates',
      () async {
        final created = await endpoints.budget.create(
          authedSession,
          'Display Test',
          'USD',
        );

        final withDisplayCurrency = await endpoints.budget.update(
          authedSession,
          created.id!,
          displayCurrencyCode: 'GBP',
        );
        expect(withDisplayCurrency.displayCurrencyCode, 'GBP');

        final cleared = await endpoints.budget.update(
          authedSession,
          created.id!,
          clearDisplayCurrencyCode: true,
        );
        expect(cleared.displayCurrencyCode, isNull);
      },
    );

    test('when deleting a budget then it is removed', () async {
      final created = await endpoints.budget.create(
        authedSession,
        'Delete Me',
        'USD',
      );

      await endpoints.budget.delete(authedSession, created.id!);

      expect(
        () => endpoints.budget.get(authedSession, created.id!),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      "when getting another user's budget then throws NotFoundException",
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Private',
          'USD',
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);

        expect(
          () => endpoints.budget.get(otherSession, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when listing budgets then does not include other user budgets',
      () async {
        await endpoints.budget.create(authedSession, 'User A Budget', 'USD');

        final otherSession = createAuthenticatedSession(sessionBuilder);
        await endpoints.budget.create(otherSession, 'User B Budget', 'EUR');

        final budgets = await endpoints.budget.list(authedSession);
        expect(budgets, hasLength(1));
        expect(budgets.first.name, 'User A Budget');
      },
    );
  });
}
