import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/institution_catalog_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

const String _entityId = TestData.gbpEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);

final _testInstitutions = <Institution>[
  Institution(slug: 'chase', name: 'Chase', website: 'chase.com'),
  Institution(slug: 'citi', name: 'Citi', website: 'citi.com'),
  Institution(
    slug: 'bank-of-america',
    name: 'Bank of America',
    website: 'bankofamerica.com',
  ),
  Institution(
    slug: 'wells-fargo',
    name: 'Wells Fargo',
    website: 'wellsfargo.com',
  ),
  Institution(
    slug: 'capital-one',
    name: 'Capital One',
    website: 'capitalone.com',
  ),
];
const _addAccountUnlinkedButtonKey = Key('add-account-add-unlinked-button');
const _addAccountUnlinkedScrollKey = Key('add-account-unlinked-scroll');
const _addAccountNicknameFieldKey = Key('add-account-unlinked-nickname-field');
const _addAccountTypeTileKey = Key('add-account-unlinked-type-tile');
const _addAccountBalanceFieldKey = Key('add-account-unlinked-balance-field');
const ValueKey<String> _addAccountCheckingTypeKey = ValueKey(
  'add-account-type-option-checking',
);
const _addAccountUnlinkedIntroText =
    'Bank connections are currently unavailable';

Account _makeAccount({
  required String name,
  required int balanceMinor,
  required String currencyCode,
  UuidValue? id,
  AccountKind kind = AccountKind.checking,
  bool onBudget = true,
  bool isClosed = false,
}) => Account(
  id: id,
  name: name,
  kind: kind,
  balanceSource: AccountBalanceSource.transactions,
  balanceMinor: balanceMinor,
  currencyCode: currencyCode,
  entityId: _entityUuid,
  onBudget: onBudget,
  sortOrder: 0,
  closedAt: isClosed ? DateTime.utc(2026, 10) : null,
);

TransactionView _makeTransactionView({
  required String id,
  required UuidValue accountId,
  required String description,
  required int amountMinor,
  bool cleared = false,
  DateTime? date,
}) {
  final transaction = Transaction(
    id: UuidValue.fromString(id),
    entityId: _entityUuid,
    accountId: accountId,
    date: date ?? DateTime(2026, 9, 3),
    amountMinor: amountMinor,
    baseAmountMinor: amountMinor,
    fxRateDate: date ?? DateTime(2026, 9, 3),
    description: description,
    status: cleared ? TransactionStatus.cleared : TransactionStatus.uncleared,
  );
  return TransactionView(
    transaction: transaction,
    lines: [
      TransactionLine(
        id: UuidValue.fromString('$id-1'.replaceRange(0, 1, 'a')),
        transactionId: transaction.id!,
        amountMinor: amountMinor,
        baseAmountMinor: amountMinor,
      ),
    ],
    accountCurrencyCode: 'USD',
    accountName: 'Daily USD',
  );
}

/// The paged account transactions, served from memory.
class _FakeTransactionPages extends TransactionPages {
  _FakeTransactionPages(this.items);

  final List<TransactionView> items;

  @override
  Future<TransactionPageState> build(String entityId) async =>
      TransactionPageState(filter: const TransactionFilter(), items: items);
}

class _FakeAccountActions extends AccountActions {
  @override
  FutureOr<void> build() {}

  @override
  Future<Account> createAccount({
    required String name,
    required AccountKind kind,
    required String currencyCode,
    required String entityId,
    AccountBalanceSource? balanceSource,
    String? institutionId,
    String? note,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
  }) async => Account(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000777'),
    name: name,
    kind: kind,
    balanceSource: balanceSource ?? AccountBalanceSource.transactions,
    balanceMinor: openingBalanceMinor ?? 0,
    currencyCode: currencyCode,
    entityId: _entityUuid,
    onBudget: onBudget ?? true,
    sortOrder: 0,
  );
}

class _UnavailablePlaidAccountLink extends PlaidAccountLink {
  @override
  FutureOr<void> build() {}

  /// Every link operation throws so a tap lands in the screen's fallback:
  /// the unlinked-account flow with the "Add an unlinked account instead"
  /// toast, exactly as when the Plaid service is unreachable in production.
  @override
  Future<String> createLinkToken({required String entityId}) =>
      throw Exception('Bank linking is unavailable in this fixture.');

  @override
  Future<PlaidConnection> exchangePublicToken({
    required String entityId,
    required String publicToken,
  }) => throw Exception('Bank linking is unavailable in this fixture.');

