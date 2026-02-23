import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

const _budgetId = '00000000-0000-0000-0000-000000000971';
const _categoryId = '00000000-0000-0000-0000-000000000972';
const _envelopeId = '00000000-0000-0000-0000-000000000973';

BudgetSummary _makeSummaryForMonth(BudgetMonth month) {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000974',
  );
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final readyToAssignCents = month.month * 10000;
  const totalBudgetedCents = 5000;
  final totalIncomeCents = readyToAssignCents + totalBudgetedCents;

  final envelope = Envelope(
    id: envelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountCents: totalBudgetedCents,
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
          id: categoryUuid,
          name: 'Bills',
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [envelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: envelope,
            allocatedCents: totalBudgetedCents,
            spentCents: 0,
            availableCents: totalBudgetedCents,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: totalBudgetedCents,
        totalSpentCents: 0,
        totalAvailableCents: totalBudgetedCents,
      ),
    ],
    totalIncomeCents: totalIncomeCents,
    totalBudgetedCents: totalBudgetedCents,
    readyToAssignCents: readyToAssignCents,
    year: month.year,
    month: month.month,
  );
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  patrolWidgetTest('switching months updates plan header values', ($) async {
    final tester = $.tester;
    final container = ProviderContainer(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith((ref, budgetId) async {
          final month = ref.watch(selectedMonthProvider(budgetId));
          return _makeSummaryForMonth(month);
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

    final initialMonth = container.read(selectedMonthProvider(_budgetId));
    final initialReadyText = formatCents(
      initialMonth.month * 10000,
      CurrencyCode.usd,
    );
    expect(find.text(initialReadyText), findsWidgets);

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await tester.pumpAndSettle();

    final previousMonth = container.read(selectedMonthProvider(_budgetId));
    final expectedPreviousMonth = initialMonth.month == 1
        ? BudgetMonth(year: initialMonth.year - 1, month: 12)
        : BudgetMonth(year: initialMonth.year, month: initialMonth.month - 1);
    expect(previousMonth, expectedPreviousMonth);

    final previousReadyText = formatCents(
      previousMonth.month * 10000,
      CurrencyCode.usd,
    );
    expect(find.text(previousReadyText), findsWidgets);

    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();

    final restoredMonth = container.read(selectedMonthProvider(_budgetId));
    expect(restoredMonth, initialMonth);
    expect(find.text(initialReadyText), findsWidgets);
  });
}
