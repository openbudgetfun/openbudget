// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';

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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ReportsScreen', () {
    testWidgets('renders loading indicator while report loads', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with error icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) => throw Exception('Could not load report data'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load report data'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Data Yet'), findsOneWidget);
      expect(
        find.text('Add transactions to see spending reports for this month'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.bar_chart_rounded), findsOneWidget);
    });

    testWidgets('renders app bar with reports title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('renders month navigation with previous and next buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('renders summary card with income label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalIncome: 300000,
                totalExpenses: 150000,
                transactionCount: 5,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('renders summary card with expenses label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalIncome: 300000,
                totalExpenses: 150000,
                transactionCount: 5,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('renders summary card with net income label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalIncome: 300000,
                totalExpenses: 150000,
                transactionCount: 5,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Income'), findsOneWidget);
    });

    testWidgets('renders summary card with transactions label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalIncome: 300000,
                totalExpenses: 150000,
                transactionCount: 5,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('renders category spending section when categories present', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalIncome: 500000,
                totalExpenses: 200000,
                transactionCount: 8,
                categorySpending: {
                  'Groceries': 80000,
                  'Transport': 50000,
                  'Entertainment': 70000,
                },
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('renders spending bars for each category', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(
                totalExpenses: 100000,
                transactionCount: 3,
                categorySpending: {'Food': 60000, 'Bills': 40000},
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });

    testWidgets('renders action icons in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingReportProvider.overrideWith(
              (ref, args) async => _makeReport(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ReportsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category_rounded), findsOneWidget);
      expect(find.byIcon(Icons.store_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.compare_arrows_rounded), findsOneWidget);
    });
  });
}
