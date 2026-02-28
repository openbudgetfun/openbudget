import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'solana_wallet_provider.g.dart';

@riverpod
Future<SolanaWallet?> accountSolanaWallet(
  Ref ref,
  String budgetId,
  String accountId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final accountUuid = UuidValue.fromString(accountId);

  return client.solanaWallet.getForAccount(budgetUuid, accountUuid);
}

@riverpod
Future<List<SolanaWalletHolding>> solanaWalletHoldings(
  Ref ref,
  String budgetId,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final walletUuid = UuidValue.fromString(walletId);

  return client.solanaWallet.listHoldings(budgetUuid, walletUuid);
}

@riverpod
Future<List<SolanaWalletTransaction>> solanaWalletTransactions(
  Ref ref,
  String budgetId,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final walletUuid = UuidValue.fromString(walletId);

  return client.solanaWallet.listTransactions(
    budgetUuid,
    walletUuid,
    limit: 200,
  );
}

@riverpod
Future<List<SolanaWalletTaxYearSummary>> solanaWalletTaxYearSummaries(
  Ref ref,
  String budgetId,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final walletUuid = UuidValue.fromString(walletId);

  return client.solanaWallet.listTaxYearSummaries(budgetUuid, walletUuid);
}

@riverpod
class SolanaWalletActions extends _$SolanaWalletActions {
  @override
  FutureOr<void> build() {}

  Future<SolanaWalletSyncResult> syncWallet({
    required String budgetId,
    required String walletId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final budgetUuid = UuidValue.fromString(budgetId);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final walletUuid = UuidValue.fromString(walletId);

    final result = await client.solanaWallet.sync(
      budgetUuid,
      walletUuid,
      limit: 200,
    );

    ref
      ..invalidate(solanaWalletTransactionsProvider(budgetId, walletId))
      ..invalidate(solanaWalletHoldingsProvider(budgetId, walletId))
      ..invalidate(solanaWalletTaxYearSummariesProvider(budgetId, walletId))
      ..invalidate(accountListProvider(budgetId));

    return result;
  }

  Future<SolanaWalletTransaction> updateTransactionMetadata({
    required String budgetId,
    required String transactionId,
    required String walletId,
    String? category,
    String? tagsCsv,
    String? memo,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final budgetUuid = UuidValue.fromString(budgetId);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final transactionUuid = UuidValue.fromString(transactionId);

    final result = await client.solanaWallet.updateTransactionMetadata(
      budgetUuid,
      transactionUuid,
      category: category,
      tagsCsv: tagsCsv,
      memo: memo,
    );

    ref.invalidate(solanaWalletTransactionsProvider(budgetId, walletId));
    return result;
  }
}
