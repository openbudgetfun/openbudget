import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_realtime_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_shell_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/screens/whats_new_sheet.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

const _budgetId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000501',
);

const _notesJson = r'''
{
  "title": "2.4.0",
  "summary": [],
  "sections": [
    {
      "title": "New",
      "collapsed": false,
      "entries": [
        {
          "summary": "See what changed after each update",
          "details_markdown": "OpenBudget now opens its release notes once after an update.\n\n- **Every update.** Read what changed without leaving the app.",
          "change_type": "user_feat"
        }
      ]
    }
  ]
}
''';

class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final contents = files[key];
    if (contents == null) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}

Budget _makeBudget() => Budget(
  name: 'OpenBudget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
);

Widget _buildApp({
  required ProviderContainer container,
  required GoRouter router,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    theme: OpenBudgetTheme.light,
    darkTheme: OpenBudgetTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  ),
);

GoRouter _buildRouter() => GoRouter(
  initialLocation: '/plan',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => BudgetShellScreen(
        navigationShell: navigationShell,
        budgetId: _budgetId,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plan',
              builder: (_, _) => const Scaffold(body: Text('Plan')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              builder: (_, _) => const Scaffold(body: Text('Accounts')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reflect',
              builder: (_, _) => const Scaffold(body: Text('Reflect')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              name: moreRoute,
              path: '/more',
              builder: (_, _) => const Scaffold(body: Text('More')),
              routes: [
                GoRoute(
                  name: settingsRoute,
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(budgetId: _budgetId),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

ProviderContainer _buildContainer({
  required InMemoryUiPreferencesStore store,
  required AssetBundle bundle,
}) {
  final container = ProviderContainer(
    overrides: [
      budgetRealtimeProvider.overrideWith((ref, budgetId) {}),
      budgetDetailProvider.overrideWith((ref, budgetId) async => _makeBudget()),
      uiPreferencesStoreProvider.overrideWithValue(store),
      appVersionProvider.overrideWith((ref) async => '2.4.0'),
      whatsNewAssetBundleProvider.overrideWithValue(bundle),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _openSettings(WidgetTester tester, GoRouter router) async {
  router.goNamed(settingsRoute);
  await tester.pumpAndSettle();
  final whatsNewRow = find.text("What's new");
  await tester.scrollUntilVisible(
    whatsNewRow,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(whatsNewRow);
  await tester.pumpAndSettle();
  await tester.tap(whatsNewRow);
  await tester.pumpAndSettle();
}

void main() {
  patrolWidgetTest(
    'shows notes once after an update and again from settings',
    ($) async {
      final tester = $.tester;
      final store = InMemoryUiPreferencesStore();
      await store.writeString(
        key: WhatsNewPreferenceKeys.lastSeenVersion,
        value: '2.3.0',
      );
      final container = _buildContainer(
        store: store,
        bundle: _FakeAssetBundle({
          'assets/release_notes/2.4.0.json': _notesJson,
        }),
      );
      final router = _buildRouter();

      await tester.pumpWidget(_buildApp(container: container, router: router));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('See what changed after each update'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsNothing);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        '2.4.0',
      );

      await _openSettings(tester, router);

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('See what changed after each update'), findsOneWidget);
    },
  );

  patrolWidgetTest(
    'records a release without notes without opening a sheet',
    ($) async {
      final tester = $.tester;
      final store = InMemoryUiPreferencesStore();
      await store.writeString(
        key: WhatsNewPreferenceKeys.lastSeenVersion,
        value: '2.3.0',
      );
      final container = _buildContainer(
        store: store,
        bundle: _FakeAssetBundle(<String, String>{}),
      );
      final router = _buildRouter();

      await tester.pumpWidget(_buildApp(container: container, router: router));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsNothing);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        '2.4.0',
      );

      await _openSettings(tester, router);

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('Nothing new to read'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    },
  );
}
