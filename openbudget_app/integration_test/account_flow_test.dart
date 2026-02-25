import 'dart:async';

// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

import 'helpers/screenshot_capture.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
const _addAccountUnlinkedButtonKey = Key('add-account-add-unlinked-button');
const _addAccountUnlinkedScrollKey = Key('add-account-unlinked-scroll');
const _addAccountNicknameFieldKey = Key('add-account-unlinked-nickname-field');
const _addAccountTypeTileKey = Key('add-account-unlinked-type-tile');
const _addAccountBalanceFieldKey = Key('add-account-unlinked-balance-field');
const _addAccountCheckingTypeKey = ValueKey('add-account-type-option-checking');

Account _makeAccount({
  required String name,
  required int balanceCents,
  required String currencyCode,
  UuidValue? id,
  String accountType = 'checking',
  bool onBudget = true,
  bool isClosed = false,
}) {
  return Account(
    id: id,
    name: name,
    accountType: accountType,
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: _budgetUuid,
    onBudget: onBudget,
    sortOrder: 0,
    isClosed: isClosed,
  );
}

Budget _makeBudget({String currencyCode = 'USD'}) {
  return Budget(
    id: _budgetUuid,
    name: 'OpenBudget',
    currencyCode: currencyCode,
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );
}

BudgetSummary _makeSummary({String currencyCode = 'USD'}) {
  return BudgetSummary(
    budget: _makeBudget(currencyCode: currencyCode),
    categories: const [],
    totalIncomeCents: 0,
    totalBudgetedCents: 0,
    readyToAssignCents: 0,
    year: 2026,
    month: 9,
  );
}

Transaction _makeTransaction({
  required String id,
  required UuidValue accountId,
  required String description,
  required int amountCents,
  bool cleared = false,
  bool reconciled = false,
  DateTime? transactionDate,
}) {
  return Transaction(
    id: UuidValue.fromString(id),
    description: description,
    amountCents: amountCents,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    accountId: accountId,
    transactionDate: transactionDate ?? DateTime(2026, 9, 3),
    cleared: cleared,
    reconciled: reconciled,
  );
}

class _FakeAccountActions extends AccountActions {
  @override
  FutureOr<void> build() {}

  @override
  Future<Account> createAccount({
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required String budgetId,
    required bool onBudget,
    required int sortOrder,
  }) async {
    return Account(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000777'),
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: _budgetUuid,
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: false,
    );
  }
}

