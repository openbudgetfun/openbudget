import 'dart:async';

import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

final _date = DateTime.utc(2026, 4, 12);

/// Account deletion must never deadlock with another money write.
///
/// Each race is staged with real transactions: a helper holds one row lock so
/// both operations stop at a known point, and a bounded barrier waits for both
/// backends to block instead of sleeping for a guessed interval. Two separate
/// authenticated sessions then run the racing writes.
void main() {
  late PgTestServer server;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  late BudgetTestBook book;
  late List<EntityChangedEvent> events;

  setUp(() async {
    events = [];
    Future<void> record(
      Session session,
      UuidValue entityId,
      ChangeScope scope, {
      int? month,
      UuidValue? accountId,
    }) async {
      events.add(
        EntityChangedEvent(
          entityId: entityId,
          scope: scope,
          month: month,
          accountId: accountId,
        ),
      );
    }

    AccountService.debugPublisher = record;
    TransactionWriter.debugPublisher = record;
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    AccountService.resetForTests();
    TransactionWriter.resetForTests();
  });

  Session sessionOf() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  Future<_TransferFixture> seedTransfer() async {
    final from = await book.addAccount(name: 'From');
    final to = await book.addAccount(name: 'To');
    final fromLeg = await TransactionWriter.create(
      book.session,
      TransactionInput(
        accountId: from.id!,
        date: _date,
        amountMinor: -400,
        lines: const [],
      ),
    );
    final toLeg = await TransactionWriter.create(
      book.session,
      TransactionInput(
        accountId: to.id!,
        date: _date,
        amountMinor: 400,
        lines: const [],
      ),
    );
    final link = await Transfer.db.insertRow(
      book.session,
      Transfer(
        fromTransactionId: fromLeg.transaction.id!,
        toTransactionId: toLeg.transaction.id!,
      ),
    );
    events.clear();

    return _TransferFixture(
      fromId: from.id!,
      toId: to.id!,
      fromLeg: fromLeg.transaction.id!,
      toLeg: toLeg.transaction.id!,
      link: link.id!,
    );
  }

  group('account deletion lock order', () {
    test(
      'when two opposite account deletes race then neither deadlocks',
      () async {
        final fixture = await seedTransfer();
        final legs = _sortedLegs(fixture);
        final gate = await _RowGate.hold(sessionOf(), 'transaction', legs.last);
        addTearDown(gate.release);

        final fromSession = sessionOf();
        final toSession = sessionOf();
        final outcomes = await _race(
          server: server,
          gate: gate,
          first: () => AccountService.delete(fromSession, fixture.fromId),
          second: () => AccountService.delete(toSession, fixture.toId),
        );

        _expectNoDeadlock(outcomes);
        await _expectDeleteOutcome(outcomes.first, fixture.fromId, book);
        await _expectDeleteOutcome(outcomes.last, fixture.toId, book);

        await _expectNoOrphanTransfer(fixture, book, events);
      },
    );

    test(
      'when an account delete races deleting a transfer leg then neither '
      'deadlocks',
      () async {
        final fixture = await seedTransfer();
        final legs = _sortedLegs(fixture);
        final gate = await _RowGate.hold(sessionOf(), 'transaction', legs.last);
        addTearDown(gate.release);

        final writerSession = sessionOf();
        final deleteSession = sessionOf();
        final accountId = fixture.accountIdOf(legs.last);
        final outcomes = await _race(
          server: server,
          gate: gate,
          first: () => TransactionWriter.delete(writerSession, legs.first),
          second: () => AccountService.delete(deleteSession, accountId),
          firstLocked: () => _waitForRowLock(server, 'transaction', legs.first),
        );

        _expectNoDeadlock(outcomes);
        expect(
          outcomes.first,
          isNull,
          reason: 'the writer delete reached the leg first',
        );
        expect(
          outcomes.last,
          isNull,
          reason: 'the account still exists, so its delete must succeed',
        );
        expect(await Account.db.findById(book.session, accountId), isNull);

        await _expectNoOrphanTransfer(fixture, book, events);
      },
    );

    test(
      'when an account delete races editing an ordinary transaction then '
      'neither deadlocks',
      () async {
        final fixture = await seedTransfer();
        final ordinary = await TransactionWriter.create(
          book.session,
          TransactionInput(
            accountId: fixture.fromId,
            date: _date,
            amountMinor: -100,
            lines: const [],
          ),
        );
        final legs = _sortedLegs(fixture);
        final gate = await _RowGate.hold(sessionOf(), 'transaction', legs.last);
        addTearDown(gate.release);

        final deleteSession = sessionOf();
        final editSession = sessionOf();
        final outcomes = await _race(
          server: server,
          gate: gate,
          first: () => AccountService.delete(deleteSession, fixture.fromId),
          second: () async {
            await TransactionWriter.update(
              editSession,
              ordinary.transaction.id!,
              TransactionInput(
                accountId: fixture.fromId,
                date: _date,
                amountMinor: -100,
                memo: 'edited while the account deletes',
                lines: const [],
              ),
            );
          },
          firstLocked: () => _waitForAccountLock(server, fixture.fromId),
        );

        _expectNoDeadlock(outcomes);
        expect(
          outcomes.first,
          isNull,
          reason: 'the account delete must commit',
        );
        expect(
          outcomes.last,
          anyOf(isNull, isA<NotFoundException>()),
          reason: 'the edit either wins or finds its transaction deleted',
        );
        expect(await Account.db.findById(book.session, fixture.fromId), isNull);

        await _expectNoOrphanTransfer(fixture, book, events);
      },
    );

    test(
      'when an account delete races editing a transfer leg then neither '
      'deadlocks',
      () async {
        final fixture = await seedTransfer();
        final legs = _sortedLegs(fixture);
        final gate = await _RowGate.hold(
          sessionOf(),
          'transaction',
          legs.first,
        );
        addTearDown(gate.release);

        final editLeg = legs.last;
        final row = (await book.transaction(editLeg))!;
        final deleteSession = sessionOf();
        final editSession = sessionOf();
        final outcomes = await _race(
          server: server,
          gate: gate,
          first: () => AccountService.delete(deleteSession, row.accountId),
          second: () async {
            await TransactionWriter.update(
              editSession,
              editLeg,
              TransactionInput(
                accountId: row.accountId,
                date: row.date,
                amountMinor: row.amountMinor,
                memo: 'edited while locking',
                lines: const [],
              ),
            );
          },
          firstLocked: () => _waitForAccountLock(server, row.accountId),
        );

        _expectNoDeadlock(outcomes);
        expect(
          outcomes.first,
          isNull,
          reason: 'the account delete must commit',
        );
        expect(
          outcomes.last,
          anyOf(isNull, isA<NotFoundException>()),
          reason: 'the edit either wins or finds its transaction deleted',
        );
        expect(await Account.db.findById(book.session, row.accountId), isNull);

        await _expectNoOrphanTransfer(fixture, book, events);
      },
    );

    test(
      'when a transfer commits while an account delete waits for the target '
      'then the delete fails clearly and both legs survive',
      () async {
        late Account target;
        late Account peer;
        for (var attempt = 0; attempt < 20; attempt++) {
          target = await book.addAccount(name: 'Target $attempt');
          peer = await book.addAccount(name: 'Peer $attempt');
          if (target.id!.uuid.compareTo(peer.id!.uuid) < 0) break;
        }
        expect(
          target.id!.uuid.compareTo(peer.id!.uuid),
          lessThan(0),
          reason: 'the create must lock the target before the peer',
        );

        // The create locks the target, then blocks on the peer. The account
        // delete discovers no transfer and blocks on the target, so releasing
        // the peer lets the create commit before the delete can re-read.
        final gate = await _RowGate.hold(sessionOf(), 'account', peer.id!);
        addTearDown(gate.release);
        final createRun = _runCatching(() async {
          await TransactionWriter.createTransfer(
            sessionOf(),
            TransferInput(
              fromAccountId: target.id!,
              toAccountId: peer.id!,
              date: _date,
              fromAmountMinor: 400,
            ),
          );
        });
        await _waitForBlockedCount(server, 1);

        final deleteRun = _runCatching(
          () => AccountService.delete(sessionOf(), target.id!),
        );
        await _waitForBlockedWriters(server);
        await gate.release();

        final outcomes = await Future.wait([
          createRun.timeout(const Duration(seconds: 20)),
          deleteRun.timeout(const Duration(seconds: 20)),
        ]);
        expect(outcomes.first, isNull, reason: 'the transfer must commit');
        expect(
          outcomes.last,
          isA<ValidationException>(),
          reason: 'the delete must report the new transfer, not a StateError',
        );

        expect(await Account.db.findById(book.session, target.id!), isNotNull);
        expect(await Account.db.findById(book.session, peer.id!), isNotNull);
        final currentLegs = await model.Transaction.db.find(
          book.session,
          where: (t) =>
              t.accountId.equals(target.id) | t.accountId.equals(peer.id),
        );
        expect(currentLegs, hasLength(2));
        final legIds = {for (final leg in currentLegs) leg.id!};
        final currentTransfers = [
          for (final link in await Transfer.db.find(book.session))
            if (legIds.contains(link.fromTransactionId) ||
                legIds.contains(link.toTransactionId))
              link,
        ];
        expect(currentTransfers, hasLength(1));
        expect((await book.reload(target)).balanceMinor, -400);
        expect((await book.reload(peer)).balanceMinor, 400);
        await book.expectBalancesConsistent();
      },
    );
  });
}

