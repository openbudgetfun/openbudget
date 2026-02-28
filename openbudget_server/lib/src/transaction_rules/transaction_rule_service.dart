import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/payees/payee_service.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing transaction rules within a budget.
///
/// Transaction rules auto-assign an envelope when a specific payee is used.
/// Each payee can have at most one rule per budget (unique constraint).
class TransactionRuleService {
  static final _log = ObLogger('TransactionRuleService');

  /// Creates a transaction rule, verifying budget ownership.
  static Future<TransactionRule> create(
    Session session, {
    required UuidValue budgetId,
    required UuidValue payeeId,
    required UuidValue targetEnvelopeId,
  }) async {
    _log.info('Creating rule payee=$payeeId envelope=$targetEnvelopeId');
    await BudgetService.getById(session, budgetId: budgetId);
    await _validateRuleReferences(
      session,
      budgetId: budgetId,
      payeeId: payeeId,
      targetEnvelopeId: targetEnvelopeId,
    );

    final rule = TransactionRule(
      budgetId: budgetId,
      payeeId: payeeId,
      targetEnvelopeId: targetEnvelopeId,
      enabled: true,
      createdAt: DateTime.now(),
    );
    return TransactionRule.db.insertRow(session, rule);
  }

  /// Lists all transaction rules for a budget, verifying ownership.
  static Future<List<TransactionRule>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return TransactionRule.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.createdAt,
    );
  }

  /// Fetches a single rule, verifying budget ownership.
  static Future<TransactionRule> getById(
    Session session, {
    required UuidValue ruleId,
  }) async {
    final rule = await TransactionRule.db.findById(session, ruleId);
    if (rule == null) {
      throw NotFoundException('Transaction rule not found');
    }

    await BudgetService.getById(session, budgetId: rule.budgetId);
    return rule;
  }

  /// Updates a rule's target envelope or enabled state.
  static Future<TransactionRule> update(
    Session session, {
    required UuidValue ruleId,
    UuidValue? targetEnvelopeId,
    bool? enabled,
  }) async {
    final rule = await getById(session, ruleId: ruleId);
    if (targetEnvelopeId != null) {
      await _assertEnvelopeBelongsToBudget(
        session,
        budgetId: rule.budgetId,
        envelopeId: targetEnvelopeId,
      );
    }

    final updated = rule.copyWith(
      targetEnvelopeId: targetEnvelopeId ?? rule.targetEnvelopeId,
      enabled: enabled ?? rule.enabled,
    );
    return TransactionRule.db.updateRow(session, updated);
  }

  /// Finds a matching rule for a payee within a budget.
  ///
  /// Returns the target envelope ID if an enabled rule exists, or null.
  static Future<UuidValue?> findMatchingEnvelope(
    Session session, {
    required UuidValue budgetId,
    required UuidValue payeeId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);
    await _assertPayeeBelongsToBudget(
      session,
      budgetId: budgetId,
      payeeId: payeeId,
    );

    final rules = await TransactionRule.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.payeeId.equals(payeeId) &
          t.enabled.equals(true),
      limit: 1,
    );

    if (rules.isEmpty) return null;
    return rules.first.targetEnvelopeId;
  }

  /// Deletes a rule, verifying budget ownership.
  static Future<TransactionRule> delete(
    Session session, {
    required UuidValue ruleId,
  }) async {
    _log.info('Deleting rule id=$ruleId');
    final rule = await getById(session, ruleId: ruleId);
    return TransactionRule.db.deleteRow(session, rule);
  }

  static Future<void> _assertEnvelopeBelongsToBudget(
    Session session, {
    required UuidValue budgetId,
    required UuidValue envelopeId,
  }) async {
    final envelope = await EnvelopeService.getById(
      session,
      envelopeId: envelopeId,
    );
    final category = await CategoryService.getById(
      session,
      categoryId: envelope.categoryId,
    );
    if (category.budgetId != budgetId) {
      throw NotFoundException('Envelope not found in this budget');
    }
  }

  static Future<void> _assertPayeeBelongsToBudget(
    Session session, {
    required UuidValue budgetId,
    required UuidValue payeeId,
  }) async {
    final payee = await PayeeService.getById(session, payeeId: payeeId);
    if (payee.budgetId != budgetId) {
      throw NotFoundException('Payee not found in this budget');
    }
  }

  static Future<void> _validateRuleReferences(
    Session session, {
    required UuidValue budgetId,
    required UuidValue payeeId,
    required UuidValue targetEnvelopeId,
  }) async {
    await _assertPayeeBelongsToBudget(
      session,
      budgetId: budgetId,
      payeeId: payeeId,
    );
    await _assertEnvelopeBelongsToBudget(
      session,
      budgetId: budgetId,
      envelopeId: targetEnvelopeId,
    );
  }
}
