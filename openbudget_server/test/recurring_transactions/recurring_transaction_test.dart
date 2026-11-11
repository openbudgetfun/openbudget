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
  late BudgetTestBook book;
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
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    addTearDown(book.session.close);
  });

  tearDown(() {
    events.reset();
    FxService.resetForTests();
  });

  DateTime today() => EntityClock.today(book.entity);

  Future<int> postedCount(BudgetTestBook target) => model.Transaction.db.count(
    target.session,
    where: (t) => t.entityId.equals(target.entity.id),
  );

  Future<Account> account({
    String name = 'Checking',
    String? currencyCode,
    AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
    DateTime? closedAt,
    Entity? entity,
  }) => book.addAccount(
    name: name,
    currencyCode: currencyCode,
    balanceSource: balanceSource,
    closedAt: closedAt,
    entity: entity,
  );

  Future<RecurringTransaction> createDue({
    required Account onAccount,
    String description = 'Rent',
    int amountMinor = -1000,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    DateTime? nextDate,
    DateTime? endDate,
    UuidValue? payeeId,
    UuidValue? envelopeId,
    String? memo,
  }) => endpoint.create(
    book.session,
    onAccount.id!,
    description,
    amountMinor,
    frequency,
    nextDate ?? today(),
    payeeId: payeeId,
    envelopeId: envelopeId,
    memo: memo,
    endDate: endDate,
  );

  group('Given the recurring transaction endpoint', () {
    test('when authenticated CRUD then returns the §7.1 fields', () async {
      final checking = await account();
      final payee = await book.addPayee();
      final envelope = await book.addEnvelope(name: 'Housing');
      final endDate = today().add(const Duration(days: 90));

      final created = await endpoint.create(
        book.session,
        checking.id!,
        '  Rent  ',
        -125000,
        RecurrenceFrequency.monthly,
        today().add(const Duration(days: 1)),
        payeeId: payee.id,
        envelopeId: envelope.id,
        memo: '  Flat  ',
        endDate: endDate,
      );

      expect(created.entityId, book.entity.id);
      expect(created.accountId, checking.id);
      expect(created.payeeId, payee.id);
      expect(created.envelopeId, envelope.id);
      expect(created.description, 'Rent');
      expect(created.memo, 'Flat');
      expect(created.amountMinor, -125000);
      expect(created.frequency, RecurrenceFrequency.monthly);
      expect(created.nextDate, today().add(const Duration(days: 1)));
      expect(created.endDate, endDate);
      expect(created.isActive, isTrue);
      expect(created.id, isNotNull);

      expect(
        (await endpoint.list(
          book.session,
          book.entity.id!,
        )).map((row) => row.id),
        [created.id],
      );
      expect((await endpoint.get(book.session, created.id!)).id, created.id);

      final updated = await endpoint.update(
        book.session,
        created.id!,
        description: 'Rent and service charge',
        amountMinor: -130000,
        frequency: RecurrenceFrequency.biweekly,
        nextDate: today().add(const Duration(days: 2)),
        memo: '',
        endDate: today().add(const Duration(days: 120)),
        isActive: false,
      );
      expect(updated.description, 'Rent and service charge');
      expect(updated.amountMinor, -130000);
      expect(updated.frequency, RecurrenceFrequency.biweekly);
      expect(updated.nextDate, today().add(const Duration(days: 2)));
      expect(updated.memo, isNull, reason: 'a blank memo clears it');
      expect(updated.endDate, today().add(const Duration(days: 120)));
      expect(updated.isActive, isFalse);

      final cleared = await endpoint.update(
        book.session,
        created.id!,
        clearPayee: true,
        clearEnvelope: true,
        clearEndDate: true,
      );
      expect(cleared.payeeId, isNull);
      expect(cleared.envelopeId, isNull);
      expect(cleared.endDate, isNull);
      expect(cleared.description, updated.description);

      expect((await endpoint.delete(book.session, created.id!)).id, created.id);
      expect(await endpoint.list(book.session, book.entity.id!), isEmpty);
      expect(events.events, isNotEmpty);
      expect(
        events.events.every((event) => event.scope == ChangeScope.transactions),
        isTrue,
      );
    });

    test('when clear flags conflict with values then rejects', () async {
      final checking = await account();
      final payee = await book.addPayee();
      final envelope = await book.addEnvelope();
      final created = await createDue(onAccount: checking);

      await expectLater(
        endpoint.update(
          book.session,
          created.id!,
          payeeId: payee.id,
          clearPayee: true,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(
          book.session,
          created.id!,
          envelopeId: envelope.id,
          clearEnvelope: true,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(
          book.session,
          created.id!,
          endDate: today(),
          clearEndDate: true,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('when posting one occurrence then history survives delete', () async {
      final checking = await account();
      final created = await createDue(onAccount: checking);

      expect(await endpoint.postDue(book.session, book.entity.id!), 1);
      final posted = await model.Transaction.db.find(
        book.session,
        where: (t) => t.recurringTransactionId.equals(created.id),
      );
      expect(posted, hasLength(1));
      expect(posted.single.externalId, startsWith('recurring:'));
      expect(posted.single.amountMinor, -1000);

      await endpoint.delete(book.session, created.id!);

      final retained = await model.Transaction.db.findById(
        book.session,
        posted.single.id!,
      );
      expect(retained, isNotNull);
      expect(retained!.recurringTransactionId, isNull);
      expect(retained.amountMinor, -1000);
      expect(await book.cachedBalanceMinor(checking), -1000);
      expect(await book.recomputedBalanceMinor(checking), -1000);
    });

    test(
      'when skipping then advances one occurrence without posting',
      () async {
        final checking = await account();
        final created = await endpoint.create(
          book.session,
          checking.id!,
          'Rent',
          -1000,
          RecurrenceFrequency.monthly,
          DateTime.utc(2024, 1, 31),
        );

        final skipped = await endpoint.skipOccurrence(
          book.session,
          created.id!,
        );
        expect(skipped.nextDate, DateTime.utc(2024, 2, 29));
        expect(skipped.isActive, isTrue);
        expect(await postedCount(book), 0);
      },
    );

    test(
      'when skipping the final occurrence then endDate deactivates it',
      () async {
        final checking = await account();
        final created = await createDue(
          onAccount: checking,
          endDate: today(),
        );

        final skipped = await endpoint.skipOccurrence(
          book.session,
          created.id!,
        );
        expect(skipped.nextDate.isAfter(today()), isTrue);
        expect(skipped.isActive, isFalse);
        expect(await endpoint.countDue(book.session, book.entity.id!), 0);
        expect(await postedCount(book), 0);
      },
    );

    test(
      'when a leap anchor skips then uses the next calendar occurrence',
      () async {
        final checking = await account();
        final yearly = await endpoint.create(
          book.session,
          checking.id!,
          'Leap fee',
          -1000,
          RecurrenceFrequency.yearly,
          DateTime.utc(2024, 2, 29),
        );

        final skipped = await endpoint.skipOccurrence(book.session, yearly.id!);
        expect(skipped.nextDate, DateTime.utc(2025, 2, 28));
        expect(skipped.isActive, isTrue);
      },
    );

    test(
      'when endDate is the next date then posting deactivates inclusively',
      () async {
        final checking = await account();
        final created = await createDue(
          onAccount: checking,
          endDate: today(),
        );

        expect(await endpoint.postDue(book.session, book.entity.id!), 1);
        final reloaded = await endpoint.get(book.session, created.id!);
        expect(reloaded.isActive, isFalse);
        expect(reloaded.nextDate.isAfter(today()), isTrue);
        expect(await endpoint.countDue(book.session, book.entity.id!), 0);
      },
    );

    test(
      'when isActive is false then due count and posting ignore it',
      () async {
        final checking = await account();
        final created = await createDue(onAccount: checking);
        expect(await endpoint.countDue(book.session, book.entity.id!), 1);

        await endpoint.update(book.session, created.id!, isActive: false);
        expect(await endpoint.countDue(book.session, book.entity.id!), 0);
        expect(await endpoint.postDue(book.session, book.entity.id!), 0);
        expect(await postedCount(book), 0);

        await endpoint.update(book.session, created.id!, isActive: true);
        expect(await endpoint.countDue(book.session, book.entity.id!), 1);
        expect(await endpoint.postDue(book.session, book.entity.id!), 1);
      },
    );

    test('when nextDate is far in the future then the schedule is allowed '
        'but not due', () async {
      final checking = await account();
      final future = today().add(const Duration(days: 30));
      final created = await createDue(onAccount: checking, nextDate: future);

      expect(created.nextDate, future);
      expect(await endpoint.countDue(book.session, book.entity.id!), 0);
      expect(await endpoint.postDue(book.session, book.entity.id!), 0);
      expect(await postedCount(book), 0);
    });

    test('when an unauthenticated caller uses any method then authentication '
        'is required', () async {
      final anonymous = server.anonymousSession();
      addTearDown(anonymous.close);
      final checking = await account();
      final created = await createDue(onAccount: checking);

      await expectLater(
        endpoint.create(
          anonymous,
          checking.id!,
          'Rent',
          -1000,
          RecurrenceFrequency.monthly,
          today(),
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.list(anonymous, book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.get(anonymous, created.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.update(anonymous, created.id!, description: 'Changed'),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.skipOccurrence(anonymous, created.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.postDue(anonymous, book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.countDue(anonymous, book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.delete(anonymous, created.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });

    test('when another owner uses the key then every method denies', () async {
      final otherSession = server.anonymousSession();
      addTearDown(otherSession.close);
      final other = await BudgetTestBook.create(otherSession);
      final otherAccount = await other.addAccount();
      final otherSchedule = await RecurringTransaction.db.insertRow(
        other.session,
        RecurringTransaction(
          entityId: other.entity.id!,
          accountId: otherAccount.id!,
          description: 'Other rent',
          amountMinor: -1000,
          frequency: RecurrenceFrequency.monthly,
          nextDate: EntityClock.today(other.entity),
        ),
      );

      await expectLater(
        endpoint.list(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.get(book.session, otherSchedule.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.update(
          book.session,
          otherSchedule.id!,
          description: 'Hijack',
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.skipOccurrence(book.session, otherSchedule.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.postDue(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.countDue(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(book.session, otherSchedule.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test(
      'when references or dates are invalid then rejects without writes',
      () async {
        final checking = await account();
        final valuation = await account(
          name: 'House',
          balanceSource: AccountBalanceSource.valuations,
        );
        final closed = await account(
          name: 'Closed',
          closedAt: DateTime.utc(2026),
        );
        final otherSession = server.anonymousSession();
        addTearDown(otherSession.close);
        final other = await BudgetTestBook.create(otherSession);
        final otherPayee = await other.addPayee();
        final otherEnvelope = await other.addEnvelope();

        for (final invalid in [
          () => endpoint.create(
            book.session,
            checking.id!,
            '  ',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            0,
            RecurrenceFrequency.monthly,
            today(),
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            maxSafeMinor + 1,
            RecurrenceFrequency.monthly,
            today(),
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            DateTime(2026),
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
            endDate: today().subtract(const Duration(days: 1)),
          ),
          () => endpoint.create(
            book.session,
            valuation.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
          ),
          () => endpoint.create(
            book.session,
            closed.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
            payeeId: otherPayee.id,
          ),
          () => endpoint.create(
            book.session,
            checking.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
            envelopeId: otherEnvelope.id,
          ),
        ]) {
          await expectLater(invalid(), throwsA(isA<Exception>()));
        }

        expect(await endpoint.list(book.session, book.entity.id!), isEmpty);
        expect(await postedCount(book), 0);
      },
    );

    test(
      'when the entity is archived then writes reject but reads still work',
      () async {
        final archived = await book.addEntity(
          archivedAt: DateTime.utc(2026),
        );
        final archivedAccount = await account(entity: archived);

        await expectLater(
          endpoint.create(
            book.session,
            archivedAccount.id!,
            'Rent',
            -1000,
            RecurrenceFrequency.monthly,
            today(),
          ),
          throwsA(isA<ValidationException>()),
        );

        final schedule = await RecurringTransaction.db.insertRow(
          book.session,
          RecurringTransaction(
            entityId: archived.id!,
            accountId: archivedAccount.id!,
            description: 'Archived rent',
            amountMinor: -1000,
            frequency: RecurrenceFrequency.monthly,
            nextDate: today(),
          ),
        );
        expect(
          (await endpoint.get(book.session, schedule.id!)).id,
          schedule.id,
        );
        await expectLater(
          endpoint.update(book.session, schedule.id!, description: 'Changed'),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoint.delete(book.session, schedule.id!),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
