import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolWidgetTest(
    'app icon screen previews each mark colourway and persists the choice',
    ($) async {
      final tester = $.tester;
      final store = InMemoryUiPreferencesStore();
      final container = ProviderContainer(
        overrides: [uiPreferencesStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppIconScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nightMark = tester.widget<ObMark>(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Night'),
          matching: find.byType(ObMark),
        ),
      );
      expect(nightMark.variant, ObMarkVariant.night);
      expect(nightMark.tile, isTrue);

      await tester.tap(find.text('Ink'));
      await tester.pumpAndSettle();

      expect(container.read(appIconStyleProvider), AppIconStyle.ink);
      expect(
        store.readString(UiPreferenceKeys.appIconStyle),
        AppIconStyle.ink.name,
      );
    },
  );
}
