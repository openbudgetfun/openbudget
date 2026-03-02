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

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    );
    final textTheme = _buildTextTheme(baseTextTheme, colorScheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface.withAlpha(isLight ? 244 : 232),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.primary.withAlpha(isLight ? 20 : 36),
        elevation: ElevationTokens.none,
        scrolledUnderElevation: ElevationTokens.med,
        shadowColor: colorScheme.shadow.withAlpha(isLight ? 28 : 84),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: isLight ? ElevationTokens.low : ElevationTokens.none,
        shadowColor: colorScheme.shadow.withAlpha(isLight ? 24 : 90),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withAlpha(isLight ? 170 : 205),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withAlpha(186),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          elevation: ElevationTokens.none,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(10),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
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
        height: 74,
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        shadowColor: colorScheme.shadow.withAlpha(isLight ? 12 : 48),
        elevation: isLight ? ElevationTokens.low : ElevationTokens.none,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xl),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.xl),
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
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.7,
        space: 0,
        color: colorScheme.outlineVariant.withAlpha(isLight ? 170 : 205),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: 14,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: ElevationTokens.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, ColorScheme colorScheme) {
    TextStyle applyTabular(TextStyle? style) {
      final value = style ?? const TextStyle();
      return value.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    }

    return base
        .copyWith(
          displayLarge: applyTabular(base.displayLarge).copyWith(
            fontSize: 44,
            height: 52 / 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
          displayMedium: applyTabular(base.displayMedium).copyWith(
            fontSize: 36,
            height: 44 / 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          displaySmall: applyTabular(base.displaySmall).copyWith(
            fontSize: 30,
            height: 38 / 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          headlineLarge: applyTabular(base.headlineLarge).copyWith(
            fontSize: 26,
            height: 34 / 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          headlineMedium: applyTabular(base.headlineMedium).copyWith(
            fontSize: 22,
            height: 30 / 22,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: applyTabular(base.headlineSmall).copyWith(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: applyTabular(base.titleLarge).copyWith(
            fontSize: 21,
            height: 28 / 21,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: applyTabular(base.titleMedium).copyWith(
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: applyTabular(base.titleSmall).copyWith(
            fontSize: 16,
            height: 22 / 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: applyTabular(base.bodyLarge).copyWith(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: applyTabular(base.bodyMedium).copyWith(
            fontSize: 15,
            height: 22 / 15,
            fontWeight: FontWeight.w500,
          ),
          bodySmall: applyTabular(base.bodySmall).copyWith(
            fontSize: 13,
            height: 19 / 13,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: applyTabular(base.labelLarge).copyWith(
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          labelMedium: applyTabular(base.labelMedium).copyWith(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          labelSmall: applyTabular(base.labelSmall).copyWith(
            fontSize: 11,
            height: 16 / 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        )
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );
  }

  static ColorScheme _lightColorScheme(ColorScheme base) => base.copyWith(
    primary: const Color(0xFF3D63FF),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFDDE5FF),
    onPrimaryContainer: const Color(0xFF182868),
    secondary: const Color(0xFF00B89C),
    onSecondary: const Color(0xFF003D33),
    secondaryContainer: const Color(0xFFBDF3E7),
    onSecondaryContainer: const Color(0xFF003128),
    tertiary: const Color(0xFFFFA347),
    onTertiary: const Color(0xFF4A2800),
    tertiaryContainer: const Color(0xFFFFE0BD),
    onTertiaryContainer: const Color(0xFF3B2100),
    error: const Color(0xFFC93A60),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFD9E3),
    onErrorContainer: const Color(0xFF62162F),
    surface: ColorTokens.surfaceLight,
    onSurface: const Color(0xFF151B34),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7FAFF),
    surfaceContainer: const Color(0xFFF1F5FF),
    surfaceContainerHigh: const Color(0xFFEAF0FF),
    surfaceContainerHighest: const Color(0xFFE2EAFF),
    onSurfaceVariant: const Color(0xFF556089),
    outline: const Color(0xFF8896C3),
    outlineVariant: const Color(0xFFC9D3F2),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF090E1E),
    inverseSurface: const Color(0xFF1A2343),
    onInverseSurface: const Color(0xFFEAF0FF),
    inversePrimary: const Color(0xFFBAC6FF),
  );

  static ColorScheme _darkColorScheme(ColorScheme base) => base.copyWith(
    primary: const Color(0xFFA5B6FF),
    onPrimary: const Color(0xFF101939),
    primaryContainer: const Color(0xFF2B3D86),
    onPrimaryContainer: const Color(0xFFE2E8FF),
    secondary: const Color(0xFF41E0C3),
    onSecondary: const Color(0xFF00392F),
    secondaryContainer: const Color(0xFF005447),
    onSecondaryContainer: const Color(0xFFA6F6E6),
    tertiary: const Color(0xFFFFC47A),
    onTertiary: const Color(0xFF4A2A00),
    tertiaryContainer: const Color(0xFF6D4200),
    onTertiaryContainer: const Color(0xFFFFE0BD),
    error: const Color(0xFFFF8FAF),
    onError: const Color(0xFF4D1327),
    errorContainer: const Color(0xFF70263E),
    onErrorContainer: const Color(0xFFFFD8E3),
    surface: ColorTokens.surfaceDark,
    onSurface: const Color(0xFFEAF0FF),
    surfaceContainerLowest: const Color(0xFF040918),
    surfaceContainerLow: const Color(0xFF0E1732),
    surfaceContainer: const Color(0xFF131E3D),
    surfaceContainerHigh: const Color(0xFF19274C),
    surfaceContainerHighest: const Color(0xFF22345E),
    onSurfaceVariant: const Color(0xFF9FAED9),
    outline: const Color(0xFF6D7EAF),
    outlineVariant: const Color(0xFF2E416C),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF020614),
    inverseSurface: const Color(0xFFE9EEFF),
    onInverseSurface: const Color(0xFF111C3A),
    inversePrimary: const Color(0xFF3659EF),
  );
}
