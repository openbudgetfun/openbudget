import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_conversations_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_message_bubble.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_sources_sheet.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../tax/tax_test_data.dart' show testEntity;
import '../support/fake_assistant_api.dart';

Future<ProviderContainer> _pumpAssistant(
  WidgetTester tester,
  FakeAssistantApi api, {
  AgentUsageView? usage,
  List<AgentConversation> conversations = const [],
  String countryCode = 'GB',
}) async {
  final container = ProviderContainer(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async =>
            testEntity(id: testBudgetId, countryCode: countryCode),
      ),
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

    expect(find.text('Ask the Money guide'), findsOneWidget);
    expect(find.text('Ask about money, tax or crypto…'), findsOneWidget);
    expect(find.text('Ask about this plan…'), findsNothing);
    expect(find.text('How much tax will I owe this year?'), findsOneWidget);
    expect(find.text('Where can I cut spending?'), findsOneWidget);
    expect(find.text('Am I on track for my goals?'), findsOneWidget);
    expect(
      find.text('Guidance, not regulated financial advice.'),
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
    expect(find.text('The Money guide is thinking…'), findsOneWidget);
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
      title: 'The Money guide has no provider right now',
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
      title: "Couldn't reach the Money guide",
      text: 'Check your connection and try again.',
    ),
    (
      failure: const AssistantFailure.unknown(),
      title: "The Money guide couldn't finish",
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

    expect(find.text(r'$0.42 of $5.00 used this month'), findsOneWidget);
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

  testWidgets('says about how many conversations are left', (tester) async {
    await _pumpAssistant(
      tester,
      FakeAssistantApi(),
      usage: testUsage(conversationsLeft: 42),
    );

    expect(find.text('About 42 conversations left this month'), findsOneWidget);
  });

  testWidgets('says when one conversation is left', (tester) async {
    await _pumpAssistant(
      tester,
      FakeAssistantApi(),
      usage: testUsage(conversationsLeft: 1),
    );

    expect(find.text('About 1 conversation left this month'), findsOneWidget);
  });

  testWidgets('hides the conversations-left line without an estimate', (
    tester,
  ) async {
    await _pumpAssistant(tester, FakeAssistantApi(), usage: testUsage());

    expect(find.textContaining('left this month'), findsNothing);
  });

  testWidgets('shows a cited reply with its marks and disclaimer', (
    tester,
  ) async {
    final api = FakeAssistantApi(
      chatEvents: [
        agentEvent(
          AgentEventKind.textDelta,
          text: 'The allowance is £3,000[^gb-cgt-aea].',
          citations: [testCitation('gb-cgt-aea', grade: 'secondary')],
          touchesTaxOrInvestment: true,
        ),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('How much tax will I owe this year?'));
    await tester.pumpAndSettle();

    final mark = assistantCitationMark('1');
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text
                .toPlainText(includeSemanticsLabels: false)
                .contains(mark),
      ),
      findsOneWidget,
    );
    expect(find.byKey(AssistantReplyBubble.disclaimerKey), findsOneWidget);

    await tester.tap(find.byKey(AssistantReplyBubble.sourcesButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(AssistantSourcesSheet.sheetKey), findsOneWidget);
    expect(find.text('From a secondary source'), findsOneWidget);
  });
  group('reply disclaimer', () {
    const footer = 'Guidance, not regulated financial advice.';

    Future<void> askTaxQuestion(WidgetTester tester, String countryCode) async {
      final api = FakeAssistantApi(
        chatEvents: [
          agentEvent(
            AgentEventKind.textDelta,
            text: 'The allowance is £3,000.',
            touchesTaxOrInvestment: true,
          ),
          agentEvent(AgentEventKind.done),
        ],
      );
      await _pumpAssistant(tester, api, countryCode: countryCode);
      await tester.tap(find.text('How much tax will I owe this year?'));
      await tester.pumpAndSettle();
    }

    String disclaimerText(WidgetTester tester) => tester
        .widget<Text>(find.byKey(AssistantReplyBubble.disclaimerKey))
        .data!;

    testWidgets('shows the GB disclaimer, not the footer twice', (
      tester,
    ) async {
      await askTaxQuestion(tester, 'GB');

      expect(disclaimerText(tester), contains('ISA product'));
      expect(find.text(footer), findsOneWidget);
    });

    const wording = {
      'US': 'not a written federal tax opinion',
      'DE': 'Lohnsteuerhilfeverein',
      'NG': 'registered tax practitioner',
    };
    for (final MapEntry(key: country, value: phrase) in wording.entries) {
      testWidgets('shows its own wording for $country', (tester) async {
        await askTaxQuestion(tester, country);

        expect(disclaimerText(tester), contains(phrase));
        expect(find.text(footer), findsOneWidget);
      });
    }

    testWidgets('falls back to the generic text for an unserved country', (
      tester,
    ) async {
      await askTaxQuestion(tester, 'KE');

      expect(
        disclaimerText(tester),
        'Information only, not tax, legal or investment advice. Rules change, '
        'so check with a qualified professional before you act on it.',
      );
      expect(disclaimerText(tester), isNot(footer));
      expect(find.text(footer), findsOneWidget);
    });

    testWidgets('shows no disclaimer under a reply that is not about tax', (
      tester,
    ) async {
      final api = FakeAssistantApi(
        chatEvents: [
          agentEvent(AgentEventKind.textDelta, text: r'Trim dining by $50.'),
          agentEvent(AgentEventKind.done),
        ],
      );
      await _pumpAssistant(tester, api);
      await tester.tap(find.text('Where can I cut spending?'));
      await tester.pumpAndSettle();

      expect(find.byKey(AssistantReplyBubble.disclaimerKey), findsNothing);
    });
  });

  testWidgets('labels every server tool with its own words', (tester) async {
    const labels = {
      'list_entities': 'Looked at your budgets',
      'search_knowledge': 'Checked the sourced rules',
      'get_spending_summary': 'Looked at your spending',
      'get_tax_calendar': 'Checked your tax deadlines',
      'get_tax_summary': 'Looked at your tax summary',
      'get_net_worth': 'Looked at your net worth',
    };
    final api = FakeAssistantApi(
      chatEvents: [
        for (final tool in labels.keys)
          agentEvent(AgentEventKind.toolCall, toolName: tool),
        agentEvent(AgentEventKind.textDelta, text: 'All checked.'),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pumpAssistant(tester, api);

    await tester.tap(find.text('How much tax will I owe this year?'));
    await tester.pumpAndSettle();

    for (final label in labels.values) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Looked something up'), findsNothing);
  });
}
