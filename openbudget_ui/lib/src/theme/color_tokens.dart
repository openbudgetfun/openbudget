import 'package:flutter/material.dart';

/// Brand color tokens for OpenBudget.
abstract final class ColorTokens {
  /// Primary brand color — a financial-trust blue.
  static const Color primary = Color(0xFF1565C0);

  /// Secondary accent — a growth green.
  static const Color secondary = Color(0xFF2E7D32);

  /// Tertiary accent — a warm amber for warnings and highlights.
  static const Color tertiary = Color(0xFFF9A825);

  /// Error color.
  static const Color error = Color(0xFFB71C1C);

  /// Surface color for light theme.
  static const Color surfaceLight = Color(0xFFFAFAFA);

  /// Surface color for dark theme.
  static const Color surfaceDark = Color(0xFF121212);

  /// Background color for light theme.
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Background color for dark theme.
  static const Color backgroundDark = Color(0xFF1E1E1E);
}

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
abstract final class RadiusTokens {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Elevation tokens for consistent depth.
abstract final class ElevationTokens {
  static const double none = 0;
  static const double low = 1;
  static const double med = 4;
}
