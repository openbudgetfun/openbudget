import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);

int _previousMonth(int yyyymm) =>
    yyyymm % 100 == 1 ? yyyymm - 100 + 11 : yyyymm - 1;

/// The month view the header reads; Ready to Assign is £[calendar month]
/// × £100 so the switch is visible in the formatted figure.
BudgetMonthView _makeMonthView(int yyyymm) {
  final readyToAssignMinor = (yyyymm % 100) * 10000;
  final view = BudgetMonthView(
    entityId: _entityUuid,
    month: yyyymm,
    currencyCode: 'GBP',
    summary: BudgetMonthSummary(
      month: yyyymm,
      incomeMinor: readyToAssignMinor,
      uncategorizedMinor: 0,
      fxDifferenceMinor: 0,
      allocatedMinor: 0,
      activityMinor: 0,
      overspentLastMonthMinor: 0,
      assignedInFutureMinor: 0,
      readyToAssignMinor: readyToAssignMinor,
      availableMinor: readyToAssignMinor,
    ),
    categories: const [],
    envelopes: const [],
  );
  return view;
}

void main() {
  patrolWidgetTest('switching months updates plan header values', ($) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        entityDetailProvider.overrideWith(
          (ref, id) async => TestData.gbpEntity(),
        ),
        budgetMonthProvider.overrideWith((ref, entityId) async {
          final month = ref.watch(selectedMonthProvider(entityId));
          return _makeMonthView(month);
        }),
        budgetMonthGroupsProvider.overrideWith(
          (ref, entityId) async => const [],
        ),
        budgetGoalsProvider.overrideWith((ref, entityId) async => {}),
        creditCardPaymentsProvider.overrideWith(
          (ref, entityId) async => const [],
        ),
        recurringDueCountProvider.overrideWith((ref, entityId) async => 0),
        reviewQueueProvider.overrideWith((ref, entityId) async => const []),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/plan',
      routes: [
        GoRoute(
          path: '/budgets/:entityId/plan',
          builder: (context, state) =>
              BudgetDetailScreen(entityId: state.pathParameters['entityId']!),
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

    final initialMonth = container.read(selectedMonthProvider(_entityId));
    final initialReadyText = formatMinor(
      (initialMonth % 100) * 10000,
      CurrencyCode.gbp,
    );
    expect(find.text(initialReadyText), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-month-previous')));
    await tester.pumpAndSettle();

    final previousMonth = container.read(selectedMonthProvider(_entityId));
    expect(previousMonth, _previousMonth(initialMonth));

    final previousReadyText = formatMinor(
      (previousMonth % 100) * 10000,
      CurrencyCode.gbp,
    );
    expect(find.text(previousReadyText), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-month-next')));
    await tester.pumpAndSettle();

    final restoredMonth = container.read(selectedMonthProvider(_entityId));
    expect(restoredMonth, initialMonth);
    expect(find.text(initialReadyText), findsWidgets);
  });
}
