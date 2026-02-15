import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing budgets.
///
/// All methods require an authenticated session.
class BudgetService {
  /// Returns the authenticated user's ID as a [UuidValue], or throws.
  static UuidValue _requireUserId(Session session) {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(userIdentifier);
  }

  /// Creates a budget owned by the authenticated user.
  static Future<Budget> create(
    Session session, {
    required String name,
    required String currencyCode,
  }) async {
    final userId = _requireUserId(session);

    final budget = Budget(
      name: name,
      currencyCode: currencyCode,
      ownerId: userId,
    );
    return Budget.db.insertRow(session, budget);
  }

  /// Lists all budgets for the authenticated user.
  static Future<List<Budget>> listForUser(Session session) async {
    final userId = _requireUserId(session);

    return Budget.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Fetches a single budget, verifying ownership.
  static Future<Budget> getById(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final userId = _requireUserId(session);

    final budget = await Budget.db.findById(session, budgetId);
    if (budget == null || budget.ownerId != userId) {
      throw NotFoundException('Budget not found');
    }
    return budget;
  }

  /// Updates a budget, verifying ownership.
  static Future<Budget> update(
    Session session, {
    required UuidValue budgetId,
    String? name,
    String? currencyCode,
  }) async {
    final budget = await getById(session, budgetId: budgetId);

    final updated = budget.copyWith(
      name: name ?? budget.name,
      currencyCode: currencyCode ?? budget.currencyCode,
      updatedAt: DateTime.now(),
    );
    return Budget.db.updateRow(session, updated);
  }

  /// Deletes a budget, verifying ownership.
  static Future<Budget> delete(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final budget = await getById(session, budgetId: budgetId);
    return Budget.db.deleteRow(session, budget);
  }
}
