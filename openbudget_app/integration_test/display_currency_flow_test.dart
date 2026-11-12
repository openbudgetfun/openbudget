import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

const _entityId = '00000000-0000-0000-0000-000000000711';
final _budgetUuid = UuidValue.fromString(_entityId);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000712');

Budget _makeBudget({String? displayCurrencyCode}) => Budget(
  id: _budgetUuid,
  name: 'FX Plan',
  currencyCode: 'USD',
  displayCurrencyCode: displayCurrencyCode,
  ownerId: _ownerUuid,
);

List<Account> _makeAccounts() => [
  Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000713'),
    name: 'USD Checking',
    accountType: 'checking',
    balanceMinor: 10000,
    currencyCode: 'USD',
    entityId: _budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: false,
  ),
  Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000714'),
    name: 'EUR Savings',
    accountType: 'savings',
    balanceMinor: 10000,
    currencyCode: 'EUR',
    entityId: _budgetUuid,
    onBudget: true,
    sortOrder: 1,
    isClosed: false,
  ),
];

BudgetSummary _makeSummary(Budget budget) => BudgetSummary(
  budget: budget,
  categories: const [],
  totalIncomeMinor: 10000,
  totalBudgetedMinor: 0,
  readyToAssignMinor: 10000,
  year: 2026,
  month: 2,
);

SpendingReport _makeReport() => const SpendingReport(
  totalIncome: 800000,
  totalExpenses: 222000,
  netIncome: 578000,
  transactionCount: 9,
  categorySpending: {'Rent': 120000},
  currencyCode: 'USD',
);

NetWorthData _makeNetWorthData(List<Account> accounts) {
  final usd = accounts.firstWhere((account) => account.currencyCode == 'USD');
  final eur = accounts.firstWhere((account) => account.currencyCode == 'EUR');

  return NetWorthData(
    totalAssets: 20000,
    totalLiabilities: 0,
    netWorth: 20000,
    assetAccounts: [usd, eur],
    liabilityAccounts: const [],
    currencyCode: 'USD',
    currencyBreakdown: [
      CurrencyNetWorthData(
        currency: 'USD',
        totalAssets: 10000,
        totalLiabilities: 0,
        assetAccounts: [usd],
        liabilityAccounts: const [],
      ),
      CurrencyNetWorthData(
        currency: 'EUR',
        totalAssets: 10000,
        totalLiabilities: 0,
        assetAccounts: [eur],
        liabilityAccounts: const [],
      ),
    ],
  );
}

