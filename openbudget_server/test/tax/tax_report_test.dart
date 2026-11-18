import 'dart:async';
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
import '../support/tax_fake_pack.dart';
import '../support/tax_test_book.dart';

TaxReportLineView? _lineWith(TaxReportView report, String code) {
  for (final line in report.lines) {
    if (line.code == code) return line;
  }
  return null;
}

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
    TaxService.clock = () => DateTime.utc(2026, 11, 11);
    await server.clearRates();
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

  Future<TransactionView> addLine(
    Account account, {
    int amountMinor = -10000,
    DateTime? date,
    String? code = 'gb.ind.employment',
    String? fxRate,
    int? salesTaxMinor,
    int? businessUsePercent,
    UuidValue? envelopeId,
  }) => createTaxTransaction(
    book.session,
    account,
    amountMinor: amountMinor,
    date: date,
    fxRate: fxRate,
    lines: [
      TransactionLineInput(
        amountMinor: amountMinor,
        envelopeId: envelopeId,
        taxCategoryCode: code,
        businessUsePercent: businessUsePercent,
        salesTaxMinor: salesTaxMinor,
      ),
    ],
  );

  group('when reporting a UK individual', () {
    test('then liability, bands and a refund keep the core contract', () async {
      final account = await book.addAccount();
      await addLine(
        account,
        amountMinor: 5_000_000,
        date: DateTime.utc(2026, 6, 10),
      );
      await addLine(
        account,
        amountMinor: 1_000_000,
        date: DateTime.utc(2026, 7, 10),
        code: 'gb.ind.tax_paid',
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      expect(report.jurisdiction, 'GB');
      expect(report.yearLabel, '2026/27');
      expect(report.entityKind, EntityKind.individual);
      expect(report.currencyCode, 'GBP');
      expect(report.uncategorizedCount, 0);
      expect(report.convertedEntryCount, 0);
      expect(report.totalLiabilityMinor, 748600);
      expect(report.alreadyPaidMinor, 1_000_000);
      expect(report.balanceDueMinor, -251400);

      final employment = _lineWith(report, 'gb.ind.employment');
      expect(employment?.amountMinor, 5_000_000);
      expect(employment?.entryCount, 1);

      final incomeTax = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on non-savings income',
      );
      expect(incomeTax.amountMinor, 748600);
      expect(incomeTax.bands, isNotEmpty);
      expect(
        incomeTax.bands.fold(0, (sum, band) => sum + band.taxMinor),
        incomeTax.amountMinor,
      );
      expect(report.opportunities, isNotEmpty);
      expect(report.opportunities.first.id, isNotEmpty);
      expect(report.rulesVerifiedOn, isNotNull);
      expect(report.sources, isNotEmpty);
    });

    test('then the report carries the caveats it touched and the figures '
        'its lines quote', () async {
      final account = await book.addAccount();
      await addLine(
        account,
        amountMinor: 5_000_000,
        date: DateTime.utc(2026, 6, 10),
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      // The individual return touched the personal-return caveats only:
      // every caveat is a GB one that names that section.
      expect(report.caveats, isNotEmpty);
      for (final caveat in report.caveats) {
        expect(caveat.id, startsWith('gb.'));
        expect(caveat.text, isNotEmpty);
        expect(caveat.grade, anyOf('primary', 'secondary', 'inferred'));
        expect(caveat.sections, contains('personalReturn'));
        expect(caveat.recheckBy, isNotNull);
      }
      // The personal-allowance line quotes its named figure, which arrives
      // with its grade for the secondary-source badge.
      final allowanceLine = report.lines.firstWhere(
        (line) => line.figureId == 'personalAllowance',
      );
      expect(allowanceLine.amountMinor, 1_257_000);
      final allowance = report.figures.firstWhere(
        (figure) => figure.id == 'personalAllowance',
      );
      expect(allowance.grade, 'primary');
      expect(allowance.unit, 'currencyMinor');
      expect(allowance.source, isNotEmpty);
      expect(allowance.verifiedOn, report.rulesVerifiedOn);
      // No caveat about the payroll section, which the report never used.
      expect(
        report.caveats.any((caveat) => caveat.sections.contains('payroll')),
        isFalse,
      );
    });

    test('then the year window follows the jurisdiction boundary', () async {
      final account = await book.addAccount();
      for (final date in [
        DateTime.utc(2025, 4, 5),
        DateTime.utc(2025, 4, 6),
        DateTime.utc(2026, 4, 5),
        DateTime.utc(2026, 4, 6),
      ]) {
        await addLine(account, amountMinor: 10000, date: date);
      }

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2025,
      );

      final employment = _lineWith(report, 'gb.ind.employment');
      expect(employment?.amountMinor, 20000);
      expect(employment?.entryCount, 2);
      expect(report.uncategorizedCount, 0);
    });

    test('then a US entity uses its calendar year instead', () async {
      final us = await book.addEntity(
        name: 'US family',
        countryCode: 'US',
        baseCurrencyCode: 'USD',
      );
      await saveTaxProfile(
        book.session,
        us,
        profileJson: jsonEncode(
          const UsTaxProfile(
            entityKind: EntityKind.individual,
          ).toJson(),
        ),
      );
      final account = await book.addAccount(
        name: 'US checking',
        currencyCode: 'USD',
        entity: us,
      );
      await createTaxTransaction(
        book.session,
        account,
        amountMinor: 100000,
        date: DateTime.utc(2026, 1, 15),
        lines: [
          TransactionLineInput(
            amountMinor: 100000,
            taxCategoryCode: 'us.ind.wages',
          ),
        ],
      );

      final report = await endpoint.getReport(
        book.session,
        us.id!,
        startYear: 2026,
      );

      expect(report.jurisdiction, 'US');
      expect(report.yearLabel, '2026');
      expect(report.startYear, 2026);
      expect(_lineWith(report, 'us.ind.wages')?.amountMinor, 100000);
    });
  });

  group('when distinguishing transfers and line overrides', () {
    test('then transfer legs never enter tax', () async {
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
      for (final leg in legs) {
        final line = taxLine(leg);
        await TransactionLine.db.updateRow(
          book.session,
          line.copyWith(taxCategoryCode: 'gb.ind.employment'),
        );
      }

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      expect(_lineWith(report, 'gb.ind.employment'), isNull);
      expect(report.uncategorizedCount, 0);
    });

    test('then the line category overrides its envelope default', () async {
      final account = await book.addAccount();
      final envelope = await book.addEnvelope(name: 'Salary');
      await endpoint.setEnvelopeTaxCategory(
        book.session,
        envelope.id!,
        code: 'gb.ind.employment',
      );

      await addLine(
        account,
        amountMinor: 7000,
        code: 'gb.ind.self_employment',
        envelopeId: envelope.id,
      );
      await addLine(
        account,
        amountMinor: 3000,
        code: null,
        envelopeId: envelope.id,
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      expect(_lineWith(report, 'gb.ind.employment')?.amountMinor, 3000);
      expect(_lineWith(report, 'gb.ind.self_employment')?.amountMinor, 7000);
      expect(report.uncategorizedCount, 0);
    });

    test(
      'then clearing the envelope default makes the line uncategorised',
      () async {
        final account = await book.addAccount();
        final envelope = await book.addEnvelope(name: 'Salary');
        await endpoint.setEnvelopeTaxCategory(
          book.session,
          envelope.id!,
          code: 'gb.ind.employment',
        );
        await addLine(
          account,
          amountMinor: 3000,
          code: null,
          envelopeId: envelope.id,
        );

        await endpoint.setEnvelopeTaxCategory(book.session, envelope.id!);

        final report = await endpoint.getReport(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(_lineWith(report, 'gb.ind.employment'), isNull);
        expect(report.uncategorizedCount, 1);
      },
    );
  });

  group('when converting several currencies', () {
    test('then each line converts once with ISO exponents', () async {
      final day = DateTime.utc(2026, 6, 14);
      await book.seedRate(currencyCode: 'USD', rateDate: day, rate: '1');
      await book.seedRate(currencyCode: 'GBP', rateDate: day, rate: '0.8');
      await book.seedRate(currencyCode: 'JPY', rateDate: day, rate: '150');
      await book.seedRate(currencyCode: 'KWD', rateDate: day, rate: '0.307');

      final date = DateTime.utc(2026, 6, 15);
      final gbp = await book.addAccount(name: 'GBP');
      final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
      final jpy = await book.addAccount(name: 'JPY', currencyCode: 'JPY');
      final kwd = await book.addAccount(name: 'KWD', currencyCode: 'KWD');

      await addLine(gbp, amountMinor: 10000, date: date);
      await addLine(
        usd,
        amountMinor: 12500,
        date: date,
        fxRate: '0.8',
      );
      await addLine(
        jpy,
        amountMinor: 15000,
        date: date,
        fxRate: '0.005333333333',
      );
      await addLine(
        kwd,
        amountMinor: 10000,
        date: date,
        fxRate: '2.6',
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      // 10000 GBP + 12500 USD at 0.8 + 15000 JPY at 150/USD + 10.000 KWD at
      // 0.307/USD, each converted once into GBP.
      expect(_lineWith(report, 'gb.ind.employment')?.amountMinor, 30606);
      expect(report.convertedEntryCount, 3);
      expect(
        report.assumptions,
        contains(
          'Amounts in other currencies were converted at the exchange rate '
          'on each transaction date.',
        ),
      );
    });

    test(
      'then a six-day-old row is used and an eight-day-old one is not',
      () async {
        final date = DateTime.utc(2026, 6, 15);
        await book.seedRate(
          currencyCode: 'USD',
          rateDate: DateTime.utc(2026, 6, 9),
          rate: '1',
        );
        await book.seedRate(
          currencyCode: 'GBP',
          rateDate: DateTime.utc(2026, 6, 9),
          rate: '0.8',
        );
        await book.seedRate(
          currencyCode: 'GBP',
          rateDate: DateTime.utc(2026, 6, 7),
          rate: '0.5',
        );
        final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
        await addLine(
          usd,
          amountMinor: 12500,
          date: date,
          fxRate: '0.8',
        );

        final report = await endpoint.getReport(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(_lineWith(report, 'gb.ind.employment')?.amountMinor, 10000);
      },
    );

    test(
      'then a missing rate fails and requests one backfill per date',
      () async {
        final dates = <DateTime>[];
        FxService.configure(
          apiKey: null,
          baseUrl: null,
          backfillScheduler: (_, date) async {
            dates.add(date);
          },
        );
        final date = DateTime.utc(2026, 6, 15);
        final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
        await addLine(usd, amountMinor: 12500, date: date, fxRate: '0.8');
        await addLine(usd, amountMinor: 6250, date: date, fxRate: '0.8');

        await expectLater(
          endpoint.getReport(book.session, book.entity.id!, startYear: 2026),
          throwsA(
            isA<FxRateUnavailableException>()
                .having((error) => error.fromCurrencyCode, 'from', 'USD')
                .having((error) => error.toCurrencyCode, 'to', 'GBP')
                .having((error) => error.date, 'date', date),
          ),
        );
        expect(dates, [date]);
      },
    );

    test('then a future-only rate is never used', () async {
      final date = DateTime.utc(2026, 6, 15);
      await book.seedRate(
        currencyCode: 'USD',
        rateDate: DateTime.utc(2026, 6, 16),
        rate: '1',
      );
      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: DateTime.utc(2026, 6, 16),
        rate: '0.8',
      );
      final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
      await addLine(usd, amountMinor: 12500, date: date, fxRate: '0.8');

      await expectLater(
        endpoint.getReport(book.session, book.entity.id!, startYear: 2026),
        throwsA(isA<FxRateUnavailableException>()),
      );
    });

    test('then one missing side never becomes a 1:1 conversion', () async {
      final date = DateTime.utc(2026, 6, 15);
      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: DateTime.utc(2026, 6, 14),
        rate: '0.8',
      );
      final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');
      await addLine(usd, amountMinor: 12500, date: date, fxRate: '0.8');

      await expectLater(
        endpoint.getReport(book.session, book.entity.id!, startYear: 2026),
        throwsA(isA<FxRateUnavailableException>()),
      );
    });
  });

  group('when books link to other entities', () {
    test(
      'then an individual report includes owned sole traders once',
      () async {
        TaxService.packFor = (_) => FakeTaxPack();
        final personal = book.entity;
        final business = await book.addEntity(
          name: 'Business',
          kind: EntityKind.soleTrader,
          linkedPersonalEntityId: personal.id,
        );
        await saveTaxProfile(book.session, business);

        final personalAccount = await book.addAccount(name: 'Personal');
        final businessAccount = await book.addAccount(
          name: 'Business',
          entity: business,
        );
        await addLine(personalAccount, amountMinor: 10000);
        await createTaxTransaction(
          book.session,
          businessAccount,
          amountMinor: 20000,
          date: DateTime.utc(2026, 6, 15),
          lines: [
            TransactionLineInput(
              amountMinor: 20000,
              taxCategoryCode: 'gb.se.turnover',
            ),
          ],
        );

        final report = await endpoint.getReport(
          book.session,
          personal.id!,
          startYear: 2026,
        );

        expect(
          report.lines
              .firstWhere((line) => line.label == 'Entries')
              .amountMinor,
          1,
        );
        expect(
          report.lines
              .firstWhere((line) => line.label == 'Linked books')
              .amountMinor,
          1,
        );
        expect(
          report.lines
              .firstWhere((line) => line.label == 'Linked entries')
              .amountMinor,
          1,
        );
      },
    );

    test(
      'then another owner cannot feed the report through a forged link',
      () async {
        TaxService.packFor = (_) => FakeTaxPack();
        final other = await BudgetTestBook.create(server.anonymousSession());
        final forged = await other.addEntity(
          name: 'Forged business',
          kind: EntityKind.soleTrader,
          linkedPersonalEntityId: book.entity.id,
        );
        final otherAccount = await other.addAccount(
          name: 'Forged account',
          entity: forged,
        );
        await createTaxTransaction(
          other.session,
          otherAccount,
          amountMinor: 20000,
          date: DateTime.utc(2026, 6, 15),
          lines: [
            TransactionLineInput(
              amountMinor: 20000,
              taxCategoryCode: 'gb.se.turnover',
            ),
          ],
        );

        final report = await endpoint.getReport(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(
          report.lines
              .firstWhere((line) => line.label == 'Linked books')
              .amountMinor,
          0,
        );
        expect(
          report.lines
              .firstWhere((line) => line.label == 'Linked entries')
              .amountMinor,
          0,
        );
      },
    );

    test(
      'then a linked sole trader without a profile is not counted',
      () async {
        TaxService.packFor = (_) => FakeTaxPack();
        final business = await book.addEntity(
          name: 'Unprofiled business',
          kind: EntityKind.soleTrader,
          linkedPersonalEntityId: book.entity.id,
        );
        final businessAccount = await book.addAccount(
          name: 'Business',
          entity: business,
        );
        await createTaxTransaction(
          book.session,
          businessAccount,
          amountMinor: 20000,
          date: DateTime.utc(2026, 6, 15),
          lines: [
            TransactionLineInput(
              amountMinor: 20000,
              taxCategoryCode: 'gb.se.turnover',
            ),
          ],
        );

        final report = await endpoint.getReport(
          book.session,
          book.entity.id!,
          startYear: 2026,
        );

        expect(
          report.lines
              .firstWhere((line) => line.label == 'Linked books')
              .amountMinor,
          0,
        );
      },
    );

    test("then a company links only its director's personal books", () async {
      TaxService.packFor = (_) => FakeTaxPack();
      final personal = book.entity;
      final company = await book.addEntity(
        name: 'Company',
        kind: EntityKind.company,
        linkedPersonalEntityId: personal.id,
      );
      await saveTaxProfile(
        book.session,
        company,
        profileJson: gbProfileJson(EntityKind.company),
      );
      final personalAccount = await book.addAccount(name: 'Personal');
      await addLine(personalAccount, amountMinor: 10000);

      final report = await endpoint.getReport(
        book.session,
        company.id!,
        startYear: 2026,
      );

      expect(
        report.lines.firstWhere((line) => line.label == 'Entries').amountMinor,
        0,
      );
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Linked books')
            .amountMinor,
        1,
      );
      expect(
        report.lines
            .firstWhere((line) => line.label == 'Linked entries')
            .amountMinor,
        1,
      );
    });

    test("then a company cannot link another owner's personal books", () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      final company = await book.addEntity(
        name: 'Company',
        kind: EntityKind.company,
      );
      await saveTaxProfile(
        book.session,
        company,
        profileJson: gbProfileJson(EntityKind.company),
      );
      await book.session.db.unsafeExecute(
        'UPDATE "entity" SET "linkedPersonalEntityId" = @linked::uuid '
        'WHERE id = @id::uuid',
        parameters: QueryParameters.named({
          'linked': other.entity.id!.toString(),
          'id': company.id!.toString(),
        }),
      );

      await expectLater(
        endpoint.getReport(book.session, company.id!, startYear: 2026),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('when the default year is resolved', () {
    test("then the entity's local date picks the tax year", () async {
      final localBook = await BudgetTestBook.create(
        server.anonymousSession(),
        timeZone: 'America/Los_Angeles',
      );
      await saveTaxProfile(localBook.session, localBook.entity);
      TaxService.clock = () => DateTime.utc(2027, 4, 6, 2);

      final report = await endpoint.getReport(
        localBook.session,
        localBook.entity.id!,
      );

      expect(report.startYear, 2026);
      expect(report.yearLabel, '2026/27');
    });
  });

  group('when a report reads while a write is open', () {
    test('then every query sees one committed snapshot', () async {
      final account = await book.addAccount();
      final view = await createTaxTransaction(
        book.session,
        account,
        amountMinor: 10000,
        lines: [
          TransactionLineInput(
            amountMinor: 10000,
            taxCategoryCode: 'gb.ind.employment',
          ),
        ],
      );
      final transactionId = view.transaction.id!;
      final reportSession = server.authenticatedSession(book.userId);
      final started = Completer<void>();
      final release = Completer<void>();

      final write = TransactionWriter.inTransaction(book.session, (tx) async {
        final lines = await TransactionLine.db.find(
          book.session,
          where: (t) => t.transactionId.equals(transactionId),
          transaction: tx,
        );
        await TransactionWriter.updateLines(
          book.session,
          transactionId,
          [
            for (final line in lines)
              TransactionLineInput(
                amountMinor: line.amountMinor,
                envelopeId: line.envelopeId,
                ledgerAccountId: line.ledgerAccountId,
                taxCategoryCode: 'gb.ind.self_employment',
                businessUsePercent: line.businessUsePercent,
                salesTaxMinor: line.salesTaxMinor,
                memo: line.memo,
              ),
          ],
          transaction: tx,
        );
        started.complete();
        await release.future;
      });

      await started.future;
      final during = await endpoint.getReport(
        reportSession,
        book.entity.id!,
        startYear: 2026,
      );
      release.complete();
      await write;
      final after = await endpoint.getReport(
        reportSession,
        book.entity.id!,
        startYear: 2026,
      );

      expect(_lineWith(during, 'gb.ind.employment')?.amountMinor, 10000);
      expect(_lineWith(during, 'gb.ind.self_employment'), isNull);
      expect(_lineWith(after, 'gb.ind.employment'), isNull);
      expect(_lineWith(after, 'gb.ind.self_employment')?.amountMinor, 10000);
    });
  });
}
