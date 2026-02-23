import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';

// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

const _budgetId = '00000000-0000-0000-0000-000000000991';

BudgetSummary _makeSummary({
  required int totalIncomeCents,
  required int totalBudgetedCents,
  required int readyToAssignCents,
}) {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000992',
  );
  return BudgetSummary(
    budget: Budget(
      id: budgetUuid,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerUuid,
    ),
    categories: const [],
    totalIncomeCents: totalIncomeCents,
    totalBudgetedCents: totalBudgetedCents,
    readyToAssignCents: readyToAssignCents,
    year: 2026,
    month: 2,
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add accounts onboarding CTA routes to add account screen', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, _) async {
          return _makeSummary(
            totalIncomeCents: 0,
            totalBudgetedCents: 0,
            readyToAssignCents: 0,
          );
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
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (context, state) =>
              BudgetDetailScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: addAccountRoute,
          path: addAccountPath,
          builder: (_, __) =>
              const Scaffold(body: Center(child: Text('Add Account Screen'))),
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

    expect(find.text('Add Accounts'), findsOneWidget);
    await tester.tap(find.text('Add Accounts'));
    await tester.pumpAndSettle();
    expect(find.text('Add Account Screen'), findsOneWidget);
  });

  testWidgets(
    'assign money onboarding secondary CTA routes to add account screen',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith((ref, _) async {
            return _makeSummary(
              totalIncomeCents: 5000000,
              totalBudgetedCents: 0,
              readyToAssignCents: 5000000,
            );
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
            name: planRoute,
            path: '/budgets/:id/plan',
            builder: (context, state) =>
                BudgetDetailScreen(budgetId: state.pathParameters['id']!),
          ),
          GoRoute(
            name: addAccountRoute,
            path: addAccountPath,
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Add Account Screen'))),
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

      expect(find.text('Add Another Account'), findsOneWidget);
      await tester.tap(find.text('Add Another Account'));
      await tester.pumpAndSettle();
      expect(find.text('Add Account Screen'), findsOneWidget);
    },
  );
}
