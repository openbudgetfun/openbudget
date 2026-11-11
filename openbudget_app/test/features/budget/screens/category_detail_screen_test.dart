import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = '00000000-0000-0000-0000-000000000100';
const _categoryId = '00000000-0000-0000-0000-000000000101';
const _envelopeId = '00000000-0000-0000-0000-000000000102';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_entityId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000103',
  );

  final envelope = Envelope(
    id: envelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountMinor: 6000,
    spentAmountMinor: 0,
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
          entityId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [envelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: envelope,
            allocatedMinor: 6000,
            spentMinor: 0,
            availableMinor: 6000,
            carryoverMinor: 0,
          ),
        ],
        totalBudgetedMinor: 6000,
        totalSpentMinor: 0,
        totalAvailableMinor: 6000,
      ),
    ],
    totalIncomeMinor: 20000,
    totalBudgetedMinor: 6000,
    readyToAssignMinor: 14000,
    year: 2026,
    month: 2,
  );
}

void main() {
  testWidgets('renders full-screen category detail sections', (tester) async {
    final goal = EnvelopeGoal(
      envelopeId: UuidValue.fromString(_envelopeId),
      goalType: 'monthly_funding',
      targetAmountMinor: 6000,
      monthlyFundingMinor: 6000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith(
            (ref, _) async => _makeSummary(),
          ),
          budgetGoalsProvider.overrideWith(
            (ref, _) async => {_envelopeId: goal},
          ),
        ],
        child: MaterialApp(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryDetailScreen(
            entityId: _entityId,
            categoryId: _categoryId,
            envelopeId: _envelopeId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Amount to Assign This Month'), findsOneWidget);
    expect(find.text('Assigned So Far'), findsOneWidget);
    expect(find.text('To Go'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Delete Category'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Snooze for this month'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Tax category'), findsOneWidget);
    expect(find.text('Rename Category'), findsOneWidget);
    expect(find.text('Hide Category'), findsOneWidget);
    expect(find.text('Delete Category'), findsOneWidget);
  });
}
