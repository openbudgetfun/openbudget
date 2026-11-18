import 'package:openbudget_server/src/envelope_goals/envelope_goal_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for envelope goal operations.
///
/// All methods require authentication and delegate to [EnvelopeGoalService],
/// which owns the entity boundary.
class EnvelopeGoalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or replaces the goal for one envelope.
  Future<EnvelopeGoal> upsert(
    Session session,
    UuidValue envelopeId,
    EnvelopeGoalKind kind,
    int amountMinor, {
    DateTime? targetDate,
  }) => EnvelopeGoalService.upsert(
    session,
    envelopeId: envelopeId,
    kind: kind,
    amountMinor: amountMinor,
    targetDate: targetDate,
  );

  /// Lists every goal of an entity.
  Future<List<EnvelopeGoal>> list(Session session, UuidValue entityId) =>
      EnvelopeGoalService.list(session, entityId: entityId);

  /// Deletes one goal by id.
  Future<void> delete(Session session, UuidValue goalId) =>
      EnvelopeGoalService.delete(session, goalId: goalId);
}
