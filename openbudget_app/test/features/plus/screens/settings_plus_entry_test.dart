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
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../support/fakes.dart';

const _budgetId = 'plus-entry-budget';
final _ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000902');

void main() {
  testWidgets('settings opens OpenBudget Plus from the top row', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, id) async => Budget(
            name: 'Family Plan',
            currencyCode: 'USD',
            ownerId: _ownerId,
          ),
        ),
        plusPlatformProvider.overrideWithValue(PlusPlatform.web),
        plusBillingApiProvider.overrideWithValue(FakePlusBillingApi()),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/budgets/$_budgetId/more/settings',
      routes: [
        GoRoute(
          name: plusRoute,
          path: plusPath,
          builder: (context, state) => const PlusScreen(),
        ),
        GoRoute(
          name: settingsRoute,
          path: settingsPath,
          builder: (context, state) =>
              SettingsScreen(budgetId: state.pathParameters['id']!),
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

    expect(find.text('OpenBudget Plus'), findsOneWidget);
    expect(
      find.text('Tax reports, the assistant and more'),
      findsOneWidget,
    );

    await tester.tap(find.text('OpenBudget Plus'));
    await tester.pumpAndSettle();

    expect(find.text('Get more from every envelope'), findsOneWidget);
    expect(find.text('Pay with card'), findsOneWidget);
  });
}
