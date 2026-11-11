import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/recurring_transactions/recurring_post_future_call.dart';
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_endpoint.dart';
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_service.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

void main() {
  late PgTestServer server;
  late RecurringTransactionEndpoint endpoint;
  late RecurringPostFutureCall job;
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
    job = RecurringPostFutureCall();
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

  Future<BudgetTestBook> newBook({String timeZone = 'Europe/London'}) async {
    final session = server.anonymousSession();
    addTearDown(session.close);
    final book = await BudgetTestBook.create(session, timeZone: timeZone);
    await book.session.caches.clear();
    return book;
  }

  Future<RecurringTransaction> createDue(
    BudgetTestBook book,
    Account account, {
    String description = 'Rent',
    int amountMinor = -1000,
    String? currencyCode,
  }) => endpoint.create(
    book.session,
    account.id!,
    description,
    amountMinor,
    RecurrenceFrequency.monthly,
    EntityClock.today(book.entity),
  );

  group('Given the hourly recurring poster', () {
    test('when the session is unauthenticated then it posts for every '
        'persisted owner in isolation', () async {
      final first = await newBook(timeZone: 'Pacific/Kiritimati');
      final second = await newBook(timeZone: 'Pacific/Pago_Pago');
      final firstAccount = await first.addAccount(name: 'First account');
      final secondAccount = await second.addAccount(name: 'Second account');
      final firstSchedule = await createDue(first, firstAccount);
      final secondSchedule = await createDue(second, secondAccount);

      final unauthenticated = server.anonymousSession();
      addTearDown(unauthenticated.close);
      expect(unauthenticated.authenticated, isNull);

      await job.postDue(unauthenticated);

      expect(unauthenticated.authenticated, isNull);
      final firstRows = await model.Transaction.db.find(
        first.session,
        where: (t) => t.recurringTransactionId.equals(firstSchedule.id),
      );
      final secondRows = await model.Transaction.db.find(
        second.session,
        where: (t) => t.recurringTransactionId.equals(secondSchedule.id),
      );
      expect(firstRows, hasLength(1));
      expect(secondRows, hasLength(1));
      expect(firstRows.single.entityId, first.entity.id);
      expect(secondRows.single.entityId, second.entity.id);
      expect(
        await Entity.db.findById(first.session, second.entity.id!),
        isNotNull,
      );
      expect(
        (await Entity.db.findById(first.session, first.entity.id!))?.ownerId,
        first.userId,
      );
      expect(
        (await Entity.db.findById(second.session, second.entity.id!))?.ownerId,
        second.userId,
      );
    });

    test('when a principal names another entity then the system seam denies '
        'it', () async {
      final first = await newBook();
      final second = await newBook();
      final firstAccount = await first.addAccount();
      await createDue(first, firstAccount);
      final principal = await EntityAccess.systemOwnerFor(
        first.session,
        first.entity.id!,
      );

      await expectLater(
        RecurringTransactionService.postDueForSystemJob(
          first.session,
          entityId: second.entity.id!,
          systemOwner: principal,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.postDue(first.session, second.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('when one schedule is missing FX then it stays due while another '
        'schedule posts', () async {
      final book = await newBook();
      final gbp = await book.addAccount(name: 'GBP account');
      final usd = await book.addAccount(
        name: 'USD account',
        currencyCode: 'USD',
      );
      final good = await createDue(book, gbp, description: 'Good');
      final bad = await createDue(book, usd, description: 'Bad');
      final badDate = bad.nextDate;
      await server.clearRates();

      final unauthenticated = server.anonymousSession();
      addTearDown(unauthenticated.close);
      await job.postDue(unauthenticated);

      expect(
        await model.Transaction.db.count(
          book.session,
          where: (t) => t.recurringTransactionId.equals(good.id),
        ),
        1,
      );
      expect(
        await model.Transaction.db.count(
          book.session,
          where: (t) => t.recurringTransactionId.equals(bad.id),
        ),
        0,
      );
      final failed = await endpoint.get(book.session, bad.id!);
      expect(failed.nextDate, badDate);
      expect(failed.isActive, isTrue);
      expect(await endpoint.countDue(book.session, book.entity.id!), 1);
    });

    test(
      'when the hourly job runs twice then a due occurrence posts once',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final schedule = await createDue(book, account);
        final unauthenticated = server.anonymousSession();
        addTearDown(unauthenticated.close);

        await job.postDue(unauthenticated);
        await job.postDue(unauthenticated);

        expect(
          await model.Transaction.db.count(
            book.session,
            where: (t) => t.recurringTransactionId.equals(schedule.id),
          ),
          1,
        );
        expect(
          (await endpoint.get(book.session, schedule.id!)).isActive,
          isTrue,
        );
      },
    );

    test('when two hourly jobs race then the stable occurrence is not '
        'duplicated', () async {
      final book = await newBook();
      final account = await book.addAccount();
      final schedule = await createDue(book, account);
      final firstSession = server.anonymousSession();
      final secondSession = server.anonymousSession();
      addTearDown(firstSession.close);
      addTearDown(secondSession.close);
      final firstJob = RecurringPostFutureCall();
      final secondJob = RecurringPostFutureCall();

      await Future.wait([
        firstJob.postDue(firstSession),
        secondJob.postDue(secondSession),
      ]);

      final rows = await model.Transaction.db.find(
        book.session,
        where: (t) => t.recurringTransactionId.equals(schedule.id),
      );
      expect(rows, hasLength(1));
      final advanced = await endpoint.get(book.session, schedule.id!);
      expect(advanced.nextDate.isAfter(schedule.nextDate), isTrue);
      expect(await endpoint.countDue(book.session, book.entity.id!), 0);
    });
  });
}
