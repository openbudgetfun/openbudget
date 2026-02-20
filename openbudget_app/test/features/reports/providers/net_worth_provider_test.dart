// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  const budgetId = 'test-budget-1';
  final budgetUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );

  Account makeAccount({
    required String name,
    required int balanceCents,
    required String currencyCode,
    String accountType = 'checking',
    bool isClosed = false,
  }) => Account(
    name: name,
    accountType: accountType,
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: budgetUuid,
    onBudget: true,
    sortOrder: 0,
    isClosed: isClosed,
  );

  test('aggregates net worth by currency', () async {
    final container = ProviderContainer(
      overrides: [
        accountListProvider.overrideWith(
          (ref, id) async => [
            makeAccount(
              name: 'USD Checking',
              balanceCents: 150000,
              currencyCode: 'USD',
            ),
            makeAccount(
              name: 'EUR Savings',
              balanceCents: 120000,
              currencyCode: 'EUR',
            ),
            makeAccount(
              name: 'EUR Card',
              balanceCents: -30000,
              currencyCode: 'EUR',
              accountType: 'creditCard',
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(netWorthProvider(budgetId).future);

    expect(data.hasMultipleCurrencies, isTrue);
    expect(data.currencyBreakdown.length, 2);

    final usd = data.currencyBreakdown.firstWhere(
      (entry) => entry.currency == CurrencyCode.usd,
    );
    final eur = data.currencyBreakdown.firstWhere(
      (entry) => entry.currency == CurrencyCode.eur,
    );

    expect(usd.totalAssets, 150000);
    expect(usd.totalLiabilities, 0);
    expect(eur.totalAssets, 120000);
    expect(eur.totalLiabilities, -30000);
    expect(eur.netWorth, 90000);
  });
}
