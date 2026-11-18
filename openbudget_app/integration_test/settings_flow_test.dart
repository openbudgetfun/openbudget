import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/account_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/currency_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/plan_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;

/// Answers `settings.deleteAccount` and fails any other endpoint call.
class _FakeSettingsServer extends Client {
  _FakeSettingsServer() : super('http://localhost/');

  int deleteAccountCalls = 0;

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (endpoint == 'settings' && method == 'deleteAccount') {
      deleteAccountCalls++;
      return null as T;
    }
    throw StateError('Unexpected endpoint call $endpoint.$method');
  }
}

/// Starts signed in and signs out locally when the account is deleted.
class _SignedInAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const Authenticated(userId: TestData.ownerId);

  @override
  Future<void> forgetDeletedAccount() async {
    state = const Unauthenticated();
  }
}

void main() {
  patrolWidgetTest(
    'navigates settings -> plan settings -> currency -> display options',
    ($) async {
      final tester = $.tester;
      final store = InMemoryUiPreferencesStore();
      final server = _FakeSettingsServer();
      final container = ProviderContainer(
        overrides: [
          entityDetailProvider.overrideWith(
            (ref, id) async => TestData.gbpEntity(name: "Alex's Plan"),
          ),
          userSettingsProvider.overrideWith(
            (ref) async => UserSettings(
              userId: UuidValue.fromString(TestData.ownerId),
              reportingCurrencyCode: 'GBP',
            ),
          ),
          uiPreferencesStoreProvider.overrideWithValue(store),
          serverpodClientProvider.overrideWithValue(server),
          authProvider.overrideWith(_SignedInAuthNotifier.new),
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
            name: settingsRoute,
            path: settingsPath,
            builder: (context, state) =>
                SettingsScreen(entityId: state.pathParameters['entityId']!),
            routes: [
              GoRoute(
                name: planSettingsRoute,
                path: 'plan',
                builder: (context, state) => PlanSettingsScreen(
                  entityId: state.pathParameters['entityId']!,
                ),
                routes: [
                  GoRoute(
                    name: currencySettingsRoute,
                    path: 'currency',
                    builder: (context, state) => CurrencySettingsScreen(
                      entityId: state.pathParameters['entityId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                name: appIconRoute,
                path: 'app-icon',
                builder: (context, state) =>
                    AppIconScreen(entityId: state.pathParameters['entityId']!),
              ),
              GoRoute(
                name: accountSettingsRoute,
                path: 'account-settings',
                builder: (context, state) => AccountSettingsScreen(
                  entityId: state.pathParameters['entityId']!,
                ),
                routes: [
                  GoRoute(
                    name: deleteAccountRoute,
                    path: 'delete',
                    builder: (context, state) => DeleteAccountScreen(
                      entityId: state.pathParameters['entityId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                name: displayOptionsRoute,
                path: 'display',
                builder: (context, state) => DisplayOptionsScreen(
                  entityId: state.pathParameters['entityId']!,
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData.light(useMaterial3: true),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(find.text("Alex's Plan"), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Plan Settings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Plan Settings'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('App Icon'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('App Icon'), findsOneWidget);
      expect(find.text('Display Options'), findsOneWidget);

      await tester.tap(find.text('App Icon'));
      await tester.pumpAndSettle();

      expect(find.text('App Icon'), findsWidgets);
      await tester.tap(find.text('Night'));
      await tester.pumpAndSettle();
      expect(container.read(appIconStyleProvider), AppIconStyle.night);
      expect(
        store.readString(UiPreferenceKeys.appIconStyle),
        AppIconStyle.night.name,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, 500));
      await tester.pumpAndSettle();
      // The row can stop half under the app bar; bring all of it into view.
      await tester.ensureVisible(find.text('Plan Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plan Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Settings'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);

      await tester.tap(find.text('Currency').first);
      await tester.pumpAndSettle();

      expect(find.text('Currency'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Settings'), findsWidgets);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Display Options'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Display Options'));
      await tester.pumpAndSettle();

      expect(find.text('Display Options'), findsWidgets);
      expect(find.text('Done'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Differentiate Without Color'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hide Amounts'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Amounts'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hide Progress Bars'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Progress Bars'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(
        container.read(balanceStyleProvider),
        BalanceStyle.differentiateWithoutColor,
      );
      expect(container.read(hideAmountsProvider), isTrue);
      expect(container.read(hideProgressBarsProvider), isTrue);
      expect(store.readString(UiPreferenceKeys.themeMode), ThemeMode.dark.name);
      expect(
        store.readString(UiPreferenceKeys.balanceStyle),
        BalanceStyle.differentiateWithoutColor.name,
      );
      expect(store.readBool(UiPreferenceKeys.hideAmounts), isTrue);
      expect(store.readBool(UiPreferenceKeys.hideProgressBars), isTrue);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Account Settings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsWidgets);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Delete Account'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Delete Account'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Deleting your account is permanent'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(DeleteAccountScreen.deleteButtonKey),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(DeleteAccountScreen.deleteButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.byKey(DeleteAccountScreen.confirmButtonKey));
      await tester.pumpAndSettle();

      expect(server.deleteAccountCalls, 1);
      expect(container.read(authProvider), isA<Unauthenticated>());
    },
  );
}
