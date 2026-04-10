import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/solana_wallets/solana_wallet_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for Solana wallet operations.
class SolanaWalletEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Attaches (or updates) a Solana wallet to an account.
  Future<SolanaWallet> attach(
    Session session,
    UuidValue budgetId,
    UuidValue accountId,
    String address, {
    String? label,
    String cluster = 'mainnet',
  }) async {
    final wallet = await SolanaWalletService.attachWallet(
      session,
      budgetId: budgetId,
      accountId: accountId,
      address: address,
      label: label,
      cluster: cluster,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(wallet.budgetId);
    return wallet;
  }

  /// Returns all Solana wallets for a budget.
  Future<List<SolanaWallet>> list(Session session, UuidValue budgetId) async =>
      SolanaWalletService.listForBudget(session, budgetId: budgetId);

  /// Returns wallet metadata for an account.
  Future<SolanaWallet?> getForAccount(
    Session session,
    UuidValue budgetId,
    UuidValue accountId,
  ) async => SolanaWalletService.getForAccount(
    session,
    budgetId: budgetId,
    accountId: accountId,
  );

  /// Syncs recent chain activity and holdings for the wallet.
  Future<SolanaWalletSyncResult> sync(
    Session session,
    UuidValue budgetId,
    UuidValue walletId, {
    int limit = 200,
  }) async {
    final syncResult = await SolanaWalletService.syncWallet(
      session,
      budgetId: budgetId,
      walletId: walletId,
      limit: limit,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return syncResult;
  }

  /// Lists parsed wallet transactions.
  Future<List<SolanaWalletTransaction>> listTransactions(
    Session session,
    UuidValue budgetId,
    UuidValue walletId, {
    int limit = 100,
  }) async => SolanaWalletService.listTransactions(
    session,
    budgetId: budgetId,
    walletId: walletId,
    limit: limit,
  );

  /// Lists current wallet holdings.
  Future<List<SolanaWalletHolding>> listHoldings(
    Session session,
    UuidValue budgetId,
    UuidValue walletId,
  ) async => SolanaWalletService.listHoldings(
    session,
    budgetId: budgetId,
    walletId: walletId,
  );

  /// Returns estimated realized wallet P&L grouped by tax year.
  Future<List<SolanaWalletTaxYearSummary>> listTaxYearSummaries(
    Session session,
    UuidValue budgetId,
    UuidValue walletId,
  ) async => SolanaWalletService.listTaxYearSummaries(
    session,
    budgetId: budgetId,
    walletId: walletId,
  );

  /// Updates category/tags/memo for a wallet transaction.
  Future<SolanaWalletTransaction> updateTransactionMetadata(
    Session session,
    UuidValue budgetId,
    UuidValue transactionId, {
    String? category,
    String? tagsCsv,
    String? memo,
  }) async {
    final transaction = await SolanaWalletService.updateTransactionMetadata(
      session,
      budgetId: budgetId,
      transactionId: transactionId,
      category: category,
      tagsCsv: tagsCsv,
      memo: memo,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }
}
