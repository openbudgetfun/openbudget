// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

Account _makeAccount({
  String name = 'Checking',
  String accountType = 'checking',
  int balanceCents = 100000,
  String currencyCode = 'USD',
  bool onBudget = true,
  bool isClosed = false,
  int sortOrder = 0,
}) {
  return Account(
    name: name,
    accountType: accountType,
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: _budgetUuid,
    onBudget: onBudget,
    sortOrder: sortOrder,
    isClosed: isClosed,
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

    testWidgets('renders app bar with title and transfer button', (
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
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
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

    testWidgets('always shows FAB add button', (tester) async {
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

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
