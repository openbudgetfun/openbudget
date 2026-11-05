import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent_token_api.g.dart';

/// The agent-token calls the Agent access screen needs.
///
/// A narrow interface keeps every provider testable with a fake instead of a
/// live Serverpod client, while production wraps the generated endpoint.
abstract interface class AgentTokenApi {
  /// Creates a token. Its secret is returned exactly once.
  Future<AgentAccessTokenCreated> createAccessToken({
    required String name,
    required bool canPropose,
  });

  /// Lists every token the signed-in user owns, newest first.
  Future<List<AgentAccessTokenView>> listAccessTokens();

  /// Revokes one of the user's tokens. Revoking twice is harmless.
  Future<AgentAccessTokenView> revokeAccessToken(UuidValue id);
}

/// [AgentTokenApi] backed by the generated Serverpod token endpoint.
class ServerpodAgentTokenApi implements AgentTokenApi {
  const ServerpodAgentTokenApi(this._endpoint);

  final EndpointAgentToken _endpoint;

  @override
  Future<AgentAccessTokenCreated> createAccessToken({
    required String name,
    required bool canPropose,
  }) => _endpoint.createAccessToken(name, canPropose);

  @override
  Future<List<AgentAccessTokenView>> listAccessTokens() =>
      _endpoint.listAccessTokens();

  @override
  Future<AgentAccessTokenView> revokeAccessToken(UuidValue id) =>
      _endpoint.revokeAccessToken(id);
}

/// The agent-token calls used by the Agent access feature.
@Riverpod(keepAlive: true)
AgentTokenApi agentTokenApi(Ref ref) =>
    ServerpodAgentTokenApi(ref.watch(serverpodClientProvider).agentToken);
