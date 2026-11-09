import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// The only writer of cached balances; every method requires the writing tx.
abstract final class AccountBalanceService {
  /// Adds a movement while holding the account row lock.
  static Future<void> applyDelta(
    Session session,
    UuidValue accountId,
    int delta, {
    required Transaction transaction,
  }) async {
    if (delta.abs() > 9007199254740991) {
      throw ValidationException(message: 'Delta exceeds safe minor unit range');
    }
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (account == null ||
        account.balanceSource != AccountBalanceSource.transactions) {
      throw StateError('Transaction balance requires a transactions account');
    }
    await _set(session, account, account.balanceMinor + delta, transaction);
  }

  static Future<void> _set(
    Session session,
    Account account,
    int amount,
    Transaction tx,
  ) async {
    if (amount.abs() > 9007199254740991) {
      throw ValidationException(
        message: 'Balance exceeds safe minor unit range',
      );
    }
    await Account.db.updateRow(
      session,
      account.copyWith(balanceMinor: amount, updatedAt: DateTime.now().toUtc()),
      transaction: tx,
    );
  }

  /// Recomputes either source from persisted facts under the caller's lock.
  static Future<int> recompute(
    Session session,
    Account account, {
    required Transaction transaction,
  }) async {
    if (account.balanceSource == AccountBalanceSource.valuations) {
      final value = await AccountValuation.db.findFirstRow(
        session,
        where: (t) => t.accountId.equals(account.id),
        orderBy: (t) => t.valuationDate.desc(),
        transaction: transaction,
      );
      return value?.valueMinor ?? 0;
    }
    final rows = await session.db.unsafeQuery(
      'SELECT COALESCE(SUM("amountMinor"), 0)::bigint FROM "transaction" WHERE "accountId" = @id',
      parameters: QueryParameters.named({'id': account.id}),
      transaction: transaction,
    );
    return rows.first.first as int;
  }

  /// Refreshes the latest valuation atomically with its insert/edit/delete.
  static Future<void> refreshValuation(
    Session session,
    UuidValue accountId, {
    required Transaction transaction,
  }) async {
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (account == null ||
        account.balanceSource != AccountBalanceSource.valuations) {
      throw StateError('Valuation balance requires a valuations account');
    }
    await _set(
      session,
      account,
      await recompute(session, account, transaction: transaction),
      transaction,
    );
  }

  /// Detects and repairs drift, rechecking each account under its row lock.
  static Future<int> verify(Session session) async {
    final drift = await session.db.unsafeQuery('''
SELECT a.id::text
FROM account a
JOIN LATERAL (
  SELECT CASE a."balanceSource"
    WHEN 'transactions' THEN
      (SELECT COALESCE(SUM(t."amountMinor"), 0) FROM "transaction" t WHERE t."accountId" = a.id)
    ELSE
      COALESCE((SELECT v."valueMinor" FROM account_valuation v
        WHERE v."accountId" = a.id ORDER BY v."valuationDate" DESC LIMIT 1), 0)
  END AS actual
) s ON true
WHERE a."balanceMinor" <> s.actual''');
    var repaired = 0;
    for (final row in drift) {
      final id = UuidValue.fromString(row.first as String);
      final changed = await session.db.transaction((tx) async {
        final account = await Account.db.findById(
          session,
          id,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (account == null) return null;
        final actual = await recompute(session, account, transaction: tx);
        if (actual == account.balanceMinor) return null;
        await _set(session, account, actual, tx);
        await AuditEvent.db.insertRow(
          session,
          AuditEvent(
            entityId: account.entityId,
            actorId: UuidValue.fromString(
              '00000000-0000-0000-0000-000000000000',
            ),
            action: AuditAction.balanceRepaired,
            subjectType: AuditSubject.account,
            subjectId: account.id,
            payloadJson: jsonEncode({
              'cached': account.balanceMinor,
              'actual': actual,
            }),
          ),
          transaction: tx,
        );
        session.log(
          'Repaired balance drift for account ${account.id}',
          level: LogLevel.error,
        );
        return account;
      });
      if (changed != null) {
        repaired++;
        await EntityRealtimeNotifier.notify(
          session,
          changed.entityId,
          ChangeScope.accounts,
          accountId: changed.id,
        );
      }
    }
    return repaired;
  }
}
