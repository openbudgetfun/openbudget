// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_endpoint.dart';
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
    addTearDown(() async {
      await book.expectBalancesConsistent();
    });
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    FxService.resetForTests();
  });

  ImportRow row({
    int amountMinor = -1000,
    DateTime? date,
    String description = '',
    String? payeeName,
    String? memo,
    String? externalId,
  }) => ImportRow(
    date: date ?? _date,
    amountMinor: amountMinor,
    description: description,
    payeeName: payeeName,
    memo: memo,
    externalId: externalId,
  );

  TransactionInput entry(
    Account account, {
    int amountMinor = -1000,
    DateTime? date,
    String description = '',
  }) => TransactionInput(
    accountId: account.id!,
    date: date ?? _date,
    amountMinor: amountMinor,
    description: description,
    lines: const [],
  );

  Future<List<model.Transaction>> transactions(Account account) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(account.id),
      );

  Future<List<Payee>> payeesNamed(String name) => Payee.db.find(
    book.session,
    where: (t) => t.name.equals(name),
  );

  group('idempotence and duplicate ids', () {
    test(
      'a repeated file derives the same ids and inserts nothing new',
      () async {
        final account = await book.addAccount();
        final rows = [
          row(
            amountMinor: -1250,
            description: 'Groceries',
            externalId: ' bank-1 ',
          ),
          row(amountMinor: 2500, description: 'Salary'),
          row(amountMinor: -400, description: 'Coffee'),
          row(amountMinor: -400, description: 'Coffee'),
          row(amountMinor: -400, description: 'Coffee'),
        ];

        final first = await TransactionWriter.importRows(
          book.session,
          account.id!,
          rows,
        );

        expect(first.insertedCount, 5);
        expect(first.skippedDuplicateCount, 0);
        expect(first.errors, isEmpty);
        expect(await book.cachedBalanceMinor(account), 50);
        expect(events, hasLength(1));

        final stored = await transactions(account);
        final coffeeIds = {
          for (final row in stored)
            if (row.description == 'Coffee') row.externalId!,
        };
        expect(coffeeIds, hasLength(3));
        expect(coffeeIds.every((id) => id.startsWith('csv:')), isTrue);
        expect(coffeeIds.every((id) => id.length == 68), isTrue);
        final secondCoffee =
            'csv:${sha256.convert(utf8.encode('2026-03-10|-400|Coffee|1'))}';
        expect(coffeeIds, contains(secondCoffee));
        expect(
          stored.singleWhere((row) => row.externalId == 'bank-1').amountMinor,
          -1250,
        );

        events.clear();
        final second = await TransactionWriter.importRows(
          book.session,
          account.id!,
          rows,
        );

        expect(second.insertedCount, 0);
        expect(second.skippedDuplicateCount, 5);
        expect(second.errors, isEmpty);
        expect(await transactions(account), hasLength(5));
        expect(await book.cachedBalanceMinor(account), 50);
        expect(events, isEmpty);
      },
    );

    test(
      'scopes ids per account and inserts a repeated batch id once',
      () async {
        final first = await book.addAccount(name: 'First');
        final second = await book.addAccount(name: 'Second');

        final firstResult = await TransactionWriter.importRows(
          book.session,
          first.id!,
          [row(externalId: 'shared', amountMinor: 100, description: 'In')],
        );
        final secondResult = await TransactionWriter.importRows(
          book.session,
          second.id!,
          [row(externalId: 'shared', amountMinor: 200, description: 'In')],
        );

        expect(firstResult.insertedCount, 1);
        expect(secondResult.insertedCount, 1);

        final repeated = await TransactionWriter.importRows(
          book.session,
          first.id!,
          [
            row(externalId: 'batch', amountMinor: 300, description: 'First'),
            row(externalId: 'batch', amountMinor: -300, description: 'Second'),
          ],
        );

        expect(repeated.insertedCount, 1);
        expect(repeated.skippedDuplicateCount, 1);
        expect(repeated.errors, isEmpty);
        final stored = await transactions(first);
        expect(stored.where((row) => row.externalId == 'batch'), hasLength(1));
        expect(
          stored.singleWhere((row) => row.externalId == 'batch').description,
          'First',
        );
      },
    );

    test('an existing duplicate skips payload validation', () async {
      final account = await book.addAccount();
      await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -100),
        metadata: const TransactionWriteMetadata(externalId: 'bank-9'),
      );
      events.clear();

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          row(
            externalId: 'bank-9',
            amountMinor: 0,
            date: EntityClock.today(book.entity).add(const Duration(days: 5)),
          ),
        ],
      );

      expect(result.insertedCount, 0);
      expect(result.skippedDuplicateCount, 1);
      expect(result.errors, isEmpty);
      expect(await transactions(account), hasLength(1));
      expect(events, isEmpty);
    });

    test('a rejected row never claims its id for a later row', () async {
      final account = await book.addAccount();

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          row(externalId: 'retry', amountMinor: 0),
          row(externalId: 'retry', amountMinor: 500),
        ],
      );

      expect(result.insertedCount, 1);
      expect(result.errors.single, startsWith('0: '));
      expect(await transactions(account), hasLength(1));
      expect(
        (await transactions(account)).single.amountMinor,
        500,
      );
    });
  });

  group('row validation', () {
    test('reports 0-based indexes and commits the valid rows', () async {
      final rows = [
        row(amountMinor: -1000, description: 'Valid'),
        row(amountMinor: 0, description: 'Zero'),
        row(date: DateTime(2026, 3, 10, 12), description: 'Local date'),
        row(
          date: EntityClock.today(book.entity).add(const Duration(days: 2)),
          description: 'Future',
        ),
        row(amountMinor: maxSafeMinor + 1, description: 'Too large'),
        row(externalId: '   ', description: 'Blank id'),
        row(externalId: 'x' * 256, description: 'Long id'),
        row(externalId: 'bad\u0001id', description: 'Control id'),
      ];
      final account = await book.addAccount();

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        rows,
      );

      expect(result.insertedCount, 1);
      expect(result.skippedDuplicateCount, 0);
      expect(result.errors, hasLength(7));
      for (var index = 1; index <= 7; index++) {
        expect(result.errors[index - 1], startsWith('$index: '));
      }
      expect(result.errors[0], contains('must not be zero'));
      expect(result.errors[1], contains('UTC calendar date'));
      expect(result.errors[2], contains('today plus one'));
      expect(result.errors[3], contains('safe minor-unit range'));
      expect(result.errors[4], contains('must not be blank'));
      expect(result.errors[5], contains('at most 255 characters'));
      expect(result.errors[6], contains('control characters'));
      expect(await book.cachedBalanceMinor(account), -1000);
    });

    test('a period lock rejects one row, not the whole import', () async {
      final ledger = await BudgetTestBook.create(
        server.anonymousSession(),
        accountingMode: AccountingMode.ledger,
      );
      addTearDown(ledger.expectBalancesConsistent);
      final account = await ledger.addAccount();
      await ledger.addPeriodLock(_date);

      final result = await TransactionWriter.importRows(
        ledger.session,
        account.id!,
        [
          row(amountMinor: -100),
          row(
            date: DateTime.utc(2026, 3, 11),
            amountMinor: -200,
            description: 'After',
          ),
        ],
      );

      expect(result.insertedCount, 1);
      expect(result.errors.single, startsWith('0: '));
      expect(result.errors.single, contains('period lock'));
      expect(await ledger.cachedBalanceMinor(account), -200);
    });

    test('imports are ordinary uncleared postings without metadata', () async {
      final account = await book.addAccount();

      await TransactionWriter.importRows(book.session, account.id!, [
        row(amountMinor: -500, description: 'Shop'),
      ]);

      final stored = (await transactions(account)).single;
      expect(stored.status, TransactionStatus.uncleared);
      expect(stored.kind, TransactionKind.standard);
      expect(stored.revision, 0);
      expect(stored.recurringTransactionId, isNull);
      expect(stored.flag, isNull);
      expect(stored.payeeId, isNull);
      expect(await Transfer.db.find(book.session), isEmpty);
    });
  });

  group('account failures', () {
    test('checks authentication and ownership for an empty batch', () async {
      final account = await book.addAccount();

      final empty = await TransactionWriter.importRows(
        book.session,
        account.id!,
        const [],
      );
      expect(empty.insertedCount, 0);
      expect(empty.skippedDuplicateCount, 0);
      expect(empty.errors, isEmpty);

      final anonymous = server.anonymousSession();
      addTearDown(anonymous.close);
      await expectLater(
        TransactionWriter.importRows(anonymous, account.id!, const []),
        throwsA(isA<AuthenticationRequiredException>()),
      );

      final other = await BudgetTestBook.create(server.anonymousSession());
      await expectLater(
        TransactionWriter.importRows(other.session, account.id!, const []),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        TransactionWriter.importRows(
          book.session,
          const Uuid().v7obj(),
          const [],
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'closed, valuation and archived targets fail the whole call',
      () async {
        final closed = await book.addAccount(
          name: 'Closed',
          closedAt: DateTime.utc(2026, 1, 1),
        );
        await expectLater(
          TransactionWriter.importRows(book.session, closed.id!, [row()]),
          throwsA(isA<ValidationException>()),
        );

        final valuation = await book.addAccount(
          name: 'House',
          kind: AccountKind.property,
          balanceSource: AccountBalanceSource.valuations,
        );
        await expectLater(
          TransactionWriter.importRows(book.session, valuation.id!, [row()]),
          throwsA(isA<StateError>()),
        );

        final archivedEntity = await book.addEntity(
          name: 'Archived',
          archivedAt: DateTime.utc(2026, 1, 1),
        );
        final archivedAccount = await book.addAccount(
          name: 'Archived',
          entity: archivedEntity,
        );
        await expectLater(
          TransactionWriter.importRows(
            book.session,
            archivedAccount.id!,
            [row()],
          ),
          throwsA(isA<ValidationException>()),
        );

        final unsupported = await book.addAccount(
          name: 'Unsupported',
          currencyCode: 'ZZZ',
        );
        await expectLater(
          TransactionWriter.importRows(book.session, unsupported.id!, [row()]),
          throwsA(isA<ValidationException>()),
        );

        expect(await transactions(closed), isEmpty);
        expect(await transactions(valuation), isEmpty);
        expect(await transactions(archivedAccount), isEmpty);
        expect(await transactions(unsupported), isEmpty);
        expect(events, isEmpty);
      },
    );

    test('an oversized batch is rejected before any row is written', () async {
      final account = await book.addAccount();
      final rows = [
        for (var index = 0; index <= TransactionWriter.maxImportRows; index++)
          row(externalId: 'row-$index', amountMinor: -1),
      ];

      await expectLater(
        TransactionWriter.importRows(book.session, account.id!, rows),
        throwsA(isA<ValidationException>()),
      );

      expect(await transactions(account), isEmpty);
      expect(await book.cachedBalanceMinor(account), 0);
      expect(events, isEmpty);
    });
  });

  group('atomicity and events', () {
    test('a caller rollback writes nothing and emits nothing', () async {
      final account = await book.addAccount();

      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.importRows(
            book.session,
            account.id!,
            [row(amountMinor: -100, payeeName: 'Rolled back')],
            transaction: tx,
          );
          expect(events, isEmpty);
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );

      expect(await transactions(account), isEmpty);
      expect(await payeesNamed('Rolled back'), isEmpty);
      expect(events, isEmpty);
    });

    test('events dedupe by month and only cover new facts', () async {
      final account = await book.addAccount();
      final rows = [
        row(
          date: DateTime.utc(2026, 3, 10),
          amountMinor: -100,
          description: 'A',
        ),
        row(
          date: DateTime.utc(2026, 3, 20),
          amountMinor: -200,
          description: 'B',
        ),
        row(
          date: DateTime.utc(2026, 4, 1),
          amountMinor: -300,
          description: 'C',
        ),
      ];

      await TransactionWriter.inTransaction(book.session, (tx) async {
        await TransactionWriter.importRows(
          book.session,
          account.id!,
          rows,
          transaction: tx,
        );
        expect(events, isEmpty);
      });

      expect(events, hasLength(2));
      expect(
        events.map((event) => event.month),
        unorderedEquals([202603, 202604]),
      );
      expect(events.every((event) => event.accountId == account.id), isTrue);
      expect(events.every((event) => event.entityId == book.entity.id), isTrue);
      expect(
        events.every((event) => event.scope == ChangeScope.transactions),
        isTrue,
      );

      events.clear();
      await TransactionWriter.importRows(book.session, account.id!, rows);
      expect(events, isEmpty);
    });

    test('aggregate overflow rolls back facts, payees and events', () async {
      final account = await book.addAccount();
      await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: maxSafeMinor),
      );
      events.clear();

      await expectLater(
        TransactionWriter.importRows(book.session, account.id!, [
          row(amountMinor: 100, description: 'In', payeeName: 'Overflow shop'),
          row(amountMinor: -50, description: 'Out'),
        ]),
        throwsA(isA<ValidationException>()),
      );

      expect(await transactions(account), hasLength(1));
      expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      expect(await book.recomputedBalanceMinor(account), maxSafeMinor);
      expect(await payeesNamed('Overflow shop'), isEmpty);
      expect(events, isEmpty);
    });

    test(
      'one net delta lands a balance a per-row step would overflow',
      () async {
        final account = await book.addAccount();
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: maxSafeMinor - 1),
        );

        final result = await TransactionWriter.importRows(
          book.session,
          account.id!,
          [
            row(amountMinor: 2, description: 'In'),
            row(amountMinor: -1, description: 'Out'),
          ],
        );

        expect(result.insertedCount, 2);
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);
        expect(await book.recomputedBalanceMinor(account), maxSafeMinor);
      },
    );

    test(
      'concurrent identical imports keep one copy and one balance',
      () async {
        final account = await book.addAccount();
        final rows = [
          for (var index = 0; index < 5; index++)
            row(
              externalId: 'row-$index',
              amountMinor: 10 + index,
              description: 'Row $index',
            ),
        ];
        final sessions = [
          server.authenticatedSession(book.userId),
          server.authenticatedSession(book.userId),
        ];
        addTearDown(() async {
          for (final session in sessions) {
            await session.close();
          }
        });

        final results = await Future.wait([
          for (final session in sessions)
            TransactionWriter.importRows(session, account.id!, rows),
        ]);

        expect(
          results.fold<int>(0, (sum, result) => sum + result.insertedCount),
          5,
        );
        expect(
          results.fold<int>(
            0,
            (sum, result) => sum + result.skippedDuplicateCount,
          ),
          5,
        );
        expect(results.every((result) => result.errors.isEmpty), isTrue);
        expect(await transactions(account), hasLength(5));
        expect(await book.cachedBalanceMinor(account), 60);
        expect(await book.recomputedBalanceMinor(account), 60);
      },
    );
  });

  group('fx and payees', () {
    test('a foreign row keeps the market rate, date and exact base', () async {
      final account = await book.addAccount(currencyCode: 'EUR');
      await book.seedMarketRate(
        fromCurrencyCode: 'EUR',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '0.8',
        toPerUsd: '1',
      );

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [row(amountMinor: -1000, description: 'Abroad')],
      );

      expect(result.insertedCount, 1);
      final stored = (await transactions(account)).single;
      expect(stored.amountMinor, -1000);
      expect(stored.baseAmountMinor, -1250);
      expect(stored.fxRate, '1.25');
      expect(stored.fxRateDate, _date);
      expect(stored.fxRateSource, FxRateSource.market);
      final lines = await TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.equals(stored.id),
      );
      expect(lines.single.baseAmountMinor, -1250);
      expect(await book.cachedBalanceMinor(account), -1000);
    });

    test('a missing market rate rejects only its row', () async {
      await server.clearRates();
      await book.session.caches.clear();
      final account = await book.addAccount(currencyCode: 'EUR');
      await book.seedMarketRate(
        fromCurrencyCode: 'EUR',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '0.8',
        toPerUsd: '1',
      );

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          row(
            date: _date.subtract(const Duration(days: 1)),
            amountMinor: -100,
            description: 'No rate',
          ),
          row(amountMinor: -200, description: 'Priced'),
        ],
      );

      expect(result.insertedCount, 1);
      expect(result.errors.single, startsWith('0: '));
      expect(result.errors.single, contains('Exchange rate not available'));
      expect((await transactions(account)).single.description, 'Priced');
    });

    test('payee rules and new payees follow the create path', () async {
      final account = await book.addAccount();
      final envelope = await book.addEnvelope();
      final payee = await book.addPayee(name: 'Corner shop');
      await book.addRule(payee: payee, envelope: envelope);

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          row(
            amountMinor: -500,
            description: 'Shop 1',
            payeeName: ' Corner shop ',
          ),
          row(
            amountMinor: -700,
            description: 'Shop 2',
            payeeName: 'Corner shop',
          ),
          row(amountMinor: -300, description: 'New 1', payeeName: 'New shop'),
          row(amountMinor: -400, description: 'New 2', payeeName: 'New shop'),
        ],
      );

      expect(result.insertedCount, 4);
      final stored = await transactions(account);
      final ruled = stored.where((row) => row.payeeId == payee.id);
      expect(ruled, hasLength(2));
      for (final row in ruled) {
        final lines = await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(row.id),
        );
        expect(lines.map((line) => line.envelopeId), [envelope.id]);
      }

      final newPayees = await payeesNamed('New shop');
      expect(newPayees, hasLength(1));
      expect(
        stored.where((row) => row.payeeId == newPayees.single.id),
        hasLength(2),
      );

      await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -100),
        metadata: const TransactionWriteMetadata(externalId: 'dup-id'),
      );
      final duplicate = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          row(
            externalId: 'dup-id',
            amountMinor: -100,
            payeeName: 'Ghost shop',
          ),
        ],
      );

      expect(duplicate.skippedDuplicateCount, 1);
      expect(await payeesNamed('Ghost shop'), isEmpty);
    });
  });

  group('surface', () {
    test('the service and endpoint delegate to the writer', () async {
      final account = await book.addAccount();
      final endpoint = TransactionEndpoint();
      expect(endpoint.requireLogin, isTrue);

      final viaService = await TransactionService.importRows(
        book.session,
        account.id!,
        [row(externalId: 'service-1', amountMinor: -100)],
      );
      final viaEndpoint = await endpoint.importRows(
        book.session,
        account.id!,
        [row(externalId: 'endpoint-1', amountMinor: -200)],
      );

      expect(viaService.insertedCount, 1);
      expect(viaEndpoint.insertedCount, 1);
      expect(await book.cachedBalanceMinor(account), -300);
    });
  });
}
