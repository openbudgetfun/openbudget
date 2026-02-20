// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  final budgetId = UuidValue.fromString('00000000-0000-0000-0000-000000000001');

  Account makeAccount({
    required String id,
    required String name,
    required String currencyCode,
  }) => Account(
    id: UuidValue.fromString(id),
    name: name,
    accountType: 'checking',
    balanceCents: 0,
    currencyCode: currencyCode,
    budgetId: budgetId,
    onBudget: true,
    sortOrder: 0,
    isClosed: false,
  );

  final accounts = [
    makeAccount(
      id: '00000000-0000-0000-0000-000000000101',
      name: 'USD Checking',
      currencyCode: 'USD',
    ),
    makeAccount(
      id: '00000000-0000-0000-0000-000000000102',
      name: 'USD Savings',
      currencyCode: 'USD',
    ),
    makeAccount(
      id: '00000000-0000-0000-0000-000000000103',
      name: 'EUR Wallet',
      currencyCode: 'EUR',
    ),
  ];

  test('transferDestinationAccounts keeps only matching currency accounts', () {
    final fromId = accounts.first.id!.toString();
    final options = transferDestinationAccounts(
      accounts,
      fromAccountId: fromId,
    );

    expect(options.length, 2);
    expect(options.every((account) => account.currencyCode == 'USD'), isTrue);
  });

  test('transferDestinationAccounts returns all accounts when no source', () {
    final options = transferDestinationAccounts(accounts, fromAccountId: null);

    expect(options, hasLength(accounts.length));
  });

  test('transferCurrency falls back to USD without a selected source', () {
    final currency = transferCurrency(accounts, fromAccountId: null);

    expect(currency, CurrencyCode.usd);
  });

  test('transferCurrency matches selected source account currency', () {
    final fromId = accounts.last.id!.toString();
    final currency = transferCurrency(accounts, fromAccountId: fromId);

    expect(currency, CurrencyCode.eur);
  });

  test('parseTransferAmountCents respects decimal precision by currency', () {
    expect(parseTransferAmountCents('12.34', CurrencyCode.usd), 1234);
    expect(parseTransferAmountCents('12.34', CurrencyCode.jpy), 12);
    expect(parseTransferAmountCents('0.00000042', CurrencyCode.btc), 42);
  });
}
