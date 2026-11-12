// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

final _date = DateTime.utc(2026, 3, 10);

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
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
    List<TransactionLineInput> lines = const [],
    String description = '',
    String? memo,
    TransactionStatus status = TransactionStatus.uncleared,
    TransactionFlag? flag,
    UuidValue? payeeId,
    String? payeeName,
    String? fxRate,
  }) => TransactionInput(
    accountId: account.id!,
    date: date ?? _date,
    amountMinor: amountMinor,
    fxRate: fxRate,
    payeeId: payeeId,
    payeeName: payeeName,
    description: description,
    memo: memo,
    status: status,
    flag: flag,
    lines: lines,
  );

  Future<TransactionView> add(
    Account account, {
    int amountMinor = -1000,
    DateTime? date,
    List<TransactionLineInput> lines = const [],
    String description = '',
    String? memo,
    TransactionStatus status = TransactionStatus.uncleared,
    TransactionFlag? flag,
    UuidValue? payeeId,
    String? payeeName,
    String? fxRate,
  }) => TransactionService.create(
    book.session,
    entry(
      account,
      amountMinor: amountMinor,
      date: date,
      lines: lines,
      description: description,
      memo: memo,
      status: status,
      flag: flag,
      payeeId: payeeId,
      payeeName: payeeName,
      fxRate: fxRate,
    ),
  );

  Future<List<model.Transaction>> transactionsOf(UuidValue accountId) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(accountId),
      );

  Future<TransactionPage> page({
    UuidValue? entityId,
    UuidValue? accountId,
    UuidValue? envelopeId,
    UuidValue? payeeId,
    DateTime? fromDate,
    DateTime? toDate,
    TransactionStatus? status,
    bool uncategorizedOnly = false,
    String? search,
    int limit = 50,
    String? cursor,
  }) => TransactionService.list(
    book.session,
    TransactionQuery(
      entityId: entityId ?? book.entity.id!,
      accountId: accountId,
      envelopeId: envelopeId,
      payeeId: payeeId,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      uncategorizedOnly: uncategorizedOnly,
      search: search,
      limit: limit,
      cursor: cursor,
    ),
  );

  String cursorOf(String text) =>
      base64Url.encode(utf8.encode(text)).replaceAll('=', '');

  group('list', () {
    test('pages equal dates stably by (date desc, id desc)', () async {
      final account = await book.addAccount();
      for (var index = 0; index < 7; index++) {
        await add(account, description: 'Row $index');
      }
      final stored = await transactionsOf(account.id!);
      final expected = stored.map((row) => row.id!.uuid).toList()
        ..sort((a, b) => b.compareTo(a));

      final walked = <String>[];
      String? cursor;
      var pages = 0;
      while (true) {
        final result = await page(
          accountId: account.id,
          limit: 2,
          cursor: cursor,
        );
        expect(result.items.length, lessThanOrEqualTo(2));
        for (final item in result.items) {
          expect(walked, isNot(contains(item.transaction.id!.uuid)));
          walked.add(item.transaction.id!.uuid);
        }
        pages++;
        expect(pages, lessThan(10));
        cursor = result.nextCursor;
        if (cursor == null) break;
      }

      expect(pages, 4);
      expect(walked, expected);

      final repeated = <String>[];
      cursor = null;
      while (true) {
        final result = await page(
          accountId: account.id,
          limit: 3,
          cursor: cursor,
        );
        repeated.addAll(
          result.items.map((item) => item.transaction.id!.uuid),
        );
        cursor = result.nextCursor;
        if (cursor == null) break;
      }
      expect(repeated, expected);
    });

    test('returns one row for a split transaction with many lines', () async {
      final account = await book.addAccount();
      final envelope = await book.addEnvelope();
      final created = await add(
        account,
        amountMinor: -600,
        lines: [
          TransactionLineInput(amountMinor: -100, memo: 'A'),
          TransactionLineInput(amountMinor: -200, memo: 'B'),
          TransactionLineInput(
            amountMinor: -300,
            envelopeId: envelope.id,
            memo: 'C',
          ),
        ],
      );

      final result = await page(accountId: account.id);
      expect(result.items, hasLength(1));
      expect(result.items.single.transaction.id, created.transaction.id);
      expect(result.items.single.lines, hasLength(3));
      expect(result.nextCursor, isNull);
    });

    test(
      'applies account, envelope, payee, status and inclusive dates',
      () async {
        final first = await book.addAccount(name: 'First');
        final second = await book.addAccount(name: 'Second');
        final firstEnvelope = await book.addEnvelope(name: 'One');
        final secondEnvelope = await book.addEnvelope(name: 'Two');
        final payee = await book.addPayee(name: 'Shop');

        final nine = DateTime.utc(2026, 3, 9);
        final ten = DateTime.utc(2026, 3, 10);
        await add(
          first,
          date: nine,
          description: 'Nine',
          status: TransactionStatus.cleared,
          payeeId: payee.id,
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: firstEnvelope.id,
            ),
          ],
        );
        await add(
          first,
          date: ten,
          description: 'Ten',
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: secondEnvelope.id,
            ),
          ],
        );
        await add(
          second,
          date: ten,
          description: 'Second ten',
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: firstEnvelope.id,
            ),
          ],
        );

        expect(
          (await page(accountId: first.id)).items.map(
            (item) => item.transaction.description,
          ),
          unorderedEquals(['Nine', 'Ten']),
        );
        expect(
          (await page(envelopeId: firstEnvelope.id)).items.map(
            (item) => item.transaction.description,
          ),
          unorderedEquals(['Nine', 'Second ten']),
        );
        expect(
          (await page(payeeId: payee.id)).items.single.transaction.description,
          'Nine',
        );
        expect(
          (await page(status: TransactionStatus.cleared))
              .items
              .single
              .transaction
              .description,
          'Nine',
        );
        expect(
          (await page(fromDate: ten, toDate: ten)).items.map(
            (item) => item.transaction.description,
          ),
          unorderedEquals(['Ten', 'Second ten']),
        );
        expect(
          (await page(
            fromDate: nine,
            toDate: nine,
          )).items.single.transaction.description,
          'Nine',
        );
        expect(
          (await page(
            accountId: first.id,
            fromDate: nine,
            toDate: ten,
          )).items.map((item) => item.transaction.description),
          unorderedEquals(['Nine', 'Ten']),
        );
      },
    );

    test(
      'searches description, memo and payee name case-insensitively',
      () async {
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Coffee Shop');
        await add(account, description: 'COFFEE beans');
        await add(account, description: 'Tea', memo: 'coffee with milk');
        await add(account, description: 'Water', payeeId: payee.id);

        final matches = await page(search: 'coffee');
        expect(matches.items, hasLength(3));
        expect((await page(search: 'COFFEE')).items, hasLength(3));
        expect((await page(search: 'tea')).items, hasLength(1));
      },
    );

    test('escapes LIKE metacharacters so they match literally', () async {
      final account = await book.addAccount();
      await add(account, description: '100% cocoa');
      await add(account, description: '100x cocoa');
      await add(account, description: 'a_b');
      await add(account, description: 'axb');
      await add(account, description: r'back\slash');
      await add(account, description: 'backslash');

      expect(
        (await page(search: '%')).items.single.transaction.description,
        '100% cocoa',
      );
      expect(
        (await page(search: '100%')).items.single.transaction.description,
        '100% cocoa',
      );
      expect(
        (await page(search: '_')).items.single.transaction.description,
        'a_b',
      );
      expect(
        (await page(search: 'a_b')).items.single.transaction.description,
        'a_b',
      );
      expect(
        (await page(search: r'\')).items.single.transaction.description,
        r'back\slash',
      );
      expect((await page(search: 'back')).items, hasLength(2));
    });

    test(
      'uncategorizedOnly keeps on-budget outflows and skips internal transfers',
      () async {
        final onBudget = await book.addAccount(name: 'On budget');
        final secondBudget = await book.addAccount(name: 'Second budget');
        final offBudget = await book.addAccount(
          name: 'Off budget',
          onBudget: false,
        );
        final envelope = await book.addEnvelope();

        await add(
          onBudget,
          amountMinor: -500,
          description: 'Uncategorized outflow',
        );
        await add(
          onBudget,
          amountMinor: 500,
          description: 'Uncategorized inflow',
        );
        await add(
          onBudget,
          amountMinor: -500,
          description: 'Categorized outflow',
          lines: [
            TransactionLineInput(amountMinor: -500, envelopeId: envelope.id),
          ],
        );
        await add(
          offBudget,
          amountMinor: -500,
          description: 'Off budget outflow',
        );
        await TransactionService.createTransfer(
          book.session,
          TransferInput(
            fromAccountId: onBudget.id!,
            toAccountId: secondBudget.id!,
            date: _date,
            fromAmountMinor: 400,
            memo: 'internal',
          ),
        );
        await TransactionService.createTransfer(
          book.session,
          TransferInput(
            fromAccountId: onBudget.id!,
            toAccountId: offBudget.id!,
            date: _date,
            fromAmountMinor: 300,
            memo: 'external',
          ),
        );

        final result = await page(uncategorizedOnly: true);
        final labels = result.items
            .map(
              (item) => item.transaction.memo ?? item.transaction.description,
            )
            .toList();
        expect(labels, unorderedEquals(['Uncategorized outflow', 'external']));
      },
    );

    test('validates references, limits, dates and cursors', () async {
      final account = await book.addAccount();
      await add(account);
      final other = await BudgetTestBook.create(server.anonymousSession());
      final otherAccount = await other.addAccount();
      final otherEnvelope = await other.addEnvelope();
      final otherPayee = await other.addPayee();

      await expectLater(
        page(accountId: otherAccount.id),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        page(envelopeId: otherEnvelope.id),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        page(payeeId: otherPayee.id),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        page(entityId: other.entity.id),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        page(limit: 0),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        page(limit: 201),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        page(fromDate: DateTime(2026, 3, 10)),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        page(toDate: DateTime.utc(2026, 3, 10, 1)),
        throwsA(isA<ValidationException>()),
      );

      final badCursors = [
        '',
        'not-base64!!',
        cursorOf('not-a-cursor'),
        cursorOf('2026-02-30|${const Uuid().v7()}'),
        cursorOf('2026-03-10|not-a-uuid'),
        cursorOf('1899-03-10|${const Uuid().v7()}'),
        'a' * 101,
      ];
      for (final cursor in badCursors) {
        await expectLater(
          page(cursor: cursor),
          throwsA(isA<ValidationException>()),
          reason: 'cursor "$cursor"',
        );
      }

      final valid = await page(
        cursor: cursorOf('2026-03-01|${const Uuid().v7()}'),
      );
      expect(valid.items, isEmpty);
      expect(valid.nextCursor, isNull);
    });

    test('builds views with a bounded number of relation queries', () async {
      final account = await book.addAccount();
      final peer = await book.addAccount(name: 'Peer');
      final envelope = await book.addEnvelope();
      final payee = await book.addPayee(name: 'Bounded');
      for (var index = 0; index < 20; index++) {
        await add(
          account,
          amountMinor: -100,
          description: 'Row $index',
          payeeId: payee.id,
          lines: [
            TransactionLineInput(amountMinor: -50, envelopeId: envelope.id),
            TransactionLineInput(amountMinor: -50),
          ],
        );
      }
      for (var index = 0; index < 10; index++) {
        await TransactionService.createTransfer(
          book.session,
          TransferInput(
            fromAccountId: account.id!,
            toAccountId: peer.id!,
            date: _date,
            fromAmountMinor: 100,
          ),
        );
      }

      final rows = await model.Transaction.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(rows, hasLength(40));

      TransactionWriter.resetDebugViewBatchQueryCount();
      final many = await TransactionWriter.views(book.session, rows);
      final manyQueries = TransactionWriter.debugViewBatchQueryCount;
      expect(many, hasLength(40));

      TransactionWriter.resetDebugViewBatchQueryCount();
      final one = await TransactionWriter.views(book.session, [rows.first]);
      final oneQueries = TransactionWriter.debugViewBatchQueryCount;
      expect(one, hasLength(1));

      expect(manyQueries, lessThanOrEqualTo(6));
      expect(oneQueries, lessThanOrEqualTo(6));
      expect(manyQueries, lessThan(rows.length));
    });
  });

  group('findDuplicates', () {
    test('matches the same signed amount within three civil days', () async {
      final account = await book.addAccount();
      final other = await book.addAccount(name: 'Other');
      for (final offset in [-4, -3, -2, 0, 2, 3, 4]) {
        await add(
          account,
          amountMinor: -500,
          date: _date.add(Duration(days: offset)),
          description: 'offset $offset',
        );
      }
      await add(account, amountMinor: -501, description: 'near miss');
      await add(other, amountMinor: -500, description: 'other account');

      final matches = await TransactionService.findDuplicates(
        book.session,
        account.id!,
        _date,
        -500,
      );
      expect(
        matches.map((view) => view.transaction.description),
        ['offset 3', 'offset 2', 'offset 0', 'offset -2', 'offset -3'],
      );

      expect(
        await TransactionService.findDuplicates(
          book.session,
          account.id!,
          _date,
          500,
        ),
        isEmpty,
      );
    });

    test('is bounded, ownership checked and date validated', () async {
      final account = await book.addAccount();
      for (var index = 0; index < 25; index++) {
        await add(account, amountMinor: -700, description: 'match $index');
      }

      final matches = await TransactionService.findDuplicates(
        book.session,
        account.id!,
        _date,
        -700,
      );
      expect(matches, hasLength(TransactionService.maxDuplicateMatches));

      await expectLater(
        TransactionService.findDuplicates(
          book.session,
          account.id!,
          DateTime(2026, 3, 10),
          -700,
        ),
        throwsA(isA<ValidationException>()),
      );

      final other = await BudgetTestBook.create(server.anonymousSession());
      final otherAccount = await other.addAccount();
      await expectLater(
        TransactionService.findDuplicates(
          book.session,
          otherAccount.id!,
          _date,
          -700,
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('bulk metadata', () {
    test(
      'setStatus counts unique changed rows and preserves money and FX',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');
        final first = await add(
          account,
          amountMinor: -1000,
          description: 'First',
          fxRate: '0.8',
        );
        final second = await add(
          account,
          amountMinor: -500,
          description: 'Second',
          fxRate: '0.8',
        );
        final before = await transactionsOf(account.id!);
        expect(before.map((row) => row.baseAmountMinor), [-800, -400]);
        final balanceBefore = await book.cachedBalanceMinor(account);
        final revisionBefore = {
          for (final row in before) row.id!: row.revision,
        };
        events.clear();

        final changed = await TransactionService.setStatus(
          book.session,
          [
            first.transaction.id!,
            second.transaction.id!,
            first.transaction.id!,
          ],
          TransactionStatus.cleared,
        );
        expect(changed, 2);
        expect(
          await TransactionService.setStatus(
            book.session,
            [first.transaction.id!],
            TransactionStatus.cleared,
          ),
          0,
        );

        final after = await transactionsOf(account.id!);
        for (final row in after) {
          expect(row.status, TransactionStatus.cleared);
          expect(row.fxRate, '0.8');
          expect(row.fxRateSource, FxRateSource.manual);
          expect(row.fxRateDate, _date);
          expect(row.revision, revisionBefore[row.id]);
          expect(
            row.baseAmountMinor,
            before.firstWhere((old) => old.id == row.id).baseAmountMinor,
          );
        }
        expect(await book.cachedBalanceMinor(account), balanceBefore);
        expect(events, hasLength(1));
        expect(events.single.scope, ChangeScope.transactions);
        expect(events.single.month, 202603);
        expect(events.single.accountId, account.id);
      },
    );

    test(
      'setStatus unlocks a reconciled row without re-pricing or re-balancing',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');
        final created = await add(
          account,
          amountMinor: -1000,
          fxRate: '0.8',
          description: 'Reconciled',
        );
        final row = await book.transaction(created.transaction.id!);
        await model.Transaction.db.updateRow(
          book.session,
          row!.copyWith(status: TransactionStatus.reconciled),
        );
        final balance = await book.cachedBalanceMinor(account);

        expect(
          await TransactionService.setStatus(
            book.session,
            [created.transaction.id!],
            TransactionStatus.cleared,
          ),
          1,
        );

        final unlocked = await book.transaction(created.transaction.id!);
        expect(unlocked!.status, TransactionStatus.cleared);
        expect(unlocked.amountMinor, -1000);
        expect(unlocked.baseAmountMinor, -800);
        expect(unlocked.fxRate, '0.8');
        expect(unlocked.fxRateDate, _date);
        expect(unlocked.fxRateSource, FxRateSource.manual);
        expect(await book.cachedBalanceMinor(account), balance);
      },
    );

    test(
      'setStatus rejects reconciled forgery and empty ids is a no-op',
      () async {
        final account = await book.addAccount();
        final created = await add(account);

        await expectLater(
          TransactionService.setStatus(
            book.session,
            [created.transaction.id!],
            TransactionStatus.reconciled,
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(
          (await book.transaction(created.transaction.id!))!.status,
          TransactionStatus.uncleared,
        );

        events.clear();
        expect(
          await TransactionService.setStatus(
            book.session,
            const [],
            TransactionStatus.cleared,
          ),
          0,
        );
        expect(events, isEmpty);
      },
    );

    test('one foreign row rejects the whole bulk change', () async {
      final account = await book.addAccount();
      final own = await add(account, description: 'Own');
      final other = await BudgetTestBook.create(server.anonymousSession());
      final otherAccount = await other.addAccount();
      final foreign = await TransactionService.create(
        other.session,
        TransactionInput(
          accountId: otherAccount.id!,
          date: _date,
          amountMinor: -1000,
          description: 'Foreign',
          lines: const [],
        ),
      );
      events.clear();

      await expectLater(
        TransactionService.setStatus(
          book.session,
          [own.transaction.id!, foreign.transaction.id!],
          TransactionStatus.cleared,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        TransactionService.setFlag(
          book.session,
          [own.transaction.id!, foreign.transaction.id!],
          TransactionFlag.green,
        ),
        throwsA(isA<NotFoundException>()),
      );

      expect(
        (await book.transaction(own.transaction.id!))!.status,
        TransactionStatus.uncleared,
      );
      expect(
        (await book.transaction(own.transaction.id!))!.flag,
        isNull,
      );
      expect(
        (await other.transaction(foreign.transaction.id!))!.status,
        TransactionStatus.uncleared,
      );
      expect(events, isEmpty);
    });

    test('caps a bulk request at one page', () async {
      final ids = [
        for (var index = 0; index < 201; index++) const Uuid().v7obj(),
      ];
      await expectLater(
        TransactionService.setStatus(
          book.session,
          ids,
          TransactionStatus.cleared,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('setFlag sets and clears the colour without changing money', () async {
      final account = await book.addAccount();
      final first = await add(account, amountMinor: -400);
      final second = await add(account, amountMinor: -600);
      final ids = [first.transaction.id!, second.transaction.id!];
      final balance = await book.cachedBalanceMinor(account);
      events.clear();

      expect(
        await TransactionService.setFlag(
          book.session,
          ids,
          TransactionFlag.blue,
        ),
        2,
      );
      expect(
        (await transactionsOf(account.id!)).map((row) => row.flag),
        everyElement(TransactionFlag.blue),
      );
      expect(await book.cachedBalanceMinor(account), balance);
      expect(events, hasLength(1));

      expect(await TransactionService.setFlag(book.session, ids, null), 2);
      expect(
        (await transactionsOf(account.id!)).map((row) => row.flag),
        everyElement(isNull),
      );
      expect(await book.cachedBalanceMinor(account), balance);
      expect(await TransactionService.setFlag(book.session, ids, null), 0);
    });

    test('publishes scoped changes only after commit', () async {
      final account = await book.addAccount();
      final march = await add(account, date: _date, description: 'March');
      final february = await add(
        account,
        date: DateTime.utc(2026, 2, 10),
        description: 'February',
      );
      events.clear();

      expect(
        await TransactionService.setStatus(
          book.session,
          [march.transaction.id!, february.transaction.id!],
          TransactionStatus.cleared,
        ),
        2,
      );
      expect(events, hasLength(2));
      expect(
        events.map((event) => event.month),
        unorderedEquals([202602, 202603]),
      );
      expect(
        events.map((event) => event.accountId),
        everyElement(account.id),
      );
      expect(
        events.map((event) => event.scope),
        everyElement(ChangeScope.transactions),
      );

      final rollback = await add(account, description: 'Rollback');
      events.clear();
      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.setStatus(
            book.session,
            [rollback.transaction.id!],
            TransactionStatus.cleared,
            transaction: tx,
          );
          expect(events, isEmpty);
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );
      expect(events, isEmpty);
      expect(
        (await book.transaction(rollback.transaction.id!))!.status,
        TransactionStatus.uncleared,
      );
    });

    test('metadata changes never fetch a rate', () async {
      final account = await book.addAccount(currencyCode: 'USD');
      final created = await add(account, amountMinor: -1000, fxRate: '0.8');
      FxService.configure(
        apiKey: null,
        baseUrl: null,
        backfillScheduler: (_, _) async => fail('a rate was fetched'),
      );

      expect(
        await TransactionService.setStatus(
          book.session,
          [created.transaction.id!],
          TransactionStatus.cleared,
        ),
        1,
      );
      expect(
        await TransactionService.setFlag(
          book.session,
          [created.transaction.id!],
          TransactionFlag.purple,
        ),
        1,
      );
    });

    test(
      'respects period locks and archived entities as the writer does',
      () async {
        final ledger = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final account = await ledger.addAccount();
        final created = await TransactionService.create(
          ledger.session,
          TransactionInput(
            accountId: account.id!,
            date: _date,
            amountMinor: -1000,
            lines: const [],
          ),
        );
        await ledger.addPeriodLock(_date);

        await expectLater(
          TransactionService.delete(ledger.session, created.transaction.id!),
          throwsA(isA<ValidationException>()),
        );
        expect(
          await TransactionService.setStatus(
            ledger.session,
            [created.transaction.id!],
            TransactionStatus.cleared,
          ),
          1,
        );

        final archived = await book.addEntity(
          name: 'Archived',
          archivedAt: DateTime.now().toUtc(),
        );
        final from = await book.addAccount(
          name: 'Archived from',
          entity: archived,
        );
        final to = await book.addAccount(name: 'Archived to', entity: archived);
        await expectLater(
          TransactionService.createTransfer(
            book.session,
            TransferInput(
              fromAccountId: from.id!,
              toAccountId: to.id!,
              date: _date,
              fromAmountMinor: 100,
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}
