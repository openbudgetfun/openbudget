// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/account_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/currency_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/plan_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _budgetId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000311');

Budget _makeBudget({String name = "Alex's Plan", String currencyCode = 'USD'}) {
  return Budget(name: name, currencyCode: currencyCode, ownerId: _ownerUuid);
}

void main() {
  patrolWidgetTest(
    'navigates settings -> plan settings -> currency -> display options',
    ($) async {
      final tester = $.tester;
      final store = InMemoryUiPreferencesStore();
      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
          uiPreferencesStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/$_budgetId/more/settings',
        routes: [
          GoRoute(
            name: moreRoute,
            path: morePath,
            builder: (_, __) => const Scaffold(body: Text('More')),
          ),
          GoRoute(
            name: settingsRoute,
            path: settingsPath,
            builder: (context, state) =>
                SettingsScreen(budgetId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                name: planSettingsRoute,
                path: 'plan',
                builder: (context, state) =>
                    PlanSettingsScreen(budgetId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    name: currencySettingsRoute,
                    path: 'currency',
                    builder: (context, state) => CurrencySettingsScreen(
                      budgetId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                name: appIconRoute,
                path: 'app-icon',
                builder: (context, state) =>
                    AppIconScreen(budgetId: state.pathParameters['id']!),
              ),
              GoRoute(
                name: accountSettingsRoute,
                path: 'account-settings',
                builder: (context, state) => AccountSettingsScreen(
                  budgetId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    name: deleteAccountRoute,
                    path: 'delete',
                    builder: (context, state) => DeleteAccountScreen(
                      budgetId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                name: displayOptionsRoute,
                path: 'display',
                builder: (context, state) =>
                    DisplayOptionsScreen(budgetId: state.pathParameters['id']!),
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
      expect(find.text('Plan Settings'), findsOneWidget);
      expect(find.text('App Icon'), findsOneWidget);
      expect(find.text('Display Options'), findsOneWidget);

      await tester.tap(find.text('App Icon'));
      await tester.pumpAndSettle();

      expect(find.text('App Icon'), findsWidgets);
      await tester.tap(find.text('Arrow'));
      await tester.pumpAndSettle();
      expect(container.read(appIconStyleProvider), AppIconStyle.v5);
      expect(
        store.readString(UiPreferenceKeys.appIconStyle),
        AppIconStyle.v5.name,
      );

      await tester.tap(find.text('Done'));
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

      await tester.tap(find.text('Display Options'));
      await tester.pumpAndSettle();

      expect(find.text('Display Options'), findsWidgets);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Differentiate Without Color'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Hide Amounts'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Amounts'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Hide Progress Bars'));
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

      expect(find.text('Delete Account'), findsWidgets);
      expect(
        find.textContaining(
          'Account deletion is currently unavailable in this build',
        ),
        findsOneWidget,
      );
      final deleteActionButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete Account (Unavailable)'),
      );
      expect(deleteActionButton.onPressed, isNull);

      expect(
        find.text(
          'Delete requests are disabled until backend account deletion is available.',
        ),
        findsOneWidget,
      );
    },
  );
}
