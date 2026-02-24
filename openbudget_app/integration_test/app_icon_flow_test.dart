import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolWidgetTest(
    'app icon screen uses dark icon previews and persists icon selection',
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

      final sproutTile = find.widgetWithText(ListTile, 'Sprout');
      final sproutImage = tester.widget<Image>(
        find.descendant(of: sproutTile, matching: find.byType(Image)).first,
      );
      final sproutAsset = sproutImage.image as AssetImage;
      expect(
        sproutAsset.assetName,
        'assets/branding/logos/ob_v3_dark_preview.png',
      );

      await tester.tap(find.text('Arrow'));
      await tester.pumpAndSettle();

      expect(container.read(appIconStyleProvider), AppIconStyle.v5);
      expect(
        store.readString(UiPreferenceKeys.appIconStyle),
        AppIconStyle.v5.name,
      );
    },
  );
}
