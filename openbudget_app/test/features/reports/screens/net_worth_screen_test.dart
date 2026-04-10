// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';
  final budgetUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );

  Account makeAccount({
    required String name,
    required int balanceCents,
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
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: budgetUuid,
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
      home: const NetWorthScreen(budgetId: budgetId),
    ),
  );

  testWidgets('renders single-currency net worth summary', (tester) async {
    final usdAccount = makeAccount(
      name: 'USD Checking',
      balanceCents: 120000,
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
          currency: CurrencyCode.usd,
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
      balanceCents: 100000,
      currencyCode: 'USD',
    );
    final eurAccount = makeAccount(
      name: 'EUR Savings',
      balanceCents: 200000,
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
          currency: CurrencyCode.usd,
          totalAssets: 100000,
          totalLiabilities: 0,
          assetAccounts: [usdAccount],
          liabilityAccounts: const [],
        ),
        CurrencyNetWorthData(
          currency: CurrencyCode.eur,
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
