import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

/// Pumps the plan screen with every server-backed provider overridden, so
/// it renders the fixture month view without a client.
Widget _buildSubject({Future<BudgetMonthView>? monthView}) => ProviderScope(
  overrides: [
    budgetMonthProvider(fixtureEntityId).overrideWith(
      (ref) => monthView ?? Future.value(testMonthView()),
    ),
    entityDetailProvider(fixtureEntityId).overrideWith(
      (ref) async => testEntity(name: 'My Budget'),
    ),
    creditCardPaymentsProvider(fixtureEntityId).overrideWith(
      (ref) async => const <CreditCardPaymentInfo>[],
    ),
    recurringDueCountProvider(fixtureEntityId).overrideWith((ref) async => 0),
    reviewQueueProvider(fixtureEntityId).overrideWith(
      (ref) async => const <TransactionView>[],
    ),
    ageOfMoneyProvider(fixtureEntityId).overrideWith((ref) async => 12),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const BudgetDetailScreen(entityId: fixtureEntityId),
  ),
);

void main() {
  group('BudgetDetailScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      final never = Completer<BudgetMonthView>();
      await tester.pumpWidget(
        _buildSubject(monthView: never.future),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
    });

    testWidgets('shows budget name in app bar when data loads', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('My Budget'), findsOneWidget);
    });

    testWidgets('shows Copy Last Month button in header', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Copy Last Month'), findsOneWidget);
    });

    testWidgets('tapping Copy Last Month shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Last Month'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Copy all budget allocations from last month to the current '
          'month? This will overwrite any existing allocations.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      // Header button + dialog title + dialog confirm button
      expect(find.text('Copy Last Month'), findsNWidgets(3));
    });

    testWidgets('dismissing Copy Last Month dialog via Cancel does nothing', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy Last Month'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog is dismissed, no snackbar
      expect(
        find.text(
          'Copy all budget allocations from last month to the current '
          'month? This will overwrite any existing allocations.',
        ),
        findsNothing,
      );
      expect(find.text('Allocations copied from previous month'), findsNothing);
    });

    testWidgets('shows empty state when no categories', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          monthView: Future.value(
            testMonthView(
              summary: testMonthSummary(
                incomeMinor: 100000,
                allocatedMinor: 50000,
                readyToAssignMinor: 0,
              ),
              categories: [],
              envelopes: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Categories Yet'), findsOneWidget);
    });

    testWidgets('shows Add Category button', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Add Category'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Add Category'), findsOneWidget);
    });

    testWidgets('does not show old bottom action bar', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // Bottom action bar removed in favor of shell tab navigation
      expect(find.text('Add Income'), findsNothing);
      expect(find.text('Add Expense'), findsNothing);
    });

    testWidgets('shows add accounts onboarding card when there is no income', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          monthView: Future.value(
            testMonthView(
              summary: testMonthSummary(
                incomeMinor: 0,
                allocatedMinor: 0,
                readyToAssignMinor: 0,
              ),
              categories: [],
              envelopes: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start working with real numbers'), findsOneWidget);
      expect(find.text('Add Accounts'), findsOneWidget);
      expect(find.text('Copy Last Month'), findsNothing);
    });

    testWidgets(
      'shows assign money onboarding card when money is ready but unassigned',
      (tester) async {
        await tester.pumpWidget(
          _buildSubject(
            monthView: Future.value(
              testMonthView(
                summary: testMonthSummary(
                  incomeMinor: 5000000,
                  allocatedMinor: 0,
                  readyToAssignMinor: 5000000,
                ),
                categories: [],
                envelopes: [],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Assign Your'), findsOneWidget);
        expect(find.text('Assign Money'), findsOneWidget);
        expect(find.text('Add Another Account'), findsOneWidget);
      },
    );

    testWidgets('shows finish onboarding card when budgeting has started', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Spend with confidence and clarity'), findsOneWidget);
      expect(find.text('Finish Onboarding'), findsOneWidget);
    });

    testWidgets('renders spotlight priorities and summary cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          monthView: Future.value(testMonthView(month: 202602)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spotlight'));
      await tester.pumpAndSettle();

      expect(find.text('Top Priorities'), findsOneWidget);
      expect(find.text('Add Priorities'), findsOneWidget);
      expect(find.text('February Summary'), findsOneWidget);
      expect(find.text('Total Targets'), findsOneWidget);
      expect(find.text('Underfunded'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Spent'), findsOneWidget);
    });
  });
}
