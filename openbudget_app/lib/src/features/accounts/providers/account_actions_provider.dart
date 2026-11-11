import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_actions_provider.g.dart';

/// Create, edit, close and delete actions for accounts, plus valuations for
/// track-by-value accounts. Opening balances and dates become an opening
/// transaction or a first valuation on the server.
@riverpod
class AccountActions extends _$AccountActions {
  @override
  FutureOr<void> build() {}

  Future<Account> createAccount({
    required String entityId,
    required String name,
    required AccountKind kind,
    required String currencyCode,
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    String? institutionId,
    String? note,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      return await client.account.create(
        UuidValue.fromString(entityId),
        name,
        kind,
        currencyCode,
        balanceSource: balanceSource,
        onBudget: onBudget,
        openingBalanceMinor: openingBalanceMinor,
        openingDate: openingDate,
        institutionId: institutionId == null
            ? null
            : UuidValue.fromString(institutionId),
        note: note,
      );
    } finally {
      ref.invalidate(accountListProvider(entityId));
    }
  }

  Future<Account> updateAccount({
    required String accountId,
    required String entityId,
    String? name,
    AccountKind? kind,
    bool? onBudget,
    String? institutionId,
    bool clearInstitution = false,
    String? note,
    int? sortOrder,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final account = await client.account.update(
      UuidValue.fromString(accountId),
      name: name,
      kind: kind,
      onBudget: onBudget,
      institutionId: institutionId == null
          ? null
          : UuidValue.fromString(institutionId),
      clearInstitution: clearInstitution,
      note: note,
      sortOrder: sortOrder,
    );
    ref.invalidate(accountListProvider(entityId));
    return account;
  }

  Future<Account> closeAccount({
    required String accountId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final account = await client.account.close(UuidValue.fromString(accountId));
    ref.invalidate(accountListProvider(entityId));
    return account;
  }

  Future<Account> reopenAccount({
    required String accountId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final account = await client.account.reopen(
      UuidValue.fromString(accountId),
    );
    ref.invalidate(accountListProvider(entityId));
    return account;
  }

  Future<void> deleteAccount({
    required String accountId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      await client.account.delete(UuidValue.fromString(accountId));
    } finally {
      ref.invalidate(accountListProvider(entityId));
    }
  }

  /// Records or replaces the valuation for the latest date of a
  /// track-by-value account.
  Future<AccountValuation> setValuation({
    required String accountId,
    required String entityId,
    required DateTime valuationDate,
    required int valueMinor,
    String? note,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final valuation = await client.account.setValuation(
      UuidValue.fromString(accountId),
      valuationDate,
      valueMinor,
      note: note,
    );
    ref
      ..invalidate(accountListProvider(entityId))
      ..invalidate(accountValuationsProvider(accountId));
    return valuation;
  }

  Future<void> deleteValuation({
    required String valuationId,
    required String accountId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.account.deleteValuation(UuidValue.fromString(valuationId));
    ref
      ..invalidate(accountListProvider(entityId))
      ..invalidate(accountValuationsProvider(accountId));
  }
}
