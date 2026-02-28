import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given RecurringTransactionEndpoint', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder authedSession;

    setUp(() async {
      authedSession = createAuthenticatedSession(sessionBuilder);
    });

    test(
      'when creating recurring transaction with valid references then persists',
      () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Recurring Budget',
          'USD',
        );
        final category = await endpoints.category.create(
          authedSession,
          'Utilities',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Electric',
          category.id!,
          0,
          'USD',
        );
        final payee = await endpoints.payee.create(
          authedSession,
          'Power Co',
          budget.id!,
        );
        final account = await endpoints.account.create(
          authedSession,
          'Checking',
          'checking',
          100000,
          'USD',
          budget.id!,
          onBudget: true,
          sortOrder: 0,
        );

        final recurring = await endpoints.recurringTransaction.create(
          authedSession,
          'Monthly electric bill',
          -12000,
          'USD',
          budget.id!,
          'monthly',
          DateTime.utc(2026, 2),
          envelopeId: envelope.id,
          accountId: account.id,
          payeeId: payee.id,
        );

        expect(recurring.budgetId, budget.id);
        expect(recurring.envelopeId, envelope.id);
        expect(recurring.accountId, account.id);
        expect(recurring.payeeId, payee.id);
      },
    );

    test(
      'when creating recurring transaction with envelope outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Budget',
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
          endpoints.recurringTransaction.create(
            authedSession,
            'Invalid recurring envelope',
            -1000,
            'USD',
            primaryBudget.id!,
            'monthly',
            DateTime.utc(2026, 2),
            envelopeId: foreignEnvelope.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final recurrings = await endpoints.recurringTransaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(recurrings, isEmpty);
      },
    );

    test(
      'when creating recurring transaction with account outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Account Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Account Budget',
          'USD',
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
          endpoints.recurringTransaction.create(
            authedSession,
            'Invalid recurring account',
            -1000,
            'USD',
            primaryBudget.id!,
            'monthly',
            DateTime.utc(2026, 2),
            accountId: foreignAccount.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final recurrings = await endpoints.recurringTransaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(recurrings, isEmpty);
      },
    );

    test(
      'when creating recurring transaction with payee outside budget then throws and does not persist',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Payee Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Payee Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Payee',
          foreignBudget.id!,
        );

        await expectLater(
          endpoints.recurringTransaction.create(
            authedSession,
            'Invalid recurring payee',
            -1000,
            'USD',
            primaryBudget.id!,
            'monthly',
            DateTime.utc(2026, 2),
            payeeId: foreignPayee.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final recurrings = await endpoints.recurringTransaction.list(
          authedSession,
          primaryBudget.id!,
        );
        expect(recurrings, isEmpty);
      },
    );

    test(
      'when updating recurring transaction with envelope outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Update Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Update Budget',
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
        final recurring = await endpoints.recurringTransaction.create(
          authedSession,
          'Recurring source',
          -2000,
          'USD',
          primaryBudget.id!,
          'monthly',
          DateTime.utc(2026, 2),
        );

        await expectLater(
          endpoints.recurringTransaction.update(
            authedSession,
            recurring.id!,
            envelopeId: foreignEnvelope.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.recurringTransaction.get(
          authedSession,
          recurring.id!,
        );
        expect(unchanged.envelopeId, isNull);
      },
    );

    test(
      'when updating recurring transaction with account outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Update Account Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Update Account Budget',
          'USD',
        );
        final foreignAccount = await endpoints.account.create(
          authedSession,
          'Foreign Update Account',
          'checking',
          0,
          'USD',
          foreignBudget.id!,
          onBudget: true,
          sortOrder: 0,
        );
        final recurring = await endpoints.recurringTransaction.create(
          authedSession,
          'Recurring source',
          -2000,
          'USD',
          primaryBudget.id!,
          'monthly',
          DateTime.utc(2026, 2),
        );

        await expectLater(
          endpoints.recurringTransaction.update(
            authedSession,
            recurring.id!,
            accountId: foreignAccount.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.recurringTransaction.get(
          authedSession,
          recurring.id!,
        );
        expect(unchanged.accountId, isNull);
      },
    );

    test(
      'when updating recurring transaction with payee outside budget then throws and keeps original',
      () async {
        final primaryBudget = await endpoints.budget.create(
          authedSession,
          'Primary Recurring Update Payee Budget',
          'USD',
        );
        final foreignBudget = await endpoints.budget.create(
          authedSession,
          'Foreign Recurring Update Payee Budget',
          'USD',
        );
        final foreignPayee = await endpoints.payee.create(
          authedSession,
          'Foreign Update Payee',
          foreignBudget.id!,
        );
        final recurring = await endpoints.recurringTransaction.create(
          authedSession,
          'Recurring source',
          -2000,
          'USD',
          primaryBudget.id!,
          'monthly',
          DateTime.utc(2026, 2),
        );

        await expectLater(
          endpoints.recurringTransaction.update(
            authedSession,
            recurring.id!,
            payeeId: foreignPayee.id,
          ),
          throwsA(isA<NotFoundException>()),
        );

        final unchanged = await endpoints.recurringTransaction.get(
          authedSession,
          recurring.id!,
        );
        expect(unchanged.payeeId, isNull);
      },
    );
  });
}
