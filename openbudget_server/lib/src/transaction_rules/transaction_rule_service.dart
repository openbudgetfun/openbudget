import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transaction_rules/payee_rule_lookup.dart';
import 'package:serverpod/serverpod.dart';

/// Owns transaction-rule lifecycle within one entity.
///
/// A rule assigns one envelope whenever a payee codes a future ordinary or
/// imported transaction with no explicit envelope. A payee has at most one
/// rule, enforced by the unique `payeeId` index. Every read and write crosses
/// [EntityAccess] and verifies that the payee and envelope belong to the same
/// owned entity.
abstract final class TransactionRuleService {
  static final _log = ObLogger('TransactionRuleService');

  /// Creates the entity's rule for [payeeId].
  ///
  /// The unique index settles a concurrent create: the losing call rolls back
  /// with a domain validation error instead of a raw database error, and
  /// exactly one rule remains.
  static Future<TransactionRule> create(
    Session session, {
    required UuidValue entityId,
    required UuidValue payeeId,
    required UuidValue envelopeId,
  }) async {
    _log.info('Creating rule payee=$payeeId envelope=$envelopeId');

    final rule = await session.db.transaction((tx) async {
      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );
      await _requirePayee(
        session,
        entityId: entityId,
        payeeId: payeeId,
        tx: tx,
      );
      await _requireEnvelope(
        session,
        entityId: entityId,
        envelopeId: envelopeId,
        tx: tx,
      );

      final inserted = await session.db.unsafeExecute(
        'INSERT INTO transaction_rule '
        '("entityId", "payeeId", "envelopeId", enabled, "createdAt") '
        'VALUES (@entityId::uuid, @payeeId::uuid, @envelopeId::uuid, true, '
        'now()) '
        'ON CONFLICT ("payeeId") DO NOTHING',
        parameters: QueryParameters.named({
          'entityId': entityId.toString(),
          'payeeId': payeeId.toString(),
          'envelopeId': envelopeId.toString(),
        }),
        transaction: tx,
      );
      if (inserted == 0) {
        throw ValidationException(
          message: 'A rule already exists for this payee',
        );
      }

      final row = await TransactionRule.db.findFirstRow(
        session,
        where: (t) => t.payeeId.equals(payeeId),
        transaction: tx,
      );
      if (row == null) {
        throw StateError('Transaction rule insert did not produce a row');
      }

      return row;
    });

    await _notify(session, rule.entityId);
    return rule;
  }

  /// Lists every rule of an entity, ordered by creation time and id.
  static Future<List<TransactionRule>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    return TransactionRule.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.createdAt, t.id],
    );
  }

  /// Loads one rule after checking that the caller owns its entity.
  static Future<TransactionRule> getById(
    Session session, {
    required UuidValue ruleId,
  }) async {
    final rule = await TransactionRule.db.findById(session, ruleId);
    if (rule == null) {
      throw NotFoundException(message: 'Transaction rule not found');
    }

    await EntityAccess.requireOwned(session, rule.entityId);
    return rule;
  }

  /// Changes a rule's destination envelope, its enabled state, or both.
  static Future<TransactionRule> update(
    Session session, {
    required UuidValue ruleId,
    UuidValue? envelopeId,
    bool? enabled,
  }) async {
    _log.info('Updating rule id=$ruleId');

    final updated = await session.db.transaction((tx) async {
      final discovered = await TransactionRule.db.findById(
        session,
        ruleId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Transaction rule not found');
      }

      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final rule = await TransactionRule.db.findById(
        session,
        ruleId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (rule == null) {
        throw NotFoundException(message: 'Transaction rule not found');
      }
      if (rule.entityId != discovered.entityId) {
        throw ValidationException(
          message: 'The rule changed concurrently; retry the update',
        );
      }

      if (envelopeId != null) {
        await _requireEnvelope(
          session,
          entityId: rule.entityId,
          envelopeId: envelopeId,
          tx: tx,
        );
      }

      return TransactionRule.db.updateRow(
        session,
        rule.copyWith(
          envelopeId: envelopeId ?? rule.envelopeId,
          enabled: enabled ?? rule.enabled,
        ),
        transaction: tx,
      );
    });

    await _notify(session, updated.entityId);
    return updated;
  }

  /// Returns the envelope an enabled rule supplies for a payee, or null.
  ///
  /// This is the preview the client shows before a transaction is written. It
  /// uses [PayeeRuleLookup], the same read `TransactionWriter` applies, so the
  /// preview cannot disagree with the next ordinary or imported transaction.
  static Future<UuidValue?> findMatchingEnvelope(
    Session session, {
    required UuidValue entityId,
    required UuidValue payeeId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);
    await _requirePayee(session, entityId: entityId, payeeId: payeeId);

    final envelopeId = await PayeeRuleLookup.enabledEnvelope(
      session,
      entityId: entityId,
      payeeId: payeeId,
    );
    if (envelopeId == null) return null;

    final envelope = await Envelope.db.findById(session, envelopeId);
    if (envelope == null || envelope.entityId != entityId) {
      throw ValidationException(
        message: 'A rule points at an envelope of another entity',
      );
    }

    return envelopeId;
  }

  /// Deletes a rule.
  static Future<TransactionRule> delete(
    Session session, {
    required UuidValue ruleId,
  }) async {
    _log.info('Deleting rule id=$ruleId');

    final deleted = await session.db.transaction((tx) async {
      final discovered = await TransactionRule.db.findById(
        session,
        ruleId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Transaction rule not found');
      }

      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final rule = await TransactionRule.db.findById(
        session,
        ruleId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (rule == null) {
        throw NotFoundException(message: 'Transaction rule not found');
      }
      if (rule.entityId != discovered.entityId) {
        throw ValidationException(
          message: 'The rule changed concurrently; retry the delete',
        );
      }

      await TransactionRule.db.deleteRow(session, rule, transaction: tx);
      return rule;
    });

    await _notify(session, deleted.entityId);
    return deleted;
  }

  static Future<void> _requirePayee(
    Session session, {
    required UuidValue entityId,
    required UuidValue payeeId,
    Transaction? tx,
  }) async {
    final payee = await Payee.db.findById(session, payeeId, transaction: tx);
    if (payee == null || payee.entityId != entityId) {
      throw NotFoundException(message: 'Payee not found in this entity');
    }
  }

  static Future<void> _requireEnvelope(
    Session session, {
    required UuidValue entityId,
    required UuidValue envelopeId,
    Transaction? tx,
  }) async {
    final envelope = await Envelope.db.findById(
      session,
      envelopeId,
      transaction: tx,
    );
    if (envelope == null || envelope.entityId != entityId) {
      throw NotFoundException(message: 'Envelope not found in this entity');
    }
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects transaction-rule changes',
      );
    }

    return entity;
  }

  static Future<void> _notify(Session session, UuidValue entityId) =>
      EntityRealtimeNotifier.notify(
        session,
        entityId,
        ChangeScope.transactions,
      );
}
