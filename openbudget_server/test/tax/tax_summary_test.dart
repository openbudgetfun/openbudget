import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
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
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxSummaryService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.utc(2026, 11, 11);
    TaxSummaryService.clock = () => DateTime.utc(2026, 11, 11);
    await server.clearRates();
    book = await BudgetTestBook.create(server.anonymousSession());
    endpoint = TaxEndpoint();
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxSummaryService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    TaxSummaryService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  group('when a Kenyan individual has no rule pack', () {
    late Entity kenya;

    setUp(() async {
      kenya = await EntityService.create(
        book.session,
        'Nairobi books',
        EntityKind.individual,
        'KE',
        'KES',
        'Africa/Nairobi',
      );
    });

    test(
      'then the header describes the universal tax year and rules',
      () async {
        final summary = await endpoint.getSummary(book.session, kenya.id!);

        expect(summary.entityId, kenya.id);
        expect(summary.entityKind, EntityKind.individual);
        expect(summary.countryCode, 'KE');
        expect(summary.currencyCode, 'KES');
        expect(summary.isUniversal, isTrue);
        // The frozen clock places today in the 2026 calendar tax year.
        expect(summary.startYear, 2026);
        expect(summary.yearLabel, '2026');
        expect(summary.yearStart, civilDate(2026, 1, 1));
        expect(summary.yearEnd, civilDate(2027, 1, 1));
        expect(summary.rulesVersion, isNull);
        expect(summary.rulesVerifiedOn, Countries.byCode('KE')!.verifiedOn);
        expect(summary.disclaimerKey, TaxSummaryService.disclaimerKey);
        expect(summary.generatedAt, DateTime.utc(2026, 11, 11));
      },
    );

    test(
      'then totals group by category and leave out-of-scope lines out',
      () async {
        final account = await book.addAccount(entity: kenya);
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: 250000,
          date: DateTime.utc(2026, 3, 15),
          lines: [
            TransactionLineInput(
              amountMinor: 250000,
              taxCategoryCode: 'universal.income.employment',
            ),
          ],
        );
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: 50500,
          date: civilDate(2026, 7, 1),
          lines: [
            TransactionLineInput(
              amountMinor: 50500,
              taxCategoryCode: 'universal.income.interest',
            ),
          ],
        );
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: -30000,
          date: DateTime.utc(2026, 4, 2),
          lines: [
            TransactionLineInput(
              amountMinor: -30000,
              taxCategoryCode: 'universal.relief.pension',
            ),
          ],
        );
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: -40000,
          date: DateTime.utc(2026, 4, 2),
          lines: [
            TransactionLineInput(
              amountMinor: -40000,
              taxCategoryCode: 'universal.tax.income_tax_withheld',
            ),
          ],
        );
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: 10000,
          date: DateTime.utc(2026, 5, 5),
          lines: [
            TransactionLineInput(
              amountMinor: 10000,
              taxCategoryCode: 'universal.out_of_scope.gifts_received',
            ),
          ],
        );
        // One line with no category and no envelope default.
        await createTaxTransaction(
          book.session,
          account,
          amountMinor: 9999,
          date: DateTime.utc(2026, 5, 6),
          lines: [TransactionLineInput(amountMinor: 9999)],
        );

        final summary = await endpoint.getSummary(
          book.session,
          kenya.id!,
          startYear: 2026,
        );

        expect(summary.totalIncomeMinor, 300500);
        expect(summary.incomeTotals, hasLength(2));
        expect(
          summary.incomeTotals[0].categoryCode,
          'universal.income.employment',
        );
        expect(summary.incomeTotals[0].totalMinor, 250000);
        expect(summary.incomeTotals[0].entryCount, 1);
        expect(
          summary.incomeTotals[1].categoryCode,
          'universal.income.interest',
        );
        expect(summary.incomeTotals[1].totalMinor, 50500);
        expect(summary.totalReliefMinor, 30000);
        expect(
          summary.reliefTotals.single.categoryCode,
          'universal.relief.pension',
        );
        expect(summary.totalTaxPaidMinor, 40000);
        expect(
          summary.taxPaidTotals.single.categoryCode,
          'universal.tax.income_tax_withheld',
        );
        expect(summary.totalExpenseMinor, 0);
        expect(summary.expenseTotals, isEmpty);
        expect(summary.uncategorizedCount, 1);
        expect(summary.salesTaxCollectedMinor, 0);
        expect(summary.salesTaxPaidMinor, 0);
        expect(summary.salesTaxByRate, isEmpty);
        expect(summary.salesTaxByQuarter, isEmpty);
        expect(summary.wallets, isEmpty);
        expect(summary.fxNotes, isEmpty);
        expect(summary.rateSourcesUsed, isEmpty);
      },
    );

    test('then a Kenyan company uses its own financial year', () async {
      final company = await book.addEntity(
        name: 'Nairobi company',
        countryCode: 'KE',
        baseCurrencyCode: 'KES',
        timeZone: 'Africa/Nairobi',
        kind: EntityKind.company,
        fiscalYearEndMonth: 6,
        fiscalYearEndDay: 30,
      );

      final summary = await endpoint.getSummary(
        book.session,
        company.id!,
        startYear: 2026,
      );

      expect(summary.entityKind, EntityKind.company);
      expect(summary.yearStart, civilDate(2026, 7, 1));
      expect(summary.yearEnd, civilDate(2027, 7, 1));
      expect(summary.yearLabel, '2026/27');
    });
  });

  group('when a GB sole trader has foreign-currency and VAT lines', () {
    setUp(() async {
      book = await BudgetTestBook.create(
        server.anonymousSession(),
        kind: EntityKind.soleTrader,
      );
      await saveTaxProfile(book.session, book.entity);
    });

    test(
      'then totals convert FX, apply business-use share and split VAT',
      () async {
        final gbp = await book.addAccount(name: 'GBP');
        final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
        await book.seedRate(
          currencyCode: 'USD',
          rateDate: DateTime.utc(2026, 6, 14),
          rate: '1',
        );
        await book.seedRate(
          currencyCode: 'GBP',
          rateDate: DateTime.utc(2026, 6, 14),
          rate: '0.8',
        );

        // A £1,200 sale carrying £200 output VAT: 20% over its net.
        await createTaxTransaction(
          book.session,
          gbp,
          amountMinor: 120000,
          date: DateTime.utc(2026, 6, 10),
          lines: [
            TransactionLineInput(
              amountMinor: 120000,
              taxCategoryCode: 'universal.income.self_employment',
              salesTaxMinor: 20000,
            ),
          ],
        );
        // A $1,200 software subscription carrying $200 input VAT, 60% business
        // use. Converted at 0.8 GBP per USD.
        await createTaxTransaction(
          book.session,
          usd,
          amountMinor: -120000,
          date: DateTime.utc(2026, 6, 15),
          fxRate: '0.8',
          lines: [
            TransactionLineInput(
              amountMinor: -120000,
              taxCategoryCode: 'universal.expense.software',
              businessUsePercent: 60,
              salesTaxMinor: -20000,
            ),
          ],
        );
        // A £300 travel expense with no VAT, fully business use.
        await createTaxTransaction(
          book.session,
          gbp,
          amountMinor: -30000,
          date: civilDate(2026, 8, 1),
          lines: [
            TransactionLineInput(
              amountMinor: -30000,
              taxCategoryCode: 'universal.expense.travel',
            ),
          ],
        );

        final summary = await endpoint.getSummary(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(summary.isUniversal, isFalse);
        expect(summary.currencyCode, 'GBP');
        expect(summary.yearStart, DateTime.utc(2026, 4, 6));
        expect(summary.yearEnd, DateTime.utc(2027, 4, 6));
        expect(summary.yearLabel, '2026/27');
        final ruleSet = TaxRules.forJurisdiction(TaxJurisdiction.gb).ruleSet(
          2026,
        );
        expect(summary.rulesVersion, ruleSet.versionFor(TaxJurisdiction.gb));
        expect(summary.rulesVerifiedOn, ruleSet.verifiedOn);

        // The sale is net of its output VAT; the subscription is net of its
        // input VAT, converted once at 0.8 and cut to 60% business use
        // ((100000 * 0.8) * 60% = 48000); the travel cost stays whole.
        expect(summary.totalIncomeMinor, 100000);
        expect(summary.incomeTotals.single.categoryCode, 'gb.se.turnover');
        expect(summary.totalExpenseMinor, 78000);
        final software = summary.expenseTotals.singleWhere(
          (total) => total.categoryCode == 'gb.se.phone_office',
        );
        expect(software.totalMinor, 48000);
        expect(software.entryCount, 1);
        final travel = summary.expenseTotals.singleWhere(
          (total) => total.categoryCode == 'gb.se.car_van_travel',
        );
        expect(travel.totalMinor, 30000);

        // Output VAT is due in full; input VAT is only recoverable on the
        // business share ($200 * 0.8 * 60% = 9600).
        expect(summary.salesTaxCollectedMinor, 20000);
        expect(summary.salesTaxPaidMinor, 9600);
        final rate = summary.salesTaxByRate.single;
        expect(rate.ratePerMillion, 200000);
        expect(rate.collectedMinor, 20000);
        expect(rate.paidMinor, 9600);
        final quarter = summary.salesTaxByQuarter.single;
        expect(quarter.label, 'Q1');
        expect(quarter.periodStart, DateTime.utc(2026, 4, 6));
        expect(quarter.periodEnd, DateTime.utc(2026, 7, 6));
        expect(quarter.collectedMinor, 20000);
        expect(quarter.paidMinor, 9600);

        final note = summary.fxNotes.single;
        expect(note.currencyCode, 'USD');
        expect(note.fxRate, '0.8');
        expect(note.fxRateDate, DateTime.utc(2026, 6, 14));
        expect(note.fxRateSource, FxRateSource.market);
        expect(note.isStale, isFalse);
        expect(note.lineCount, 1);
        expect(note.convertedMinor, 96000);
        expect(summary.rateSourcesUsed, ['market']);
      },
    );

    test('then a separate VAT line counts as tax at an unknown rate', () async {
      final gbp = await book.addAccount();
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 20000,
        date: DateTime.utc(2026, 6, 10),
        lines: [
          TransactionLineInput(
            amountMinor: 20000,
            taxCategoryCode: 'universal.tax.sales_tax_collected',
          ),
        ],
      );
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: -5000,
        date: DateTime.utc(2026, 6, 11),
        lines: [
          TransactionLineInput(
            amountMinor: -5000,
            taxCategoryCode: 'universal.tax.sales_tax_paid',
          ),
        ],
      );

      final summary = await endpoint.getSummary(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      expect(summary.salesTaxCollectedMinor, 20000);
      expect(summary.salesTaxPaidMinor, 5000);
      expect(summary.salesTaxByRate.single.ratePerMillion, isNull);
      expect(summary.salesTaxByRate.single.collectedMinor, 20000);
      expect(summary.salesTaxByRate.single.paidMinor, 5000);
      // The tax lines are not income or expenses.
      expect(summary.totalIncomeMinor, 0);
      expect(summary.totalExpenseMinor, 0);
    });

    test('then a 9.975% line derives its rate in millionths', () async {
      final gbp = await book.addAccount();
      // A true 9.975% rate on a £100 sale implies £9.975 of tax, which
      // the minor-unit line stores as £9.98: the derived ratio is
      // 99800 per million, close to but not exactly the true 99750.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 10998,
        date: DateTime.utc(2026, 6, 10),
        lines: [
          TransactionLineInput(
            amountMinor: 10998,
            taxCategoryCode: 'universal.income.self_employment',
            salesTaxMinor: 998,
          ),
        ],
      );
      // On a £4,000 sale the whole-unit tax £399 is the exact rate.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 439900,
        date: DateTime.utc(2026, 6, 11),
        lines: [
          TransactionLineInput(
            amountMinor: 439900,
            taxCategoryCode: 'universal.income.self_employment',
            salesTaxMinor: 39900,
          ),
        ],
      );
      // £399.01 implies 99752.5 per million; rounding half away from
      // zero at the millionth gives 99753.
      await createTaxTransaction(
        book.session,
        gbp,
        amountMinor: 439901,
        date: DateTime.utc(2026, 6, 12),
        lines: [
          TransactionLineInput(
            amountMinor: 439901,
            taxCategoryCode: 'universal.income.self_employment',
            salesTaxMinor: 39901,
          ),
        ],
      );

      final summary = await endpoint.getSummary(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      final rates = summary.salesTaxByRate;
      expect(rates, hasLength(3));
      expect(rates[0].ratePerMillion, 99750);
      expect(rates[0].collectedMinor, 39900);
      expect(rates[1].ratePerMillion, 99753);
      expect(rates[1].collectedMinor, 39901);
      expect(rates[2].ratePerMillion, 99800);
      expect(rates[2].collectedMinor, 998);
      expect(summary.salesTaxCollectedMinor, 80799);
    });

    test(
      'then out-of-period lines and uncategorised ones are counted right',
      () async {
        final gbp = await book.addAccount();
        await createTaxTransaction(
          book.session,
          gbp,
          amountMinor: 10000,
          date: civilDate(2026, 6, 1),
          lines: [TransactionLineInput(amountMinor: 10000)],
        );
        await createTaxTransaction(
          book.session,
          gbp,
          amountMinor: 45000,
          date: civilDate(2025, 6, 1),
          lines: [
            TransactionLineInput(
              amountMinor: 45000,
              taxCategoryCode: 'universal.income.other',
            ),
          ],
        );

        final summary = await endpoint.getSummary(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(summary.uncategorizedCount, 1);
        expect(summary.totalIncomeMinor, 0);
      },
    );

    test(
      'then an unsupported pack year declines with the rules exception',
      () async {
        final gbp = await book.addAccount();

        await expectLater(
          endpoint.getSummary(book.session, book.entity.id!, startYear: 2019),
          throwsA(isA<TaxRulesUnavailableException>()),
        );
        // A missing rate still fails the read and asks for a backfill.
        final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
        await createTaxTransaction(
          book.session,
          usd,
          amountMinor: -120000,
          date: DateTime.utc(2026, 6, 15),
          fxRate: '0.8',
          lines: [
            TransactionLineInput(
              amountMinor: -120000,
              taxCategoryCode: 'universal.expense.software',
            ),
          ],
        );
        await expectLater(
          endpoint.getSummary(book.session, book.entity.id!, startYear: 2026),
          throwsA(isA<FxRateUnavailableException>()),
        );
        expect(gbp, isNotNull);
      },
    );
  });

  group('when an entity owns wallets', () {
    setUp(() async {
      book = await BudgetTestBook.create(
        server.anonymousSession(),
        kind: EntityKind.soleTrader,
      );
      await saveTaxProfile(book.session, book.entity);
    });

    test(
      'then the summary shows stored FIFO estimates with their caveats',
      () async {
        final account = await book.addAccount(name: 'Crypto');
        final wallet = await Wallet.db.insertRow(
          book.session,
          Wallet(
            entityId: book.entity.id!,
            accountId: account.id!,
            network: WalletNetwork.solanaMainnet,
            address: '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin',
            label: 'Treasury',
          ),
        );
        Future<void> addRow(
          String signature,
          DateTime occurredAt, {
          int? proceeds,
          int? cost,
          int? realized,
        }) => WalletTransaction.db.insertRow(
          book.session,
          WalletTransaction(
            walletId: wallet.id!,
            network: WalletNetwork.solanaMainnet,
            signature: signature,
            slot: 1,
            occurredAt: occurredAt,
            description: 'swap',
            txType: 'SWAP',
            source: 'test',
            pnlCurrencyCode: 'USD',
            proceedsMinor: proceeds,
            costBasisMinor: cost,
            realizedPnlMinor: realized,
          ),
        );
        // Two valued disposals inside the 2026/27 tax year.
        await addRow(
          'sig1',
          DateTime.utc(2026, 6, 10, 12),
          proceeds: 50000,
          cost: 30000,
          realized: 20000,
        );
        await addRow(
          'sig2',
          DateTime.utc(2026, 7, 1, 12),
          proceeds: 10000,
          cost: 15000,
          realized: -5000,
        );
        // One unpriced transaction, and one outside the period.
        await addRow('sig3', DateTime.utc(2026, 8, 1, 12));
        await addRow(
          'sig4',
          DateTime.utc(2025, 6, 1, 12),
          proceeds: 999999,
          cost: 0,
          realized: 999999,
        );

        final summary = await endpoint.getSummary(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        final row = summary.wallets.single;
        expect(row.walletId, wallet.id);
        expect(row.label, 'Treasury');
        expect(row.currencyCode, 'USD');
        expect(row.costBasisMethod, 'fifo');
        expect(row.transactionCount, 2);
        expect(row.proceedsMinor, 60000);
        expect(row.costBasisMinor, 45000);
        expect(row.gainMinor, 15000);
        expect(row.caveats, hasLength(2));
        expect(row.caveats.first, contains('FIFO'));
        expect(row.caveats.last, contains('1 wallet transaction'));
        // Wallet figures never mix into the base-currency totals.
        expect(summary.totalIncomeMinor, 0);
        expect(summary.currencyCode, 'GBP');
      },
    );
  });

  group('ownership', () {
    test("then another user's entity is forbidden", () async {
      final mine = await BudgetTestBook.create(
        server.anonymousSession(),
        kind: EntityKind.soleTrader,
      );
      await saveTaxProfile(mine.session, mine.entity);
      final other = await BudgetTestBook.create(server.anonymousSession());

      await expectLater(
        endpoint.getSummary(mine.session, other.entity.id!, startYear: 2026),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('then an unknown entity is not found', () async {
      await expectLater(
        endpoint.getSummary(book.session, const Uuid().v7obj()),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('then an anonymous session is rejected', () async {
      await expectLater(
        endpoint.getSummary(server.anonymousSession(), book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });
  });
}
