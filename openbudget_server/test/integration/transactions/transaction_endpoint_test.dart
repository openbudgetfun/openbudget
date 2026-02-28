import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/transactions/transaction_service.dart';
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
      'when creating transaction with envelope outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Budget',
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
          endpoints.transaction.create(
            authedSession,
            'Invalid envelope transaction',
            -1200,
            'USD',
            primaryBudget.id!,
            DateTime.utc(2026, 1, 15),
            envelopeId: foreignEnvelope.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final transactions = await endpoints.transaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(transactions, isEmpty);
      },
    );

    test(
      'when creating transaction with payee outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Payee Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Payee Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Payee',
          foreignBudget.id!,
        );

        await expectLater(
          endpoints.transaction.create(
            authedSession,
            'Invalid payee transaction',
            -1200,
            'USD',
            primaryBudget.id!,
            DateTime.utc(2026, 1, 15),
            payeeId: foreignPayee.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final transactions = await endpoints.transaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(transactions, isEmpty);
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
      'when transfer inflow insert fails then no partial transactions persist',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Transfer Rollback Budget',
          'USD',
        );
        final budgetId = budget.id!;
        final fromAccount = await endpoints.account.create(
          authedSession,
          'Checking',
          'checking',
          500000,
          'USD',
          budgetId,
          onBudget: true,
          sortOrder: 0,
        );
        final toAccount = await endpoints.account.create(
          authedSession,
          'Savings',
          'savings',
          100000,
          'USD',
          budgetId,
          onBudget: true,
          sortOrder: 1,
        );

        final session = authedSession.build();
        try {
          await session.db.unsafeSimpleExecute(r'''
CREATE OR REPLACE FUNCTION ob_fail_transfer_inflow_insert()
RETURNS trigger AS $$
BEGIN
  IF NEW."transferPairId" IS NOT NULL THEN
    RAISE EXCEPTION 'forced transfer inflow failure';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ob_fail_transfer_inflow_insert_trigger ON "transaction";
CREATE TRIGGER ob_fail_transfer_inflow_insert_trigger
BEFORE INSERT ON "transaction"
FOR EACH ROW
EXECUTE FUNCTION ob_fail_transfer_inflow_insert();
''');

          await expectLater(
            TransactionService.createTransfer(
              session,
              description: 'Should roll back',
              amountCents: 25000,
              currencyCode: 'USD',
              budgetId: budgetId,
              fromAccountId: fromAccount.id!,
              toAccountId: toAccount.id!,
              transactionDate: DateTime.utc(2026, 1, 20),
            ),
            throwsA(isA<Exception>()),
          );

          final transactions = await Transaction.db.find(
            session,
            where: (t) => t.budgetId.equals(budgetId),
          );
          expect(transactions, isEmpty);
        } finally {
          await session.close();
        }
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

        final primaryTransactions = await endpoints.transaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(primaryTransactions, isEmpty);
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

        final transactions = await endpoints.transaction.list(
          authedSession,
          budget.id!,
        );
        expect(transactions, isEmpty);
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

    test(
      'when updating transaction with envelope outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Update Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Update Budget',
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
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Update Envelope Source',
          -1300,
          'USD',
          primaryBudget.id!,
          DateTime.utc(2026, 1, 15),
        );

        await expectLater(
          endpoints.transaction.update(
            authedSession,
            transaction.id!,
            envelopeId: foreignEnvelope.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.transaction.get(
          authedSession,
          transaction.id!,
        );
        expect(unchanged.envelopeId, isNull);
      },
    );

    test(
      'when updating transaction with payee outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Update Payee Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Update Payee Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Update Payee',
          foreignBudget.id!,
        );
        final localPayee = await endpoints.payee.create(
          authedSession,
          'Local Payee',
          primaryBudget.id!,
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Update Payee Source',
          -1300,
          'USD',
          primaryBudget.id!,
          DateTime.utc(2026, 1, 15),
          payeeId: localPayee.id,
        );

        await expectLater(
          endpoints.transaction.update(
            authedSession,
            transaction.id!,
            payeeId: foreignPayee.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.transaction.get(
          authedSession,
          transaction.id!,
        );
        expect(unchanged.payeeId, localPayee.id);
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

    test(
      'when creating split then creates parent and child transactions',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Split Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Expenses',
          budget.id!,
          0,
        );
        final groceriesEnvelope = await endpoints.envelope.create(
          authedSession,
          'Groceries',
          category.id!,
          0,
          'USD',
        );
        final diningEnvelope = await endpoints.envelope.create(
          authedSession,
          'Dining',
          category.id!,
          0,
          'USD',
        );

        final created = await endpoints.transaction.createSplit(
          authedSession,
          'Split purchase',
          -2500,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
          [
            SplitItem(
              amountCents: 1500,
              envelopeId: groceriesEnvelope.id,
              memo: 'Groceries',
            ),
            SplitItem(
              amountCents: 1000,
              envelopeId: diningEnvelope.id,
              memo: 'Dining',
            ),
          ],
        );

        expect(created, hasLength(3));
        final parent = created.first;
        final children = created.skip(1).toList();

        expect(parent.parentTransactionId, isNull);
        expect(parent.envelopeId, isNull);
        for (final child in children) {
          expect(child.parentTransactionId, parent.id);
        }
        expect(children.map((transaction) => transaction.amountCents).toSet(), {
          -1500,
          -1000,
        });

        final splits = await endpoints.transaction.listSplits(
          authedSession,
          parent.id!,
        );
        expect(splits, hasLength(2));
      },
    );

    test(
      'when creating split with envelope outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Split Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Split Budget',
          'USD',
        );
        final foreignCategory = await endpoints.category.create(
          authedSession,
          'Foreign Split Category',
          foreignBudget.id!,
          0,
        );
        final foreignEnvelope = await endpoints.envelope.create(
          authedSession,
          'Foreign Split Envelope',
          foreignCategory.id!,
          0,
          'USD',
        );

        await expectLater(
          endpoints.transaction.createSplit(
            authedSession,
            'Invalid split',
            -2500,
            'USD',
            primaryBudget.id!,
            DateTime.utc(2026, 1, 15),
            [
              SplitItem(
                amountCents: 2500,
                envelopeId: foreignEnvelope.id,
                memo: 'Invalid split envelope',
              ),
            ],
          ),
          throwsA(isA<NotFoundException>()),
        );

        final transactions = await endpoints.transaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(transactions, isEmpty);
      },
    );

    test(
      'when creating split with account outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Split Account Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Split Account Budget',
          'USD',
        );
        final foreignAccount = await endpoints.account.create(
          authedSession,
          'Foreign Split Account',
          'checking',
          0,
          'USD',
          foreignBudget.id!,
          onBudget: true,
          sortOrder: 0,
        );

        await expectLater(
          endpoints.transaction.createSplit(
            authedSession,
            'Invalid split account',
            -2500,
            'USD',
            primaryBudget.id!,
            DateTime.utc(2026, 1, 15),
            [SplitItem(amountCents: 2500, memo: 'Single split')],
            accountId: foreignAccount.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final transactions = await endpoints.transaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(transactions, isEmpty);
      },
    );
  });
}
