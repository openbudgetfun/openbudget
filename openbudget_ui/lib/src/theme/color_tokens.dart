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
/// The pen draws every corner by hand: [sm] for controls and fields, [md] for
/// cards, [lg] for chips, and [xl] for sheets and dialogs.
abstract final class RadiusTokens {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 24;
}

/// Elevation tokens. OpenBudget draws no shadows: surfaces sit on the same
/// paper and the pen outline separates them, so every level is flat.
abstract final class ElevationTokens {
  static const double none = 0;
  static const double low = 0;
  static const double med = 0;
}
