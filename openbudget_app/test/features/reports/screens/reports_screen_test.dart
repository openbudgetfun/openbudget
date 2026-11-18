import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/utils/report_group_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const String _entityId = fixtureEntityId;

SpendingReport _makeReport({
  int totalIncome = 0,
  int totalExpenses = 0,
  Map<String, int>? categorySpending,
  String currencyCode = 'USD',
}) {
  final spending = categorySpending ?? {};
  return SpendingReport(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netIncome: totalIncome - totalExpenses,
    categorySpending: spending,
    currencyCode: currencyCode,
    month: 202611,
  );
}

NetWorthView _makeNetWorth() => NetWorthView(
  currencyCode: 'USD',
  asOf: DateTime.utc(2026, 11, 5),
  assetsMinor: 5222000,
  liabilitiesMinor: -125,
  netWorthMinor: 5221875,
  isComplete: true,
  missingCurrencyCodes: const [],
  hasStaleRates: false,
  currencies: const [],
  entities: const [],
  accounts: const [],
);

Widget _buildSubject({
  required Future<SpendingReport> Function(Ref ref, (String, int) args)
  spendingBuilder,
  Future<NetWorthView> Function(Ref ref)? netWorthBuilder,
}) => ProviderScope(
  overrides: [
    spendingReportProvider.overrideWith(spendingBuilder),
    netWorthProvider.overrideWith(
      netWorthBuilder ?? (ref) async => _makeNetWorth(),
    ),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const ReportsScreen(entityId: _entityId),
  ),
);

void main() {
  group('ReportsScreen', () {
    testWidgets('renders loading indicator while spending preview loads', (
      tester,
    ) async {
      final completer = Completer<SpendingReport>();
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) => completer.future,
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsWidgets);
    });

    testWidgets('renders reflect dashboard cards', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(
            totalIncome: 800000,
            totalExpenses: 222000,
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

    testWidgets('renders uncategorised spending as its own translated row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(
            totalExpenses: 145000,
            categorySpending: {
              'Rent': 100000,
              reportUncategorisedGroup: 45000,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uncategorised'), findsOneWidget);
      expect(find.text(reportUncategorisedGroup), findsNothing);
      expect(find.text(r'$1,450.00'), findsWidgets);
      expect(find.text(r'$450.00'), findsOneWidget);
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

      expect(find.textContaining('Could not load report data'), findsWidgets);
    });

    testWidgets('shows the trends and comparison entry points', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          spendingBuilder: (ref, args) async => _makeReport(),
        ),
      );
      await tester.pumpAndSettle();

      // The entry points sit below the two preview cards.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      expect(find.text('Spending Trends'), findsOneWidget);
      expect(find.text('Budget Comparison'), findsOneWidget);
    });

    // Age of money moved to the plan header and display-currency
    // conversion is server-side now: the previews here always render the
    // base-currency figures straight from the report.
  });
}
