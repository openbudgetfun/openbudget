import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for read-only blockchain wallet account integration.
class WalletEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Connects a Solana wallet and imports holdings as a synced account.
  Future<WalletConnectResult> connectSolanaWallet(
    Session session,
    UuidValue budgetId,
    String address, {
    String? label,
    bool onBudget = false,
  }) async {
    final result = await WalletService.connectSolanaWallet(
      session,
      budgetId: budgetId,
      address: address,
      label: label,
      onBudget: onBudget,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return result;
  }

  /// Refreshes holdings and account balance for a wallet connection.
  Future<WalletConnectResult> refreshSolanaWallet(
    Session session,
    UuidValue budgetId,
    UuidValue connectionId,
  ) async {
    final result = await WalletService.refreshSolanaWallet(
      session,
      budgetId: budgetId,
      connectionId: connectionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return result;
  }

  /// Returns the latest persisted holdings for a wallet connection.
  Future<List<WalletHolding>> listWalletHoldings(
    Session session,
    UuidValue budgetId,
    UuidValue connectionId,
  ) async => WalletService.listHoldings(
    session,
    budgetId: budgetId,
    connectionId: connectionId,
  );
}
