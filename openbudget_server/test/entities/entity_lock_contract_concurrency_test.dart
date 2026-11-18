import 'dart:async';

import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

/// The entity write lock serializes entity writers without blocking the
/// foreign-key key-share check every child insert takes.
///
/// A transaction insert locks its entity row `FOR KEY SHARE` after it holds
/// its account. An entity write lock that also blocks that check inverts the
/// writer's order and forms a 40P01 cycle, so the shared lock defaults to
/// `FOR NO KEY UPDATE`: entity writers still exclude each other, and a base
/// currency change still upgrades to `FOR UPDATE` before it counts rows.
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
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  Session sessionOf() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  group('when an entity write lock is held', () {
    test('then a transaction foreign-key check still commits', () async {
      final account = await book.addAccount();
      final holder = await _EntityWriteLock.hold(sessionOf(), book.entity.id!);

      final created = await _runCatching(
        () => TransactionWriter.create(
          sessionOf(),
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 5, 2),
            amountMinor: -900,
            lines: const [],
          ),
        ).timeout(const Duration(seconds: 10)),
      );
      await holder.release();

      expect(
        created,
        isA<TransactionView>(),
        reason: 'FOR NO KEY UPDATE must not block the insert key-share check',
      );
    });

    test('then another entity writer still waits for it', () async {
      final holder = await _EntityWriteLock.hold(sessionOf(), book.entity.id!);

      final updateRun = _runCatching(
        () => EntityService.update(
          sessionOf(),
          book.entity.id!,
          name: 'Renamed while locked',
        ).timeout(const Duration(seconds: 30)),
      );
      await _waitForBlockedCount(server, 1);
      await holder.release();

      final outcome = await updateRun;
      expect(
        outcome,
        isA<Entity>().having(
          (entity) => entity.name,
          'name',
          'Renamed while locked',
        ),
      );
    });
  });

  group('when a base currency change counts transactions', () {
    test('then an in-flight create still rejects the change', () async {
      final account = await book.addAccount();
      final held = await _HeldCreate.start(
        sessionOf(),
        TransactionInput(
          accountId: account.id!,
          date: DateTime.utc(2026, 5, 3),
          amountMinor: -500,
          lines: const [],
        ),
      );

      final updateRun = _runCatching(
        () => EntityService.update(
          sessionOf(),
          book.entity.id!,
          baseCurrencyCode: 'USD',
        ).timeout(const Duration(seconds: 30)),
      );
      await _waitForBlockedCount(server, 1);
      await held.release();

      final outcome = await updateRun;
      expect(
        outcome,
        isA<ValidationException>().having(
          (error) => error.message,
          'message',
          contains('Base currency is fixed after the first transaction'),
        ),
        reason: 'the currency change must block new inserts before it counts',
      );
    });
  });
}

Future<Object?> _runCatching(Future<Object?> Function() body) async {
  try {
    return await body();
  } on Object catch (error) {
    return error;
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

/// Holds the shared entity write lock in its own transaction.
final class _EntityWriteLock {
  _EntityWriteLock._(this._release, this._done);

  static Future<_EntityWriteLock> hold(
    Session session,
    UuidValue entityId,
  ) async {
    final locked = Completer<void>();
    final release = Completer<void>();
    final done = session.db.transaction((tx) async {
      await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      );
      locked.complete();
      await release.future;
    });
    await locked.future;

    return _EntityWriteLock._(release, done);
  }

  final Completer<void> _release;
  final Future<void> _done;

  Future<void> release() async {
    if (!_release.isCompleted) _release.complete();
    await _done;
  }
}

/// Creates one transaction through the writer and keeps it uncommitted until
/// [release] is called, so its account lock and entity key share stay open.
final class _HeldCreate {
  _HeldCreate._(this._release, this._done);

  static Future<_HeldCreate> start(
    Session session,
    TransactionInput input,
  ) async {
    final created = Completer<void>();
    final release = Completer<void>();
    final done = TransactionWriter.inTransaction(session, (tx) async {
      await TransactionWriter.create(session, input, transaction: tx);
      created.complete();
      await release.future;
    });
    await created.future;

    return _HeldCreate._(release, done);
  }

  final Completer<void> _release;
  final Future<void> _done;

  Future<void> release() async {
    if (!_release.isCompleted) _release.complete();
    await _done;
  }
}
