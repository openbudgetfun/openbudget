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
