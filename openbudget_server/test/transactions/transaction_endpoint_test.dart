// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

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

  Future<List<model.Transaction>> transactionsOf(UuidValue accountId) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(accountId),
      );

  Future<Transfer> transferBetween(UuidValue fromId, UuidValue toId) async {
    final leg = await model.Transaction.db.findFirstRow(
      book.session,
      where: (t) => t.accountId.equals(fromId) & t.amountMinor.equals(-5000),
    );
    if (leg == null) throw StateError('Transfer leg missing');
    final transfer = await Transfer.db.findFirstRow(
      book.session,
      where: (t) => t.fromTransactionId.equals(leg.id),
    );
    if (transfer == null) throw StateError('Transfer link missing');
    return transfer;
  }

  group('delegation to TransactionWriter', () {
    test('create, get, update and delete use the real writer', () async {
      expect(endpoint.requireLogin, isTrue);
      final account = await book.addAccount();
      final envelope = await book.addEnvelope();

      final created = await endpoint.create(
        book.session,
        entry(
          account,
          amountMinor: -1250,
          description: 'Groceries',
          lines: [
            TransactionLineInput(
              amountMinor: -1250,
              envelopeId: envelope.id,
            ),
          ],
        ),
      );

      expect(created.transaction.description, 'Groceries');
      expect(created.transaction.amountMinor, -1250);
      expect(created.lines.single.envelopeId, envelope.id);
      expect(created.accountCurrencyCode, 'GBP');
      expect(await book.cachedBalanceMinor(account), -1250);
      expect(await book.recomputedBalanceMinor(account), -1250);
      expect(events, hasLength(1));
      expect(events.single.accountId, account.id);

      final loaded = await endpoint.get(book.session, created.transaction.id!);
      expect(loaded.transaction.id, created.transaction.id);
      expect(loaded.lines, hasLength(1));

      final updated = await endpoint.update(
        book.session,
        created.transaction.id!,
        entry(
          account,
          amountMinor: -1500,
          description: 'Groceries and coffee',
          lines: [
            TransactionLineInput(amountMinor: -1500, envelopeId: envelope.id),
          ],
        ),
      );
      expect(updated.transaction.description, 'Groceries and coffee');
      expect(updated.transaction.amountMinor, -1500);
      expect(updated.transaction.fxRate, created.transaction.fxRate);
      expect(await book.cachedBalanceMinor(account), -1500);

      final page = await endpoint.list(
        book.session,
        TransactionQuery(
          entityId: book.entity.id!,
          accountId: account.id,
        ),
      );
      expect(page.items.single.transaction.id, created.transaction.id);
      expect(page.nextCursor, isNull);

      await endpoint.delete(book.session, created.transaction.id!);
      expect(await transactionsOf(account.id!), isEmpty);
      expect(await book.cachedBalanceMinor(account), 0);
      expect(await book.recomputedBalanceMinor(account), 0);
    });

    test(
      'createTransfer and updateTransfer preserve both legs and link',
      () async {
        final from = await book.addAccount(name: 'Checking');
        final to = await book.addAccount(name: 'Savings');

        final created = await endpoint.createTransfer(
          book.session,
          TransferInput(
            fromAccountId: from.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 5000,
            status: TransactionStatus.cleared,
          ),
        );

        expect(created, hasLength(2));
        expect(created.first.transaction.amountMinor, -5000);
        expect(created.last.transaction.amountMinor, 5000);
        expect(created.first.transferPeer, isNotNull);
        expect(created.first.transferPeer!.accountId, to.id);
        expect(await book.cachedBalanceMinor(from), -5000);
        expect(await book.cachedBalanceMinor(to), 5000);

        final transfer = await transferBetween(from.id!, to.id!);
        final updated = await endpoint.updateTransfer(
          book.session,
          transfer.id!,
          TransferInput(
            fromAccountId: from.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 3000,
            status: TransactionStatus.cleared,
          ),
        );

        expect(updated, hasLength(2));
        expect(updated.first.transaction.id, created.first.transaction.id);
        expect(updated.last.transaction.id, created.last.transaction.id);
        expect(updated.first.transferPeer!.transferId, transfer.id);
        expect(await book.cachedBalanceMinor(from), -3000);
        expect(await book.cachedBalanceMinor(to), 3000);
      },
    );

    test('setStatus and setFlag change only metadata', () async {
      final account = await book.addAccount();
      final first = await endpoint.create(
        book.session,
        entry(account, amountMinor: -700, description: 'One'),
      );
      final second = await endpoint.create(
        book.session,
        entry(account, amountMinor: -300, description: 'Two'),
      );
      final ids = [first.transaction.id!, second.transaction.id!];
      const balanced = -1000;
      expect(await book.cachedBalanceMinor(account), balanced);

      expect(
        await endpoint.setStatus(
          book.session,
          ids,
          TransactionStatus.cleared,
        ),
        2,
      );
      expect(
        await endpoint.setFlag(book.session, ids, TransactionFlag.red),
        2,
      );

      final cleared = await transactionsOf(account.id!);
      expect(
        cleared.map((row) => row.status),
        everyElement(TransactionStatus.cleared),
      );
      expect(cleared.map((row) => row.flag), everyElement(TransactionFlag.red));
      expect(await book.cachedBalanceMinor(account), balanced);

      expect(await endpoint.setFlag(book.session, ids, null), 2);
      final unflagged = await transactionsOf(account.id!);
      expect(unflagged.map((row) => row.flag), everyElement(isNull));
      expect(await book.cachedBalanceMinor(account), balanced);
    });

    test(
      'findDuplicates returns only the same account and exact amount',
      () async {
        final account = await book.addAccount();
        final other = await book.addAccount(name: 'Other');
        await endpoint.create(
          book.session,
          entry(account, amountMinor: -900, description: 'Near'),
        );
        await endpoint.create(
          book.session,
          entry(account, amountMinor: -901, description: 'Different'),
        );
        await endpoint.create(
          book.session,
          entry(other, amountMinor: -900, description: 'Other account'),
        );

        final matches = await endpoint.findDuplicates(
          book.session,
          account.id!,
          _date,
          -900,
        );
        expect(matches, hasLength(1));
        expect(matches.single.transaction.description, 'Near');
      },
    );
  });

  group('authentication', () {
    test('every endpoint method rejects an anonymous session', () async {
      final account = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await endpoint.create(
        book.session,
        entry(account, amountMinor: -100),
      );
      final transfer = await endpoint.createTransfer(
        book.session,
        TransferInput(
          fromAccountId: account.id!,
          toAccountId: to.id!,
          date: _date,
          fromAmountMinor: 250,
        ),
      );
      final transferId = transfer.first.transferPeer!.transferId;
      final anonymous = server.anonymousSession();
      final query = TransactionQuery(entityId: book.entity.id!);
      final input = entry(account, amountMinor: -100);

      await expectLater(
        endpoint.create(anonymous, input),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.get(anonymous, created.transaction.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.list(anonymous, query),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.update(anonymous, created.transaction.id!, input),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.delete(anonymous, created.transaction.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.setStatus(
          anonymous,
          [created.transaction.id!],
          TransactionStatus.cleared,
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.setFlag(
          anonymous,
          [created.transaction.id!],
          TransactionFlag.blue,
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.createTransfer(
          anonymous,
          TransferInput(
            fromAccountId: account.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 100,
          ),
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.updateTransfer(
          anonymous,
          transferId,
          TransferInput(
            fromAccountId: account.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 100,
          ),
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.reconcile(anonymous, account.id!, _date, 0, false),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.findDuplicates(anonymous, account.id!, _date, -100),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });
  });

  group('foreign ownership', () {
    test("every endpoint method rejects another user's data", () async {
      final account = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await endpoint.create(
        book.session,
        entry(account, amountMinor: -100),
      );
      final transfer = await endpoint.createTransfer(
        book.session,
        TransferInput(
          fromAccountId: account.id!,
          toAccountId: to.id!,
          date: _date,
          fromAmountMinor: 250,
        ),
      );
      final transferId = transfer.first.transferPeer!.transferId;
      final other = await BudgetTestBook.create(server.anonymousSession());
      final session = other.session;
      final query = TransactionQuery(entityId: book.entity.id!);
      final input = entry(account, amountMinor: -100);

      await expectLater(
        endpoint.create(session, input),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.get(session, created.transaction.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.list(session, query),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.update(session, created.transaction.id!, input),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(session, created.transaction.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.setStatus(
          session,
          [created.transaction.id!],
          TransactionStatus.cleared,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.setFlag(
          session,
          [created.transaction.id!],
          TransactionFlag.blue,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.createTransfer(
          session,
          TransferInput(
            fromAccountId: account.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 100,
          ),
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.updateTransfer(
          session,
          transferId,
          TransferInput(
            fromAccountId: account.id!,
            toAccountId: to.id!,
            date: _date,
            fromAmountMinor: 100,
          ),
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.reconcile(session, account.id!, _date, 0, false),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.findDuplicates(session, account.id!, _date, -100),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
