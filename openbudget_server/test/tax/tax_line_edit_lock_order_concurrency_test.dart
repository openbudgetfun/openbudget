import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import '../support/tax_test_book.dart';

/// A tax line edit must take its locks without inverting a money writer.
///
/// The writer inserts a transaction after it holds the account, and that insert
/// takes PostgreSQL's `FOR KEY SHARE` on the entity row for its foreign-key
/// check. The tax edit locks the entity first and the account second, so an
/// entity write lock that blocks the key-share check closes a 40P01 cycle.
/// These races are staged with real row locks and a bounded blocked-backend
/// barrier rather than a sleep.
void main() {
  late PgTestServer server;
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
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    EntityRealtimeNotifier.debugPublisher = (
      _,
      _,
      _, {
      month,
      accountId,
    }) async {};
    TransactionWriter.debugPublisher = (_, _, _, {month, accountId}) async {};
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.utc(2026, 11, 11);
    book = await BudgetTestBook.create(server.anonymousSession());
    await saveTaxProfile(book.session, book.entity);
    await book.session.caches.clear();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  Session sessionOf() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  group('when a tax line edit races an ordinary create', () {
    test('then neither deadlocks and both changes commit', () async {
      final account = await book.addAccount();
      final seeded = await createTaxTransaction(book.session, account);
      final line = taxLine(seeded);

      // An uncommitted payee with the same name stops the ordinary create
      // inside its payee upsert, after it has locked the account and before it
      // inserts the transaction that checks the entity foreign key.
      final gate = await _PayeeGate.hold(
        sessionOf(),
        book.entity.id!,
        'Tax gate payer',
      );
      addTearDown(gate.release);

      final createRun = _runCatching(
        () => TransactionWriter.create(
          sessionOf(),
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 6, 16),
            amountMinor: -1500,
            lines: const [],
            payeeName: 'Tax gate payer',
            description: 'Created while coding one line',
          ),
        ),
      );
      await _waitForBlockedCount(server, 1);

      final taxRun = _runCatching(
        () => TaxEndpoint().setLineTax(
          sessionOf(),
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
      );
      await _waitForBlockedCount(server, 2);

      await gate.release();
      final outcomes = await _settle(createRun, taxRun);
      _expectNoDeadlock(outcomes);

      expect(outcomes.first, isA<TransactionView>());
      expect(outcomes.last, isA<TransactionView>());

      // A line edit replaces the stored line, so read the line the successful
      // tax view returned rather than the id discovered before the race.
      final stored = await TransactionLine.db.findById(
        book.session,
        taxLine(outcomes.last! as TransactionView).id!,
      );
      expect(stored?.taxCategoryCode, 'gb.ind.employment');
      final rows = await model.Transaction.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(
        rows,
        hasLength(2),
        reason: 'both writes must commit exactly once',
      );
    });
  });

  group('when an ordinary edit moves the transaction account', () {
    test('then the tax edit rejects before a late lock and writes nothing', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final seeded = await createTaxTransaction(book.session, from);
      final line = taxLine(seeded);

      // The tax edit discovers the line and header, then waits for the entity
      // write lock. The ordinary edit moves the header to the second account
      // while the discovered account is still the first.
      final gate = await _RowGate.hold(
        sessionOf(),
        'entity',
        book.entity.id!,
      );
      addTearDown(gate.release);

      final taxRun = _runCatching(
        () => TaxEndpoint().setLineTax(
          sessionOf(),
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
      );
      await _waitForBlockedCount(server, 1);

      // The ordinary writer replaces every line id when it rebuilds a moved
      // transaction. Move the header and its cached balance in one committed
      // transaction, but keep the discovered line, so this stages the exact
      // stale state the tax edit must reject: the header now sits on the other
      // account while the tax edit still believes it is on the first.
      await book.session.db.transaction((tx) async {
        await book.session.db.unsafeExecute(
          'UPDATE "transaction" SET "accountId" = @accountId::uuid '
          'WHERE id = @id::uuid',
          parameters: QueryParameters.named({
            'accountId': to.id!.toString(),
            'id': seeded.transaction.id!.toString(),
          }),
          transaction: tx,
        );
        await book.session.db.unsafeExecute(
          'UPDATE account SET "balanceMinor" = "balanceMinor" - @amount '
          'WHERE id = @id::uuid',
          parameters: QueryParameters.named({
            'amount': seeded.transaction.amountMinor,
            'id': from.id!.toString(),
          }),
          transaction: tx,
        );
        await book.session.db.unsafeExecute(
          'UPDATE account SET "balanceMinor" = "balanceMinor" + @amount '
          'WHERE id = @id::uuid',
          parameters: QueryParameters.named({
            'amount': seeded.transaction.amountMinor,
            'id': to.id!.toString(),
          }),
          transaction: tx,
        );
      });

      await gate.release();
      final outcome = await taxRun.timeout(const Duration(seconds: 30));

      expect(
        outcome,
        isA<ValidationException>().having(
          (error) => error.message,
          'message',
          contains('concurrently'),
        ),
      );

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.taxCategoryCode, isNull);
      final header = await model.Transaction.db.findById(
        book.session,
        seeded.transaction.id!,
      );
      expect(header?.accountId, to.id);
      expect(
        await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(seeded.transaction.id),
        ),
        hasLength(1),
        reason: 'the rejected edit must not replace or duplicate lines',
      );
    });
  });
}

