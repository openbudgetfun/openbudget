import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// The one read of an enabled payee rule.
///
/// `TransactionWriter` applies the result when it codes a new ordinary or
/// imported transaction, and `transactionRule.findMatchingEnvelope` returns
/// the same result to the client as a preview. Keeping the query here stops
/// the writer and the API from growing two definitions of "the rule for this
/// payee".
abstract final class PayeeRuleLookup {
  /// Returns the envelope of [payeeId]'s enabled rule within [entityId].
  ///
  /// A disabled rule and a payee without a rule both return null. The caller
  /// owns deciding whether the transaction is eligible: the writer applies a
  /// rule only to a single-line, envelope-less, on-budget outflow.
  static Future<UuidValue?> enabledEnvelope(
    Session session, {
    required UuidValue entityId,
    required UuidValue payeeId,
    Transaction? transaction,
  }) async {
    final rule = await TransactionRule.db.findFirstRow(
      session,
      where: (t) =>
          t.entityId.equals(entityId) &
          t.payeeId.equals(payeeId) &
          t.enabled.equals(true),
      transaction: transaction,
    );

    return rule?.envelopeId;
  }
}