Widget _buildApp({
  required List<Account> accounts,
  List<Transaction> accountTransactions = const [],
  String budgetCurrencyCode = 'USD',
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: '/budgets/:id/accounts',
        builder: (context, state) =>
            AccountListScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: addAccountRoute,
        path: '/budgets/:id/accounts/add',
        builder: (context, state) =>
            AddAccountScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: '/budgets/:id/accounts/:accountId',
        builder: (context, state) => AccountDetailScreen(
          budgetId: state.pathParameters['id']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountActionsProvider.overrideWith(_FakeAccountActions.new),
      accountListProvider.overrideWith((ref, budgetId) async => accounts),
      accountTransactionsProvider.overrideWith(
        (ref, args) async => accountTransactions,
      ),
      payeeListProvider.overrideWith((ref, budgetId) async => const []),
      budgetSummaryProvider.overrideWith(
        (ref, budgetId) async => _makeSummary(currencyCode: budgetCurrencyCode),
      ),
      budgetDetailProvider.overrideWith(
        (ref, budgetId) async => _makeBudget(currencyCode: budgetCurrencyCode),
      ),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  patrolWidgetTest('shows mixed-currency summaries in accounts view', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
          _makeAccount(
            name: 'Savings EUR',
            balanceCents: 100000,
            currencyCode: 'EUR',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily USD'), findsOneWidget);
    expect(find.text('Savings EUR'), findsOneWidget);
    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('EUR'), findsWidgets);
  });

  patrolWidgetTest('empty accounts flow navigates through add account wizard', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    expect(find.text('No Accounts Yet'), findsOneWidget);
    await tester.tap(find.text('Add Account'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('Loading institutions...'), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'add-accounts-loading-institutions-screen',
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
    await _ensureAddUnlinkedVisible(tester);
    expect(find.textContaining('Unlinked Account'), findsWidgets);
    await captureIntegrationScreenshot(tester, 'add-accounts-search-screen');

    await _tapAddUnlinkedAccount(tester);
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
  });

  patrolWidgetTest('bank search shortcut moves user to unlinked account flow', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Account'));
    await _pumpToAddAccountSearch(tester);

    await tester.enterText(find.byType(TextField).first, 'citi');
    await tester.pumpAndSettle();

    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('Citi'), findsOneWidget);
    expect(find.text('Chase'), findsNothing);

    await tester.tap(find.text('Citi'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(
      find.textContaining('Linked connections for "Citi" are coming soon'),
      findsOneWidget,
    );
  });

  patrolWidgetTest('submitting search query keeps user in bank search mode', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Account'));
    await _pumpToAddAccountSearch(tester);

    await tester.enterText(find.byType(TextField).first, 'citi');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Search for your bank'), findsOneWidget);
    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('Citi'), findsOneWidget);
    expect(find.text('Add Unlinked Account'), findsNothing);
    expect(find.textContaining('Linked connections for "citi"'), findsNothing);
    await captureIntegrationScreenshot(
      tester,
      'add-accounts-search-submit-results',
    );
  });

  patrolWidgetTest(
    'desktop add accounts flow shows search controls and options',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      expect(find.text('No Accounts Yet'), findsOneWidget);
      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);

      expect(find.text('Search for your bank'), findsOneWidget);
      expect(find.text('Search by institution name'), findsOneWidget);
      expect(
        find.text('Search by institution name or web address (URL)'),
        findsOneWidget,
      );
      expect(find.text('Popular Options'), findsOneWidget);
      expect(find.text('Chase'), findsOneWidget);
      expect(find.text('Capital One'), findsOneWidget);
      await _ensureAddUnlinkedVisible(tester);
      expect(find.byKey(_addAccountUnlinkedButtonKey), findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'add-accounts-search-desktop-screen',
      );
    },
  );

  patrolWidgetTest(
    'desktop add accounts search filters institutions to matching results',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);

      await tester.enterText(find.byType(TextField).first, 'citi');
      await tester.pumpAndSettle();

      expect(find.text('Search Results'), findsOneWidget);
      expect(find.text('Citi'), findsOneWidget);
      expect(find.text('Chase'), findsNothing);
      await _ensureAddUnlinkedVisible(tester);
      expect(find.byKey(_addAccountUnlinkedButtonKey), findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'add-accounts-search-desktop-citi-results-screen',
      );
    },
  );

  patrolWidgetTest('desktop add accounts search shows empty-results guidance', (
    $,
  ) async {
    final tester = $.tester;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Account'));
    await _pumpToAddAccountSearch(tester);

    await tester.enterText(find.byType(TextField).first, 'no-bank-here');
    await tester.pumpAndSettle();

    expect(find.text('Search Results'), findsOneWidget);
    expect(
      find.text('Search by institution name or web address (URL)'),
      findsOneWidget,
    );
    expect(
      find.text(
        'No institutions found. Try another name or add an unlinked account.',
      ),
      findsOneWidget,
    );
    expect(find.text('Citi'), findsNothing);
    await _ensureAddUnlinkedVisible(tester);
    expect(find.byKey(_addAccountUnlinkedButtonKey), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'add-accounts-search-desktop-empty-results-screen',
    );
  });

  patrolWidgetTest(
    'desktop linked bank tap shows loading overlay before fallback',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);

      await tester.enterText(find.byType(TextField).first, 'citi');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Citi'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      expect(find.text('Loading institutions...'), findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'add-accounts-loading-overlay-desktop-screen',
      );

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(find.text('Loading institutions...'), findsNothing);
      expect(find.text('Add Unlinked Account'), findsOneWidget);
      expect(
        find.textContaining('Linked connections for "Citi" are coming soon'),
        findsOneWidget,
      );
    },
  );

  patrolWidgetTest(
    'unlinked account requires explicit type selection before next',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);
      await _tapAddUnlinkedAccount(tester);
      await tester.pumpAndSettle();

      var nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountNicknameFieldKey),
        'Daily',
      );
      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountBalanceFieldKey),
        '50000',
      );
      await tester.pumpAndSettle();

      nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
      expect(nextButton.onPressed, isNull);

      await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
      await captureIntegrationScreenshot(tester, 'add-account-type-selection');
      await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
      await tester.pumpAndSettle();

      nextButton = tester.widget(find.widgetWithText(FilledButton, 'Next'));
      expect(nextButton.onPressed, isNotNull);
    },
  );

  patrolWidgetTest(
    'unlinked account submit shows success and returns to accounts',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);
      await _tapAddUnlinkedAccount(tester);
      await tester.pumpAndSettle();

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountNicknameFieldKey),
        'Daily',
      );
      await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
      await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
      await tester.pumpAndSettle();
      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountBalanceFieldKey),
        '50000',
      );
      await tester.pumpAndSettle();

      final nextButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Next'),
      );
      expect(nextButton.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Success!'), findsOneWidget);
      expect(find.text('Add Another'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Done'));
      await tester.pumpAndSettle();

      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('No Accounts Yet'), findsOneWidget);
    },
  );

  patrolWidgetTest('desktop unlinked account flow submits successfully', (
    $,
  ) async {
    final tester = $.tester;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Account'));
    await _pumpToAddAccountSearch(tester);
    await _tapAddUnlinkedAccount(tester);
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(find.textContaining("Let's go!"), findsOneWidget);
    expect(find.text('Give it a nickname'), findsOneWidget);
    expect(find.text('What type of account are you adding?'), findsOneWidget);
    final introDy = tester.getTopLeft(find.textContaining("Let's go!")).dy;
    final nicknameFieldDy = tester
        .getTopLeft(find.byKey(_addAccountNicknameFieldKey))
        .dy;
    final accountTypeTileDy = tester
        .getTopLeft(find.byKey(_addAccountTypeTileKey))
        .dy;
    expect(introDy, greaterThan(56));
    expect(introDy, lessThan(nicknameFieldDy));
    expect(nicknameFieldDy, lessThan(accountTypeTileDy));
    expect(accountTypeTileDy, lessThan(520));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(
      tester,
      'add-unlinked-account-desktop-form-screen',
    );

    await _enterTextWhenVisible(
      tester,
      find.byKey(_addAccountNicknameFieldKey),
      'Daily',
    );
    await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
    await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
    await tester.pumpAndSettle();
    await _enterTextWhenVisible(
      tester,
      find.byKey(_addAccountBalanceFieldKey),
      '50000',
    );
    await tester.pumpAndSettle();
    await captureIntegrationScreenshot(
      tester,
      'add-unlinked-account-desktop-filled-screen',
    );

    final nextButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next'),
    );
    expect(nextButton.onPressed, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Success!'), findsOneWidget);
    expect(find.text('Add Another'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'add-unlinked-account-desktop-success-screen',
    );
  });

  patrolWidgetTest(
    'desktop unlinked account next button stays gated until required fields are complete',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);
      await _tapAddUnlinkedAccount(tester);
      await tester.pumpAndSettle();

      final nextFinder = find.widgetWithText(FilledButton, 'Next');

      var nextButton = tester.widget<FilledButton>(nextFinder);
      expect(nextButton.onPressed, isNull);
      expect(find.text('Currency'), findsNothing);
      expect(find.text(r'USD ($)'), findsNothing);

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountNicknameFieldKey),
        'Daily',
      );
      await tester.pumpAndSettle();
      nextButton = tester.widget(nextFinder);
      expect(nextButton.onPressed, isNull);

      await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
      await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
      await tester.pumpAndSettle();
      nextButton = tester.widget(nextFinder);
      expect(nextButton.onPressed, isNull);

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountBalanceFieldKey),
        '50000',
      );
      await tester.pumpAndSettle();
      nextButton = tester.widget(nextFinder);
      expect(nextButton.onPressed, isNotNull);

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountBalanceFieldKey),
        '',
      );
      await tester.pumpAndSettle();
      nextButton = tester.widget(nextFinder);
      expect(nextButton.onPressed, isNull);
    },
  );

  patrolWidgetTest(
    'desktop unlinked account resets scroll position across step transitions',
    ($) async {
      final tester = $.tester;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1024, 460));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);
      await _tapAddUnlinkedAccount(tester);
      await tester.pumpAndSettle();

      final introFinder = find.textContaining("Let's go!");
      expect(introFinder, findsOneWidget);
      final introTopBeforeScroll = tester.getTopLeft(introFinder).dy;

      await tester.drag(
        find.byKey(_addAccountUnlinkedScrollKey),
        const Offset(0, -320),
      );
      await tester.pumpAndSettle();
      final introTopAfterManualScroll = tester.getTopLeft(introFinder).dy;
      expect(introTopAfterManualScroll, lessThan(introTopBeforeScroll));

      await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
      await tester.pumpAndSettle();
      await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
      await tester.pumpAndSettle();

      final introTopAfterTypeReturn = tester.getTopLeft(introFinder).dy;
      expect(introTopAfterTypeReturn, greaterThan(introTopAfterManualScroll));

      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountNicknameFieldKey),
        'Daily',
      );
      await _enterTextWhenVisible(
        tester,
        find.byKey(_addAccountBalanceFieldKey),
        '50000',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();

      expect(find.text('Success!'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add Another'));
      await tester.pumpAndSettle();

      expect(find.text('Add Unlinked Account'), findsOneWidget);
      final introTopAfterAddAnother = tester.getTopLeft(introFinder).dy;
      expect(introTopAfterAddAnother, greaterThan(introTopAfterManualScroll));
      await captureIntegrationScreenshot(
        tester,
        'add-unlinked-account-desktop-reset-screen',
      );
    },
  );

  patrolWidgetTest('account detail flow navigates to detail and back to list', (
    $,
  ) async {
    final tester = $.tester;
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000111',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          Transaction(
            id: UuidValue.fromString('00000000-0000-0000-0000-000000000211'),
            description: 'Rent',
            amountCents: -280000,
            currencyCode: 'USD',
            budgetId: _budgetUuid,
            accountId: accountId,
            transactionDate: DateTime(2026, 9, 3),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Daily USD'), findsOneWidget);
  });

  patrolWidgetTest(
    'account detail overflow menu toggles reconciled visibility',
    ($) async {
      final tester = $.tester;
      final accountId = UuidValue.fromString(
        '00000000-0000-0000-0000-000000000111',
      );
      await tester.pumpWidget(
        _buildApp(
          accounts: [
            _makeAccount(
              id: accountId,
              name: 'Daily USD',
              balanceCents: 250000,
              currencyCode: 'USD',
            ),
          ],
          accountTransactions: [
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000211',
              accountId: accountId,
              description: 'Self storage',
              amountCents: -3000,
            ),
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000212',
              accountId: accountId,
              description: 'Starting Balance',
              amountCents: 5000000,
              reconciled: true,
              transactionDate: DateTime(2026, 9, 2),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily USD'));
      await tester.pumpAndSettle();
      expect(find.text('Starting Balance'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Reconciled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Starting Balance'), findsNothing);
      expect(find.text('Self storage'), findsOneWidget);

      await tester.tap(find.textContaining('uncleared transactions'));
      await tester.pumpAndSettle();
      expect(find.text('Self storage'), findsOneWidget);
    },
  );

  patrolWidgetTest('account detail edit flow opens full-screen account form', (
    $,
  ) async {
    final tester = $.tester;
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000122',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000512',
            accountId: accountId,
            description: 'Gym',
            amountCents: -15000,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Account'));
    await tester.pumpAndSettle();

    expect(find.text('Account Nickname'), findsOneWidget);
    expect(find.text('Account Notes'), findsOneWidget);
    expect(find.text('Working Balance'), findsWidgets);
    expect(find.text('Link an Account'), findsOneWidget);
    expect(find.text('Close Account'), findsOneWidget);
  });

  patrolWidgetTest(
    'closed account edit dialog exposes delete and reopen actions',
    ($) async {
      final tester = $.tester;
      final accountId = UuidValue.fromString(
        '00000000-0000-0000-0000-000000000113',
      );
      await tester.pumpWidget(
        _buildApp(
          accounts: [
            _makeAccount(
              id: accountId,
              name: 'Loan',
              balanceCents: -50000,
              currencyCode: 'USD',
              onBudget: false,
              isClosed: true,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Loan'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Delete Permanently', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Reopen Account', skipOffstage: false), findsOneWidget);
    },
  );

  patrolWidgetTest('reconcile action opens balance match prompt', ($) async {
    final tester = $.tester;
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000114',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000311',
            accountId: accountId,
            description: 'Rent',
            amountCents: -280000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reconcile'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Does this match your bank balance'),
      findsOneWidget,
    );
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  patrolWidgetTest('desktop account menu supports reconcile and edit flows', (
    $,
  ) async {
    final tester = $.tester;
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000116',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 5222000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000611',
            accountId: accountId,
            description: 'Landlord',
            amountCents: -10000,
            cleared: true,
          ),
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000612',
            accountId: accountId,
            description: 'Supermarket',
            amountCents: -50000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reconcile'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Does this match your bank balance'),
      findsOneWidget,
    );
    await captureIntegrationScreenshot(
      tester,
      'accounts-reconcile-dialog-desktop-screen',
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Account'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Account'), findsOneWidget);
    expect(find.text('Account Nickname'), findsOneWidget);
    expect(find.text('Account Notes'), findsOneWidget);
    expect(find.text('Working Balance'), findsWidgets);
    await captureIntegrationScreenshot(
      tester,
      'accounts-edit-account-desktop-screen',
    );
  });

  patrolWidgetTest('loan account shows overview and activity tabs', ($) async {
    final tester = $.tester;
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000115',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Loan',
            accountType: 'other',
            balanceCents: -125,
            currencyCode: 'USD',
            onBudget: false,
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000411',
            accountId: accountId,
            description: 'Payment from Daily',
            amountCents: 50000,
            transactionDate: DateTime(2026, 9, 4),
          ),
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000412',
            accountId: accountId,
            description: 'Initial Balance',
            amountCents: -50000,
            transactionDate: DateTime(2026, 9, 3),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Loan'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Loan Payoff Overview'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Create Target'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Target'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '600');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Target'), findsOneWidget);

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();

    expect(find.text('Payment from Daily'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
  });
}

Future<void> _tapWhenVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      await tester.tap(finder.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      return;
    }

    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      final scrollOffset = attempt.isEven
          ? const Offset(0, 280)
          : const Offset(0, -280);
      await tester.drag(scrollable.first, scrollOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }

    await tester.pump(const Duration(milliseconds: 120));
  }

  expect(finder, findsOneWidget);
}

Future<void> _activateListTile(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      final tile = tester.widget<ListTile>(finder.first);
      final onTap = tile.onTap;
      expect(onTap, isNotNull);
      onTap!.call();
      await tester.pumpAndSettle();
      return;
    }

    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      final scrollOffset = attempt.isEven
          ? const Offset(0, 280)
          : const Offset(0, -280);
      await tester.drag(scrollable.first, scrollOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }

    await tester.pump(const Duration(milliseconds: 120));
  }

  expect(finder, findsOneWidget);
}