  @override
  Future<PlaidConnection> syncConnection({
    required String connectionId,
    required String entityId,
  }) => throw Exception('Bank linking is unavailable in this fixture.');

  @override
  Future<void> removeConnection({
    required String connectionId,
    required String entityId,
  }) => throw Exception('Bank linking is unavailable in this fixture.');

  @override
  Future<PlaidConnection> importSandboxAccounts({
    required String entityId,
    String? plaidInstitutionId,
  }) => throw Exception('Bank linking is unavailable in this fixture.');
}

Widget _buildApp({
  required List<Account> accounts,
  List<TransactionView> accountTransactions = const [],
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/accounts',
    routes: [
      // The detail and add screens are children of the list route, mirroring
      // the app router, so the detail screen can pop back to the list.
      GoRoute(
        name: accountListRoute,
        path: '/budgets/:entityId/accounts',
        builder: (context, state) =>
            AccountListScreen(entityId: state.pathParameters['entityId']!),
        routes: [
          GoRoute(
            name: addAccountRoute,
            path: 'add',
            builder: (context, state) =>
                AddAccountScreen(entityId: state.pathParameters['entityId']!),
          ),
          GoRoute(
            name: accountDetailRoute,
            path: ':accountId',
            builder: (context, state) => AccountDetailScreen(
              entityId: state.pathParameters['entityId']!,
              accountId: state.pathParameters['accountId']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      accountDetailProvider.overrideWith(
        (ref, accountId) async => accounts.firstWhere(
          (account) => account.id?.toString() == accountId,
        ),
      ),
      accountBalancesProvider.overrideWith((ref, accountId) async {
        final account = accounts.firstWhere(
          (account) => account.id?.toString() == accountId,
        );
        var clearedMinor = 0;
        var unclearedMinor = 0;
        for (final view in accountTransactions) {
          if (view.transaction.accountId != account.id) continue;
          if (view.transaction.status == TransactionStatus.uncleared) {
            unclearedMinor += view.transaction.amountMinor;
          } else {
            clearedMinor += view.transaction.amountMinor;
          }
        }
        return AccountBalancesView(
          accountId: account.id ?? _entityUuid,
          currencyCode: account.currencyCode,
          balanceMinor: account.balanceMinor,
          clearedMinor: clearedMinor,
          unclearedMinor: unclearedMinor,
        );
      }),
      accountValuationsProvider.overrideWith(
        (ref, accountId) async => const [],
      ),
      walletForAccountProvider.overrideWith(
        (ref, accountId) async => null,
      ),
      accountActionsProvider.overrideWith(_FakeAccountActions.new),
      plaidAccountLinkProvider.overrideWith(_UnavailablePlaidAccountLink.new),
      accountListProvider.overrideWith((ref, entityId) async => accounts),
      transactionPagesProvider.overrideWith2(
        (entityId) => _FakeTransactionPages(accountTransactions),
      ),
      payeeListProvider.overrideWith((ref, entityId) async => const []),
      netWorthForEntitiesProvider.overrideWith(
        (ref, entityIds) async => TestData.gbpNetWorthWithUsd(),
      ),
      plaidConnectionsProvider.overrideWith(
        (ref, entityId) async => const [],
      ),
      institutionCatalogProvider.overrideWith(
        (ref, locationCode) async => _testInstitutions,
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
            balanceMinor: 250000,
            currencyCode: 'USD',
          ),
          _makeAccount(
            name: 'Savings EUR',
            balanceMinor: 100000,
            currencyCode: 'EUR',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final accountsPage = AccountsTabPage(tester);
    expect(accountsPage.accountTile('Daily USD'), findsOneWidget);
    await accountsPage.scrollToAccount('Savings EUR');
    expect(accountsPage.accountTile('Savings EUR'), findsOneWidget);
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
    await _captureAddAccountStepScreenshot(
      tester,
      'add-accounts-loading-institutions-screen',
    );
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
    await _ensureAddUnlinkedVisible(tester);
    expect(find.textContaining('Unlinked Account'), findsWidgets);
    await _captureAddAccountStepScreenshot(
      tester,
      'add-accounts-search-screen',
    );

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
    expect(find.textContaining('unlinked account instead'), findsOneWidget);
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
    await _captureAddAccountStepScreenshot(
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
      await _captureAddAccountStepScreenshot(
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
      await _captureAddAccountStepScreenshot(
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
    await _captureAddAccountStepScreenshot(
      tester,
      'add-accounts-search-desktop-empty-results-screen',
    );
  });

  patrolWidgetTest(
    'desktop linked bank tap falls back to unlinked account guidance',
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
      await tester.pumpAndSettle();

      expect(find.text('Add Unlinked Account'), findsOneWidget);
      expect(find.textContaining('unlinked account instead'), findsOneWidget);
      await _captureAddAccountStepScreenshot(
        tester,
        'add-accounts-desktop-unlinked-fallback-screen',
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
      await _captureAddAccountStepScreenshot(
        tester,
        'add-account-type-selection',
      );
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
      expect(find.text('Add another'), findsOneWidget);
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
    expect(find.textContaining(_addAccountUnlinkedIntroText), findsOneWidget);
    expect(find.text('Give it a nickname'), findsOneWidget);
    expect(find.text('What type of account are you adding?'), findsOneWidget);
    final introDy = tester
        .getTopLeft(find.textContaining(_addAccountUnlinkedIntroText))
        .dy;
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
    await tester.ensureVisible(
      find.textContaining(_addAccountUnlinkedIntroText),
    );
    await tester.pumpAndSettle();
    await _captureAddAccountStepScreenshot(
      tester,
      'add-unlinked-account-desktop-form-screen',
    );

    await _enterTextWhenVisible(
      tester,
      find.byKey(_addAccountNicknameFieldKey),
      'Daily',
    );
    await _activateListTile(tester, find.byKey(_addAccountTypeTileKey));
    expect(
      find.text(
        'Cash accounts hold funds you already own and can spend immediately.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining("you'll need to repay later, often with interest"),
      findsOneWidget,
    );
    expect(
      find.text(
        "Accounts that hold money you don't plan to spend soon, such as "
        'investments or loans.',
      ),
      findsOneWidget,
    );
    await _activateListTile(tester, find.byKey(_addAccountCheckingTypeKey));
    await tester.pumpAndSettle();
    await _enterTextWhenVisible(
      tester,
      find.byKey(_addAccountBalanceFieldKey),
      '50000',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.textContaining(_addAccountUnlinkedIntroText),
    );
    await tester.pumpAndSettle();
    await _captureAddAccountStepScreenshot(
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
    expect(find.text('Add another'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    await _captureAddAccountStepScreenshot(
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
      await tester.binding.setSurfaceSize(const Size(1024, 420));
      await tester.pumpWidget(_buildApp(accounts: const []));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Account'));
      await _pumpToAddAccountSearch(tester);
      await _tapAddUnlinkedAccount(tester);
      await tester.pumpAndSettle();

      final introFinder = find.textContaining(_addAccountUnlinkedIntroText);
      expect(introFinder, findsOneWidget);
      final introTopBeforeScroll = tester.getTopLeft(introFinder).dy;

      var introTopAfterManualScroll = introTopBeforeScroll;
      for (var attempt = 0; attempt < 4; attempt++) {
        await tester.drag(
          find.byKey(_addAccountUnlinkedScrollKey),
          const Offset(0, -280),
        );
        await tester.pumpAndSettle();
        introTopAfterManualScroll = tester.getTopLeft(introFinder).dy;
        if (introTopAfterManualScroll < introTopBeforeScroll) {
          break;
        }
      }
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
      await tester.tap(find.widgetWithText(OutlinedButton, 'Add another'));
      await tester.pumpAndSettle();

      expect(find.text('Add Unlinked Account'), findsOneWidget);
      final introTopAfterAddAnother = tester.getTopLeft(introFinder).dy;
      expect(introTopAfterAddAnother, greaterThan(introTopAfterManualScroll));
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
            balanceMinor: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000211',
            accountId: accountId,
            description: 'Rent',
            amountMinor: -280000,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();
    await scrollIntoView(tester, find.text('Rent'));
    expect(find.text('Rent'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Daily USD'), findsOneWidget);
  });

  patrolWidgetTest(
    'account detail lists cleared and uncleared transactions together',
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
              balanceMinor: 250000,
              currencyCode: 'USD',
            ),
          ],
          accountTransactions: [
            _makeTransactionView(
              id: '00000000-0000-0000-0000-000000000211',
              accountId: accountId,
              description: 'Self storage',
              amountMinor: -3000,
            ),
            _makeTransactionView(
              id: '00000000-0000-0000-0000-000000000212',
              accountId: accountId,
              description: 'Starting Balance',
              amountMinor: 5000000,
              cleared: true,
              date: DateTime(2026, 9, 2),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily USD'));
      await tester.pumpAndSettle();
      // The redesigned detail screen keeps every transaction in one list,
      // cleared ones included, so both rows render.
      await scrollIntoView(tester, find.text('Starting Balance'));
      expect(find.text('Starting Balance'), findsOneWidget);
      await scrollIntoView(tester, find.text('Self storage'));
      expect(find.text('Self storage'), findsOneWidget);
    },
  );

  patrolWidgetTest('account detail edit action opens the add account screen', (
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
            balanceMinor: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000512',
            accountId: accountId,
            description: 'Gym',
            amountMinor: -15000,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    // The redesigned detail screen opens the account screens straight from
    // the app bar edit action instead of a full-screen edit form.
    await AccountDetailPage(tester).editViaAppBar();
    await tester.pumpAndSettle();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
  });

  patrolWidgetTest(
    'closed account detail exposes the reopen action without editing',
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
              balanceMinor: -50000,
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

      // Closed accounts surface a Closed badge with an inline reopen action
      // and no app-bar edit button.
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Reopen Account'), findsOneWidget);
      expect(AccountDetailPage(tester).editButton, findsNothing);
    },
  );

  patrolWidgetTest('reconcile action opens the statement balance sheet', (
    $,
  ) async {
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
            balanceMinor: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000311',
            accountId: accountId,
            description: 'Rent',
            amountMinor: -280000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    await AccountDetailPage(tester).openReconcileSheet();

    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Reconcile Daily USD')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Statement balance')),
      findsOneWidget,
    );
  });

  patrolWidgetTest('desktop account detail supports reconcile and edit flows', (
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
            balanceMinor: 5222000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000611',
            accountId: accountId,
            description: 'Landlord',
            amountMinor: -10000,
            cleared: true,
          ),
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000612',
            accountId: accountId,
            description: 'Supermarket',
            amountMinor: -50000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();

    await AccountDetailPage(tester).openReconcileSheet();
    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Reconcile Daily USD')),
      findsOneWidget,
    );
    await captureIntegrationScreenshot(
      tester,
      'accounts-reconcile-dialog-desktop-screen',
    );

    // Drag the sheet away, then take the app-bar edit action.
    await tester.drag(find.text('Reconcile Daily USD'), const Offset(0, 480));
    await tester.pumpAndSettle();
    expect(find.text('Reconcile Daily USD'), findsNothing);

    await AccountDetailPage(tester).editViaAppBar();
    await tester.pumpAndSettle();
    expect(find.text('Add Accounts'), findsOneWidget);
    await captureIntegrationScreenshot(
      tester,
      'accounts-edit-account-desktop-screen',
    );
  });

  patrolWidgetTest('loan account shows its balance and payment history', (
    $,
  ) async {
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
            kind: AccountKind.otherLiability,
            balanceMinor: -125,
            currencyCode: 'USD',
            onBudget: false,
          ),
        ],
        accountTransactions: [
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000411',
            accountId: accountId,
            description: 'Payment from Daily',
            amountMinor: 50000,
            date: DateTime(2026, 9, 4),
          ),
          _makeTransactionView(
            id: '00000000-0000-0000-0000-000000000412',
            accountId: accountId,
            description: 'Initial Balance',
            amountMinor: -50000,
            date: DateTime(2026, 9, 3),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Loan'));
    await tester.pumpAndSettle();

    // The liability balance headlines the card; the activity follows in the
    // same list, no tabs. The hero figure draws its cents raised, so it is
    // found by the label it is announced with.
    expect(
      find.bySemanticsLabel(RegExp(r'^-\$1\.25$', multiLine: true)),
      findsOneWidget,
    );
    await scrollIntoView(tester, find.text('Payment from Daily'));
    expect(find.text('Payment from Daily'), findsOneWidget);
    await scrollIntoView(tester, find.text('Initial Balance'));
    expect(find.text('Initial Balance'), findsOneWidget);
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
  final introLabel = find.textContaining(_addAccountUnlinkedIntroText);
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
  if (introLabel.evaluate().isNotEmpty) {
    await tester.ensureVisible(introLabel.first);
    await tester.pumpAndSettle();
  }
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

Future<void> _captureAddAccountStepScreenshot(
  WidgetTester tester,
  String name,
) => captureIntegrationScreenshot(
  tester,
  name,
  captureTarget: find.byKey(addAccountScreenCaptureBoundaryKey),
);
