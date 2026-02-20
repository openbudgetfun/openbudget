import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'net_worth_provider.g.dart';

/// Computes net worth from all active accounts in a budget.
@riverpod
Future<NetWorthData> netWorth(Ref ref, String budgetId) async {
  final accounts = await ref.watch(accountListProvider(budgetId).future);
  final activeAccounts = accounts.where((account) => !account.isClosed);

  final byCurrency = <CurrencyCode, _CurrencyAccumulator>{};

  for (final account in activeAccounts) {
    final currency = parseCurrencyCode(account.currencyCode);
    final bucket = byCurrency.putIfAbsent(currency, _CurrencyAccumulator.new);

    if (account.accountType == 'creditCard') {
      bucket.totalLiabilities += account.balanceCents;
      bucket.liabilityAccounts.add(account);
    } else {
      bucket.totalAssets += account.balanceCents;
      bucket.assetAccounts.add(account);
    }
  }

  final breakdown =
      byCurrency.entries
          .map(
            (entry) => CurrencyNetWorthData(
              currency: entry.key,
              totalAssets: entry.value.totalAssets,
              totalLiabilities: entry.value.totalLiabilities,
              assetAccounts: List<Account>.unmodifiable(
                entry.value.assetAccounts,
              ),
              liabilityAccounts: List<Account>.unmodifiable(
                entry.value.liabilityAccounts,
              ),
            ),
          )
          .toList()
        ..sort((a, b) => a.currency.code.compareTo(b.currency.code));

  final primaryTotals = breakdown.length == 1 ? breakdown.first : null;

  final totalAssets = primaryTotals?.totalAssets ?? 0;
  final totalLiabilities = primaryTotals?.totalLiabilities ?? 0;

  return NetWorthData(
    totalAssets: totalAssets,
    totalLiabilities: totalLiabilities,
    netWorth: primaryTotals?.netWorth ?? 0,
    assetAccounts: List<Account>.unmodifiable(
      breakdown.expand((entry) => entry.assetAccounts),
    ),
    liabilityAccounts: List<Account>.unmodifiable(
      breakdown.expand((entry) => entry.liabilityAccounts),
    ),
    currencyCode: breakdown.isNotEmpty
        ? breakdown.first.currency.code
        : CurrencyCode.usd.code,
    currencyBreakdown: List<CurrencyNetWorthData>.unmodifiable(breakdown),
  );
}

class CurrencyNetWorthData {
  const CurrencyNetWorthData({
    required this.currency,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.assetAccounts,
    required this.liabilityAccounts,
  });

  final CurrencyCode currency;
  final int totalAssets;
  final int totalLiabilities;
  final List<Account> assetAccounts;
  final List<Account> liabilityAccounts;

  int get netWorth => totalAssets + totalLiabilities;
}

class NetWorthData {
  const NetWorthData({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.assetAccounts,
    required this.liabilityAccounts,
    required this.currencyCode,
    required this.currencyBreakdown,
  });

  final int totalAssets;
  final int totalLiabilities;
  final int netWorth;
  final List<Account> assetAccounts;
  final List<Account> liabilityAccounts;
  final String currencyCode;
  final List<CurrencyNetWorthData> currencyBreakdown;

  bool get hasMultipleCurrencies => currencyBreakdown.length > 1;
}

class _CurrencyAccumulator {
  int totalAssets = 0;
  int totalLiabilities = 0;
  final assetAccounts = <Account>[];
  final liabilityAccounts = <Account>[];
}
