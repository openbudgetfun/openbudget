import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/envelopes/envelope_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'catalogue_helpers.dart';

void main() {
  late PgTestServer server;
  late EnvelopeEndpoint endpoint;
  late EventLog events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() {
    events = EventLog()..install();
    endpoint = EnvelopeEndpoint();
  });

  tearDown(() {
    events.reset();
  });

  Future<BudgetTestBook> newBook({
    AccountingMode accountingMode = AccountingMode.envelope,
  }) => BudgetTestBook.create(
    server.anonymousSession(),
    accountingMode: accountingMode,
  );

  Future<model.Transaction> createExpense(
    BudgetTestBook book, {
    required Account account,
    required Envelope envelope,
    required int amountMinor,
    DateTime? date,
  }) async {
    final view = await TransactionWriter.create(
      book.session,
      TransactionInput(
        accountId: account.id!,
        date: date ?? EntityClock.today(book.entity),
        amountMinor: amountMinor,
        lines: [
          TransactionLineInput(
            amountMinor: amountMinor,
            envelopeId: envelope.id,
          ),
        ],
      ),
    );

    return view.transaction;
  }

  test('reassign moves every reference and preserves stored money', () async {
    final book = await newBook();
    final account = await book.addAccount();
    final sourceCategory = await book.addCategory(name: 'Source');
    final destinationCategory = await book.addCategory(name: 'Destination');
    final source = await book.addEnvelopeIn(sourceCategory, name: 'Old');
    final destination = await book.addEnvelopeIn(
      destinationCategory,
      name: 'New',
    );
    await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
    await book.addAllocation(destination, month: 202611, allocatedMinor: 2500);
    await book.addAllocation(source, month: 202612, allocatedMinor: 700);
    await book.addGoal(source, amountMinor: 5000);
    final payee = await book.addPayee();
    await book.addRule(payee: payee, envelope: source);
    await book.addRecurring(source, account: account);
    final template = await book.addTemplate();
    await book.addTemplateLine(template, source, allocatedMinor: 1000);
    await book.addTemplateLine(template, destination, allocatedMinor: 2500);

    final created = await createExpense(
      book,
      account: account,
      envelope: source,
      amountMinor: -1000,
    );
    final beforeLine = (await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(created.id),
    )).single;
    final beforeBalance = (await book.reload(account)).balanceMinor;
    events.events.clear();

    await endpoint.delete(
      book.session,
      source.id!,
      reassignToEnvelopeId: destination.id,
    );

    expect(await Envelope.db.findById(book.session, source.id!), isNull);
    expect(
      await Envelope.db.findById(book.session, destination.id!),
      isNotNull,
    );

    final afterHeader = await model.Transaction.db.findById(
      book.session,
      created.id!,
    );
    expect(afterHeader, isNotNull);
    expect(afterHeader!.amountMinor, created.amountMinor);
    expect(afterHeader.baseAmountMinor, created.baseAmountMinor);
    expect(afterHeader.fxRate, created.fxRate);
    expect(afterHeader.date, created.date);
    expect(afterHeader.accountId, created.accountId);
    expect((await book.reload(account)).balanceMinor, beforeBalance);

    final afterLines = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(created.id),
    );
    expect(afterLines, hasLength(1));
    expect(afterLines.single.envelopeId, destination.id);
    expect(afterLines.single.amountMinor, beforeLine.amountMinor);
    expect(afterLines.single.baseAmountMinor, beforeLine.baseAmountMinor);

    final allocations = await MonthlyAllocation.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
      orderBy: (t) => t.month,
    );
    expect(
      {for (final row in allocations) row.month: row.allocatedMinor},
      {202611: 3500, 202612: 700},
    );

    final goals = await EnvelopeGoal.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
    );
    expect(goals, hasLength(1));
    expect(goals.single.envelopeId, destination.id);

    final rules = await TransactionRule.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
    );
    expect(rules.single.envelopeId, destination.id);

    final recurring = await RecurringTransaction.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
    );
    expect(recurring.single.envelopeId, destination.id);

    final templateLines = await BudgetTemplateLine.db.find(
      book.session,
      where: (t) => t.templateId.equals(template.id),
    );
    expect(templateLines, hasLength(1));
    expect(templateLines.single.envelopeId, destination.id);
    expect(templateLines.single.allocatedMinor, 3500);

    expect(events.planMonths, containsAll([202611, 202612]));
    expect(events.events.last.scope, ChangeScope.plan);
  });

  test('reassign announces months only after the row is gone', () async {
    final book = await newBook();
    final account = await book.addAccount();
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
    final created = await createExpense(
      book,
      account: account,
      envelope: source,
      amountMinor: -500,
    );
    events.events.clear();

    EntityRealtimeNotifier.debugPublisher =
        (session, entityId, scope, {month, accountId}) async {
          await events.record(
            session,
            entityId,
            scope,
            month: month,
            accountId: accountId,
          );
          if (scope == ChangeScope.plan && month == null) {
            expect(
              await Envelope.db.findById(book.session, source.id!),
              isNull,
            );
          }
          if (scope == ChangeScope.plan && month == 202611) {
            final lines = await TransactionLine.db.find(
              book.session,
              where: (t) => t.transactionId.equals(created.id),
            );
            expect(lines.single.envelopeId, destination.id);
          }
        };

    await endpoint.delete(
      book.session,
      source.id!,
      reassignToEnvelopeId: destination.id,
    );

    expect(events.planMonths, contains(202611));
  });

  test(
    'ledger reassignment preserves FX and writes one revision audit',
    () async {
      final book = await newBook(accountingMode: AccountingMode.ledger);
      final opened = EntityClock.today(book.entity).subtract(
        const Duration(days: 2),
      );
      await book.seedMarketRate(
        fromCurrencyCode: 'EUR',
        toCurrencyCode: 'GBP',
        rateDate: opened,
        fromPerUsd: '1.1',
        toPerUsd: '0.8',
      );
      final account = await book.addAccount(
        name: 'Euro account',
        currencyCode: 'EUR',
      );
      final source = await book.addEnvelopeIn(await book.addCategory());
      final destination = await book.addEnvelopeIn(await book.addCategory());
      final created = await createExpense(
        book,
        account: account,
        envelope: source,
        amountMinor: -1000,
        date: opened,
      );
      final beforeBalance = (await book.reload(account)).balanceMinor;
      expect(created.fxRate, isNot('1'));
      events.events.clear();

      await endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      );

      final after = await model.Transaction.db.findById(
        book.session,
        created.id!,
      );
      expect(after!.fxRate, created.fxRate);
      expect(after.baseAmountMinor, created.baseAmountMinor);
      expect(after.amountMinor, created.amountMinor);
      expect(after.revision, created.revision + 1);
      expect((await book.reload(account)).balanceMinor, beforeBalance);

      final audit = await AuditEvent.db.find(
        book.session,
        where: (t) =>
            t.entityId.equals(book.entity.id) & t.subjectId.equals(created.id),
      );
      expect(audit, hasLength(1));
      expect(audit.single.action, AuditAction.transactionEdited);
      expect(audit.single.payloadJson, contains('before'));
    },
  );

  test('a transfer leg moves through the transfer writer', () async {
    final book = await newBook(accountingMode: AccountingMode.ledger);
    final onBudget = await book.addAccount();
    final offBudget = await book.addAccount(name: 'Savings', onBudget: false);
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    final date = EntityClock.today(book.entity);

    final legs = await TransactionWriter.createTransfer(
      book.session,
      TransferInput(
        fromAccountId: onBudget.id!,
        toAccountId: offBudget.id!,
        date: date,
        fromAmountMinor: 500,
        envelopeId: source.id,
      ),
    );
    final from = legs.first.transaction;
    final to = legs.last.transaction;
    final fromBalance = (await book.reload(onBudget)).balanceMinor;
    final toBalance = (await book.reload(offBudget)).balanceMinor;
    events.events.clear();

    await endpoint.delete(
      book.session,
      source.id!,
      reassignToEnvelopeId: destination.id,
    );

    expect(
      await Transfer.db.findFirstRow(
        book.session,
        where: (t) => t.fromTransactionId.equals(from.id),
      ),
      isNotNull,
    );
    final fromLines = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(from.id),
    );
    final toLines = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(to.id),
    );
    expect(fromLines.single.envelopeId, destination.id);
    expect(toLines.single.envelopeId, isNull);
    expect((await book.reload(onBudget)).balanceMinor, fromBalance);
    expect((await book.reload(offBudget)).balanceMinor, toBalance);
    expect(
      (await model.Transaction.db.findById(book.session, from.id!))!.revision,
      from.revision + 1,
    );
  });

  test(
    'a transfer keeps each leg metadata when its envelope moves',
    () async {
      final book = await newBook(accountingMode: AccountingMode.ledger);
      final onBudget = await book.addAccount();
      final offBudget = await book.addAccount(
        name: 'Brokerage',
        onBudget: false,
      );
      final source = await book.addEnvelopeIn(await book.addCategory());
      final destination = await book.addEnvelopeIn(await book.addCategory());
      final outflowPayee = await book.addPayee(name: 'Broker fee');
      final inflowPayee = await book.addPayee(name: 'Broker sweep');
      final date = EntityClock.today(book.entity);

      final legs = await TransactionWriter.createTransfer(
        book.session,
        TransferInput(
          fromAccountId: onBudget.id!,
          toAccountId: offBudget.id!,
          date: date,
          fromAmountMinor: 500,
          envelopeId: source.id,
        ),
      );
      final from = legs.first.transaction;
      final to = legs.last.transaction;

      await TransactionWriter.update(
        book.session,
        from.id!,
        TransactionInput(
          accountId: onBudget.id!,
          date: date,
          amountMinor: -500,
          status: TransactionStatus.cleared,
          memo: 'Outflow memo',
          flag: TransactionFlag.blue,
          payeeId: outflowPayee.id,
          description: 'Broker fee',
          lines: const [],
        ),
      );
      await TransactionWriter.update(
        book.session,
        to.id!,
        TransactionInput(
          accountId: offBudget.id!,
          date: date,
          amountMinor: 500,
          status: TransactionStatus.uncleared,
          memo: 'Inflow memo',
          flag: TransactionFlag.green,
          payeeId: inflowPayee.id,
          description: 'Broker sweep',
          lines: const [],
        ),
      );

      final beforeFrom = (await model.Transaction.db.findById(
        book.session,
        from.id!,
      ))!;
      final beforeTo = (await model.Transaction.db.findById(
        book.session,
        to.id!,
      ))!;
      final fromBalance = (await book.reload(onBudget)).balanceMinor;
      final toBalance = (await book.reload(offBudget)).balanceMinor;
      events.events.clear();

      await endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      );

      expect(await Envelope.db.findById(book.session, source.id!), isNull);
      final afterFrom = (await model.Transaction.db.findById(
        book.session,
        from.id!,
      ))!;
      final afterTo = (await model.Transaction.db.findById(
        book.session,
        to.id!,
      ))!;

      expect(afterFrom.status, TransactionStatus.cleared);
      expect(afterFrom.memo, 'Outflow memo');
      expect(afterFrom.flag, TransactionFlag.blue);
      expect(afterFrom.payeeId, outflowPayee.id);
      expect(afterFrom.description, 'Broker fee');
      expect(afterTo.status, TransactionStatus.uncleared);
      expect(afterTo.memo, 'Inflow memo');
      expect(afterTo.flag, TransactionFlag.green);
      expect(afterTo.payeeId, inflowPayee.id);
      expect(afterTo.description, 'Broker sweep');

      for (final before in [beforeFrom, beforeTo]) {
        final after = before.id == from.id ? afterFrom : afterTo;
        expect(after.amountMinor, before.amountMinor);
        expect(after.baseAmountMinor, before.baseAmountMinor);
        expect(after.fxRate, before.fxRate);
        expect(after.fxRateDate, before.fxRateDate);
        expect(after.fxRateSource, before.fxRateSource);
        expect(after.date, before.date);
        expect(after.accountId, before.accountId);
        expect(after.entityId, before.entityId);
      }
      expect(afterFrom.revision, beforeFrom.revision + 1);
      expect(afterTo.revision, beforeTo.revision);

      final fromLine = (await TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.equals(from.id),
      )).single;
      final toLine = (await TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.equals(to.id),
      )).single;
      expect(fromLine.envelopeId, destination.id);
      expect(fromLine.amountMinor, -500);
      expect(fromLine.baseAmountMinor, beforeFrom.baseAmountMinor);
      expect(toLine.envelopeId, isNull);
      expect(toLine.amountMinor, 500);

      expect((await book.reload(onBudget)).balanceMinor, fromBalance);
      expect((await book.reload(offBudget)).balanceMinor, toBalance);

      final audits = await AuditEvent.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(audits, hasLength(1));
      expect(audits.single.action, AuditAction.transactionEdited);
      expect(audits.single.subjectId, from.id);
      expect(audits.single.payloadJson, contains('before'));

      final transactionEvents = events.events
          .where((event) => event.scope == ChangeScope.transactions)
          .toList();
      expect(transactionEvents, hasLength(1));
      expect(transactionEvents.single.entityId, book.entity.id);
      expect(transactionEvents.single.accountId, onBudget.id);
      expect(transactionEvents.single.month, MonthKey.fromDate(date));
    },
  );

  test('a reconciled transfer peer rejects the whole reassignment', () async {
    final book = await newBook(accountingMode: AccountingMode.ledger);
    final onBudget = await book.addAccount();
    final offBudget = await book.addAccount(
      name: 'Brokerage',
      onBudget: false,
    );
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    final date = EntityClock.today(book.entity);

    final legs = await TransactionWriter.createTransfer(
      book.session,
      TransferInput(
        fromAccountId: onBudget.id!,
        toAccountId: offBudget.id!,
        date: date,
        fromAmountMinor: 500,
        envelopeId: source.id,
      ),
    );
    final from = legs.first.transaction;
    final to = legs.last.transaction;
    await TransactionWriter.update(
      book.session,
      to.id!,
      TransactionInput(
        accountId: offBudget.id!,
        date: date,
        amountMinor: 500,
        status: TransactionStatus.reconciled,
        lines: const [],
      ),
    );
    final beforeFrom = (await model.Transaction.db.findById(
      book.session,
      from.id!,
    ))!;
    final beforeTo = (await model.Transaction.db.findById(
      book.session,
      to.id!,
    ))!;
    final fromBalance = (await book.reload(onBudget)).balanceMinor;
    final toBalance = (await book.reload(offBudget)).balanceMinor;
    events.events.clear();

    await expectLater(
      endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
    final line = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(from.id),
    );
    expect(line.single.envelopeId, source.id);
    final afterFrom = (await model.Transaction.db.findById(
      book.session,
      from.id!,
    ))!;
    final afterTo = (await model.Transaction.db.findById(
      book.session,
      to.id!,
    ))!;
    expect(afterFrom.revision, beforeFrom.revision);
    expect(afterTo.revision, beforeTo.revision);
    expect(afterFrom.status, beforeFrom.status);
    expect(afterTo.status, TransactionStatus.reconciled);
    expect((await book.reload(onBudget)).balanceMinor, fromBalance);
    expect((await book.reload(offBudget)).balanceMinor, toBalance);
    expect(
      await AuditEvent.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      0,
    );
    expect(events.events, isEmpty);
  });

  test('a conflicting goal rejects the whole reassignment', () async {
    final book = await newBook();
    final account = await book.addAccount();
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
    await book.addAllocation(destination, month: 202611, allocatedMinor: 2500);
    await book.addGoal(source, amountMinor: 5000);
    await book.addGoal(
      destination,
      kind: EnvelopeGoalKind.targetBalance,
      amountMinor: 9000,
    );
    await createExpense(
      book,
      account: account,
      envelope: source,
      amountMinor: -500,
    );
    events.events.clear();

    await expectLater(
      endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
    final allocations = await MonthlyAllocation.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
      orderBy: (t) => t.envelopeId,
    );
    expect(allocations, hasLength(2));
    expect(
      allocations
          .firstWhere((row) => row.envelopeId == destination.id)
          .allocatedMinor,
      2500,
    );
    final lines = await TransactionLine.db.find(
      book.session,
      where: (t) => t.envelopeId.equals(source.id),
    );
    expect(lines, hasLength(1));
    expect(events.events, isEmpty);
  });

  test('a reconciled line rejects the whole reassignment', () async {
    final book = await newBook();
    final account = await book.addAccount();
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
    final created = await createExpense(
      book,
      account: account,
      envelope: source,
      amountMinor: -500,
    );
    await model.Transaction.db.updateRow(
      book.session,
      created.copyWith(status: TransactionStatus.reconciled),
    );
    events.events.clear();

    await expectLater(
      endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
    final line = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(created.id),
    );
    expect(line.single.envelopeId, source.id);
    expect(
      (await MonthlyAllocation.db.find(
        book.session,
        where: (t) => t.envelopeId.equals(source.id),
      )).single.allocatedMinor,
      1000,
    );
    expect(events.events, isEmpty);
  });

  test('a period lock rejects the whole reassignment', () async {
    final book = await newBook(accountingMode: AccountingMode.ledger);
    final account = await book.addAccount();
    final source = await book.addEnvelopeIn(await book.addCategory());
    final destination = await book.addEnvelopeIn(await book.addCategory());
    final created = await createExpense(
      book,
      account: account,
      envelope: source,
      amountMinor: -500,
      date: EntityClock.today(book.entity).subtract(const Duration(days: 1)),
    );
    await book.addPeriodLock(EntityClock.today(book.entity));
    events.events.clear();

    await expectLater(
      endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
    final stored = await model.Transaction.db.findById(
      book.session,
      created.id!,
    );
    expect(stored!.revision, created.revision);
    expect(
      await AuditEvent.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      0,
    );
    expect(events.events, isEmpty);
  });

  test(
    'destination validation rejects itself, a missing id and a foreign id',
    () async {
      final book = await newBook();
      final source = await book.addEnvelopeIn(await book.addCategory());
      final other = await BudgetTestBook.create(server.anonymousSession());
      final foreign = await other.addEnvelopeIn(await other.addCategory());

      await expectLater(
        endpoint.delete(
          book.session,
          source.id!,
          reassignToEnvelopeId: source.id,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.delete(
          book.session,
          source.id!,
          reassignToEnvelopeId: const Uuid().v7obj(),
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.delete(
          book.session,
          source.id!,
          reassignToEnvelopeId: foreign.id,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
    },
  );

  test(
    'identical goals merge while a zero allocation disappears',
    () async {
      final book = await newBook();
      final source = await book.addEnvelopeIn(await book.addCategory());
      final destination = await book.addEnvelopeIn(await book.addCategory());
      await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
      await book.addAllocation(
        destination,
        month: 202611,
        allocatedMinor: -1000,
      );
      await book.addGoal(source, amountMinor: 5000);
      await book.addGoal(destination, amountMinor: 5000);
      final payee = await book.addPayee();
      await book.addRule(payee: payee, envelope: source);

      await endpoint.delete(
        book.session,
        source.id!,
        reassignToEnvelopeId: destination.id,
      );

      expect(
        await MonthlyAllocation.db.count(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        ),
        0,
      );
      final goals = await EnvelopeGoal.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(goals, hasLength(1));
      expect(goals.single.envelopeId, destination.id);
      final rules = await TransactionRule.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(rules, hasLength(1));
      expect(rules.single.envelopeId, destination.id);
    },
  );
}
