import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_chat_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposal_actions_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_provider_settings_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../support/fake_assistant_api.dart';

ProviderContainer _container(FakeAssistantApi api) {
  final container = ProviderContainer(
    overrides: [assistantApiProvider.overrideWith((ref) => api)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AssistantChat', () {
    test('streams a turn into user, tool, proposal and reply items', () async {
      final proposal = testProposal();
      final api = FakeAssistantApi(
        proposals: [proposal],
        chatEvents: [
          agentEvent(AgentEventKind.toolCall, toolName: 'get_tax_report'),
          agentEvent(AgentEventKind.proposal, proposal: proposal),
          agentEvent(
            AgentEventKind.textDelta,
            text: r'You could move $50.',
          ),
          agentEvent(AgentEventKind.usage, costMicroUsd: 12000),
          agentEvent(AgentEventKind.done),
        ],
      );
      final container = _container(api);
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      container
          .read(assistantChatProvider(testBudgetId).notifier)
          .send('Where can I cut spending?');
      await pumpEventQueue();

      final state = container.read(assistantChatProvider(testBudgetId));
      expect(state.isStreaming, isFalse);
      expect(state.conversationId, testConversationId);
      expect(state.failure, isNull);
      expect(state.items, hasLength(4));
      expect(state.items[0], isA<AssistantUserMessage>());
      expect(
        (state.items[0] as AssistantUserMessage).text,
        'Where can I cut spending?',
      );
      expect(
        (state.items[1] as AssistantToolCall).toolName,
        'get_tax_report',
      );
      expect(
        (state.items[2] as AssistantProposalItem).proposal.id,
        testProposalId,
      );
      expect(
        (state.items[3] as AssistantAssistantMessage).text,
        r'You could move $50.',
      );
      expect(api.chatRequests.single.conversationId, isNull);
      expect(api.chatRequests.single.budgetId, testBudgetId);
    });

    test('opens an existing conversation in time order', () async {
      final api = FakeAssistantApi(
        messages: [
          testMessage(
            AgentMessageRole.user,
            'How much tax?',
            createdAt: DateTime(2026, 1, 1, 10),
          ),
          testMessage(
            AgentMessageRole.assistant,
            r'About $400.',
            createdAt: DateTime(2026, 1, 1, 10, 1),
          ),
        ],
        proposals: [
          testProposal(createdAt: DateTime(2026, 1, 1, 10, 2)),
          testProposal(
            summary: 'Another conversation',
            createdAt: DateTime(2026, 1, 1, 10, 3),
          ),
        ],
      );
      // The second proposal belongs to a different conversation.
      api.proposals[1] = api.proposals[1].copyWith(
        conversationId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000e99',
        ),
      );
      final container = _container(api);
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container
          .read(assistantChatProvider(testBudgetId).notifier)
          .openConversation(testConversation());

      final state = container.read(assistantChatProvider(testBudgetId));
      expect(state.conversationId, testConversationId);
      expect(state.isLoadingHistory, isFalse);
      expect(state.items, hasLength(3));
      expect(state.items[0], isA<AssistantUserMessage>());
      expect(state.items[1], isA<AssistantAssistantMessage>());
      expect(state.items[2], isA<AssistantProposalItem>());
    });

    test('maps a stream failure and retries the last question', () async {
      var failing = true;
      final api = FakeAssistantApi(
        chatStream: (budgetId, conversationId, message) => failing
            ? Stream.error(
                const AssistantFailure.validation(
                  message: 'Message must not be empty.',
                ),
              )
            : Stream.fromIterable([
                agentEvent(
                  AgentEventKind.textDelta,
                  text: 'Here is the answer.',
                ),
                agentEvent(AgentEventKind.done),
              ]),
      );
      final container = _container(api);
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(
        assistantChatProvider(testBudgetId).notifier,
      )..send('How much tax?');
      await pumpEventQueue();

      expect(
        container.read(assistantChatProvider(testBudgetId)).failure,
        const AssistantFailure.validation(
          message: 'Message must not be empty.',
        ),
      );

      failing = false;
      notifier.retryLastMessage();
      await pumpEventQueue();

      final state = container.read(assistantChatProvider(testBudgetId));
      expect(state.failure, isNull);
      expect(state.items, hasLength(2));
      expect(state.items[0], isA<AssistantUserMessage>());
      expect(
        (state.items[1] as AssistantAssistantMessage).text,
        'Here is the answer.',
      );
      expect(api.chatRequests, hasLength(2));
    });

    test('starts a new conversation with an empty state', () async {
      final container = _container(
        FakeAssistantApi(
          chatEvents: [
            agentEvent(AgentEventKind.textDelta, text: 'Hello'),
            agentEvent(AgentEventKind.done),
          ],
        ),
      );
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      final notifier = container.read(
        assistantChatProvider(testBudgetId).notifier,
      )..send('Hi');
      await pumpEventQueue();
      notifier.startNewConversation();

      final state = container.read(assistantChatProvider(testBudgetId));
      expect(state.items, isEmpty);
      expect(state.conversationId, isNull);
    });
  });

  group('AssistantProposalActions', () {
    test('applies a proposal and updates the chat card', () async {
      final proposal = testProposal();
      final api = FakeAssistantApi(
        proposals: [proposal],
        chatEvents: [
          agentEvent(AgentEventKind.proposal, proposal: proposal),
          agentEvent(AgentEventKind.textDelta, text: 'Done.'),
          agentEvent(AgentEventKind.done),
        ],
      );
      final container = _container(api);
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      container
          .read(assistantChatProvider(testBudgetId).notifier)
          .send('Move some money');
      await pumpEventQueue();
      await container
          .read(assistantProposalActionsProvider.notifier)
          .apply(budgetId: testBudgetId, proposalId: testProposalId);

      expect(api.applyCalls, [testProposalId]);
      final item = container
          .read(assistantChatProvider(testBudgetId))
          .items
          .whereType<AssistantProposalItem>()
          .single;
      expect(item.proposal.status, AgentProposalStatus.applied);
    });

    test('dismisses a proposal and updates the chat card', () async {
      final proposal = testProposal();
      final api = FakeAssistantApi(
        proposals: [proposal],
        chatEvents: [
          agentEvent(AgentEventKind.proposal, proposal: proposal),
          agentEvent(AgentEventKind.textDelta, text: 'Done.'),
          agentEvent(AgentEventKind.done),
        ],
      );
      final container = _container(api);
      final subscription = container.listen(
        assistantChatProvider(testBudgetId),
        (_, _) {},
      );
      addTearDown(subscription.close);

      container
          .read(assistantChatProvider(testBudgetId).notifier)
          .send('Move some money');
      await pumpEventQueue();
      await container
          .read(assistantProposalActionsProvider.notifier)
          .dismiss(budgetId: testBudgetId, proposalId: testProposalId);

      expect(api.dismissCalls, [testProposalId]);
      final item = container
          .read(assistantChatProvider(testBudgetId))
          .items
          .whereType<AssistantProposalItem>()
          .single;
      expect(item.proposal.status, AgentProposalStatus.dismissed);
    });
  });

  group('AssistantProposals', () {
    test('splits pending proposals from resolved history', () async {
      final api = FakeAssistantApi(
        proposals: [
          testProposal(summary: 'Pending move'),
          testProposal(
            summary: 'Applied move',
            status: AgentProposalStatus.applied,
          ),
          testProposal(
            summary: 'Dismissed move',
            status: AgentProposalStatus.dismissed,
          ),
        ],
      );
      final container = _container(api);

      final state = await container.read(
        assistantProposalsProvider(testBudgetId).future,
      );

      expect(state.pending.map((card) => card.summary), ['Pending move']);
      expect(state.history.map((card) => card.summary), [
        'Applied move',
        'Dismissed move',
      ]);
    });
  });

  group('AssistantProviderSettings', () {
    test('saves and removes the user provider', () async {
      final api = FakeAssistantApi();
      final container = _container(api);
      final subscription = container.listen(
        assistantProviderSettingsProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(assistantProviderSettingsProvider.future);

      final notifier = container.read(
        assistantProviderSettingsProvider.notifier,
      );
      final saved = await notifier.save(
        baseUrl: 'https://api.example.com/v1',
        model: 'model-a',
        apiKey: 'sk-test-abcd',
      );

      expect(saved.keyHint, 'abcd');
      expect(api.saveRequests.single.baseUrl, 'https://api.example.com/v1');
      expect(
        container.read(assistantProviderSettingsProvider).value?.keyHint,
        'abcd',
      );

      await notifier.remove();
      expect(api.clearCalls, 1);
      expect(container.read(assistantProviderSettingsProvider).value, isNull);
    });
  });
}
