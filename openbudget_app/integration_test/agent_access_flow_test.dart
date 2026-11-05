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
import 'package:patrol/patrol.dart';

import 'common/fake_agent_token_api.dart';
import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

final _ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000f07');

void main() {
  patrolWidgetTest(
    'Settings -> Agent access -> create, copy and revoke a token',
    ($) async {
      final tester = $.tester;
      tester.view
        ..physicalSize = const Size(1200, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final api = FakeAgentTokenApi();
      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith(
            (ref, id) async => Budget(
              name: "Alex's Plan",
              currencyCode: 'USD',
              ownerId: _ownerId,
            ),
          ),
          agentTokenApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation:
            '/budgets/${TestData.agentAccessBudgetId}/more/settings',
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
                SettingsScreen(budgetId: state.pathParameters['id']!),
          ),
        ],
      );

      await tester.pumpApp(
        const SizedBox.shrink(),
        container: container,
        router: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pumpAndSettle();

      final page = AgentAccessPage(tester);
      expect(page.settingsRow, findsOneWidget);

      await page.openFromSettings();

      expect(page.title, findsOneWidget);
      expect(page.emptyTitle, findsOneWidget);

      await page.createToken(TestData.agentAccessTokenName);

      expect(page.tokenDialog, findsOneWidget);
      expect(find.text(TestData.agentAccessToken), findsOneWidget);
      expect(api.createCalls, 1);
      expect(api.lastName, TestData.agentAccessTokenName);
      expect(api.lastCanPropose, isTrue);

      await page.copyToken();

      expect(page.tokenDialog, findsNothing);

      await page.revokeFirstToken();

      expect(api.revokeCalls, 1);
      expect(page.revokedChip, findsOneWidget);
    },
  );
}
