import 'package:flutter/material.dart';

/// Semantic color roles for OpenBudget surfaces, text, states, and charts.
///
/// These getters intentionally hide hue-based names so the app can map roles
/// differently for light and dark themes without changing call sites.
abstract final class OpenBudgetPalette {
  static const Color _bgPrimaryLight = Color(0xFFF5F7FF);
  static const Color _bgSecondaryLight = Color(0xFFFFFFFF);
  static const Color _bgTertiaryLight = Color(0xFFEFF3FF);
  static const Color _borderSubtleLight = Color(0xFFD6DDF7);
  static const Color _fgSecondaryLight = Color(0xFF5C6586);
  static const Color _bgBrandLight = Color(0xFF4E63FF);
  static const Color _bgAccentLight = Color(0xFFDCE4FF);
  static const Color _bgSuccessLight = Color(0xFFC4F1E3);
  static const Color _fgSuccessLight = Color(0xFF10886B);
  static const Color _fgErrorLight = Color(0xFFC23558);
  static const Color _bgAuthLight = Color(0xFFF3F6FF);
  static const Color _fgHeroTitleLight = Color(0xFF141B3D);
  static const Color _fgHeroBodyLight = Color(0xFF3F4A73);
  static const Color _bgHeroGradientStartLight = Color(0xFF6E7DFF);
  static const Color _bgHeroGradientEndLight = Color(0xFF35C7AE);
  static const Color _bgHeroBlobPrimaryLight = Color(0xFF8A97FF);
  static const Color _bgHeroBlobSecondaryLight = Color(0xFFA4BAFF);
  static const Color _bgHeroBlobAccentLight = Color(0xFF4CD5B6);
  static const Color _fgSuccessStrongLight = Color(0xFF0B6F56);
  static const Color _bgInfoLight = Color(0xFFE5ECFF);
  static const Color _bgErrorLight = Color(0xFFFFE5ED);
  static const Color _bgBadgeLight = Color(0xFFE7ECFF);
  static const Color _bgSelectedLight = Color(0xFFE3E9FF);
  static const Color _bgWarningLight = Color(0xFFFFC86B);
  static const Color _bgTagErrorLight = Color(0xFFFFC2D1);
  static const Color _fgTagErrorLight = Color(0xFF6B1530);
  static const Color _fgTagWarningLight = Color(0xFF5C3A00);
  static const Color _bgTagSuccessLight = Color(0xFFB3EED8);
  static const Color _fgTagSuccessLight = Color(0xFF0A4F3B);
  static const Color _fgIconStrongLight = Color(0xFF1B2240);

  static const Color _bgPrimaryDark = Color(0xFF090D1A);
  static const Color _bgSecondaryDark = Color(0xFF12182C);
  static const Color _bgTertiaryDark = Color(0xFF1A2340);
  static const Color _borderSubtleDark = Color(0xFF2F3A5E);
  static const Color _fgSecondaryDark = Color(0xFFA5AFD3);
  static const Color _bgBrandDark = Color(0xFF8B98FF);
  static const Color _bgAccentDark = Color(0xFF2C3B72);
  static const Color _bgSuccessDark = Color(0xFF1B5345);
  static const Color _fgSuccessDark = Color(0xFF5ADDB5);
  static const Color _fgErrorDark = Color(0xFFFF89A8);
  static const Color _bgAuthDark = Color(0xFF070B18);
  static const Color _fgHeroTitleDark = Color(0xFFF1F3FF);
  static const Color _fgHeroBodyDark = Color(0xFFBDC6E5);
  static const Color _bgHeroGradientStartDark = Color(0xFF4A5DFF);
  static const Color _bgHeroGradientEndDark = Color(0xFF1FB59A);
  static const Color _bgHeroBlobPrimaryDark = Color(0xFF6574FF);
  static const Color _bgHeroBlobSecondaryDark = Color(0xFF425CA8);
  static const Color _bgHeroBlobAccentDark = Color(0xFF2ED7C2);
  static const Color _fgSuccessStrongDark = Color(0xFF88F4D7);
  static const Color _bgInfoDark = Color(0xFF1A2B58);
  static const Color _bgErrorDark = Color(0xFF4A2532);
  static const Color _bgBadgeDark = Color(0xFF24315D);
  static const Color _bgSelectedDark = Color(0xFF2A396A);
  static const Color _bgWarningDark = Color(0xFFFFC066);
  static const Color _bgTagErrorDark = Color(0xFF5B2436);
  static const Color _fgTagErrorDark = Color(0xFFFFC9D5);
  static const Color _fgTagWarningDark = Color(0xFFFFDBA1);
  static const Color _bgTagSuccessDark = Color(0xFF1D5A4B);
  static const Color _fgTagSuccessDark = Color(0xFFA6F6DE);
  static const Color _fgIconStrongDark = Color(0xFFF1F3FF);

