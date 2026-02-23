// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_plan_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _budgetId = '00000000-0000-0000-0000-000000000A01';
const _categoryId = '00000000-0000-0000-0000-000000000A02';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000A03',
  );

  Envelope envelope(String id, String name, int sortOrder) => Envelope(
    id: UuidValue.fromString(id),
    name: name,
    categoryId: categoryUuid,
    budgetedAmountCents: 0,
    spentAmountCents: 0,
    currencyCode: 'USD',
    sortOrder: sortOrder,
  );

  final groceries = envelope(
    '00000000-0000-0000-0000-000000000A10',
    'Groceries',
    0,
  );
  final transportation = envelope(
    '00000000-0000-0000-0000-000000000A11',
    'Transportation',
    1,
  );
  final pets = envelope('00000000-0000-0000-0000-000000000A12', 'Pets', 2);
  final vetVisits = envelope(
    '00000000-0000-0000-0000-000000000A13',
    'Vet visits',
    3,
  );

  MonthlyEnvelopeData monthly(Envelope e) => MonthlyEnvelopeData(
    envelope: e,
    allocatedCents: 0,
    spentCents: 0,
    availableCents: 0,
    carryoverCents: 0,
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
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [groceries, transportation, pets, vetVisits],
        monthlyEnvelopes: [
          monthly(groceries),
          monthly(transportation),
          monthly(pets),
          monthly(vetVisits),
        ],
        totalBudgetedCents: 0,
        totalSpentCents: 0,
        totalAvailableCents: 0,
      ),
    ],
    totalIncomeCents: 800000,
    totalBudgetedCents: 0,
    readyToAssignCents: 800000,
    year: 2026,
    month: 2,
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  patrolWidgetTest(
    'edit plan screen supports target entry, group details, and next navigation',
    ($) async {
      final tester = $.tester;
      final container = ProviderContainer(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith((ref, _) async {
            return _makeSummary();
          }),
          budgetGoalsProvider.overrideWith((ref, _) async => {}),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$_budgetId/plan/edit',
        routes: [
          GoRoute(
            name: planRoute,
            path: '/budgets/:id/plan',
            builder: (_, __) =>
                const Scaffold(body: Center(child: Text('Plan destination'))),
          ),
          GoRoute(
            name: editPlanRoute,
            path: '/budgets/:id/plan/edit',
            builder: (context, state) =>
                EditPlanScreen(budgetId: state.pathParameters['id']!),
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
      expect(find.text('Add Target'), findsWidgets);

      await tester.tap(find.text('Add Target').first);
      await tester.pumpAndSettle();
      expect(find.text('Save Target'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '2800');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(Key('edit-plan-group-menu-${_categoryId.toLowerCase()}')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Category Group Name'), findsOneWidget);
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Hidden categories are moved to a group at the bottom of your plan.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Plan'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Plan destination'), findsOneWidget);
    },
  );
}
