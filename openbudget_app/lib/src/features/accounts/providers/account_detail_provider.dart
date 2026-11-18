import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_detail_provider.g.dart';

/// One owned account.
@riverpod
Future<Account> accountDetail(Ref ref, String accountId) async {
  final client = ref.read(serverpodClientProvider);
  return client.account.get(UuidValue.fromString(accountId));
}

/// The account's cached and cleared balances, plus the bank's reported one.
@riverpod
Future<AccountBalancesView> accountBalances(Ref ref, String accountId) async {
  final client = ref.read(serverpodClientProvider);
  return client.account.getBalances(UuidValue.fromString(accountId));
}

/// The value history of a track-by-value account, newest first.
@riverpod
Future<List<AccountValuation>> accountValuations(
  Ref ref,
  String accountId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.account.listValuations(UuidValue.fromString(accountId));
}
