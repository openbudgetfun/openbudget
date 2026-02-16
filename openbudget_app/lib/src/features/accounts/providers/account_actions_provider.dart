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
  }) async {
    final client = ref.read(serverpodClientProvider);
    final account = await client.account.create(
      name,
      accountType,
      balanceCents,
      currencyCode,
      UuidValue.fromString(budgetId),
      onBudget: onBudget,
      sortOrder: sortOrder,
    );
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

  Future<void> deleteAccount({
    required String accountId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.account.delete(UuidValue.fromString(accountId));
    ref.invalidate(accountListProvider(budgetId));
  }
}
