import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

import 'test_data.dart';

/// An [AgentTokenApi] for the Patrol flow, with no server behind it.
class FakeAgentTokenApi implements AgentTokenApi {
  final List<AgentAccessTokenView> tokens = [];

  int createCalls = 0;
  int revokeCalls = 0;
  String? lastName;
  bool? lastCanPropose;

  @override
  Future<AgentAccessTokenCreated> createAccessToken({
    required String name,
    required bool canPropose,
  }) async {
    createCalls++;
    lastName = name;
    lastCanPropose = canPropose;

    final view = AgentAccessTokenView(
      id: UuidValue.fromString(TestData.agentAccessTokenId),
      name: name,
      tokenPrefix: TestData.agentAccessToken.substring(0, 12),
      canPropose: canPropose,
      createdAt: DateTime.utc(2026, 3),
    );
    tokens.insert(0, view);
    return AgentAccessTokenCreated(
      token: TestData.agentAccessToken,
      view: view,
    );
  }

  @override
  Future<List<AgentAccessTokenView>> listAccessTokens() async =>
      List.of(tokens);

  @override
  Future<AgentAccessTokenView> revokeAccessToken(UuidValue id) async {
    revokeCalls++;
    final index = tokens.indexWhere((token) => token.id == id);
    final revoked = tokens[index].copyWith(revokedAt: DateTime.utc(2026, 3, 2));
    tokens[index] = revoked;
    return revoked;
  }
}
