// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/ledger/ledger_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/ledger_test_book.dart';
import '../support/pg_test_server.dart';

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

  group('Given LedgerEndpoint', () {
    group('authentication', () {
      test('then requireLogin is true', () {
        expect(LedgerEndpoint().requireLogin, isTrue);
      });

      test('then every method rejects an anonymous session', () async {
        final book = await LedgerTestBook.create(server);
        final anonymous = server.anonymousSession();
        addTearDown(anonymous.close);
        final entityId = book.entity.id!;
        final ledgerAccountId = const Uuid().v7obj();
        final journalId = const Uuid().v7obj();
        final date = DateTime.utc(2026, 11);

        final calls = <Future<Object?> Function()>[
          () => book.endpoint.enableLedger(anonymous, entityId),
          () => book.endpoint.listAccounts(anonymous, entityId),
          () => book.endpoint.createAccount(
            anonymous,
            entityId,
            '9000',
            'Anonymous',
            LedgerAccountType.expense,
          ),
          () => book.endpoint.archiveAccount(anonymous, ledgerAccountId),
          () => book.endpoint.saveDraftJournal(
            anonymous,
            entityId,
            date,
            const [],
          ),
          () => book.endpoint.deleteDraftJournal(anonymous, journalId),
          () => book.endpoint.postJournal(anonymous, journalId),
          () => book.endpoint.reverseJournal(anonymous, journalId, date),
          () => book.endpoint.listJournals(anonymous, entityId),
          () => book.endpoint.listJournalLines(anonymous, journalId),
          () => book.endpoint.getLockDate(anonymous, entityId),
          () => book.endpoint.setLockDate(anonymous, entityId, date),
          () => book.endpoint.trialBalance(anonymous, entityId, date),
          () => book.endpoint.listAuditEvents(anonymous, entityId),
        ];
        for (final call in calls) {
          await expectLater(
            call(),
            throwsA(isA<AuthenticationRequiredException>()),
          );
        }
      });
    });

    group('cross-owner access', () {
      test('then every method rejects a foreign entity or row', () async {
        final owner = await LedgerTestBook.create(server);
        final stranger = await LedgerTestBook.createStranger(server);
        final checking = await owner.addAccount();
        await owner.enable();
        final linked = await owner.linkedAccount(
          await owner.reloadAccount(checking.id!),
        );
        final expense = await owner.accountWithRole(
          LedgerSystemRole.rounding,
        );
        final lines = LedgerLineBuilder(owner.baseCurrency);
        final journal = await owner.post(DateTime.utc(2026, 11), [
          lines.debit(linked, 1000),
          lines.credit(expense, 1000),
        ]);
        final foreignSession = stranger.session;
        final entityId = owner.entity.id!;

        final calls = <Future<Object?> Function()>[
          () => owner.endpoint.enableLedger(foreignSession, entityId),
          () => owner.endpoint.listAccounts(foreignSession, entityId),
          () => owner.endpoint.createAccount(
            foreignSession,
            entityId,
            '9000',
            'Foreign',
            LedgerAccountType.expense,
          ),
          () => owner.endpoint.archiveAccount(foreignSession, linked.id!),
          () => owner.endpoint.saveDraftJournal(
            foreignSession,
            entityId,
            DateTime.utc(2026, 11),
            const [],
          ),
          () => owner.endpoint.deleteDraftJournal(foreignSession, journal.id!),
          () => owner.endpoint.postJournal(foreignSession, journal.id!),
          () => owner.endpoint.reverseJournal(
            foreignSession,
            journal.id!,
            DateTime.utc(2026, 11, 2),
          ),
          () => owner.endpoint.listJournals(foreignSession, entityId),
          () => owner.endpoint.listJournalLines(foreignSession, journal.id!),
          () => owner.endpoint.getLockDate(foreignSession, entityId),
          () => owner.endpoint.setLockDate(
            foreignSession,
            entityId,
            DateTime.utc(2026, 11),
          ),
          () => owner.endpoint.trialBalance(
            foreignSession,
            entityId,
            DateTime.utc(2026, 11),
          ),
          () => owner.endpoint.listAuditEvents(foreignSession, entityId),
        ];
        for (final call in calls) {
          await expectLater(call(), throwsA(isA<ForbiddenException>()));
        }

        await expectLater(
          owner.endpoint.postJournal(owner.session, const Uuid().v7obj()),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('enabling the ledger', () {
      test(
        'then the chart comes from core and money accounts are linked',
        () async {
          final book = await LedgerTestBook.create(server);
          final checking = await book.addAccount(name: 'Current');
          final card = await book.addAccount(
            name: 'Card',
            kind: AccountKind.creditCard,
          );

          final enabled = await book.enable();

          expect(enabled.accountingMode, AccountingMode.ledger);
          final template = LedgerChartTemplate.forBooks(
            jurisdiction: TaxJurisdiction.gb,
            entityKind: EntityKind.company,
          )!;
          final chart = await book.chart();
          expect(chart, hasLength(template.accounts.length + 2));
          for (final seeded in template.accounts) {
            final match = chart.where((account) => account.code == seeded.code);
            expect(match, hasLength(1));
            expect(match.single.name, seeded.name);
            expect(match.single.type, seeded.type);
            expect(match.single.systemRole, seeded.systemRole);
          }

          final reloadedChecking = await book.reloadAccount(checking.id!);
          final reloadedCard = await book.reloadAccount(card.id!);
          expect(reloadedChecking.ledgerAccountId, isNotNull);
          expect(reloadedCard.ledgerAccountId, isNotNull);
          expect(
            reloadedChecking.ledgerAccountId,
            isNot(reloadedCard.ledgerAccountId),
          );
          final checkingLedger = await book.linkedAccount(reloadedChecking);
          final cardLedger = await book.linkedAccount(reloadedCard);
          expect(checkingLedger.systemRole, isNull);
          expect(cardLedger.systemRole, isNull);
          expect(checkingLedger.type, LedgerAccountType.asset);
          expect(cardLedger.type, LedgerAccountType.liability);
          expect(checkingLedger.currencyCode, isNull);
          expect(cardLedger.currencyCode, isNull);
          expect(
            chart.map((account) => account.code).toSet(),
            hasLength(chart.length),
          );
        },
      );

      test('then enabling twice is idempotent', () async {
        final book = await LedgerTestBook.create(server);
        final checking = await book.addAccount();
        await book.enable();
        final firstChart = await book.chart();
        final firstLink = (await book.reloadAccount(checking.id!))
            .ledgerAccountId;

        final second = await book.enable();

        expect(second.accountingMode, AccountingMode.ledger);
        final secondChart = await book.chart();
        expect(secondChart, hasLength(firstChart.length));
        expect(
          secondChart.map((account) => account.id).toSet(),
          firstChart.map((account) => account.id).toSet(),
        );
        expect(
          (await book.reloadAccount(checking.id!)).ledgerAccountId,
          firstLink,
        );
      });

      test('then a foreign account link carries its currency', () async {
        final book = await LedgerTestBook.create(server);
        final usd = await book.addAccount(
          name: 'USD current',
          currencyCode: 'USD',
        );
        await book.enable();

        final linked = await book.linkedAccount(
          await book.reloadAccount(usd.id!),
        );
        expect(linked.currencyCode, 'USD');
        expect(linked.type, LedgerAccountType.asset);
        expect(linked.systemRole, isNull);
      });

      test('then valuations accounts get no ledger link', () async {
        final book = await LedgerTestBook.create(server);
        final investment = await book.addAccount(
          name: 'Brokerage',
          kind: AccountKind.investment,
          balanceSource: AccountBalanceSource.valuations,
          onBudget: false,
        );
        await book.enable();

        expect(
          (await book.reloadAccount(investment.id!)).ledgerAccountId,
          isNull,
        );
      });

      test(
        'then a new money account links without a second source of truth',
        () async {
          final book = await LedgerTestBook.create(server);
          await book.enable();

          final created = await book.addAccount(name: 'Savings');
          final reloaded = await book.reloadAccount(created.id!);
          final linked = await book.linkedAccount(reloaded);
          final chart = await book.chart();

          expect(reloaded.ledgerAccountId, linked.id);
          expect(linked.name, 'Savings');
          expect(linked.type, LedgerAccountType.asset);
          expect(linked.systemRole, isNull);
          expect(linked.entityId, book.entity.id);
          expect(
            chart.where((account) => account.code == linked.code),
            hasLength(1),
          );

          final lines = LedgerLineBuilder(book.baseCurrency);
          final journal = await book.post(DateTime.utc(2026, 11), [
            lines.debit(linked, 2500),
            lines.credit(
              await book.accountWithRole(LedgerSystemRole.openingBalanceEquity),
              2500,
            ),
          ]);
          expect(journal.status, JournalStatus.posted);
        },
      );

      test('then an individual entity is rejected', () async {
        final book = await LedgerTestBook.create(
          server,
          kind: EntityKind.individual,
        );
        await expectLater(
          book.enable(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then an unsupported country has no template', () async {
        final book = await LedgerTestBook.create(
          server,
          countryCode: 'ZZ',
        );
        await expectLater(
          book.enable(),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then an archived entity rejects enabling', () async {
        final book = await LedgerTestBook.create(server);
        await EntityService.setArchived(
          book.session,
          book.entity.id!,
          archived: true,
        );
        await expectLater(
          book.enable(),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('managing chart accounts', () {
      test('then structural accounts protect their role and archive', () async {
        final book = await LedgerTestBook.create(server);
        await book.enable();
        final bank = await book.accountWithRole(LedgerSystemRole.bank);

        await expectLater(
          book.endpoint.archiveAccount(book.session, bank.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            '1500',
            'Second bank',
            LedgerAccountType.asset,
            systemRole: LedgerSystemRole.bank,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            bank.code,
            'Duplicate code',
            LedgerAccountType.asset,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'then a non-structural account archives and stops taking lines',
        () async {
          final book = await LedgerTestBook.create(server);
          await book.enable();
          final created = await book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            '6100',
            'Marketing',
            LedgerAccountType.expense,
          );
          final lines = LedgerLineBuilder(book.baseCurrency);
          final bank = await book.accountWithRole(LedgerSystemRole.bank);

          final archived = await book.endpoint.archiveAccount(
            book.session,
            created.id!,
          );
          expect(archived.archivedAt, isNotNull);
          final visible = await book.chart();
          expect(visible.any((account) => account.id == created.id), isFalse);
          final all = await book.chart(includeArchived: true);
          expect(all.any((account) => account.id == created.id), isTrue);
          final second = await book.endpoint.archiveAccount(
            book.session,
            created.id!,
          );
          expect(second.archivedAt, archived.archivedAt);

          await expectLater(
            book.endpoint.saveDraftJournal(
              book.session,
              book.entity.id!,
              DateTime.utc(2026, 11),
              [lines.debit(created, 100), lines.credit(bank, 100)],
            ),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('then supported currencies and enums are validated', () async {
        final book = await LedgerTestBook.create(server);
        await book.enable();

        await expectLater(
          book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            '9001',
            'Bad currency',
            LedgerAccountType.asset,
            currencyCode: 'ZZZ',
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            '  ',
            'Blank code',
            LedgerAccountType.asset,
          ),
          throwsA(isA<ValidationException>()),
        );
        final valid = await book.endpoint.createAccount(
          book.session,
          book.entity.id!,
          '9002',
          'USD clearing',
          LedgerAccountType.asset,
          currencyCode: 'usd',
        );
        expect(valid.currencyCode, 'USD');
      });
    });

    group('saving drafts', () {
      late LedgerTestBook book;
      late LedgerLineBuilder lines;
      late LedgerAccount bank;
      late LedgerAccount equity;
      late LedgerAccount income;

      setUp(() async {
        book = await LedgerTestBook.create(server);
        final checking = await book.addAccount();
        await book.enable();
        lines = LedgerLineBuilder(book.baseCurrency);
        bank = await book.linkedAccount(await book.reloadAccount(checking.id!));
        equity = await book.accountWithRole(
          LedgerSystemRole.openingBalanceEquity,
        );
        income = await book.accountWithCode('4000');
      });

      test(
        'then a balanced draft stores base facts and identity rates',
        () async {
          final draft = await book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(bank, 50000), lines.credit(equity, 50000)],
            reference: 'JB-OPEN-1',
            narration: 'Opening cash',
            source: JournalSource.opening,
          );

          expect(draft.status, JournalStatus.draft);
          expect(draft.source, JournalSource.opening);
          expect(draft.postedAt, isNull);
          expect(draft.postedBy, isNull);
          final stored = await book.endpoint.listJournalLines(
            book.session,
            draft.id!,
          );
          expect(stored, hasLength(2));
          expect(stored.first.baseDebitMinor, 50000);
          expect(stored.first.fxRate, '1');
          expect(stored.first.fxRateSource, FxRateSource.identity);
          expect(stored.first.fxRateDate, DateTime.utc(2026, 11));
        },
      );

      test('then a single-line draft is rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(bank, 100)],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then an unbalanced draft is rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(bank, 10000), lines.credit(income, 9999)],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a line with both sides or a zero line is rejected', () async {
        final bothSides = JournalLineInput(
          ledgerAccountId: bank.id!,
          debitMinor: 100,
          creditMinor: 100,
          currencyCode: 'GBP',
          baseDebitMinor: 100,
          baseCreditMinor: 0,
          fxRate: '1',
          fxRateDate: DateTime.utc(2026, 11),
          fxRateSource: FxRateSource.identity,
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [bothSides, lines.credit(income, 100)],
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              JournalLineInput(
                ledgerAccountId: bank.id!,
                currencyCode: 'GBP',
                fxRate: '1',
                fxRateDate: DateTime.utc(2026, 11),
                fxRateSource: FxRateSource.identity,
              ),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then negative and unsafe amounts are rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              JournalLineInput(
                ledgerAccountId: bank.id!,
                debitMinor: -100,
                currencyCode: 'GBP',
                baseDebitMinor: -100,
                fxRate: '1',
                fxRateDate: DateTime.utc(2026, 11),
                fxRateSource: FxRateSource.identity,
              ),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(bank, 100, baseAmountMinor: maxSafeMinor + 1),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then foreign-currency lines must balance per currency', () async {
        // USD 100.00 Dr at 0.8 and USD 99.00 Cr at 0.808081 both land on GBP
        // 80.00. The base balances, the transaction currency does not.
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(
                bank,
                10000,
                currencyCode: 'USD',
                baseAmountMinor: 8000,
                fxRate: '0.8',
              ),
              lines.credit(
                income,
                9900,
                currencyCode: 'USD',
                baseAmountMinor: 8000,
                fxRate: '0.808081',
              ),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a base amount contradicting the rate is rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(
                bank,
                100000,
                currencyCode: 'USD',
                baseAmountMinor: 76923,
                fxRate: '0.8',
              ),
              lines.credit(income, 76923),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then unsupported currencies and bad rates are rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(bank, 100, currencyCode: 'ZZZ'),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(
                bank,
                100,
                currencyCode: 'USD',
                baseAmountMinor: 80,
                fxRate: 'zero',
              ),
              lines.credit(income, 80),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a rate date after the journal is rejected', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11, 2),
            [
              lines.debit(
                bank,
                100,
                currencyCode: 'USD',
                baseAmountMinor: 80,
                fxRate: '0.8',
                fxRateDate: DateTime.utc(2026, 11, 3),
              ),
              lines.credit(income, 80),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then identity is only valid for the base currency', () async {
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(
                bank,
                100,
                currencyCode: 'USD',
                baseAmountMinor: 100,
                fxRateSource: FxRateSource.identity,
              ),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [
              lines.debit(bank, 100, fxRateSource: FxRateSource.manual),
              lines.credit(income, 100),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then system sources are not caller-forgeable', () async {
        for (final source in [
          JournalSource.reversal,
          JournalSource.transaction,
          JournalSource.revaluation,
        ]) {
          await expectLater(
            book.endpoint.saveDraftJournal(
              book.session,
              book.entity.id!,
              DateTime.utc(2026, 11),
              [lines.debit(bank, 100), lines.credit(income, 100)],
              source: source,
            ),
            throwsA(isA<ValidationException>()),
          );
        }
      });

      test('then control accounts reject manual lines', () async {
        final receivable = await book.accountWithRole(
          LedgerSystemRole.accountsReceivable,
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(receivable, 100), lines.credit(income, 100)],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a foreign ledger reference is rejected', () async {
        final other = await LedgerTestBook.create(server);
        await other.enable();
        final otherBank = await other.accountWithRole(LedgerSystemRole.bank);
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(otherBank, 100), lines.credit(income, 100)],
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a draft edits in place and keeps its identity', () async {
        final draft = await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11),
          [lines.debit(bank, 50000), lines.credit(equity, 50000)],
          reference: 'JB-EDIT',
        );
        final updated = await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 2),
          [lines.debit(bank, 60000), lines.credit(equity, 60000)],
          journalId: draft.id,
          reference: 'JB-EDIT',
        );

        expect(updated.id, draft.id);
        expect(updated.date, DateTime.utc(2026, 11, 2));
        final stored = await book.endpoint.listJournalLines(
          book.session,
          draft.id!,
        );
        expect(stored, hasLength(2));
        expect(
          stored.fold<int>(0, (sum, line) => sum + line.baseDebitMinor),
          60000,
        );
      });

      test('then a draft deletes and posted journals never do', () async {
        final draft = await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11),
          [lines.debit(bank, 50000), lines.credit(equity, 50000)],
        );
        await book.endpoint.deleteDraftJournal(book.session, draft.id!);
        expect(
          await book.endpoint.listJournals(book.session, book.entity.id!),
          isEmpty,
        );

        final posted = await book.post(DateTime.utc(2026, 11), [
          lines.debit(bank, 50000),
          lines.credit(equity, 50000),
        ]);
        await expectLater(
          book.endpoint.postJournal(book.session, posted.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.deleteDraftJournal(book.session, posted.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(bank, 1), lines.credit(equity, 1)],
            journalId: posted.id,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'then an account archived after the draft rejects posting',
        () async {
          final created = await book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            '6100',
            'Marketing',
            LedgerAccountType.expense,
          );
          final draft = await book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
            [lines.debit(created, 100), lines.credit(bank, 100)],
          );
          await book.endpoint.archiveAccount(book.session, created.id!);

          await expectLater(
            book.endpoint.postJournal(book.session, draft.id!),
            throwsA(isA<ValidationException>()),
          );
          final stored = (await Journal.db.findById(book.session, draft.id!))!;
          expect(stored.status, JournalStatus.draft);
        },
      );

      test('then a posted journal keeps its exact facts', () async {
        final posted = await book.post(DateTime.utc(2026, 11), [
          lines.debit(bank, 12345),
          lines.credit(equity, 12345),
        ]);
        final before = await book.endpoint.listJournalLines(
          book.session,
          posted.id!,
        );

        await book.endpoint.reverseJournal(
          book.session,
          posted.id!,
          DateTime.utc(2026, 11, 2),
        );

        final after = await book.endpoint.listJournalLines(
          book.session,
          posted.id!,
        );
        expect(
          [
            for (final line in after)
              (
                line.id,
                line.debitMinor,
                line.creditMinor,
                line.baseDebitMinor,
                line.baseCreditMinor,
              ),
          ],
          [
            for (final line in before)
              (
                line.id,
                line.debitMinor,
                line.creditMinor,
                line.baseDebitMinor,
                line.baseCreditMinor,
              ),
          ],
        );
      });
    });

    group('posting, reversing and the trial balance', () {
      late LedgerTestBook book;
      late LedgerLineBuilder lines;
      late LedgerAccount bank;
      late LedgerAccount equity;
      late LedgerAccount expense;
      late LedgerAccount income;

      setUp(() async {
        book = await LedgerTestBook.create(server);
        final checking = await book.addAccount();
        await book.enable();
        lines = LedgerLineBuilder(book.baseCurrency);
        bank = await book.linkedAccount(await book.reloadAccount(checking.id!));
        equity = await book.accountWithRole(
          LedgerSystemRole.openingBalanceEquity,
        );
        expense = await book.accountWithCode('5600');
        income = await book.accountWithCode('4000');
      });

      test(
        'then posting stamps server facts and the audit before state',
        () async {
          final posted = await book.post(
            DateTime.utc(2026, 11),
            [lines.debit(bank, 50000), lines.credit(equity, 50000)],
            source: JournalSource.opening,
          );

          expect(posted.status, JournalStatus.posted);
          expect(posted.postedAt, isNotNull);
          expect(posted.postedAt!.isUtc, isTrue);
          expect(posted.postedBy, book.userId);
          final events = await book.endpoint.listAuditEvents(
            book.session,
            book.entity.id!,
          );
          final event = events.singleWhere(
            (event) => event.action == AuditAction.journalPosted,
          );
          expect(event.actorId, book.userId);
          expect(event.payloadJson, contains('"status":"draft"'));
          expect(event.subjectType, AuditSubject.journal);
          expect(event.subjectId, posted.id);
        },
      );

      test(
        'then a posted fee reverses and the trial balance nets zero',
        () async {
          await book.post(
            DateTime.utc(2026, 11),
            [lines.debit(bank, 50000), lines.credit(equity, 50000)],
            source: JournalSource.opening,
          );
          final fee = await book.post(DateTime.utc(2026, 11, 3), [
            lines.debit(expense, 1250),
            lines.credit(bank, 1250),
          ]);

          final before = await book.endpoint.trialBalance(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11, 3),
          );
          expect(before.totalDebitMinor, 51250);
          expect(before.totalCreditMinor, 51250);

          final reversal = await book.endpoint.reverseJournal(
            book.session,
            fee.id!,
            DateTime.utc(2026, 11, 20),
          );
          expect(reversal.status, JournalStatus.posted);
          expect(reversal.source, JournalSource.reversal);
          expect(reversal.reversalOfJournalId, fee.id);
          final journals = await book.endpoint.listJournals(
            book.session,
            book.entity.id!,
          );
          expect(
            journals.singleWhere((journal) => journal.id == fee.id).status,
            JournalStatus.reversed,
          );

          final after = await book.endpoint.trialBalance(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11, 20),
          );
          final byCode = {
            for (final row in after.rows) row.accountCode: row.netMinor,
          };
          expect(byCode[bank.code], 50000);
          expect(byCode[expense.code], 0);
          expect(byCode[equity.code], -50000);
          expect(after.totalDebitMinor, 52500);
          expect(after.totalCreditMinor, 52500);

          await expectLater(
            book.endpoint.reverseJournal(
              book.session,
              fee.id!,
              DateTime.utc(2026, 11, 21),
            ),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('then a reversal preserves the stored rate and rate date', () async {
        final usdChecking = await book.addAccount(
          name: 'USD current',
          currencyCode: 'USD',
        );
        final usdBank = await book.linkedAccount(
          await book.reloadAccount(usdChecking.id!),
        );
        final original = await book.post(DateTime.utc(2026, 11), [
          lines.debit(
            usdBank,
            100000,
            currencyCode: 'USD',
            baseAmountMinor: 80000,
            fxRate: '0.8',
            fxRateDate: DateTime.utc(2026, 10, 31),
          ),
          lines.credit(equity, 80000),
        ]);
        final originalLines = await book.endpoint.listJournalLines(
          book.session,
          original.id!,
        );
        final usdLine = originalLines.singleWhere(
          (line) => line.ledgerAccountId == usdBank.id,
        );

        final reversal = await book.endpoint.reverseJournal(
          book.session,
          original.id!,
          DateTime.utc(2026, 11, 20),
        );
        final reversalLines = await book.endpoint.listJournalLines(
          book.session,
          reversal.id!,
        );
        final reversedUsd = reversalLines.singleWhere(
          (line) => line.ledgerAccountId == usdBank.id,
        );

        expect(reversedUsd.fxRate, '0.8');
        expect(reversedUsd.fxRateDate, usdLine.fxRateDate);
        expect(reversedUsd.fxRateSource, FxRateSource.manual);
        expect(reversedUsd.debitMinor, usdLine.creditMinor);
        expect(reversedUsd.creditMinor, usdLine.debitMinor);
        expect(reversedUsd.baseDebitMinor, usdLine.baseCreditMinor);
        expect(reversedUsd.baseCreditMinor, usdLine.baseDebitMinor);
        final refetchedOriginal = await book.endpoint.listJournalLines(
          book.session,
          original.id!,
        );
        expect(
          refetchedOriginal
              .singleWhere(
                (line) => line.ledgerAccountId == usdBank.id,
              )
              .fxRate,
          '0.8',
        );
      });

      test('then the trial balance honors as-of and excludes drafts', () async {
        await book.post(
          DateTime.utc(2026, 11),
          [lines.debit(bank, 50000), lines.credit(equity, 50000)],
          source: JournalSource.opening,
        );
        await book.post(DateTime.utc(2026, 11, 20), [
          lines.debit(expense, 1250),
          lines.credit(bank, 1250),
        ]);
        await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11),
          [lines.debit(expense, 99999), lines.credit(bank, 99999)],
        );

        final before = await book.endpoint.trialBalance(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11),
        );
        expect(before.rows, hasLength(2));
        expect(before.totalDebitMinor, 50000);
        expect(before.currencyCode, book.baseCurrency);

        await expectLater(
          book.endpoint.trialBalance(
            book.session,
            book.entity.id!,
            DateTime(2026, 11),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then an unbalanced book is a hard error', () async {
        final posted = await book.post(DateTime.utc(2026, 11), [
          lines.debit(bank, 100),
          lines.credit(equity, 100),
        ]);
        await JournalLine.db.insertRow(
          book.session,
          JournalLine(
            journalId: posted.id!,
            ledgerAccountId: income.id!,
            debitMinor: 1,
            currencyCode: book.baseCurrency,
            baseDebitMinor: 1,
            fxRate: '1',
            fxRateDate: DateTime.utc(2026, 11),
            fxRateSource: FxRateSource.identity,
          ),
        );

        await expectLater(
          book.endpoint.trialBalance(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'then posted bank movements are not fake cash transactions',
        () async {
          final moneyAccount = (await Account.db.findFirstRow(
            book.session,
            where: (t) => t.ledgerAccountId.equals(bank.id),
          ))!;
          expect(moneyAccount.balanceMinor, 0);
          final transactionsBefore = await model.Transaction.db.count(
            book.session,
          );

          await book.post(DateTime.utc(2026, 11), [
            lines.debit(bank, 7500),
            lines.credit(equity, 7500),
          ]);

          final after = await Account.db.findById(
            book.session,
            moneyAccount.id!,
          );
          expect(after!.balanceMinor, 0);
          expect(
            await model.Transaction.db.count(book.session),
            transactionsBefore,
          );
        },
      );

      test('then JPY and KWD post with their own exponents', () async {
        final jpyBook = await LedgerTestBook.create(
          server,
          baseCurrencyCode: 'JPY',
        );
        final jpyChecking = await jpyBook.addAccount(currencyCode: 'JPY');
        await jpyBook.enable();
        final jpyBank = await jpyBook.linkedAccount(
          await jpyBook.reloadAccount(jpyChecking.id!),
        );
        final jpyEquity = await jpyBook.accountWithRole(
          LedgerSystemRole.openingBalanceEquity,
        );
        final jpyLines = LedgerLineBuilder('JPY');
        // USD 100.00 at 150 JPY per USD is 15,000 yen minor units; a *100
        // assumption would produce 1,500,000.
        await jpyBook.post(DateTime.utc(2026, 11), [
          jpyLines.debit(
            jpyBank,
            10000,
            currencyCode: 'USD',
            baseAmountMinor: 15000,
            fxRate: '150',
          ),
          jpyLines.credit(jpyEquity, 15000),
        ]);
        final jpyTrial = await jpyBook.endpoint.trialBalance(
          jpyBook.session,
          jpyBook.entity.id!,
          DateTime.utc(2026, 11),
        );
        expect(jpyTrial.totalDebitMinor, 15000);

        final kwdBook = await LedgerTestBook.create(
          server,
          baseCurrencyCode: 'KWD',
        );
        final kwdChecking = await kwdBook.addAccount(currencyCode: 'KWD');
        await kwdBook.enable();
        final kwdBank = await kwdBook.linkedAccount(
          await kwdBook.reloadAccount(kwdChecking.id!),
        );
        final kwdEquity = await kwdBook.accountWithRole(
          LedgerSystemRole.openingBalanceEquity,
        );
        final kwdLines = LedgerLineBuilder('KWD');
        // USD 100.00 at 0.307 KWD per USD is 30.700 KWD, or 30,700 fils.
        await kwdBook.post(DateTime.utc(2026, 11), [
          kwdLines.debit(
            kwdBank,
            10000,
            currencyCode: 'USD',
            baseAmountMinor: 30700,
            fxRate: '0.307',
          ),
          kwdLines.credit(kwdEquity, 30700),
        ]);
        final kwdTrial = await kwdBook.endpoint.trialBalance(
          kwdBook.session,
          kwdBook.entity.id!,
          DateTime.utc(2026, 11),
        );
        expect(kwdTrial.totalDebitMinor, 30700);
      });
    });

    group('the period lock', () {
      late LedgerTestBook book;
      late LedgerLineBuilder lines;
      late LedgerAccount bank;
      late LedgerAccount expense;

      setUp(() async {
        book = await LedgerTestBook.create(server);
        final checking = await book.addAccount();
        await book.enable();
        lines = LedgerLineBuilder(book.baseCurrency);
        bank = await book.linkedAccount(await book.reloadAccount(checking.id!));
        expense = await book.accountWithCode('5600');
      });

      test(
        'then dates on or before the lock reject post and draft writes',
        () async {
          final locked = DateTime.utc(2026, 11, 3);
          await book.endpoint.setLockDate(
            book.session,
            book.entity.id!,
            locked,
          );
          final lock = await book.endpoint.getLockDate(
            book.session,
            book.entity.id!,
          );
          expect(lock!.lockDate, locked);

          await expectLater(
            book.endpoint.saveDraftJournal(
              book.session,
              book.entity.id!,
              locked,
              [lines.debit(expense, 100), lines.credit(bank, 100)],
            ),
            throwsA(isA<ValidationException>()),
          );
          await expectLater(
            book.endpoint.setLockDate(
              book.session,
              book.entity.id!,
              DateTime(2026, 11, 3),
            ),
            throwsA(isA<ValidationException>()),
          );

          final open = await book.post(DateTime.utc(2026, 11, 4), [
            lines.debit(expense, 100),
            lines.credit(bank, 100),
          ]);
          expect(open.status, JournalStatus.posted);
        },
      );

      test('then a draft in the lock cannot be edited or deleted', () async {
        final draft = await book.endpoint.saveDraftJournal(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 2),
          [lines.debit(expense, 100), lines.credit(bank, 100)],
        );
        await book.endpoint.setLockDate(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 3),
        );

        await expectLater(
          book.endpoint.saveDraftJournal(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11, 4),
            [lines.debit(expense, 100), lines.credit(bank, 100)],
            journalId: draft.id,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.deleteDraftJournal(book.session, draft.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'then reversal into the lock is rejected and after it succeeds',
        () async {
          final journal = await book.post(DateTime.utc(2026, 11), [
            lines.debit(expense, 100),
            lines.credit(bank, 100),
          ]);
          await book.endpoint.setLockDate(
            book.session,
            book.entity.id!,
            DateTime.utc(2026, 11, 3),
          );

          await expectLater(
            book.endpoint.reverseJournal(
              book.session,
              journal.id!,
              DateTime.utc(2026, 11, 3),
            ),
            throwsA(isA<ValidationException>()),
          );
          final reversal = await book.endpoint.reverseJournal(
            book.session,
            journal.id!,
            DateTime.utc(2026, 11, 4),
          );
          expect(reversal.status, JournalStatus.posted);
        },
      );

      test('then moving the lock is audited with both dates', () async {
        await book.endpoint.setLockDate(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 3),
        );
        await book.endpoint.setLockDate(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 1),
        );

        final events = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
        );
        final lockEvents = events
            .where((event) => event.action == AuditAction.lockSet)
            .toList();
        expect(lockEvents, hasLength(2));
        expect(lockEvents.first.payloadJson, contains('2026-11-03'));
        expect(lockEvents.first.payloadJson, contains('2026-11-01'));
        expect(lockEvents.first.actorId, book.userId);
      });
    });

    group('bounded lists and audit pages', () {
      test(
        'then journals page by date and id with the documented cursor',
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
          final date = DateTime.utc(2026, 11, 3);
          final journals = <Journal>[];
          for (var index = 0; index < 3; index++) {
            journals.add(
              await book.post(date, [
                lines.debit(bank, 100 + index),
                lines.credit(equity, 100 + index),
              ], reference: 'JB-$index'),
            );
          }
          final ordered = [...journals]
            ..sort((a, b) => b.id!.uuid.compareTo(a.id!.uuid));

          final firstPage = await book.endpoint.listJournals(
            book.session,
            book.entity.id!,
            limit: 2,
          );
          expect(firstPage, hasLength(2));
          expect(
            firstPage.map((journal) => journal.id),
            ordered.take(2).map((journal) => journal.id),
          );

          final secondPage = await book.endpoint.listJournals(
            book.session,
            book.entity.id!,
            limit: 2,
            cursor: journalCursor(firstPage.last.date, firstPage.last.id!),
          );
          expect(secondPage.map((journal) => journal.id), [ordered.last.id]);

          await expectLater(
            book.endpoint.listJournals(
              book.session,
              book.entity.id!,
              limit: 0,
            ),
            throwsA(isA<ValidationException>()),
          );
          await expectLater(
            book.endpoint.listJournals(
              book.session,
              book.entity.id!,
              limit: 201,
            ),
            throwsA(isA<ValidationException>()),
          );
          await expectLater(
            book.endpoint.listJournals(
              book.session,
              book.entity.id!,
              cursor: 'not a cursor',
            ),
            throwsA(isA<ValidationException>()),
          );
          await expectLater(
            book.endpoint.listJournals(
              book.session,
              book.entity.id!,
              fromDate: DateTime.utc(2026, 11, 4),
              toDate: DateTime.utc(2026, 11, 3),
            ),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('then audit events page newest first with bounded ties', () async {
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
        await book.post(DateTime.utc(2026, 11), [
          lines.debit(bank, 100),
          lines.credit(equity, 100),
        ]);
        await book.endpoint.setLockDate(
          book.session,
          book.entity.id!,
          DateTime.utc(2026, 11, 5),
        );

        final page = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
          limit: 1,
        );
        expect(page, hasLength(1));
        final all = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
        );
        expect(all.length, greaterThanOrEqualTo(3));
        expect(
          all.map((event) => event.action),
          containsAll([
            AuditAction.ledgerEnabled,
            AuditAction.journalPosted,
            AuditAction.lockSet,
          ]),
        );
        expect(
          all.every((event) => event.createdAt.isUtc),
          isTrue,
        );

        final before = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
          before: page.single.createdAt,
        );
        expect(
          before.every(
            (event) => event.createdAt.isBefore(page.single.createdAt),
          ),
          isTrue,
        );
        await expectLater(
          book.endpoint.listAuditEvents(
            book.session,
            book.entity.id!,
            limit: 201,
          ),
          throwsA(isA<ValidationException>()),
        );

        // Equal server timestamps still have one stable id order.
        final timestamp = DateTime.utc(2020);
        final first = const Uuid().v7obj();
        final second = const Uuid().v7obj();
        for (final id in [first, second]) {
          await AuditEvent.db.insertRow(
            book.session,
            AuditEvent(
              id: id,
              entityId: book.entity.id!,
              actorId: book.userId,
              action: AuditAction.balanceRepaired,
              payloadJson: '{"before":null}',
              createdAt: timestamp,
            ),
          );
        }
        final ties = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
          before: DateTime.utc(2020).add(const Duration(seconds: 1)),
        );
        final tieIds = ties
            .where((event) => event.createdAt == timestamp)
            .map((event) => event.id!.uuid)
            .toList();
        final expectedTies = [first.uuid, second.uuid]
          ..sort((a, b) => b.compareTo(a));
        expect(tieIds, expectedTies);
      });

      test('then failed writes leave no audit event', () async {
        final individual = await LedgerTestBook.create(
          server,
          kind: EntityKind.individual,
        );
        await expectLater(
          individual.enable(),
          throwsA(isA<ValidationException>()),
        );
        expect(
          await AuditEvent.db.count(
            individual.session,
            where: (t) => t.entityId.equals(individual.entity.id),
          ),
          0,
        );

        final book = await LedgerTestBook.create(server);
        await book.enable();
        final before = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
        );
        final bank = await book.accountWithRole(LedgerSystemRole.bank);
        await expectLater(
          book.endpoint.archiveAccount(book.session, bank.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          book.endpoint.createAccount(
            book.session,
            book.entity.id!,
            bank.code,
            'Duplicate',
            LedgerAccountType.expense,
          ),
          throwsA(isA<ValidationException>()),
        );
        final after = await book.endpoint.listAuditEvents(
          book.session,
          book.entity.id!,
        );
        expect(after, hasLength(before.length));
      });
    });
  });
}
