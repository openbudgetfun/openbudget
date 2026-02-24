// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_by_payee_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000601',
);

SpendingReport _makeReport() {
  return const SpendingReport(
    totalIncome: 800000,
    totalExpenses: 222000,
    netIncome: 578000,
    transactionCount: 9,
    categorySpending: {'Rent': 120000, 'Utilities': 60000, 'Groceries': 42000},
    currencyCode: 'USD',
  );
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

Widget _buildApp() {
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
        builder: (context, state) =>
            SpendingByPayeeScreen(budgetId: state.pathParameters['id']!),
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
      spendingReportProvider.overrideWith((ref, args) async => _makeReport()),
      netWorthProvider.overrideWith(
        (ref, budgetId) async => _makeNetWorthData(),
      ),
      ageOfMoneyProvider.overrideWith((ref, budgetId) async => 2),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
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
      expect(
        find.textContaining(RegExp(r'[A-Za-z]+ \d{4}–[A-Za-z]+ \d{4}')),
        findsOneWidget,
      );
      await _captureScreenshot(tester, 'reports-spending-breakdown-preset');
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

Future<void> _captureScreenshot(WidgetTester tester, String name) async {
  final binding = tester.binding;
  if (binding is! IntegrationTestWidgetsFlutterBinding) {
    // ignore: avoid_print, reason: keeps CI logs explicit when screenshot capture is unavailable.
    print('Skipping screenshot capture for $name: unsupported test binding');
    return;
  }

  List<int> bytes;
  try {
    bytes = await binding.takeScreenshot(name);
  } on MissingPluginException {
    // ignore: avoid_print, reason: keeps CI logs explicit when screenshot plugin is unavailable.
    print('Skipping screenshot capture for $name: plugin unavailable');
    return;
  }
  if (bytes.isEmpty) return;

  final screenshotDir = Directory(
    '${Directory.systemTemp.path}/openbudget_screenshots/runtime',
  );
  if (!screenshotDir.existsSync()) {
    screenshotDir.createSync(recursive: true);
  }
  final screenshotPath = '${screenshotDir.path}/$name.png';
  File(screenshotPath).writeAsBytesSync(bytes);
  // ignore: avoid_print, reason: exposes generated artifact path in CI/test logs.
  print('Saved screenshot: $screenshotPath');
}
