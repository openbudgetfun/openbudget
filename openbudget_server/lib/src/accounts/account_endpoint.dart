import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for account operations.
///
/// All methods require authentication and cross [AccountService] for the
/// entity-ownership check.
class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates an account and its opening balance or first valuation.
  Future<Account> create(
    Session session,
    UuidValue entityId,
    String name,
    AccountKind kind,
    String currencyCode, {
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    UuidValue? institutionId,
    String? note,
  }) => AccountService.create(
    session,
    entityId,
    name,
    kind,
    currencyCode,
    balanceSource: balanceSource,
    onBudget: onBudget,
    openingBalanceMinor: openingBalanceMinor,
    openingDate: openingDate,
    institutionId: institutionId,
    note: note,
  );

  /// Lists every account of one owned entity.
  Future<List<Account>> list(Session session, UuidValue entityId) =>
      AccountService.list(session, entityId);

  /// Lists every account in every entity the caller owns.
  Future<List<Account>> listAll(Session session) =>
      AccountService.listAll(session);

  /// Loads one owned account.
  Future<Account> get(Session session, UuidValue accountId) =>
      AccountService.get(session, accountId);

  /// Updates mutable account metadata.
  Future<Account> update(
    Session session,
    UuidValue accountId, {
    String? name,
    AccountKind? kind,
    bool? onBudget,
    UuidValue? institutionId,
    bool? clearInstitution,
    String? note,
    int? sortOrder,
  }) => AccountService.update(
    session,
    accountId,
    name: name,
    kind: kind,
    onBudget: onBudget,
    institutionId: institutionId,
    clearInstitution: clearInstitution ?? false,
    note: note,
    sortOrder: sortOrder,
  );

  /// Replaces the account order of one owned entity.
  Future<List<Account>> reorder(
    Session session,
    UuidValue entityId,
    List<UuidValue> accountIds,
  ) => AccountService.reorder(session, entityId, accountIds);

  /// Closes an account whose balance is zero.
  Future<Account> close(Session session, UuidValue accountId) =>
      AccountService.close(session, accountId);

  /// Reopens a closed account.
  Future<Account> reopen(Session session, UuidValue accountId) =>
      AccountService.reopen(session, accountId);

  /// Deletes the account, its transactions and its valuations.
  Future<void> delete(Session session, UuidValue accountId) =>
      AccountService.delete(session, accountId);

  /// Returns the cached and cleared balances of one account.
  Future<AccountBalancesView> getBalances(
    Session session,
    UuidValue accountId,
  ) => AccountService.getBalances(session, accountId);

  /// Lists one account's valuations newest-first.
  Future<List<AccountValuation>> listValuations(
    Session session,
    UuidValue accountId,
  ) => AccountService.listValuations(session, accountId);

  /// Upserts one manual valuation.
  Future<AccountValuation> setValuation(
    Session session,
    UuidValue accountId,
    DateTime valuationDate,
    int valueMinor, {
    String? note,
  }) => AccountService.setValuation(
    session,
    accountId,
    valuationDate,
    valueMinor,
    note: note,
  );

  /// Deletes one valuation and recomputes the account balance.
  Future<void> deleteValuation(Session session, UuidValue valuationId) =>
      AccountService.deleteValuation(session, valuationId);
}
