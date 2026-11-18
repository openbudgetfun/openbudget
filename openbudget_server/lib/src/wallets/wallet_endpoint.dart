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
  ///
  /// The address is validated through the core parser before anything is
  /// stored or read. EVM wallets pass [scanNetworks], the networks each read
  /// covers; every other family reads its one network.
  Future<Wallet> connect(
    Session session,
    UuidValue entityId,
    WalletNetwork network,
    String address, {
    String? label,
    String? accountName,
    List<WalletNetwork>? scanNetworks,
  }) => WalletService.connect(
    session,
    entityId,
    network,
    address,
    label: label,
    accountName: accountName,
    scanNetworks: scanNetworks,
  );

  /// Reads what one address holds across its family's supported networks,
  /// before connecting. Nothing is written. Rate limited to 20 reads an
  /// hour per user; the 21st is rejected.
  Future<WalletPreview> preview(
    Session session,
    UuidValue entityId,
    String address,
  ) => WalletService.preview(session, entityId, address);

  /// The networks that can be read now: each one's family has a registered
  /// provider and its secret is present.
  Future<List<WalletNetwork>> supportedNetworks(Session session) async =>
      WalletService.supportedNetworks(session);

  /// Replaces the networks an EVM wallet reads; null reads its home network
  /// only. A changed set is read at once: an added network shows its
  /// holdings, a removed one loses its holdings and read state, and the
  /// valuation follows, before this answers.
  Future<Wallet> setScanNetworks(
    Session session,
    UuidValue walletId,
    List<WalletNetwork>? networks,
  ) => WalletService.setScanNetworks(session, walletId, networks);

  /// One row per network of the wallet: when its holdings were last read
  /// and why the last read failed.
  Future<List<WalletNetworkState>> listNetworkStates(
    Session session,
    UuidValue walletId,
  ) => WalletService.listNetworkStates(session, walletId);

  /// Lists the wallets of one owned entity.
  Future<List<Wallet>> list(Session session, UuidValue entityId) =>
      WalletService.list(session, entityId);

  /// Loads the wallet that values one owned account, if any.
  Future<Wallet?> getForAccount(Session session, UuidValue accountId) =>
      WalletService.getForAccount(session, accountId);

  /// Fetches the chain and commits holdings, transactions and the valuation.
  Future<WalletSyncResult> sync(
    Session session,
    UuidValue walletId,
  ) => WalletService.sync(session, walletId);

  /// Lists the wallet's persisted holdings.
  Future<List<WalletHolding>> listHoldings(
    Session session,
    UuidValue walletId,
  ) => WalletService.listHoldings(session, walletId);

  /// Sets a user verdict on one holding: hide it, allow it, or clear the
  /// override and let the classifier decide.
  Future<WalletHolding> setHoldingVerdict(
    Session session,
    UuidValue walletHoldingId,
    SpamVerdict? verdict,
  ) => WalletService.setHoldingVerdict(
    session,
    walletHoldingId,
    verdict,
  );

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
