import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Creates the ledger account that mirrors a money account and links the two.
///
/// `Account.ledgerAccountId` is the only link between the two charts. The
/// mirror carries no [LedgerSystemRole]: structural roles are single-account
/// controls, while every bank, card and loan account needs its own ledger
/// row. A foreign-currency money account's mirror carries the account
/// currency; a base-currency one leaves it null.
///
/// Callers must already hold the entity write lock for the rest of their
/// transaction, so two concurrent writers cannot allocate the same code.
abstract final class LedgerAccountLinker {
  /// Lowest illustrative code used for a money account's mirror.
  ///
  /// Codes are user-visible labels, never keys. Allocation is deterministic:
  /// the lowest free integer at or above this value, in account display
  /// order. The unique `(entityId, code)` index is the final guard.
  static const int firstMirrorCode = 1000;

  /// Creates and links the mirror for [account] when it is a transactions
  /// account that has no link yet.
  ///
  /// Valuations-sourced accounts are not money accounts: their value comes
  /// from valuations, not posted bank movements, so they get no mirror.
  static Future<Account> attachMoneyAccount(
    Session session,
    Transaction transaction, {
    required Entity entity,
    required Account account,
    required UuidValue actorId,
  }) async {
    assert(
      account.entityId == entity.id,
      'The money account belongs to another entity.',
    );
    if (account.balanceSource != AccountBalanceSource.transactions) {
      return account;
    }
    if (account.ledgerAccountId != null) return account;

    final chart = await LedgerAccount.db.find(
      session,
      where: (t) => t.entityId.equals(entity.id),
      transaction: transaction,
    );
    final usedCodes = {for (final row in chart) row.code};

    final ledger = await LedgerAccount.db.insertRow(
      session,
      LedgerAccount(
        entityId: entity.id!,
        code: _nextCode(usedCodes),
        name: account.name,
        type: account.kind.isLiability
            ? LedgerAccountType.liability
            : LedgerAccountType.asset,
        currencyCode: account.currencyCode == entity.baseCurrencyCode
            ? null
            : account.currencyCode,
      ),
      transaction: transaction,
    );
    await AuditEvent.db.insertRow(
      session,
      AuditEvent(
        entityId: entity.id!,
        actorId: actorId,
        action: AuditAction.ledgerAccountCreated,
        subjectType: AuditSubject.ledgerAccount,
        subjectId: ledger.id,
        payloadJson: jsonEncode({
          'before': null,
          'after': {
            'code': ledger.code,
            'name': ledger.name,
            'type': ledger.type.name,
            'systemRole': null,
            'currencyCode': ledger.currencyCode,
            'accountId': account.id?.toString(),
          },
        }),
        createdAt: DateTime.now().toUtc(),
      ),
      transaction: transaction,
    );

    return Account.db.updateRow(
      session,
      account.copyWith(
        ledgerAccountId: ledger.id,
        updatedAt: DateTime.now().toUtc(),
      ),
      transaction: transaction,
    );
  }

  static String _nextCode(Set<String> usedCodes) {
    for (var code = firstMirrorCode; ; code++) {
      final text = '$code';
      if (!usedCodes.contains(text)) return text;
    }
  }
}
