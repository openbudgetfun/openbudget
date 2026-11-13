import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/crypto_breakdown.dart';

const String _entityId = fixtureEntityId;

NetWorthView _view({
  String currencyCode = 'USD',
  int assetsMinor = 120000,
  int liabilitiesMinor = 0,
  bool isComplete = true,
  List<String> missingCurrencyCodes = const [],
  bool hasStaleRates = false,
  List<NetWorthAccountRow> accounts = const [],
  List<NetWorthCurrencyRow> currencies = const [],
}) => NetWorthView(
  currencyCode: currencyCode,
  asOf: DateTime.utc(2026, 9, 5),
  assetsMinor: assetsMinor,
  liabilitiesMinor: liabilitiesMinor,
  netWorthMinor: assetsMinor + liabilitiesMinor,
  isComplete: isComplete,
  missingCurrencyCodes: missingCurrencyCodes,
  hasStaleRates: hasStaleRates,
  currencies: currencies,
  entities: const [],
  accounts: accounts,
);

Widget _buildSubject(NetWorthView view, {bool withWallets = false}) =>
    ProviderScope(
      overrides: [
        netWorthProvider.overrideWith((ref) async => view),
        cryptoBreakdownProvider.overrideWith(
          (ref, arg) async => withWallets
              ? cryptoBreakdownView(arg.$2)
              : noWalletsBreakdown(arg.$2),
        ),
        reportingCurrencyProvider.overrideWith((ref) async => 'USD'),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const NetWorthScreen(entityId: _entityId),
      ),
    );

void main() {
  testWidgets('renders single-currency net worth summary', (tester) async {
    final view = _view(
      accounts: [
        NetWorthAccountRow(
          accountId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000101',
          ),
          entityId: UuidValue.fromString(_entityId),
          name: 'USD Checking',
          kind: AccountKind.checking,
          isLiability: false,
          currencyCode: 'USD',
          balanceMinor: 120000,
          convertedMinor: 120000,
        ),
      ],
      currencies: [
        NetWorthCurrencyRow(
          currencyCode: 'USD',
          nativeMinor: 120000,
          convertedMinor: 120000,
          isStale: false,
          accountCount: 1,
        ),
      ],
    );

    await tester.pumpWidget(_buildSubject(view));
    await tester.pumpAndSettle();

    expect(find.text('Net Worth'), findsAtLeast(1));
    expect(find.textContaining(r'$1,200.00'), findsAtLeast(1));
    expect(find.text('Assets'), findsAtLeast(1));
    expect(find.text('Liabilities'), findsAtLeast(1));
  });

  testWidgets('renders multi-currency accounts in the breakdown', (
    tester,
  ) async {
    final view = _view(
      assetsMinor: 300000,
      accounts: [
        NetWorthAccountRow(
          accountId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000101',
          ),
          entityId: UuidValue.fromString(_entityId),
          name: 'USD Checking',
          kind: AccountKind.checking,
          isLiability: false,
          currencyCode: 'USD',
          balanceMinor: 100000,
          convertedMinor: 100000,
        ),
        NetWorthAccountRow(
          accountId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000102',
          ),
          entityId: UuidValue.fromString(_entityId),
          name: 'EUR Savings',
          kind: AccountKind.savings,
          isLiability: false,
          currencyCode: 'EUR',
          balanceMinor: 200000,
          convertedMinor: 200000,
        ),
      ],
      currencies: [
        NetWorthCurrencyRow(
          currencyCode: 'USD',
          nativeMinor: 100000,
          convertedMinor: 100000,
          isStale: false,
          accountCount: 1,
        ),
        NetWorthCurrencyRow(
          currencyCode: 'EUR',
          nativeMinor: 200000,
          convertedMinor: 200000,
          isStale: false,
          accountCount: 1,
        ),
      ],
    );

    await tester.pumpWidget(_buildSubject(view));
    await tester.pumpAndSettle();

    // Accounts live on the By-account tab, below the headline cards.
    await tester.scrollUntilVisible(
      find.text('By account'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('By account'));
    await tester.pumpAndSettle();

    expect(find.text('USD Checking'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('EUR Savings'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('EUR Savings'), findsOneWidget);
    expect(find.textContaining('EUR'), findsWidgets);
  });

  testWidgets('incomplete currencies warn instead of being converted', (
    tester,
  ) async {
    final view = _view(
      isComplete: false,
      missingCurrencyCodes: const ['JPY'],
      currencies: [
        // A currency with no rate: the row counts the accounts but has no
        // converted total.
        NetWorthCurrencyRow(
          currencyCode: 'JPY',
          nativeMinor: 100000,
          isStale: false,
          accountCount: 1,
        ),
      ],
      accounts: [
        NetWorthAccountRow(
          accountId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000101',
          ),
          entityId: UuidValue.fromString(_entityId),
          name: 'USD Checking',
          kind: AccountKind.checking,
          isLiability: false,
          currencyCode: 'USD',
          balanceMinor: 120000,
          convertedMinor: 120000,
        ),
      ],
    );

    await tester.pumpWidget(_buildSubject(view));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Some accounts are not included'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Some accounts are not included'), findsOneWidget);
    expect(find.textContaining('no rate'), findsOneWidget);
  });

  testWidgets('shows no Crypto section for an entity without wallets', (
    tester,
  ) async {
    await tester.pumpWidget(_buildSubject(_view()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('crypto-breakdown-section')), findsNothing);
    expect(find.text('Crypto'), findsNothing);
  });

  testWidgets('shows the Crypto section under the history chart when the '
      'entity has wallets', (tester) async {
    // Tall enough that the whole list is built and laid out at once.
    tester.view
      ..physicalSize = const Size(800, 4000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_buildSubject(_view(), withWallets: true));
    await tester.pumpAndSettle();

    final section = find.byKey(const Key('crypto-breakdown-section'));
    expect(section, findsOneWidget);
    expect(find.text('Across 2 wallets'), findsOneWidget);

    await tester.tap(find.byKey(const Key('crypto-breakdown-toggle-by-asset')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('crypto-breakdown-row-asset:USDC')),
      findsOneWidget,
    );

    // The history chart sits above it and the breakdown tabs below.
    final sectionTop = tester.getTopLeft(section).dy;
    expect(
      tester.getTopLeft(find.text('History').first).dy,
      lessThan(sectionTop),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('net-worth-tab-by-entity'))).dy,
      greaterThan(sectionTop),
    );
  });
}
