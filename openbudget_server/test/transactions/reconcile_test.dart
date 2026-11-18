// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

final _date = DateTime.utc(2026, 3, 10);

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late TransactionEndpoint endpoint;
  late List<EntityChangedEvent> events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = [];
    TransactionWriter.debugPublisher =
        (session, entityId, scope, {month, accountId}) async {
          events.add(
            EntityChangedEvent(
              entityId: entityId,
              scope: scope,
              month: month,
              accountId: accountId,
            ),
          );
        };
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    endpoint = TransactionEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    FxService.resetForTests();
  });

  TransactionInput entry(
    Account account, {
    int amountMinor = -1000,
    DateTime? date,
    String? fxRate,
    TransactionStatus status = TransactionStatus.uncleared,
  }) => TransactionInput(
    accountId: account.id!,
    date: date ?? _date,
    amountMinor: amountMinor,
    fxRate: fxRate,
    status: status,
    lines: const [],
  );

  Future<model.Transaction> seed(
    Account account, {
    int amountMinor = -1000,
    DateTime? date,
    String? fxRate,
    TransactionStatus status = TransactionStatus.uncleared,
  }) async {
    final view = await TransactionWriter.create(
      book.session,
      entry(
        account,
        amountMinor: amountMinor,
        date: date,
        fxRate: fxRate,
        status: status,
      ),
    );
    return view.transaction;
  }

  Future<List<model.Transaction>> rowsFor(Account account) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(account.id),
      );

  Future<List<model.Transaction>> adjustments(Account account) async {
    final rows = await rowsFor(account);
    return [
      for (final row in rows)
        if (row.kind == TransactionKind.balanceAdjustment) row,
    ];
  }

  Future<List<TransactionLine>> linesOf(UuidValue transactionId) =>
      TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.equals(transactionId),
        orderByList: (t) => [t.sortOrder, t.id],
      );

  Future<List<AuditEvent>> auditsOf(Entity entity) => AuditEvent.db.find(
    book.session,
    where: (t) => t.entityId.equals(entity.id),
  );

  group('account and statement boundaries', () {
    test('the endpoint requires login and rejects a foreign owner', () async {
      final account = await book.addAccount();
      final today = EntityClock.today(book.entity);

      expect(endpoint.requireLogin, isTrue);
      await expectLater(
        endpoint.reconcile(
          server.anonymousSession(),
          account.id!,
          today,
          0,
          false,
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );

      final other = await BudgetTestBook.create(server.anonymousSession());
      await expectLater(
        endpoint.reconcile(other.session, account.id!, today, 0, false),
        throwsA(isA<ForbiddenException>()),
      );
      expect((await book.reload(account)).reconciledThroughDate, isNull);
    });

    test('a valuation account is a domain validation error', () async {
      final account = await book.addAccount(
        balanceSource: AccountBalanceSource.valuations,
      );

      await expectLater(
        TransactionWriter.reconcile(book.session, account.id!, _date, 0, false),
        throwsA(isA<ValidationException>()),
      );
      expect((await book.reload(account)).reconciledThroughDate, isNull);
    });

    test(
      'each entity local today is accepted and its tomorrow rejected',
      () async {
        for (final timeZone in ['Pacific/Kiritimati', 'Pacific/Honolulu']) {
          final zoneBook = await BudgetTestBook.create(
            server.anonymousSession(),
            timeZone: timeZone,
          );
          addTearDown(zoneBook.expectBalancesConsistent);
          final account = await zoneBook.addAccount();
          final today = EntityClock.today(zoneBook.entity);

          final result = await TransactionWriter.reconcile(
            zoneBook.session,
            account.id!,
            today,
            0,
            false,
          );
          expect(result.clearedBalanceMinor, 0);
          expect((await zoneBook.reload(account)).reconciledThroughDate, today);

          await expectLater(
            TransactionWriter.reconcile(
              zoneBook.session,
              account.id!,
              today.add(const Duration(days: 1)),
              0,
              false,
            ),
            throwsA(isA<ValidationException>()),
          );
        }
      },
    );

    test('non-civil and pre-1900 statement dates are rejected', () async {
      final account = await book.addAccount();

      await expectLater(
        TransactionWriter.reconcile(
          book.session,
          account.id!,
          DateTime(2026, 3, 10),
          0,
          false,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.reconcile(
          book.session,
          account.id!,
          DateTime.utc(1899, 12, 31),
          0,
          false,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an archived entity allows a preview but rejects a write', () async {
      final archived = await book.addEntity(
        name: 'Archived',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final account = await book.addAccount(entity: archived);

      final preview = await TransactionWriter.reconcile(
        book.session,
        account.id!,
        _date,
        100,
        false,
      );
      expect(preview.clearedBalanceMinor, 0);
      expect(preview.differenceMinor, 100);
      expect(preview.reconciledCount, 0);

      await expectLater(
        TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          100,
          true,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.reconcile(book.session, account.id!, _date, 0, false),
        throwsA(isA<ValidationException>()),
      );
      expect((await book.reload(account)).reconciledThroughDate, isNull);
      expect(events, isEmpty);
    });
  });

  group('cleared balance and status transitions', () {
    test(
      'cleared and reconciled rows through the inclusive date count',
      () async {
        final account = await book.addAccount();
        final reconciledBefore = await seed(
          account,
          amountMinor: 500,
          date: _date.subtract(const Duration(days: 2)),
          status: TransactionStatus.reconciled,
        );
        final clearedBefore = await seed(
          account,
          amountMinor: -1000,
          date: _date.subtract(const Duration(days: 1)),
          status: TransactionStatus.cleared,
        );
        final clearedOn = await seed(
          account,
          amountMinor: -2000,
          status: TransactionStatus.cleared,
        );
        final clearedAfter = await seed(
          account,
          amountMinor: -3000,
          date: _date.add(const Duration(days: 1)),
          status: TransactionStatus.cleared,
        );
        final unclearedOn = await seed(
          account,
          amountMinor: -4000,
          status: TransactionStatus.uncleared,
        );
        events.clear();

        final result = await TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          -2500,
          false,
        );

        expect(result.clearedBalanceMinor, -2500);
        expect(result.differenceMinor, 0);
        expect(result.adjustmentTransactionId, isNull);
        expect(result.reconciledCount, 2);
        expect((await book.reload(account)).reconciledThroughDate, _date);

        expect(
          (await book.transaction(reconciledBefore.id!))!.status,
          TransactionStatus.reconciled,
        );
        expect(
          (await book.transaction(clearedBefore.id!))!.status,
          TransactionStatus.reconciled,
        );
        expect(
          (await book.transaction(clearedOn.id!))!.status,
          TransactionStatus.reconciled,
        );
        expect(
          (await book.transaction(clearedAfter.id!))!.status,
          TransactionStatus.cleared,
        );
        expect(
          (await book.transaction(unclearedOn.id!))!.status,
          TransactionStatus.uncleared,
        );

        expect(events, hasLength(1));
        expect(events.single.entityId, book.entity.id);
        expect(events.single.accountId, account.id);
        expect(events.single.month, 202603);
        expect(events.single.scope, ChangeScope.transactions);
      },
    );

    test('a matching statement writes no adjustment header', () async {
      final account = await book.addAccount();
      await seed(
        account,
        amountMinor: -1000,
        status: TransactionStatus.cleared,
      );
      final baseline = (await rowsFor(account)).length;
      events.clear();

      final result = await TransactionWriter.reconcile(
        book.session,
        account.id!,
        _date,
        -1000,
        true,
      );

      expect(result.clearedBalanceMinor, -1000);
      expect(result.differenceMinor, 0);
      expect(result.adjustmentTransactionId, isNull);
      expect(result.reconciledCount, 1);
      expect((await rowsFor(account)).length, baseline);
      expect(await adjustments(account), isEmpty);
      expect((await book.reload(account)).reconciledThroughDate, _date);
      expect(await book.cachedBalanceMinor(account), -1000);
      expect(await book.recomputedBalanceMinor(account), -1000);
    });

    test(
      'a non-zero difference without an adjustment changes nothing',
      () async {
        final account = await book.addAccount();
        final cleared = await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );
        final current = await book.reload(account);
        await Account.db.updateRow(
          book.session,
          current.copyWith(
            reportedBalanceMinor: -5000,
            reportedBalanceAt: _date,
          ),
        );
        final before = (await book.transaction(cleared.id!))!;
        final beforeAccount = await book.reload(account);
        events.clear();

        final result = await TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          -1200,
          false,
        );

        expect(result.clearedBalanceMinor, -1000);
        expect(result.differenceMinor, -200);
        expect(result.adjustmentTransactionId, isNull);
        expect(result.reconciledCount, 0);

        final after = (await book.transaction(cleared.id!))!;
        final afterAccount = await book.reload(account);
        expect(after.status, TransactionStatus.cleared);
        expect(after.updatedAt, before.updatedAt);
        expect(after.fxRate, before.fxRate);
        expect(after.fxRateSource, before.fxRateSource);
        expect(after.baseAmountMinor, before.baseAmountMinor);
        expect(after.revision, before.revision);
        expect(afterAccount.reconciledThroughDate, isNull);
        expect(afterAccount.updatedAt, beforeAccount.updatedAt);
        expect(afterAccount.balanceMinor, -1000);
        expect(afterAccount.reportedBalanceMinor, -5000);
        expect(await adjustments(account), isEmpty);
        expect(await auditsOf(book.entity), isEmpty);
        expect(events, isEmpty);
      },
    );

    test(
      'a caller rollback leaves rows, through date and events untouched',
      () async {
        final account = await book.addAccount();
        final cleared = await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );
        events.clear();

        await expectLater(
          TransactionWriter.inTransaction(book.session, (tx) async {
            await TransactionWriter.reconcile(
              book.session,
              account.id!,
              _date,
              -500,
              true,
              transaction: tx,
            );
            throw StateError('roll back');
          }),
          throwsA(isA<StateError>()),
        );

        expect(await adjustments(account), isEmpty);
        expect(
          (await book.transaction(cleared.id!))!.status,
          TransactionStatus.cleared,
        );
        expect((await book.reload(account)).reconciledThroughDate, isNull);
        expect(await book.cachedBalanceMinor(account), -1000);
        expect(await auditsOf(book.entity), isEmpty);
        expect(events, isEmpty);
      },
    );
  });

  group('adjustments', () {
    test(
      'a positive difference increases the cache on one uncategorized line',
      () async {
        final account = await book.addAccount();
        final cleared = await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );
        final baseline = (await rowsFor(account)).length;
        events.clear();

        final result = await TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          500,
          true,
        );

        expect(result.clearedBalanceMinor, -1000);
        expect(result.differenceMinor, 1500);
        expect(result.adjustmentTransactionId, isNotNull);
        expect(result.reconciledCount, 2);
        expect((await rowsFor(account)).length, baseline + 1);

        final adjustment = (await book.transaction(
          result.adjustmentTransactionId!,
        ))!;
        expect(adjustment.kind, TransactionKind.balanceAdjustment);
        expect(adjustment.accountId, account.id);
        expect(adjustment.entityId, book.entity.id);
        expect(adjustment.date, _date);
        expect(adjustment.amountMinor, 1500);
        expect(adjustment.baseAmountMinor, 1500);
        expect(adjustment.fxRate, '1');
        expect(adjustment.fxRateSource, FxRateSource.identity);
        expect(adjustment.status, TransactionStatus.reconciled);
        expect(adjustment.revision, 0);
        expect(adjustment.description, 'Reconciliation adjustment');

        final lines = await linesOf(adjustment.id!);
        expect(lines, hasLength(1));
        expect(lines.single.amountMinor, 1500);
        expect(lines.single.baseAmountMinor, 1500);
        expect(lines.single.envelopeId, isNull);
        expect(lines.single.sortOrder, 0);

        expect(
          (await book.transaction(cleared.id!))!.status,
          TransactionStatus.reconciled,
        );
        expect(await book.cachedBalanceMinor(account), 500);
        expect(await book.recomputedBalanceMinor(account), 500);
        expect((await book.reload(account)).reconciledThroughDate, _date);
        expect(events, hasLength(1));
        expect(events.single.accountId, account.id);
        expect(events.single.month, 202603);
        expect(events.single.scope, ChangeScope.transactions);
      },
    );

    test('a negative difference decreases the cache', () async {
      final account = await book.addAccount();
      await seed(
        account,
        amountMinor: -1000,
        status: TransactionStatus.cleared,
      );

      final result = await TransactionWriter.reconcile(
        book.session,
        account.id!,
        _date,
        -2500,
        true,
      );

      expect(result.clearedBalanceMinor, -1000);
      expect(result.differenceMinor, -1500);
      expect(result.reconciledCount, 2);
      final adjustment = (await book.transaction(
        result.adjustmentTransactionId!,
      ))!;
      expect(adjustment.amountMinor, -1500);
      expect((await linesOf(adjustment.id!)).single.amountMinor, -1500);
      expect(await book.cachedBalanceMinor(account), -2500);
      expect(await book.recomputedBalanceMinor(account), -2500);
    });

    test(
      'a foreign adjustment uses the real rate and keeps old FX history',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');
        await book.seedMarketRate(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          rateDate: _date,
          fromPerUsd: '1',
          toPerUsd: '0.8',
        );
        final cleared = await seed(
          account,
          amountMinor: -10000,
          fxRate: '0.75',
          status: TransactionStatus.cleared,
        );

        final result = await TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          -9000,
          true,
        );

        expect(result.differenceMinor, 1000);
        final adjustment = (await book.transaction(
          result.adjustmentTransactionId!,
        ))!;
        expect(adjustment.fxRate, '0.8');
        expect(adjustment.fxRateDate, _date);
        expect(adjustment.fxRateSource, FxRateSource.market);
        expect(adjustment.baseAmountMinor, 800);
        final lines = await linesOf(adjustment.id!);
        expect(lines.single.baseAmountMinor, 800);
        expect(await book.cachedBalanceMinor(account), -9000);

        final historical = (await book.transaction(cleared.id!))!;
        expect(historical.amountMinor, -10000);
        expect(historical.fxRate, '0.75');
        expect(historical.fxRateSource, FxRateSource.manual);
        expect(historical.baseAmountMinor, -7500);
      },
    );

    test('a missing rate rolls back the adjustment and every status', () async {
      final account = await book.addAccount(currencyCode: 'USD');
      final cleared = await seed(
        account,
        amountMinor: -10000,
        fxRate: '0.9',
        status: TransactionStatus.cleared,
      );
      await server.clearRates();
      events.clear();

      await expectLater(
        TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          -9000,
          true,
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );

      expect(await adjustments(account), isEmpty);
      expect(
        (await book.transaction(cleared.id!))!.status,
        TransactionStatus.cleared,
      );
      expect((await book.reload(account)).reconciledThroughDate, isNull);
      expect(await book.cachedBalanceMinor(account), -10000);
      expect(events, isEmpty);
    });

    test(
      'a closed account rejects only the adjustment it would create',
      () async {
        final account = await book.addAccount();
        final cleared = await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );
        final closed = await book.reload(account);
        await Account.db.updateRow(
          book.session,
          closed.copyWith(closedAt: DateTime.utc(2026, 3, 11)),
        );
        events.clear();

        await expectLater(
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            -500,
            true,
          ),
          throwsA(isA<ValidationException>()),
        );

        expect(await adjustments(account), isEmpty);
        expect(
          (await book.transaction(cleared.id!))!.status,
          TransactionStatus.cleared,
        );
        expect((await book.reload(account)).reconciledThroughDate, isNull);
        expect(events, isEmpty);
      },
    );

    test(
      'a period lock rejects the dated adjustment but allows the match',
      () async {
        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        addTearDown(ledgerBook.expectBalancesConsistent);
        final account = await ledgerBook.addAccount();
        final cleared = await TransactionWriter.create(
          ledgerBook.session,
          TransactionInput(
            accountId: account.id!,
            date: _date,
            amountMinor: -1000,
            status: TransactionStatus.cleared,
            lines: const [],
          ),
        );
        await ledgerBook.addPeriodLock(_date);
        events.clear();

        await expectLater(
          TransactionWriter.reconcile(
            ledgerBook.session,
            account.id!,
            _date,
            -500,
            true,
          ),
          throwsA(isA<ValidationException>()),
        );

        expect(
          await model.Transaction.db.find(
            ledgerBook.session,
            where: (t) => t.accountId.equals(account.id),
          ),
          hasLength(1),
        );
        expect(
          (await ledgerBook.transaction(cleared.transaction.id!))!.status,
          TransactionStatus.cleared,
        );
        expect(
          (await ledgerBook.reload(account)).reconciledThroughDate,
          isNull,
        );

        final matched = await TransactionWriter.reconcile(
          ledgerBook.session,
          account.id!,
          _date,
          -1000,
          false,
        );
        expect(matched.reconciledCount, 1);
        expect(
          (await ledgerBook.transaction(cleared.transaction.id!))!.status,
          TransactionStatus.reconciled,
        );
      },
    );

    test('a safe difference cannot overflow the cached balance', () async {
      final account = await book.addAccount();
      const half = maxSafeMinor ~/ 2;
      await seed(account, amountMinor: half, status: TransactionStatus.cleared);
      await seed(
        account,
        amountMinor: -half,
        status: TransactionStatus.cleared,
      );
      await seed(
        account,
        amountMinor: maxSafeMinor,
        status: TransactionStatus.uncleared,
      );
      expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      events.clear();

      await expectLater(
        TransactionWriter.reconcile(
          book.session,
          account.id!,
          _date,
          maxSafeMinor,
          true,
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await adjustments(account), isEmpty);
      expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      expect((await book.reload(account)).reconciledThroughDate, isNull);
      expect(events, isEmpty);
    });

    test(
      'a statement or difference beyond the safe range is rejected',
      () async {
        final account = await book.addAccount();

        await expectLater(
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            maxSafeMinor + 1,
            true,
          ),
          throwsA(isA<ValidationException>()),
        );

        final cleared = await seed(
          account,
          amountMinor: maxSafeMinor,
          status: TransactionStatus.cleared,
        );

        await expectLater(
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            -maxSafeMinor,
            true,
          ),
          throwsA(isA<ValidationException>()),
        );

        expect(await adjustments(account), isEmpty);
        expect(
          (await book.transaction(cleared.id!))!.status,
          TransactionStatus.cleared,
        );
        expect((await book.reload(account)).reconciledThroughDate, isNull);
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      },
    );
  });

  group('selection, repetition and concurrency', () {
    test('only the selected transfer leg becomes reconciled', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final legs = await TransactionWriter.createTransfer(
        book.session,
        TransferInput(
          fromAccountId: from.id!,
          toAccountId: to.id!,
          date: _date,
          fromAmountMinor: 500,
          status: TransactionStatus.cleared,
        ),
      );
      final fromLeg = legs[0].transaction;
      final toLeg = legs[1].transaction;
      events.clear();

      final result = await TransactionWriter.reconcile(
        book.session,
        from.id!,
        _date,
        -500,
        false,
      );

      expect(result.clearedBalanceMinor, -500);
      expect(result.differenceMinor, 0);
      expect(result.reconciledCount, 1);
      expect(
        (await book.transaction(fromLeg.id!))!.status,
        TransactionStatus.reconciled,
      );
      expect(
        (await book.transaction(toLeg.id!))!.status,
        TransactionStatus.cleared,
      );
      expect((await book.reload(from)).reconciledThroughDate, _date);
      expect((await book.reload(to)).reconciledThroughDate, isNull);
      expect(events, hasLength(1));
      expect(events.single.accountId, from.id);
    });

    test('a repeated reconciliation never duplicates the adjustment', () async {
      final account = await book.addAccount();
      await seed(
        account,
        amountMinor: -1000,
        status: TransactionStatus.cleared,
      );

      final first = await TransactionWriter.reconcile(
        book.session,
        account.id!,
        _date,
        -500,
        true,
      );
      expect(first.reconciledCount, 2);
      expect(await adjustments(account), hasLength(1));
      expect((await rowsFor(account)).length, 2);
      events.clear();

      final second = await TransactionWriter.reconcile(
        book.session,
        account.id!,
        _date,
        -500,
        true,
      );

      expect(second.clearedBalanceMinor, -500);
      expect(second.differenceMinor, 0);
      expect(second.adjustmentTransactionId, isNull);
      expect(second.reconciledCount, 0);
      expect(await adjustments(account), hasLength(1));
      expect((await rowsFor(account)).length, 2);
      expect((await book.reload(account)).reconciledThroughDate, _date);
      expect(events, isEmpty);
    });

    test(
      'concurrent reconciles write one adjustment without deadlock',
      () async {
        final account = await book.addAccount();
        await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );

        final results = await Future.wait([
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            -500,
            true,
          ),
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            -500,
            true,
          ),
        ]);

        expect(
          results.where((result) => result.adjustmentTransactionId != null),
          hasLength(1),
        );
        expect(await adjustments(account), hasLength(1));
        expect(await book.cachedBalanceMinor(account), -500);
        expect(await book.recomputedBalanceMinor(account), -500);
        expect((await book.reload(account)).reconciledThroughDate, _date);
      },
    );

    test(
      'a reconcile and writers share the account lock without deadlock',
      () async {
        final account = await book.addAccount();
        await seed(
          account,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
        );

        await Future.wait([
          TransactionWriter.reconcile(
            book.session,
            account.id!,
            _date,
            -500,
            true,
          ),
          for (var index = 0; index < 5; index++)
            TransactionWriter.create(
              book.session,
              entry(
                account,
                amountMinor: -100,
                status: TransactionStatus.cleared,
              ),
            ),
        ]);

        expect(await adjustments(account), hasLength(1));
        expect(
          await book.cachedBalanceMinor(account),
          await book.recomputedBalanceMinor(account),
        );
      },
    );
  });

  group('ledger behaviour', () {
    test('status changes keep revisions and write no audit', () async {
      final ledgerBook = await BudgetTestBook.create(
        server.anonymousSession(),
        accountingMode: AccountingMode.ledger,
      );
      addTearDown(ledgerBook.expectBalancesConsistent);
      final account = await ledgerBook.addAccount();
      final cleared = await TransactionWriter.create(
        ledgerBook.session,
        TransactionInput(
          accountId: account.id!,
          date: _date,
          amountMinor: -1000,
          status: TransactionStatus.cleared,
          lines: const [],
        ),
      );

      final result = await TransactionWriter.reconcile(
        ledgerBook.session,
        account.id!,
        _date,
        -500,
        true,
      );

      expect(
        (await ledgerBook.transaction(cleared.transaction.id!))!.revision,
        0,
      );
      expect(
        (await ledgerBook.transaction(result.adjustmentTransactionId!))!
            .revision,
        0,
      );
      expect(
        await AuditEvent.db.find(
          ledgerBook.session,
          where: (t) => t.entityId.equals(ledgerBook.entity.id),
        ),
        isEmpty,
      );
    });
  });
}
