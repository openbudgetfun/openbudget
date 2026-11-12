import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/plaid/plaid_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for Plaid-linked bank connections.
///
/// Every method is entity-scoped. The connection rows carry no secrets for
/// the client: the token and cursor fields are `scope=serverOnly`, so the
/// generated class cannot leak them.
class PlaidEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a short-lived link token for starting Plaid Link in the client.
  Future<String> createLinkToken(Session session, UuidValue entityId) =>
      PlaidService.createLinkToken(session, entityId: entityId);

  /// Exchanges a public token, imports the item's accounts with their
  /// opening balances, and syncs the posted movements once.
  Future<PlaidConnection> exchangePublicToken(
    Session session,
    UuidValue entityId,
    String publicToken,
  ) => PlaidService.exchangePublicToken(
    session,
    entityId: entityId,
    publicToken: publicToken,
  );

  /// Refreshes one connection: reported balances, valuations and movements.
  Future<PlaidConnection> syncConnection(
    Session session,
    UuidValue connectionId,
  ) => PlaidService.syncConnection(session, connectionId: connectionId);

  /// Lists the entity's connections, secrets never included.
  Future<List<PlaidConnection>> listConnections(
    Session session,
    UuidValue entityId,
  ) => PlaidService.listConnections(session, entityId: entityId);

  /// Removes a connection, revokes the item at Plaid, and keeps the
  /// accounts' imported history.
  Future<void> removeConnection(Session session, UuidValue connectionId) =>
      PlaidService.removeConnection(session, connectionId: connectionId);

  /// Creates a Plaid sandbox item and links it without client-side Link.
  Future<PlaidConnection> importSandboxAccounts(
    Session session,
    UuidValue entityId, {
    String? plaidInstitutionId,
  }) => PlaidService.importSandboxAccounts(
    session,
    entityId: entityId,
    plaidInstitutionId: plaidInstitutionId,
  );
}
