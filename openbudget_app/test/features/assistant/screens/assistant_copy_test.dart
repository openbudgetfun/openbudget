import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_conversations_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_proposals_screen.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_provider_screen.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_message_bubble.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../../tax/tax_test_data.dart' show testEntity;
import '../support/fake_assistant_api.dart';

// The feature is the Money guide (docs/money-guide.md, section 3). The code and
// ARB keys keep the `assistant` name, but no word a person sees or hears may.

final _assistantWord = RegExp('assistant', caseSensitive: false);

/// Every piece of text the current frame shows or speaks: painted text,
/// tooltips and semantic labels.
List<String> _renderedText(WidgetTester tester) => [
  for (final widget in tester.allWidgets)
    ...switch (widget) {
      RichText(:final text) => [text.toPlainText()],
      Tooltip(:final message?) => [message],
      Semantics(:final properties) when properties.label != null => [
        properties.label!,
      ],
      _ => const <String>[],
    },
];

void _expectNoAssistantLabel(WidgetTester tester, String where) {
  final texts = _renderedText(tester);
  expect(texts, isNotEmpty, reason: where);
  expect(
    texts.where(_assistantWord.hasMatch),
    isEmpty,
    reason: 'An "assistant" label is visible on $where',
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  FakeAssistantApi api,
) async {
  final container = ProviderContainer(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => testEntity(id: testBudgetId),
      ),
      assistantApiProvider.overrideWith((ref) => api),
      assistantUsageProvider.overrideWith((ref) async => api.usage),
      assistantConversationsProvider.overrideWith(
        (ref, id) async => api.conversations,
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpApp(
    screen,
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the empty conversation says Money guide', (tester) async {
    await _pump(
      tester,
      const AssistantScreen(entityId: testBudgetId),
      FakeAssistantApi(usage: testUsage(conversationsLeft: 12)),
    );

    expect(find.text('Money guide'), findsOneWidget);
    expect(find.text('Ask the Money guide'), findsOneWidget);
    _expectNoAssistantLabel(tester, 'the empty conversation');
  });

  testWidgets('a turn, its sources and the conversation list', (tester) async {
    final proposal = testProposal();
    final api = FakeAssistantApi(
      conversations: [testConversation()],
      proposals: [proposal],
      chatEvents: [
        agentEvent(AgentEventKind.toolCall, toolName: 'get_tax_report'),
        agentEvent(AgentEventKind.proposal, proposal: proposal),
        agentEvent(
          AgentEventKind.textDelta,
          text: 'The allowance is £3,000[^gb-cgt-aea].',
          citations: [
            testCitation('gb-cgt-aea', grade: 'secondary', announced: true),
          ],
          touchesTaxOrInvestment: true,
        ),
        agentEvent(AgentEventKind.done),
      ],
    );
    await _pump(tester, const AssistantScreen(entityId: testBudgetId), api);

    await tester.tap(find.text('How much tax will I owe this year?'));
    await tester.pumpAndSettle();
    _expectNoAssistantLabel(tester, 'a reply');

    await tester.tap(find.byKey(AssistantReplyBubble.sourcesButtonKey));
    await tester.pumpAndSettle();
    _expectNoAssistantLabel(tester, 'the sources sheet');
    Navigator.of(tester.element(find.text('Sources'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AssistantScreen.conversationsButtonKey));
    await tester.pumpAndSettle();
    _expectNoAssistantLabel(tester, 'the conversations sheet');
  });

  for (final failure in const <AssistantFailure>[
    AssistantFailure.entitlementRequired(),
    AssistantFailure.allowanceExhausted(),
    AssistantFailure.providerUnavailable(),
    AssistantFailure.network(),
    AssistantFailure.unknown(),
  ]) {
    testWidgets('the ${failure.runtimeType} failure', (tester) async {
      await _pump(
        tester,
        const AssistantScreen(entityId: testBudgetId),
        FakeAssistantApi(chatError: failure),
      );

      await tester.tap(find.text('Where can I cut spending?'));
      await tester.pumpAndSettle();

      _expectNoAssistantLabel(tester, 'the ${failure.runtimeType} failure');
    });
  }

  testWidgets('the empty suggestions screen', (tester) async {
    await _pump(
      tester,
      const AssistantProposalsScreen(entityId: testBudgetId),
      FakeAssistantApi(),
    );
    expect(find.text('Money guide suggestions'), findsOneWidget);
    _expectNoAssistantLabel(tester, 'the empty suggestions screen');
  });

  testWidgets('the suggestions screen with history', (tester) async {
    await _pump(
      tester,
      const AssistantProposalsScreen(entityId: testBudgetId),
      FakeAssistantApi(
        proposals: [
          testProposal(),
          testProposal(status: AgentProposalStatus.applied),
        ],
      ),
    );
    _expectNoAssistantLabel(tester, 'the suggestions screen');
  });

  testWidgets('the provider form', (tester) async {
    await _pump(tester, const AssistantProviderScreen(), FakeAssistantApi());
    expect(find.text('Money guide provider'), findsOneWidget);
    _expectNoAssistantLabel(tester, 'the provider form');
  });

  testWidgets('the connected provider screen', (tester) async {
    await _pump(
      tester,
      const AssistantProviderScreen(),
      FakeAssistantApi(
        providerSettings: AgentProviderSettingsView(
          baseUrl: 'https://api.example.com/v1',
          model: 'model-a',
          keyHint: 'abcd',
        ),
      ),
    );
    _expectNoAssistantLabel(tester, 'the connected provider');
  });
}
