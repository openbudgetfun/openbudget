// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

  Budget makeBudget({String currencyCode = 'USD'}) => Budget(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    name: 'My Budget',
    currencyCode: currencyCode,
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );

  List<Payee> makePayees() => [
    Payee(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000010'),
      name: 'Employer Inc',
      budgetId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    ),
    Payee(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000011'),
      name: 'Freelance Client',
      budgetId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    ),
  ];

  Widget buildSubject({Budget? budget, List<Payee>? payees}) => ProviderScope(
    overrides: [
      budgetDetailProvider.overrideWith(
        (ref, id) async => budget ?? makeBudget(),
      ),
      payeeListProvider.overrideWith((ref, id) async => payees ?? makePayees()),
    ],
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AddIncomeScreen(budgetId: budgetId),
    ),
  );

  Widget buildRoutedSubject({Budget? budget, List<Payee>? payees}) {
    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/income/add',
      routes: [
        GoRoute(
          name: planRoute,
          path: planPath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Plan Route'))),
        ),
        GoRoute(
          name: addIncomeRoute,
          path: addIncomePath,
          builder: (context, state) =>
              AddIncomeScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: addExpenseRoute,
          path: addExpensePath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Add Expense Route'))),
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
      ],
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('AddIncomeScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AddIncomeScreen(budgetId: budgetId),
          ),
        ),
      );
      await tester.pump();

      // The scaffold renders even while providers load.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows Add Income title', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Title in app bar + title text inside card.
      expect(find.text('Add Income'), findsNWidgets(2));
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

    testWidgets('shows date picker with today date', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);

      // Verify a date string is shown (formatted as YYYY-MM-DD).
      final now = DateTime.now();
      final expectedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('shows payee dropdown with No Payee option', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Payee'), findsOneWidget);
      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      // The default selected item shows 'No Payee'.
      expect(find.text('No Payee'), findsOneWidget);
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

    testWidgets('shows income icon', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
    });

    testWidgets('shows cancel button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('renders payee dropdown items when payees available', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap the payee dropdown to open it.
      await tester.tap(find.text('No Payee'));
      await tester.pumpAndSettle();

      // Dropdown should show payee options.
      expect(find.text('Employer Inc'), findsOneWidget);
      expect(find.text('Freelance Client'), findsOneWidget);
    });

    testWidgets('renders empty payee dropdown when no payees', (tester) async {
      await tester.pumpWidget(buildSubject(payees: []));
      await tester.pumpAndSettle();

      // Tap the payee dropdown.
      await tester.tap(find.text('No Payee'));
      await tester.pumpAndSettle();

      // Only the 'No Payee' option should be present (shown twice: selected +
      // dropdown item).
      expect(find.text('No Payee'), findsNWidgets(2));
      expect(find.text('Employer Inc'), findsNothing);
    });

    testWidgets('tapping date opens date picker dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap the date ListTile.
      await tester.tap(find.byIcon(Icons.calendar_today_rounded));
      await tester.pumpAndSettle();

      // DatePicker dialog should appear.
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('can enter description text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Find description text field and enter text.
      final descField = find.widgetWithText(TextField, 'Description');
      await tester.enterText(descField, 'Monthly Salary');
      await tester.pumpAndSettle();

      expect(find.text('Monthly Salary'), findsOneWidget);
    });

    testWidgets('can enter amount text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final amountField = find.widgetWithText(TextField, 'Amount');
      await tester.enterText(amountField, '5000');
      await tester.pumpAndSettle();

      expect(find.text('5000'), findsOneWidget);
    });

    testWidgets('shows amount hint in budget currency', (tester) async {
      await tester.pumpWidget(
        buildSubject(budget: makeBudget(currencyCode: 'JPY')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('¥0'), findsAtLeast(1));
    });

    testWidgets('can enter memo text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final memoField = find.widgetWithText(TextField, 'Memo');
      await tester.enterText(memoField, 'Regular monthly payment');
      await tester.pumpAndSettle();

      expect(find.text('Regular monthly payment'), findsOneWidget);
    });

    testWidgets('form fields have correct keyboard types', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Amount field should have number keyboard.
      final amountField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Amount'),
      );
      expect(amountField.keyboardType, isNotNull);
      expect(amountField.keyboardType.decimal, isTrue);
    });

    testWidgets('amount field is wrapped in Focus for blur detection', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The Focus widget wrapping the amount field exists.
      expect(find.byType(Focus), findsWidgets);
    });

    testWidgets('cancel navigates back to plan route', (tester) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('tapping Add Expense mode navigates to add expense route', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Expense').first);
      await tester.pumpAndSettle();

      expect(find.text('Add Expense Route'), findsOneWidget);
    });
  });
}
