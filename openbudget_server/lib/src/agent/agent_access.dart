import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Reads the signed-in user, or throws when the session is anonymous.
UuidValue requireAgentUserId(Session session) {
  final userIdentifier = session.authenticated?.userIdentifier;
  if (userIdentifier == null) throw AuthenticationRequiredException();
  return UuidValue.fromString(userIdentifier);
}

/// Loads a budget and checks it belongs to [userId].
///
/// The agent checks ownership from the stored owner column rather than from
/// `session.authenticated`, so the same tools work for an MCP server that has
/// no Serverpod session.
Future<Budget> requireOwnedBudget(
  Session session, {
  required UuidValue userId,
  required UuidValue budgetId,
}) async {
  final budget = await Budget.db.findById(session, budgetId);
  if (budget == null || budget.ownerId != userId) {
    throw NotFoundException(message: 'Budget not found');
  }
  return budget;
}
