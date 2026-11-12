import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const String _entityId = fixtureEntityId;

Account _makeAccount({
  String name = 'Checking',
  AccountKind kind = AccountKind.checking,
  int balanceMinor = 100000,
  String currencyCode = 'USD',
  bool onBudget = true,
  bool isClosed = false,
  int sortOrder = 0,
}) => testAccount(
  name: name,
  kind: kind,
  balanceMinor: balanceMinor,
  currencyCode: currencyCode,
  onBudget: onBudget,
  closedAt: isClosed ? DateTime.utc(2026, 8) : null,
);

NetWorthView _netWorth({
  int assetsMinor = 100000,
  int liabilitiesMinor = 0,
  List<NetWorthAccountRow> accounts = const [],
}) => NetWorthView(
  currencyCode: 'USD',
  asOf: DateTime.utc(2026, 9, 5),
  assetsMinor: assetsMinor,
  liabilitiesMinor: liabilitiesMinor,
  netWorthMinor: assetsMinor - liabilitiesMinor,
  isComplete: true,
  missingCurrencyCodes: const [],
  hasStaleRates: false,
  currencies: const [],
  entities: const [],
  accounts: accounts,
);

Widget _buildSubject({
  required List<Account> accounts,
  NetWorthView? netWorth,
  bool routed = false,
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/accounts',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (context, state) =>
            AccountListScreen(entityId: state.pathParameters['entityId']!),
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
      entityDetailProvider.overrideWith((ref, id) async => testEntity()),
      accountListProvider.overrideWith((ref, entityId) async => accounts),
      plaidConnectionsProvider.overrideWith((ref, entityId) async => const []),
      netWorthForEntitiesProvider.overrideWith(
        (ref, ids) async => netWorth ?? _netWorth(),
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

void main() {
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
            home: const AccountListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountListProvider.overrideWith(
              (ref, entityId) => throw Exception('Network error'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AccountListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load accounts'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('renders empty state with add account button', (tester) async {
      await tester.pumpWidget(_buildSubject(accounts: const []));
      await tester.pumpAndSettle();

      expect(find.text('No Accounts Yet'), findsOneWidget);
      expect(
        find.text('Add your first account to track balances'),
        findsOneWidget,
      );
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('renders app bar with title and quick action buttons', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(accounts: const []));
      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsOneWidget);
      expect(
        find.byKey(const Key('account-list-add-button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('account-list-more-button')),
        findsOneWidget,
      );
    });

    testWidgets('groups accounts into assets and liabilities', (tester) async {
      final accounts = [
        _makeAccount(name: 'Main Checking', balanceMinor: 250000),
        _makeAccount(
          name: 'Emergency Fund',
          kind: AccountKind.savings,
          balanceMinor: 500000,
          sortOrder: 1,
        ),
        _makeAccount(
          name: 'Credit Card',
          kind: AccountKind.creditCard,
          balanceMinor: -150000,
          sortOrder: 2,
        ),
      ];

      await tester.pumpWidget(
        _buildSubject(
          accounts: accounts,
          netWorth: _netWorth(
            assetsMinor: 750000,
            liabilitiesMinor: 150000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The totals card and the group headers share these labels.
      expect(find.text('Assets'), findsWidgets);
      expect(find.text('Main Checking'), findsOneWidget);
      expect(find.text('Emergency Fund'), findsOneWidget);
      // The liabilities section starts below the fold; the net worth
      // card also lists the account, so the row appears twice.
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(find.text('Liabilities'), findsWidgets);
      expect(find.text('Credit Card'), findsNWidgets(2));
    });

    testWidgets('renders closed accounts folded at the end', (tester) async {
      final accounts = [
        _makeAccount(name: 'Old Checking', isClosed: true),
        _makeAccount(name: 'Daily', sortOrder: 1),
      ];

      await tester.pumpWidget(_buildSubject(accounts: accounts));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Closed Accounts'),
        200,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(find.text('Closed Accounts'), findsOneWidget);
      expect(find.text('Old Checking'), findsOneWidget);
    });

    testWidgets('renders net worth card with assets and liabilities', (
      tester,
    ) async {
      final accounts = [
        _makeAccount(name: 'Bank', balanceMinor: 500000),
        _makeAccount(
          name: 'Credit Card',
          kind: AccountKind.creditCard,
          balanceMinor: -150000,
          sortOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _buildSubject(
          accounts: accounts,
          netWorth: _netWorth(
            assetsMinor: 500000,
            liabilitiesMinor: 150000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      // The totals card and the group headers both use these labels.
      expect(find.text('Assets'), findsWidgets);
      expect(find.text('Liabilities'), findsWidgets);
    });

    testWidgets('shows the base equivalent for a foreign account row', (
      tester,
    ) async {
      final accounts = [
        _makeAccount(name: 'EUR Checking', currencyCode: 'EUR'),
      ];

      await tester.pumpWidget(
        _buildSubject(
          accounts: accounts,
          netWorth: _netWorth(
            assetsMinor: 43160,
            accounts: [
              NetWorthAccountRow(
                accountId: UuidValue.fromString(fixtureAccountId),
                entityId: UuidValue.fromString(_entityId),
                name: 'EUR Checking',
                kind: AccountKind.checking,
                isLiability: false,
                currencyCode: 'EUR',
                balanceMinor: 100000,
                convertedMinor: 43160,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.text('EUR Checking'), findsOneWidget);
      // The net worth card renders the converted total for the row.
      expect(find.textContaining('in base currency'), findsOneWidget);
    });

    testWidgets('in-list add account button appears under the accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(accounts: [_makeAccount()]),
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
      await tester.pumpWidget(_buildSubject(accounts: const [], routed: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await tester.pumpAndSettle();

      expect(find.text('Add Account Route'), findsOneWidget);
    });

    testWidgets('top app bar add action navigates to add account route', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('account-list-add-button')));
      await tester.pumpAndSettle();

      expect(find.text('Add Account Route'), findsOneWidget);
    });

    testWidgets('transfer action navigates to transfer route', (tester) async {
      await tester.pumpWidget(
        _buildSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('account-list-more-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Route'), findsOneWidget);
    });

    testWidgets('settings action navigates to settings route', (tester) async {
      await tester.pumpWidget(
        _buildSubject(accounts: [_makeAccount(name: 'Daily')]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('account-list-more-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings Route'), findsOneWidget);
    });

    testWidgets('tapping account row navigates to account detail route', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          accounts: [
            _makeAccount(name: 'Daily Account'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily Account'));
      await tester.pumpAndSettle();

      expect(find.text('Account Detail $fixtureAccountId'), findsOneWidget);
    });
  });
}
