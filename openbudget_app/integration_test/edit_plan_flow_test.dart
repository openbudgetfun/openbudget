import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_plan_screen.dart';
import 'package:openbudget_app/src/features/budget/widgets/budget_amount_keypad.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;
const String _categoryId = '00000000-0000-0000-0000-000000000a02';

Envelope _envelope(String id, String name, int sortOrder) => Envelope(
  id: UuidValue.fromString(id),
  name: name,
  entityId: UuidValue.fromString(_entityId),
  categoryId: UuidValue.fromString(_categoryId),
  sortOrder: sortOrder,
);

/// One 'Needs' group with four envelopes and £8,000 waiting to be assigned.
List<CategoryMonthGroup> _makeGroups() {
  final groceries = _envelope(
    '00000000-0000-0000-0000-000000000a10',
    'Groceries',
    0,
  );
  final transportation = _envelope(
    '00000000-0000-0000-0000-000000000a11',
    'Transportation',
    1,
  );
  final pets = _envelope('00000000-0000-0000-0000-000000000a12', 'Pets', 2);
  final vetVisits = _envelope(
    '00000000-0000-0000-0000-000000000a13',
    'Vet visits',
    3,
  );

  EnvelopeMonthView view(Envelope envelope) => EnvelopeMonthView(
    envelope: envelope,
    carryoverMinor: 0,
    allocatedMinor: 0,
    activityMinor: 0,
    availableMinor: 0,
    goalUnderfundedMinor: 0,
  );

  return [
    CategoryMonthGroup(
      category: Category(
        id: UuidValue.fromString(_categoryId),
        name: 'Needs',
        entityId: UuidValue.fromString(_entityId),
        sortOrder: 0,
      ),
      envelopes: [
        view(groceries),
        view(transportation),
        view(pets),
        view(vetVisits),
      ],
    ),
  ];
}

BudgetMonthView _makeMonthView() => BudgetMonthView(
  entityId: UuidValue.fromString(_entityId),
  month: 202602,
  currencyCode: 'GBP',
  summary: BudgetMonthSummary(
    month: 202602,
    incomeMinor: 800000,
    uncategorizedMinor: 0,
    fxDifferenceMinor: 0,
    allocatedMinor: 0,
    activityMinor: 0,
    overspentLastMonthMinor: 0,
    assignedInFutureMinor: 0,
    readyToAssignMinor: 800000,
    availableMinor: 800000,
  ),
  categories: [_makeGroups().single.category],
  envelopes: const [],
);

void main() {
  patrolWidgetTest(
    'edit plan screen supports target entry, group details, and next navigation',
    ($) async {
      final tester = $.tester;
      final groups = _makeGroups();
      final container = ProviderContainer(
        overrides: [
          entityDetailProvider.overrideWith(
            (ref, id) async => TestData.gbpEntity(),
          ),
          budgetMonthProvider.overrideWith((ref, entityId) async {
            ref.watch(selectedYyyymmProvider(entityId));
            return _makeMonthView();
          }),
          budgetMonthGroupsProvider.overrideWith((ref, entityId) async {
            ref.watch(selectedYyyymmProvider(entityId));
            return groups;
          }),
          budgetGoalsProvider.overrideWith((ref, entityId) async => {}),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$_entityId/plan/edit',
        routes: [
          GoRoute(
            name: planRoute,
            path: '/budgets/:entityId/plan',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('Plan destination'))),
          ),
          GoRoute(
            name: editPlanRoute,
            path: '/budgets/:entityId/plan/edit',
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
      expect(find.text('Add Target'), findsWidgets);

      final editPlanPage = EditPlanPage(tester);
      await editPlanPage.openFirstAddTarget();
      expect(editPlanPage.saveTargetButton, findsOneWidget);
      // The amount field opens the keypad sheet; enter 2800 and confirm.
      await tester.tap(find.widgetWithText(BudgetAmountField, 'Amount'));
      await tester.pumpAndSettle();
      for (final digit in ['2', '8', '0', '0']) {
        await tester.tap(find.byKey(Key('budget-keypad-digit-$digit')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('budget-keypad-done')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await editPlanPage.openGroupDetails(_categoryId);
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
