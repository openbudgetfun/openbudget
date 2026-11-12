import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);

/// The month view the plan screen reads: an empty plan with nothing
/// assigned.
BudgetMonthView _makeMonthView({required int readyToAssignMinor}) {
  final summary = BudgetMonthSummary(
    month: 202602,
    incomeMinor: readyToAssignMinor,
    uncategorizedMinor: 0,
    fxDifferenceMinor: 0,
    allocatedMinor: 0,
    activityMinor: 0,
    overspentLastMonthMinor: 0,
    assignedInFutureMinor: 0,
    readyToAssignMinor: readyToAssignMinor,
    availableMinor: readyToAssignMinor,
  );
  return BudgetMonthView(
    entityId: _entityUuid,
    month: 202602,
    currencyCode: 'GBP',
    summary: summary,
    categories: const [],
    envelopes: const [],
  );
}

/// A fake entity creator that returns a fixed id, so the create screen
/// routes into the add account step without a server.
class _FakeEntityActions extends EntityActions {
  int createCalls = 0;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<String> create({
    required String name,
    required EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
  }) async {
    createCalls++;
    return _entityId;
  }
}

Widget _buildPlanApp(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/plan',
    routes: [
      GoRoute(
        name: planRoute,
        path: '/budgets/:entityId/plan',
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

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

ProviderContainer _planContainer({required int readyToAssignMinor}) {
  final container = ProviderContainer(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.gbpEntity(),
      ),
      budgetMonthProvider.overrideWith(
        (ref, entityId) async =>
            _makeMonthView(readyToAssignMinor: readyToAssignMinor),
      ),
      budgetMonthGroupsProvider.overrideWith((ref, entityId) async => const []),
      budgetGoalsProvider.overrideWith((ref, entityId) async => {}),
      creditCardPaymentsProvider.overrideWith(
        (ref, entityId) async => const [],
      ),
      recurringDueCountProvider.overrideWith((ref, entityId) async => 0),
      reviewQueueProvider.overrideWith((ref, entityId) async => const []),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  patrolWidgetTest(
    'onboarding starts at create entity and lands on add account',
    ($) async {
      final tester = $.tester;
      final actions = _FakeEntityActions();
      final container = ProviderContainer(
        overrides: [entityActionsProvider.overrideWith(() => actions)],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: createEntityPath,
        routes: [
          GoRoute(
            path: createEntityPath,
            builder: (_, _) => const CreateEntityScreen(),
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

      final createPage = CreateEntityPage(tester);
      expect(createPage.title, findsOneWidget);
      await createPage.create(
        navigatesTo: find.text('Add Account Screen'),
      );

      expect(actions.createCalls, 1);
      expect(find.text('Add Account Screen'), findsOneWidget);
    },
  );

  patrolWidgetTest(
    'add accounts onboarding CTA routes to add account screen',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(
        _buildPlanApp(_planContainer(readyToAssignMinor: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Accounts'), findsOneWidget);
      await tester.tap(find.text('Add Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Add Account Screen'), findsOneWidget);
    },
  );

  patrolWidgetTest(
    'assign money onboarding secondary CTA routes to add account screen',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(
        _buildPlanApp(_planContainer(readyToAssignMinor: 5000000)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Another Account'), findsOneWidget);
      await tester.tap(find.text('Add Another Account'));
      await tester.pumpAndSettle();
      expect(find.text('Add Account Screen'), findsOneWidget);
    },
  );
}
