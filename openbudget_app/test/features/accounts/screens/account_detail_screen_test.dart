import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/widgets/wallet_settings_sheet.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const String _entityId = fixtureEntityId;
const String _accountId = fixtureAccountId;
const String _walletId = '00000000-0000-0000-0000-0000000000abc1';

Entity _entity() => testEntity(baseCurrencyCode: 'USD');

Account _account({
  String name = 'Daily',
  AccountKind kind = AccountKind.checking,
  int balanceMinor = 5202000,
  String currencyCode = 'USD',
  bool onBudget = true,
  AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
  DateTime? closedAt,
}) => testAccount(
  name: name,
  kind: kind,
  currencyCode: currencyCode,
  balanceMinor: balanceMinor,
  onBudget: onBudget,
  balanceSource: balanceSource,
  closedAt: closedAt,
);

AccountBalancesView _balances({
  int balanceMinor = 5202000,
  int clearedMinor = 5000000,
  int unclearedMinor = 202000,
  int? reportedBalanceMinor = 5199000,
}) => AccountBalancesView(
  accountId: UuidValue.fromString(_accountId),
  currencyCode: 'USD',
  balanceMinor: balanceMinor,
  clearedMinor: clearedMinor,
  unclearedMinor: unclearedMinor,
  reportedBalanceMinor: reportedBalanceMinor,
);

TransactionView _view({
  required String id,
  required String description,
  required int amountMinor,
  TransactionStatus status = TransactionStatus.uncleared,
  int baseAmountMinor = -1,
  String accountCurrencyCode = 'USD',
  String accountName = 'Daily',
}) => TransactionView(
  transaction: Transaction(
    id: UuidValue.fromString(id),
    entityId: UuidValue.fromString(_entityId),
    accountId: UuidValue.fromString(_accountId),
    date: DateTime.utc(2026, 9, 3),
    amountMinor: amountMinor,
    baseAmountMinor: baseAmountMinor == -1 ? amountMinor : baseAmountMinor,
    fxRateDate: DateTime.utc(2026, 9, 3),
    description: description,
    status: status,
  ),
  lines: [
    TransactionLine(
      transactionId: UuidValue.fromString(id),
      amountMinor: amountMinor,
      baseAmountMinor: baseAmountMinor == -1 ? amountMinor : baseAmountMinor,
    ),
  ],
  accountCurrencyCode: accountCurrencyCode,
  accountName: accountName,
);

TransactionPageState _pageState(
  List<TransactionView> items, {
  String? nextCursor,
}) => TransactionPageState(
  filter: const TransactionFilter(accountId: _accountId),
  items: items,
  nextCursor: nextCursor,
);

/// A paged provider that always answers with the fixture page.
class _FakeTransactionPages extends TransactionPages {
  _FakeTransactionPages(this.items, {this.nextCursor});

  final List<TransactionView> items;
  final String? nextCursor;

  @override
  Future<TransactionPageState> build(String entityId) async =>
      _pageState(items, nextCursor: nextCursor);
}

Wallet _wallet() => Wallet(
  id: UuidValue.fromString(_walletId),
  entityId: UuidValue.fromString(_entityId),
  accountId: UuidValue.fromString(_accountId),
  network: WalletNetwork.solanaMainnet,
  address: '8f5PsYfTEvtwFw8szw8RKtAHY8fE6hzJHjxbM6j6YV1z',
  label: 'Main Wallet',
  syncStatus: SyncStatus.synced,
  lastSyncedAt: DateTime.utc(2026, 9, 5, 10, 30),
);

WalletHolding _holding({
  String symbol = 'SOL',
  BigInt? quantityRaw,
  int decimals = 9,
  int valueMinor = 28000,
  int? costBasisMinor = 25000,
  int? realizedPnlMinor = 3000,
  String priceCurrencyCode = 'USD',
}) => WalletHolding(
  walletId: UuidValue.fromString(_walletId),
  network: WalletNetwork.solanaMainnet,
  assetId: 'So11111111111111111111111111111111111111112',
  symbol: symbol,
  decimals: decimals,
  quantityRaw: quantityRaw ?? BigInt.from(1500000000),
  priceCurrencyCode: priceCurrencyCode,
  valueMinor: valueMinor,
  priceQuality: PriceQuality.live,
  costBasisMinor: costBasisMinor,
  realizedPnlMinor: realizedPnlMinor,
);

