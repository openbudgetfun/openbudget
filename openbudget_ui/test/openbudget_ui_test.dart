import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('OpenBudgetTheme', () {
    testWidgets('light theme uses Material 3', (tester) async {
      final theme = OpenBudgetTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('dark theme uses Material 3', (tester) async {
      final theme = OpenBudgetTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('ColorTokens', () {
    test('primary matches brand token', () {
      expect(ColorTokens.primary, const Color(0xFF4E63FF));
    });

    test('secondary matches brand token', () {
      expect(ColorTokens.secondary, const Color(0xFF28C6A0));
    });
  });
}
