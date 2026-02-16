import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  // Riverpod notifiers use methods, not setters, for state mutations.
  // ignore: use_setters_to_change_properties
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
