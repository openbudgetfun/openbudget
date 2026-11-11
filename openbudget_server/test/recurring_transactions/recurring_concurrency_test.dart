import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/envelopes/envelope_endpoint.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/payees/payee_endpoint.dart';
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
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
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    final session = server.anonymousSession();
    addTearDown(session.close);
    book = await BudgetTestBook.create(session);
    await book.session.caches.clear();
    endpoint = RecurringTransactionEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    events.reset();
    FxService.resetForTests();
  });

  Session sessionOf() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  DateTime today() => EntityClock.today(book.entity);

  Future<RecurringTransaction> createDue(
    Account account, {
    UuidValue? payeeId,
    UuidValue? envelopeId,
    String description = 'Rent',
    int amountMinor = -1000,
  }) => endpoint.create(
    book.session,
    account.id!,
    description,
    amountMinor,
    RecurrenceFrequency.monthly,
    today(),
    payeeId: payeeId,
    envelopeId: envelopeId,
  );

  group('Given recurring posting and its neighbours', () {
    test(
      'when manual and automatic posters race then one occurrence wins',
      () async {
        final account = await book.addAccount();
        final schedule = await createDue(account);
        final gate = await _RowGate.hold(sessionOf(), 'account', account.id!);
        addTearDown(gate.release);

        final first = _capture(
          endpoint.postDue(sessionOf(), book.entity.id!),
        );
        await _waitForBlockedCount(server, 1);
        final second = _capture(
          endpoint.postDue(sessionOf(), book.entity.id!),
        );
        await _waitForBlockedCount(server, 2);
        await gate.release();

        final results = await Future.wait([
          first.timeout(const Duration(seconds: 20)),
          second.timeout(const Duration(seconds: 20)),
        ]);
        _expectNoDeadlock(results);

        final rows = await model.Transaction.db.find(
          book.session,
          where: (t) => t.recurringTransactionId.equals(schedule.id),
        );
        expect(rows, hasLength(1));
        expect(
          results.whereType<int>().fold<int>(0, (sum, count) => sum + count),
          1,
        );
      },
    );

    test(
      'when a payee merge races posting then the merge and payee survive',
      () async {
        final account = await book.addAccount();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        final schedule = await createDue(account, payeeId: source.id);
        final gate = await _RowGate.hold(sessionOf(), 'account', account.id!);
        addTearDown(gate.release);
        final payeeEndpoint = PayeeEndpoint();

        final postRun = _capture(
          endpoint.postDue(sessionOf(), book.entity.id!),
        );
        await _waitForBlockedCount(server, 1);
        final mergeRun = _capture(
          payeeEndpoint.merge(sessionOf(), source.id!, target.id!),
        );
        await _waitForBlockedCount(server, 2);
        await gate.release();

        final results = await Future.wait([
          postRun.timeout(const Duration(seconds: 20)),
          mergeRun.timeout(const Duration(seconds: 20)),
        ]);
        _expectNoDeadlock(results);
        expect(results.whereType<DatabaseException>(), isEmpty);

        final storedSchedule = await RecurringTransaction.db.findById(
          book.session,
          schedule.id!,
        );
        expect(storedSchedule?.payeeId, target.id);
        final rows = await model.Transaction.db.find(
          book.session,
          where: (t) => t.recurringTransactionId.equals(schedule.id),
        );
        expect(rows, hasLength(1));
        expect(rows.single.payeeId, target.id);
        expect(await Payee.db.findById(book.session, source.id!), isNull);
      },
    );

    test('when an envelope reassignment races posting then both lines end in '
        'the destination', () async {
      final account = await book.addAccount();
      final source = await book.addEnvelope(name: 'Source');
      final destination = await book.addEnvelope(name: 'Destination');
      final existing = await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: account.id!,
          date: today(),
          amountMinor: -100,
          lines: [
            TransactionLineInput(amountMinor: -100, envelopeId: source.id),
          ],
        ),
      );
      final schedule = await createDue(account, envelopeId: source.id);
      final gate = await _RowGate.hold(sessionOf(), 'account', account.id!);
      addTearDown(gate.release);
      final envelopeEndpoint = EnvelopeEndpoint();

      final postRun = _capture(
        endpoint.postDue(sessionOf(), book.entity.id!),
      );
      await _waitForBlockedCount(server, 1);
      final reassignRun = _capture(
        envelopeEndpoint.delete(
          sessionOf(),
          source.id!,
          reassignToEnvelopeId: destination.id,
        ),
      );
      await _waitForBlockedCount(server, 2);
      await gate.release();

      final results = await Future.wait([
        postRun.timeout(const Duration(seconds: 20)),
        reassignRun.timeout(const Duration(seconds: 20)),
      ]);
      _expectNoDeadlock(results);
      expect(await Envelope.db.findById(book.session, source.id!), isNull);

      final posted = await model.Transaction.db.findFirstRow(
        book.session,
        where: (t) => t.recurringTransactionId.equals(schedule.id),
      );
      expect(posted, isNotNull);
      final transactionIds = {existing.transaction.id!, posted!.id!};
      final lines = await TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.inSet(transactionIds),
      );
      expect(lines, hasLength(2));
      expect(lines.every((line) => line.envelopeId == destination.id), isTrue);
    });

    test(
      'when an account delete races posting then no orphan survives',
      () async {
        final account = await book.addAccount();
        final schedule = await createDue(account);
        final gate = await _RowGate.hold(sessionOf(), 'account', account.id!);
        addTearDown(gate.release);

        final postRun = _capture(
          endpoint.postDue(sessionOf(), book.entity.id!),
        );
        await _waitForBlockedCount(server, 1);
        final deleteRun = _capture(
          AccountService.delete(sessionOf(), account.id!),
        );
        await _waitForBlockedCount(server, 2);
        await gate.release();

        final results = await Future.wait([
          postRun.timeout(const Duration(seconds: 20)),
          deleteRun.timeout(const Duration(seconds: 20)),
        ]);
        _expectNoDeadlock(results);

        expect(await Account.db.findById(book.session, account.id!), isNull);
        expect(
          await RecurringTransaction.db.findById(book.session, schedule.id!),
          isNull,
        );
        expect(
          await model.Transaction.db.count(
            book.session,
            where: (t) => t.recurringTransactionId.equals(schedule.id),
          ),
          0,
        );
      },
    );

    test(
      'when a schedule edit races posting then neither write is lost',
      () async {
        final account = await book.addAccount();
        final schedule = await createDue(account);
        final gate = await _RowGate.hold(sessionOf(), 'account', account.id!);
        addTearDown(gate.release);

        final postRun = _capture(
          endpoint.postDue(sessionOf(), book.entity.id!),
        );
        await _waitForBlockedCount(server, 1);
        final editRun = _capture(
          endpoint.update(
            sessionOf(),
            schedule.id!,
            description: 'Edited rent',
            amountMinor: -2000,
          ),
        );
        await _waitForBlockedCount(server, 2);
        await gate.release();

        final results = await Future.wait([
          postRun.timeout(const Duration(seconds: 20)),
          editRun.timeout(const Duration(seconds: 20)),
        ]);
        _expectNoDeadlock(results);

        final stored = await endpoint.get(book.session, schedule.id!);
        expect(stored.description, 'Edited rent');
        expect(stored.amountMinor, -2000);
        final rows = await model.Transaction.db.find(
          book.session,
          where: (t) => t.recurringTransactionId.equals(schedule.id),
        );
        expect(rows.length, lessThanOrEqualTo(1));
        if (rows.isNotEmpty) {
          final row = rows.single;
          expect(
            (row.amountMinor == -1000 && row.description == 'Rent') ||
                (row.amountMinor == -2000 && row.description == 'Edited rent'),
            isTrue,
          );
        }
        expect(
          await model.Transaction.db.count(
            book.session,
            where: (t) => t.recurringTransactionId.equals(schedule.id),
          ),
          lessThanOrEqualTo(1),
        );
      },
    );
  });
}

/// Captures a success value or the thrown error so two calls can race.
Future<Object?> _capture(Future<Object?> future) async {
  try {
    return await future;
  } on Object catch (error) {
    return error;
  }
}

void _expectNoDeadlock(List<Object?> outcomes) {
  for (final error in outcomes.whereType<DatabaseQueryException>()) {
    expect(
      error.code,
      isNot('40P01'),
      reason: 'recurring posting must not deadlock: $error',
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
