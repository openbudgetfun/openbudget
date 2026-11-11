import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  const entityId = 'test-budget-1';
  final budgetUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );

  Account makeAccount({
    required String name,
    required int balanceMinor,
    required String currencyCode,
    String type = 'checking',
  }) => Account(
    id: UuidValue.fromString(
      name == 'USD Checking'
          ? '00000000-0000-0000-0000-000000000101'
          : '00000000-0000-0000-0000-000000000102',
    ),
    name: name,
    accountType: type,
    balanceMinor: balanceMinor,
    currencyCode: currencyCode,
    entityId: budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: false,
  );

  Widget buildSubject(NetWorthData data) => ProviderScope(
    overrides: [netWorthProvider.overrideWith((ref, id) async => data)],
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const NetWorthScreen(entityId: entityId),
    ),
  );

  testWidgets('renders single-currency net worth summary', (tester) async {
    final usdAccount = makeAccount(
      name: 'USD Checking',
      balanceMinor: 120000,
      currencyCode: 'USD',
    );
    final data = NetWorthData(
      totalAssets: 120000,
      totalLiabilities: 0,
      netWorth: 120000,
      assetAccounts: [usdAccount],
      liabilityAccounts: const [],
      currencyCode: 'USD',
      currencyBreakdown: [
        CurrencyNetWorthData(
          currency: 'USD',
          totalAssets: 120000,
          totalLiabilities: 0,
          assetAccounts: [usdAccount],
          liabilityAccounts: const [],
        ),
      ],
    );

    await tester.pumpWidget(buildSubject(data));
    await tester.pumpAndSettle();

    expect(find.text('Net Worth'), findsAtLeast(1));
    expect(find.textContaining(r'$1,200.00'), findsAtLeast(1));
    expect(find.text('Assets'), findsAtLeast(1));
    expect(find.text('Liabilities'), findsAtLeast(1));
  });

  testWidgets('renders multi-currency net worth summary', (tester) async {
    final usdAccount = makeAccount(
      name: 'USD Checking',
      balanceMinor: 100000,
      currencyCode: 'USD',
    );
    final eurAccount = makeAccount(
      name: 'EUR Savings',
      balanceMinor: 200000,
      currencyCode: 'EUR',
    );

    final data = NetWorthData(
      totalAssets: 300000,
      totalLiabilities: 0,
      netWorth: 300000,
      assetAccounts: [usdAccount, eurAccount],
      liabilityAccounts: const [],
      currencyCode: 'USD',
      currencyBreakdown: [
        CurrencyNetWorthData(
          currency: 'USD',
          totalAssets: 100000,
          totalLiabilities: 0,
          assetAccounts: [usdAccount],
          liabilityAccounts: const [],
        ),
        CurrencyNetWorthData(
          currency: 'EUR',
          totalAssets: 200000,
          totalLiabilities: 0,
          assetAccounts: [eurAccount],
          liabilityAccounts: const [],
        ),
      ],
    );

    await tester.pumpWidget(buildSubject(data));
    await tester.pumpAndSettle();

    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('EUR'), findsWidgets);
    expect(find.text('USD Checking'), findsOneWidget);
    expect(find.text('EUR Savings'), findsOneWidget);
  });
}