/// Starts both writes, waits until both block, releases the gate, and settles.
Future<List<Object?>> _race({
  required PgTestServer server,
  required _RowGate gate,
  required Future<void> Function() first,
  required Future<void> Function() second,
  Future<void> Function()? firstLocked,
}) async {
  final firstRun = _runCatching(first);
  if (firstLocked != null) await firstLocked();

  final secondRun = _runCatching(second);
  await _waitForBlockedWriters(server);
  await gate.release();

  return Future.wait([
    firstRun.timeout(const Duration(seconds: 20)),
    secondRun.timeout(const Duration(seconds: 20)),
  ]);
}

/// Runs [body], returning its error instead of throwing, so both racing
/// operations can settle before a test inspects them.
Future<Object?> _runCatching(Future<void> Function() body) async {
  try {
    await body();
    return null;
  } on Object catch (error) {
    return error;
  }
}

void _expectNoDeadlock(List<Object?> outcomes) {
  for (final error in outcomes.nonNulls) {
    if (error is DatabaseQueryException) {
      expect(
        error.code,
        isNot('40P01'),
        reason: 'account deletion must not deadlock: $error',
      );
    }
  }
}

Future<void> _expectDeleteOutcome(
  Object? error,
  UuidValue accountId,
  BudgetTestBook book,
) async {
  final exists = await Account.db.findById(book.session, accountId) != null;
  if (error == null) {
    expect(exists, isFalse, reason: 'a successful delete removes its account');
    return;
  }

  expect(error, isA<NotFoundException>());
  expect(exists, isTrue, reason: 'a failed delete leaves its account in place');
}

