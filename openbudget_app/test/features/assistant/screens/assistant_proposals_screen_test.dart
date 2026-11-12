import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_proposals_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../support/fake_assistant_api.dart';

Future<ProviderContainer> _pumpProposals(
  WidgetTester tester,
  FakeAssistantApi api,
) async {
  final container = ProviderContainer(
    overrides: [assistantApiProvider.overrideWith((ref) => api)],
  );
  addTearDown(container.dispose);

  await tester.pumpApp(
    const AssistantProposalsScreen(entityId: testBudgetId),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows pending proposals and collapses the history', (
    tester,
  ) async {
    final pending = testProposal(summary: r'Move $50 to groceries.');
    final applied = testProposal(
      summary: r'Move $20 to fuel.',
      status: AgentProposalStatus.applied,
    );
    await _pumpProposals(
      tester,
      FakeAssistantApi(proposals: [pending, applied]),
    );

    expect(find.text('Waiting for you'), findsOneWidget);
    expect(find.text(r'Move $50 to groceries.'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Past proposals'), findsOneWidget);
    expect(find.text(r'Move $20 to fuel.'), findsNothing);

    await tester.tap(find.text('Past proposals'));
    await tester.pumpAndSettle();

    expect(find.text(r'Move $20 to fuel.'), findsOneWidget);
    expect(find.text('Applied'), findsOneWidget);
  });

  testWidgets('applies a pending proposal and moves it to history', (
    tester,
  ) async {
    final pending = testProposal(summary: r'Move $50 to groceries.');
    final api = FakeAssistantApi(proposals: [pending]);
    await _pumpProposals(tester, api);

    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(api.applyCalls, [testProposalId]);
    expect(find.text(r'Move $50 to groceries.'), findsNothing);

    await tester.tap(find.text('Past proposals'));
    await tester.pumpAndSettle();
    expect(find.text(r'Move $50 to groceries.'), findsOneWidget);
    expect(find.text('Applied'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no proposals', (
    tester,
  ) async {
    await _pumpProposals(tester, FakeAssistantApi());

    expect(find.text('Nothing waiting'), findsOneWidget);
    expect(
      find.text(
        'When the assistant suggests a move, it waits here for you to apply '
        'or dismiss it.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an error state and retries', (tester) async {
    final api = FakeAssistantApi(proposalsError: Exception('offline'));
    await _pumpProposals(tester, api);

    expect(find.text('Could not load proposals.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
