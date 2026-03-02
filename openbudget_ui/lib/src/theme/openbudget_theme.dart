import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';

/// Provides Material 3 light and dark themes for OpenBudget.
abstract final class OpenBudgetTheme {
  /// Light theme.
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Dark theme.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final seededColorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.primary,
      brightness: brightness,
      secondary: ColorTokens.secondary,
      tertiary: ColorTokens.tertiary,
      error: ColorTokens.error,
    );

    final colorScheme = isLight
        ? _lightColorScheme(seededColorScheme)
        : _darkColorScheme(seededColorScheme);

    final baseTextTheme = isLight
        ? GoogleFonts.interTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    // Apply tabular figures for numeric alignment.
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface.withAlpha(isLight ? 245 : 235),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: ElevationTokens.none,
        scrolledUnderElevation: ElevationTokens.low,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: ElevationTokens.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          side: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(isLight ? 170 : 190),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHigh;
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.lg),
          ),
        ),
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainerLow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        space: 0,
        color: colorScheme.outlineVariant.withAlpha(isLight ? 170 : 190),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.md,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
      ),
    );
  }

  static ColorScheme _lightColorScheme(ColorScheme base) => base.copyWith(
    primary: const Color(0xFF4E63FF),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFE2E8FF),
    onPrimaryContainer: const Color(0xFF1A2468),
    secondary: const Color(0xFF1BBE99),
    onSecondary: const Color(0xFF003D32),
    secondaryContainer: const Color(0xFFC1F5E8),
    onSecondaryContainer: const Color(0xFF003227),
    tertiary: const Color(0xFFFFB64C),
    onTertiary: const Color(0xFF4C2A00),
    tertiaryContainer: const Color(0xFFFFE2C1),
    onTertiaryContainer: const Color(0xFF3C2200),
    error: const Color(0xFFC23558),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFD9E3),
    onErrorContainer: const Color(0xFF5D1028),
    surface: ColorTokens.surfaceLight,
    onSurface: const Color(0xFF1A2239),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF8FAFF),
    surfaceContainer: const Color(0xFFF1F4FF),
    surfaceContainerHigh: const Color(0xFFE9EEFF),
    surfaceContainerHighest: const Color(0xFFE1E8FF),
    onSurfaceVariant: const Color(0xFF5A6486),
    outline: const Color(0xFF95A1C8),
    outlineVariant: const Color(0xFFCBD4EF),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF080C1A),
    inverseSurface: const Color(0xFF1B233D),
    onInverseSurface: const Color(0xFFEAF0FF),
    inversePrimary: const Color(0xFFB8C0FF),
  );

  static ColorScheme _darkColorScheme(ColorScheme base) => base.copyWith(
    primary: const Color(0xFF8B98FF),
    onPrimary: const Color(0xFF141C46),
    primaryContainer: const Color(0xFF2A377B),
    onPrimaryContainer: const Color(0xFFDEE4FF),
    secondary: const Color(0xFF57DFBE),
    onSecondary: const Color(0xFF00382E),
    secondaryContainer: const Color(0xFF005143),
    onSecondaryContainer: const Color(0xFFA9F4E1),
    tertiary: const Color(0xFFFFC071),
    onTertiary: const Color(0xFF4A2A00),
    tertiaryContainer: const Color(0xFF694100),
    onTertiaryContainer: const Color(0xFFFFDFB9),
    error: const Color(0xFFFF89A8),
    onError: const Color(0xFF4D1225),
    errorContainer: const Color(0xFF6A2338),
    onErrorContainer: const Color(0xFFFFD9E2),
    surface: ColorTokens.surfaceDark,
    onSurface: const Color(0xFFF1F3FF),
    surfaceContainerLowest: const Color(0xFF0A1021),
    surfaceContainerLow: const Color(0xFF11182C),
    surfaceContainer: const Color(0xFF151D34),
    surfaceContainerHigh: const Color(0xFF1A2340),
    surfaceContainerHighest: const Color(0xFF202A4B),
    onSurfaceVariant: const Color(0xFFA5AFD3),
    outline: const Color(0xFF7280AA),
    outlineVariant: const Color(0xFF2E3A5D),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF030711),
    inverseSurface: const Color(0xFFE7ECFF),
    onInverseSurface: const Color(0xFF131B32),
    inversePrimary: const Color(0xFF4B60FC),
  );
}