Future<List<Object?>> _settle(
  Future<Object?> first,
  Future<Object?> second,
) => Future.wait([
  first.timeout(const Duration(seconds: 30)),
  second.timeout(const Duration(seconds: 30)),
]);

Future<Object?> _runCatching(Future<Object?> Function() body) async {
  try {
    return await body();
  } on Object catch (error) {
    return error;
  }
}

void _expectNoDeadlock(List<Object?> outcomes) {
  for (final error in outcomes.nonNulls) {
    expect(
      error is DatabaseQueryException ? error.code : null,
      isNot('40P01'),
      reason: 'a tax line edit must never deadlock with a money write: $error',
    );
  }
}

/// Waits until [minimum] backends are blocked on row locks.
Future<void> _waitForBlockedCount(PgTestServer server, int minimum) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final rows = await server.session.db.unsafeQuery(
      'SELECT count(*)::bigint FROM pg_stat_activity '
      'WHERE datname = current_database() '
      "AND wait_event_type = 'Lock' AND pid <> pg_backend_pid()",
    );
    if ((rows.first.first as int) >= minimum) return;

    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('$minimum writers did not block on a row lock within the timeout');
}

/// Holds one row lock in its own transaction until [release] is called.
final class _RowGate {
  _RowGate._(this._release, this._done);

  static Future<_RowGate> hold(
    Session session,
    String table,
    UuidValue id,
  ) async {
    final locked = Completer<void>();
    final release = Completer<void>();
    final done = session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        'SELECT id FROM "$table" WHERE id = @id::uuid FOR UPDATE',
        parameters: QueryParameters.named({'id': id.toString()}),
        transaction: tx,
      );
      locked.complete();
      await release.future;
    });
    await locked.future;

    return _RowGate._(release, done);
  }

  final Completer<void> _release;
  final Future<void> _done;

  Future<void> release() async {
    if (!_release.isCompleted) _release.complete();
    await _done;
  }
}

/// Holds one uncommitted payee so a create that resolves the same name stops
/// inside its payee upsert with the account already locked.
final class _PayeeGate {
  _PayeeGate._(this._release, this._done);

  static Future<_PayeeGate> hold(
    Session session,
    UuidValue entityId,
    String name,
  ) async {
    final inserted = Completer<void>();
    final release = Completer<void>();
    final done = session.db.transaction((tx) async {
      await session.db.unsafeExecute(
        'INSERT INTO payee ("entityId", name, "createdAt") '
        'VALUES (@entityId::uuid, @name, now())',
        parameters: QueryParameters.named({
          'entityId': entityId.toString(),
          'name': name,
        }),
        transaction: tx,
      );
      inserted.complete();
      await release.future;
    });
    await inserted.future;

    return _PayeeGate._(release, done);
  }

  final Completer<void> _release;
  final Future<void> _done;

  Future<void> release() async {
    if (!_release.isCompleted) _release.complete();
    await _done;
  }
}
