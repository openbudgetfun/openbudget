import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

/// Builds an agent access token view for tests.
AgentAccessTokenView makeAgentToken({
  String id = '00000000-0000-0000-0000-000000000b01',
  String name = 'Claude Code',
  String tokenPrefix = 'obk_12345678',
  bool canPropose = true,
  DateTime? createdAt,
  DateTime? lastUsedAt,
  DateTime? revokedAt,
}) => AgentAccessTokenView(
  id: UuidValue.fromString(id),
  name: name,
  tokenPrefix: tokenPrefix,
  canPropose: canPropose,
  createdAt: createdAt ?? DateTime.utc(2026, 2, 1, 9),
  lastUsedAt: lastUsedAt,
  revokedAt: revokedAt,
);

/// An [AgentTokenApi] that records calls and returns test data.
class FakeAgentTokenApi implements AgentTokenApi {
  List<AgentAccessTokenView> tokens = [];

  String token = 'obk_new_secret_token';

  int listCalls = 0;
  int createCalls = 0;
  int revokeCalls = 0;

  Exception? listError;
  Exception? createError;
  Exception? revokeError;

  String? lastName;
  bool? lastCanPropose;
  UuidValue? lastRevokedId;

  int _nextId = 1;

  @override
  Future<AgentAccessTokenCreated> createAccessToken({
    required String name,
    required bool canPropose,
  }) async {
    createCalls++;
    lastName = name;
    lastCanPropose = canPropose;
    if (createError case final error?) throw error;

    final id = _nextId++;
    final view = makeAgentToken(
      id: '00000000-0000-0000-0000-${id.toString().padLeft(12, '0')}',
      name: name,
      tokenPrefix: token.substring(0, 12),
      canPropose: canPropose,
      createdAt: DateTime.utc(2026, 3),
    );
    tokens = [view, ...tokens];
    return AgentAccessTokenCreated(token: token, view: view);
  }

  @override
  Future<List<AgentAccessTokenView>> listAccessTokens() async {
    listCalls++;
    if (listError case final error?) throw error;
    return List.of(tokens);
  }

  @override
  Future<AgentAccessTokenView> revokeAccessToken(UuidValue id) async {
    revokeCalls++;
    lastRevokedId = id;
    if (revokeError case final error?) throw error;

    final revoked = tokens
        .firstWhere((token) => token.id == id)
        .copyWith(revokedAt: DateTime.utc(2026, 3, 2));
    tokens = [
      for (final token in tokens)
        if (token.id == id) revoked else token,
    ];
    return revoked;
  }
}
