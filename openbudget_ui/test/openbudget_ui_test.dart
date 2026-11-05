import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  group('OpenBudgetTheme', () {
    test('light theme is Material 3 on paper', () {
      final theme = OpenBudgetTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.ob, const ObPalette.paper());
      expect(theme.scaffoldBackgroundColor, ObSwatch.paper);
    });

    test('dark theme is Material 3 on night paper', () {
      final theme = OpenBudgetTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.ob, const ObPalette.night());
      expect(theme.scaffoldBackgroundColor, ObSwatch.night);
    });

    test('bodies and labels use the readable linear face', () {
      final text = OpenBudgetTheme.light.textTheme;
      expect(text.bodyMedium?.fontFamily, obTextFontFamily);
      expect(text.labelLarge?.fontFamily, obTextFontFamily);
    });

    test('nothing casts a shadow', () {
      final theme = OpenBudgetTheme.light;
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    });

    test('amounts use tabular figures in the numeral face', () {
      final style = ObTextStyles.amount(const TextStyle(fontSize: 14));
      expect(style.fontFamily, obNumeralFontFamily);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  group('ObPalette contrast', () {
    for (final (name, palette) in [
      ('paper', const ObPalette.paper()),
      ('night', const ObPalette.night()),
    ]) {
      test('$name ink and muted ink read at AA on the surface', () {
        expect(obContrastRatio(palette.ink, palette.surface), greaterThan(7));
        expect(
          obContrastRatio(palette.mutedInk, palette.surface),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name action label reads at AA on the action fill', () {
        expect(
          obContrastRatio(palette.onAction, palette.action),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$name ink reads at AA on the highlighter', () {
        expect(
          obContrastRatio(palette.ink, palette.highlighter),
          greaterThanOrEqualTo(4.5),
        );
      });

      for (final tone in ObTone.values) {
        test('$name ${tone.name} hue and ink read at AA on its wash', () {
          final wash = palette.wash(tone);
          expect(
            obContrastRatio(palette.hue(tone), wash),
            greaterThanOrEqualTo(4.5),
          );
          expect(obContrastRatio(palette.ink, wash), greaterThanOrEqualTo(4.5));
          expect(
            obContrastRatio(palette.hue(tone), palette.surface),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }

    test('lerp lands on the target at t = 1', () {
      const paper = ObPalette.paper();
      const night = ObPalette.night();
      final mixed = paper.lerp(night, 1);
      for (final (actual, expected) in [
        (mixed.ink, night.ink),
        (mixed.surface, night.surface),
        (mixed.highlighter, night.highlighter),
        (mixed.overspent, night.overspent),
      ]) {
        expect(actual.toARGB32(), expected.toARGB32());
      }
    });

    test('a bare theme falls back to the palette for its brightness', () {
      expect(ThemeData().ob, const ObPalette.paper());
      expect(
        ThemeData(brightness: Brightness.dark).ob,
        const ObPalette.night(),
      );
    });
  });
}
