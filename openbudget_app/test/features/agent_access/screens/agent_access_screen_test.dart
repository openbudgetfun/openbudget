import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_app/src/features/agent_access/screens/agent_access_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../support/fakes.dart';

ProviderContainer _container(FakeAgentTokenApi api) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [agentTokenApiProvider.overrideWithValue(api)],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
) {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpApp(
    const AgentAccessScreen(),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

String _date(DateTime timestamp) =>
    DateFormat.yMMMd().format(timestamp.toLocal());

void main() {
  group('AgentAccessScreen', () {
    testWidgets('shows the empty state and the create form', (tester) async {
      final container = _container(FakeAgentTokenApi());

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('No agent tokens yet'), findsOneWidget);
      expect(
        find.text(
          'Create a token above, then point your MCP client at the server.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(AgentAccessScreen.nameFieldKey), findsOneWidget);
      expect(
        find.byKey(AgentAccessScreen.canProposeSwitchKey),
        findsOneWidget,
      );
      expect(find.byKey(AgentAccessScreen.createButtonKey), findsOneWidget);
    });

    testWidgets('lists active and revoked tokens', (tester) async {
      final active = makeAgentToken(name: 'Work laptop');
      final revoked = makeAgentToken(
        id: '00000000-0000-0000-0000-000000000b02',
        name: 'Codex',
        tokenPrefix: 'obk_87654321',
        createdAt: DateTime.utc(2026, 2, 10),
        lastUsedAt: DateTime.utc(2026, 2, 20, 15),
        revokedAt: DateTime.utc(2026, 2, 22, 10),
      );
      final api = FakeAgentTokenApi()..tokens = [active, revoked];
      final container = _container(api);

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Work laptop'), findsOneWidget);
      expect(find.text('Codex'), findsOneWidget);
      expect(find.text('obk_12345678…'), findsOneWidget);
      expect(find.text('obk_87654321…'), findsOneWidget);
      expect(find.text('Created ${_date(active.createdAt)}'), findsOneWidget);
      expect(find.text('Never used'), findsOneWidget);
      expect(
        find.text('Last used ${_date(revoked.lastUsedAt!)}'),
        findsOneWidget,
      );
      expect(find.text('Revoked'), findsOneWidget);
      expect(
        find.byKey(AgentAccessScreen.revokeButtonKey(active.id)),
        findsOneWidget,
      );
      expect(
        find.byKey(AgentAccessScreen.revokeButtonKey(revoked.id)),
        findsNothing,
      );
    });

    testWidgets('creates a token, shows it once and copies it', (
      tester,
    ) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            final data = call.arguments as Map<Object?, Object?>;
            copied.add(data['text']! as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final api = FakeAgentTokenApi();
      final container = _container(api);

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(AgentAccessScreen.nameFieldKey),
        'Claude Code CLI',
      );
      await tester.tap(find.byKey(AgentAccessScreen.canProposeSwitchKey));
      await tester.pump();
      await tester.tap(find.byKey(AgentAccessScreen.createButtonKey));
      await tester.pumpAndSettle();

      expect(api.createCalls, 1);
      expect(api.lastName, 'Claude Code CLI');
      expect(api.lastCanPropose, isFalse);
      expect(api.listCalls, 2);

      expect(find.byKey(AgentAccessScreen.tokenDialogKey), findsOneWidget);
      expect(find.text(api.token), findsOneWidget);
      expect(
        find.text(
          'Copy this token now. It is shown once and cannot be recovered; '
          'the server stores only its hash.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(AgentAccessScreen.copyButtonKey));
      await tester.pumpAndSettle();

      expect(copied, [api.token]);
      expect(find.byKey(AgentAccessScreen.tokenDialogKey), findsNothing);
      expect(find.text('Token copied to clipboard.'), findsOneWidget);
      expect(find.text('Claude Code CLI'), findsOneWidget);
    });

    testWidgets('revokes a token after confirmation', (tester) async {
      final token = makeAgentToken();
      final api = FakeAgentTokenApi()..tokens = [token];
      final container = _container(api);

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(AgentAccessScreen.revokeButtonKey(token.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Revoke this token?'), findsOneWidget);
      expect(
        find.text(
          'Any agent using this token stops working immediately. '
          'This cannot be undone.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Revoke token'));
      await tester.pumpAndSettle();

      expect(api.revokeCalls, 1);
      expect(api.lastRevokedId, token.id);
      expect(find.text('Revoked'), findsOneWidget);
      expect(find.text('Token revoked.'), findsOneWidget);
      expect(
        find.byKey(AgentAccessScreen.revokeButtonKey(token.id)),
        findsNothing,
      );
    });

    testWidgets('shows the server validation message', (tester) async {
      final api = FakeAgentTokenApi()
        ..createError = ValidationException(
          message: 'A user can have at most 10 unrevoked access tokens.',
        );
      final container = _container(api);

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(AgentAccessScreen.nameFieldKey),
        'Claude Code',
      );
      await tester.tap(find.byKey(AgentAccessScreen.createButtonKey));
      await tester.pumpAndSettle();

      expect(
        find.text('A user can have at most 10 unrevoked access tokens.'),
        findsOneWidget,
      );
      expect(find.byKey(AgentAccessScreen.tokenDialogKey), findsNothing);
    });

    testWidgets('shows the generic failure for anything else', (
      tester,
    ) async {
      final api = FakeAgentTokenApi()..createError = Exception('boom');
      final container = _container(api);

      await _pumpScreen(tester, container);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(AgentAccessScreen.nameFieldKey),
        'Claude Code',
      );
      await tester.tap(find.byKey(AgentAccessScreen.createButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('That did not work. Try again.'), findsOneWidget);
      expect(find.byKey(AgentAccessScreen.tokenDialogKey), findsNothing);
    });
  });
}
