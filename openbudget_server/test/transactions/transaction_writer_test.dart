// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

final _date = DateTime.utc(2026, 3, 10);

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
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
    addTearDown(() async {
      await book.expectBalancesConsistent();
    });
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
    String? fxRate,
    UuidValue? payeeId,
    String? payeeName,
    String description = '',
    String? memo,
    TransactionStatus status = TransactionStatus.uncleared,
    TransactionFlag? flag,
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

  Future<List<model.Transaction>> transactions(Account account) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(account.id),
      );

  group('create', () {
    test('writes the header, lines and cached balance exactly', () async {
      final account = await book.addAccount();
      final view = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -1250,
          description: 'Groceries',
          lines: [
            TransactionLineInput(amountMinor: -500),
            TransactionLineInput(amountMinor: -750),
          ],
        ),
      );

      expect(view.transaction.amountMinor, -1250);
      expect(view.transaction.baseAmountMinor, -1250);
      expect(view.transaction.fxRate, '1');
      expect(view.transaction.fxRateSource, FxRateSource.identity);
      expect(view.lines.map((line) => line.amountMinor), [-500, -750]);
      expect(view.lines.map((line) => line.baseAmountMinor), [-500, -750]);
      expect(view.lines.map((line) => line.sortOrder), [0, 1]);
      expect(view.accountCurrencyCode, 'GBP');
      expect(await book.cachedBalanceMinor(account), -1250);
      expect(await book.recomputedBalanceMinor(account), -1250);
      expect(await book.lineCount(view.transaction.id!), 2);

      expect(events, hasLength(1));
      expect(events.single.entityId, book.entity.id);
      expect(events.single.scope, ChangeScope.transactions);
      expect(events.single.month, 202603);
      expect(events.single.accountId, account.id);
    });

    test('empty lines become one line for the whole amount', () async {
      final account = await book.addAccount();

      final view = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: 4200),
      );

      expect(view.lines, hasLength(1));
      expect(view.lines.single.amountMinor, 4200);
      expect(view.lines.single.baseAmountMinor, 4200);
      expect(view.lines.single.envelopeId, isNull);
    });

    test('a manual rate is stored as manual with its exact base', () async {
      final account = await book.addAccount(currencyCode: 'USD');

      final view = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: 3333, fxRate: '0.8'),
      );

      expect(view.transaction.fxRate, '0.8');
      expect(view.transaction.fxRateSource, FxRateSource.manual);
      expect(view.transaction.fxRateDate, _date);
      expect(view.transaction.baseAmountMinor, 2666);
      expect(await book.cachedBalanceMinor(account), 3333);
    });

    test(
      'a missing market rate throws with every field and writes nothing',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');

        try {
          await TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 1000),
          );
          fail('expected FxRateUnavailableException');
        } on FxRateUnavailableException catch (error) {
          expect(error.fromCurrencyCode, 'USD');
          expect(error.toCurrencyCode, 'GBP');
          expect(error.date, _date);
          expect(error.message, isNotEmpty);
        }

        expect(await transactions(account), isEmpty);
        expect(await book.cachedBalanceMinor(account), 0);
        expect(events, isEmpty);
      },
    );

    test(
      'same-currency identity wins even when a manual rate is supplied',
      () async {
        final account = await book.addAccount();

        final view = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: 100, fxRate: '2'),
        );

        expect(view.transaction.fxRate, '1');
        expect(view.transaction.fxRateSource, FxRateSource.identity);
        expect(view.transaction.baseAmountMinor, 100);
      },
    );

    test('a caller transaction resolves rates in its own snapshot', () async {
      final account = await book.addAccount(currencyCode: 'USD');

      final view = await TransactionWriter.inTransaction(
        book.session,
        (tx) async {
          await book.seedRate(
            currencyCode: 'USD',
            rateDate: _date,
            rate: '1',
          );
          await book.seedRate(
            currencyCode: 'GBP',
            rateDate: _date,
            rate: '0.8',
          );
          return TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 5000),
            transaction: tx,
          );
        },
      );

      expect(view.transaction.fxRate, '0.8');
      expect(view.transaction.baseAmountMinor, 4000);
      expect(events, hasLength(1));
    });

    test('the payee rule fills only the no-envelope single outflow', () async {
      final account = await book.addAccount();
      final payee = await book.addPayee();
      final ruleEnvelope = await book.addEnvelope(name: 'Rule');
      final explicitEnvelope = await book.addEnvelope(name: 'Explicit');
      await book.addRule(payee: payee, envelope: ruleEnvelope);

      final ruled = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -500, payeeId: payee.id),
      );
      final explicit = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -500,
          payeeId: payee.id,
          lines: [
            TransactionLineInput(
              amountMinor: -500,
              envelopeId: explicitEnvelope.id,
            ),
          ],
        ),
      );
      final inflow = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: 500, payeeId: payee.id),
      );

      expect(ruled.lines.single.envelopeId, ruleEnvelope.id);
      expect(explicit.lines.single.envelopeId, explicitEnvelope.id);
      expect(inflow.lines.single.envelopeId, isNull);
    });

    test('payee names upsert on entity and name without duplicates', () async {
      final account = await book.addAccount();

      await Future.wait([
        for (var index = 0; index < 10; index++)
          TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 100, payeeName: 'Cafe'),
          ),
      ]);

      final payees = await Payee.db.find(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      );
      expect(payees, hasLength(1));
      expect(payees.single.name, 'Cafe');
      expect(await transactions(account), hasLength(10));
    });

    test('split residue lands on the largest absolute line', () async {
      final account = await book.addAccount(currencyCode: 'USD');

      final view = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -100,
          fxRate: '0.8',
          lines: [
            TransactionLineInput(amountMinor: -33),
            TransactionLineInput(amountMinor: -33),
            TransactionLineInput(amountMinor: -34),
          ],
        ),
      );

      expect(
        view.lines.map((line) => line.baseAmountMinor),
        [-26, -26, -28],
      );
      expect(
        view.lines.fold<int>(
          0,
          (sum, line) => sum + line.baseAmountMinor,
        ),
        view.transaction.baseAmountMinor,
      );
      expect(view.transaction.baseAmountMinor, -80);
    });

    test('JPY and KWD splits keep the base sum exact', () async {
      final yen = await book.addAccount(name: 'Yen', currencyCode: 'JPY');
      final dinar = await book.addAccount(name: 'Dinar', currencyCode: 'KWD');

      final yenView = await TransactionWriter.create(
        book.session,
        entry(
          yen,
          amountMinor: 1000,
          fxRate: '0.005',
          lines: [
            TransactionLineInput(amountMinor: 333),
            TransactionLineInput(amountMinor: 333),
            TransactionLineInput(amountMinor: 334),
          ],
        ),
      );
      final dinarView = await TransactionWriter.create(
        book.session,
        entry(
          dinar,
          amountMinor: 1000,
          fxRate: '2.555',
          lines: [
            TransactionLineInput(amountMinor: 333),
            TransactionLineInput(amountMinor: 333),
            TransactionLineInput(amountMinor: 334),
          ],
        ),
      );

      expect(yenView.transaction.baseAmountMinor, 500);
      expect(
        yenView.lines.fold<int>(
          0,
          (sum, line) => sum + line.baseAmountMinor,
        ),
        500,
      );
      expect(dinarView.transaction.baseAmountMinor, 256);
      expect(
        dinarView.lines.fold<int>(
          0,
          (sum, line) => sum + line.baseAmountMinor,
        ),
        256,
      );
      expect(
        dinarView.lines.map((line) => line.baseAmountMinor),
        [85, 85, 86],
      );
    });

    test('a wrong line sum is rejected before any row is written', () async {
      final account = await book.addAccount();

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(
            account,
            amountMinor: -200,
            lines: [
              TransactionLineInput(amountMinor: -100),
              TransactionLineInput(amountMinor: -101),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await transactions(account), isEmpty);
      expect(await book.cachedBalanceMinor(account), 0);
    });

    test(
      'cross-entity envelopes, ledger accounts and accounts are forbidden',
      () async {
        final otherBook = await BudgetTestBook.create(
          server.anonymousSession(),
        );
        final otherEnvelope = await otherBook.addEnvelope();
        final account = await book.addAccount();

        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(
              account,
              amountMinor: -100,
              lines: [
                TransactionLineInput(
                  amountMinor: -100,
                  envelopeId: otherEnvelope.id,
                ),
              ],
            ),
          ),
          throwsA(isA<ForbiddenException>()),
        );

        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final otherLedgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final ledgerAccount = await ledgerBook.addAccount();
        final otherLedger = await otherLedgerBook.addLedgerAccount();

        await expectLater(
          TransactionWriter.create(
            ledgerBook.session,
            entry(
              ledgerAccount,
              amountMinor: -100,
              lines: [
                TransactionLineInput(
                  amountMinor: -100,
                  ledgerAccountId: otherLedger.id,
                ),
              ],
            ),
          ),
          throwsA(isA<ForbiddenException>()),
        );

        final otherPayee = await otherBook.addPayee();
        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(account, amountMinor: -100, payeeId: otherPayee.id),
          ),
          throwsA(isA<ForbiddenException>()),
        );

        final otherAccount = await otherBook.addAccount();
        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(otherAccount, amountMinor: -100),
          ),
          throwsA(isA<ForbiddenException>()),
        );
      },
    );

    test(
      'off-budget envelopes and envelope-mode ledger coding are rejected',
      () async {
        final offBudget = await book.addAccount(onBudget: false);
        final envelope = await book.addEnvelope();

        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(
              offBudget,
              amountMinor: -100,
              lines: [
                TransactionLineInput(
                  amountMinor: -100,
                  envelopeId: envelope.id,
                ),
              ],
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final account = await book.addAccount();
        final ledger = await book.addLedgerAccount();
        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(
              account,
              amountMinor: -100,
              lines: [
                TransactionLineInput(
                  amountMinor: -100,
                  ledgerAccountId: ledger.id,
                ),
              ],
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final valuation = await book.addAccount(
          name: 'House',
          kind: AccountKind.property,
          balanceSource: AccountBalanceSource.valuations,
        );
        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(valuation, amountMinor: 100),
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('tax, business-use and sales-tax line rules are enforced', () async {
      final account = await book.addAccount();
      final envelope = await book.addEnvelope();

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(
            account,
            amountMinor: -100,
            lines: [
              TransactionLineInput(
                amountMinor: -100,
                envelopeId: envelope.id,
                businessUsePercent: 101,
              ),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(
            account,
            amountMinor: -100,
            lines: [
              TransactionLineInput(amountMinor: -100, salesTaxMinor: 20),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(
            account,
            amountMinor: -100,
            lines: [
              TransactionLineInput(
                amountMinor: -100,
                envelopeId: envelope.id,
                taxCategoryCode: 'not.a.code',
              ),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      final valid = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -120,
          lines: [
            TransactionLineInput(
              amountMinor: -120,
              envelopeId: envelope.id,
              businessUsePercent: 100,
              salesTaxMinor: -20,
              taxCategoryCode: 'gb.ind.out_of_scope',
            ),
          ],
        ),
      );
      expect(valid.lines.single.salesTaxMinor, -20);
      expect(valid.lines.single.taxCategoryCode, 'gb.ind.out_of_scope');
    });

    test(
      'invalid civil dates and dates beyond tomorrow are rejected',
      () async {
        final account = await book.addAccount();

        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(account, date: DateTime(2026, 3, 10)),
          ),
          throwsA(isA<ValidationException>()),
        );

        await expectLater(
          TransactionWriter.create(
            book.session,
            entry(
              account,
              date: EntityClock.today(book.entity).add(
                const Duration(days: 2),
              ),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('closed accounts reject new transactions', () async {
      final account = await book.addAccount(
        closedAt: DateTime.utc(2026, 1, 1),
      );

      await expectLater(
        TransactionWriter.create(book.session, entry(account)),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a ledger account cannot code to itself or be archived', () async {
      final ledgerBook = await BudgetTestBook.create(
        server.anonymousSession(),
        accountingMode: AccountingMode.ledger,
      );
      final ownLedger = await ledgerBook.addLedgerAccount();
      final archived = await ledgerBook.addLedgerAccount(
        code: '6200',
        name: 'Archived',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final account = await ledgerBook.addAccount(
        ledgerAccountId: ownLedger.id,
      );

      await expectLater(
        TransactionWriter.create(
          ledgerBook.session,
          entry(
            account,
            amountMinor: -100,
            lines: [
              TransactionLineInput(
                amountMinor: -100,
                ledgerAccountId: ownLedger.id,
              ),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.create(
          ledgerBook.session,
          entry(
            account,
            amountMinor: -100,
            lines: [
              TransactionLineInput(
                amountMinor: -100,
                ledgerAccountId: archived.id,
              ),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('amounts outside the safe minor-unit range are rejected', () async {
      final account = await book.addAccount();

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(account, amountMinor: maxSafeMinor + 1),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(
            account,
            amountMinor: maxSafeMinor,
            lines: [
              TransactionLineInput(amountMinor: maxSafeMinor + 1),
              TransactionLineInput(amountMinor: -1),
            ],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'the ledger period lock rejects entries on or before the lock',
      () async {
        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final account = await ledgerBook.addAccount();
        await ledgerBook.addPeriodLock(DateTime.utc(2026, 2, 28));

        await expectLater(
          TransactionWriter.create(
            ledgerBook.session,
            entry(account, date: DateTime.utc(2026, 2, 28)),
          ),
          throwsA(isA<ValidationException>()),
        );

        final allowed = await TransactionWriter.create(
          ledgerBook.session,
          entry(account, date: DateTime.utc(2026, 3, 1)),
        );
        expect(allowed.transaction.date, DateTime.utc(2026, 3, 1));
      },
    );
  });

  group('update', () {
    test('a memo-only edit preserves the stored market rate', () async {
      final account = await book.addAccount(currencyCode: 'USD');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: 10000),
      );
      expect(created.transaction.fxRate, '0.8');

      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: _date.add(const Duration(days: 1)),
        rate: '0.9',
      );
      await book.session.caches.clear();

      final updated = await TransactionWriter.update(
        book.session,
        created.transaction.id!,
        entry(account, amountMinor: 10000, memo: 'Edited memo'),
      );

      expect(updated.transaction.fxRate, '0.8');
      expect(updated.transaction.fxRateDate, _date);
      expect(updated.transaction.fxRateSource, FxRateSource.market);
      expect(updated.transaction.baseAmountMinor, 8000);
      expect(updated.transaction.memo, 'Edited memo');
      expect(await book.cachedBalanceMinor(account), 10000);
    });

    test('a money edit re-resolves the market rate', () async {
      final account = await book.addAccount(currencyCode: 'USD');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: 10000),
      );
      expect(created.transaction.baseAmountMinor, 8000);

      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.9',
      );
      await book.session.caches.clear();

      final edited = await TransactionWriter.update(
        book.session,
        created.transaction.id!,
        entry(account, amountMinor: 11000),
      );

      expect(edited.transaction.fxRate, '0.9');
      expect(edited.transaction.baseAmountMinor, 9900);
      expect(edited.transaction.fxRateSource, FxRateSource.market);
      expect(await book.cachedBalanceMinor(account), 11000);
    });

    test('moves the exact old and new deltas between accounts', () async {
      final source = await book.addAccount(name: 'Source');
      final target = await book.addAccount(name: 'Target');
      final created = await TransactionWriter.create(
        book.session,
        entry(source, amountMinor: -300),
      );

      final moved = await TransactionWriter.update(
        book.session,
        created.transaction.id!,
        entry(target, amountMinor: -300),
      );

      final closed = await book.addAccount(
        name: 'Closed',
        closedAt: DateTime.utc(2026, 1, 1),
      );
      await expectLater(
        TransactionWriter.update(
          book.session,
          created.transaction.id!,
          entry(closed, amountMinor: -300),
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(moved.transaction.accountId, target.id);
      expect(await book.cachedBalanceMinor(source), 0);
      expect(await book.cachedBalanceMinor(target), -300);
      expect(await book.recomputedBalanceMinor(source), 0);
      expect(await book.recomputedBalanceMinor(target), -300);
    });

    test('cannot move to an account in another entity', () async {
      final source = await book.addAccount();
      final otherBook = await BudgetTestBook.create(server.anonymousSession());
      final foreign = await otherBook.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(source, amountMinor: -300),
      );

      await expectLater(
        TransactionWriter.update(
          book.session,
          created.transaction.id!,
          entry(foreign, amountMinor: -300),
        ),
        throwsA(isA<ForbiddenException>()),
      );

      final sameOwnerOtherEntity = await book.addAccount();
      final otherEntity = await Entity.db.insertRow(
        book.session,
        Entity(
          ownerId: book.userId,
          name: 'Second entity',
          kind: EntityKind.individual,
          countryCode: 'GB',
          baseCurrencyCode: 'GBP',
          timeZone: 'Europe/London',
          fiscalYearEndMonth: 4,
          fiscalYearEndDay: 5,
        ),
      );
      final crossEntity = await Account.db.insertRow(
        book.session,
        Account(
          entityId: otherEntity.id!,
          name: 'Other entity account',
          kind: AccountKind.checking,
          currencyCode: 'GBP',
          balanceSource: AccountBalanceSource.transactions,
          onBudget: true,
        ),
      );

      await expectLater(
        TransactionWriter.update(
          book.session,
          created.transaction.id!,
          entry(crossEntity, amountMinor: -300),
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await book.cachedBalanceMinor(sameOwnerOtherEntity), 0);
    });

    test('a reconciled row permits metadata and protects money', () async {
      final account = await book.addAccount();
      final other = await book.addAccount(name: 'Other');
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -500),
      );
      final id = created.transaction.id!;

      final reconciled = await TransactionWriter.update(
        book.session,
        id,
        entry(account, amountMinor: -500, status: TransactionStatus.reconciled),
      );
      expect(reconciled.transaction.status, TransactionStatus.reconciled);

      for (final changed in [
        entry(account, amountMinor: -600, status: TransactionStatus.reconciled),
        entry(
          account,
          amountMinor: -500,
          date: DateTime.utc(2026, 3, 11),
          status: TransactionStatus.reconciled,
        ),
        entry(other, amountMinor: -500, status: TransactionStatus.reconciled),
      ]) {
        await expectLater(
          TransactionWriter.update(book.session, id, changed),
          throwsA(isA<ValidationException>()),
        );
      }

      await expectLater(
        TransactionWriter.updateLines(
          book.session,
          id,
          [TransactionLineInput(amountMinor: -250)],
        ),
        throwsA(isA<ValidationException>()),
      );

      final unlocked = await TransactionWriter.update(
        book.session,
        id,
        entry(
          account,
          amountMinor: -500,
          status: TransactionStatus.cleared,
          flag: TransactionFlag.blue,
          memo: 'Checked',
          description: 'Updated',
        ),
      );

      expect(unlocked.transaction.status, TransactionStatus.cleared);
      expect(unlocked.transaction.flag, TransactionFlag.blue);
      expect(unlocked.transaction.memo, 'Checked');
      expect(unlocked.transaction.description, 'Updated');
      expect(await book.cachedBalanceMinor(account), -500);
    });

    test('a transfer leg rejects account and amount changes', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final fromLeg = await TransactionWriter.create(
        book.session,
        entry(from, amountMinor: -400),
      );
      final toLeg = await TransactionWriter.create(
        book.session,
        entry(to, amountMinor: 400),
      );
      await Transfer.db.insertRow(
        book.session,
        Transfer(
          fromTransactionId: fromLeg.transaction.id!,
          toTransactionId: toLeg.transaction.id!,
        ),
      );

      await expectLater(
        TransactionWriter.update(
          book.session,
          fromLeg.transaction.id!,
          entry(from, amountMinor: -500, memo: 'metadata ok'),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.updateLines(
          book.session,
          fromLeg.transaction.id!,
          [TransactionLineInput(amountMinor: -400)],
        ),
        throwsA(isA<ValidationException>()),
      );

      final metadata = await TransactionWriter.update(
        book.session,
        fromLeg.transaction.id!,
        entry(from, amountMinor: -400, memo: 'metadata ok'),
      );
      expect(metadata.transaction.memo, 'metadata ok');
    });

    test(
      'ledger mode revisions and audit events follow material edits',
      () async {
        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final account = await ledgerBook.addAccount();
        final created = await TransactionWriter.create(
          ledgerBook.session,
          entry(account, amountMinor: -100),
        );
        final id = created.transaction.id!;
        expect(created.transaction.revision, 0);

        await ledgerBook.addPeriodLock(DateTime.utc(2026, 1, 31));
        final edited = await TransactionWriter.update(
          ledgerBook.session,
          id,
          entry(account, amountMinor: -200),
        );
        expect(edited.transaction.revision, 1);
        final editAudits = await AuditEvent.db.find(
          ledgerBook.session,
          where: (t) =>
              t.entityId.equals(ledgerBook.entity.id) &
              t.action.equals(AuditAction.transactionEdited),
        );
        expect(editAudits, hasLength(1));
        final payload = editAudits.single.payloadJson;
        expect(payload, contains('"before"'));
        expect(payload, contains('"amountMinor":-100'));

        final memo = await TransactionWriter.update(
          ledgerBook.session,
          id,
          entry(account, amountMinor: -200, memo: 'No revision'),
        );
        expect(memo.transaction.revision, 1);
        expect(
          await AuditEvent.db.find(
            ledgerBook.session,
            where: (t) =>
                t.entityId.equals(ledgerBook.entity.id) &
                t.action.equals(AuditAction.transactionEdited),
          ),
          hasLength(1),
        );

        final relined = await TransactionWriter.updateLines(
          ledgerBook.session,
          id,
          [
            TransactionLineInput(amountMinor: -80),
            TransactionLineInput(amountMinor: -120),
          ],
        );
        expect(relined.transaction.revision, 2);
        expect(
          await AuditEvent.db.find(
            ledgerBook.session,
            where: (t) =>
                t.entityId.equals(ledgerBook.entity.id) &
                t.action.equals(AuditAction.transactionEdited),
          ),
          hasLength(2),
        );

        await TransactionWriter.delete(ledgerBook.session, id);
        final deletes = await AuditEvent.db.find(
          ledgerBook.session,
          where: (t) =>
              t.entityId.equals(ledgerBook.entity.id) &
              t.action.equals(AuditAction.transactionDeleted),
        );
        expect(deletes, hasLength(1));
        expect(await ledgerBook.transaction(id), isNull);
      },
    );

    test(
      'the period lock protects updates and deletes, not metadata',
      () async {
        final ledgerBook = await BudgetTestBook.create(
          server.anonymousSession(),
          accountingMode: AccountingMode.ledger,
        );
        final account = await ledgerBook.addAccount();
        final created = await TransactionWriter.create(
          ledgerBook.session,
          entry(account, amountMinor: -100, date: DateTime.utc(2026, 2, 1)),
        );
        await ledgerBook.addPeriodLock(DateTime.utc(2026, 2, 28));
        final id = created.transaction.id!;

        await expectLater(
          TransactionWriter.update(
            ledgerBook.session,
            id,
            entry(
              account,
              amountMinor: -200,
              date: DateTime.utc(2026, 2, 1),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          TransactionWriter.delete(ledgerBook.session, id),
          throwsA(isA<ValidationException>()),
        );

        final metadata = await TransactionWriter.update(
          ledgerBook.session,
          id,
          entry(
            account,
            amountMinor: -100,
            date: DateTime.utc(2026, 2, 1),
            memo: 'Allowed metadata',
          ),
        );
        expect(metadata.transaction.memo, 'Allowed metadata');
      },
    );

    test(
      'a line-only edit keeps the stored market rate when history disappears',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');
        await book.seedMarketRate(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          rateDate: _date,
          fromPerUsd: '1',
          toPerUsd: '0.8',
        );
        final created = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -10000),
        );
        expect(created.transaction.fxRate, '0.8');
        expect(created.transaction.baseAmountMinor, -8000);

        await server.clearRates();

        final edited = await TransactionWriter.update(
          book.session,
          created.transaction.id!,
          entry(
            account,
            amountMinor: -10000,
            lines: [
              TransactionLineInput(amountMinor: -4000),
              TransactionLineInput(amountMinor: -6000),
            ],
          ),
        );

        expect(edited.transaction.fxRate, '0.8');
        expect(edited.transaction.fxRateDate, _date);
        expect(edited.transaction.fxRateSource, FxRateSource.market);
        expect(edited.transaction.baseAmountMinor, -8000);
        expect(
          edited.lines.map((line) => line.baseAmountMinor),
          [-3200, -4800],
        );
        expect(
          edited.lines.fold<int>(0, (sum, line) => sum + line.baseAmountMinor),
          -8000,
        );
      },
    );

    test('a line-only edit keeps an existing manual rate', () async {
      final account = await book.addAccount(currencyCode: 'USD');
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -10000, fxRate: '0.8'),
      );
      expect(created.transaction.fxRateSource, FxRateSource.manual);
      expect(created.transaction.baseAmountMinor, -8000);

      final edited = await TransactionWriter.update(
        book.session,
        created.transaction.id!,
        entry(
          account,
          amountMinor: -10000,
          lines: [
            TransactionLineInput(amountMinor: -4000),
            TransactionLineInput(amountMinor: -6000),
          ],
        ),
      );

      expect(edited.transaction.fxRate, '0.8');
      expect(edited.transaction.fxRateDate, _date);
      expect(edited.transaction.fxRateSource, FxRateSource.manual);
      expect(edited.transaction.baseAmountMinor, -8000);
      expect(
        edited.lines.map((line) => line.baseAmountMinor),
        [-3200, -4800],
      );
    });

    test(
      'equal rate representations are not a money change, even reconciled',
      () async {
        final account = await book.addAccount(currencyCode: 'USD');
        final created = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -10000, fxRate: '0.8'),
        );
        final id = created.transaction.id!;
        await TransactionWriter.update(
          book.session,
          id,
          entry(
            account,
            amountMinor: -10000,
            fxRate: '0.8',
            status: TransactionStatus.reconciled,
          ),
        );

        final edited = await TransactionWriter.update(
          book.session,
          id,
          entry(
            account,
            amountMinor: -10000,
            fxRate: '0.80',
            status: TransactionStatus.reconciled,
            memo: 'Equal rate',
          ),
        );

        expect(edited.transaction.fxRate, '0.8');
        expect(edited.transaction.fxRateSource, FxRateSource.manual);
        expect(edited.transaction.baseAmountMinor, -8000);
        expect(edited.transaction.memo, 'Equal rate');
      },
    );

    test(
      'a metadata-only edit survives a MAX_SAFE balance with an old negative row',
      () async {
        final account = await book.addAccount();
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: maxSafeMinor),
        );
        final negative = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -maxSafeMinor),
        );
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: maxSafeMinor),
        );
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);

        final edited = await TransactionWriter.update(
          book.session,
          negative.transaction.id!,
          entry(account, amountMinor: -maxSafeMinor, memo: 'Metadata only'),
        );

        expect(edited.transaction.memo, 'Metadata only');
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      },
    );

    test(
      'a valid money edit near the boundary applies one net delta',
      () async {
        final account = await book.addAccount();
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: maxSafeMinor),
        );
        final edited = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -1000),
        );
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: 990),
        );
        expect(await book.cachedBalanceMinor(account), maxSafeMinor - 10);

        final view = await TransactionWriter.update(
          book.session,
          edited.transaction.id!,
          entry(account, amountMinor: -990),
        );

        expect(view.transaction.amountMinor, -990);
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      },
    );

    test(
      'a net delta beyond the single-amount bound lands on a valid balance',
      () async {
        final account = await book.addAccount();
        final created = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -maxSafeMinor),
        );
        expect(await book.cachedBalanceMinor(account), -maxSafeMinor);

        final edited = await TransactionWriter.update(
          book.session,
          created.transaction.id!,
          entry(account, amountMinor: maxSafeMinor),
        );

        expect(edited.transaction.amountMinor, maxSafeMinor);
        expect(await book.cachedBalanceMinor(account), maxSafeMinor);
      },
    );

    test('a true overflow rolls back the header, lines and balance', () async {
      final account = await book.addAccount();
      await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: maxSafeMinor),
      );
      final edited = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -1000,
          lines: [
            TransactionLineInput(amountMinor: -400),
            TransactionLineInput(amountMinor: -600),
          ],
        ),
      );
      final id = edited.transaction.id!;
      events.clear();

      await expectLater(
        TransactionWriter.update(
          book.session,
          id,
          entry(
            account,
            amountMinor: maxSafeMinor,
            lines: [TransactionLineInput(amountMinor: maxSafeMinor)],
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      final row = await book.transaction(id);
      expect(row!.amountMinor, -1000);
      expect(await book.lineCount(id), 2);
      expect(await book.cachedBalanceMinor(account), maxSafeMinor - 1000);
      expect(events, isEmpty);
    });

    test(
      'a transfer leg rejects date and line changes but allows metadata',
      () async {
        final from = await book.addAccount(name: 'From');
        final to = await book.addAccount(name: 'To');
        final fromLeg = await TransactionWriter.create(
          book.session,
          entry(
            from,
            amountMinor: -400,
            lines: [TransactionLineInput(amountMinor: -400)],
          ),
        );
        final toLeg = await TransactionWriter.create(
          book.session,
          entry(to, amountMinor: 400),
        );
        await Transfer.db.insertRow(
          book.session,
          Transfer(
            fromTransactionId: fromLeg.transaction.id!,
            toTransactionId: toLeg.transaction.id!,
          ),
        );
        final fromId = fromLeg.transaction.id!;
        final toId = toLeg.transaction.id!;

        await expectLater(
          TransactionWriter.update(
            book.session,
            fromId,
            entry(from, amountMinor: -400, date: DateTime.utc(2026, 3, 11)),
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          TransactionWriter.update(
            book.session,
            fromId,
            entry(
              from,
              amountMinor: -400,
              lines: [
                TransactionLineInput(amountMinor: -200),
                TransactionLineInput(amountMinor: -200),
              ],
            ),
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          TransactionWriter.update(
            book.session,
            toId,
            entry(to, amountMinor: 400, date: DateTime.utc(2026, 3, 11)),
          ),
          throwsA(isA<ValidationException>()),
        );

        final metadata = await TransactionWriter.update(
          book.session,
          fromId,
          entry(from, amountMinor: -400, memo: 'metadata ok'),
        );

        expect(metadata.transaction.memo, 'metadata ok');
        expect(metadata.transaction.amountMinor, -400);
        expect(metadata.transaction.baseAmountMinor, -400);
        expect(metadata.transaction.fxRate, '1');

        final fromRow = await book.transaction(fromId);
        final toRow = await book.transaction(toId);
        expect(fromRow!.amountMinor, -400);
        expect(fromRow.baseAmountMinor, -400);
        expect(toRow!.amountMinor, 400);
        expect(toRow.baseAmountMinor, 400);
        expect(await book.cachedBalanceMinor(from), -400);
        expect(await book.cachedBalanceMinor(to), 400);
      },
    );

    test('a date-changing edit notifies both the old and new month', () async {
      final account = await book.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -250, date: DateTime.utc(2026, 3, 10)),
      );
      events.clear();

      final edited = await TransactionWriter.update(
        book.session,
        created.transaction.id!,
        entry(account, amountMinor: -250, date: DateTime.utc(2026, 4, 2)),
      );

      expect(edited.transaction.date, DateTime.utc(2026, 4, 2));
      expect(events, hasLength(2));
      expect(events.map((event) => event.month), containsAll([202603, 202604]));
      expect(events.every((event) => event.accountId == account.id), isTrue);
      expect(events.every((event) => event.entityId == book.entity.id), isTrue);
      expect(
        events.every((event) => event.scope == ChangeScope.transactions),
        isTrue,
      );
    });

    test('a rolled-back date-changing edit emits nothing', () async {
      final account = await book.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -250, date: DateTime.utc(2026, 3, 10)),
      );
      events.clear();

      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.update(
            book.session,
            created.transaction.id!,
            entry(account, amountMinor: -250, date: DateTime.utc(2026, 4, 2)),
            transaction: tx,
          );
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );

      expect(events, isEmpty);
      final row = await book.transaction(created.transaction.id!);
      expect(row!.date, DateTime.utc(2026, 3, 10));
    });
  });

  group('updateLines', () {
    test(
      'replaces the split with the same validation and no balance move',
      () async {
        final account = await book.addAccount();
        final envelope = await book.addEnvelope();
        final created = await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: -1000),
        );

        final view = await TransactionWriter.updateLines(
          book.session,
          created.transaction.id!,
          [
            TransactionLineInput(amountMinor: -400, envelopeId: envelope.id),
            TransactionLineInput(amountMinor: -600),
          ],
        );

        expect(view.lines, hasLength(2));
        expect(view.lines.first.envelopeId, envelope.id);
        expect(await book.cachedBalanceMinor(account), -1000);

        await expectLater(
          TransactionWriter.updateLines(
            book.session,
            created.transaction.id!,
            [
              TransactionLineInput(amountMinor: -400),
              TransactionLineInput(amountMinor: -599),
            ],
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(
          await book.lineCount(created.transaction.id!),
          2,
          reason: 'a rejected replacement keeps the previous lines',
        );
      },
    );
  });

  group('delete', () {
    test('reverses the balance and cascades lines', () async {
      final account = await book.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(
          account,
          amountMinor: -700,
          lines: [
            TransactionLineInput(amountMinor: -300),
            TransactionLineInput(amountMinor: -400),
          ],
        ),
      );
      final id = created.transaction.id!;

      await TransactionWriter.delete(book.session, id);

      expect(await book.cachedBalanceMinor(account), 0);
      expect(await book.recomputedBalanceMinor(account), 0);
      expect(await book.transaction(id), isNull);
      expect(await book.lineCount(id), 0);
    });

    test(
      'deleting a seeded transfer leg removes both legs and the link',
      () async {
        final from = await book.addAccount(name: 'From');
        final to = await book.addAccount(name: 'To');
        final fromLeg = await TransactionWriter.create(
          book.session,
          entry(from, amountMinor: -400),
        );
        final toLeg = await TransactionWriter.create(
          book.session,
          entry(to, amountMinor: 400),
        );
        final transfer = await Transfer.db.insertRow(
          book.session,
          Transfer(
            fromTransactionId: fromLeg.transaction.id!,
            toTransactionId: toLeg.transaction.id!,
          ),
        );

        await TransactionWriter.delete(
          book.session,
          fromLeg.transaction.id!,
        );

        expect(await book.cachedBalanceMinor(from), 0);
        expect(await book.cachedBalanceMinor(to), 0);
        expect(await book.transaction(fromLeg.transaction.id!), isNull);
        expect(await book.transaction(toLeg.transaction.id!), isNull);
        expect(await Transfer.db.findById(book.session, transfer.id!), isNull);
        expect(events, hasLength(4));
      },
    );

    test('a reconciled second leg rejects deleting the pair', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final fromLeg = await TransactionWriter.create(
        book.session,
        entry(from, amountMinor: -400),
      );
      final toLeg = await TransactionWriter.create(
        book.session,
        entry(to, amountMinor: 400),
      );
      await Transfer.db.insertRow(
        book.session,
        Transfer(
          fromTransactionId: fromLeg.transaction.id!,
          toTransactionId: toLeg.transaction.id!,
        ),
      );
      await TransactionWriter.update(
        book.session,
        toLeg.transaction.id!,
        entry(to, amountMinor: 400, status: TransactionStatus.reconciled),
      );

      await expectLater(
        TransactionWriter.delete(
          book.session,
          fromLeg.transaction.id!,
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await book.cachedBalanceMinor(from), -400);
      expect(await book.cachedBalanceMinor(to), 400);
    });

    test('a reconciled row must unlock before deletion', () async {
      final account = await book.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -100),
      );
      final id = created.transaction.id!;
      await TransactionWriter.update(
        book.session,
        id,
        entry(
          account,
          amountMinor: -100,
          status: TransactionStatus.reconciled,
        ),
      );

      await expectLater(
        TransactionWriter.delete(book.session, id),
        throwsA(isA<ValidationException>()),
      );
      expect(await book.cachedBalanceMinor(account), -100);
    });
  });

  group('atomicity and concurrency', () {
    test('an overflow rolls back the header, lines and balance', () async {
      final account = await book.addAccount();
      await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: maxSafeMinor - 10),
      );
      events.clear();

      await expectLater(
        TransactionWriter.create(
          book.session,
          entry(account, amountMinor: 100),
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(await transactions(account), hasLength(1));
      expect(await book.cachedBalanceMinor(account), maxSafeMinor - 10);
      expect(events, isEmpty);
    });

    test('a caller transaction only emits after its own commit', () async {
      final account = await book.addAccount();

      await TransactionWriter.inTransaction(book.session, (tx) async {
        await TransactionWriter.create(
          book.session,
          entry(account, amountMinor: 250),
          transaction: tx,
        );
        expect(events, isEmpty);
      });

      expect(events, hasLength(1));
      expect(await book.cachedBalanceMinor(account), 250);
      expect(await book.recomputedBalanceMinor(account), 250);
    });

    test('a rolled-back caller transaction writes and emits nothing', () async {
      final account = await book.addAccount();

      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 250),
            transaction: tx,
          );
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );

      expect(await transactions(account), isEmpty);
      expect(await book.cachedBalanceMinor(account), 0);
      expect(events, isEmpty);
    });

    test('joining an unmanaged transaction is rejected', () async {
      final account = await book.addAccount();

      await expectLater(
        book.session.db.transaction((tx) async {
          await TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 100),
            transaction: tx,
          );
        }),
        throwsA(isA<StateError>()),
      );
      expect(await transactions(account), isEmpty);
    });

    test('twenty parallel creates leave the exact balance', () async {
      final account = await book.addAccount();

      await Future.wait([
        for (var index = 0; index < 20; index++)
          TransactionWriter.create(
            book.session,
            entry(account, amountMinor: 137, description: 'Row $index'),
          ),
      ]);

      expect(await transactions(account), hasLength(20));
      expect(await book.cachedBalanceMinor(account), 2740);
      expect(await book.recomputedBalanceMinor(account), 2740);
      expect(events, hasLength(20));
    });
  });

  group('read and ownership', () {
    test('get returns the view and rejects another user', () async {
      final account = await book.addAccount();
      final created = await TransactionWriter.create(
        book.session,
        entry(account, amountMinor: -100),
      );

      final view = await TransactionWriter.get(
        book.session,
        created.transaction.id!,
      );
      expect(view.transaction.id, created.transaction.id);

      final otherBook = await BudgetTestBook.create(server.anonymousSession());
      await expectLater(
        TransactionWriter.get(
          otherBook.session,
          created.transaction.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });
}
