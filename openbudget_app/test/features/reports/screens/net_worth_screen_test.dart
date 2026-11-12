import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

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

Widget _buildSubject(NetWorthView view) => ProviderScope(
  overrides: [
    netWorthProvider.overrideWith((ref) async => view),
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
}