Future<void> _expectNoOrphanTransfer(
  _TransferFixture fixture,
  BudgetTestBook book,
  List<EntityChangedEvent> events,
) async {
  expect(await Transfer.db.findById(book.session, fixture.link), isNull);

  final legs = await model.Transaction.db.find(
    book.session,
    where: (t) =>
        t.accountId.equals(fixture.fromId) | t.accountId.equals(fixture.toId),
  );
  expect(
    legs,
    isEmpty,
    reason: 'deleting either account must remove both transfer legs',
  );

  final accountEvents = <UuidValue>{};
  for (final event in events) {
    final accountId = event.accountId;
    if (event.scope == ChangeScope.accounts && accountId != null) {
      accountEvents.add(accountId);
    }
  }
  for (final accountId in [fixture.fromId, fixture.toId]) {
    final stored = await Account.db.findById(book.session, accountId);
    if (stored == null) {
      expect(
        accountEvents,
        contains(accountId),
        reason: 'a committed delete publishes its account change',
      );
      continue;
    }

    expect(
      stored.balanceMinor,
      0,
      reason: 'the surviving peer must reverse the transfer',
    );
    expect(
      accountEvents,
      isNot(contains(accountId)),
      reason: 'a surviving account must not publish a delete',
    );
  }
}

/// Waits until [id] is locked by another backend.
Future<void> _waitForRowLock(
  PgTestServer server,
  String table,
  UuidValue id,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    try {
      await server.session.db.unsafeQuery(
        'SELECT id FROM "$table" WHERE id = @id::uuid FOR UPDATE NOWAIT',
        parameters: QueryParameters.named({'id': id.toString()}),
      );
    } on DatabaseQueryException catch (error) {
      if (error.code == '55P03') return;
      rethrow;
    }

    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('$table row $id was not locked within the timeout');
}

Future<void> _waitForAccountLock(
  PgTestServer server,
  UuidValue accountId,
) => _waitForRowLock(server, 'account', accountId);

/// Waits until both racing writes are blocked on their row locks.
Future<void> _waitForBlockedWriters(PgTestServer server) =>
    _waitForBlockedCount(server, 2);

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

/// Holds a row lock in its own transaction until [release] is called.
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

final class _TransferFixture {
  const _TransferFixture({
    required this.fromId,
    required this.toId,
    required this.fromLeg,
    required this.toLeg,
    required this.link,
  });

  final UuidValue fromId;
  final UuidValue toId;
  final UuidValue fromLeg;
  final UuidValue toLeg;
  final UuidValue link;

  UuidValue accountIdOf(UuidValue leg) => leg == fromLeg ? fromId : toId;
}

List<UuidValue> _sortedLegs(_TransferFixture fixture) =>
    [fixture.fromLeg, fixture.toLeg]..sort((a, b) => a.uuid.compareTo(b.uuid));