void main() {
  patrolWidgetTest('display currency can be set to GBP from settings', (
    $,
  ) async {
    final tester = $.tester;
    final displayCurrencyOverride = <String, String?>{_entityId: null};

    final container = ProviderContainer(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async =>
              _makeBudget(displayCurrencyCode: displayCurrencyOverride[id]),
        ),
        updateDisplayCurrencyProvider.overrideWith(
          (ref) =>
              ({
                required entityId,
                required clearDisplayCurrencyCode,
                displayCurrencyCode,
              }) async {
                displayCurrencyOverride[entityId] = clearDisplayCurrencyCode
                    ? null
                    : displayCurrencyCode;
              },
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/more/settings/display',
      routes: [
        GoRoute(
          name: settingsRoute,
          path: '/budgets/:id/more/settings',
          builder: (_, _) => const Scaffold(body: Text('Settings')),
          routes: [
            GoRoute(
              name: displayOptionsRoute,
              path: 'display',
              builder: (context, state) => DisplayOptionsScreen(
                entityId: state.pathParameters['entityId']!,
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: ThemeData.light(useMaterial3: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Display Currency'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('British Pound (GBP)'));
    await tester.pumpAndSettle();

    expect(displayCurrencyOverride[_entityId], 'GBP');
    container.invalidate(budgetDetailProvider(_entityId));
    await tester.pumpAndSettle();
    expect(find.text('British Pound (GBP)'), findsOneWidget);
    await _captureScreenshot(tester, 'display_options_gbp_selected');
  });

  patrolWidgetTest('mixed-currency summary and reports show converted totals', (
    $,
  ) async {
    final tester = $.tester;
    final budget = _makeBudget(displayCurrencyCode: 'GBP');
    final accounts = _makeAccounts();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          name: homeRoute,
          path: '/',
          builder: (_, _) => const HomeScreen(),
        ),
        GoRoute(
          name: accountListRoute,
          path: '/budgets/:id/accounts',
          builder: (context, state) =>
              AccountListScreen(entityId: state.pathParameters['entityId']!),
        ),
        GoRoute(
          name: reportsRoute,
          path: '/budgets/:id/reflect',
          builder: (context, state) =>
              ReportsScreen(entityId: state.pathParameters['entityId']!),
        ),
        GoRoute(
          name: netWorthRoute,
          path: '/budgets/:id/reflect/net-worth',
          builder: (context, state) =>
              NetWorthScreen(entityId: state.pathParameters['entityId']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetListProvider.overrideWith((ref) async => [budget]),
          budgetSummaryProvider.overrideWith(
            (ref, entityId) async => _makeSummary(budget),
          ),
          accountListProvider.overrideWith((ref, entityId) async => accounts),
          spendingReportProvider.overrideWith(
            (ref, args) async => _makeReport(),
          ),
          netWorthProvider.overrideWith(
            (ref, entityId) async => _makeNetWorthData(accounts),
          ),
          ageOfMoneyProvider.overrideWith((ref, entityId) async => 2),
          displayCurrencyConverterProvider.overrideWith(
            (ref, entityId) async => const DisplayCurrencyConverter(
              displayCurrency: CurrencyCode.gbp,
              baseCurrencyCode: 'USD',
              ratesByCode: {'USD': 1.0, 'EUR': 0.8, 'GBP': 0.7},
            ),
          ),
        ],
        child: MaterialApp.router(
          theme: ThemeData.light(useMaterial3: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('\u00A3157.50'), findsWidgets);
    expect(find.textContaining('\u00A370.00 to assign'), findsOneWidget);
    await _captureScreenshot(tester, 'home_summary_converted_gbp');

    router.go('/budgets/$_entityId/accounts');
    await tester.pumpAndSettle();
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.textContaining('\u00A3157.50'), findsWidgets);
    await _captureScreenshot(tester, 'accounts_summary_converted_gbp');

    router.go('/budgets/$_entityId/reflect');
    await tester.pumpAndSettle();
    expect(find.text('Reflect'), findsOneWidget);
    expect(find.textContaining('\u00A31,554.00'), findsWidgets);
    await _captureScreenshot(tester, 'reports_summary_converted_gbp');

    router.go('/budgets/$_entityId/reflect/net-worth');
    await tester.pumpAndSettle();
    expect(find.text('Net Worth'), findsWidgets);
    expect(find.textContaining('\u00A3157.50'), findsWidgets);
    await _captureScreenshot(tester, 'reports_net_worth_converted_gbp');
  });
}

Future<void> _captureScreenshot(WidgetTester tester, String name) async {
  final binding = tester.binding;
  var bytes = const <int>[];
  if (binding is IntegrationTestWidgetsFlutterBinding) {
    try {
      bytes = await binding.takeScreenshot(name);
    } on MissingPluginException {
      bytes = await _captureRenderViewPng(tester) ?? const [];
      if (bytes.isEmpty) {
        // Ignore print usage in integration tests to surface artifact paths.
        // ignore: avoid_print
        print('Skipping screenshot capture for $name: plugin unavailable');
        return;
      }
    }
  } else {
    bytes = await _captureRenderViewPng(tester) ?? const [];
    if (bytes.isEmpty) {
      // Ignore print usage in integration tests to surface artifact paths.
      // ignore: avoid_print
      print('Skipping screenshot capture for $name: unsupported test binding');
      return;
    }
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
  // Ignore print usage in integration tests to surface artifact paths.
  // ignore: avoid_print
  print('Saved screenshot: $screenshotPath');
}

Future<List<int>?> _captureRenderViewPng(WidgetTester tester) async {
  try {
    final renderView = tester.binding.renderViews.firstOrNull;
    if (renderView == null) return null;
    final layer = renderView.debugLayer;
    if (layer is! OffsetLayer) return null;
    final image = await layer.toImage(renderView.paintBounds, pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } on Exception {
    return null;
  }
}
