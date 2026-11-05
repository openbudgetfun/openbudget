import 'dart:convert';

import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/monthly_allocations/monthly_allocation_service.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// Applies and dismisses the changes the assistant proposed.
///
/// Applying runs the same services the app uses, inside the signed-in user's
/// session, so a proposal can never bypass ownership or validation.
abstract final class AgentProposalService {
  /// Lists proposals for one budget, newest first.
  static Future<List<AgentProposal>> list(
    Session session, {
    required UuidValue budgetId,
    required bool pendingOnly,
  }) async {
    final userId = requireAgentUserId(session);
    await requireOwnedBudget(session, userId: userId, budgetId: budgetId);

    return AgentProposal.db.find(
      session,
      where: (t) {
        var where = t.budgetId.equals(budgetId) & t.userId.equals(userId);
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

    BudgetRealtimeNotifier.notifyBudgetChanged(proposal.budgetId);
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
    final month = _requiredString(payload, 'month');
    final match = RegExp(r'^(\d{4})-(0[1-9]|1[0-2])$').firstMatch(month);
    if (match == null) {
      throw ValidationException(message: 'The proposal month is not YYYY-MM.');
    }

    await MonthlyAllocationService.moveMoney(
      session,
      fromEnvelopeId: fromEnvelopeId,
      toEnvelopeId: toEnvelopeId,
      budgetId: proposal.budgetId,
      year: int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
      amountCents: amountMinor,
    );
  }

  static Future<void> _applyTransactionTax(
    Session session,
    Map<String, Object?> payload,
  ) async {
    final transactionId = _requiredUuid(payload, 'transactionId');
    final code = _requiredString(payload, 'code');
    // The payload only carries a percent when the user asked to change it, so
    // keep the transaction's existing business use and sales tax rather than
    // clearing them along with the category.
    final transaction = await TransactionService.getById(
      session,
      transactionId: transactionId,
    );
    await TaxService.setTransactionTax(
      session,
      transactionId: transactionId,
      code: code,
      businessUsePercent:
          _optionalInt(payload, 'businessUsePercent') ??
          transaction.businessUsePercent,
      salesTaxCents: transaction.salesTaxCents,
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
