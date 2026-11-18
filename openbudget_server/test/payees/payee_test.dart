import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/payees/payee_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'payee_helpers.dart';

final _day = DateTime.utc(2026, 3);

/// Captures a success value or the thrown error so two calls can race.
Future<Object> _capture(Future<Object?> future) async {
  try {
    final result = await future;
    if (result == null) {
      throw StateError('Captured a null result');
    }
    return result;
  } on Object catch (error) {
    return error;
  }
}

void main() {
  late PgTestServer server;
  late PayeeEndpoint endpoint;
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
    endpoint = PayeeEndpoint();
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

  Future<BudgetTestBook> newBook({
    String baseCurrencyCode = 'GBP',
    AccountingMode accountingMode = AccountingMode.envelope,
  }) => BudgetTestBook.create(
    server.anonymousSession(),
    baseCurrencyCode: baseCurrencyCode,
    accountingMode: accountingMode,
  );

  group('Given the payee endpoint', () {
    test(
      'when creating the same trimmed name twice then reuses one row',
      () async {
        final book = await newBook();

        final first = await endpoint.create(
          book.session,
          '  Corner Shop  ',
          book.entity.id!,
        );
        final second = await endpoint.create(
          book.session,
          'Corner Shop',
          book.entity.id!,
        );

        expect(first.name, 'Corner Shop');
        expect(first.entityId, book.entity.id);
        expect(second.id, first.id);
        expect(await book.payeeCount(book.entity.id!), 1);
        expect(events.events, isNotEmpty);
        expect(
          events.events.every(
            (event) => event.scope == ChangeScope.transactions,
          ),
          isTrue,
        );
      },
    );

    test(
      'when listing then orders by name and returns a gettable row',
      () async {
        final book = await newBook();

        final zeta = await endpoint.create(
          book.session,
          'Zeta',
          book.entity.id!,
        );
        final alpha = await endpoint.create(
          book.session,
          'Alpha',
          book.entity.id!,
        );
        final beta = await endpoint.create(
          book.session,
          'Beta',
          book.entity.id!,
        );

        final listed = await endpoint.list(book.session, book.entity.id!);

        expect(listed.map((payee) => payee.id), [alpha.id, beta.id, zeta.id]);
        expect(listed.map((payee) => payee.name), ['Alpha', 'Beta', 'Zeta']);
        expect((await endpoint.get(book.session, beta.id!)).name, 'Beta');
      },
    );

    test('when two creates race then both return the same row', () async {
      final book = await newBook();
      final secondSession = server.authenticatedSession(book.userId);
      addTearDown(secondSession.close);

      final results = await Future.wait([
        endpoint.create(book.session, 'Race', book.entity.id!),
        endpoint.create(secondSession, 'Race', book.entity.id!),
      ]);

      expect(results.first.id, results.last.id);
      expect(await book.payeeCount(book.entity.id!), 1);
    });

    test('when a name is blank then create and update reject it', () async {
      final book = await newBook();
      final payee = await book.addPayee(name: 'Before');

      await expectLater(
        endpoint.create(book.session, '   ', book.entity.id!),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(book.session, payee.id!, name: '  '),
        throwsA(isA<ValidationException>()),
      );
      expect((await endpoint.get(book.session, payee.id!)).name, 'Before');
    });

    test(
      'when renaming to a used name then rejects and keeps both rows',
      () async {
        final book = await newBook();
        final alpha = await endpoint.create(
          book.session,
          'Alpha',
          book.entity.id!,
        );
        final beta = await endpoint.create(
          book.session,
          'Beta',
          book.entity.id!,
        );

        await expectLater(
          endpoint.update(book.session, beta.id!, name: 'Alpha'),
          throwsA(isA<ValidationException>()),
        );

        expect((await endpoint.get(book.session, beta.id!)).name, 'Beta');
        expect((await endpoint.get(book.session, alpha.id!)).name, 'Alpha');
        expect(
          (await endpoint.update(
            book.session,
            beta.id!,
            name: '  Gamma  ',
          )).name,
          'Gamma',
        );
      },
    );

    test(
      'when two renames race then one keeps the name and one is rejected',
      () async {
        final book = await newBook();
        final one = await endpoint.create(book.session, 'One', book.entity.id!);
        final two = await endpoint.create(book.session, 'Two', book.entity.id!);
        final secondSession = server.authenticatedSession(book.userId);
        addTearDown(secondSession.close);

        final results = await Future.wait([
          _capture(endpoint.update(book.session, one.id!, name: 'Same')),
          _capture(endpoint.update(secondSession, two.id!, name: 'Same')),
        ]);

        expect(results.whereType<Payee>(), hasLength(1));
        expect(results.whereType<ValidationException>(), hasLength(1));
        final matching = await Payee.db.find(
          book.session,
          where: (t) =>
              t.entityId.equals(book.entity.id) & t.name.equals('Same'),
        );
        expect(matching, hasLength(1));
      },
    );

    test('when the entity is archived then every write rejects it', () async {
      final book = await newBook();
      final archived = await book.addEntity(
        archivedAt: DateTime.utc(2026),
      );
      final first = await book.addPayeeIn(archived, name: 'First');
      final second = await book.addPayeeIn(archived, name: 'Second');

      await expectLater(
        endpoint.create(book.session, 'New', archived.id!),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(book.session, first.id!, name: 'Changed'),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.merge(book.session, first.id!, second.id!),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.delete(book.session, first.id!),
        throwsA(isA<ValidationException>()),
      );
      expect(await book.payeeCount(archived.id!), 2);
    });

    test('when unauthenticated then every method requires a login', () async {
      final book = await newBook();
      final first = await book.addPayee(name: 'First');
      final second = await book.addPayee(name: 'Second');
      final anonymous = server.anonymousSession();

      await expectAuthenticationRequired(
        () => endpoint.create(anonymous, 'New', book.entity.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.list(anonymous, book.entity.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.get(anonymous, first.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.update(anonymous, first.id!, name: 'Changed'),
      );
      await expectAuthenticationRequired(
        () => endpoint.lastUsedEnvelopeId(
          anonymous,
          first.id!,
          book.entity.id!,
        ),
      );
      await expectAuthenticationRequired(
        () => endpoint.merge(anonymous, first.id!, second.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.delete(anonymous, first.id!),
      );
    });

    test('when another owner calls then every method is forbidden', () async {
      final book = await newBook();
      final mine = await book.addPayee(name: 'Mine');
      final other = await newBook();
      final theirs = await other.addPayee(name: 'Theirs');

      await expectLater(
        endpoint.create(book.session, 'New', other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.list(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.get(book.session, theirs.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.update(book.session, theirs.id!, name: 'Stolen'),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.lastUsedEnvelopeId(
          book.session,
          theirs.id!,
          other.entity.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      final otherSecond = await other.addPayee(name: 'Other second');
      await expectLater(
        endpoint.merge(book.session, theirs.id!, otherSecond.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(book.session, theirs.id!),
        throwsA(isA<ForbiddenException>()),
      );
      expect(mine.id, isNotNull);
    });
  });

  group('Given a payee last used envelope', () {
    test('when there is no coded history then returns null', () async {
      final book = await newBook();
      final payee = await book.addPayee();
      final account = await book.addAccount();

      expect(
        await endpoint.lastUsedEnvelopeId(
          book.session,
          payee.id!,
          book.entity.id!,
        ),
        isNull,
      );

      await book.addTransaction(
        account: account,
        date: _day,
        payee: payee,
      );

      expect(
        await endpoint.lastUsedEnvelopeId(
          book.session,
          payee.id!,
          book.entity.id!,
        ),
        isNull,
      );
    });

    test(
      'when transactions split and tie then picks the latest deterministically',
      () async {
        final book = await newBook();
        final payee = await book.addPayee();
        final account = await book.addAccount();
        final firstEnvelope = await book.addEnvelope(name: 'First');
        final secondEnvelope = await book.addEnvelope(name: 'Second');
        final thirdEnvelope = await book.addEnvelope(name: 'Third');

        await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3),
          payee: payee,
          lines: [
            TransactionLineInput(
              amountMinor: -100,
              envelopeId: firstEnvelope.id,
            ),
            TransactionLineInput(
              amountMinor: -900,
              envelopeId: secondEnvelope.id,
            ),
          ],
        );
        expect(
          await endpoint.lastUsedEnvelopeId(
            book.session,
            payee.id!,
            book.entity.id!,
          ),
          secondEnvelope.id,
        );

        await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 2),
          payee: payee,
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: thirdEnvelope.id,
            ),
          ],
        );
        expect(
          await endpoint.lastUsedEnvelopeId(
            book.session,
            payee.id!,
            book.entity.id!,
          ),
          secondEnvelope.id,
        );

        await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3, 2),
          payee: payee,
          lines: [
            TransactionLineInput(
              amountMinor: -500,
              envelopeId: secondEnvelope.id,
            ),
            TransactionLineInput(
              amountMinor: -500,
              envelopeId: firstEnvelope.id,
            ),
          ],
        );
        final expectedTie =
            firstEnvelope.id!.uuid.compareTo(secondEnvelope.id!.uuid) < 0
            ? firstEnvelope.id
            : secondEnvelope.id;
        expect(
          await endpoint.lastUsedEnvelopeId(
            book.session,
            payee.id!,
            book.entity.id!,
          ),
          expectedTie,
        );

        await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3, 2),
          payee: payee,
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: thirdEnvelope.id,
            ),
          ],
        );
        expect(
          await endpoint.lastUsedEnvelopeId(
            book.session,
            payee.id!,
            book.entity.id!,
          ),
          thirdEnvelope.id,
        );
      },
    );

    test('when the payee and entity disagree then returns not found', () async {
      final book = await newBook();
      final other = await newBook();
      final theirs = await other.addPayee();

      await expectLater(
        endpoint.lastUsedEnvelopeId(
          book.session,
          theirs.id!,
          book.entity.id!,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('Given a payee merge', () {
    test(
      'when the full reference graph moves then counts and facts survive',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final offBudget = await book.addAccount(
          name: 'Savings',
          onBudget: false,
        );
        final envelope = await book.addEnvelope();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        await book.addRule(payee: source, envelope: envelope);

        final ordinary = await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3),
          payee: source,
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
          ],
        );
        final reconciled = await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3, 2),
          amountMinor: -2000,
          payee: source,
          status: TransactionStatus.reconciled,
          lines: [
            TransactionLineInput(amountMinor: -2000, envelopeId: envelope.id),
          ],
        );
        final alreadyTarget = await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3, 3),
          payee: target,
        );
        final transfer = await book.addTransferWithPayee(
          from: account,
          to: offBudget,
          date: DateTime.utc(2026, 3, 4),
          envelope: envelope,
          payee: source,
        );
        final recurring = await book.addPayeeRecurring(
          account: account,
          payee: source,
          envelope: envelope,
        );

        final beforeOrdinary = await book.reloadTransaction(
          ordinary.transaction.id!,
        );
        final beforeOrdinaryLines = await book.linesOf(
          ordinary.transaction.id!,
        );
        final beforeReconciled = await book.reloadTransaction(
          reconciled.transaction.id!,
        );
        final beforeTransferFrom = transfer.from;
        final beforeTransferTo = transfer.to;
        final beforeLink = transfer.link;
        final eventCount = events.events.length;

        final changed = await endpoint.merge(
          book.session,
          source.id!,
          target.id!,
        );

        expect(changed, 3);
        expect(await book.payeeCount(book.entity.id!), 1);
        expect(await book.ruleCount(source.id!), 0);
        expect(await book.ruleCount(target.id!), 1);

        final afterOrdinary = await book.reloadTransaction(
          beforeOrdinary.id!,
        );
        expect(afterOrdinary.payeeId, target.id);
        expect(afterOrdinary.amountMinor, beforeOrdinary.amountMinor);
        expect(afterOrdinary.baseAmountMinor, beforeOrdinary.baseAmountMinor);
        expect(afterOrdinary.fxRate, beforeOrdinary.fxRate);
        expect(afterOrdinary.fxRateDate, beforeOrdinary.fxRateDate);
        expect(afterOrdinary.fxRateSource, beforeOrdinary.fxRateSource);
        expect(afterOrdinary.date, beforeOrdinary.date);
        expect(afterOrdinary.status, beforeOrdinary.status);
        expect(afterOrdinary.revision, beforeOrdinary.revision);
        expect(afterOrdinary.kind, beforeOrdinary.kind);
        final afterOrdinaryLines = await book.linesOf(beforeOrdinary.id!);
        expect(afterOrdinaryLines, hasLength(beforeOrdinaryLines.length));
        for (var index = 0; index < beforeOrdinaryLines.length; index++) {
          expect(
            afterOrdinaryLines[index].amountMinor,
            beforeOrdinaryLines[index].amountMinor,
          );
          expect(
            afterOrdinaryLines[index].baseAmountMinor,
            beforeOrdinaryLines[index].baseAmountMinor,
          );
          expect(
            afterOrdinaryLines[index].envelopeId,
            beforeOrdinaryLines[index].envelopeId,
          );
          expect(
            afterOrdinaryLines[index].sortOrder,
            beforeOrdinaryLines[index].sortOrder,
          );
        }

        final afterReconciled = await book.reloadTransaction(
          beforeReconciled.id!,
        );
        expect(afterReconciled.payeeId, target.id);
        expect(afterReconciled.status, TransactionStatus.reconciled);
        expect(afterReconciled.amountMinor, beforeReconciled.amountMinor);
        expect(afterReconciled.revision, beforeReconciled.revision);

        expect(
          (await book.reloadTransaction(alreadyTarget.transaction.id!)).payeeId,
          target.id,
        );

        final afterTransferFrom = await book.reloadTransaction(
          beforeTransferFrom.id!,
        );
        final afterTransferTo = await book.reloadTransaction(
          beforeTransferTo.id!,
        );
        expect(afterTransferFrom.payeeId, target.id);
        expect(afterTransferFrom.amountMinor, beforeTransferFrom.amountMinor);
        expect(
          afterTransferFrom.baseAmountMinor,
          beforeTransferFrom.baseAmountMinor,
        );
        expect(afterTransferFrom.fxRate, beforeTransferFrom.fxRate);
        expect(afterTransferFrom.status, beforeTransferFrom.status);
        expect(afterTransferTo.payeeId, beforeTransferTo.payeeId);
        expect(afterTransferTo.amountMinor, beforeTransferTo.amountMinor);
        final afterLink = await Transfer.db.findById(
          book.session,
          beforeLink.id!,
        );
        expect(afterLink?.fromTransactionId, beforeLink.fromTransactionId);
        expect(afterLink?.toTransactionId, beforeLink.toTransactionId);

        final afterRecurring = await RecurringTransaction.db.findById(
          book.session,
          recurring.id!,
        );
        expect(afterRecurring?.payeeId, target.id);
        expect(afterRecurring?.envelopeId, envelope.id);

        await book.expectBalancesConsistent();
        expect(events.events.length, greaterThan(eventCount));
        expect(
          events.events.every(
            (event) => event.scope == ChangeScope.transactions,
          ),
          isTrue,
        );
      },
    );

    test('when rules are identical then collapses them without loss', () async {
      final book = await newBook();
      final envelope = await book.addEnvelope();
      final source = await book.addPayee(name: 'Source');
      final target = await book.addPayee(name: 'Target');
      final sourceRule = await book.addRule(payee: source, envelope: envelope);
      final targetRule = await book.addRule(payee: target, envelope: envelope);

      await endpoint.merge(book.session, source.id!, target.id!);

      expect(
        await TransactionRule.db.findById(book.session, sourceRule.id!),
        isNull,
      );
      final kept = await TransactionRule.db.findById(
        book.session,
        targetRule.id!,
      );
      expect(kept?.payeeId, target.id);
      expect(kept?.envelopeId, envelope.id);
      expect(kept?.enabled, isTrue);
    });

    test(
      'when rules differ then rejects and rolls the whole merge back',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final first = await book.addEnvelope(name: 'First');
        final second = await book.addEnvelope(name: 'Second');
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        final sourceRule = await book.addRule(payee: source, envelope: first);
        final targetRule = await book.addRule(payee: target, envelope: second);
        final transaction = await book.addTransaction(
          account: account,
          date: _day,
          payee: source,
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: first.id),
          ],
        );
        final recurring = await book.addPayeeRecurring(
          account: account,
          payee: source,
          envelope: first,
        );
        final eventCount = events.events.length;

        await expectLater(
          endpoint.merge(book.session, source.id!, target.id!),
          throwsA(isA<ValidationException>()),
        );

        expect(await book.payeeCount(book.entity.id!), 2);
        expect(
          (await book.reloadTransaction(transaction.transaction.id!)).payeeId,
          source.id,
        );
        expect(
          (await RecurringTransaction.db.findById(
            book.session,
            recurring.id!,
          ))?.payeeId,
          source.id,
        );
        expect(
          (await TransactionRule.db.findById(
            book.session,
            sourceRule.id!,
          ))?.envelopeId,
          first.id,
        );
        expect(
          (await TransactionRule.db.findById(
            book.session,
            targetRule.id!,
          ))?.envelopeId,
          second.id,
        );
        expect(events.events.length, eventCount);
      },
    );

    test(
      'when rules differ only by enabled then rejects without loss',
      () async {
        final book = await newBook();
        final envelope = await book.addEnvelope();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        final sourceRule = await book.addRule(
          payee: source,
          envelope: envelope,
        );
        final targetRule = await book.addRule(
          payee: target,
          envelope: envelope,
          enabled: false,
        );

        await expectLater(
          endpoint.merge(book.session, source.id!, target.id!),
          throwsA(isA<ValidationException>()),
        );

        expect(
          (await TransactionRule.db.findById(
            book.session,
            sourceRule.id!,
          ))?.enabled,
          isTrue,
        );
        expect(
          (await TransactionRule.db.findById(
            book.session,
            targetRule.id!,
          ))?.enabled,
          isFalse,
        );
      },
    );

    test(
      'when the payees are the same or in different entities then rejects',
      () async {
        final book = await newBook();
        final source = await book.addPayee(name: 'Source');
        final other = await newBook();
        final target = await other.addPayee(name: 'Target');

        await expectLater(
          endpoint.merge(book.session, source.id!, source.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoint.merge(book.session, source.id!, target.id!),
          throwsA(isA<ValidationException>()),
        );
        expect(await book.payeeCount(book.entity.id!), 1);
        expect(await other.payeeCount(other.entity.id!), 1);
      },
    );

    test(
      'when FX rates are gone then keeps the stored manual rate and revision',
      () async {
        final book = await newBook(accountingMode: AccountingMode.ledger);
        final account = await book.addAccount(currencyCode: 'USD');
        final envelope = await book.addEnvelope();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        final transaction = await book.addTransaction(
          account: account,
          date: _day,
          payee: source,
          fxRate: '0.8',
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
          ],
        );
        final before = await book.reloadTransaction(
          transaction.transaction.id!,
        );
        expect(before.fxRateSource, FxRateSource.manual);
        expect(before.fxRate, '0.8');
        expect(before.baseAmountMinor, -800);
        expect(before.revision, 0);

        await book.session.caches.clear();
        await server.clearRates();

        expect(await endpoint.merge(book.session, source.id!, target.id!), 1);

        final after = await book.reloadTransaction(transaction.transaction.id!);
        expect(after.payeeId, target.id);
        expect(after.fxRate, before.fxRate);
        expect(after.fxRateDate, before.fxRateDate);
        expect(after.fxRateSource, before.fxRateSource);
        expect(after.baseAmountMinor, before.baseAmountMinor);
        expect(after.revision, before.revision);
        await book.expectBalancesConsistent();
      },
    );

    test(
      'when two opposite merges race then one row and its references survive',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final envelope = await book.addEnvelope();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        final transaction = await book.addTransaction(
          account: account,
          date: _day,
          payee: source,
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
          ],
        );
        final secondSession = server.authenticatedSession(book.userId);
        addTearDown(secondSession.close);

        final results = await Future.wait([
          _capture(endpoint.merge(book.session, source.id!, target.id!)),
          _capture(endpoint.merge(secondSession, target.id!, source.id!)),
        ]);

        expect(results.whereType<int>(), hasLength(1));
        expect(
          results.where(
            (result) =>
                result is NotFoundException || result is ValidationException,
          ),
          hasLength(1),
        );
        final payees = await Payee.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        );
        expect(payees, hasLength(1));
        expect(
          (await book.reloadTransaction(transaction.transaction.id!)).payeeId,
          payees.single.id,
        );
        await book.expectBalancesConsistent();
      },
    );

    test(
      'when a merge races a writer then no deadlock or dangling payee remains',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final envelope = await book.addEnvelope();
        final source = await book.addPayee(name: 'Source');
        final target = await book.addPayee(name: 'Target');
        await book.addRule(payee: source, envelope: envelope);
        await book.addTransaction(
          account: account,
          date: _day,
          payee: source,
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
          ],
        );
        final secondSession = server.authenticatedSession(book.userId);
        addTearDown(secondSession.close);

        final results = await Future.wait([
          _capture(endpoint.merge(book.session, source.id!, target.id!)),
          _capture(
            TransactionWriter.create(
              secondSession,
              TransactionInput(
                accountId: account.id!,
                date: DateTime.utc(2026, 3, 2),
                amountMinor: -500,
                payeeId: source.id,
                lines: const [],
              ),
            ),
          ),
        ]);

        for (final result in results) {
          expect(result, isNot(isA<DatabaseException>()));
        }
        expect(
          results.where((result) => result is int || result is TransactionView),
          isNotEmpty,
        );

        final payees = await Payee.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        );
        final payeeIds = {for (final payee in payees) payee.id};
        final rows = await model.Transaction.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        );
        for (final row in rows) {
          if (row.payeeId != null) expect(payeeIds, contains(row.payeeId));
        }
        await book.expectBalancesConsistent();
      },
    );
  });

  group('Given a payee delete', () {
    test(
      'when deleting then nulls references, drops the rule and keeps history',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final envelope = await book.addEnvelope();
        final payee = await book.addPayee();
        final rule = await book.addRule(payee: payee, envelope: envelope);
        final transaction = await book.addTransaction(
          account: account,
          date: _day,
          payee: payee,
          lines: [
            TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
          ],
        );
        final recurring = await book.addPayeeRecurring(
          account: account,
          payee: payee,
          envelope: envelope,
        );
        final before = await book.reloadTransaction(
          transaction.transaction.id!,
        );
        final beforeLines = await book.linesOf(transaction.transaction.id!);
        final eventCount = events.events.length;

        final deleted = await endpoint.delete(book.session, payee.id!);

        expect(deleted.id, payee.id);
        expect(await Payee.db.findById(book.session, payee.id!), isNull);
        final after = await book.reloadTransaction(before.id!);
        expect(after.payeeId, isNull);
        expect(after.amountMinor, before.amountMinor);
        expect(after.baseAmountMinor, before.baseAmountMinor);
        expect(after.fxRate, before.fxRate);
        expect(after.date, before.date);
        expect(after.status, before.status);
        final afterLines = await book.linesOf(before.id!);
        expect(afterLines, hasLength(beforeLines.length));
        for (var index = 0; index < beforeLines.length; index++) {
          expect(afterLines[index].amountMinor, beforeLines[index].amountMinor);
          expect(afterLines[index].envelopeId, beforeLines[index].envelopeId);
        }
        expect(
          (await RecurringTransaction.db.findById(
            book.session,
            recurring.id!,
          ))?.payeeId,
          isNull,
        );
        expect(
          await TransactionRule.db.findById(book.session, rule.id!),
          isNull,
        );
        await book.expectBalancesConsistent();
        expect(events.events.length, greaterThan(eventCount));
        expect(
          events.events.every(
            (event) => event.scope == ChangeScope.transactions,
          ),
          isTrue,
        );
      },
    );
  });
}
