import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../../support/tax_fake_pack.dart';
import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

int _lineAmount(TaxReportView report, String label) =>
    report.lines.firstWhere((line) => line.label == label).amountMinor;

void main() {
  withServerpod('Given TaxEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;

    setUp(() {
      authedSession = createAuthenticatedSession(sessionBuilder);
      TaxService.packFor = (_) => FakeTaxPack();
    });

    tearDown(() {
      TaxService.packFor = TaxRules.forJurisdiction;
    });

    Future<Budget> createBudget(
      TestSessionBuilder session,
      String name,
    ) => endpoints.budget.create(session, name, 'GBP');

    String profileJson(TaxEntityKind kind) =>
        jsonEncode(GbTaxProfile(entityKind: kind).toJson());

    Future<TaxProfileRecord> saveProfile(
      TestSessionBuilder session,
      Budget budget,
      TaxEntityKind kind, {
      UuidValue? linkedBudgetId,
    }) => endpoints.tax.saveProfile(
      session,
      budget.id!,
      'GB',
      kind.name,
      profileJson(kind),
      linkedBudgetId: linkedBudgetId,
    );

    group('when authenticating', () {
      test('then an unauthenticated caller is rejected', () async {
        final budget = await createBudget(authedSession, 'Personal');
        final anonymous = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );

        await expectLater(
          endpoints.tax.getProfile(anonymous, budget.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('then another user cannot read or write the profile', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final other = createAuthenticatedSession(sessionBuilder);

        await expectLater(
          endpoints.tax.getProfile(other, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.tax.saveProfile(
            other,
            budget.id!,
            'GB',
            TaxEntityKind.individual.name,
            profileJson(TaxEntityKind.individual),
          ),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.tax.listCategories(other, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.tax.getReport(other, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when saving a profile', () {
      test('then the profile round-trips through getProfile', () async {
        final budget = await createBudget(authedSession, 'Personal');

        final saved = await saveProfile(
          authedSession,
          budget,
          TaxEntityKind.individual,
        );
        final loaded = await endpoints.tax.getProfile(
          authedSession,
          budget.id!,
        );

        expect(saved.jurisdiction, 'GB');
        expect(saved.entityKind, 'individual');
        expect(loaded?.id, saved.id);
        expect(loaded?.profileJson, saved.profileJson);
      });

      test('then a US profile keeps its new fields', () async {
        final budget = await endpoints.budget.create(
          authedSession,
          'Family',
          'USD',
        );
        const profile = UsTaxProfile(
          entityKind: TaxEntityKind.individual,
          filingStatus: UsFilingStatus.qualifyingSurvivingSpouse,
          homeOfficeMethod: UsHomeOfficeMethod.regular,
          specifiedServiceTrade: true,
          foreignEarnedIncomeExclusionMinor: 500000,
          taxpayer65OrOlder: true,
          spouse65OrOlder: true,
          dependents: [
            UsDependent(underSeventeen: true, hasValidSsn: true),
            UsDependent(underSeventeen: false, hasValidSsn: false),
          ],
        );

        final saved = await endpoints.tax.saveProfile(
          authedSession,
          budget.id!,
          'US',
          TaxEntityKind.individual.name,
          jsonEncode(profile.toJson()),
        );

        expect(saved.jurisdiction, 'US');
        final roundTripped = TaxProfile.fromJson(
          jsonDecode(saved.profileJson) as Map<String, Object?>,
        ) as UsTaxProfile;
        expect(
          roundTripped.filingStatus,
          UsFilingStatus.qualifyingSurvivingSpouse,
        );
        expect(roundTripped.homeOfficeMethod, UsHomeOfficeMethod.regular);
        expect(roundTripped.specifiedServiceTrade, isTrue);
        expect(roundTripped.foreignEarnedIncomeExclusionMinor, 500000);
        expect(roundTripped.taxpayer65OrOlder, isTrue);
        expect(roundTripped.spouse65OrOlder, isTrue);
        expect(roundTripped.dependents, hasLength(2));
        expect(roundTripped.dependents.first.hasValidSsn, isTrue);
        expect(roundTripped.dependents.last.hasValidSsn, isFalse);
      });

      test('then an unknown US filing status rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');

        await expectLater(
          endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'US',
            TaxEntityKind.individual.name,
            jsonEncode({
              'jurisdiction': 'US',
              'entityKind': 'individual',
              'salesTaxRegistered': false,
              'filingStatus': 'headOfFamily',
            }),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with an unknown jurisdiction then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');

        await expectLater(
          endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'ZZ',
            TaxEntityKind.individual.name,
            profileJson(TaxEntityKind.individual),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with an unknown entity kind then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');

        await expectLater(
          endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'GB',
            'partnership',
            profileJson(TaxEntityKind.individual),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with malformed JSON then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');

        await expectLater(
          endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'GB',
            TaxEntityKind.individual.name,
            '{not-json',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with a profile of another entity kind then rejects', () async {
        final budget = await createBudget(authedSession, 'Business');

        await expectLater(
          endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'GB',
            TaxEntityKind.soleTrader.name,
            profileJson(TaxEntityKind.individual),
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('when an individual links another budget then rejects', () async {
        final personal = await createBudget(authedSession, 'Personal');
        final other = await createBudget(authedSession, 'Other');

        await expectLater(
          saveProfile(
            authedSession,
            personal,
            TaxEntityKind.individual,
            linkedBudgetId: other.id,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('when a sole trader links itself then rejects', () async {
        final business = await createBudget(authedSession, 'Business');

        await expectLater(
          saveProfile(
            authedSession,
            business,
            TaxEntityKind.soleTrader,
            linkedBudgetId: business.id,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('when a sole trader links a company then rejects', () async {
        final business = await createBudget(authedSession, 'Business');
        final company = await createBudget(authedSession, 'Company');
        await saveProfile(
          authedSession,
          company,
          TaxEntityKind.company,
        );

        await expectLater(
          saveProfile(
            authedSession,
            business,
            TaxEntityKind.soleTrader,
            linkedBudgetId: company.id,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test(
        'when a sole trader links a personal budget then stores it',
        () async {
          final personal = await createBudget(authedSession, 'Personal');
          final business = await createBudget(authedSession, 'Business');
          await saveProfile(
            authedSession,
            personal,
            TaxEntityKind.individual,
          );

          final saved = await saveProfile(
            authedSession,
            business,
            TaxEntityKind.soleTrader,
            linkedBudgetId: personal.id,
          );

          expect(saved.linkedBudgetId, personal.id);
        },
      );
    });

    group('when listing categories', () {
      test('then only categories for the entity kind are returned', () async {
        final personal = await createBudget(authedSession, 'Personal');
        final company = await createBudget(authedSession, 'Company');
        await saveProfile(authedSession, personal, TaxEntityKind.individual);
        await saveProfile(authedSession, company, TaxEntityKind.company);

        final personalCategories = await endpoints.tax.listCategories(
          authedSession,
          personal.id!,
        );
        final companyCategories = await endpoints.tax.listCategories(
          authedSession,
          company.id!,
        );

        expect(
          personalCategories.map((category) => category.code),
          contains(FakeTaxPack.employment.code),
        );
        expect(
          companyCategories.map((category) => category.code),
          isNot(contains(FakeTaxPack.employment.code)),
        );
      });

      test(
        'when the real United Kingdom pack is used then SA103F boxes are listed',
        () async {
          final business = await createBudget(authedSession, 'Studio');
          await saveProfile(authedSession, business, TaxEntityKind.soleTrader);
          TaxService.packFor = TaxRules.forJurisdiction;

          final categories = await endpoints.tax.listCategories(
            authedSession,
            business.id!,
          );

          expect(categories, isNotEmpty);
          expect(
            categories.map((category) => category.code),
            everyElement(startsWith('gb.')),
          );
          expect(
            categories.any(
              (category) =>
                  category.reportReference?.contains('SA103F') ?? false,
            ),
            isTrue,
          );
        },
      );
    });

    group('when categorising an envelope', () {
      test('then the category is stored and can be cleared', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final category = await endpoints.category.create(
          authedSession,
          'Work',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Office',
          category.id!,
          0,
          'GBP',
        );

        final tagged = await endpoints.tax.setEnvelopeTaxCategory(
          authedSession,
          envelope.id!,
          code: FakeTaxPack.officeCosts.code,
        );
        expect(tagged.taxCategoryCode, FakeTaxPack.officeCosts.code);

        final cleared = await endpoints.tax.setEnvelopeTaxCategory(
          authedSession,
          envelope.id!,
        );
        expect(cleared.taxCategoryCode, isNull);
      });

      test('with an unknown category then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final category = await endpoints.category.create(
          authedSession,
          'Work',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Office',
          category.id!,
          0,
          'GBP',
        );

        await expectLater(
          endpoints.tax.setEnvelopeTaxCategory(
            authedSession,
            envelope.id!,
            code: 'gb.unknown',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with a category for another entity kind then rejects', () async {
        final budget = await createBudget(authedSession, 'Company');
        await saveProfile(authedSession, budget, TaxEntityKind.company);
        final category = await endpoints.category.create(
          authedSession,
          'Work',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Payroll',
          category.id!,
          0,
          'GBP',
        );

        await expectLater(
          endpoints.tax.setEnvelopeTaxCategory(
            authedSession,
            envelope.id!,
            code: FakeTaxPack.employment.code,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('when another user tries then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final category = await endpoints.category.create(
          authedSession,
          'Work',
          budget.id!,
          0,
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          'Office',
          category.id!,
          0,
          'GBP',
        );
        final other = createAuthenticatedSession(sessionBuilder);

        await expectLater(
          endpoints.tax.setEnvelopeTaxCategory(
            other,
            envelope.id!,
            code: FakeTaxPack.officeCosts.code,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when categorising a transaction', () {
      test('then the values are stored and can be cleared', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Receipt',
          -10000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        final tagged = await endpoints.tax.setTransactionTax(
          authedSession,
          transaction.id!,
          code: FakeTaxPack.officeCosts.code,
          businessUsePercent: 50,
          salesTaxCents: 2000,
        );
        expect(tagged.taxCategoryCode, FakeTaxPack.officeCosts.code);
        expect(tagged.businessUsePercent, 50);
        expect(tagged.salesTaxCents, 2000);

        final cleared = await endpoints.tax.setTransactionTax(
          authedSession,
          transaction.id!,
        );
        expect(cleared.taxCategoryCode, isNull);
        expect(cleared.businessUsePercent, isNull);
        expect(cleared.salesTaxCents, isNull);
      });

      test('with an unknown category then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Receipt',
          -10000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        await expectLater(
          endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            code: 'gb.unknown',
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with an invalid business use percent then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Receipt',
          -10000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        await expectLater(
          endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            businessUsePercent: 101,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            businessUsePercent: -1,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('with sales tax outside the amount then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Receipt',
          -10000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );

        await expectLater(
          endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            salesTaxCents: -1,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            salesTaxCents: 10001,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('when another user tries then rejects', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(authedSession, budget, TaxEntityKind.individual);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Receipt',
          -10000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );
        final other = createAuthenticatedSession(sessionBuilder);

        await expectLater(
          endpoints.tax.setTransactionTax(
            other,
            transaction.id!,
            code: FakeTaxPack.officeCosts.code,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when reporting', () {
      test(
        'then a linked sole trader appears in the personal report',
        () async {
          final personal = await createBudget(authedSession, 'Personal');
          final business = await createBudget(authedSession, 'Business');
          await saveProfile(
            authedSession,
            personal,
            TaxEntityKind.individual,
          );
          await saveProfile(
            authedSession,
            business,
            TaxEntityKind.soleTrader,
            linkedBudgetId: personal.id,
          );

          final salary = await endpoints.transaction.create(
            authedSession,
            'Salary',
            300000,
            'GBP',
            personal.id!,
            DateTime.utc(2026, 1, 10),
          );
          await endpoints.tax.setTransactionTax(
            authedSession,
            salary.id!,
            code: FakeTaxPack.employment.code,
          );
          final sale = await endpoints.transaction.create(
            authedSession,
            'Sale',
            50000,
            'GBP',
            business.id!,
            DateTime.utc(2026, 2, 10),
          );
          await endpoints.tax.setTransactionTax(
            authedSession,
            sale.id!,
            code: FakeTaxPack.turnover.code,
          );
          final laptop = await endpoints.transaction.create(
            authedSession,
            'Laptop',
            -20000,
            'GBP',
            business.id!,
            DateTime.utc(2026, 2, 11),
          );
          await endpoints.tax.setTransactionTax(
            authedSession,
            laptop.id!,
            code: FakeTaxPack.officeCosts.code,
          );

          final report = await endpoints.tax.getReport(
            authedSession,
            personal.id!,
            startYear: 2026,
          );

          expect(report.entityKind, 'individual');
          expect(report.currencyCode, 'GBP');
          expect(report.startYear, 2026);
          expect(_lineAmount(report, 'Entries'), 1);
          expect(_lineAmount(report, 'Linked books'), 1);
          expect(_lineAmount(report, 'Linked entries'), 2);
          expect(report.opportunities, hasLength(1));
          expect(report.totalLiabilityMinor, 0);
          expect(report.balanceDueMinor, 0);
        },
      );

      test('then foreign currency entries are converted and counted', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(
          authedSession,
          budget,
          TaxEntityKind.individual,
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          'US client',
          10000,
          'USD',
          budget.id!,
          DateTime.utc(2026, 1, 15),
        );
        await endpoints.tax.setTransactionTax(
          authedSession,
          transaction.id!,
          code: FakeTaxPack.turnover.code,
        );

        final session = sessionBuilder.build();
        final snapshot = await FxRateSnapshot.db.insertRow(
          session,
          FxRateSnapshot(
            provider: 'test',
            baseCurrencyCode: 'USD',
            fetchedAt: DateTime.utc(2026, 1, 10),
            isLatest: true,
          ),
        );
        await FxRateEntry.db.insertRow(
          session,
          FxRateEntry(
            snapshotId: snapshot.id!,
            currencyCode: 'GBP',
            rate: 0.8,
          ),
        );

        final report = await endpoints.tax.getReport(
          authedSession,
          budget.id!,
          startYear: 2026,
        );

        expect(_lineAmount(report, 'Entries'), 1);
        expect(report.convertedEntryCount, 1);
        expect(
          report.assumptions,
          contains(
            'Amounts in other currencies were converted at the exchange rate '
            'on each transaction date.',
          ),
        );
      });

      test('then uncategorised transactions are counted', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(
          authedSession,
          budget,
          TaxEntityKind.individual,
        );
        await endpoints.transaction.create(
          authedSession,
          'Uncategorised',
          -5000,
          'GBP',
          budget.id!,
          DateTime.utc(2026, 3),
        );

        final report = await endpoints.tax.getReport(
          authedSession,
          budget.id!,
          startYear: 2026,
        );

        expect(_lineAmount(report, 'Entries'), 0);
        expect(report.uncategorizedCount, 1);
      });

      test(
        'when the year has no rates then throws TaxRulesUnavailableException',
        () async {
          final budget = await createBudget(authedSession, 'Personal');
          await saveProfile(
            authedSession,
            budget,
            TaxEntityKind.individual,
          );
          TaxService.packFor = TaxRules.forJurisdiction;

          await expectLater(
            endpoints.tax.getReport(authedSession, budget.id!, startYear: 2019),
            throwsA(isA<TaxRulesUnavailableException>()),
          );
        },
      );

      test(
        'when using the shipped UK pack then a £50,000 salary owes £7,486',
        () async {
          final budget = await createBudget(authedSession, 'Personal');
          await saveProfile(
            authedSession,
            budget,
            TaxEntityKind.individual,
          );
          TaxService.packFor = TaxRules.forJurisdiction;
          final salary = await endpoints.transaction.create(
            authedSession,
            'Salary',
            5000000,
            'GBP',
            budget.id!,
            DateTime.utc(2026, 6, 10),
          );
          await endpoints.tax.setTransactionTax(
            authedSession,
            salary.id!,
            code: 'gb.ind.employment',
          );

          final report = await endpoints.tax.getReport(
            authedSession,
            budget.id!,
            startYear: 2026,
          );

          expect(report.yearLabel, '2026/27');
          expect(report.uncategorizedCount, 0);
          final incomeTax = report.liabilities.firstWhere(
            (liability) =>
                liability.label == 'Income Tax on non-savings income',
          );
          expect(incomeTax.amountMinor, 748600);
          expect(report.totalLiabilityMinor, 748600);
        },
      );

      test('when the year is unsupported then throws', () async {
        final budget = await createBudget(authedSession, 'Personal');
        await saveProfile(
          authedSession,
          budget,
          TaxEntityKind.individual,
        );

        await expectLater(
          endpoints.tax.getReport(
            authedSession,
            budget.id!,
            startYear: 2024,
          ),
          throwsA(isA<TaxRulesUnavailableException>()),
        );
      });
    });
  });
}
