// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
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

  Widget buildSubject({String currencyCode = 'USD'}) {
    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/accounts/add',
      routes: [
        GoRoute(
          name: addAccountRoute,
          path: '/budgets/:id/accounts/add',
          builder: (context, state) =>
              AddAccountScreen(budgetId: state.pathParameters['id']!),
        ),
        GoRoute(
          name: accountListRoute,
          path: '/budgets/:id/accounts',
          builder: (_, __) => const Scaffold(body: Text('Account List')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => makeBudget(currencyCode: currencyCode),
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

  testWidgets('renders bank search entry step', (tester) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
    expect(find.text('Popular Options'), findsOneWidget);
    expect(find.text('Add an Unlinked Account'), findsOneWidget);
  });

  testWidgets('shows staged loading states before bank search', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.text('Search for your bank'), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Loading institutions...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Search for your bank'), findsOneWidget);
  });

  testWidgets('renders currency selector in unlinked account step', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(currencyCode: 'EUR'));
    await _pumpToBankSearch(tester);

    await tester.tap(find.text('Add an Unlinked Account'));
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('EUR (€)'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });

  testWidgets('account type picker can be opened from unlinked form', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await tester.tap(find.text('Add an Unlinked Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Select account type...'));
    await tester.pumpAndSettle();

    expect(find.text('Select Account Type'), findsOneWidget);
    expect(find.text('Cash Accounts'), findsOneWidget);
    expect(find.text('Credit Accounts'), findsOneWidget);
    expect(find.text('Mortgages and Loans'), findsOneWidget);
  });

  testWidgets('next stays disabled until type and balance are provided', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await _pumpToBankSearch(tester);

    await tester.tap(find.text('Add an Unlinked Account'));
    await tester.pumpAndSettle();

    var nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next'),
    );
    expect(nextButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'Daily');
    await tester.enterText(find.byType(TextField).at(1), '50000');
    await tester.pumpAndSettle();

    nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
    expect(nextButton.onPressed, isNull);

    await tester.tap(find.text('Select account type...'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checking'));
    await tester.pumpAndSettle();

    nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
    expect(nextButton.onPressed, isNotNull);
  });
}

Future<void> _pumpToBankSearch(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pumpAndSettle();
}
