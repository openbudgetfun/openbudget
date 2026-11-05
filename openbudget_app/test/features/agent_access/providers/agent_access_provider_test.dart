import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/agent_access/models/agent_access_state.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_access_provider.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../support/fakes.dart';

void main() {
  late FakeAgentTokenApi api;

  setUp(() {
    api = FakeAgentTokenApi();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [agentTokenApiProvider.overrideWithValue(api)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      agentAccessTokensProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    return container;
  }

  group('AgentAccessTokens list', () {
    test('lists every token the server returns', () async {
      final active = makeAgentToken(
        lastUsedAt: DateTime.utc(2026, 2, 20),
      );
      final revoked = makeAgentToken(
        id: '00000000-0000-0000-0000-000000000b02',
        name: 'Codex',
        revokedAt: DateTime.utc(2026, 2, 22),
      );
      api.tokens = [active, revoked];

      final container = makeContainer();
      final state = await container.read(agentAccessTokensProvider.future);

      expect(api.listCalls, 1);
      expect(state.tokens, [active, revoked]);
      expect(state.tokens.first.lastUsedAt, isNotNull);
      expect(state.tokens.last.revokedAt, isNotNull);
      expect(state.failure, isNull);
    });
  });

  group('AgentAccessTokens create', () {
    test('returns the secret once and refreshes the list', () async {
      api.tokens = [makeAgentToken(name: 'Existing')];

      final container = makeContainer();
      await container.read(agentAccessTokensProvider.future);
      expect(api.listCalls, 1);

      final created = await container
          .read(agentAccessTokensProvider.notifier)
          .create(name: 'Claude Code', canPropose: true);

      expect(created, isNotNull);
      expect(created!.token, api.token);
      expect(created.view.name, 'Claude Code');
      expect(api.createCalls, 1);
      expect(api.lastName, 'Claude Code');
      expect(api.lastCanPropose, isTrue);
      expect(api.listCalls, 2);

      final state = container.read(agentAccessTokensProvider).requireValue;
      expect(state.isCreating, isFalse);
      expect(state.tokens.first.name, 'Claude Code');
      expect(state.tokens.last.name, 'Existing');
    });

    test('records a validation message from the server', () async {
      api.createError = ValidationException(
        message: 'A user can have at most 10 unrevoked access tokens.',
      );

      final container = makeContainer();
      await container.read(agentAccessTokensProvider.future);

      final created = await container
          .read(agentAccessTokensProvider.notifier)
          .create(name: 'Claude Code', canPropose: true);

      expect(created, isNull);
      expect(api.listCalls, 1);

      final state = container.read(agentAccessTokensProvider).requireValue;
      expect(state.isCreating, isFalse);
      expect(
        state.failure,
        const AgentAccessFailure.validation(
          message: 'A user can have at most 10 unrevoked access tokens.',
        ),
      );
    });

    test('maps anything else to the generic failure', () async {
      api.createError = Exception('boom');

      final container = makeContainer();
      await container.read(agentAccessTokensProvider.future);

      await container
          .read(agentAccessTokensProvider.notifier)
          .create(name: 'Claude Code', canPropose: true);

      final state = container.read(agentAccessTokensProvider).requireValue;
      expect(state.failure, const AgentAccessFailure.unknown());
    });
  });

  group('AgentAccessTokens revoke', () {
    test('revokes the token and refreshes the list', () async {
      final token = makeAgentToken();
      api.tokens = [token];

      final container = makeContainer();
      await container.read(agentAccessTokensProvider.future);

      final revoked = await container
          .read(agentAccessTokensProvider.notifier)
          .revoke(token.id);

      expect(revoked, isTrue);
      expect(api.revokeCalls, 1);
      expect(api.lastRevokedId, token.id);
      expect(api.listCalls, 2);

      final state = container.read(agentAccessTokensProvider).requireValue;
      expect(state.revokingId, isNull);
      expect(state.tokens.single.revokedAt, isNotNull);
    });

    test('a missing token becomes the generic failure', () async {
      final token = makeAgentToken();
      api
        ..tokens = [token]
        ..revokeError = NotFoundException(message: 'Access token not found');

      final container = makeContainer();
      await container.read(agentAccessTokensProvider.future);

      final revoked = await container
          .read(agentAccessTokensProvider.notifier)
          .revoke(token.id);

      expect(revoked, isFalse);
      expect(api.listCalls, 1);

      final state = container.read(agentAccessTokensProvider).requireValue;
      expect(state.revokingId, isNull);
      expect(state.failure, const AgentAccessFailure.unknown());
      expect(state.tokens.single.revokedAt, isNull);
    });
  });
}
