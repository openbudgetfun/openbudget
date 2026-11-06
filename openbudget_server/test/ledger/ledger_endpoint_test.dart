import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given LedgerEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder owner;
    late TestSessionBuilder stranger;

    /// Fixed calendar dates well inside an open period.
    final openingDate = DateTime(2026, 11);
    final feeDate = DateTime(2026, 11, 3);
    final laterDate = DateTime(2026, 11, 20);

    setUp(() {
      owner = createAuthenticatedSession(sessionBuilder);
      stranger = createAuthenticatedSession(sessionBuilder);
    });

    /// Creates a GB budget with a tax profile of [entityKind].
    Future<Budget> createBudget(
      TestSessionBuilder session,
      TaxEntityKind entityKind, {
      String currency = 'GBP',
      String jurisdiction = 'GB',
      bool withProfile = true,
    }) async {
      final budget = await endpoints.budget.create(session, 'Books', currency);
      if (withProfile) {
        final profileJson = switch (jurisdiction) {
          'US' => jsonEncode(
            UsTaxProfile(entityKind: entityKind).toJson(),
          ),
          'NG' => jsonEncode(
            NgTaxProfile(entityKind: entityKind).toJson(),
          ),
          'DE' => jsonEncode(
            DeTaxProfile(entityKind: entityKind).toJson(),
          ),
          _ => jsonEncode(GbTaxProfile(entityKind: entityKind).toJson()),
        };
        await endpoints.tax.saveProfile(
          session,
          budget.id!,
          jurisdiction,
          entityKind.name,
          profileJson,
        );
      }
      return budget;
    }

    /// Enables the ledger and returns the seeded accounts by code.
    Future<Map<String, LedgerAccount>> enableLedger(
      TestSessionBuilder session,
      Budget budget,
    ) async {
      await endpoints.ledger.enableLedger(session, budget.id!);
      final accounts = await endpoints.ledger.listAccounts(
        session,
        budget.id!,
        includeArchived: false,
      );
      return {for (final account in accounts) account.code: account};
    }

    JournalLineInput line(
      LedgerAccount account, {
      required bool isDebit,
      required int amountMinor,
      String currency = 'GBP',
      int functionalAmountMinor = -1,
      String rate = '1',
    }) => JournalLineInput(
      ledgerAccountId: account.id!,
      debitMinor: isDebit ? amountMinor : 0,
      creditMinor: isDebit ? 0 : amountMinor,
      currencyCode: currency,
      functionalDebitMinor: isDebit
          ? (functionalAmountMinor < 0 ? amountMinor : functionalAmountMinor)
          : 0,
      functionalCreditMinor: isDebit
          ? 0
          : (functionalAmountMinor < 0 ? amountMinor : functionalAmountMinor),
      exchangeRate: rate,
      rateDate: DateTime(2026, 11),
      rateSource: 'manual',
    );

    /// Posts a one-shot journal through the draft and post paths.
    Future<Journal> post(
      TestSessionBuilder session,
      Budget budget, {
      required DateTime date,
      required List<JournalLineInput> lines,
      String source = 'manual',
    }) async {
      final draft = await endpoints.ledger.saveDraftJournal(
        session,
        budget.id!,
        date,
        lines,
        reference: 'JB-test',
        source: source,
      );
      return endpoints.ledger.postJournal(session, draft.id!);
    }

    group('when enabling the ledger', () {
      test('then the caller must own the budget', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);

        await expectLater(
          endpoints.ledger.enableLedger(stranger, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('then a budget without a tax profile is rejected', () async {
        final budget = await createBudget(
          owner,
          TaxEntityKind.company,
          withProfile: false,
        );

        await expectLater(
          endpoints.ledger.enableLedger(owner, budget.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then individual budgets are rejected', () async {
        final budget = await createBudget(
          owner,
          TaxEntityKind.individual,
        );

        await expectLater(
          endpoints.ledger.enableLedger(owner, budget.id!),
          throwsA(isA<ValidationException>()),
        );
        expect(budget.accountingMode, 'envelope');
      });

      test('then a company budget seeds the chart and switches mode', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);

        final accounts = await enableLedger(owner, budget);

        final updated = await endpoints.budget.get(owner, budget.id!);
        expect(updated.accountingMode, 'ledger');
        final codes = accounts.keys.toList()..sort();
        expect(codes, hasLength(greaterThanOrEqualTo(20)));
        expect(accounts['2200']!.systemRole, 'vatControl');
        expect(accounts['2500']!.systemRole, 'directorsLoan');
        expect(accounts['1000']!.systemRole, 'bank');
        expect(codes.toSet(), hasLength(codes.length));
      });

      test(
        'then a sole-trader chart has drawings and no director loan',
        () async {
          final budget = await createBudget(
            owner,
            TaxEntityKind.soleTrader,
          );

          final accounts = await enableLedger(owner, budget);

          final roles = accounts.values
              .map((account) => account.systemRole)
              .whereType<String>()
              .toSet();
          expect(roles, contains('ownerDrawings'));
          expect(roles, isNot(contains('directorsLoan')));
        },
      );

      test('then each jurisdiction seeds its own codes', () async {
        final usBudget = await createBudget(
          owner,
          TaxEntityKind.soleTrader,
          currency: 'USD',
          jurisdiction: 'US',
        );
        final deBudget = await createBudget(
          owner,
          TaxEntityKind.company,
          currency: 'EUR',
          jurisdiction: 'DE',
        );

        final usAccounts = await enableLedger(owner, usBudget);
        final deAccounts = await enableLedger(owner, deBudget);

        expect(usAccounts['2200']!.name, 'Sales tax payable');
        expect(deAccounts['1800']!.systemRole, 'bank');
        expect(deAccounts['2900']!.name, 'Stammkapital');
      });

      test('then enabling twice is rejected', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        await enableLedger(owner, budget);

        await expectLater(
          endpoints.ledger.enableLedger(owner, budget.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then an audit event records the switch', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        await enableLedger(owner, budget);

        final events = await LedgerAuditEvent.db.find(sessionBuilder.build());
        expect(
          events.any((event) => event.action == 'ledger.enabled'),
          isTrue,
        );
      });
    });

    group('when budget ownership is checked', () {
      test('then a stranger cannot list accounts', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        await enableLedger(owner, budget);

        await expectLater(
          endpoints.ledger.listAccounts(
            stranger,
            budget.id!,
            includeArchived: false,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('then a stranger cannot save drafts or post', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);

        await expectLater(
          endpoints.ledger.saveDraftJournal(
            stranger,
            budget.id!,
            openingDate,
            [
              line(accounts['1000']!, isDebit: true, amountMinor: 1000),
              line(accounts['3200']!, isDebit: false, amountMinor: 1000),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('then a stranger cannot post or reverse by journal id', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 1000),
            line(accounts['3200']!, isDebit: false, amountMinor: 1000),
          ],
          source: 'opening',
        );

        await expectLater(
          endpoints.ledger.postJournal(stranger, journal.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.ledger.reverseJournal(stranger, journal.id!, laterDate),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('then a stranger cannot read lines or the lock date', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 1000),
            line(accounts['3200']!, isDebit: false, amountMinor: 1000),
          ],
          source: 'opening',
        );

        await expectLater(
          endpoints.ledger.listJournalLines(stranger, journal.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.ledger.getLockDate(stranger, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when saving drafts', () {
      late Budget budget;
      late Map<String, LedgerAccount> accounts;

      setUp(() async {
        budget = await createBudget(owner, TaxEntityKind.company);
        accounts = await enableLedger(owner, budget);
      });

      test('then a balanced draft is stored', () async {
        final draft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          openingDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          reference: 'JB-OPEN-1',
          narration: 'Opening cash',
          source: 'opening',
        );

        expect(draft.status, 'draft');
        expect(draft.reference, 'JB-OPEN-1');
        expect(draft.source, 'opening');
        expect(draft.postedAt, isNull);
      });

      test('then an unbalanced draft is rejected (T1)', () async {
        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              line(accounts['1000']!, isDebit: true, amountMinor: 10000),
              line(accounts['4000']!, isDebit: false, amountMinor: 9999),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a single-line draft is rejected (T1)', () async {
        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              line(accounts['1000']!, isDebit: true, amountMinor: 10000),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a line with both sides is rejected (T1)', () async {
        final badLine = JournalLineInput(
          ledgerAccountId: accounts['1000']!.id!,
          debitMinor: 100,
          creditMinor: 100,
          currencyCode: 'GBP',
          functionalDebitMinor: 100,
          functionalCreditMinor: 0,
          exchangeRate: '1',
          rateDate: DateTime(2026, 11),
          rateSource: 'manual',
        );

        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              badLine,
              line(accounts['4000']!, isDebit: false, amountMinor: 100),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then foreign-currency lines balance per currency (T1)', () async {
        // USD 100.00 Dr at 0.8 and USD 99.00 Cr at 0.808081: both GBP 80.00,
        // balanced in the functional currency but not in USD. Rejected.
        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              line(
                accounts['1000']!,
                isDebit: true,
                amountMinor: 10000,
                currency: 'USD',
                functionalAmountMinor: 8000,
                rate: '0.8',
              ),
              line(
                accounts['4000']!,
                isDebit: false,
                amountMinor: 9900,
                currency: 'USD',
                functionalAmountMinor: 8000,
                rate: '0.808081',
              ),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a draft lists its lines for editing', () async {
        final draft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          openingDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 2500),
            line(accounts['3200']!, isDebit: false, amountMinor: 2500),
          ],
          reference: 'JB-lines',
          source: 'manual',
        );

        final lines = await endpoints.ledger.listJournalLines(
          owner,
          draft.id!,
        );

        expect(lines, hasLength(2));
        expect(
          {
            for (final l in lines)
              l.ledgerAccountId: (l.debitMinor, l.creditMinor),
          },
          {
            accounts['1000']!.id: (2500, 0),
            accounts['3200']!.id: (0, 2500),
          },
        );
      });

      test('then a draft can be edited', () async {
        final draft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          openingDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          reference: 'JB-OPEN-1',
          source: 'manual',
        );

        final updated = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          feeDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 60000),
            line(accounts['3200']!, isDebit: false, amountMinor: 60000),
          ],
          journalId: draft.id,
          reference: 'JB-OPEN-1',
          source: 'manual',
        );

        expect(updated.id, draft.id);
        expect(updated.date.year, feeDate.year);
        expect(updated.date.month, feeDate.month);
        expect(updated.date.day, feeDate.day);
        final lines = await JournalLine.db.find(
          owner.build(),
          where: (l) => l.journalId.equals(draft.id),
        );
        expect(lines, hasLength(2));
        expect(
          lines.fold<int>(0, (sum, l) => sum + l.functionalDebitMinor),
          60000,
        );
      });

      test('then a draft can be deleted', () async {
        final draft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          openingDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          reference: '',
          source: 'manual',
        );

        await endpoints.ledger.deleteDraftJournal(owner, draft.id!);

        final journals = await endpoints.ledger.listJournals(
          owner,
          budget.id!,
        );
        expect(journals, isEmpty);
      });

      test('then drafts reference only accounts inside the budget', () async {
        final otherBudget = await createBudget(owner, TaxEntityKind.company);
        await enableLedger(owner, otherBudget);
        final otherAccounts = await endpoints.ledger.listAccounts(
          owner,
          otherBudget.id!,
          includeArchived: false,
        );

        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              line(otherAccounts.first, isDebit: true, amountMinor: 1000),
              line(accounts['3200']!, isDebit: false, amountMinor: 1000),
            ],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('when posting and reversing', () {
      late Budget budget;
      late Map<String, LedgerAccount> accounts;

      setUp(() async {
        budget = await createBudget(owner, TaxEntityKind.company);
        accounts = await enableLedger(owner, budget);
      });

      test('then a posted journal is stamped and immutable', () async {
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );

        expect(journal.status, 'posted');
        expect(journal.postedAt, isNotNull);
        expect(journal.postedBy, isNotNull);

        await expectLater(
          endpoints.ledger.postJournal(owner, journal.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.ledger.deleteDraftJournal(owner, journal.id!),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [
              line(accounts['1000']!, isDebit: true, amountMinor: 1),
              line(accounts['3200']!, isDebit: false, amountMinor: 1),
            ],
            journalId: journal.id,
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then the bank-fee journal posts and reverses (T5.3)', () async {
        await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        final fee = await post(
          owner,
          budget,
          date: feeDate,
          lines: [
            line(accounts['5600']!, isDebit: true, amountMinor: 1250),
            line(accounts['1000']!, isDebit: false, amountMinor: 1250),
          ],
        );

        final before = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          feeDate,
        );
        expect(before.totalDebitMinor, 51250);

        final reversal = await endpoints.ledger.reverseJournal(
          owner,
          fee.id!,
          laterDate,
        );

        expect(reversal.status, 'posted');
        expect(reversal.source, 'reversal');
        expect(reversal.reversalOfJournalId, fee.id);
        final refetchedFee = await endpoints.ledger.listJournals(
          owner,
          budget.id!,
        );
        expect(
          refetchedFee.firstWhere((j) => j.id == fee.id).status,
          'reversed',
        );

        final after = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          laterDate,
        );
        final netByCode = {
          for (final row in after.rows) row.accountCode: row.netMinor,
        };
        expect(netByCode['1000'], 50000);
        expect(netByCode['5600'], 0);
        expect(netByCode['3200'], -50000);
        // Opening plus the fee and its reversal: both journals stay in the
        // books and the mirror journal cancels the fee.
        expect(after.totalDebitMinor, 52500);
        expect(after.totalCreditMinor, 52500);
      });

      test('then a journal cannot be reversed twice', () async {
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        await endpoints.ledger.reverseJournal(owner, journal.id!, feeDate);

        await expectLater(
          endpoints.ledger.reverseJournal(owner, journal.id!, laterDate),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a mixed-currency settlement journal posts (T6.1)', () async {
        // Day 1: USD 1,000.00 invoice at 0.8 GBP per USD books GBP 800.00
        // (Dr AR, Cr Sales). Day 20: paid USD 1,000.00 at 0.769231 = GBP
        // 769.23, realised FX loss GBP 30.77 releases the AR at 0.8.
        await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(
              accounts['1100']!,
              isDebit: true,
              amountMinor: 100000,
              currency: 'USD',
              functionalAmountMinor: 80000,
              rate: '0.8',
            ),
            line(
              accounts['4000']!,
              isDebit: false,
              amountMinor: 80000,
            ),
          ],
        );
        await post(
          owner,
          budget,
          date: laterDate,
          lines: [
            line(
              accounts['1000']!,
              isDebit: true,
              amountMinor: 100000,
              currency: 'USD',
              functionalAmountMinor: 76923,
              rate: '0.769231',
            ),
            line(accounts['5800']!, isDebit: true, amountMinor: 3077),
            line(
              accounts['1100']!,
              isDebit: false,
              amountMinor: 100000,
              currency: 'USD',
              functionalAmountMinor: 80000,
              rate: '0.8',
            ),
          ],
        );

        final trialBalance = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          laterDate,
        );
        final netByCode = {
          for (final row in trialBalance.rows) row.accountCode: row.netMinor,
        };
        expect(netByCode['1100'], 0);
        expect(netByCode['1000'], 76923);
        expect(netByCode['5800'], 3077);
        expect(netByCode['4000'], -80000);
        expect(trialBalance.totalDebitMinor, trialBalance.totalCreditMinor);
      });

      test(
        'then a functional amount contradicting the rate is rejected',
        () async {
          await expectLater(
            endpoints.ledger.saveDraftJournal(
              owner,
              budget.id!,
              openingDate,
              [
                line(
                  accounts['1000']!,
                  isDebit: true,
                  amountMinor: 100000,
                  currency: 'USD',
                  functionalAmountMinor: 76923,
                  rate: '0.8',
                ),
                line(accounts['4000']!, isDebit: false, amountMinor: 76923),
              ],
              reference: '',
              source: 'manual',
            ),
            throwsA(isA<ValidationException>()),
          );
        },
      );

      test('then audit rows exist for post and reversal', () async {
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        await endpoints.ledger.reverseJournal(owner, journal.id!, feeDate);

        final events = await LedgerAuditEvent.db.find(owner.build());
        final actions = events.map((event) => event.action).toSet();
        expect(actions, containsAll(['journal.posted', 'journal.reversed']));
      });
    });

    group('when the period is locked', () {
      late Budget budget;
      late Map<String, LedgerAccount> accounts;

      setUp(() async {
        budget = await createBudget(owner, TaxEntityKind.company);
        accounts = await enableLedger(owner, budget);
      });

      test('then posting on or before the lock date is rejected', () async {
        await endpoints.ledger.setLockDate(owner, budget.id!, feeDate);

        final draft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          feeDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 1000),
            line(accounts['5600']!, isDebit: false, amountMinor: 1000),
          ],
          reference: '',
          source: 'manual',
        );

        await expectLater(
          endpoints.ledger.postJournal(owner, draft.id!),
          throwsA(isA<ValidationException>()),
        );

        final openDraft = await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          laterDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 1000),
            line(accounts['5600']!, isDebit: false, amountMinor: 1000),
          ],
          reference: '',
          source: 'manual',
        );
        final posted = await endpoints.ledger.postJournal(owner, openDraft.id!);
        expect(posted.status, 'posted');
      });

      test('then reversing into the locked period is rejected', () async {
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        await endpoints.ledger.setLockDate(owner, budget.id!, feeDate);

        await expectLater(
          endpoints.ledger.reverseJournal(owner, journal.id!, feeDate),
          throwsA(isA<ValidationException>()),
        );

        final reversal = await endpoints.ledger.reverseJournal(
          owner,
          journal.id!,
          laterDate,
        );
        expect(reversal.status, 'posted');
      });

      test('then the lock date reads back once set', () async {
        expect(await endpoints.ledger.getLockDate(owner, budget.id!), isNull);

        await endpoints.ledger.setLockDate(owner, budget.id!, feeDate);

        final lock = await endpoints.ledger.getLockDate(owner, budget.id!);
        expect(lock?.lockDate, DateTime.utc(2026, 11, 3));
      });

      test('then setting the lock is audited', () async {
        await endpoints.ledger.setLockDate(owner, budget.id!, feeDate);

        final events = await LedgerAuditEvent.db.find(owner.build());
        final lockEvents = events
            .where((event) => event.action == 'lock.set')
            .toList();
        expect(lockEvents, hasLength(1));
        expect(
          lockEvents.single.payloadJson,
          contains(feeDate.toIso8601String().substring(0, 10)),
        );
      });
    });

    group('when archiving accounts', () {
      late Budget budget;
      late Map<String, LedgerAccount> accounts;

      setUp(() async {
        budget = await createBudget(owner, TaxEntityKind.company);
        accounts = await enableLedger(owner, budget);
      });

      test('then system accounts are refused', () async {
        await expectLater(
          endpoints.ledger.archiveAccount(owner, accounts['1000']!.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a cleared account archives', () async {
        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['5600']!, isDebit: true, amountMinor: 1250),
            line(accounts['1000']!, isDebit: false, amountMinor: 1250),
          ],
        );
        await endpoints.ledger.reverseJournal(owner, journal.id!, feeDate);

        final archived = await endpoints.ledger.archiveAccount(
          owner,
          accounts['5600']!.id!,
        );
        expect(archived.archived, isTrue);

        final visible = await endpoints.ledger.listAccounts(
          owner,
          budget.id!,
          includeArchived: false,
        );
        expect(
          visible.any((account) => account.code == '5600'),
          isFalse,
        );
        final all = await endpoints.ledger.listAccounts(
          owner,
          budget.id!,
          includeArchived: true,
        );
        expect(all.any((account) => account.code == '5600'), isTrue);
      });

      test('then a non-zero balance refuses to archive', () async {
        await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['5600']!, isDebit: true, amountMinor: 1250),
            line(accounts['1000']!, isDebit: false, amountMinor: 1250),
          ],
        );

        await expectLater(
          endpoints.ledger.archiveAccount(owner, accounts['5600']!.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a duplicate code is refused', () async {
        await expectLater(
          endpoints.ledger.createAccount(
            owner,
            budget.id!,
            '1000',
            'Second bank',
            'asset',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a duplicate system role is refused', () async {
        await expectLater(
          endpoints.ledger.createAccount(
            owner,
            budget.id!,
            '1500',
            'Piggy bank',
            'asset',
            systemRole: 'bank',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a new account can be created and used', () async {
        final account = await endpoints.ledger.createAccount(
          owner,
          budget.id!,
          '6100',
          'Marketing',
          'expense',
        );
        expect(account.systemRole, isNull);

        final journal = await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(account, isDebit: true, amountMinor: 2000),
            line(accounts['1000']!, isDebit: false, amountMinor: 2000),
          ],
        );
        expect(journal.status, 'posted');
      });
    });

    group('when computing the trial balance', () {
      test('then it balances across posted journals (T8.1 shape)', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);

        await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        await post(
          owner,
          budget,
          date: feeDate,
          lines: [
            line(accounts['5600']!, isDebit: true, amountMinor: 1250),
            line(accounts['1000']!, isDebit: false, amountMinor: 1250),
          ],
        );

        final trialBalance = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          feeDate,
        );

        expect(trialBalance.currencyCode, 'GBP');
        final byCode = {
          for (final row in trialBalance.rows) row.accountCode: row,
        };
        expect(byCode['1000']!.debitMinor, 50000);
        expect(byCode['1000']!.creditMinor, 1250);
        expect(byCode['1000']!.netMinor, 48750);
        expect(byCode['5600']!.netMinor, 1250);
        expect(byCode['3200']!.netMinor, -50000);
        expect(byCode['3200']!.accountType, 'equity');
        expect(trialBalance.totalDebitMinor, 51250);
        expect(trialBalance.totalCreditMinor, 51250);
      });

      test('then journals after the as-of date are excluded', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);

        await post(
          owner,
          budget,
          date: openingDate,
          lines: [
            line(accounts['1000']!, isDebit: true, amountMinor: 50000),
            line(accounts['3200']!, isDebit: false, amountMinor: 50000),
          ],
          source: 'opening',
        );
        await post(
          owner,
          budget,
          date: laterDate,
          lines: [
            line(accounts['5600']!, isDebit: true, amountMinor: 1250),
            line(accounts['1000']!, isDebit: false, amountMinor: 1250),
          ],
        );

        final before = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          openingDate,
        );
        expect(before.rows, hasLength(2));
        expect(before.totalDebitMinor, 50000);
      });

      test('then drafts never feed the trial balance', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        final accounts = await enableLedger(owner, budget);

        await endpoints.ledger.saveDraftJournal(
          owner,
          budget.id!,
          openingDate,
          [
            line(accounts['1000']!, isDebit: true, amountMinor: 99999),
            line(accounts['3200']!, isDebit: false, amountMinor: 99999),
          ],
          reference: '',
          source: 'manual',
        );

        final trialBalance = await endpoints.ledger.trialBalance(
          owner,
          budget.id!,
          laterDate,
        );
        expect(trialBalance.rows, isEmpty);
        expect(trialBalance.totalDebitMinor, 0);
      });

      test('then a stranger cannot read the trial balance', () async {
        final budget = await createBudget(owner, TaxEntityKind.company);
        await enableLedger(owner, budget);

        await expectLater(
          endpoints.ledger.trialBalance(stranger, budget.id!, laterDate),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when the budget is in envelope mode', () {
      test('then ledger calls are refused', () async {
        final budget = await createBudget(
          owner,
          TaxEntityKind.company,
          withProfile: false,
        );

        await expectLater(
          endpoints.ledger.listAccounts(
            owner,
            budget.id!,
            includeArchived: false,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.ledger.saveDraftJournal(
            owner,
            budget.id!,
            openingDate,
            [],
            reference: '',
            source: 'manual',
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.ledger.trialBalance(owner, budget.id!, laterDate),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
