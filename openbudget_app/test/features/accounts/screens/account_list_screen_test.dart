// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

Account _makeAccount({
  UuidValue? id,
  String name = 'Checking',
  String accountType = 'checking',
  int balanceCents = 100000,
  String currencyCode = 'USD',
  bool onBudget = true,
  bool isClosed = false,
  int sortOrder = 0,
}) => Account(
    id: id,
    name: name,
    accountType: accountType,
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: _budgetUuid,
    onBudget: onBudget,
    sortOrder: sortOrder,
    isClosed: isClosed,
  );

Widget _buildRoutedSubject({required List<Account> accounts}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (context, state) =>
            AccountListScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: addAccountRoute,
        path: addAccountPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Add Account Route'))),
      ),
      GoRoute(
        name: createTransferRoute,
        path: createTransferPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Transfer Route'))),
      ),
      GoRoute(
        name: transactionListRoute,
        path: transactionListPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Transactions Route'))),
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Settings Route'))),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('Account Detail ${state.pathParameters['accountId']!}'),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountListProvider.overrideWith((ref, budgetId) async => accounts),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AccountListScreen', () {
    testWidgets('renders loading indicator while accounts load', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith(
              (ref, budgetId) => throw Exception('Network error'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load accounts'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty state with add account button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith(
              (ref, budgetId) async => <Account>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Accounts Yet'), findsOneWidget);
      expect(
        find.text('Add your first account to track balances'),
        findsOneWidget,
      );
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
    });

    testWidgets('renders app bar with title and quick action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith(
              (ref, budgetId) async => <Account>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('renders on-budget accounts section', (tester) async {
      final accounts = [
        _makeAccount(name: 'Main Checking', balanceCents: 250000),
        _makeAccount(
          name: 'Emergency Fund',
          accountType: 'savings',
          balanceCents: 500000,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budget Accounts'), findsOneWidget);
      expect(find.text('Main Checking'), findsOneWidget);
      expect(find.text('Emergency Fund'), findsOneWidget);
    });

    testWidgets('renders off-budget accounts section', (tester) async {
      final accounts = [
        _makeAccount(
          name: 'Brokerage',
          accountType: 'investment',
          balanceCents: 1500000,
          onBudget: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tracking Accounts'), findsOneWidget);
      expect(find.text('Brokerage'), findsOneWidget);
    });

    testWidgets('renders closed accounts section', (tester) async {
      final accounts = [_makeAccount(name: 'Old Checking', isClosed: true)];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Closed Accounts'), findsOneWidget);
      expect(find.text('Old Checking'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('renders net worth card with assets and liabilities', (
      tester,
    ) async {
      final accounts = [
        _makeAccount(name: 'Bank', balanceCents: 500000),
        _makeAccount(
          name: 'Credit Card',
          accountType: 'creditCard',
          balanceCents: -150000,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('Assets'), findsOneWidget);
      expect(find.text('Liabilities'), findsOneWidget);
    });

    testWidgets('renders account type labels correctly', (tester) async {
      final accounts = [
        _makeAccount(name: 'My Checking'),
        _makeAccount(name: 'My Savings', accountType: 'savings', sortOrder: 1),
        _makeAccount(
          name: 'My Credit Card',
          accountType: 'creditCard',
          balanceCents: -50000,
          sortOrder: 2,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checking'), findsOneWidget);
      expect(find.text('Savings'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Credit Card'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Credit Card'), findsOneWidget);
    });

    testWidgets('renders all three sections when mixed accounts exist', (
      tester,
    ) async {
      final accounts = [
        _makeAccount(name: 'On Budget Account'),
        _makeAccount(name: 'Off Budget Account', onBudget: false, sortOrder: 1),
        _makeAccount(name: 'Closed Account', isClosed: true, sortOrder: 2),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Budget Accounts'), findsOneWidget);
      expect(find.text('Tracking Accounts'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Closed Accounts'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Closed Accounts'), findsOneWidget);
      expect(find.text('On Budget Account'), findsOneWidget);
      expect(find.text('Off Budget Account'), findsOneWidget);
      expect(find.text('Closed Account'), findsOneWidget);
    });

    testWidgets('renders multi-currency totals in headers and net worth', (
      tester,
    ) async {
      final accounts = [
        _makeAccount(name: 'USD Checking'),
        _makeAccount(
          name: 'EUR Checking',
          balanceCents: 200000,
          currencyCode: 'EUR',
          sortOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('USD'), findsWidgets);
      expect(find.textContaining('EUR'), findsWidgets);
      expect(find.text('USD Checking'), findsOneWidget);
      expect(find.text('EUR Checking'), findsOneWidget);
    });

    testWidgets('notification banner can be dismissed', (tester) async {
      await tester.pumpWidget(
        _buildRoutedSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsNothing);
    });

    testWidgets('always shows in-list add account button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith(
              (ref, budgetId) async => [_makeAccount()],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'Add Account'),
        findsOneWidget,
      );
    });

    testWidgets('empty-state Add Account button navigates to add account', (
      tester,
    ) async {
      await tester.pumpWidget(_buildRoutedSubject(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('Add Account Route'), findsOneWidget);
    });

    testWidgets('top app bar add action navigates to add account route', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildRoutedSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Add Account Route'), findsOneWidget);
    });

    testWidgets('transfer action navigates to transfer route', (tester) async {
      await tester.pumpWidget(
        _buildRoutedSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Route'), findsOneWidget);
    });

    testWidgets('settings action navigates to settings route', (tester) async {
      await tester.pumpWidget(
        _buildRoutedSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Route'), findsOneWidget);
    });

    testWidgets('all transactions row navigates to transactions route', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildRoutedSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All transactions'));
      await tester.pumpAndSettle();

      expect(find.text('Transactions Route'), findsOneWidget);
    });

    testWidgets('tapping account row navigates to account detail route', (
      tester,
    ) async {
      final accountId = UuidValue.fromString(
        '00000000-0000-0000-0000-000000000111',
      );
      await tester.pumpWidget(
        _buildRoutedSubject(
          accounts: [_makeAccount(name: 'Daily Account', id: accountId)],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily Account'));
      await tester.pumpAndSettle();

      expect(find.text('Account Detail $accountId'), findsOneWidget);
    });
  });
}
