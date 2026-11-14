import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_provider.g.dart';

/// The crypto wallets of one entity, merged Solana and generic surface on
/// `client.wallet`.
@riverpod
Future<List<Wallet>> walletList(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.list(UuidValue.fromString(entityId));
}

/// The wallet that values one account, if any.
@riverpod
Future<Wallet?> walletForAccount(Ref ref, String accountId) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.getForAccount(UuidValue.fromString(accountId));
}

/// The wallet's persisted holdings.
@riverpod
Future<List<WalletHolding>> walletHoldings(Ref ref, String walletId) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.listHoldings(UuidValue.fromString(walletId));
}

/// How the last read of each of the wallet's networks went: when it
/// succeeded, and why it failed.
@riverpod
Future<List<WalletNetworkState>> walletNetworkStates(
  Ref ref,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.listNetworkStates(UuidValue.fromString(walletId));
}

/// The wallet's on-chain transactions, newest first.
@riverpod
Future<List<WalletTransaction>> walletTransactions(
  Ref ref,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.listTransactions(UuidValue.fromString(walletId));
}

/// Estimated realised P&L grouped by fiscal year and currency.
@riverpod
Future<List<WalletTaxYearSummary>> walletTaxYearSummaries(
  Ref ref,
  String walletId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.wallet.listTaxYearSummaries(UuidValue.fromString(walletId));
}

/// Wallet mutations. Kept alive so the invalidations that follow each await
/// still reach the providers they refresh: an auto-disposed notifier is
/// unmounted by then and its `ref.invalidate` does nothing.
@Riverpod(keepAlive: true)
class WalletActions extends _$WalletActions {
  @override
  FutureOr<void> build() {}

  /// Connects a wallet; the server creates its crypto account and syncs.
  Future<Wallet> connect({
    required String entityId,
    required WalletNetwork network,
    required String address,
    String? label,
    String? accountName,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final wallet = await client.wallet.connect(
      UuidValue.fromString(entityId),
      network,
      address,
      label: label,
      accountName: accountName,
    );
    ref.invalidate(walletListProvider(entityId));
    return wallet;
  }

  Future<WalletSyncResult> sync({
    required String walletId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final result = await client.wallet.sync(UuidValue.fromString(walletId));
    ref
      ..invalidate(walletListProvider(entityId))
      ..invalidate(walletHoldingsProvider(walletId))
      ..invalidate(walletNetworkStatesProvider(walletId))
      ..invalidate(walletTransactionsProvider(walletId))
      ..invalidate(walletTaxYearSummariesProvider(walletId));
    return result;
  }

  /// Hides or shows holdings by setting the user's verdict on each, then
  /// refreshes the wallet's holdings. [verdict] of
  /// [SpamVerdict.hiddenByUser] hides; [SpamVerdict.allowedByUser] shows.
  ///
  /// The holdings are refreshed even when a call fails part-way, so the
  /// screen shows what the server now holds.
  Future<void> setHoldingVerdicts({
    required String walletId,
    required List<UuidValue> holdingIds,
    required SpamVerdict verdict,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      for (final holdingId in holdingIds) {
        await client.wallet.setHoldingVerdict(holdingId, verdict);
      }
    } finally {
      ref.invalidate(walletHoldingsProvider(walletId));
    }
  }

  Future<WalletTransaction> updateTransactionMetadata({
    required String walletTransactionId,
    required String walletId,
    String? category,
    List<String>? tags,
    String? memo,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final updated = await client.wallet.updateTransactionMetadata(
      UuidValue.fromString(walletTransactionId),
      category: category,
      tags: tags,
      memo: memo,
    );
    ref.invalidate(walletTransactionsProvider(walletId));
    return updated;
  }

  Future<void> disconnect({
    required String walletId,
    required String entityId,
    bool deleteAccount = false,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.wallet.disconnect(
      UuidValue.fromString(walletId),
      deleteAccount: deleteAccount,
    );
    ref.invalidate(walletListProvider(entityId));
  }
}
