import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_conversations_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../support/fake_assistant_api.dart';

Future<ProviderContainer> _pumpAssistant(
  WidgetTester tester,
  FakeAssistantApi api, {
  AgentUsageView? usage,
  List<AgentConversation> conversations = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      assistantApiProvider.overrideWith((ref) => api),
      assistantUsageProvider.overrideWith((ref) async => usage ?? testUsage()),
      assistantConversationsProvider.overrideWith(
        (ref, id) async => conversations,
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpApp(
    const AssistantScreen(entityId: testBudgetId),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows the empty state and sends a suggested prompt', (
    tester,
  ) async {
    final api = FakeAssistantApi(
      chatEvents: [
        agentEvent(
          AgentEventKind.textDelta,
          text: 'Start with your dining budget.',
        ),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    expect(find.text('Ask about this plan'), findsOneWidget);
    expect(find.text('How much tax will I owe this year?'), findsOneWidget);
    expect(find.text('Where can I cut spending?'), findsOneWidget);
    expect(find.text('Am I on track for my goals?'), findsOneWidget);
    expect(
      find.text('Guidance only, not financial or tax advice.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Where can I cut spending?'));
    await tester.pumpAndSettle();

    expect(api.chatRequests.single.message, 'Where can I cut spending?');
    expect(find.text('Start with your dining budget.'), findsOneWidget);
  });

  testWidgets('shows a typing indicator while the stream is open', (
    tester,
  ) async {
    final controller = StreamController<AgentEvent>();
    addTearDown(controller.close);
    final api = FakeAssistantApi(
      chatStream: (entityId, conversationId, message) => controller.stream,
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('How much tax will I owe this year?'));
    await tester.pump();

    expect(find.byType(WiredLoadingIndicator), findsOneWidget);
    expect(find.text('The assistant is thinking…'), findsOneWidget);
    expect(
      tester
          .widget<ObTextField>(find.byKey(AssistantScreen.composerFieldKey))
          .enabled,
      isFalse,
    );

    controller
      ..add(agentEvent(AgentEventKind.textDelta, text: r'About $412.'))
      ..add(agentEvent(AgentEventKind.done));
    await tester.pumpAndSettle();

    expect(find.byType(WiredLoadingIndicator), findsNothing);
    expect(find.text(r'About $412.'), findsOneWidget);
  });

  testWidgets('shows a tool call as a small chip', (tester) async {
    final api = FakeAssistantApi(
      chatEvents: [
        agentEvent(AgentEventKind.toolCall, toolName: 'get_tax_report'),
        agentEvent(
          AgentEventKind.textDelta,
          text: r'Your tax report says $412.',
        ),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('How much tax will I owe this year?'));
    await tester.pumpAndSettle();

    expect(find.text('Looked at your tax report'), findsOneWidget);
    expect(find.text(r'Your tax report says $412.'), findsOneWidget);
  });

  testWidgets('applies an inline proposal and shows the applied state', (
    tester,
  ) async {
    final proposal = testProposal();
    final api = FakeAssistantApi(
      proposals: [proposal],
      chatEvents: [
        agentEvent(AgentEventKind.proposal, proposal: proposal),
        agentEvent(AgentEventKind.textDelta, text: r'This would free up $50.'),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('Where can I cut spending?'));
    await tester.pumpAndSettle();

    expect(find.text(proposal.summary), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(api.applyCalls, [testProposalId]);
    expect(find.text('Applied'), findsOneWidget);
    expect(find.text('Apply'), findsNothing);
  });

  testWidgets('dismisses an inline proposal and shows the dismissed state', (
    tester,
  ) async {
    final proposal = testProposal();
    final api = FakeAssistantApi(
      proposals: [proposal],
      chatEvents: [
        agentEvent(AgentEventKind.proposal, proposal: proposal),
        agentEvent(AgentEventKind.textDelta, text: r'This would free up $50.'),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('Where can I cut spending?'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(api.dismissCalls, [testProposalId]);
    expect(find.text('Dismissed'), findsOneWidget);
    expect(find.text('Dismiss'), findsNothing);
  });

  final failures = <({AssistantFailure failure, String title, String text})>[
    (
      failure: const AssistantFailure.entitlementRequired(),
      title: 'OpenBudget Plus is needed',
      text: 'Use your own provider',
    ),
    (
      failure: const AssistantFailure.allowanceExhausted(),
      title: 'Included usage is spent',
      text: 'Use your own provider',
    ),
    (
      failure: const AssistantFailure.providerUnavailable(),
      title: 'The assistant has no provider right now',
      text:
          "The built-in provider isn't available. Try again, or connect "
          'your own OpenAI-compatible provider.',
    ),
    (
      failure: const AssistantFailure.validation(
        message: 'Message must not be empty.',
      ),
      title: "That request wasn't valid",
      text: 'Message must not be empty.',
    ),
    (
      failure: const AssistantFailure.network(),
      title: "Couldn't reach the assistant",
      text: 'Check your connection and try again.',
    ),
    (
      failure: const AssistantFailure.unknown(),
      title: "The assistant couldn't finish",
      text: 'Something went wrong while answering. Try again.',
    ),
  ];

  for (final failureCase in failures) {
    testWidgets('shows the ${failureCase.title} error state', (tester) async {
      final api = FakeAssistantApi(chatError: failureCase.failure);
      await _pumpAssistant(tester, api);

      await tester.tap(find.text('Where can I cut spending?'));
      await tester.pumpAndSettle();

      expect(find.text(failureCase.title), findsOneWidget);
      expect(find.text(failureCase.text), findsOneWidget);
    });
  }

  testWidgets('shows the included usage meter for the built-in provider', (
    tester,
  ) async {
    await _pumpAssistant(
      tester,
      FakeAssistantApi(),
      usage: testUsage(),
    );

    expect(find.text(r'$0.42 of $1.00 used this month'), findsOneWidget);
    expect(find.byType(ObEnvelopeGauge), findsOneWidget);
  });

  testWidgets('says when the user provider is answering', (tester) async {
    await _pumpAssistant(
      tester,
      FakeAssistantApi(),
      usage: testUsage(
        provider: AgentProvider.byo,
        allowanceMicroUsd: 0,
        usedMicroUsd: 0,
      ),
    );

    expect(find.text('Using your own provider'), findsOneWidget);
    expect(find.text(r'$0.00 of $0.00 used this month'), findsNothing);
  });
}