Widget _buildSubject({
  Account? account,
  AccountBalancesView? balances,
  List<TransactionView>? transactions,
  bool hasMore = false,
  Wallet? wallet,
  List<WalletHolding>? holdings,
  List<AccountValuation>? valuations,
}) {
  final resolvedAccount = account ?? _account();
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/accounts/$_accountId',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Accounts Route'))),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) => AccountDetailScreen(
          entityId: state.pathParameters['entityId']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      entityDetailProvider.overrideWith((ref, id) async => _entity()),
      accountDetailProvider.overrideWith((ref, id) async => resolvedAccount),
      accountBalancesProvider.overrideWith(
        (ref, id) async => balances ?? _balances(),
      ),
      accountValuationsProvider.overrideWith(
        (ref, id) async => valuations ?? const [],
      ),
      accountListProvider.overrideWith(
        (ref, entityId) async => [resolvedAccount],
      ),
      transactionPagesProvider.overrideWith2(
        (entityId) => _FakeTransactionPages(
          transactions ?? const [],
          nextCursor: hasMore ? 'cursor-1' : null,
        ),
      ),
      netWorthForEntitiesProvider.overrideWith(
        (ref, ids) async => _netWorth(),
      ),
      walletForAccountProvider.overrideWith((ref, id) async => wallet),
      if (wallet != null) ...[
        walletHoldingsProvider.overrideWith(
          (ref, id) async => holdings ?? const [],
        ),
        walletTransactionsProvider.overrideWith(
          (ref, id) async => const [],
        ),
        walletTaxYearSummariesProvider.overrideWith(
          (ref, id) async => const [],
        ),
      ],
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

NetWorthView _netWorth() => NetWorthView(
  currencyCode: 'USD',
  asOf: DateTime.utc(2026, 9, 5),
  assetsMinor: 5202000,
  liabilitiesMinor: 0,
  netWorthMinor: 5202000,
  isComplete: true,
  missingCurrencyCodes: const [],
  hasStaleRates: false,
  currencies: const [],
  entities: const [],
  accounts: const [],
);

void main() {
  group('AccountDetailScreen', () {
    testWidgets('renders the balance, split, and reported line', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();
      await tester.pump();

      expect(find.text('Daily'), findsOneWidget);
      // The hero balance draws its minor units raised, so it is found by
      // the label it is announced with.
      expect(
        find.bySemanticsLabel(
          RegExp(r'^\$52,020\.00$', multiLine: true),
        ),
        findsOneWidget,
      );
      expect(find.text(r'Cleared $50,000.00'), findsOneWidget);
      expect(find.text(r'Uncleared $2,020.00'), findsOneWidget);
      expect(find.text(r'Bank says $51,990.00'), findsOneWidget);
    });

    testWidgets('shows the server-converted equivalent for a foreign account', (
      tester,
    ) async {
      // The conversion comes from the net worth view's account rows, not
      // from any client-side FX math.
      final account = _account(currencyCode: 'EUR', balanceMinor: 40000);
      final container = ProviderContainer(
        overrides: [
          walletForAccountProvider.overrideWith((ref, id) async => null),
          entityDetailProvider.overrideWith((ref, id) async => _entity()),
          accountDetailProvider.overrideWith((ref, id) async => account),
          accountBalancesProvider.overrideWith(
            (ref, id) async => _balances(
              balanceMinor: 40000,
              clearedMinor: 40000,
              unclearedMinor: 0,
              reportedBalanceMinor: null,
            ),
          ),
          accountValuationsProvider.overrideWith((ref, id) async => const []),
          accountListProvider.overrideWith((ref, entityId) async => [account]),
          transactionPagesProvider.overrideWith2(
            (entityId) => _FakeTransactionPages(const []),
          ),
          netWorthForEntitiesProvider.overrideWith(
            (ref, ids) async => NetWorthView(
              currencyCode: 'USD',
              asOf: DateTime.utc(2026, 9, 5),
              assetsMinor: 43160,
              liabilitiesMinor: 0,
              netWorthMinor: 43160,
              isComplete: true,
              missingCurrencyCodes: const [],
              hasStaleRates: false,
              currencies: const [],
              entities: const [],
              accounts: [
                NetWorthAccountRow(
                  accountId: UuidValue.fromString(_accountId),
                  entityId: UuidValue.fromString(_entityId),
                  name: 'Daily',
                  kind: AccountKind.checking,
                  isLiability: false,
                  currencyCode: 'EUR',
                  balanceMinor: 40000,
                  convertedMinor: 43160,
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: GoRouter(
              initialLocation: '/budgets/$_entityId/accounts/$_accountId',
              routes: [
                GoRoute(
                  name: accountDetailRoute,
                  path: accountDetailPath,
                  builder: (context, state) => AccountDetailScreen(
                    entityId: state.pathParameters['entityId']!,
                    accountId: state.pathParameters['accountId']!,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('in base currency'), findsOneWidget);
      expect(find.text(r'≈ $431.60 in base currency'), findsOneWidget);
    });

    testWidgets('renders transaction rows for the paged list', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          transactions: [
            _view(
              id: '00000000-0000-0000-0000-000000000211',
              description: 'Rent',
              amountMinor: -280000,
            ),
            _view(
              id: '00000000-0000-0000-0000-000000000212',
              description: 'Payroll',
              amountMinor: 300000,
              status: TransactionStatus.cleared,
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Payroll'), findsOneWidget);
    });

    testWidgets('offers load more when a next page exists', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          transactions: [
            _view(
              id: '00000000-0000-0000-0000-000000000211',
              description: 'Rent',
              amountMinor: -280000,
            ),
          ],
          hasMore: true,
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Load more'),
        300,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .last,
      );
      await tester.pump();
      expect(find.text('Load more'), findsOneWidget);
    });

    testWidgets('shows the closed badge and reopen action', (tester) async {
      await tester.pumpWidget(
        _buildSubject(account: _account(closedAt: DateTime.utc(2026, 8))),
      );
      await tester.pump();
      await tester.pump();

      // The badge sits just under the balance card; a small drag suffices.
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Reopen Account'), findsOneWidget);
    });

    testWidgets('valuation accounts show their value history', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          account: _account(
            name: 'Flat',
            kind: AccountKind.property,
            balanceSource: AccountBalanceSource.valuations,
            balanceMinor: 420000000,
          ),
          balances: _balances(
            balanceMinor: 420000000,
            clearedMinor: 420000000,
            unclearedMinor: 0,
            reportedBalanceMinor: null,
          ),
          valuations: [
            AccountValuation(
              accountId: UuidValue.fromString(_accountId),
              valuationDate: DateTime.utc(2026, 8, 31),
              valueMinor: 420000000,
              source: ValuationSource.manual,
            ),
            AccountValuation(
              accountId: UuidValue.fromString(_accountId),
              valuationDate: DateTime.utc(2026, 5, 31),
              valueMinor: 400000000,
              source: ValuationSource.manual,
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Value history'),
        300,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .last,
      );
      await tester.pump();
      expect(find.text('Value history'), findsOneWidget);
      expect(find.text('Update value'), findsOneWidget);
      expect(find.text(r'$4,200,000.00'), findsWidgets);
      expect(find.textContaining('Valued'), findsWidgets);
    });

    testWidgets('a wallet account offers wallet settings and its holdings, '
        'though the server values it', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          // The server makes every wallet account track by value, because
          // the wallet's valuation sets it.
          account: _account(
            name: 'Main Wallet',
            kind: AccountKind.crypto,
            balanceMinor: 28000,
            onBudget: false,
            balanceSource: AccountBalanceSource.valuations,
          ),
          wallet: _wallet(),
          holdings: [_holding()],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(walletSettingsButtonKey), findsOneWidget);
      expect(find.text('Holdings'), findsOneWidget);
      expect(find.text('SOL'), findsOneWidget);
      await tester.tap(find.byKey(walletSettingsButtonKey));
      await tester.pumpAndSettle();
      // The sheet opens on the wallet's own name and single chain.
      expect(find.byKey(walletSettingsNameFieldKey), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(walletSettingsNameFieldKey))
            .controller!
            .text,
        'Main Wallet',
      );
      expect(find.text('Disconnect wallet'), findsOneWidget);
    });

    testWidgets('an account without a wallet has no wallet settings', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(walletSettingsButtonKey), findsNothing);
    });

    testWidgets('wallet accounts show holdings with value and P&L', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          account: _account(
            name: 'Main Wallet',
            kind: AccountKind.crypto,
            balanceMinor: 28000,
            onBudget: false,
          ),
          balances: _balances(
            balanceMinor: 28000,
            clearedMinor: 28000,
            unclearedMinor: 0,
            reportedBalanceMinor: null,
          ),
          wallet: _wallet(),
          holdings: [_holding()],
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('Holdings'),
        300,
        scrollable: find
            .byWidgetPredicate(
              (widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .last,
      );
      await tester.pump();
      expect(find.text('Holdings'), findsOneWidget);
      expect(find.text('SOL'), findsOneWidget);
      // 9 decimals: 1500000000 raw = 1.5 SOL.
      expect(find.text('Quantity 1.5'), findsOneWidget);
      // The network's subtotal and the row both show the value.
      expect(find.text(r'$280.00'), findsNWidgets(2));
      expect(
        find.bySemanticsLabel(
          RegExp(r'^Value \$280\.00$', multiLine: true),
        ),
        findsOneWidget,
      );
      expect(find.text(r'P&L $30.00'), findsOneWidget);
    });

    group('reconcile sheet', () {
      Future<void> openSheet(WidgetTester tester) async {
        await tester.tap(find.text('Reconcile'));
        await tester.pump();
        await tester.pump();
      }

      Finder statementField() => find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );

      testWidgets('pre-fills the bank reported balance', (tester) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pump();
        await tester.pump();

        await openSheet(tester);

        expect(find.text('Reconcile Daily'), findsOneWidget);
        final field = tester.widget<TextField>(statementField());
        expect(field.controller?.text, '51990.00');
      });

      testWidgets('shows a live difference against the balance', (
        tester,
      ) async {
        await tester.pumpWidget(_buildSubject());
        await tester.pump();
        await tester.pump();

        await openSheet(tester);
        // The sheet diffs against the cleared balance ($50,000.00).
        await tester.enterText(statementField(), '50000.00');
        await tester.pump();
        await tester.pump();

        expect(find.textContaining('Difference'), findsOneWidget);
        expect(find.textContaining(r'$0.00'), findsOneWidget);
        expect(find.text('Matches your statement'), findsOneWidget);
      });
    });
  });
}
