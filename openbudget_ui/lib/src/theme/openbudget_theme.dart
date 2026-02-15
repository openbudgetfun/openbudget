import 'package:flutter/material.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';

/// Provides Material 3 light and dark themes for OpenBudget.
abstract final class OpenBudgetTheme {
  /// Light theme.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: ColorTokens.primary,
        scaffoldBackgroundColor: ColorTokens.backgroundLight,
      );

  /// Dark theme.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: ColorTokens.primary,
        scaffoldBackgroundColor: ColorTokens.backgroundDark,
      );
}
