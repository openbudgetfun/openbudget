import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/providers/fx_rate_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

/// Section-10 flow: a cross-currency transfer between a GBP and a USD
/// account. Sent and Received are entered by hand, the implied rate shows,
/// the transfer saves and both account balances move.
void main() {
  patrolWidgetTest(
    'cross-currency transfer shows the implied rate and moves both balances',
    ($) async {
      final tester = $.tester;
      final accounts = _MutableAccounts([
        TestData.checkingAccount(balanceMinor: 100000),
        TestData.usdCheckingAccount(balanceMinor: 20000),
      ]);
      final transfers = _RecordingTransferActions(accounts);

      final container = ProviderContainer(
        overrides: [
          entityDetailProvider.overrideWith(
            (ref, id) async => TestData.gbpEntity(),
          ),
          accountListProvider.overrideWith(
            (ref, entityId) async => ref.watch(accounts.provider),
          ),
          accountListAllProvider.overrideWith(
            (ref) async => ref.watch(accounts.provider),
          ),
          transactionActionsProvider.overrideWith(() => transfers),
          fxQuoteProvider.overrideWith((ref, currencies) async {
            final (from, to, _) = currencies;
            return FxQuoteView(
              fromCurrencyCode: from,
              toCurrencyCode: to,
              rate: TestData.usdToGbpRate,
              rateDate: DateTime.utc(2026, 11, 8),
              source: FxRateSource.market,
              isStale: false,
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/${TestData.gbpEntityId}/transfer',
        routes: [
          GoRoute(
            name: createTransferRoute,
            path: '/budgets/:entityId/transfer',
            builder: (context, state) =>
                const CreateTransferScreen(entityId: TestData.gbpEntityId),
          ),
          GoRoute(
            name: accountListRoute,
            path: '/budgets/:entityId/accounts',
            builder: (_, _) => const _AccountsProbe(),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData.light(useMaterial3: true),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final page = TransferPage(tester);
      expect(page.title, findsOneWidget);

      await page.pickAccount(
        from: '${TestData.checkingAccountName} (GBP)',
        to: '${TestData.usdCheckingAccountName} (USD)',
      );
      await page.enterSent('100.00');
      await tester.pumpAndSettle();

      // Entering Sent only leaves Received empty; the implied rate line is
      // visible against the quoted market rate.
      expect(page.impliedRate, findsOneWidget);
      expect(find.textContaining('1 USD = 0.79 GBP'), findsOneWidget);
      expect(find.textContaining('Nov 8'), findsOneWidget);

      await page.enterReceived('79.00');
      await tester.pumpAndSettle();

      // With both amounts typed the rate is implied from them, still shown
      // on the line.
      expect(page.impliedRate, findsOneWidget);

      await page.submit();
      await tester.pumpAndSettle();

      // The transfer saved as one input carrying both legs' amounts.
      expect(transfers.inputs, hasLength(1));
      final input = transfers.inputs.single;
      expect(input.fromAmountMinor, 10000);
      expect(input.toAmountMinor, 7900);
      expect(input.useMarketRate, isFalse);

      // Both balances moved: the USD account paid out $100, the GBP account
      // received the £79 the implied rate produced.
      expect(
        accounts
            .named(TestData.usdCheckingAccountName)
            .balanceMinor,
        10000,
      );
      expect(
        accounts.named(TestData.checkingAccountName).balanceMinor,
        107900,
      );
      expect(find.text('£1,079.00'), findsOneWidget);
      expect(find.text(r'$100.00'), findsOneWidget);
    },
  );
}

/// The account rows the list screen and the transfer form both read, kept
/// mutable so the fake transfer can move the balances.
class _MutableAccounts {
  _MutableAccounts(List<Account> initial) : state = List.of(initial);

  List<Account> state;

  Provider<List<Account>> get provider => Provider<List<Account>>(
    (ref) => state,
  );

  Account named(String name) => state.singleWhere(
    (account) => account.name == name,
  );
}

class _RecordingTransferActions extends TransactionActions {
  _RecordingTransferActions(this.accounts);

  final _MutableAccounts accounts;
  final List<TransferInput> inputs = [];

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<List<TransactionView>> createTransfer({
    required TransferInput input,
    required String entityId,
  }) async {
    inputs.add(input);
    final from = accounts.state.firstWhere(
      (account) => account.id?.toString() == input.fromAccountId.toString(),
    );
    final to = accounts.state.firstWhere(
      (account) => account.id?.toString() == input.toAccountId.toString(),
    );
    accounts.state = [
      for (final account in accounts.state)
        if (account == from)
          account.copyWith(
            balanceMinor: account.balanceMinor - input.fromAmountMinor,
          )
        else if (account == to)
          account.copyWith(
            balanceMinor: account.balanceMinor + (input.toAmountMinor ?? 0),
          )
        else
          account,
    ];
    return const [];
  }
}

/// A stand-in account list screen that shows the raw balance figures the
/// flow asserts on.
class _AccountsProbe extends ConsumerWidget {
  const _AccountsProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountListProvider('entity')).value ?? const <Account>[];
    final texts = <Widget>[
      for (final account in accounts)
        Text(
          _format(account.balanceMinor, account.currencyCode),
        ),
    ];
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: texts),
      ),
    );
  }

  String _format(int minor, String currencyCode) => switch (currencyCode) {
    'GBP' => '£${_pounds(minor)}',
    _ => r'$' + _pounds(minor),
  };

  String _pounds(int minor) {
    final whole = minor ~/ 100;
    final fraction = (minor % 100).abs().toString().padLeft(2, '0');
    final sign = minor < 0 ? '-' : '';
    return '$sign$whole.$fraction';
  }
}
