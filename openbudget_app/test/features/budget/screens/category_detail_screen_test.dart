// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = '00000000-0000-0000-0000-000000000100';
const _categoryId = '00000000-0000-0000-0000-000000000101';
const _envelopeId = '00000000-0000-0000-0000-000000000102';

BudgetSummary _makeSummary() {
  final budgetUuid = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);
  final envelopeUuid = UuidValue.fromString(_envelopeId);
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000103',
  );

  final envelope = Envelope(
    id: envelopeUuid,
    name: 'Utilities',
    categoryId: categoryUuid,
    budgetedAmountCents: 6000,
    spentAmountCents: 0,
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
          budgetId: budgetUuid,
          sortOrder: 0,
        ),
        envelopes: [envelope],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: envelope,
            allocatedCents: 6000,
            spentCents: 0,
            availableCents: 6000,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 6000,
        totalSpentCents: 0,
        totalAvailableCents: 6000,
      ),
    ],
    totalIncomeCents: 20000,
    totalBudgetedCents: 6000,
    readyToAssignCents: 14000,
    year: 2026,
    month: 2,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders full-screen category detail sections', (tester) async {
    final goal = EnvelopeGoal(
      envelopeId: UuidValue.fromString(_envelopeId),
      goalType: 'monthly_funding',
      targetAmountCents: 6000,
      monthlyFundingCents: 6000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith((ref, _) async {
            return _makeSummary();
          }),
          budgetGoalsProvider.overrideWith((ref, _) async {
            return {_envelopeId: goal};
          }),
        ],
        child: MaterialApp(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryDetailScreen(
            budgetId: _budgetId,
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

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Rename Envelope'), findsOneWidget);
    expect(find.text('Hide Envelope'), findsOneWidget);
    expect(find.text('Delete Envelope'), findsOneWidget);
  });
}
