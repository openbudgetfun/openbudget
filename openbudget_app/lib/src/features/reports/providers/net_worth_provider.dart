import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'net_worth_provider.g.dart';

/// Computes net worth from all accounts in a budget.
@riverpod
Future<NetWorthData> netWorth(Ref ref, String budgetId) async {
  final accounts = await ref.watch(accountListProvider(budgetId).future);

  var totalAssets = 0;
  var totalLiabilities = 0;
  final assetAccounts = <Account>[];
  final liabilityAccounts = <Account>[];

  for (final account in accounts) {
    if (account.isClosed) continue;

    if (account.accountType == 'creditCard') {
      // Credit card balances are liabilities (typically negative).
      totalLiabilities += account.balanceCents;
      liabilityAccounts.add(account);
    } else {
      totalAssets += account.balanceCents;
      assetAccounts.add(account);
    }
  }

  return NetWorthData(
    totalAssets: totalAssets,
    totalLiabilities: totalLiabilities,
    netWorth: totalAssets + totalLiabilities,
    assetAccounts: assetAccounts,
    liabilityAccounts: liabilityAccounts,
    currencyCode: accounts.isNotEmpty ? accounts.first.currencyCode : 'USD',
  );
}

class NetWorthData {
  const NetWorthData({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.assetAccounts,
    required this.liabilityAccounts,
    required this.currencyCode,
  });

  final int totalAssets;
  final int totalLiabilities;
  final int netWorth;
  final List<Account> assetAccounts;
  final List<Account> liabilityAccounts;
  final String currencyCode;
}
