import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_by_payee_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

const String _entityId = TestData.gbpEntityId;

/// One month of spending, keyed by the requested yyyymm; months outside the
/// four fixture months come back empty, matching the server's no-data
/// answer.
SpendingReport _reportForMonth(int endMonth) => switch (endMonth) {
  202602 => const SpendingReport(
    totalIncome: 800000,
    totalExpenses: 222000,
    netIncome: 578000,
    categorySpending: {'Rent': 120000, 'Clothing': 80000, 'Utilities': 22000},
    currencyCode: 'USD',
    month: 202602,
  ),
  202601 => const SpendingReport(
    totalIncome: 800000,
    totalExpenses: 162000,
    netIncome: 638000,
    categorySpending: {'Rent': 90000, 'Clothing': 50000, 'Utilities': 22000},
    currencyCode: 'USD',
    month: 202601,
  ),
  202512 => const SpendingReport(
    totalIncome: 800000,
    totalExpenses: 282000,
    netIncome: 518000,
    categorySpending: {'Rent': 150000, 'Clothing': 100000, 'Utilities': 32000},
    currencyCode: 'USD',
    month: 202512,
  ),
  202511 => const SpendingReport(
    totalIncome: 730000,
    totalExpenses: 152000,
    netIncome: 578000,
    categorySpending: {'Rent': 80000, 'Clothing': 50000, 'Utilities': 22000},
    currencyCode: 'USD',
    month: 202511,
  ),
  _ => SpendingReport(
    totalIncome: 0,
    totalExpenses: 0,
    netIncome: 0,
    categorySpending: const {},
    currencyCode: 'USD',
    month: endMonth,
  ),
};

/// The combined preset range: sums of the fixture months the range covers.
SpendingReport _reportForRange(int endMonth, int monthCount) {
  var income = 0;
  var expenses = 0;
  final categorySpending = <String, int>{};
  for (var offset = 0; offset < monthCount; offset++) {
    final report = _reportForMonth(endMonth - offset);
    income += report.totalIncome;
    expenses += report.totalExpenses;
    report.categorySpending.forEach((category, minor) {
      categorySpending[category] = (categorySpending[category] ?? 0) + minor;
    });
  }
  return SpendingReport(
    totalIncome: income,
    totalExpenses: expenses,
    netIncome: income - expenses,
    categorySpending: categorySpending,
    currencyCode: 'USD',
  );
}

Widget _buildApp({ThemeMode themeMode = ThemeMode.light}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/reflect',
    routes: [
      GoRoute(
        name: reportsRoute,
        path: '/budgets/:entityId/reflect',
        builder: (context, state) =>
            ReportsScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: spendingByPayeeRoute,
        path: '/budgets/:entityId/reflect/payees',
        builder: (context, state) => SpendingByPayeeScreen(
          entityId: state.pathParameters['entityId']!,
          initialYear: 2026,
          initialMonth: 2,
        ),
      ),
      GoRoute(
        name: netWorthRoute,
        path: '/budgets/:entityId/reflect/net-worth',
        builder: (context, state) =>
            NetWorthScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      spendingReportProvider.overrideWith((ref, args) async {
        final (entityId, endMonth) = args;
        return _reportForMonth(endMonth);
      }),
      spendingReportPresetProvider.overrideWith((ref, args) async {
        final (entityId, endMonth, monthCount) = args;
        return _reportForRange(endMonth, monthCount);
      }),
      netWorthProvider.overrideWith(
        (ref) async => TestData.gbpNetWorthWithUsd(),
      ),
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

    final expectedBackground = OpenBudgetPalette.bgPrimaryFor(
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

      await tester.tap(find.byKey(SpendingByPayeeScreen.previousMonthKey));
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
      await tester.scrollUntilVisible(
        find.text('Income this period'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Income this period'), findsOneWidget);

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
