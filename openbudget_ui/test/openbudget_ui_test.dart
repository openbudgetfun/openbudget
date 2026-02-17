import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('OpenBudgetTheme', () {
    test('light theme uses Material 3', () {
      final theme = OpenBudgetTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('dark theme uses Material 3', () {
      final theme = OpenBudgetTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('ColorTokens', () {
    test('primary is blue', () {
      expect(ColorTokens.primary, const Color(0xFF1565C0));
    });

    test('secondary is green', () {
      expect(ColorTokens.secondary, const Color(0xFF2E7D32));
    });
  });
}
