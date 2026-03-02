import 'package:flutter/material.dart';

/// Brand color tokens for OpenBudget.
abstract final class ColorTokens {
  /// Primary brand color used for key actions and selected states.
  static const Color primary = Color(0xFF4E63FF);

  /// Secondary accent used for progress and supportive highlights.
  static const Color secondary = Color(0xFF28C6A0);

  /// Tertiary accent used for warnings and warm emphasis.
  static const Color tertiary = Color(0xFFFFB64C);

  /// Error color used for destructive and negative states.
  static const Color error = Color(0xFFC23558);

  /// Base surface color for light theme.
  static const Color surfaceLight = Color(0xFFFCFDFF);

  /// Base surface color for dark theme.
  static const Color surfaceDark = Color(0xFF0F1324);

  /// Background color for light theme.
  static const Color backgroundLight = Color(0xFFF5F7FF);

  /// Background color for dark theme.
  static const Color backgroundDark = Color(0xFF090D1A);
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
