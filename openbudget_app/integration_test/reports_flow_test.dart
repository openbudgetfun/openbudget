// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_by_payee_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'helpers/screenshot_capture.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000601',
);

SpendingReport _makeReportForMonth(int year, int month) {
  return switch ((year, month)) {
    (2026, 2) => const SpendingReport(
      totalIncome: 800000,
      totalExpenses: 222000,
      netIncome: 578000,
      transactionCount: 9,
      categorySpending: {'Rent': 120000, 'Clothing': 80000, 'Utilities': 22000},
      currencyCode: 'USD',
    ),
    (2026, 1) => const SpendingReport(
      totalIncome: 800000,
      totalExpenses: 162000,
      netIncome: 638000,
      transactionCount: 8,
      categorySpending: {'Rent': 90000, 'Clothing': 50000, 'Utilities': 22000},
      currencyCode: 'USD',
    ),
    (2025, 12) => const SpendingReport(
      totalIncome: 800000,
      totalExpenses: 282000,
      netIncome: 518000,
      transactionCount: 10,
      categorySpending: {
        'Rent': 150000,
        'Clothing': 100000,
        'Utilities': 32000,
      },
      currencyCode: 'USD',
    ),
    (2025, 11) => const SpendingReport(
      totalIncome: 730000,
      totalExpenses: 152000,
      netIncome: 578000,
      transactionCount: 8,
      categorySpending: {'Rent': 80000, 'Clothing': 50000, 'Utilities': 22000},
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
}

NetWorthData _makeNetWorthData() {
  final checking = Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000602'),
    name: 'Daily',
    accountType: 'checking',
    balanceCents: 5222000,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: false,
  );
  final creditCard = Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000603'),
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

Widget _buildApp({ThemeMode themeMode = ThemeMode.light}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/reflect',
    routes: [
      GoRoute(
        name: reportsRoute,
        path: '/budgets/:id/reflect',
        builder: (context, state) =>
            ReportsScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: spendingByPayeeRoute,
        path: '/budgets/:id/reflect/payees',
        builder: (context, state) => SpendingByPayeeScreen(
          budgetId: state.pathParameters['id']!,
          initialYear: 2026,
          initialMonth: 2,
        ),
      ),
      GoRoute(
        name: netWorthRoute,
        path: '/budgets/:id/reflect/net-worth',
        builder: (context, state) =>
            NetWorthScreen(budgetId: state.pathParameters['id']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      spendingReportProvider.overrideWith(
        (ref, args) async => _makeReportForMonth(args.$2, args.$3),
      ),
      netWorthProvider.overrideWith(
        (ref, budgetId) async => _makeNetWorthData(),
      ),
      ageOfMoneyProvider.overrideWith((ref, budgetId) async => 2),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      darkTheme: OpenBudgetTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  patrolWidgetTest('reflect dashboard navigates to spending breakdown detail', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Reflect'), findsOneWidget);
    await tester.tap(find.text('Spending Breakdown').first);
    await tester.pumpAndSettle();

    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Preset'), findsOneWidget);
    expect(find.text('Rent'), findsWidgets);
    expect(find.text('Utilities'), findsWidgets);
    expect(find.textContaining('2,220.00'), findsOneWidget);
  });

  patrolWidgetTest('spending breakdown applies dark-mode background surfaces', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Spending Breakdown').first);
    await tester.pumpAndSettle();

    final expectedBackground = OpenBudgetPalette.appBackgroundFor(
      OpenBudgetTheme.dark,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Scaffold && widget.backgroundColor == expectedBackground,
      ),
      findsWidgets,
    );
  });

  patrolWidgetTest(
    'spending breakdown supports preset toggle and range selection UI',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spending Breakdown').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preset'));
      await tester.pumpAndSettle();

      expect(find.text('Preset Range'), findsOneWidget);
      expect(find.text('Last 3 Months'), findsWidgets);
      expect(find.text('February 2026'), findsOneWidget);
      expect(find.text('December 2025–February 2026'), findsOneWidget);
      expect(find.textContaining(r'$6,660.00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('January 2026'), findsOneWidget);
      expect(find.text('November 2025–January 2026'), findsOneWidget);
      expect(find.textContaining(r'$5,960.00'), findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'reports-spending-breakdown-preset',
      );
    },
  );

  patrolWidgetTest(
    'spending breakdown updates totals when preset range changes',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spending Breakdown').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preset'));
      await tester.pumpAndSettle();

      expect(find.text('Last 3 Months'), findsWidgets);
      expect(find.text('December 2025–February 2026'), findsOneWidget);
      expect(find.textContaining(r'$6,660.00'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 6 Months').last);
      await tester.pumpAndSettle();

      expect(find.text('September 2025–February 2026'), findsOneWidget);
      expect(find.textContaining(r'$8,180.00'), findsOneWidget);
      expect(find.textContaining(r'$4,400.00'), findsOneWidget);
      expect(find.textContaining(r'$2,800.00'), findsOneWidget);
      expect(find.textContaining(r'$980.00'), findsOneWidget);

      await captureIntegrationScreenshot(
        tester,
        'reports-spending-breakdown-last-six-months',
      );
    },
  );

  patrolWidgetTest(
    'desktop spending breakdown preset keeps six-month totals in sync',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spending Breakdown').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preset'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 6 Months').last);
      await tester.pumpAndSettle();

      expect(find.text('Preset Range'), findsOneWidget);
      expect(find.text('Last 6 Months'), findsWidgets);
      expect(find.text('September 2025–February 2026'), findsOneWidget);
      expect(find.textContaining(r'$8,180.00'), findsOneWidget);
      expect(find.textContaining(r'$4,400.00'), findsOneWidget);
      expect(find.textContaining(r'$2,800.00'), findsOneWidget);
      expect(find.textContaining(r'$980.00'), findsOneWidget);

      await captureIntegrationScreenshot(
        tester,
        'reports-spending-breakdown-last-six-months-desktop-screen',
      );
    },
  );

  patrolWidgetTest('reflect dashboard navigates to net worth detail', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Net Worth').first);
    await tester.pumpAndSettle();

    expect(find.text('Net Worth'), findsWidgets);
    expect(find.text('Assets'), findsWidgets);
    expect(find.text('Liabilities'), findsWidgets);
  });
}
