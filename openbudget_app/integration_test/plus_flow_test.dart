import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:openbudget_app/src/features/plus/screens/plus_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/fake_plus_backend.dart';
import 'common/patrol_helpers.dart';

const _entityId = 'test-budget-id';
final _ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000903');

Budget _makeBudget() => Budget(
  name: "Alex's Plan",
  currencyCode: 'USD',
  ownerId: _ownerId,
);

Entitlement _activePlan() => Entitlement(
  userId: _ownerId,
  source: EntitlementSource.stripe,
  externalId: 'sub_patrol_plus',
  status: EntitlementStatus.active,
  currentPeriodStart: DateTime.utc(2026, 2),
  currentPeriodEnd: DateTime.utc(2026, 3),
);

void main() {
  patrolWidgetTest(
    'opens OpenBudget Plus from settings and shows the active plan',
    ($) async {
      final tester = $.tester;
      tester.view
        ..physicalSize = const Size(1200, 2400)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
          plusPlatformProvider.overrideWithValue(PlusPlatform.web),
          plusBillingApiProvider.overrideWithValue(
            FakePlusBillingBackend(entitlement: _activePlan()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$_entityId/more/settings',
        routes: [
          GoRoute(
            name: moreRoute,
            path: morePath,
            builder: (_, _) => const Scaffold(body: Text('More')),
          ),
          GoRoute(
            name: plusRoute,
            path: plusPath,
            builder: (_, _) => const PlusScreen(),
          ),
          GoRoute(
            name: settingsRoute,
            path: settingsPath,
            builder: (context, state) =>
                SettingsScreen(entityId: state.pathParameters['entityId']!),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) =>
                ObWiredScope(child: child ?? const SizedBox.shrink()),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final plus = PlusPage(tester);
      expect(plus.settingsRow, findsOneWidget);

      await plus.openFromSettings();

      expect(plus.planTitle, findsOneWidget);
      expect(plus.activeChip, findsOneWidget);
      expect(find.text('Paid with Card'), findsOneWidget);
      expect(plus.manageButton, findsOneWidget);
      expect(plus.refreshButton, findsOneWidget);
    },
  );
}