  static const Color _bgFlagCriticalLight = Color(0xFFF45B6D);
  static const Color _bgFlagHighLight = Color(0xFFFFA046);
  static const Color _bgFlagMediumLight = Color(0xFFFFC960);
  static const Color _bgFlagPositiveLight = Color(0xFF3DCB8A);
  static const Color _bgFlagInfoLight = Color(0xFF4C87FF);
  static const Color _bgFlagAccentLight = Color(0xFFA16BFF);

  static const Color _bgFlagCriticalDark = Color(0xFFFF7C94);
  static const Color _bgFlagHighDark = Color(0xFFFFB262);
  static const Color _bgFlagMediumDark = Color(0xFFFFD282);
  static const Color _bgFlagPositiveDark = Color(0xFF5BDFB8);
  static const Color _bgFlagInfoDark = Color(0xFF7AB0FF);
  static const Color _bgFlagAccentDark = Color(0xFFC09DFF);

  static const List<Color> _chartSeriesLight = <Color>[
    Color(0xFF4E63FF),
    Color(0xFF28C6A0),
    Color(0xFFFFB64C),
    Color(0xFFF35D89),
    Color(0xFF6AA4FF),
    Color(0xFF8B7DFF),
  ];

  static const List<Color> _chartSeriesDark = <Color>[
    Color(0xFF8B98FF),
    Color(0xFF4CDABD),
    Color(0xFFFFBC72),
    Color(0xFFFF82AA),
    Color(0xFF73B0FF),
    Color(0xFFC3A4FF),
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
  static Color bgPrimaryFor(ThemeData theme) =>
      _resolve(theme, light: _bgPrimaryLight, dark: _bgPrimaryDark);

  /// Secondary background for cards, tiles, and elevated content blocks.
  static Color bgSecondaryFor(ThemeData theme) =>
      _resolve(theme, light: _bgSecondaryLight, dark: _bgSecondaryDark);

  /// Tertiary background for muted surfaces and subtle containers.
  static Color bgTertiaryFor(ThemeData theme) =>
      _resolve(theme, light: _bgTertiaryLight, dark: _bgTertiaryDark);

  /// Subtle border and divider color.
  static Color borderSubtleFor(ThemeData theme) =>
      _resolve(theme, light: _borderSubtleLight, dark: _borderSubtleDark);

  /// Primary foreground for high-emphasis text and icons on normal surfaces.
  static Color fgPrimaryFor(ThemeData theme) => theme.colorScheme.onSurface;

  /// Emphasized foreground used when slightly reduced opacity is preferred.
  static Color fgPrimaryEmphasisFor(ThemeData theme) =>
      fgPrimaryFor(theme).withAlpha(222);

  /// Secondary foreground for muted text and supporting iconography.
  static Color fgSecondaryFor(ThemeData theme) =>
      _resolve(theme, light: _fgSecondaryLight, dark: _fgSecondaryDark);

  /// Foreground for text/icons shown on brand-filled backgrounds.
  static Color fgOnBrandFor(ThemeData theme) => _resolve(
    theme,
    light: const Color(0xFFFFFFFF),
    dark: const Color(0xFF141C46),
  );

  /// Brand background for primary actions and highlighted interactive elements.
  static Color bgBrandFor(ThemeData theme) =>
      _resolve(theme, light: _bgBrandLight, dark: _bgBrandDark);

  /// Accent background for secondary highlighted states.
  static Color bgAccentFor(ThemeData theme) =>
      _resolve(theme, light: _bgAccentLight, dark: _bgAccentDark);

  /// Positive background used for success-themed badges and chips.
  static Color bgSuccessFor(ThemeData theme) =>
      _resolve(theme, light: _bgSuccessLight, dark: _bgSuccessDark);

  /// Positive foreground used for successful numeric trends and values.
  static Color fgSuccessFor(ThemeData theme) =>
      _resolve(theme, light: _fgSuccessLight, dark: _fgSuccessDark);

  /// Error foreground used for destructive and negative values.
  static Color fgErrorFor(ThemeData theme) =>
      _resolve(theme, light: _fgErrorLight, dark: _fgErrorDark);

  /// Scrim used behind modals and transient overlays.
  static Color overlayScrimFor(ThemeData theme) => _resolve(
    theme,
    light: const Color(0x8A080F27),
    dark: const Color(0xB3081027),
  );

  /// Auth screen background.
  static Color bgAuthFor(ThemeData theme) =>
      _resolve(theme, light: _bgAuthLight, dark: _bgAuthDark);

  /// Hero title foreground for onboarding/marketing headers.
  static Color fgHeroTitleFor(ThemeData theme) =>
      _resolve(theme, light: _fgHeroTitleLight, dark: _fgHeroTitleDark);

  /// Hero body foreground for onboarding/marketing supporting text.
  static Color fgHeroBodyFor(ThemeData theme) =>
      _resolve(theme, light: _fgHeroBodyLight, dark: _fgHeroBodyDark);

  /// Hero gradient start color.
  static Color bgHeroGradientStartFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroGradientStartLight,
    dark: _bgHeroGradientStartDark,
  );

