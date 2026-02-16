import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/payees/payee_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for payee operations.
///
/// All methods require authentication.
class PayeeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new payee within a budget.
  Future<Payee> create(Session session, String name, UuidValue budgetId) async {
    return PayeeService.create(session, name: name, budgetId: budgetId);
  }

  /// Lists all payees for a budget.
  Future<List<Payee>> list(Session session, UuidValue budgetId) async {
    return PayeeService.listForBudget(session, budgetId: budgetId);
  }

  /// Gets a single payee by ID.
  Future<Payee> get(Session session, UuidValue payeeId) async {
    return PayeeService.getById(session, payeeId: payeeId);
  }

  /// Updates a payee by ID.
  Future<Payee> update(
    Session session,
    UuidValue payeeId, {
    String? name,
  }) async {
    return PayeeService.update(session, payeeId: payeeId, name: name);
  }

  /// Returns the envelope ID from the most recent transaction for a payee.
  Future<UuidValue?> lastUsedEnvelopeId(
    Session session,
    UuidValue payeeId,
    UuidValue budgetId,
  ) async {
    return PayeeService.lastUsedEnvelopeId(
      session,
      payeeId: payeeId,
      budgetId: budgetId,
    );
  }

  /// Merges the source payee into the target payee.
  ///
  /// All transactions and rules from the source are reassigned to the target.
  /// The source payee is deleted after merging.
  /// Returns the number of transactions reassigned.
  Future<int> merge(
    Session session,
    UuidValue sourcePayeeId,
    UuidValue targetPayeeId,
  ) async {
    return PayeeService.merge(
      session,
      sourcePayeeId: sourcePayeeId,
      targetPayeeId: targetPayeeId,
    );
  }

  /// Deletes a payee by ID.
  Future<Payee> delete(Session session, UuidValue payeeId) async {
    return PayeeService.delete(session, payeeId: payeeId);
  }
}
