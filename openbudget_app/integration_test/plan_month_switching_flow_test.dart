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
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

const _entityId = '00000000-0000-0000-0000-000000000971';
const _categoryId = '00000000-0000-0000-0000-000000000972';
const _envelopeId = '00000000-0000-0000-0000-000000000973';

BudgetSummary _makeSummaryForMonth(BudgetMonth month) {
  final budgetUuid = UuidValue.fromString(_entityId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000974',
  );
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final readyToAssignMinor = month.month * 10000;
  const totalBudgetedMinor = 5000;
  final totalIncomeMinor = readyToAssignMinor + totalBudgetedMinor;

  final envelope = Envelope(
    id: envelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountMinor: totalBudgetedMinor,
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
          name: 'Bills',
          entityId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [envelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: envelope,
            allocatedMinor: totalBudgetedMinor,
            spentMinor: 0,
            availableMinor: totalBudgetedMinor,
            carryoverMinor: 0,
          ),
        ],
        totalBudgetedMinor: totalBudgetedMinor,
        totalSpentMinor: 0,
        totalAvailableMinor: totalBudgetedMinor,
      ),
    ],
    totalIncomeMinor: totalIncomeMinor,
    totalBudgetedMinor: totalBudgetedMinor,
    readyToAssignMinor: readyToAssignMinor,
    year: month.year,
    month: month.month,
  );
}

void main() {
  patrolWidgetTest('switching months updates plan header values', ($) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        ageOfMoneyProvider.overrideWith((ref, entityId) async => null),
        monthlyTransactionsProvider.overrideWith((ref, _) async => const []),
        budgetMonthlySummaryProvider.overrideWith((ref, entityId) async {
          final month = ref.watch(selectedMonthProvider(entityId));
          return _makeSummaryForMonth(month);
        }),
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
          path: '/budgets/:id/plan',
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
      initialMonth.month * 10000,
      CurrencyCode.usd,
    );
    expect(find.text(initialReadyText), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-month-previous')));
    await tester.pumpAndSettle();

    final previousMonth = container.read(selectedMonthProvider(_entityId));
    final expectedPreviousMonth = initialMonth.month == 1
        ? BudgetMonth(year: initialMonth.year - 1, month: 12)
        : BudgetMonth(year: initialMonth.year, month: initialMonth.month - 1);
    expect(previousMonth, expectedPreviousMonth);

    final previousReadyText = formatMinor(
      previousMonth.month * 10000,
      CurrencyCode.usd,
    );
    expect(find.text(previousReadyText), findsWidgets);

    await tester.tap(find.byKey(const Key('budget-month-next')));
    await tester.pumpAndSettle();

    final restoredMonth = container.read(selectedMonthProvider(_entityId));
    expect(restoredMonth, initialMonth);
    expect(find.text(initialReadyText), findsWidgets);
  });
}
