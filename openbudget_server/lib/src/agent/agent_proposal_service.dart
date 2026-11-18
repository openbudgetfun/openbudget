import 'dart:convert';

import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/budget/budget_service.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart';

/// Applies and dismisses the changes the assistant proposed.
///
/// Applying runs the same services the app uses — the envelope plan's
/// [BudgetService] and the tax writers in [TaxService] — inside the signed-in
/// user's session, so a proposal can never bypass ownership, validation, the
/// balance and FX invariants, or the entity lock contract.
abstract final class AgentProposalService {
  /// Lists proposals for one entity, newest first.
  static Future<List<AgentProposal>> list(
    Session session, {
    required UuidValue entityId,
    required bool pendingOnly,
  }) async {
    final userId = requireAgentUserId(session);
    await requireOwnedEntity(session, userId: userId, entityId: entityId);

    return AgentProposal.db.find(
      session,
      where: (t) {
        var where = t.entityId.equals(entityId) & t.userId.equals(userId);
        if (pendingOnly) {
          where = where & t.status.equals(AgentProposalStatus.pending);
        }
        return where;
      },
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Applies a pending proposal and marks it applied.
  static Future<AgentProposal> apply(
    Session session, {
    required UuidValue proposalId,
  }) async {
    final proposal = await _requireOwned(session, proposalId);
    if (proposal.status != AgentProposalStatus.pending) {
      throw ValidationException(
        message: 'This proposal has already been resolved.',
      );
    }

    final payload = _payload(proposal);

    // Claim the proposal before changing anything, so two concurrent applies
    // cannot both move the money. Only the call that flips it from pending
    // goes on to apply it.
    final claimed = await AgentProposal.db.updateWhere(
      session,
      columnValues: (t) => [
        t.status(AgentProposalStatus.applied),
        t.resolvedAt(DateTime.now().toUtc()),
      ],
      where: (t) =>
          t.id.equals(proposal.id) &
          t.status.equals(AgentProposalStatus.pending),
    );
    if (claimed.isEmpty) {
      throw ValidationException(
        message: 'This proposal has already been resolved.',
      );
    }

    try {
      switch (proposal.kind) {
        case AgentProposalKind.moveMoney:
          await _applyMoveMoney(session, proposal, payload);
        case AgentProposalKind.setTransactionTaxCategory:
          await _applyTransactionTax(session, payload);
        case AgentProposalKind.setEnvelopeTaxCategory:
          await _applyEnvelopeTax(session, payload);
      }
    } on Object {
      // The change did not happen; return the proposal to the user.
      await AgentProposal.db.updateRow(session, proposal);
      rethrow;
    }

    await EntityRealtimeNotifier.notify(
      session,
      proposal.entityId,
      ChangeScope.entity,
    );
    return claimed.single;
  }

  /// Dismisses a pending proposal without changing anything.
  static Future<AgentProposal> dismiss(
    Session session, {
    required UuidValue proposalId,
  }) async {
    final proposal = await _requireOwned(session, proposalId);
    if (proposal.status != AgentProposalStatus.pending) {
      throw ValidationException(
        message: 'This proposal has already been resolved.',
      );
    }

    return AgentProposal.db.updateRow(
      session,
      proposal.copyWith(
        status: AgentProposalStatus.dismissed,
        resolvedAt: DateTime.now().toUtc(),
      ),
    );
  }

  static Future<AgentProposal> _requireOwned(
    Session session,
    UuidValue proposalId,
  ) async {
    final userId = requireAgentUserId(session);
    final proposal = await AgentProposal.db.findById(session, proposalId);
    if (proposal == null || proposal.userId != userId) {
      throw NotFoundException(message: 'Proposal not found');
    }
    return proposal;
  }

  static Map<String, Object?> _payload(AgentProposal proposal) {
    final Object? decoded;
    try {
      decoded = jsonDecode(proposal.payloadJson);
    } on FormatException {
      throw ValidationException(
        message: 'The proposal payload is not valid JSON.',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw ValidationException(
        message: 'The proposal payload is not an object.',
      );
    }
    return decoded;
  }

  /// Moves money through the envelope plan's own service, so the allocation
  /// rows, the month view and the change event follow the exact app path.
  static Future<void> _applyMoveMoney(
    Session session,
    AgentProposal proposal,
    Map<String, Object?> payload,
  ) async {
    final fromEnvelopeId = _requiredUuid(payload, 'fromEnvelopeId');
    final toEnvelopeId = _requiredUuid(payload, 'toEnvelopeId');
    final amountMinor = _requiredInt(payload, 'amountMinor');
    if (amountMinor <= 0) {
      throw ValidationException(
        message: 'The proposal amount must be positive.',
      );
    }
    if (fromEnvelopeId == toEnvelopeId) {
      throw ValidationException(
        message: 'The proposal must move money between two envelopes.',
      );
    }
    final month = _requiredInt(payload, 'month');

    await BudgetService.moveMoney(
      session,
      entityId: proposal.entityId,
      month: month,
      fromEnvelopeId: fromEnvelopeId,
      toEnvelopeId: toEnvelopeId,
      amountMinor: amountMinor,
    );
  }

  /// Codes the proposed line through `TaxService.setLineTax`, which goes via
  /// `TransactionWriter.updateLines`; null business use and sales tax keep the
  /// line's stored values rather than clearing them.
  static Future<void> _applyTransactionTax(
    Session session,
    Map<String, Object?> payload,
  ) async {
    final transactionLineId = _requiredUuid(payload, 'transactionLineId');
    final code = _requiredString(payload, 'code');
    await TaxService.setLineTax(
      session,
      transactionLineId: transactionLineId,
      taxCategoryCode: code,
      businessUsePercent: _optionalInt(payload, 'businessUsePercent'),
    );
  }

  static Future<void> _applyEnvelopeTax(
    Session session,
    Map<String, Object?> payload,
  ) async {
    await TaxService.setEnvelopeTaxCategory(
      session,
      envelopeId: _requiredUuid(payload, 'envelopeId'),
      code: _requiredString(payload, 'code'),
    );
  }

  static String _requiredString(Map<String, Object?> payload, String key) {
    final value = payload[key];
    if (value is String && value.isNotEmpty) return value;
    throw ValidationException(
      message: 'The proposal payload is missing "$key".',
    );
  }

  static UuidValue _requiredUuid(Map<String, Object?> payload, String key) {
    final value = _requiredString(payload, key);
    try {
      return UuidValue.withFormatValidation(value);
    } on FormatException {
      throw ValidationException(
        message: 'The proposal payload has a bad "$key".',
      );
    }
  }

  static int _requiredInt(Map<String, Object?> payload, String key) {
    final value = _optionalInt(payload, key);
    if (value == null) {
      throw ValidationException(
        message: 'The proposal payload is missing "$key".',
      );
    }
    return value;
  }

  static int? _optionalInt(Map<String, Object?> payload, String key) {
    final value = payload[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    throw ValidationException(
      message: 'The proposal payload has a bad "$key".',
    );
  }
}
