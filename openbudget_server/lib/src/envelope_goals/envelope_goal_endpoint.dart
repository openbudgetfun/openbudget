import 'package:openbudget_server/src/envelope_goals/envelope_goal_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for envelope goal operations.
///
/// All methods require authentication.
class EnvelopeGoalEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or updates a goal for an envelope.
  Future<EnvelopeGoal> upsert(
    Session session,
    UuidValue envelopeId,
    String goalType,
    int targetAmountCents, {
    DateTime? targetDate,
    int? monthlyFundingCents,
  }) async {
    return EnvelopeGoalService.upsert(
      session,
      envelopeId: envelopeId,
      goalType: goalType,
      targetAmountCents: targetAmountCents,
      targetDate: targetDate,
      monthlyFundingCents: monthlyFundingCents,
    );
  }

  /// Gets the goal for an envelope.
  Future<EnvelopeGoal?> getForEnvelope(
    Session session,
    UuidValue envelopeId,
  ) async {
    return EnvelopeGoalService.getForEnvelope(session, envelopeId: envelopeId);
  }

  /// Lists all goals for a set of envelope IDs.
  Future<List<EnvelopeGoal>> listForEnvelopes(
    Session session,
    List<UuidValue> envelopeIds,
  ) async {
    return EnvelopeGoalService.listForBudget(session, envelopeIds: envelopeIds);
  }

  /// Deletes a goal by ID.
  Future<EnvelopeGoal> delete(Session session, UuidValue goalId) async {
    return EnvelopeGoalService.delete(session, goalId: goalId);
  }
}
