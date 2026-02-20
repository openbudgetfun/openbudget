// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_auto_post_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

  Budget makeBudget() => Budget(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    name: 'My Budget',
    currencyCode: 'USD',
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );

  BudgetSummary makeSummary({
    int readyToAssignCents = 50000,
    int totalIncomeCents = 100000,
    int totalBudgetedCents = 50000,
    List<CategoryWithEnvelopes> categories = const [],
  }) => BudgetSummary(
    budget: makeBudget(),
    categories: categories,
    totalIncomeCents: totalIncomeCents,
    totalBudgetedCents: totalBudgetedCents,
    readyToAssignCents: readyToAssignCents,
    year: 2026,
    month: 2,
  );

  Widget buildSubject({BudgetSummary? summary}) {
    return ProviderScope(
      overrides: [
        budgetMonthlySummaryProvider.overrideWith(
          (ref, id) async => summary ?? makeSummary(),
        ),
        creditCardPaymentsProvider.overrideWith(
          (ref, id) async => <CreditCardPaymentInfo>[],
        ),
        budgetGoalsProvider.overrideWith(
          (ref, id) async => <String, EnvelopeGoal>{},
        ),
        recurringDueCountProvider.overrideWith((ref, id) async => 0),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BudgetDetailScreen(budgetId: budgetId),
      ),
    );
  }

  group('BudgetDetailScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BudgetDetailScreen(budgetId: budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows budget name in app bar when data loads', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('My Budget'), findsOneWidget);
    });

    testWidgets('shows Copy Last Month button in header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Copy Last Month'), findsOneWidget);
    });

    testWidgets('tapping Copy Last Month shows confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
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
      await tester.pumpWidget(buildSubject());
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
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category_rounded), findsOneWidget);
    });

    testWidgets('shows Add Category button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Add Category'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Add Category'), findsOneWidget);
    });

    testWidgets('does not show old bottom action bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Bottom action bar removed in favor of shell tab navigation
      expect(find.text('Add Income'), findsNothing);
      expect(find.text('Add Expense'), findsNothing);
    });
  });
}