Future<void> _enterTextWhenVisible(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await _tapWhenVisible(tester, finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<void> _pumpToAddAccountSearch(WidgetTester tester) async {
  final searchTitle = find.text('Search for your bank');
  for (var attempt = 0; attempt < 8; attempt++) {
    if (searchTitle.evaluate().isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
  }
  expect(searchTitle, findsOneWidget);
}

Future<void> _tapAddUnlinkedAccount(WidgetTester tester) async {
  final buttonLabel = find.byKey(_addAccountUnlinkedButtonKey);
  final nicknameLabel = find.byKey(_addAccountNicknameFieldKey);
  final titleLabel = find.text('Add Unlinked Account');
  for (var attempt = 0; attempt < 4; attempt++) {
    if (nicknameLabel.evaluate().isNotEmpty ||
        titleLabel.evaluate().isNotEmpty) {
      break;
    }
    await _ensureAddUnlinkedVisible(tester);
    if (buttonLabel.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 150));
      continue;
    }
    await tester.tap(buttonLabel.first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    if (nicknameLabel.evaluate().isNotEmpty ||
        titleLabel.evaluate().isNotEmpty) {
      break;
    }
    await tester.pump(const Duration(milliseconds: 150));
  }
  expect(titleLabel, findsOneWidget);
}

Future<void> _ensureAddUnlinkedVisible(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  final finder = find.byKey(_addAccountUnlinkedButtonKey);

  for (var attempt = 0; attempt < 6; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      break;
    }
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, const Offset(0, -320));
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
  }

  if (finder.evaluate().isEmpty) {
    return;
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
