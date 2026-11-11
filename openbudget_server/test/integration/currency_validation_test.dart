import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'helpers/auth_helper.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given currency validation', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    Matcher throwsUnsupportedCurrency(String code) => throwsA(
      isA<ValidationException>().having(
        (error) => error.message,
        'message',
        contains('Unsupported currency: $code'),
      ),
    );

    group('budgets', () {
      test('creating a budget with an unsupported code is rejected', () async {
        await expectLater(
          endpoints.budget.create(authedSession, 'Bad Budget', 'XYZ'),
          throwsUnsupportedCurrency('XYZ'),
        );

        expect(await endpoints.budget.list(authedSession), isEmpty);
      });

      test('creating a budget normalizes a lowercase code', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Lowercase',
          ' gbp ',
        );

        expect(budget.currencyCode, 'GBP');
      });

      test('updating a budget with an unsupported code is rejected', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Keep USD',
          'USD',
        );

        await expectLater(
          endpoints.budget.update(
            authedSession,
            budget.id!,
            currencyCode: 'XYZ',
          ),
          throwsUnsupportedCurrency('XYZ'),
        );

        final unchanged = await endpoints.budget.get(
          authedSession,
          budget.id!,
        );
        expect(unchanged.currencyCode, 'USD');
      });

      test('updating a display currency validates the code', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Display',
          'USD',
        );

        await expectLater(
          endpoints.budget.update(
            authedSession,
            budget.id!,
            displayCurrencyCode: 'NOPE',
          ),
          throwsUnsupportedCurrency('NOPE'),
        );
      });
    });

    group('accounts', () {
      test(
        'creating an account with an unsupported code is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );

          await expectLater(
            endpoints.account.create(
              authedSession,
              'Bad Account',
              'checking',
              0,
              'XYZ',
              budget.id!,
              onBudget: true,
              sortOrder: 0,
            ),
            throwsUnsupportedCurrency('XYZ'),
          );

          expect(
            await endpoints.account.list(authedSession, budget.id!),
            isEmpty,
          );
        },
      );

      test('creating an account normalizes a lowercase code', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Budget',
          'USD',
        );

        final account = await endpoints.account.create(
          authedSession,
          'Euro Account',
          'checking',
          1000,
          'eur',
          budget.id!,
          onBudget: true,
          sortOrder: 0,
        );

        expect(account.currencyCode, 'EUR');
      });
    });

    group('transactions', () {
      test(
        'creating a transaction with an unsupported code is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );

          await expectLater(
            endpoints.transaction.create(
              authedSession,
              'Bad',
              -100,
              'XYZ',
              budget.id!,
              DateTime.utc(2026, 1, 15),
            ),
            throwsUnsupportedCurrency('XYZ'),
          );

          expect(
            await endpoints.transaction.list(authedSession, budget.id!),
            isEmpty,
          );
        },
      );

      test('creating a transaction normalizes a lowercase code', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Budget',
          'USD',
        );

        final transaction = await endpoints.transaction.create(
          authedSession,
          'Coffee',
          -500,
          'eur',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        expect(transaction.currencyCode, 'EUR');
      });

      test('transferring with an unsupported code is rejected', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Budget',
          'USD',
        );
        final fromAccount = await endpoints.account.create(
          authedSession,
          'From',
          'checking',
          0,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 0,
        );
        final toAccount = await endpoints.account.create(
          authedSession,
          'To',
          'savings',
          0,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 1,
        );

        await expectLater(
          endpoints.transaction.transfer(
            authedSession,
            'Transfer',
            100,
            'XYZ',
            budget.id!,
            fromAccount.id!,
            toAccount.id!,
            DateTime.utc(2026, 1, 15),
          ),
          throwsUnsupportedCurrency('XYZ'),
        );

        expect(
          await endpoints.transaction.list(authedSession, budget.id!),
          isEmpty,
        );
      });

      test(
        'transferring between different account currencies is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final fromAccount = await endpoints.account.create(
            authedSession,
            'Dollars',
            'checking',
            0,
            'USD',
            budget.id!,
            onBudget: true,
            sortOrder: 0,
          );
          final toAccount = await endpoints.account.create(
            authedSession,
            'Euros',
            'savings',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 1,
          );

          await expectLater(
            endpoints.transaction.transfer(
              authedSession,
              'Cross currency',
              100,
              'USD',
              budget.id!,
              fromAccount.id!,
              toAccount.id!,
              DateTime.utc(2026, 1, 15),
            ),
            throwsA(
              isA<ValidationException>().having(
                (error) => error.message,
                'message',
                'Source and destination accounts must share a currency (USD and EUR)',
              ),
            ),
          );

          expect(
            await endpoints.transaction.list(authedSession, budget.id!),
            isEmpty,
          );
        },
      );

      test(
        'transferring in a currency other than the accounts is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final fromAccount = await endpoints.account.create(
            authedSession,
            'From',
            'checking',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 0,
          );
          final toAccount = await endpoints.account.create(
            authedSession,
            'To',
            'savings',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 1,
          );

          await expectLater(
            endpoints.transaction.transfer(
              authedSession,
              'Wrong currency',
              100,
              'USD',
              budget.id!,
              fromAccount.id!,
              toAccount.id!,
              DateTime.utc(2026, 1, 15),
            ),
            throwsA(
              isA<ValidationException>().having(
                (error) => error.message,
                'message',
                'Transfer currency must match the account currency (EUR)',
              ),
            ),
          );

          expect(
            await endpoints.transaction.list(authedSession, budget.id!),
            isEmpty,
          );
        },
      );

      test(
        'transferring between accounts of the same currency succeeds',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final fromAccount = await endpoints.account.create(
            authedSession,
            'From',
            'checking',
            0,
            'eur',
            budget.id!,
            onBudget: true,
            sortOrder: 0,
          );
          final toAccount = await endpoints.account.create(
            authedSession,
            'To',
            'savings',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 1,
          );

          final created = await endpoints.transaction.transfer(
            authedSession,
            'Move euros',
            250,
            'eur',
            budget.id!,
            fromAccount.id!,
            toAccount.id!,
            DateTime.utc(2026, 1, 15),
          );

          expect(created, hasLength(2));
          expect(
            created.map((transaction) => transaction.currencyCode),
            everyElement('EUR'),
          );
        },
      );
    });

    group('reconciliation', () {
      test(
        'adjustment uses the account currency, not the budget currency',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final account = await endpoints.account.create(
            authedSession,
            'Euro checking',
            'checking',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 0,
          );
          final session = authedSession.build();
          try {
            await Transaction.db.insertRow(
              session,
              Transaction(
                description: 'Opening',
                amountCents: 1000,
                currencyCode: 'EUR',
                budgetId: budget.id!,
                accountId: account.id,
                transactionDate: DateTime.utc(2026, 1, 15),
                cleared: true,
                createdAt: DateTime.now(),
              ),
            );

            final result = await endpoints.transaction.reconcileWithBalance(
              authedSession,
              account.id!,
              budget.id!,
              1500,
            );

            expect(result, [1, 500]);
            final rows = await endpoints.transaction.listByAccount(
              authedSession,
              account.id!,
              budget.id!,
            );
            final adjustment = rows.singleWhere(
              (row) => row.description == 'Reconciliation adjustment',
            );
            expect(adjustment.currencyCode, 'EUR');
            expect(adjustment.amountCents, 500);
          } finally {
            await session.close();
          }
        },
      );

      test(
        'reconciling an account that holds another currency is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final account = await endpoints.account.create(
            authedSession,
            'Euro checking',
            'checking',
            0,
            'EUR',
            budget.id!,
            onBudget: true,
            sortOrder: 0,
          );
          final session = authedSession.build();
          try {
            await Transaction.db.insertRow(
              session,
              Transaction(
                description: 'Wrong currency',
                amountCents: 1000,
                currencyCode: 'USD',
                budgetId: budget.id!,
                accountId: account.id,
                transactionDate: DateTime.utc(2026, 1, 15),
                cleared: true,
                createdAt: DateTime.now(),
              ),
            );

            await expectLater(
              endpoints.transaction.reconcileWithBalance(
                authedSession,
                account.id!,
                budget.id!,
                1000,
              ),
              throwsA(
                isA<ValidationException>().having(
                  (error) => error.message,
                  'message',
                  'Cannot reconcile EUR account while it has a USD transaction',
                ),
              ),
            );

            final rows = await endpoints.transaction.listByAccount(
              authedSession,
              account.id!,
              budget.id!,
            );
            expect(rows, hasLength(1));
            expect(
              rows.any((row) => row.description == 'Reconciliation adjustment'),
              isFalse,
            );
          } finally {
            await session.close();
          }
        },
      );
    });

    group('recurring transactions', () {
      test(
        'creating a recurring transaction with an unsupported code is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );

          await expectLater(
            endpoints.recurringTransaction.create(
              authedSession,
              'Rent',
              -100000,
              'XYZ',
              budget.id!,
              'monthly',
              DateTime.utc(2026, 2),
            ),
            throwsUnsupportedCurrency('XYZ'),
          );
        },
      );
    });

    group('envelopes', () {
      test(
        'creating an envelope with an unsupported code is rejected',
        () async {
          final budget = await endpoints.budget.create(
            authedSession,
            'Budget',
            'USD',
          );
          final category = await endpoints.category.create(
            authedSession,
            'Category',
            budget.id!,
            0,
          );

          await expectLater(
            endpoints.envelope.create(
              authedSession,
              'Envelope',
              category.id!,
              10000,
              'XYZ',
            ),
            throwsUnsupportedCurrency('XYZ'),
          );
        },
      );
    });
  });
}
