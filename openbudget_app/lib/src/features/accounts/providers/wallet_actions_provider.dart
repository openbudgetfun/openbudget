import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_actions_provider.g.dart';

@riverpod
class WalletActions extends _$WalletActions {
  @override
  FutureOr<void> build() {}

  Future<WalletConnectResult> connectSolanaWallet({
    required String budgetId,
    required String address,
    String? label,
    bool onBudget = false,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final result = await client.wallet.connectSolanaWallet(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
      address,
      label: label,
      onBudget: onBudget,
    );
    ref.invalidate(accountListProvider(budgetId));
    return result;
  }
}
