// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000901',
);

SpendingReport _makeReport({
  int totalIncome = 0,
  int totalExpenses = 0,
  int transactionCount = 0,
  Map<String, int>? categorySpending,
  String currencyCode = 'USD',
}) {
  final spending = categorySpending ?? {};
  return SpendingReport(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netIncome: totalIncome - totalExpenses,
    transactionCount: transactionCount,
    categorySpending: spending,
    currencyCode: currencyCode,
  );
}

NetWorthData _makeNetWorthData() {
  final checking = Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000902'),
    name: 'Checking',
    accountType: 'checking',
    balanceCents: 5222000,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: false,
  );
  final creditCard = Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000903'),
    name: 'Credit Card',
    accountType: 'creditCard',
    balanceCents: -125,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    onBudget: true,
    sortOrder: 1,
    isClosed: false,
  );
  return NetWorthData(
    totalAssets: 5222000,
    totalLiabilities: -125,
    netWorth: 5221875,
    assetAccounts: [checking],
    liabilityAccounts: [creditCard],
    currencyCode: 'USD',
    currencyBreakdown: [
      CurrencyNetWorthData(
        currency: CurrencyCode.usd,
        totalAssets: 5222000,
        totalLiabilities: -125,
        assetAccounts: [checking],
        liabilityAccounts: [creditCard],
      ),
    ],
  );
}

Widget _buildSubject({
  required Future<SpendingReport> Function(Ref ref, (String, int, int) args)
  spendingBuilder,
  Future<NetWorthData> Function(Ref ref, String budgetId)? netWorthBuilder,
  Future<int?> Function(Ref ref, String budgetId)? ageBuilder,
  Future<DisplayCurrencyConverter> Function(Ref ref, String budgetId)?
  converterBuilder,
}) {
  return ProviderScope(
    overrides: [
      spendingReportProvider.overrideWith(spendingBuilder),
      netWorthProvider.overrideWith(
        netWorthBuilder ?? (ref, _) async => _makeNetWorthData(),
      ),
      ageOfMoneyProvider.overrideWith(ageBuilder ?? (ref, _) async => 2),
      if (converterBuilder != null)
        displayCurrencyConverterProvider.overrideWith(converterBuilder),
    ],
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ReportsScreen(budgetId: _budgetId),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReportsScreen', () {
    testWidgets('renders loading indicator while spending preview loads', (
      tester,
    ) async {
      final completer = Completer<SpendingReport>();
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) => completer.future,
          netWorthBuilder: (ref, _) => Future.value(_makeNetWorthData()),
          ageBuilder: (ref, _) => Future.value(2),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('renders reflect dashboard cards', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(
            totalIncome: 800000,
            totalExpenses: 222000,
            transactionCount: 8,
            categorySpending: {
              'Rent': 120000,
              'Utilities': 60000,
              'Groceries': 42000,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reflect'), findsOneWidget);
      expect(find.text('Spending Breakdown'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.textContaining(r'$2,220.00'), findsWidgets);
      expect(find.textContaining(r'$52,218.75'), findsWidgets);
    });

    testWidgets('renders spending categories in preview card', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(
            totalExpenses: 145000,
            transactionCount: 5,
            categorySpending: {
              'Rent': 100000,
              'Utilities': 30000,
              'Groceries': 15000,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders spending error text when report fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) =>
              Future.error(Exception('Could not load report data')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Could not load report data'), findsOneWidget);
    });

    testWidgets('renders age of money preview with days', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(),
          ageBuilder: (ref, _) async => 7,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('7 days'), findsOneWidget);
    });

    testWidgets(
      'renders converted report values when display currency is set',
      (tester) async {
        await tester.pumpWidget(
          _buildSubject(
            spendingBuilder: (ref, args) async => _makeReport(
              totalIncome: 800000,
              totalExpenses: 222000,
              transactionCount: 8,
              categorySpending: const {'Rent': 120000},
            ),
            converterBuilder: (ref, budgetId) async =>
                const DisplayCurrencyConverter(
                  displayCurrency: CurrencyCode.gbp,
                  baseCurrencyCode: 'USD',
                  ratesByCode: {'USD': 1.0, 'GBP': 0.7},
                ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('\u00A31,554.00'), findsWidgets);
        expect(find.textContaining('\u00A336,553.13'), findsWidgets);
      },
    );

    testWidgets('falls back to native report values when rates are missing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(
            totalIncome: 800000,
            totalExpenses: 222000,
            transactionCount: 8,
            categorySpending: const {'Rent': 120000},
          ),
          converterBuilder: (ref, budgetId) async =>
              const DisplayCurrencyConverter(
                displayCurrency: CurrencyCode.gbp,
                baseCurrencyCode: 'USD',
                ratesByCode: {'USD': 1.0},
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(r'$2,220.00'), findsWidgets);
    });
  });
}
