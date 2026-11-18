import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../support/ledger_test_book.dart';
import '../support/pg_test_server.dart';

/// These tests commit their writes, because two requests only serialize when
/// they run in separate transactions. Every test creates fresh users, so
/// committed rows never collide across runs.
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

  setUp(() async {
    EntityRealtimeNotifier.debugPublisher = LedgerTestBook.ignoreEvent;
    AccountService.debugPublisher = LedgerTestBook.ignoreEvent;
    TransactionWriter.debugPublisher = LedgerTestBook.ignoreEvent;
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    await server.clearRates();
  });

  tearDown(() {
    EntityRealtimeNotifier.resetForTests();
    AccountService.resetForTests();
    TransactionWriter.resetForTests();
    FxService.resetForTests();
  });

  group('Given LedgerEndpoint under concurrent requests', () {
    test('then two enables seed one chart and one link per account', () async {
      final book = await LedgerTestBook.create(server);
      final checking = await book.addAccount(name: 'Current');
      final first = book.newSession();
      final second = book.newSession();

      final results = await Future.wait([
        book.endpoint.enableLedger(first, book.entity.id!),
        book.endpoint.enableLedger(second, book.entity.id!),
      ]);

      expect(
        results.map((entity) => entity.accountingMode),
        everyElement(AccountingMode.ledger),
      );
      final chart = await book.chart();
      final template = LedgerChartTemplate.forBooks(
        jurisdiction: TaxJurisdiction.gb,
        entityKind: EntityKind.company,
      )!;
      expect(chart, hasLength(template.accounts.length + 1));
      expect(
        chart.map((account) => account.code).toSet(),
        hasLength(chart.length),
      );
      expect(
        chart.map((account) => account.id).toSet(),
        hasLength(chart.length),
      );
      final roles = chart
          .map((account) => account.systemRole)
          .whereType<LedgerSystemRole>()
          .toList();
      expect(roles.toSet(), hasLength(roles.length));
      final reloaded = await book.reloadAccount(checking.id!);
      expect(reloaded.ledgerAccountId, isNotNull);
      expect(
        chart.where((account) => account.id == reloaded.ledgerAccountId),
        hasLength(1),
      );
    });

    test(
      'then an account created while enabling still gets one link',
      () async {
        for (var attempt = 0; attempt < 3; attempt++) {
          final book = await LedgerTestBook.create(server);
          final enabling = book.newSession();
          final creating = book.newSession();

          final results = await Future.wait<Object?>([
            book.endpoint.enableLedger(enabling, book.entity.id!),
            book.addAccount(session: creating, name: 'Racer $attempt'),
          ]);
          final entity = results.first! as Entity;
          final account = results.last! as Account;
          expect(entity.accountingMode, AccountingMode.ledger);

          final reloaded = await book.reloadAccount(account.id!);
          expect(reloaded.ledgerAccountId, isNotNull);
          final chart = await book.chart();
          final matches = chart.where(
            (ledger) => ledger.id == reloaded.ledgerAccountId,
          );
          expect(matches, hasLength(1));
          expect(matches.single.entityId, book.entity.id);
          expect(matches.single.systemRole, isNull);
          expect(matches.single.name, 'Racer $attempt');
        }
      },
    );

    test('then concurrent posts of one draft have one winner', () async {
      final book = await LedgerTestBook.create(server);
      final checking = await book.addAccount();
      await book.enable();
      final lines = LedgerLineBuilder(book.baseCurrency);
      final bank = await book.linkedAccount(
        await book.reloadAccount(checking.id!),
      );
      final equity = await book.accountWithRole(
        LedgerSystemRole.openingBalanceEquity,
      );
      final draft = await book.endpoint.saveDraftJournal(
        book.session,
        book.entity.id!,
        DateTime.utc(2026, 11),
        [lines.debit(bank, 5000), lines.credit(equity, 5000)],
      );
      final first = book.newSession();
      final second = book.newSession();

      var succeeded = 0;
      var rejected = 0;
      await Future.wait([
        for (final session in [first, second])
          () async {
            try {
              await book.endpoint.postJournal(session, draft.id!);
              succeeded++;
            } on ValidationException {
              rejected++;
            }
          }(),
      ]);

      expect(succeeded, 1);
      expect(rejected, 1);
      final stored = (await Journal.db.findById(book.session, draft.id!))!;
      expect(stored.status, JournalStatus.posted);
      final events = await book.endpoint.listAuditEvents(
        book.session,
        book.entity.id!,
      );
      expect(
        events.where((event) => event.action == AuditAction.journalPosted),
        hasLength(1),
      );
    });

    test('then concurrent reversals create one mirror journal', () async {
      final book = await LedgerTestBook.create(server);
      final checking = await book.addAccount();
      await book.enable();
      final lines = LedgerLineBuilder(book.baseCurrency);
      final bank = await book.linkedAccount(
        await book.reloadAccount(checking.id!),
      );
      final equity = await book.accountWithRole(
        LedgerSystemRole.openingBalanceEquity,
      );
      final original = await book.post(DateTime.utc(2026, 11), [
        lines.debit(bank, 5000),
        lines.credit(equity, 5000),
      ]);
      final first = book.newSession();
      final second = book.newSession();

      var succeeded = 0;
      var rejected = 0;
      await Future.wait([
        for (final session in [first, second])
          () async {
            try {
              await book.endpoint.reverseJournal(
                session,
                original.id!,
                DateTime.utc(2026, 11, 2),
              );
              succeeded++;
            } on ValidationException {
              rejected++;
            }
          }(),
      ]);

      expect(succeeded, 1);
      expect(rejected, 1);
      final reversals = await Journal.db.find(
        book.session,
        where: (j) => j.reversalOfJournalId.equals(original.id),
      );
      expect(reversals, hasLength(1));
      final refetched = (await Journal.db.findById(
        book.session,
        original.id!,
      ))!;
      expect(refetched.status, JournalStatus.reversed);
      final trial = await book.endpoint.trialBalance(
        book.session,
        book.entity.id!,
        DateTime.utc(2026, 11, 3),
      );
      expect(trial.totalDebitMinor, 10000);
      expect(trial.totalCreditMinor, 10000);
      expect(
        trial.rows.fold<int>(0, (sum, row) => sum + row.netMinor),
        0,
      );
    });

    test(
      'then a lock committed under the entity lock rejects a waiting post',
      () async {
        final book = await LedgerTestBook.create(server);
        final checking = await book.addAccount();
        await book.enable();
        final lines = LedgerLineBuilder(book.baseCurrency);
        final bank = await book.linkedAccount(
          await book.reloadAccount(checking.id!),
        );
        final equity = await book.accountWithRole(
          LedgerSystemRole.openingBalanceEquity,
        );
        final draft = await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 3),
          [lines.debit(bank, 5000), lines.credit(equity, 5000)],
        );
        final locker = book.newSession();
        final poster = book.newSession();

        late Future<Journal> postFuture;
        await locker.db.transaction((transaction) async {
          await EntityAccess.requireOwned(
            locker,
            book.entity.id!,
            transaction: transaction,
            lock: true,
          );
          await LedgerPeriodLock.db.insertRow(
            locker,
            LedgerPeriodLock(
              entityId: book.entity.id!,
              lockDate: DateTime.utc(2026, 11, 3),
              setBy: book.userId,
              setAt: DateTime.now().toUtc(),
            ),
            transaction: transaction,
          );
          postFuture = book.endpoint.postJournal(poster, draft.id!);
          await Future<void>.delayed(const Duration(milliseconds: 250));
        });

        await expectLater(
          postFuture,
          throwsA(isA<ValidationException>()),
        );
        final stored = (await Journal.db.findById(book.session, draft.id!))!;
        expect(stored.status, JournalStatus.draft);
        final lock = await book.endpoint.getLockDate(
          book.session,
          book.entity.id!,
        );
        expect(lock!.lockDate, DateTime.utc(2026, 11, 3));
        final events = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
        );
        expect(
          events.where((event) => event.action == AuditAction.journalPosted),
          isEmpty,
        );
      },
    );

    test('then concurrent lock writers keep one lock row', () async {
      final book = await LedgerTestBook.create(server);
      await book.enable();
      final first = book.newSession();
      final second = book.newSession();

      await Future.wait([
        book.endpoint.setLockDate(
          first,
          book.entity.id!,
          DateTime.utc(2026, 10, 31),
        ),
        book.endpoint.setLockDate(
          second,
          book.entity.id!,
          DateTime.utc(2026, 11, 30),
        ),
      ]);

      final locks = await LedgerPeriodLock.db.find(
        book.session,
        where: (l) => l.entityId.equals(book.entity.id),
      );
      expect(locks, hasLength(1));
      final events = await book.endpoint.listAuditEvents(
        book.session,
        book.entity.id!,
      );
      expect(
        events.where((event) => event.action == AuditAction.lockSet),
        hasLength(2),
      );
    });
  });
}
