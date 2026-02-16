import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Business logic for managing payees within a budget.
///
/// All methods verify budget ownership before operating.
class PayeeService {
  /// Creates a payee within a budget, verifying ownership.
  static Future<Payee> create(
    Session session, {
    required String name,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final payee = Payee(
      name: name,
      budgetId: budgetId,
      createdAt: DateTime.now(),
    );
    return Payee.db.insertRow(session, payee);
  }

  /// Lists all payees for a budget, verifying ownership.
  static Future<List<Payee>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return Payee.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.name,
    );
  }

  /// Fetches a single payee, verifying budget ownership.
  static Future<Payee> getById(
    Session session, {
    required UuidValue payeeId,
  }) async {
    final payee = await Payee.db.findById(session, payeeId);
    if (payee == null) {
      throw NotFoundException('Payee not found');
    }

    await BudgetService.getById(session, budgetId: payee.budgetId);
    return payee;
  }

  /// Updates a payee name, verifying ownership.
  static Future<Payee> update(
    Session session, {
    required UuidValue payeeId,
    String? name,
  }) async {
    final payee = await getById(session, payeeId: payeeId);

    final updated = payee.copyWith(name: name ?? payee.name);
    return Payee.db.updateRow(session, updated);
  }

  /// Returns the envelope ID from the most recent transaction for a payee,
  /// or null if no transactions exist for the payee.
  static Future<UuidValue?> lastUsedEnvelopeId(
    Session session, {
    required UuidValue payeeId,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final transactions = await Transaction.db.find(
      session,
      where: (t) =>
          t.payeeId.equals(payeeId) &
          t.budgetId.equals(budgetId) &
          t.envelopeId.notEquals(null),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
      limit: 1,
    );

    if (transactions.isEmpty) return null;
    return transactions.first.envelopeId;
  }

  /// Merges the source payee into the target payee.
  ///
  /// Reassigns all transactions and transaction rules from the source payee
  /// to the target payee, then deletes the source payee.
  /// Returns the number of transactions reassigned.
  static Future<int> merge(
    Session session, {
    required UuidValue sourcePayeeId,
    required UuidValue targetPayeeId,
  }) async {
    final sourcePayee = await getById(session, payeeId: sourcePayeeId);
    final targetPayee = await getById(session, payeeId: targetPayeeId);

    if (sourcePayee.budgetId != targetPayee.budgetId) {
      throw ValidationException('Payees must belong to the same budget');
    }

    // Reassign all transactions from source to target payee.
    final transactions = await Transaction.db.find(
      session,
      where: (t) => t.payeeId.equals(sourcePayeeId),
    );

    var count = 0;
    for (final tx in transactions) {
      await Transaction.db.updateRow(
        session,
        tx.copyWith(payeeId: targetPayeeId),
      );
      count++;
    }

    // Reassign transaction rules from source to target payee.
    final rules = await TransactionRule.db.find(
      session,
      where: (t) => t.payeeId.equals(sourcePayeeId),
    );

    for (final rule in rules) {
      // Check if a rule already exists for the target payee in this budget.
      final existing = await TransactionRule.db.find(
        session,
        where: (t) =>
            t.payeeId.equals(targetPayeeId) & t.budgetId.equals(rule.budgetId),
        limit: 1,
      );

      if (existing.isEmpty) {
        // Reassign the rule to the target payee.
        await TransactionRule.db.updateRow(
          session,
          rule.copyWith(payeeId: targetPayeeId),
        );
      } else {
        // A rule already exists for the target; delete the duplicate.
        await TransactionRule.db.deleteRow(session, rule);
      }
    }

    // Delete the source payee.
    await Payee.db.deleteRow(session, sourcePayee);

    return count;
  }

  /// Deletes a payee, verifying ownership.
  static Future<Payee> delete(
    Session session, {
    required UuidValue payeeId,
  }) async {
    final payee = await getById(session, payeeId: payeeId);
    return Payee.db.deleteRow(session, payee);
  }
}
