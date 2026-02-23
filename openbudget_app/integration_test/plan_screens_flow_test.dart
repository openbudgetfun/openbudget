import 'dart:io';

// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _budgetId = '00000000-0000-0000-0000-000000000901';
const _categoryId = '00000000-0000-0000-0000-000000000902';
const _categoryTwoId = '00000000-0000-0000-0000-000000000908';
const _utilitiesEnvelopeId = '00000000-0000-0000-0000-000000000903';
const _storageEnvelopeId = '00000000-0000-0000-0000-000000000905';
const _groceriesEnvelopeId = '00000000-0000-0000-0000-000000000909';
const _accountId = '00000000-0000-0000-0000-000000000906';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final utilitiesEnvelopeUuid = UuidValue.fromString(_utilitiesEnvelopeId);
  final storageEnvelopeUuid = UuidValue.fromString(_storageEnvelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000904',
  );

  final utilitiesEnvelope = Envelope(
    id: utilitiesEnvelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountCents: 6000,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 0,
    note: 'Auto-pay every month',
  );
  final storageEnvelope = Envelope(
    id: storageEnvelopeUuid,
    name: 'Self storage',
    categoryId: categoryUuid,
    budgetedAmountCents: 0,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 1,
  );

  return BudgetSummary(
    budget: Budget(
      id: budgetUuid,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerUuid,
    ),
    categories: [
      CategoryWithEnvelopes(
        category: Category(
          id: categoryUuid,
          name: 'Bills',
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [utilitiesEnvelope, storageEnvelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: utilitiesEnvelope,
            allocatedCents: 6000,
            spentCents: 0,
            availableCents: 6000,
            carryoverCents: 0,
          ),
          MonthlyEnvelopeData(
            envelope: storageEnvelope,
            allocatedCents: 0,
            spentCents: 0,
            availableCents: 0,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 6000,
        totalSpentCents: 0,
        totalAvailableCents: 6000,
      ),
    ],
    totalIncomeCents: 20000,
    totalBudgetedCents: 6000,
    readyToAssignCents: 14000,
    year: 2026,
    month: 2,
  );
}

BudgetSummary _makeOverspentSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final utilitiesEnvelopeUuid = UuidValue.fromString(_utilitiesEnvelopeId);
  final storageEnvelopeUuid = UuidValue.fromString(_storageEnvelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000904',
  );

  final utilitiesEnvelope = Envelope(
    id: utilitiesEnvelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountCents: 0,
    spentAmountCents: 6000,
    currencyCode: 'USD',
    sortOrder: 0,
    note: 'Auto-pay every month',
  );
  final storageEnvelope = Envelope(
    id: storageEnvelopeUuid,
    name: 'Self storage',
    categoryId: categoryUuid,
    budgetedAmountCents: 0,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 1,
  );

  return BudgetSummary(
    budget: Budget(
      id: budgetUuid,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerUuid,
    ),
    categories: [
      CategoryWithEnvelopes(
        category: Category(
          id: categoryUuid,
          name: 'Bills',
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [utilitiesEnvelope, storageEnvelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: utilitiesEnvelope,
            allocatedCents: 0,
            spentCents: 6000,
            availableCents: -6000,
            carryoverCents: 0,
          ),
          MonthlyEnvelopeData(
            envelope: storageEnvelope,
            allocatedCents: 0,
            spentCents: 0,
            availableCents: 0,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 0,
        totalSpentCents: 6000,
        totalAvailableCents: -6000,
      ),
    ],
    totalIncomeCents: 20000,
    totalBudgetedCents: 0,
    readyToAssignCents: 20000,
    year: 2026,
    month: 2,
  );
}

BudgetSummary _makeReorderSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final billsCategoryUuid = UuidValue.fromString(_categoryId);
  final groceriesCategoryUuid = UuidValue.fromString(_categoryTwoId);
  final utilitiesEnvelopeUuid = UuidValue.fromString(_utilitiesEnvelopeId);
  final groceriesEnvelopeUuid = UuidValue.fromString(_groceriesEnvelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000904',
  );

  final utilitiesEnvelope = Envelope(
    id: utilitiesEnvelopeUuid,
    name: 'Utilities',
    categoryId: billsCategoryUuid,
    budgetedAmountCents: 6000,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 0,
  );
  final groceriesEnvelope = Envelope(
    id: groceriesEnvelopeUuid,
    name: 'Food',
    categoryId: groceriesCategoryUuid,
    budgetedAmountCents: 3000,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 0,
  );

  return BudgetSummary(
    budget: Budget(
      id: budgetUuid,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerUuid,
    ),
    categories: [
      CategoryWithEnvelopes(
        category: Category(
          id: billsCategoryUuid,
          name: 'Housing',
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [utilitiesEnvelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: utilitiesEnvelope,
            allocatedCents: 6000,
            spentCents: 0,
            availableCents: 6000,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 6000,
        totalSpentCents: 0,
        totalAvailableCents: 6000,
      ),
      CategoryWithEnvelopes(
        category: Category(
          id: groceriesCategoryUuid,
          name: 'Groceries Group',
          budgetId: budgetUuid,
          sortOrder: 1,
        ),
        envelopes: [groceriesEnvelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: groceriesEnvelope,
            allocatedCents: 3000,
            spentCents: 0,
            availableCents: 3000,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 3000,
        totalSpentCents: 0,
        totalAvailableCents: 3000,
      ),
    ],
    totalIncomeCents: 20000,
    totalBudgetedCents: 9000,
    readyToAssignCents: 11000,
    year: 2026,
    month: 2,
  );
}

List<Transaction> _makeMonthlyTransactions() {
  return [
    Transaction(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000907'),
      description: 'Landlord',
      amountCents: -10000,
      currencyCode: 'USD',
      budgetId: UuidValue.fromString(_budgetId),
      accountId: UuidValue.fromString(_accountId),
      envelopeId: UuidValue.fromString(_utilitiesEnvelopeId),
      transactionDate: DateTime(2026, 2, 22),
      cleared: false,
      reconciled: false,
    ),
  ];
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  patrolWidgetTest('opens recent moves and category detail from plan', (
    $,
  ) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, _) async {
          return _makeSummary();
        }),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
        creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
        monthlyTransactionsProvider.overrideWith(
          (ref, _) async => _makeMonthlyTransactions(),
        ),
        recurringDueCountProvider.overrideWith((ref, _) async => 0),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_budgetId/plan',
      routes: [
        GoRoute(
          name: homeRoute,
          path: homePath,
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (context, state) =>
              BudgetDetailScreen(budgetId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              name: recentMovesRoute,
              path: 'recent-moves',
              builder: (context, state) =>
                  RecentMovesScreen(budgetId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  name: envelopeMovesRoute,
                  path: ':envelopeId',
                  builder: (context, state) => EnvelopeMovesScreen(
                    budgetId: state.pathParameters['id']!,
                    envelopeId: state.pathParameters['envelopeId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              name: categoryDetailRoute,
              path: 'category/:categoryId/envelope/:envelopeId',
              builder: (context, state) => CategoryDetailScreen(
                budgetId: state.pathParameters['id']!,
                categoryId: state.pathParameters['categoryId']!,
                envelopeId: state.pathParameters['envelopeId']!,
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
    expect(find.text('Finish Onboarding'), findsOneWidget);
    container
        .read(recentMovesProvider.notifier)
        .recordAssigned(
          budgetId: _budgetId,
          envelopeId: _utilitiesEnvelopeId,
          amountCents: 6000,
        );
    container
        .read(recentMovesProvider.notifier)
        .recordMove(
          budgetId: _budgetId,
          fromEnvelopeId: _storageEnvelopeId,
          toEnvelopeId: _utilitiesEnvelopeId,
          amountCents: 3000,
        );
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'plan-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Finish Onboarding'));
    await tester.pumpAndSettle();
    expect(find.text('Finish Onboarding'), findsNothing);
    expect(find.text('Review 1 transaction'), findsOneWidget);
    await tester.tap(find.text('Review 1 transaction'));
    await tester.pumpAndSettle();
    expect(find.text('1 New Transaction'), findsOneWidget);
    await _captureScreenshot(tester, 'review-transactions-screen');
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Landlord'));
    await tester.pumpAndSettle();
    expect(find.text('1 Selected'), findsOneWidget);
    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    expect(find.text('No Transactions'), findsOneWidget);
    expect(find.text("You're All Done!"), findsOneWidget);
    await _captureScreenshot(tester, 'review-transactions-empty-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'plan-screen-onboarding-dismissed');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Spotlight'));
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'spotlight-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsWidgets);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hide Amounts'), findsOneWidget);
    await _captureScreenshot(tester, 'plan-menu');
    await tester.pump(const Duration(seconds: 1));

    await _tapPopupMenuItem(tester, 'Undo');
    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Recent Moves');
    expect(find.text('Hide Progress Bars', skipOffstage: false), findsNothing);
    await _dismissCoachmarkIfVisible(tester);
    expect(find.text('Ready to Assign'), findsOneWidget);
    expect(find.text('Self storage'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    container
        .read(recentMovesProvider.notifier)
        .recordMove(
          budgetId: _budgetId,
          fromEnvelopeId: _storageEnvelopeId,
          toEnvelopeId: _utilitiesEnvelopeId,
          amountCents: 3000,
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Progress Bars');
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Progress Bars');
    expect(find.byType(LinearProgressIndicator), findsWidgets);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Amounts');
    expect(find.text('••••'), findsWidgets);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Hide Amounts');
    expect(find.text('••••'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Collapse/Expand');
    expect(find.textContaining('Auto-pay every month'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Collapse/Expand');
    expect(find.textContaining('Auto-pay every month'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await _tapPopupMenuItem(tester, 'Recent Moves');
    await _dismissCoachmarkIfVisible(tester);
    await _captureScreenshot(tester, 'recent-moves-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Moved'));
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'recent-moves-moved-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Self storage').first);
    await tester.pumpAndSettle();
    expect(find.text('Moves'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Moves'), findsOneWidget);

    await tester.tap(find.text('Utilities').first);
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'envelope-moves-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recent Moves'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Utilities'));
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'plan-inline-editor-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    await _captureScreenshot(tester, 'category-detail-screen');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Set Goal'), findsOneWidget);
    await tester.tap(find.text('Set Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Save Target'), findsOneWidget);
    var saveTargetButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save Target'),
    );
    expect(saveTargetButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '2800');
    await tester.pumpAndSettle();

    saveTargetButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save Target'),
    );
    expect(saveTargetButton.onPressed, isNotNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Rename Category'), findsOneWidget);
  });

  patrolWidgetTest('opens overspending coverage sheet from plan banner', (
    $,
  ) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, _) async {
          return _makeOverspentSummary();
        }),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
        creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
        monthlyTransactionsProvider.overrideWith((ref, _) async => const []),
        recurringDueCountProvider.overrideWith((ref, _) async => 0),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_budgetId/plan',
      routes: [
        GoRoute(
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (context, state) =>
              BudgetDetailScreen(budgetId: state.pathParameters['id']!),
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

    expect(find.text('Cover 1 overspent category'), findsOneWidget);
    await tester.tap(find.text('Cover 1 overspent category'));
    await tester.pumpAndSettle();

    expect(find.text('Cover Overspending'), findsOneWidget);
    expect(find.textContaining(r'Needs $60.00'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Cover 1 overspent category'), findsOneWidget);
  });

  patrolWidgetTest('reorder mode moves categories and exits cleanly', (
    $,
  ) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, _) async {
          return _makeReorderSummary();
        }),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
        creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
        monthlyTransactionsProvider.overrideWith((ref, _) async => const []),
        recurringDueCountProvider.overrideWith((ref, _) async => 0),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_budgetId/plan',
      routes: [
        GoRoute(
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (context, state) =>
              BudgetDetailScreen(budgetId: state.pathParameters['id']!),
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

    await tester.tap(find.byIcon(Icons.swap_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextButton, 'Done'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Groceries Group'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final housingBefore = tester.getTopLeft(find.text('Housing')).dy;
    final groceriesBefore = tester.getTopLeft(find.text('Groceries Group')).dy;
    expect(housingBefore, lessThan(groceriesBefore));

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded).last);
    await tester.pumpAndSettle();

    final housingAfter = tester.getTopLeft(find.text('Housing')).dy;
    final groceriesAfter = tester.getTopLeft(find.text('Groceries Group')).dy;
    expect(groceriesAfter, lessThan(housingAfter));

    await tester.tap(find.widgetWithText(TextButton, 'Done'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);
  });
}

Future<void> _captureScreenshot(WidgetTester tester, String name) async {
  final binding = tester.binding;
  if (binding is! IntegrationTestWidgetsFlutterBinding) {
    // Logging here keeps the CI output explicit when screenshot capture is not
    // supported by the active test binding.
    // ignore: avoid_print
    print('Skipping screenshot capture for $name: unsupported test binding');
    return;
  }

  List<int> bytes;
  try {
    bytes = await binding.takeScreenshot(name);
  } on MissingPluginException {
    // Some test runtimes (for example flutter-tester) don't expose screenshot
    // capture. Keep test assertions focused on behavior in those environments.
    // ignore: avoid_print
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
  // Expose location in test logs for host-side collection.
  // ignore: avoid_print
  print('Saved screenshot: $screenshotPath');
}

Future<void> _tapPopupMenuItem(WidgetTester tester, String label) async {
  final textFinder = find.text(label, skipOffstage: false);
  if (textFinder.evaluate().isEmpty) {
    throw TestFailure('Expected popup menu item "$label" to be visible.');
  }

  final menuItemFinder = find.ancestor(
    of: textFinder.first,
    matching: find.byType(PopupMenuItem),
  );
  if (menuItemFinder.evaluate().isNotEmpty) {
    await tester.tap(menuItemFinder.first, warnIfMissed: false);
  } else {
    await tester.tap(textFinder.first, warnIfMissed: false);
  }
  await tester.pumpAndSettle();
}

Future<void> _dismissCoachmarkIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got It!');
  if (gotIt.evaluate().isEmpty) return;
  await tester.tap(gotIt.first);
  await tester.pumpAndSettle();
}
