import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import '../support/tax_test_book.dart';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late TaxEndpoint endpoint;
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
    events = [];
    TransactionWriter.debugPublisher =
        (_, entityId, scope, {month, accountId}) async {
          events.add(
            EntityChangedEvent(
              entityId: entityId,
              scope: scope,
              month: month,
              accountId: accountId,
            ),
          );
        };
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.utc(2026, 11, 11);
    book = await BudgetTestBook.create(server.anonymousSession());
    await saveTaxProfile(book.session, book.entity);
    endpoint = TaxEndpoint();
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  group('when coding one line', () {
    test('then code, business use and sales tax are stored exactly', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      events.clear();

      final updated = await endpoint.setLineTax(
        book.session,
        line.id!,
        taxCategoryCode: 'gb.ind.employment',
        businessUsePercent: 50,
        salesTaxMinor: -2000,
      );

      final coded = taxLine(updated);
      expect(coded.taxCategoryCode, 'gb.ind.employment');
      expect(coded.businessUsePercent, 50);
      expect(coded.salesTaxMinor, -2000);
      expect(updated.transaction.amountMinor, view.transaction.amountMinor);
      expect(events.single.scope, ChangeScope.transactions);
    });

    test('then null leaves the other fields unchanged', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      final first = await endpoint.setLineTax(
        book.session,
        line.id!,
        taxCategoryCode: 'gb.ind.employment',
        businessUsePercent: 50,
        salesTaxMinor: -2000,
      );

      final updated = await endpoint.setLineTax(
        book.session,
        taxLine(first).id!,
      );

      final coded = taxLine(updated);
      expect(coded.taxCategoryCode, 'gb.ind.employment');
      expect(coded.businessUsePercent, 50);
      expect(coded.salesTaxMinor, -2000);
    });

    test('then the clear flag clears only the category', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      final first = await endpoint.setLineTax(
        book.session,
        line.id!,
        taxCategoryCode: 'gb.ind.employment',
        businessUsePercent: 50,
        salesTaxMinor: -2000,
      );

      final updated = await endpoint.setLineTax(
        book.session,
        taxLine(first).id!,
        clearTaxCategoryCode: true,
      );

      final coded = taxLine(updated);
      expect(coded.taxCategoryCode, isNull);
      expect(coded.businessUsePercent, 50);
      expect(coded.salesTaxMinor, -2000);
    });

    test('then a code and the clear flag together reject', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);

      await expectLater(
        endpoint.setLineTax(
          book.session,
          taxLine(view).id!,
          taxCategoryCode: 'gb.ind.employment',
          clearTaxCategoryCode: true,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then business use outside 0-100 rejects without a write', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      events.clear();

      for (final value in [-1, 101]) {
        await expectLater(
          endpoint.setLineTax(
            book.session,
            line.id!,
            taxCategoryCode: 'gb.ind.employment',
            businessUsePercent: value,
          ),
          throwsA(isA<ValidationException>()),
        );
      }

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.taxCategoryCode, isNull);
      expect(events, isEmpty);
    });

    test('then sales tax outside the line sign and size rejects', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);

      for (final value in [2000, -10001]) {
        await expectLater(
          endpoint.setLineTax(
            book.session,
            line.id!,
            salesTaxMinor: value,
          ),
          throwsA(isA<ValidationException>()),
        );
      }

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.salesTaxMinor, isNull);
    });

    test('then an unknown or foreign-kind code rejects', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);

      await expectLater(
        endpoint.setLineTax(
          book.session,
          line.id!,
          taxCategoryCode: 'gb.unknown',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.setLineTax(
          book.session,
          line.id!,
          taxCategoryCode: 'gb.co.turnover',
        ),
        throwsA(isA<ValidationException>()),
      );

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.taxCategoryCode, isNull);
    });
  });

  group('when a transaction has several lines', () {
    test('then coding one preserves every other fact exactly', () async {
      final account = await book.addAccount(
        name: 'US checking',
        currencyCode: 'USD',
      );
      final first = await book.addEnvelope(name: 'First');
      final second = await book.addEnvelope(name: 'Second');
      final third = await book.addEnvelope(name: 'Third');
      final view = await createTaxTransaction(
        book.session,
        account,
        amountMinor: -30000,
        fxRate: '0.8',
        description: 'Three lines',
        lines: [
          TransactionLineInput(
            amountMinor: -10000,
            envelopeId: first.id,
            taxCategoryCode: 'gb.ind.employment',
            businessUsePercent: 25,
            salesTaxMinor: -1000,
            memo: 'first',
          ),
          TransactionLineInput(
            amountMinor: -12000,
            envelopeId: second.id,
            taxCategoryCode: 'gb.ind.self_employment',
            businessUsePercent: 50,
            salesTaxMinor: -2000,
            memo: 'second',
          ),
          TransactionLineInput(
            amountMinor: -8000,
            envelopeId: third.id,
            taxCategoryCode: 'gb.ind.property',
            memo: 'third',
          ),
        ],
      );
      final before = view.lines;
      final headerBefore = view.transaction;
      final balanceBefore = await book.cachedBalanceMinor(account);

      final updated = await endpoint.setLineTax(
        book.session,
        before[1].id!,
        taxCategoryCode: 'gb.ind.tax_paid',
        businessUsePercent: 75,
        salesTaxMinor: -3000,
      );

      final after = updated.lines;
      expect(after, hasLength(3));
      expect(updated.transaction.amountMinor, headerBefore.amountMinor);
      expect(updated.transaction.baseAmountMinor, headerBefore.baseAmountMinor);
      expect(updated.transaction.fxRate, headerBefore.fxRate);
      expect(updated.transaction.fxRateDate, headerBefore.fxRateDate);
      expect(updated.transaction.fxRateSource, headerBefore.fxRateSource);
      expect(updated.transaction.date, headerBefore.date);
      expect(updated.transaction.accountId, headerBefore.accountId);
      expect(updated.transaction.description, headerBefore.description);
      expect(await book.cachedBalanceMinor(account), balanceBefore);

      for (final index in [0, 2]) {
        expect(after[index].amountMinor, before[index].amountMinor);
        expect(after[index].baseAmountMinor, before[index].baseAmountMinor);
        expect(after[index].envelopeId, before[index].envelopeId);
        expect(after[index].taxCategoryCode, before[index].taxCategoryCode);
        expect(
          after[index].businessUsePercent,
          before[index].businessUsePercent,
        );
        expect(after[index].salesTaxMinor, before[index].salesTaxMinor);
        expect(after[index].memo, before[index].memo);
      }

      expect(after[1].taxCategoryCode, 'gb.ind.tax_paid');
      expect(after[1].businessUsePercent, 75);
      expect(after[1].salesTaxMinor, -3000);
      expect(await book.lineCount(headerBefore.id!), 3);
    });
  });

  group('when the writer rules reject', () {
    test('then a reconciled transaction stays untouched', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      await book.session.db.unsafeExecute(
        'UPDATE "transaction" SET status = \'reconciled\' WHERE id = @id::uuid',
        parameters: QueryParameters.named({
          'id': view.transaction.id!.toString(),
        }),
      );

      await expectLater(
        endpoint.setLineTax(
          book.session,
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(isA<ValidationException>()),
      );

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.taxCategoryCode, isNull);
    });

    test('then a period-locked date stays untouched', () async {
      final ledgerBook = await BudgetTestBook.create(
        server.anonymousSession(),
        accountingMode: AccountingMode.ledger,
      );
      await saveTaxProfile(ledgerBook.session, ledgerBook.entity);
      final account = await ledgerBook.addAccount();
      final view = await createTaxTransaction(
        ledgerBook.session,
        account,
        date: DateTime.utc(2026, 6, 15),
      );
      final line = taxLine(view);
      await ledgerBook.addPeriodLock(DateTime.utc(2026, 6, 30));

      await expectLater(
        endpoint.setLineTax(
          ledgerBook.session,
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(isA<ValidationException>()),
      );

      final stored = await TransactionLine.db.findById(
        ledgerBook.session,
        line.id!,
      );
      expect(stored?.taxCategoryCode, isNull);
    });

    test('then a transfer leg rejects and keeps its history', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final legs = await TransactionWriter.createTransfer(
        book.session,
        TransferInput(
          fromAccountId: from.id!,
          toAccountId: to.id!,
          date: DateTime.utc(2026, 6, 15),
          fromAmountMinor: 5000,
        ),
      );
      final line = legs.first.lines.single;

      await expectLater(
        endpoint.setLineTax(
          book.session,
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            contains('transfer leg'),
          ),
        ),
      );

      final stored = await TransactionLine.db.findById(book.session, line.id!);
      expect(stored?.taxCategoryCode, isNull);
    });

    test('then an archived entity rejects the write', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      await book.session.db.unsafeExecute(
        'UPDATE "entity" SET "archivedAt" = now() WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': book.entity.id!.toString()}),
      );

      await expectLater(
        endpoint.setLineTax(
          book.session,
          line.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test("then another owner's line cannot be inspected or edited", () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      await saveTaxProfile(other.session, other.entity);
      final otherAccount = await other.addAccount();
      final otherView = await createTaxTransaction(other.session, otherAccount);
      final otherLine = taxLine(otherView);

      await expectLater(
        endpoint.setLineTax(
          book.session,
          otherLine.id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(isA<ForbiddenException>()),
      );

      final stored = await TransactionLine.db.findById(
        other.session,
        otherLine.id!,
      );
      expect(stored?.taxCategoryCode, isNull);
    });
  });

  group('when the entity keeps ledger books', () {
    test(
      'then coding a line bumps the revision and writes the audit',
      () async {
        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        await saveTaxProfile(ledgerBook.session, ledgerBook.entity);
        final account = await ledgerBook.addAccount();
        final view = await createTaxTransaction(
          ledgerBook.session,
          account,
          lines: [
            TransactionLineInput(
              amountMinor: -10000,
              taxCategoryCode: 'gb.ind.employment',
            ),
          ],
        );
        final line = taxLine(view);
        final revision = view.transaction.revision;

        final updated = await endpoint.setLineTax(
          ledgerBook.session,
          line.id!,
          taxCategoryCode: 'gb.ind.self_employment',
        );

        expect(updated.transaction.revision, revision + 1);
        final audits = await AuditEvent.db.find(
          ledgerBook.session,
          where: (t) =>
              t.entityId.equals(ledgerBook.entity.id) &
              t.action.equals(AuditAction.transactionEdited),
        );
        expect(audits, hasLength(1));
        final payload =
            jsonDecode(audits.single.payloadJson) as Map<String, Object?>;
        final before = payload['before']! as Map<String, Object?>;
        final lines = before['lines']! as List<Object?>;
        expect(lines, hasLength(1));
        expect(
          (lines.single! as Map<String, Object?>)['taxCategoryCode'],
          'gb.ind.employment',
        );
        expect(
          (await ledgerBook.session.db.unsafeQuery(
            'SELECT count(*)::bigint FROM audit_event WHERE "entityId" = @id::uuid',
            parameters: QueryParameters.named({
              'id': ledgerBook.entity.id.toString(),
            }),
          )).first.first,
          1,
        );
      },
    );
  });

  group('when the write commits', () {
    test('then the event sees the stored line', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(book.session, account);
      final line = taxLine(view);
      final scopes = <ChangeScope>[];
      String? visibleCode;
      TransactionWriter.debugPublisher =
          (session, entityId, scope, {month, accountId}) async {
            scopes.add(scope);
            final rows = await TransactionLine.db.find(
              session,
              where: (t) => t.transactionId.equals(view.transaction.id),
            );
            visibleCode = rows.single.taxCategoryCode;
          };

      await endpoint.setLineTax(
        book.session,
        line.id!,
        taxCategoryCode: 'gb.ind.employment',
      );

      expect(scopes, [ChangeScope.transactions]);
      expect(visibleCode, 'gb.ind.employment');
    });
  });
}
