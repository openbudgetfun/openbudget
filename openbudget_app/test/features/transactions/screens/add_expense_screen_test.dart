// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_last_envelope_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_match_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';
  final budgetUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );
  final ownerUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000099',
  );
  final categoryUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000020',
  );
  final envelopeUuid1 = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000030',
  );
  final envelopeUuid2 = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000031',
  );

  Budget makeBudget({String currencyCode = 'USD'}) => Budget(
    id: budgetUuid,
    name: 'My Budget',
    currencyCode: currencyCode,
    ownerId: ownerUuid,
    createdAt: DateTime(2026),
  );

  List<Payee> makePayees() => [
    Payee(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000010'),
      name: 'Grocery Store',
      budgetId: budgetUuid,
    ),
    Payee(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000011'),
      name: 'Coffee Shop',
      budgetId: budgetUuid,
    ),
  ];

  BudgetSummary makeSummary({List<CategoryWithEnvelopes>? categories}) =>
      BudgetSummary(
        budget: makeBudget(),
        categories:
            categories ??
            [
              CategoryWithEnvelopes(
                category: Category(
                  id: categoryUuid,
                  name: 'Essentials',
                  budgetId: budgetUuid,
                  sortOrder: 0,
                ),
                envelopes: [
                  Envelope(
                    id: envelopeUuid1,
                    name: 'Groceries',
                    categoryId: categoryUuid,
                    budgetedAmountCents: 50000,
                    spentAmountCents: 20000,
                    currencyCode: 'USD',
                    sortOrder: 0,
                  ),
                  Envelope(
                    id: envelopeUuid2,
                    name: 'Dining Out',
                    categoryId: categoryUuid,
                    budgetedAmountCents: 20000,
                    spentAmountCents: 5000,
                    currencyCode: 'USD',
                    sortOrder: 1,
                  ),
                ],
                monthlyEnvelopes: const [],
                totalBudgetedCents: 70000,
                totalSpentCents: 25000,
                totalAvailableCents: 45000,
              ),
            ],
        totalIncomeCents: 100000,
        totalBudgetedCents: 70000,
        readyToAssignCents: 30000,
        year: 2026,
        month: 2,
      );

  Widget buildSubject({
    Budget? budget,
    List<Payee>? payees,
    BudgetSummary? summary,
    String? Function(Ref, (String, String))? ruleMatchOverride,
    String? Function(Ref, (String, String))? payeeLastEnvelopeOverride,
  }) => ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => budget ?? makeBudget(),
        ),
        payeeListProvider.overrideWith(
          (ref, id) async => payees ?? makePayees(),
        ),
        budgetSummaryProvider.overrideWith(
          (ref, id) async => summary ?? makeSummary(),
        ),
        ruleMatchEnvelopeProvider.overrideWith(
          (ref, args) async =>
              ruleMatchOverride != null ? ruleMatchOverride(ref, args) : null,
        ),
        payeeLastEnvelopeProvider.overrideWith(
          (ref, args) async => payeeLastEnvelopeOverride != null
              ? payeeLastEnvelopeOverride(ref, args)
              : null,
        ),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AddExpenseScreen(budgetId: budgetId),
      ),
    );

  Widget buildRoutedSubject({
    Budget? budget,
    List<Payee>? payees,
    BudgetSummary? summary,
    String? Function(Ref, (String, String))? ruleMatchOverride,
    String? Function(Ref, (String, String))? payeeLastEnvelopeOverride,
  }) {
    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/expenses/add',
      routes: [
        GoRoute(
          name: planRoute,
          path: planPath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Plan Route'))),
        ),
        GoRoute(
          name: addExpenseRoute,
          path: addExpensePath,
          builder: (context, state) =>
              AddExpenseScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: addIncomeRoute,
          path: addIncomePath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Add Income Route'))),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => budget ?? makeBudget(),
        ),
        payeeListProvider.overrideWith(
          (ref, id) async => payees ?? makePayees(),
        ),
        budgetSummaryProvider.overrideWith(
          (ref, id) async => summary ?? makeSummary(),
        ),
        ruleMatchEnvelopeProvider.overrideWith(
          (ref, args) async =>
              ruleMatchOverride != null ? ruleMatchOverride(ref, args) : null,
        ),
        payeeLastEnvelopeProvider.overrideWith(
          (ref, args) async => payeeLastEnvelopeOverride != null
              ? payeeLastEnvelopeOverride(ref, args)
              : null,
        ),
      ],
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('AddExpenseScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AddExpenseScreen(budgetId: budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Add Expense title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Title in app bar + title text inside card.
      expect(find.text('Add Expense'), findsNWidgets(2));
    });

    testWidgets('shows expense icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    });

    testWidgets('shows cancel button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('shows description text field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('shows amount text field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Amount'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money_rounded), findsOneWidget);
    });

    testWidgets('shows payee dropdown with No Payee option', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Payee'), findsOneWidget);
      expect(find.byIcon(Icons.store_rounded), findsOneWidget);
      expect(find.text('No Payee'), findsOneWidget);
    });

    testWidgets('shows envelope dropdown with Unassigned option', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The envelope dropdown label and the default selected item.
      expect(find.text('Unassigned'), findsNWidgets(2));
      expect(find.byIcon(Icons.mail_outlined), findsOneWidget);
    });

    testWidgets('shows memo text field with hint', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Memo'), findsOneWidget);
      expect(find.byIcon(Icons.note_outlined), findsOneWidget);
      expect(find.text('Add a note (optional)'), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Save Transaction'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders payee dropdown items when payees available', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap the payee dropdown to open it.
      await tester.tap(find.text('No Payee'));
      await tester.pumpAndSettle();

      expect(find.text('Grocery Store'), findsOneWidget);
      expect(find.text('Coffee Shop'), findsOneWidget);
    });

    testWidgets('renders empty payee dropdown when no payees', (tester) async {
      await tester.pumpWidget(buildSubject(payees: []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No Payee'));
      await tester.pumpAndSettle();

      // Only the 'No Payee' option (selected + dropdown item).
      expect(find.text('No Payee'), findsNWidgets(2));
      expect(find.text('Grocery Store'), findsNothing);
    });

    testWidgets('renders envelope dropdown with category/envelope names', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap envelope dropdown to open it. Find by the mail icon area.
      final envelopeDropdowns = find.byType(DropdownButtonFormField<String>);
      // Second dropdown is the envelope dropdown.
      await tester.tap(envelopeDropdowns.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Essentials / Groceries'), findsOneWidget);
      expect(find.text('Essentials / Dining Out'), findsOneWidget);
    });

    testWidgets('renders empty envelope dropdown when no categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(summary: makeSummary(categories: [])),
      );
      await tester.pumpAndSettle();

      // Open the envelope dropdown.
      final envelopeDropdowns = find.byType(DropdownButtonFormField<String>);
      await tester.tap(envelopeDropdowns.at(1));
      await tester.pumpAndSettle();

      // Only 'Unassigned' option should be present.
      expect(find.text('Essentials / Groceries'), findsNothing);
    });

    testWidgets('can enter description text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final descField = find.widgetWithText(TextField, 'Description');
      await tester.enterText(descField, 'Weekly groceries');
      await tester.pumpAndSettle();

      expect(find.text('Weekly groceries'), findsOneWidget);
    });

    testWidgets('can enter amount text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final amountField = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountField, '42.50');
      await tester.pumpAndSettle();

      expect(find.text('42.50'), findsOneWidget);
    });

    testWidgets('shows negative amount hint in budget currency', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(budget: makeBudget(currencyCode: 'JPY')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('-¥0'), findsAtLeast(1));
    });

    testWidgets('can enter memo text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final memoField = find.widgetWithText(TextField, 'Memo');
      await tester.enterText(memoField, 'Bought vegetables');
      await tester.pumpAndSettle();

      expect(find.text('Bought vegetables'), findsOneWidget);
    });

    testWidgets('amount field has number keyboard with decimal', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final amountField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Amount'),
      );
      expect(amountField.keyboardType, isNotNull);
      expect(amountField.keyboardType.decimal, isTrue);
    });

    testWidgets('no auto-assign hint visible initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Auto-assigned by rule'), findsNothing);
      expect(
        find.text(
          'Envelope auto-suggested from last transaction with this payee',
        ),
        findsNothing,
      );
    });

    testWidgets('cancel navigates back to plan route', (tester) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('tapping Add Income mode navigates to add income route', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Income').first);
      await tester.pumpAndSettle();

      expect(find.text('Add Income Route'), findsOneWidget);
    });
  });
}
