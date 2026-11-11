import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

void main() {
  const entityId = 'test-budget-1';
  final budgetUuid = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );

  Account makeAccount({
    required String name,
    required int balanceMinor,
    required String currencyCode,
    String accountType = 'checking',
    bool isClosed = false,
  }) => Account(
    name: name,
    accountType: accountType,
    balanceMinor: balanceMinor,
    currencyCode: currencyCode,
    entityId: budgetUuid,
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
              balanceMinor: 150000,
              currencyCode: 'USD',
            ),
            makeAccount(
              name: 'EUR Savings',
              balanceMinor: 120000,
              currencyCode: 'EUR',
            ),
            makeAccount(
              name: 'EUR Card',
              balanceMinor: -30000,
              currencyCode: 'EUR',
              accountType: 'creditCard',
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(netWorthProvider(entityId).future);

    expect(data.hasMultipleCurrencies, isTrue);
    expect(data.currencyBreakdown.length, 2);
    expect(data.totalAssets, 0);
    expect(data.totalLiabilities, 0);
    expect(data.netWorth, 0);

    final usd = data.currencyBreakdown.firstWhere(
      (entry) => entry.currency == 'USD',
    );
    final eur = data.currencyBreakdown.firstWhere(
      (entry) => entry.currency == 'EUR',
    );

    expect(usd.totalAssets, 150000);
    expect(usd.totalLiabilities, 0);
    expect(eur.totalAssets, 120000);
    expect(eur.totalLiabilities, -30000);
    expect(eur.netWorth, 90000);
  });

  test('keeps aggregate totals for single-currency budgets', () async {
    final container = ProviderContainer(
      overrides: [
        accountListProvider.overrideWith(
          (ref, id) async => [
            makeAccount(
              name: 'Main Checking',
              balanceMinor: 150000,
              currencyCode: 'USD',
            ),
            makeAccount(
              name: 'Credit Card',
              balanceMinor: -25000,
              currencyCode: 'USD',
              accountType: 'creditCard',
            ),
          ],
        ),
      ],
    );
    addTearDown(container.dispose);

    final data = await container.read(netWorthProvider(entityId).future);

    expect(data.hasMultipleCurrencies, isFalse);
    expect(data.currencyBreakdown.length, 1);
    expect(data.totalAssets, 150000);
    expect(data.totalLiabilities, -25000);
    expect(data.netWorth, 125000);
  });
}
