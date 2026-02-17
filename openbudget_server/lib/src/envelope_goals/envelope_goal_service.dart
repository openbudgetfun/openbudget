import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing envelope goals.
///
/// All methods verify envelope ownership before operating.
class EnvelopeGoalService {
  static final _log = ObLogger('EnvelopeGoalService');

  /// Creates or updates a goal for an envelope.
  static Future<EnvelopeGoal> upsert(
    Session session, {
    required UuidValue envelopeId,
    required String goalType,
    required int targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
  }) async {
    _log.info('Upserting goal for envelope=$envelopeId type=$goalType');
    await EnvelopeService.getById(session, envelopeId: envelopeId);

    final existing = await EnvelopeGoal.db.findFirstRow(
      session,
      where: (t) => t.envelopeId.equals(envelopeId),
    );

    if (existing != null) {
      final updated = existing.copyWith(
        goalType: goalType,
        targetAmountCents: targetAmountCents,
        targetDate: targetDate,
        monthlyFundingCents: monthlyFundingCents,
        updatedAt: DateTime.now(),
      );
      return EnvelopeGoal.db.updateRow(session, updated);
    }

    final goal = EnvelopeGoal(
      envelopeId: envelopeId,
      goalType: goalType,
      targetAmountCents: targetAmountCents,
      targetDate: targetDate,
      monthlyFundingCents: monthlyFundingCents,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return EnvelopeGoal.db.insertRow(session, goal);
  }

  /// Gets the goal for an envelope, verifying ownership.
  static Future<EnvelopeGoal?> getForEnvelope(
    Session session, {
    required UuidValue envelopeId,
  }) async {
    await EnvelopeService.getById(session, envelopeId: envelopeId);

    return EnvelopeGoal.db.findFirstRow(
      session,
      where: (t) => t.envelopeId.equals(envelopeId),
    );
  }

  /// Lists all goals for envelopes in a budget.
  static Future<List<EnvelopeGoal>> listForBudget(
    Session session, {
    required List<UuidValue> envelopeIds,
  }) async {
    if (envelopeIds.isEmpty) return [];

    return EnvelopeGoal.db.find(
      session,
      where: (t) => t.envelopeId.inSet(envelopeIds.toSet()),
    );
  }

  /// Deletes a goal by ID.
  static Future<EnvelopeGoal> delete(
    Session session, {
    required UuidValue goalId,
  }) async {
    _log.info('Deleting goal id=$goalId');
    final goal = await EnvelopeGoal.db.findById(session, goalId);
    if (goal == null) {
      throw NotFoundException('Goal not found');
    }

    await EnvelopeService.getById(session, envelopeId: goal.envelopeId);
    return EnvelopeGoal.db.deleteRow(session, goal);
  }
}
