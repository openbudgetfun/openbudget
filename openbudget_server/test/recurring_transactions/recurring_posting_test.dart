import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

void main() {
  late PgTestServer server;
  late RecurringTransactionEndpoint endpoint;
  late EventLog events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = EventLog()..install();
    endpoint = RecurringTransactionEndpoint();
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
  });

  tearDown(() {
    events.reset();
    FxService.resetForTests();
  });

  Future<BudgetTestBook> newBook({
    String timeZone = 'Europe/London',
    String baseCurrencyCode = 'GBP',
    AccountingMode accountingMode = AccountingMode.envelope,
  }) async {
    final session = server.anonymousSession();
    addTearDown(session.close);
    final book = await BudgetTestBook.create(
      session,
      timeZone: timeZone,
      baseCurrencyCode: baseCurrencyCode,
      accountingMode: accountingMode,
    );
    await book.session.caches.clear();
    return book;
  }

  DateTime today(BudgetTestBook book) => EntityClock.today(book.entity);

  Future<RecurringTransaction> createDue(
    BudgetTestBook book, {
    required Account onAccount,
    String description = 'Rent',
    int amountMinor = -1000,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    DateTime? nextDate,
    UuidValue? payeeId,
    UuidValue? envelopeId,
    String? memo,
  }) => endpoint.create(
    book.session,
    onAccount.id!,
    description,
    amountMinor,
    frequency,
    nextDate ?? today(book),
    payeeId: payeeId,
    envelopeId: envelopeId,
    memo: memo,
  );

  group('Given a due recurring schedule', () {
    test(
      'when posting then writes the real transaction, line and events',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Landlord');
        final envelope = await book.addEnvelope(name: 'Housing');
        final created = await createDue(
          book,
          onAccount: account,
          amountMinor: -125000,
          payeeId: payee.id,
          envelopeId: envelope.id,
          memo: 'October',
        );
        final scheduleDate = created.nextDate;
        events.events.clear();

        expect(await endpoint.postDue(book.session, book.entity.id!), 1);

        final posted = await model.Transaction.db.find(
          book.session,
          where: (t) => t.recurringTransactionId.equals(created.id),
        );
        expect(posted, hasLength(1));
        final row = posted.single;
        expect(row.entityId, book.entity.id);
        expect(row.accountId, account.id);
        expect(row.date, scheduleDate);
        expect(row.description, 'Rent');
        expect(row.memo, 'October');
        expect(row.amountMinor, -125000);
        expect(row.baseAmountMinor, -125000);
        expect(row.fxRate, '1');
        expect(row.fxRateSource, FxRateSource.identity);
        expect(row.payeeId, payee.id);
        expect(row.kind, TransactionKind.standard);
        expect(row.status, TransactionStatus.uncleared);
        expect(row.recurringTransactionId, created.id);
        expect(row.externalId, isNotNull);
        expect(
          row.externalId,
          'recurring:${created.id}:'
          '${scheduleDate.year}-'
          '${scheduleDate.month.toString().padLeft(2, '0')}-'
          '${scheduleDate.day.toString().padLeft(2, '0')}',
        );

        final lines = await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(row.id),
        );
        expect(lines, hasLength(1));
        expect(lines.single.amountMinor, -125000);
        expect(lines.single.envelopeId, envelope.id);

        expect(await book.cachedBalanceMinor(account), -125000);
        expect(await book.recomputedBalanceMinor(account), -125000);
        expect(await endpoint.countDue(book.session, book.entity.id!), 0);

        expect(events.events, isNotEmpty);
        expect(
          events.events.any(
            (event) =>
                event.entityId == book.entity.id &&
                event.scope == ChangeScope.transactions &&
                event.accountId == account.id &&
                event.month == MonthKey.fromDate(scheduleDate),
          ),
          isTrue,
        );
      },
    );

    test(
      'when no envelope is stored then the payee rule codes the line',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Grocer');
        final ruleEnvelope = await book.addEnvelope(name: 'Food');
        await book.addRule(payee: payee, envelope: ruleEnvelope);
        final created = await createDue(
          book,
          onAccount: account,
          description: 'Groceries',
          amountMinor: -5000,
          payeeId: payee.id,
        );

        expect(await endpoint.postDue(book.session, book.entity.id!), 1);

        final posted = await model.Transaction.db.findFirstRow(
          book.session,
          where: (t) => t.recurringTransactionId.equals(created.id),
        );
        final lines = await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(posted!.id),
        );
        expect(lines.single.envelopeId, ruleEnvelope.id);
      },
    );

    test(
      'when an explicit envelope exists then it overrides the payee rule',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Grocer');
        final ruleEnvelope = await book.addEnvelope(name: 'Food');
        final explicitEnvelope = await book.addEnvelope(name: 'Household');
        await book.addRule(payee: payee, envelope: ruleEnvelope);
        final created = await createDue(
          book,
          onAccount: account,
          description: 'Groceries',
          amountMinor: -5000,
          payeeId: payee.id,
          envelopeId: explicitEnvelope.id,
        );

        expect(await endpoint.postDue(book.session, book.entity.id!), 1);

        final posted = await model.Transaction.db.findFirstRow(
          book.session,
          where: (t) => t.recurringTransactionId.equals(created.id),
        );
        final lines = await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(posted!.id),
        );
        expect(lines.single.envelopeId, explicitEnvelope.id);
      },
    );

    test('when several daily occurrences are due then catch-up is '
        'chronological and idempotent', () async {
      final book = await newBook();
      final account = await book.addAccount();
      final start = today(book).subtract(const Duration(days: 3));
      final created = await createDue(
        book,
        onAccount: account,
        frequency: RecurrenceFrequency.daily,
        nextDate: start,
      );

      expect(await endpoint.postDue(book.session, book.entity.id!), 4);

      final posted = await model.Transaction.db.find(
        book.session,
        where: (t) => t.recurringTransactionId.equals(created.id),
        orderBy: (t) => t.date,
      );
      expect(
        posted.map((row) => row.date),
        [
          start,
          start.add(const Duration(days: 1)),
          start.add(const Duration(days: 2)),
          start.add(const Duration(days: 3)),
        ],
      );
      expect(posted.map((row) => row.externalId).toSet(), hasLength(4));

      final reloaded = await endpoint.get(book.session, created.id!);
      expect(reloaded.nextDate, today(book).add(const Duration(days: 1)));
      expect(await endpoint.postDue(book.session, book.entity.id!), 0);
      expect(await book.cachedBalanceMinor(account), -4000);
    });

    test('when counting due then a catching-up schedule counts once', () async {
      final book = await newBook();
      final account = await book.addAccount();
      final start = today(book).subtract(const Duration(days: 3));
      await createDue(
        book,
        onAccount: account,
        frequency: RecurrenceFrequency.daily,
        nextDate: start,
      );
      await createDue(
        book,
        onAccount: account,
        description: 'Weekly',
        frequency: RecurrenceFrequency.weekly,
        nextDate: today(book),
      );

      expect(await endpoint.countDue(book.session, book.entity.id!), 2);
      expect(await endpoint.postDue(book.session, book.entity.id!), 5);
      expect(await endpoint.countDue(book.session, book.entity.id!), 0);
    });

    test('when the market rate is missing then the occurrence and advance '
        'roll back, and a later retry succeeds', () async {
      final book = await newBook();
      final usd = await book.addAccount(
        name: 'USD account',
        currencyCode: 'USD',
      );
      final date = today(book);
      final created = await createDue(
        book,
        onAccount: usd,
        description: 'Subscription',
        nextDate: date,
      );
      await server.clearRates();
      events.events.clear();

      await expectLater(
        endpoint.postDue(book.session, book.entity.id!),
        throwsA(isA<FxRateUnavailableException>()),
      );

      expect(
        await model.Transaction.db.count(
          book.session,
          where: (t) => t.recurringTransactionId.equals(created.id),
        ),
        0,
      );
      expect(await book.cachedBalanceMinor(usd), 0);
      expect(events.events, isEmpty);
      expect(
        (await endpoint.get(book.session, created.id!)).nextDate,
        date,
      );

      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      await book.session.caches.clear();

      expect(await endpoint.postDue(book.session, book.entity.id!), 1);
      final posted = await model.Transaction.db.findFirstRow(
        book.session,
        where: (t) => t.recurringTransactionId.equals(created.id),
      );
      expect(posted, isNotNull);
      expect(posted!.fxRate, '0.8');
      expect(posted.fxRateSource, FxRateSource.market);
      expect(posted.baseAmountMinor, -800);
      expect(await book.cachedBalanceMinor(usd), -1000);
      expect(await book.recomputedBalanceMinor(usd), -1000);
    });

    test(
      'when the occurrence falls in a locked period then it rolls back',
      () async {
        final book = await newBook(accountingMode: AccountingMode.ledger);
        final account = await book.addAccount();
        final date = today(book);
        await book.addPeriodLock(date);
        final created = await createDue(
          book,
          onAccount: account,
          nextDate: date,
        );
        events.events.clear();

        await expectLater(
          endpoint.postDue(book.session, book.entity.id!),
          throwsA(isA<ValidationException>()),
        );

        expect(
          await model.Transaction.db.count(
            book.session,
            where: (t) => t.recurringTransactionId.equals(created.id),
          ),
          0,
        );
        expect(events.events, isEmpty);
        expect((await endpoint.get(book.session, created.id!)).nextDate, date);
        expect(await book.cachedBalanceMinor(account), 0);
      },
    );

    test('when entities have different local dates then only the local due '
        'schedule posts', () async {
      final east = await newBook(timeZone: 'Pacific/Kiritimati');
      final west = await newBook(timeZone: 'Pacific/Pago_Pago');
      final eastToday = today(east);
      final westToday = today(west);
      expect(eastToday, isNot(westToday));

      final eastAccount = await east.addAccount(name: 'East account');
      final westAccount = await west.addAccount(name: 'West account');
      final eastSchedule = await createDue(east, onAccount: eastAccount);
      final westSchedule = await createDue(
        west,
        onAccount: westAccount,
        nextDate: westToday.add(const Duration(days: 1)),
      );

      expect(await endpoint.postDue(east.session, east.entity.id!), 1);
      expect(await endpoint.postDue(west.session, west.entity.id!), 0);

      expect(
        await model.Transaction.db.count(
          east.session,
          where: (t) => t.recurringTransactionId.equals(eastSchedule.id),
        ),
        1,
      );
      expect(
        await model.Transaction.db.count(
          west.session,
          where: (t) => t.recurringTransactionId.equals(westSchedule.id),
        ),
        0,
      );
    });
  });
}
