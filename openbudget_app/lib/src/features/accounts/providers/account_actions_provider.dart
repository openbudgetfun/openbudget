import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_actions_provider.g.dart';

@riverpod
class AccountActions extends _$AccountActions {
  @override
  FutureOr<void> build() {}

  Future<Account> createAccount({
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required String budgetId,
    required bool onBudget,
    required int sortOrder,
    String? walletAddress,
    String walletCluster = 'mainnet',
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final budgetUuid = UuidValue.fromString(budgetId);
    final account = await client.account.create(
      name,
      accountType,
      balanceCents,
      currencyCode,
      budgetUuid,
      onBudget: onBudget,
      sortOrder: sortOrder,
    );

    final normalizedWallet = walletAddress?.trim();
    if (normalizedWallet != null && normalizedWallet.isNotEmpty) {
      final accountId = account.id;
      if (accountId == null) {
        throw StateError('Created account did not return an ID');
      }

      final wallet = await client.solanaWallet.attach(
        budgetUuid,
        accountId,
        normalizedWallet,
        cluster: walletCluster,
      );
      await client.solanaWallet.sync(budgetUuid, wallet.id!, limit: 200);
    }

    ref.invalidate(accountListProvider(budgetId));
    return account;
  }

  Future<Account> updateAccount({
    required String accountId,
    required String budgetId,
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final account = await client.account.update(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(accountId),
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: isClosed,
    );
    ref.invalidate(accountListProvider(budgetId));
    return account;
  }

  Future<Account> deleteAccount({
    required String accountId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final deleted = await client.account.delete(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(accountId),
    );
    ref.invalidate(accountListProvider(budgetId));
    return deleted;
  }

  Future<Account> undoDeleteAccount({
    required Account deletedAccount,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final restored = await client.account.create(
      deletedAccount.name,
      deletedAccount.accountType,
      deletedAccount.balanceCents,
      deletedAccount.currencyCode,
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
      onBudget: deletedAccount.onBudget,
      sortOrder: deletedAccount.sortOrder,
    );
    ref.invalidate(accountListProvider(budgetId));
    return restored;
  }
}
