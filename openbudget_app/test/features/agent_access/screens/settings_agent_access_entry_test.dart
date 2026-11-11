import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_app/src/features/agent_access/screens/agent_access_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../support/fakes.dart';

const _entityId = 'agent-access-entry-budget';
final _ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000b09');

void main() {
  testWidgets('settings opens agent access from its row', (tester) async {
    final container = ProviderContainer(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => Budget(
            name: 'Family Plan',
            currencyCode: 'USD',
            ownerId: _ownerId,
          ),
        ),
        agentTokenApiProvider.overrideWithValue(FakeAgentTokenApi()),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_entityId/more/settings',
      routes: [
        GoRoute(
          name: agentAccessRoute,
          path: agentAccessPath,
          builder: (context, state) => const AgentAccessScreen(),
        ),
        GoRoute(
          name: settingsRoute,
          path: settingsPath,
          builder: (context, state) =>
              SettingsScreen(entityId: state.pathParameters['entityId']!),
        ),
      ],
    );

    tester.view
      ..physicalSize = const Size(1200, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpApp(
      const SizedBox.shrink(),
      container: container,
      router: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
    await tester.pumpAndSettle();

    expect(find.text('Agent access'), findsOneWidget);
    expect(
      find.text('Connect Claude Code or another MCP client'),
      findsOneWidget,
    );

    await tester.tap(find.text('Agent access'));
    await tester.pumpAndSettle();

    expect(find.byKey(AgentAccessScreen.nameFieldKey), findsOneWidget);
    expect(find.text('No agent tokens yet'), findsOneWidget);
  });
}