  /// Hero gradient end color.
  static Color bgHeroGradientEndFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroGradientEndLight,
    dark: _bgHeroGradientEndDark,
  );

  /// Primary decorative hero blob color.
  static Color bgHeroBlobPrimaryFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobPrimaryLight,
    dark: _bgHeroBlobPrimaryDark,
  );

  /// Secondary decorative hero blob color.
  static Color bgHeroBlobSecondaryFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobSecondaryLight,
    dark: _bgHeroBlobSecondaryDark,
  );

  /// Accent decorative hero blob color.
  static Color bgHeroBlobAccentFor(ThemeData theme) => _resolve(
    theme,
    light: _bgHeroBlobAccentLight,
    dark: _bgHeroBlobAccentDark,
  );

  /// Strong positive foreground for emphasized success text.
  static Color fgSuccessStrongFor(ThemeData theme) =>
      _resolve(theme, light: _fgSuccessStrongLight, dark: _fgSuccessStrongDark);

  /// Informational background for neutral callouts.
  static Color bgInfoFor(ThemeData theme) =>
      _resolve(theme, light: _bgInfoLight, dark: _bgInfoDark);

  /// Error background for destructive callouts.
  static Color bgErrorFor(ThemeData theme) =>
      _resolve(theme, light: _bgErrorLight, dark: _bgErrorDark);

  /// Badge background for account and entity chips.
  static Color bgBadgeFor(ThemeData theme) =>
      _resolve(theme, light: _bgBadgeLight, dark: _bgBadgeDark);

  /// Background for selected rows and selected container states.
  static Color bgSelectedFor(ThemeData theme) =>
      _resolve(theme, light: _bgSelectedLight, dark: _bgSelectedDark);

  /// Warning background for cautionary badges and indicators.
  static Color bgWarningFor(ThemeData theme) =>
      _resolve(theme, light: _bgWarningLight, dark: _bgWarningDark);

  /// Error tag background color.
  static Color bgTagErrorFor(ThemeData theme) =>
      _resolve(theme, light: _bgTagErrorLight, dark: _bgTagErrorDark);

  /// Error tag foreground color.
  static Color fgTagErrorFor(ThemeData theme) =>
      _resolve(theme, light: _fgTagErrorLight, dark: _fgTagErrorDark);

  /// Warning tag foreground color.
  static Color fgTagWarningFor(ThemeData theme) =>
      _resolve(theme, light: _fgTagWarningLight, dark: _fgTagWarningDark);

  /// Success tag background color.
  static Color bgTagSuccessFor(ThemeData theme) =>
      _resolve(theme, light: _bgTagSuccessLight, dark: _bgTagSuccessDark);

  /// Success tag foreground color.
  static Color fgTagSuccessFor(ThemeData theme) =>
      _resolve(theme, light: _fgTagSuccessLight, dark: _fgTagSuccessDark);

  /// Strong icon foreground used when muted/icon defaults are too subtle.
  static Color fgIconStrongFor(ThemeData theme) =>
      _resolve(theme, light: _fgIconStrongLight, dark: _fgIconStrongDark);

  /// Flag color for critical/urgent labels.
  static Color bgFlagCriticalFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagCriticalLight, dark: _bgFlagCriticalDark);

  /// Flag color for high-priority labels.
  static Color bgFlagHighFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagHighLight, dark: _bgFlagHighDark);

  /// Flag color for medium-priority labels.
  static Color bgFlagMediumFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagMediumLight, dark: _bgFlagMediumDark);

  /// Flag color for positive/completed labels.
  static Color bgFlagPositiveFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagPositiveLight, dark: _bgFlagPositiveDark);

  /// Flag color for informational labels.
  static Color bgFlagInfoFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagInfoLight, dark: _bgFlagInfoDark);

  /// Flag color for accent/custom labels.
  static Color bgFlagAccentFor(ThemeData theme) =>
      _resolve(theme, light: _bgFlagAccentLight, dark: _bgFlagAccentDark);

  /// Ordered chart series palette for data visualizations.
  static List<Color> chartSeriesFor(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return _chartSeriesDark;
    }

    return _chartSeriesLight;
  }
}
