import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';

void main() {
  group('preferences persistence', () {
    test(
      'theme mode hydrates from persisted value and writes updates',
      () async {
        final store = InMemoryUiPreferencesStore();
        await store.writeString(
          key: UiPreferenceKeys.themeMode,
          value: ThemeMode.dark.name,
        );

        final container = ProviderContainer(
          overrides: [uiPreferencesStoreProvider.overrideWithValue(store)],
        );
        addTearDown(container.dispose);

        expect(container.read(themeModeProvider), ThemeMode.dark);

        container
            .read(themeModeProvider.notifier)
            .setThemeMode(ThemeMode.light);
        expect(
          store.readString(UiPreferenceKeys.themeMode),
          ThemeMode.light.name,
        );
      },
    );

    test(
      'app icon style hydrates from persisted value and writes updates',
      () async {
        final store = InMemoryUiPreferencesStore();
        await store.writeString(
          key: UiPreferenceKeys.appIconStyle,
          value: AppIconStyle.v3.name,
        );

        final container = ProviderContainer(
          overrides: [uiPreferencesStoreProvider.overrideWithValue(store)],
        );
        addTearDown(container.dispose);

        expect(container.read(appIconStyleProvider), AppIconStyle.v3);

        container
            .read(appIconStyleProvider.notifier)
            .setAppIconStyle(AppIconStyle.v1);
        expect(
          store.readString(UiPreferenceKeys.appIconStyle),
          AppIconStyle.v1.name,
        );
      },
    );

    test(
      'display option toggles hydrate from persisted values and write updates',
      () async {
        final store = InMemoryUiPreferencesStore();
        await store.writeBool(key: UiPreferenceKeys.hideAmounts, value: true);
        await store.writeBool(
          key: UiPreferenceKeys.hideProgressBars,
          value: true,
        );

        final container = ProviderContainer(
          overrides: [uiPreferencesStoreProvider.overrideWithValue(store)],
        );
        addTearDown(container.dispose);

        expect(container.read(hideAmountsProvider), isTrue);
        expect(container.read(hideProgressBarsProvider), isTrue);

        container
            .read(hideAmountsProvider.notifier)
            .setHideAmounts(value: false);
        container
            .read(hideProgressBarsProvider.notifier)
            .setHideProgressBars(value: false);

        expect(store.readBool(UiPreferenceKeys.hideAmounts), isFalse);
        expect(store.readBool(UiPreferenceKeys.hideProgressBars), isFalse);
      },
    );
  });
}
