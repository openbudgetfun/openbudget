import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Maintains valuation history and its current cache in a single transaction.
abstract final class AccountValuationService {
  /// Upserts the day's value after checking ownership and the account source.
  static Future<AccountValuation> set(
    Session session,
    UuidValue accountId,
    DateTime date,
    int valueMinor, {
    String? note,
  }) async {
    final result = await session.db.transaction((tx) async {
      final account = await Account.db.findById(
        session,
        accountId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (account == null) throw NotFoundException();
      final entity = await EntityAccess.requireOwned(
        session,
        account.entityId,
        transaction: tx,
      );
      if (account.balanceSource != AccountBalanceSource.valuations ||
          !isCivilDate(date) ||
          date.isAfter(EntityClock.today(entity)) ||
          valueMinor.abs() > 9007199254740991) {
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
                source: ValuationSource.manual,
                note: note,
              ),
              transaction: tx,
            )
          : await AccountValuation.db.updateRow(
              session,
              existing.copyWith(
                valueMinor: valueMinor,
                source: ValuationSource.manual,
                note: note,
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
    });
    await EntityRealtimeNotifier.notify(
      session,
      result.$2,
      ChangeScope.accounts,
      accountId: accountId,
    );
    return result.$1;
  }

  /// Deletes a value and falls back to the previous date or zero.
  static Future<void> delete(Session session, UuidValue valuationId) async {
    final result = await session.db.transaction((tx) async {
      final value = await AccountValuation.db.findById(
        session,
        valuationId,
        transaction: tx,
      );
      if (value == null) throw NotFoundException();
      final account = await Account.db.findById(
        session,
        value.accountId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (account == null) throw NotFoundException();
      await EntityAccess.requireOwned(
        session,
        account.entityId,
        transaction: tx,
      );
      await AccountValuation.db.deleteRow(session, value, transaction: tx);
      await AccountBalanceService.refreshValuation(
        session,
        account.id!,
        transaction: tx,
      );
      return account;
    });
    await EntityRealtimeNotifier.notify(
      session,
      result.entityId,
      ChangeScope.accounts,
      accountId: result.id,
    );
  }
}
