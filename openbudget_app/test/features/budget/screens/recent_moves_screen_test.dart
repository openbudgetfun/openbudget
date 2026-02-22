// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = '00000000-0000-0000-0000-000000000111';
const _categoryId = '00000000-0000-0000-0000-000000000222';
const _envelopeGroceriesId = '00000000-0000-0000-0000-000000000333';
const _envelopeClothingId = '00000000-0000-0000-0000-000000000444';

BudgetSummary _makeSummary() {
  final ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000555');
  final budgetId = UuidValue.fromString(_budgetId);
  final categoryUuid = UuidValue.fromString(_categoryId);

  final groceries = Envelope(
    id: UuidValue.fromString(_envelopeGroceriesId),
    name: 'Groceries',
    categoryId: categoryUuid,
    budgetedAmountCents: 120000,
    spentAmountCents: 40000,
    currencyCode: 'USD',
    sortOrder: 0,
  );
  final clothing = Envelope(
    id: UuidValue.fromString(_envelopeClothingId),
    name: 'Clothing',
    categoryId: categoryUuid,
    budgetedAmountCents: 40000,
    spentAmountCents: 10000,
    currencyCode: 'USD',
    sortOrder: 1,
  );

  return BudgetSummary(
    budget: Budget(
      id: budgetId,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerId,
    ),
    categories: [
      CategoryWithEnvelopes(
        category: Category(
          id: categoryUuid,
          name: 'Needs',
          budgetId: budgetId,
          sortOrder: 0,
        ),
        envelopes: [groceries, clothing],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: groceries,
            allocatedCents: 120000,
            spentCents: 40000,
            availableCents: 80000,
            carryoverCents: 0,
          ),
          MonthlyEnvelopeData(
            envelope: clothing,
            allocatedCents: 40000,
            spentCents: 10000,
            availableCents: 30000,
            carryoverCents: 0,
          ),
        ],
        totalBudgetedCents: 160000,
        totalSpentCents: 50000,
        totalAvailableCents: 110000,
      ),
    ],
    totalIncomeCents: 250000,
    totalBudgetedCents: 160000,
    readyToAssignCents: 90000,
    year: 2026,
    month: 2,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RecentMovesScreen', () {
    testWidgets('renders tabs and filters moved vs assigned events', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith((ref, _) async {
            return _makeSummary();
          }),
          budgetGoalsProvider.overrideWith((ref, _) async => {}),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecentMovesScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            budgetId: _budgetId,
            envelopeId: _envelopeGroceriesId,
            amountCents: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            budgetId: _budgetId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountCents: 3000,
          );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Recent Moves'), findsWidgets);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Moved'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Clothing'), findsOneWidget);

      await tester.tap(find.text('Moved'));
      await tester.pumpAndSettle();
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Ready to Assign'), findsNothing);

      await tester.tap(find.text('Assigned'));
      await tester.pumpAndSettle();
      expect(find.text('Ready to Assign'), findsOneWidget);
    });

    testWidgets('shows envelope-specific move history', (tester) async {
      final container = ProviderContainer(
        overrides: [
          budgetMonthlySummaryProvider.overrideWith((ref, _) async {
            return _makeSummary();
          }),
          budgetGoalsProvider.overrideWith((ref, _) async => {}),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            budgetId: _budgetId,
            envelopeId: _envelopeGroceriesId,
            amountCents: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            budgetId: _budgetId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountCents: 3000,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const EnvelopeMovesScreen(
              budgetId: _budgetId,
              envelopeId: _envelopeGroceriesId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Moves'), findsOneWidget);
      expect(find.textContaining('Groceries'), findsWidgets);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsWidgets);
    });
  });
}

Future<void> _dismissCoachmarkIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got It!');
  if (gotIt.evaluate().isEmpty) return;
  await tester.tap(gotIt);
  await tester.pumpAndSettle();
}
