import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

void main() {
  group('spendingReportPresetProvider', () {
    test('aggregates monthly reports and category totals', () async {
      final requestedMonths = <({int year, int month})>[];
      final container = ProviderContainer(
        overrides: [
          spendingReportProvider.overrideWith((ref, args) async {
            final (_, year, month) = args;
            requestedMonths.add((year: year, month: month));
            return _reportFor(year: year, month: month);
          }),
        ],
      );
      addTearDown(container.dispose);

      final report = await container.read(
        spendingReportPresetProvider('budget-1', 2025, 9, 3).future,
      );

      expect(
        requestedMonths,
        equals([
          (year: 2025, month: 9),
          (year: 2025, month: 8),
          (year: 2025, month: 7),
        ]),
      );
      expect(report.totalIncome, equals(6000));
      expect(report.totalExpenses, equals(600));
      expect(report.netIncome, equals(5400));
      expect(report.transactionCount, equals(24));
      expect(
        report.categorySpending,
        equals({'Rent': 300, 'Utilities': 260, 'Groceries': 60}),
      );
      expect(report.currencyCode, equals('USD'));
    });

    test('clamps invalid month count to one month', () async {
      final requestedMonths = <({int year, int month})>[];
      final container = ProviderContainer(
        overrides: [
          spendingReportProvider.overrideWith((ref, args) async {
            final (_, year, month) = args;
            requestedMonths.add((year: year, month: month));
            return _reportFor(year: year, month: month);
          }),
        ],
      );
      addTearDown(container.dispose);

      final report = await container.read(
        spendingReportPresetProvider('budget-1', 2025, 9, 0).future,
      );

      expect(requestedMonths, equals([(year: 2025, month: 9)]));
      expect(report.totalIncome, equals(3000));
      expect(report.totalExpenses, equals(300));
      expect(report.netIncome, equals(2700));
      expect(report.transactionCount, equals(9));
      expect(report.categorySpending, equals({'Rent': 120, 'Utilities': 180}));
    });
  });

  group('buildCategorySpendingByEnvelope', () {
    final budgetId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000701',
    );
    final utilitiesEnvelopeId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000702',
    );
    final groceriesEnvelopeId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000703',
    );
    final incomeEnvelopeId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000704',
    );

    test('counts outflow transactions only', () {
      final categorySpending = buildCategorySpendingByEnvelope(
        transactions: [
          Transaction(
            description: 'Utilities bill',
            amountCents: -6000,
            currencyCode: 'USD',
            envelopeId: utilitiesEnvelopeId,
            budgetId: budgetId,
            transactionDate: DateTime(2026, 2, 22),
          ),
          Transaction(
            description: 'Groceries',
            amountCents: -2500,
            currencyCode: 'USD',
            envelopeId: groceriesEnvelopeId,
            budgetId: budgetId,
            transactionDate: DateTime(2026, 2, 22),
          ),
          Transaction(
            description: 'Payroll',
            amountCents: 50000,
            currencyCode: 'USD',
            envelopeId: incomeEnvelopeId,
            budgetId: budgetId,
            transactionDate: DateTime(2026, 2, 22),
          ),
          Transaction(
            description: 'Ignored unassigned inflow',
            amountCents: 10000,
            currencyCode: 'USD',
            budgetId: budgetId,
            transactionDate: DateTime(2026, 2, 22),
          ),
        ],
        envelopeCategoryById: {
          utilitiesEnvelopeId.toString(): 'Utilities',
          groceriesEnvelopeId.toString(): 'Groceries',
          incomeEnvelopeId.toString(): 'Income',
        },
      );

      expect(
        categorySpending,
        equals(<String, int>{'Utilities': 6000, 'Groceries': 2500}),
      );
    });
  });
}

SpendingReport _reportFor({required int year, required int month}) =>
    switch ((year, month)) {
      (2025, 9) => const SpendingReport(
        totalIncome: 3000,
        totalExpenses: 300,
        netIncome: 2700,
        transactionCount: 9,
        categorySpending: {'Rent': 120, 'Utilities': 180},
        currencyCode: 'USD',
      ),
      (2025, 8) => const SpendingReport(
        totalIncome: 2000,
        totalExpenses: 200,
        netIncome: 1800,
        transactionCount: 8,
        categorySpending: {'Rent': 100, 'Utilities': 80, 'Groceries': 20},
        currencyCode: 'USD',
      ),
      (2025, 7) => const SpendingReport(
        totalIncome: 1000,
        totalExpenses: 100,
        netIncome: 900,
        transactionCount: 7,
        categorySpending: {'Rent': 80, 'Groceries': 40},
        currencyCode: 'USD',
      ),
      _ => const SpendingReport(
        totalIncome: 0,
        totalExpenses: 0,
        netIncome: 0,
        transactionCount: 0,
        categorySpending: {},
        currencyCode: 'USD',
      ),
    };
