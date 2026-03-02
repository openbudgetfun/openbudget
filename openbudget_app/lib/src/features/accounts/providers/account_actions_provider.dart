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
    String? institutionId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
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
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        institutionId: institutionId == null
            ? null
            : UuidValue.fromString(institutionId),
      );

      final normalizedWallet = walletAddress?.trim();
      if (normalizedWallet != null && normalizedWallet.isNotEmpty) {
        // Wallet linking is handled by dedicated wallet flows.
      }

      return account;
    } finally {
      // Always refresh account lists, even when the response fails to decode.
      ref.invalidate(accountListProvider(budgetId));
    }
  }

  Future<Account> addMineToBudget({
    required String sourceAccountId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final added = await client.account.addMineToBudget(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(sourceAccountId),
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      UuidValue.fromString(budgetId),
    );
    ref.invalidate(accountListProvider(budgetId));
    return added;
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
    try {
      final deleted = await client.account.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(accountId),
      );
      return deleted;
    } finally {
      // Always refresh account lists, even when the response fails to decode.
      ref.invalidate(accountListProvider(budgetId));
    }
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
