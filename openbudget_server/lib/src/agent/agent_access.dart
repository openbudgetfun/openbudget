import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Reads the signed-in user, or throws when the session is anonymous.
///
/// The MCP route elevates its web session to the access token's owner with
/// `session.updateAuthenticated`, so both the endpoint path and the MCP path
/// arrive here with the caller's identity.
UuidValue requireAgentUserId(Session session) {
  final userIdentifier = session.authenticated?.userIdentifier;
  if (userIdentifier == null) throw AuthenticationRequiredException();
  return UuidValue.fromString(userIdentifier);
}

/// Loads an entity and checks it belongs to [userId].
///
/// The agent checks ownership from the stored owner column rather than from
/// `session.authenticated`, so a tool can also act for an explicit owner the
/// registry context carries.
Future<Entity> requireOwnedEntity(
  Session session, {
  required UuidValue userId,
  required UuidValue entityId,
}) async {
  final entity = await Entity.db.findById(session, entityId);
  if (entity == null || entity.ownerId != userId) {
    throw NotFoundException(message: 'Entity not found');
  }
  return entity;
}
