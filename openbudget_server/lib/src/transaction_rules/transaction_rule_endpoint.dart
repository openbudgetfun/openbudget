import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/transaction_rules/transaction_rule_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for transaction rule operations.
///
/// All methods require authentication and delegate to
/// [TransactionRuleService], which owns the entity boundary and publishes
/// committed change events.
class TransactionRuleEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates the entity's rule for a payee.
  Future<TransactionRule> create(
    Session session,
    UuidValue entityId,
    UuidValue payeeId,
    UuidValue envelopeId,
  ) => TransactionRuleService.create(
    session,
    entityId: entityId,
    payeeId: payeeId,
    envelopeId: envelopeId,
  );

  /// Lists every rule of an entity.
  Future<List<TransactionRule>> list(
    Session session,
    UuidValue entityId,
  ) => TransactionRuleService.list(session, entityId: entityId);

  /// Gets a single transaction rule by ID.
  Future<TransactionRule> get(Session session, UuidValue ruleId) =>
      TransactionRuleService.getById(session, ruleId: ruleId);

  /// Changes a rule's envelope, its enabled state, or both.
  Future<TransactionRule> update(
    Session session,
    UuidValue ruleId, {
    UuidValue? envelopeId,
    bool? enabled,
  }) => TransactionRuleService.update(
    session,
    ruleId: ruleId,
    envelopeId: envelopeId,
    enabled: enabled,
  );

  /// Returns the envelope an enabled rule supplies for a payee.
  Future<UuidValue?> findMatchingEnvelope(
    Session session,
    UuidValue entityId,
    UuidValue payeeId,
  ) => TransactionRuleService.findMatchingEnvelope(
    session,
    entityId: entityId,
    payeeId: payeeId,
  );

  /// Deletes a transaction rule.
  Future<TransactionRule> delete(Session session, UuidValue ruleId) =>
      TransactionRuleService.delete(session, ruleId: ruleId);
}
