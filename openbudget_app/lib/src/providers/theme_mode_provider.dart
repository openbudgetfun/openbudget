import 'package:flutter/material.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final rawValue = ref
        .watch(uiPreferencesStoreProvider)
        .readString(UiPreferenceKeys.themeMode);
    return enumFromName(ThemeMode.values, rawValue, ThemeMode.system);
  }

  // Riverpod notifiers use methods, not setters, for state mutations.
  // ignore: use_setters_to_change_properties
  void setThemeMode(ThemeMode mode) {
    state = mode;
    persistString(ref, key: UiPreferenceKeys.themeMode, value: mode.name);
  }
}
