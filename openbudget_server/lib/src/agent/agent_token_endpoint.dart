import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/agent/mcp/agent_access_token_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Personal access tokens for external agents connecting over MCP.
///
/// Creating a token returns its secret exactly once. The server stores only a
/// hash, so a lost token is revoked and replaced, never recovered.
class AgentTokenEndpoint extends Endpoint {
  AgentTokenEndpoint({AgentAccessTokenService? tokens})
    : _tokens = tokens ?? AgentAccessTokenService();

  final AgentAccessTokenService _tokens;

  @override
  bool get requireLogin => true;

  /// Creates a token and returns its secret, which is never shown again.
  Future<AgentAccessTokenCreated> createAccessToken(
    Session session,
    String name,
    // The endpoint signature mirrors the client API and the MCP token flag.
    // ignore: avoid_positional_boolean_parameters
    bool canPropose,
  ) => _tokens.create(
    session,
    userId: requireAgentUserId(session),
    name: name,
    canPropose: canPropose,
  );

  /// Lists the user's tokens without their secret.
  Future<List<AgentAccessTokenView>> listAccessTokens(Session session) =>
      _tokens.list(session, requireAgentUserId(session));

  /// Revokes one of the user's tokens. Revoking twice is harmless.
  Future<AgentAccessTokenView> revokeAccessToken(
    Session session,
    UuidValue id,
  ) => _tokens.revoke(
    session,
    userId: requireAgentUserId(session),
    id: id,
  );
}
