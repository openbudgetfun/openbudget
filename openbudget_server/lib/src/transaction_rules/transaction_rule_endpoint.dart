import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/transaction_rules/transaction_rule_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for transaction rule operations.
///
/// All methods require authentication.
class TransactionRuleEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new transaction rule for a payee in a budget.
  Future<TransactionRule> create(
    Session session,
    UuidValue budgetId,
    UuidValue payeeId,
    UuidValue targetEnvelopeId,
  ) async {
    final rule = await TransactionRuleService.create(
      session,
      budgetId: budgetId,
      payeeId: payeeId,
      targetEnvelopeId: targetEnvelopeId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(rule.budgetId);
    return rule;
  }

  /// Lists all transaction rules for a budget.
  Future<List<TransactionRule>> list(
    Session session,
    UuidValue budgetId,
  ) async {
    return TransactionRuleService.listForBudget(session, budgetId: budgetId);
  }

  /// Gets a single transaction rule by ID.
  Future<TransactionRule> get(Session session, UuidValue ruleId) async {
    return TransactionRuleService.getById(session, ruleId: ruleId);
  }

  /// Updates a transaction rule.
  Future<TransactionRule> update(
    Session session,
    UuidValue ruleId, {
    UuidValue? targetEnvelopeId,
    bool? enabled,
  }) async {
    final rule = await TransactionRuleService.update(
      session,
      ruleId: ruleId,
      targetEnvelopeId: targetEnvelopeId,
      enabled: enabled,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(rule.budgetId);
    return rule;
  }

  /// Finds the matching envelope for a payee (used for client-side preview).
  Future<UuidValue?> findMatchingEnvelope(
    Session session,
    UuidValue budgetId,
    UuidValue payeeId,
  ) async {
    return TransactionRuleService.findMatchingEnvelope(
      session,
      budgetId: budgetId,
      payeeId: payeeId,
    );
  }

  /// Deletes a transaction rule.
  Future<TransactionRule> delete(Session session, UuidValue ruleId) async {
    final rule = await TransactionRuleService.delete(session, ruleId: ruleId);
    BudgetRealtimeNotifier.notifyBudgetChanged(rule.budgetId);
    return rule;
  }
}
