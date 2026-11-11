import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_plan_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000B01';
const _categoryId = '00000000-0000-0000-0000-000000000B02';
const _envelopeId = '00000000-0000-0000-0000-000000000B03';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_entityId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000B04',
  );

  final groceries = Envelope(
    id: envelopeUuid,
    name: 'Groceries',
    categoryId: categoryUuid,
    budgetedAmountMinor: 0,
    spentAmountMinor: 0,
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
          id: categoryUuid,
          name: 'Needs',
          entityId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [groceries],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: groceries,
            allocatedMinor: 0,
            spentMinor: 0,
            availableMinor: 0,
            carryoverMinor: 0,
          ),
        ],
        totalBudgetedMinor: 0,
        totalSpentMinor: 0,
        totalAvailableMinor: 0,
      ),
    ],
    totalIncomeMinor: 800000,
    totalBudgetedMinor: 0,
    readyToAssignMinor: 800000,
    year: 2026,
    month: 2,
  );
}

void main() {
  testWidgets('renders edit plan layout and category target entry points', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith(
          (ref, _) async => _makeSummary(),
        ),
        budgetGoalsProvider.overrideWith((ref, _) async => {}),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/plan/edit',
      routes: [
        GoRoute(
          name: planRoute,
          path: '/budgets/:id/plan',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Plan route'))),
        ),
        GoRoute(
          name: editPlanRoute,
          path: '/budgets/:id/plan/edit',
          builder: (context, state) =>
              EditPlanScreen(entityId: state.pathParameters['entityId']!),
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

    expect(find.text('Edit Plan'), findsOneWidget);
    expect(find.text('Cost to Be Me'), findsOneWidget);
    expect(find.text('Monthly Targets'), findsOneWidget);
    expect(find.text('Monthly Income'), findsOneWidget);
    expect(find.text('New Group'), findsOneWidget);
    expect(find.text('Reorder'), findsOneWidget);
    expect(find.text('Needs'), findsOneWidget);
    expect(find.text('Add Target'), findsOneWidget);
  });
}
