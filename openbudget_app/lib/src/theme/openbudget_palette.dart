import 'package:flutter/material.dart';

/// Semantic color roles for OpenBudget surfaces, text, states, and charts.
///
/// These getters intentionally hide hue-based names so the app can map roles
/// differently for light and dark themes without changing call sites.
abstract final class OpenBudgetPalette {
  static const Color _bgPrimaryLight = Color(0xFFF1EEE6);
  static const Color _bgSecondaryLight = Color(0xFFFFFFFF);
  static const Color _bgTertiaryLight = Color(0xFFF6F4EE);
  static const Color _borderSubtleLight = Color(0xFFDCD7CB);
  static const Color _fgSecondaryLight = Color(0xFF6E6A60);
  static const Color _bgBrandLight = Color(0xFF4C5BEE);
  static const Color _bgAccentLight = Color(0xFFC7C5F4);
  static const Color _bgSuccessLight = Color(0xFFA9DF61);
  static const Color _fgSuccessLight = Color(0xFF6FAF2F);
  static const Color _fgErrorLight = Color(0xFFC23043);
  static const Color _bgAuthLight = Color(0xFFF5F4F2);
  static const Color _fgHeroTitleLight = Color(0xFF1B2642);
  static const Color _fgHeroBodyLight = Color(0xFF3A465A);
  static const Color _bgHeroGradientStartLight = Color(0xFF6372F5);
  static const Color _bgHeroGradientEndLight = Color(0xFF4C5BEE);
  static const Color _bgHeroBlobPrimaryLight = Color(0xFF7D87F7);
  static const Color _bgHeroBlobSecondaryLight = Color(0xFF99A1FA);
  static const Color _bgHeroBlobAccentLight = Color(0xFF4ED09B);
  static const Color _fgSuccessStrongLight = Color(0xFF3F7A1C);
  static const Color _bgInfoLight = Color(0xFFE8E3FF);
  static const Color _bgErrorLight = Color(0xFFFDE7E7);
  static const Color _bgBadgeLight = Color(0xFFE8E6FF);
  static const Color _bgSelectedLight = Color(0xFFEFF0FF);
  static const Color _bgWarningLight = Color(0xFFE8C743);
  static const Color _bgTagErrorLight = Color(0xFFF5B2B6);
  static const Color _fgTagErrorLight = Color(0xFF5E1C23);
  static const Color _fgTagWarningLight = Color(0xFF4B3A00);
  static const Color _bgTagSuccessLight = Color(0xFFA6DC57);
  static const Color _fgTagSuccessLight = Color(0xFF234700);
  static const Color _fgIconStrongLight = Color(0xFF23201A);

  static const Color _bgFlagCriticalLight = Color(0xFFF44336);
  static const Color _bgFlagHighLight = Color(0xFFFF9800);
  static const Color _bgFlagMediumLight = Color(0xFFFFC107);
  static const Color _bgFlagPositiveLight = Color(0xFF4CAF50);
  static const Color _bgFlagInfoLight = Color(0xFF2196F3);
  static const Color _bgFlagAccentLight = Color(0xFF9C27B0);

  static const List<Color> _chartSeriesLight = <Color>[
    Color(0xFF5962F1),
    Color(0xFF8FD23A),
    Color(0xFFE9C022),
    Color(0xFFCC606B),
    Color(0xFF6E7CFF),
    Color(0xFFCACAF8),
  ];

  static Color _resolve(
    ThemeData theme, {
    required Color light,
    required Color dark,
  }) {
    if (theme.brightness == Brightness.dark) {
      return dark;
    }
    return light;
  }

  /// Transparent color for overlays and pass-through backgrounds.
  static Color transparentFor(ThemeData theme) => Colors.transparent;

