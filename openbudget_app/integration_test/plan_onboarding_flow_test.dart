import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _entityId = '00000000-0000-0000-0000-000000000991';

BudgetSummary _makeSummary({
  required int totalIncomeMinor,
  required int totalBudgetedMinor,
  required int readyToAssignMinor,
}) {
  final budgetUuid = UuidValue.fromString(_entityId);
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
    totalIncomeMinor: totalIncomeMinor,
    totalBudgetedMinor: totalBudgetedMinor,
    readyToAssignMinor: readyToAssignMinor,
    year: 2026,
    month: 2,
  );
}

void main() {
  patrolWidgetTest('add accounts onboarding CTA routes to add account screen', (
    $,
  ) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        ageOfMoneyProvider.overrideWith((ref, entityId) async => null),
        monthlyTransactionsProvider.overrideWith((ref, _) async => const []),
        budgetMonthlySummaryProvider.overrideWith(
          (ref, _) async => _makeSummary(
            totalIncomeMinor: 0,
            totalBudgetedMinor: 0,
            readyToAssignMinor: 0,
          ),
        ),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
        creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
        recurringDueCountProvider.overrideWith((ref, _) async => 0),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/plan',
      routes: [
        GoRoute(
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (context, state) =>
              BudgetDetailScreen(entityId: state.pathParameters['entityId']!),
        ),
        GoRoute(
          name: addAccountRoute,
          path: addAccountPath,
          builder: (_, _) =>
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

  patrolWidgetTest(
    'assign money onboarding secondary CTA routes to add account screen',
    ($) async {
      final tester = $.tester;
      final container = ProviderContainer(
        overrides: [
          ageOfMoneyProvider.overrideWith((ref, entityId) async => null),
          monthlyTransactionsProvider.overrideWith((ref, _) async => const []),
          budgetMonthlySummaryProvider.overrideWith(
            (ref, _) async => _makeSummary(
              totalIncomeMinor: 5000000,
              totalBudgetedMinor: 0,
              readyToAssignMinor: 5000000,
            ),
          ),
          budgetGoalsProvider.overrideWith((ref, _) async => {}),
          creditCardPaymentsProvider.overrideWith((ref, _) async => const []),
          recurringDueCountProvider.overrideWith((ref, _) async => 0),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$_entityId/plan',
        routes: [
          GoRoute(
            name: planRoute,
            path: '/budgets/:id/plan',
            builder: (context, state) =>
                BudgetDetailScreen(entityId: state.pathParameters['entityId']!),
          ),
          GoRoute(
            name: addAccountRoute,
            path: addAccountPath,
            builder: (_, _) =>
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
