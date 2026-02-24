import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given TransactionEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when creating a transaction then returns created transaction',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Test Budget',
          'USD',
        );

        final transaction = await endpoints.transaction.create(
          authedSession,
          'Coffee',
          -500,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );
        expect(transaction.description, 'Coffee');
        expect(transaction.amountCents, -500);
        expect(transaction.currencyCode, 'USD');
        expect(transaction.budgetId, budget.id);
        expect(transaction.envelopeId, isNull);
      },
    );

    test(
      'when creating a transaction with envelope then links correctly',
      () async {
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

        final transaction = await endpoints.transaction.create(
          authedSession,
          'Supermarket',
          -3500,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
          envelopeId: envelope.id,
        );
        expect(transaction.envelopeId, envelope.id);
      },
    );

    test(
      'when creating transfer then creates linked in/outflow pair',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Transfer Budget',
          'USD',
        );
        final fromAccount = await endpoints.account.create(
          authedSession,
          'Checking',
          'checking',
          500000,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 0,
        );
        final toAccount = await endpoints.account.create(
          authedSession,
          'Savings',
          'savings',
          100000,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 1,
        );

        final created = await endpoints.transaction.transfer(
          authedSession,
          'Move to savings',
          25000,
          'USD',
          budget.id!,
          fromAccount.id!,
          toAccount.id!,
          DateTime.utc(2026, 1, 20),
        );

        expect(created, hasLength(2));

        final outflow = created.firstWhere(
          (transaction) => transaction.accountId == fromAccount.id,
        );
        final inflow = created.firstWhere(
          (transaction) => transaction.accountId == toAccount.id,
        );

        expect(outflow.amountCents, -25000);
        expect(inflow.amountCents, 25000);
        expect(outflow.transferPairId, inflow.id);
        expect(inflow.transferPairId, outflow.id);
      },
    );

    test(
      'when transfer includes account outside budget then throws not found',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Transfer Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Transfer Budget',
          'USD',
        );
        final primaryAccount = await endpoints.account.create(
          authedSession,
          'Primary Account',
          'checking',
          0,
          'USD',
          primaryBudget.id!,
          onBudget: true,
          sortOrder: 0,
        );
        final foreignAccount = await endpoints.account.create(
          authedSession,
          'Foreign Account',
          'checking',
          0,
          'USD',
          foreignBudget.id!,
          onBudget: true,
          sortOrder: 0,
        );

        await expectLater(
          endpoints.transaction.transfer(
            authedSession,
            'Invalid transfer',
            1000,
            'USD',
            primaryBudget.id!,
            primaryAccount.id!,
            foreignAccount.id!,
            DateTime.utc(2026, 1, 20),
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test(
      'when transfer uses same source and destination then throws',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Same Account Transfer Budget',
          'USD',
        );
        final account = await endpoints.account.create(
          authedSession,
          'Checking',
          'checking',
          0,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 0,
        );

        await expectLater(
          endpoints.transaction.transfer(
            authedSession,
            'Self transfer',
            1000,
            'USD',
            budget.id!,
            account.id!,
            account.id!,
            DateTime.utc(2026, 1, 20),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('when listing transactions then returns all for budget', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );

      await endpoints.transaction.create(
        authedSession,
        'Transaction 1',
        -1000,
        'USD',
        budget.id!,
        DateTime.utc(2026, 1, 10),
      );
      await endpoints.transaction.create(
        authedSession,
        'Transaction 2',
        -2000,
        'USD',
        budget.id!,
        DateTime.utc(2026, 1, 15),
      );

      final transactions = await endpoints.transaction.list(
        authedSession,
        budget.id!,
      );
      expect(transactions, hasLength(2));
    });

    test(
      'when listing transactions then returns ordered by date descending',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Test Budget',
          'USD',
        );

        await endpoints.transaction.create(
          authedSession,
          'Older',
          -1000,
          'USD',
          budget.id!,
          DateTime.utc(2026),
        );
        await endpoints.transaction.create(
          authedSession,
          'Newer',
          -2000,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        final transactions = await endpoints.transaction.list(
          authedSession,
          budget.id!,
        );
        expect(transactions.first.description, 'Newer');
        expect(transactions.last.description, 'Older');
      },
    );

    test(
      'when updating a transaction then returns updated transaction',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Test Budget',
          'USD',
        );

        final transaction = await endpoints.transaction.create(
          authedSession,
          'Original',
          -1000,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        final updated = await endpoints.transaction.update(
          authedSession,
          transaction.id!,
          description: 'Updated',
          amountCents: -1500,
        );
        expect(updated.description, 'Updated');
        expect(updated.amountCents, -1500);
      },
    );

    test('when deleting a transaction then it is removed', () async {
      final budget = await endpoints.budget.create(
        authedSession,
        'Test Budget',
        'USD',
      );

      final transaction = await endpoints.transaction.create(
        authedSession,
        'Delete Me',
        -1000,
        'USD',
        budget.id!,
        DateTime.utc(2026, 1, 15),
      );

      await endpoints.transaction.delete(authedSession, transaction.id!);

      expect(
        () => endpoints.transaction.get(authedSession, transaction.id!),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      "when accessing transaction in another user's budget then throws",
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Private Budget',
          'USD',
        );

        final transaction = await endpoints.transaction.create(
          authedSession,
          'Private Transaction',
          -1000,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        final otherSession = createAuthenticatedSession(sessionBuilder);

        expect(
          () => endpoints.transaction.get(otherSession, transaction.id!),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