  /// Primary app background for full-screen scaffolds.
  static Color bgPrimaryFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surface;
    }

    return _bgPrimaryLight;
  }

  /// Secondary background for cards, tiles, and elevated content blocks.
  static Color bgSecondaryFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surfaceContainerLow;
    }

    return _bgSecondaryLight;
  }

  /// Tertiary background for muted surfaces and subtle containers.
  static Color bgTertiaryFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.surfaceContainerHigh;
    }

    return _bgTertiaryLight;
  }

  /// Subtle border and divider color.
  static Color borderSubtleFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.outlineVariant;
    }

    return _borderSubtleLight;
  }

  /// Primary foreground for high-emphasis text and icons on normal surfaces.
  static Color fgPrimaryFor(ThemeData theme) => theme.colorScheme.onSurface;

  /// Emphasized foreground used when slightly reduced opacity is preferred.
  static Color fgPrimaryEmphasisFor(ThemeData theme) =>
      fgPrimaryFor(theme).withAlpha(222);

  /// Secondary foreground for muted text and supporting iconography.
  static Color fgSecondaryFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return theme.colorScheme.onSurfaceVariant;
    }

    return _fgSecondaryLight;
  }

  /// Foreground for text/icons shown on brand-filled backgrounds.
  static Color fgOnBrandFor(ThemeData theme) => theme.colorScheme.onPrimary;

  /// Brand background for primary actions and highlighted interactive elements.
  static Color bgBrandFor(ThemeData theme) =>
      _resolve(theme, light: _bgBrandLight, dark: theme.colorScheme.primary);

  /// Accent background for secondary highlighted states.
  static Color bgAccentFor(ThemeData theme) => _resolve(
    theme,
    light: _bgAccentLight,
    dark: theme.colorScheme.secondaryContainer,
  );

  /// Positive background used for success-themed badges and chips.
  static Color bgSuccessFor(ThemeData theme) => _resolve(
    theme,
    light: _bgSuccessLight,
    dark: theme.colorScheme.tertiaryContainer,
  );

  /// Positive foreground used for successful numeric trends and values.
  static Color fgSuccessFor(ThemeData theme) =>
      _resolve(theme, light: _fgSuccessLight, dark: theme.colorScheme.tertiary);

  /// Error foreground used for destructive and negative values.
  static Color fgErrorFor(ThemeData theme) =>
      _resolve(theme, light: _fgErrorLight, dark: theme.colorScheme.error);

  /// Scrim used behind modals and transient overlays.
  static Color overlayScrimFor(ThemeData theme) =>
      theme.colorScheme.scrim.withAlpha(138);

  /// Auth screen background.
  static Color bgAuthFor(ThemeData theme) =>
      _resolve(theme, light: _bgAuthLight, dark: theme.colorScheme.surface);

  /// Hero title foreground for onboarding/marketing headers.
  static Color fgHeroTitleFor(ThemeData theme) => _resolve(
    theme,
    light: _fgHeroTitleLight,
    dark: theme.colorScheme.onSurface,
  );

  /// Hero body foreground for onboarding/marketing supporting text.
  static Color fgHeroBodyFor(ThemeData theme) => _resolve(
    theme,
    light: _fgHeroBodyLight,
    dark: theme.colorScheme.onSurfaceVariant,
  );

  /// Hero gradient start color.
  static Color bgHeroGradientStartFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroGradientStartLight,
    dark: theme.colorScheme.primaryContainer,
  );

  /// Hero gradient end color.
  static Color bgHeroGradientEndFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroGradientEndLight,
    dark: theme.colorScheme.primary,
  );

  /// Primary decorative hero blob color.
  static Color bgHeroBlobPrimaryFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobPrimaryLight,
    dark: theme.colorScheme.primary.withAlpha(220),
  );

  /// Secondary decorative hero blob color.
  static Color bgHeroBlobSecondaryFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobSecondaryLight,
    dark: theme.colorScheme.secondary.withAlpha(200),
  );

  /// Accent decorative hero blob color.
  static Color bgHeroBlobAccentFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobAccentLight,
    dark: theme.colorScheme.tertiary,
  );

  /// Strong positive foreground for emphasized success text.
  static Color fgSuccessStrongFor(ThemeData theme) => _resolve(
    theme,
    light: _fgSuccessStrongLight,
    dark: theme.colorScheme.tertiary,
  );

  /// Informational background for neutral callouts.
  static Color bgInfoFor(ThemeData theme) => _resolve(
    theme,
    light: _bgInfoLight,
    dark: theme.colorScheme.primaryContainer,
  );

  /// Error background for destructive callouts.
  static Color bgErrorFor(ThemeData theme) => _resolve(
    theme,
    light: _bgErrorLight,
    dark: theme.colorScheme.errorContainer,
  );

  /// Badge background for account and entity chips.
  static Color bgBadgeFor(ThemeData theme) => _resolve(
    theme,
    light: _bgBadgeLight,
    dark: theme.colorScheme.primaryContainer,
  );

  /// Background for selected rows and selected container states.
  static Color bgSelectedFor(ThemeData theme) => _resolve(
    theme,
    light: _bgSelectedLight,
    dark: theme.colorScheme.surfaceContainerHigh,
  );

  /// Warning background for cautionary badges and indicators.
  static Color bgWarningFor(ThemeData theme) =>
      _resolve(theme, light: _bgWarningLight, dark: const Color(0xFFF4D35E));

  /// Error tag background color.
  static Color bgTagErrorFor(ThemeData theme) => _resolve(
    theme,
    light: _bgTagErrorLight,
    dark: theme.colorScheme.errorContainer,
  );

  /// Error tag foreground color.
  static Color fgTagErrorFor(ThemeData theme) => _resolve(
    theme,
    light: _fgTagErrorLight,
    dark: theme.colorScheme.onErrorContainer,
  );

  /// Warning tag foreground color.
  static Color fgTagWarningFor(ThemeData theme) => _resolve(
    theme,
    light: _fgTagWarningLight,
    dark: theme.colorScheme.onSecondaryContainer,
  );

  /// Success tag background color.
  static Color bgTagSuccessFor(ThemeData theme) => _resolve(
    theme,
    light: _bgTagSuccessLight,
    dark: theme.colorScheme.tertiaryContainer,
  );

  /// Success tag foreground color.
  static Color fgTagSuccessFor(ThemeData theme) => _resolve(
    theme,
    light: _fgTagSuccessLight,
    dark: theme.colorScheme.onTertiaryContainer,
  );

  /// Strong icon foreground used when muted/icon defaults are too subtle.
  static Color fgIconStrongFor(ThemeData theme) => _resolve(
    theme,
    light: _fgIconStrongLight,
    dark: theme.colorScheme.onSurface,
  );

  /// Flag color for critical/urgent labels.
  static Color bgFlagCriticalFor(ThemeData theme) => _resolve(
    theme,
    light: _bgFlagCriticalLight,
    dark: const Color(0xFFFF8A80),
  );

  /// Flag color for high-priority labels.
  static Color bgFlagHighFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagHighLight, dark: const Color(0xFFFFB74D));

  /// Flag color for medium-priority labels.
  static Color bgFlagMediumFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagMediumLight, dark: const Color(0xFFFFE082));

  /// Flag color for positive/completed labels.
  static Color bgFlagPositiveFor(ThemeData theme) => _resolve(
    theme,
    light: _bgFlagPositiveLight,
    dark: const Color(0xFFA5D6A7),
  );

  /// Flag color for informational labels.
  static Color bgFlagInfoFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagInfoLight, dark: const Color(0xFF90CAF9));

  /// Flag color for accent/custom labels.
  static Color bgFlagAccentFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagAccentLight, dark: const Color(0xFFCE93D8));

  /// Ordered chart series palette for data visualizations.
  static List<Color> chartSeriesFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return <Color>[
        theme.colorScheme.primary,
        theme.colorScheme.tertiary,
        theme.colorScheme.secondary,
        theme.colorScheme.error,
        theme.colorScheme.primaryContainer,
        theme.colorScheme.secondaryContainer,
      ];
    }

    return _chartSeriesLight;
  }
}
