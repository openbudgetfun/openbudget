import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for read-only blockchain wallets.
///
/// Every method requires a signed-in caller and lets [WalletService] cross
/// [EntityAccess] before touching a wallet, account or transaction.
class WalletEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates the wallet and its crypto account in one transaction, then syncs.
  Future<Wallet> connect(
    Session session,
    UuidValue entityId,
    WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
  }) => WalletService.connect(
    session,
    entityId,
    network,
    address,
    label: label,
    accountName: accountName,
  );

  /// Lists the wallets of one owned entity.
  Future<List<Wallet>> list(Session session, UuidValue entityId) =>
      WalletService.list(session, entityId);

  /// Loads the wallet that values one owned account, if any.
  Future<Wallet?> getForAccount(Session session, UuidValue accountId) =>
      WalletService.getForAccount(session, accountId);

  /// Fetches the chain and commits holdings, transactions and the valuation.
  Future<WalletSyncResult> sync(Session session, UuidValue walletId) =>
      WalletService.sync(session, walletId);

  /// Lists the wallet's persisted holdings.
  Future<List<WalletHolding>> listHoldings(
    Session session,
    UuidValue walletId,
  ) => WalletService.listHoldings(session, walletId);

  /// Lists the wallet's transactions, newest first.
  Future<List<WalletTransaction>> listTransactions(
    Session session,
    UuidValue walletId, {
    DateTime? before,
    int? limit,
  }) => WalletService.listTransactions(
    session,
    walletId,
    before: before,
    limit: limit,
  );

  /// Groups estimated realised P&L by fiscal year and currency.
  Future<List<WalletTaxYearSummary>> listTaxYearSummaries(
    Session session,
    UuidValue walletId,
  ) => WalletService.listTaxYearSummaries(session, walletId);

  /// Replaces category, tags and memo on one wallet transaction.
  Future<WalletTransaction> updateTransactionMetadata(
    Session session,
    UuidValue walletTransactionId, {
    String? category,
    List<String>? tags,
    String? memo,
  }) => WalletService.updateTransactionMetadata(
    session,
    walletTransactionId,
    category: category,
    tags: tags,
    memo: memo,
  );

  /// Deletes the wallet; deleteAccount also deletes the crypto account and its
  /// protections apply.
  Future<void> disconnect(
    Session session,
    UuidValue walletId, {
    bool? deleteAccount,
  }) => WalletService.disconnect(
    session,
    walletId,
    deleteAccount: deleteAccount,
  );
}
