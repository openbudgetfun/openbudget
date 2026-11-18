import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Owns the one goal an envelope may have.
///
/// Every read and write crosses [EntityAccess]. The unique envelope index is
/// enforced under an envelope row lock, so two upserts cannot race into two
/// goals for one envelope.
abstract final class EnvelopeGoalService {
  static final _log = ObLogger('EnvelopeGoalService');

  /// Creates or replaces the goal for one envelope.
  static Future<EnvelopeGoal> upsert(
    Session session, {
    required UuidValue envelopeId,
    required EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
  }) async {
    _requireAmount(amountMinor);
    final date = _requireTargetDate(kind, targetDate);

    _log.info('Upserting goal envelope=$envelopeId kind=${kind.name}');

    final goal = await session.db.transaction((tx) async {
      final discovered = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Envelope not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final envelope = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (envelope == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      if (envelope.entityId != entity.id) {
        throw ValidationException(
          message: 'The envelope changed concurrently; retry the goal update',
        );
      }

      final existing = await EnvelopeGoal.db.findFirstRow(
        session,
        where: (t) => t.envelopeId.equals(envelopeId),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final now = _now();

      if (existing != null) {
        if (existing.entityId != entity.id) {
          throw ValidationException(
            message: 'The envelope goal belongs to another entity',
          );
        }

        return EnvelopeGoal.db.updateRow(
          session,
          existing.copyWith(
            kind: kind,
            amountMinor: amountMinor,
            targetDate: date,
            updatedAt: now,
          ),
          transaction: tx,
        );
      }

      return EnvelopeGoal.db.insertRow(
        session,
        EnvelopeGoal(
          entityId: entity.id!,
          envelopeId: envelopeId,
          kind: kind,
          amountMinor: amountMinor,
          targetDate: date,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
    });

    await _notify(session, goal.entityId);
    return goal;
  }

  /// Lists every goal of an entity, in envelope then id order.
  static Future<List<EnvelopeGoal>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    return EnvelopeGoal.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.envelopeId, t.id],
    );
  }

  /// Deletes one goal after checking that the caller owns its entity.
  static Future<void> delete(
    Session session, {
    required UuidValue goalId,
  }) async {
    _log.info('Deleting goal id=$goalId');

    final entityId = await session.db.transaction((tx) async {
      final discovered = await EnvelopeGoal.db.findById(
        session,
        goalId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Goal not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final envelope = await Envelope.db.findById(
        session,
        discovered.envelopeId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (envelope == null) {
        throw ValidationException(
          message: 'The goal envelope changed concurrently; retry the delete',
        );
      }
      if (envelope.entityId != entity.id) {
        throw ValidationException(
          message: 'The goal envelope belongs to another entity',
        );
      }

      final goal = await EnvelopeGoal.db.findById(
        session,
        goalId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (goal == null) {
        throw NotFoundException(message: 'Goal not found');
      }
      if (goal.envelopeId != discovered.envelopeId) {
        throw ValidationException(
          message: 'The goal changed concurrently; retry the delete',
        );
      }

      await EnvelopeGoal.db.deleteRow(session, goal, transaction: tx);
      return goal.entityId;
    });

    await _notify(session, entityId);
  }

  static void _requireAmount(int amountMinor) {
    if (amountMinor <= 0) {
      throw ValidationException(message: 'amountMinor must be positive');
    }
    if (amountMinor > maxSafeMinor) {
      throw ValidationException(
        message: 'amountMinor exceeds the safe minor-unit range',
      );
    }
  }

  static DateTime? _requireTargetDate(
    EnvelopeGoalKind kind,
    DateTime? targetDate,
  ) {
    if (kind == EnvelopeGoalKind.targetByDate) {
      if (targetDate == null) {
        throw ValidationException(
          message: 'targetByDate needs a targetDate',
        );
      }
    } else if (targetDate != null) {
      throw ValidationException(
        message: '${kind.name} does not accept a targetDate',
      );
    }

    if (targetDate == null) return null;
    if (!isCivilDate(targetDate) || targetDate.year < 1900) {
      throw ValidationException(
        message: 'targetDate must be a UTC calendar date',
      );
    }

    return targetDate;
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects goal changes',
      );
    }

    return entity;
  }

  static DateTime _now() => DateTime.now().toUtc();

  static Future<void> _notify(Session session, UuidValue entityId) =>
      EntityRealtimeNotifier.notify(session, entityId, ChangeScope.plan);
}
