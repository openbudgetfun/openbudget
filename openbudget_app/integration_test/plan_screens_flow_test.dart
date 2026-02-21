import 'dart:io';

// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = '00000000-0000-0000-0000-000000000901';
const _categoryId = '00000000-0000-0000-0000-000000000902';
const _envelopeId = '00000000-0000-0000-0000-000000000903';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000904',
  );

  final envelope = Envelope(
    id: envelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountCents: 6000,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: 0,
    note: 'Auto-pay every month',
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
        envelopes: [envelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: envelope,
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
    ],
    totalIncomeCents: 20000,
    totalBudgetedCents: 6000,
    readyToAssignCents: 14000,
    year: 2026,
    month: 2,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens recent moves and category detail from plan', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, _) async {
          return _makeSummary();
        }),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
        creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
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
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Finish Onboarding'), findsOneWidget);
    await _captureScreenshot(binding, 'plan-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Finish Onboarding'));
    await tester.pumpAndSettle();
    expect(find.text('Finish Onboarding'), findsNothing);
    await _captureScreenshot(binding, 'plan-screen-onboarding-dismissed');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Spotlight'));
    await tester.pumpAndSettle();
    await _captureScreenshot(binding, 'spotlight-screen');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Hide Amounts'), findsOneWidget);
    await _captureScreenshot(binding, 'plan-menu');
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Collapse/Expand'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Auto-pay every month'), findsNothing);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Collapse/Expand'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Auto-pay every month'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recent Moves'));
    await tester.pumpAndSettle();
    final gotIt = find.text('Got It!');
    if (gotIt.evaluate().isNotEmpty) {
      await tester.tap(gotIt);
      await tester.pumpAndSettle();
    }
    await _captureScreenshot(binding, 'recent-moves-screen');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Recent Moves'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Utilities'));
    await tester.pumpAndSettle();
    await _captureScreenshot(binding, 'category-detail-screen');
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Rename Category'), findsOneWidget);
  });
}

Future<void> _captureScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  final bytes = await binding.takeScreenshot(name);
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
