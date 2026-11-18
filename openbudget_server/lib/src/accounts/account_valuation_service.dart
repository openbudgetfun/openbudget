import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Maintains valuation history and its current cache in a single transaction.
///
/// Callers publish the committed change after this returns; the service never
/// notifies inside its own transaction.
abstract final class AccountValuationService {
  /// Upserts the day's value after checking ownership, the account source and
  /// every lifecycle restriction that must hold before money can move.
  ///
  /// Returns the stored valuation and the entity that owns its account.
  static Future<(AccountValuation, UuidValue)> set(
    Session session,
    UuidValue accountId,
    DateTime date,
    int valueMinor, {
    String? note,
  }) => session.db.transaction((tx) async {
    final result = await setInTransaction(
      session,
      tx,
      accountId,
      date,
      valueMinor,
      source: ValuationSource.manual,
      note: note,
    );
    return result;
  });

  /// Upserts a valuation inside the caller's transaction without publishing.
  ///
  /// Wallet sync uses this with [ValuationSource.wallet] so the holdings,
  /// valuation and account balance cache commit or roll back together.
  static Future<(AccountValuation, UuidValue)> setInTransaction(
    Session session,
    Transaction tx,
    UuidValue accountId,
    DateTime date,
    int valueMinor, {
    required ValuationSource source,
    String? note,
  }) async {
    final account = await _lockAccount(session, accountId, tx);
    final entity = await _requireWritableEntity(session, account, tx);
    if (account.balanceSource != AccountBalanceSource.valuations ||
        !isCivilDate(date) ||
        date.year < 1900 ||
        date.isAfter(EntityClock.today(entity)) ||
        valueMinor < -maxSafeMinor ||
        valueMinor > maxSafeMinor) {
      throw ValidationException(message: 'Invalid account valuation');
    }

    final existing = await AccountValuation.db.findFirstRow(
      session,
      where: (t) =>
          t.accountId.equals(accountId) & t.valuationDate.equals(date),
      transaction: tx,
    );
    final value = existing == null
        ? await AccountValuation.db.insertRow(
            session,
            AccountValuation(
              accountId: accountId,
              valuationDate: date,
              valueMinor: valueMinor,
              source: source,
              note: _normaliseNote(note),
            ),
            transaction: tx,
          )
        : await AccountValuation.db.updateRow(
            session,
            existing.copyWith(
              valueMinor: valueMinor,
              source: source,
              note: _normaliseNote(note),
              updatedAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
    await AccountBalanceService.refreshValuation(
      session,
      accountId,
      transaction: tx,
    );
    return (value, account.entityId);
  }

  /// Deletes a value and falls back to the previous date or zero.
  ///
  /// Returns the owning entity and the account whose cache moved.
  static Future<(UuidValue, UuidValue)> delete(
    Session session,
    UuidValue valuationId,
  ) => session.db.transaction((tx) async {
    final value = await AccountValuation.db.findById(
      session,
      valuationId,
      transaction: tx,
    );
    if (value == null) throw NotFoundException();
    final account = await _lockAccount(session, value.accountId, tx);
    await _requireWritableEntity(session, account, tx);
    await AccountValuation.db.deleteRow(session, value, transaction: tx);
    await AccountBalanceService.refreshValuation(
      session,
      account.id!,
      transaction: tx,
    );
    return (account.entityId, account.id!);
  });

  static Future<Account> _lockAccount(
    Session session,
    UuidValue accountId,
    Transaction tx,
  ) async {
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) throw NotFoundException();
    return account;
  }

  static Future<Entity> _requireWritableEntity(
    Session session,
    Account account,
    Transaction tx,
  ) async {
    final entity = await EntityAccess.requireOwned(
      session,
      account.entityId,
      transaction: tx,
    );
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects account changes',
      );
    }
    if (account.closedAt != null) {
      throw ValidationException(
        message: 'A closed account rejects valuations',
      );
    }
    return entity;
  }

  static String? _normaliseNote(String? raw) {
    final note = raw?.trim();
    return note == null || note.isEmpty ? null : note;
  }
}
