/// Spacing tokens for consistent layout.
abstract final class SpacingTokens {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Border radius tokens for consistent rounding.
///
/// The pen draws every corner by hand: [sm] for tags and tooltips, [md] for
/// buttons and fields, [lg] for cards and heroes, [xl] for sheets and
/// dialogs, and [pill] for chips. The pen clamps a radius to half the
/// shorter side, so [pill] always draws a stadium.
abstract final class RadiusTokens {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 18;
  static const double xl = 26;
  static const double pill = 999;
}

/// Elevation tokens. OpenBudget casts no soft shadows: a raised sticker gets a
/// hard print shadow from its shape (`ObStickerBorder`), so every Material
/// elevation stays flat.
abstract final class ElevationTokens {
  static const double none = 0;
  static const double low = 0;
  static const double med = 0;
}
