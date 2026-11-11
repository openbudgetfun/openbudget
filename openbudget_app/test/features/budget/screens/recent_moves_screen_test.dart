import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = '00000000-0000-0000-0000-000000000111';
const _categoryId = '00000000-0000-0000-0000-000000000222';
const _envelopeGroceriesId = '00000000-0000-0000-0000-000000000333';
const _envelopeClothingId = '00000000-0000-0000-0000-000000000444';

BudgetSummary _makeSummary() {
  final ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000555');
  final entityId = UuidValue.fromString(_entityId);
  final categoryUuid = UuidValue.fromString(_categoryId);

  final groceries = Envelope(
    id: UuidValue.fromString(_envelopeGroceriesId),
    name: 'Groceries',
    categoryId: categoryUuid,
    budgetedAmountMinor: 120000,
    spentAmountMinor: 40000,
    currencyCode: 'USD',
    sortOrder: 0,
  );
  final clothing = Envelope(
    id: UuidValue.fromString(_envelopeClothingId),
    name: 'Clothing',
    categoryId: categoryUuid,
    budgetedAmountMinor: 40000,
    spentAmountMinor: 10000,
    currencyCode: 'USD',
    sortOrder: 1,
  );

  return BudgetSummary(
    budget: Budget(
      id: entityId,
      name: 'Family Plan',
      currencyCode: 'USD',
      ownerId: ownerId,
    ),
    categories: [
      CategoryWithEnvelopes(
        category: Category(
          id: categoryUuid,
          name: 'Needs',
          entityId: entityId,
          sortOrder: 0,
        ),
        envelopes: [groceries, clothing],
        monthlyEnvelopes: [
          MonthlyEnvelopeData(
            envelope: groceries,
            allocatedMinor: 120000,
            spentMinor: 40000,
            availableMinor: 80000,
            carryoverMinor: 0,
          ),
          MonthlyEnvelopeData(
            envelope: clothing,
            allocatedMinor: 40000,
            spentMinor: 10000,
            availableMinor: 30000,
            carryoverMinor: 0,
          ),
        ],
        totalBudgetedMinor: 160000,
        totalSpentMinor: 50000,
        totalAvailableMinor: 110000,
      ),
    ],
    totalIncomeMinor: 250000,
    totalBudgetedMinor: 160000,
    readyToAssignMinor: 90000,
    year: 2026,
    month: 2,
  );
}

void main() {
  group('RecentMovesScreen', () {
    testWidgets('renders tabs and filters moved vs assigned events', (
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecentMovesScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            entityId: _entityId,
            envelopeId: _envelopeGroceriesId,
            amountMinor: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            entityId: _entityId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountMinor: 3000,
          );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Recent Moves'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);
      expect(find.textContaining(DateTime.now().year.toString()), findsWidgets);
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
          budgetMonthlySummaryProvider.overrideWith(
            (ref, _) async => _makeSummary(),
          ),
          budgetGoalsProvider.overrideWith((ref, _) async => {}),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            entityId: _entityId,
            envelopeId: _envelopeGroceriesId,
            amountMinor: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            entityId: _entityId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountMinor: 3000,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const EnvelopeMovesScreen(
              entityId: _entityId,
              envelopeId: _envelopeGroceriesId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Moves'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.back,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Groceries'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.forward,
        ),
        findsWidgets,
      );
    });
  });
}

Future<void> _dismissCoachmarkIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got It!');
  if (gotIt.evaluate().isEmpty) return;
  await tester.tap(gotIt);
  await tester.pumpAndSettle();
}
