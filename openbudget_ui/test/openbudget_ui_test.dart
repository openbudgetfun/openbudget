import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  group('OpenBudgetTheme', () {
    test('light theme is Material 3 on newsprint', () {
      final theme = OpenBudgetTheme.light;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.ob, const ObPalette.paper());
      expect(theme.scaffoldBackgroundColor, ObSwatch.newsprint);
      expect(theme.cardTheme.color, ObSwatch.paper);
    });

    test('dark theme is Material 3 on the night page', () {
      final theme = OpenBudgetTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.ob, const ObPalette.night());
      expect(theme.scaffoldBackgroundColor, ObSwatch.night);
    });

    test('titles are lettered in Skribble, bodies in the linear face', () {
      final text = OpenBudgetTheme.light.textTheme;
      expect(text.displayMedium?.fontFamily, obDisplayFontFamily);
      expect(text.titleLarge?.fontFamily, obDisplayFontFamily);
      expect(text.bodyMedium?.fontFamily, obTextFontFamily);
      expect(text.labelLarge?.fontFamily, obTextFontFamily);
    });

    test('no text role is set below 12.5 points', () {
      final text = OpenBudgetTheme.light.textTheme;
      for (final style in [
        text.bodySmall,
        text.labelSmall,
        text.labelMedium,
        text.titleSmall,
      ]) {
        expect(style?.fontSize, greaterThanOrEqualTo(12.5));
      }
    });

    test('nothing casts a soft shadow', () {
      final theme = OpenBudgetTheme.light;
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    });

    test('primary buttons are stickers that press into their shadow', () {
      final style = OpenBudgetTheme.light.filledButtonTheme.style!;
      final resting = style.shape!.resolve({})! as ObStickerBorder;
      final pressed =
          style.shape!.resolve({WidgetState.pressed})! as ObStickerBorder;
      expect(resting.lift, 1);
      expect(resting.shadowColor, ObSwatch.ink);
      expect(pressed.lift, 0);
      expect(style.backgroundColor!.resolve({}), ObSwatch.pink);
      expect(style.foregroundColor!.resolve({}), ObSwatch.ink);
      final minimum = style.minimumSize!.resolve({})!;
      expect(minimum.height, greaterThanOrEqualTo(48));
    });

    test('every platform brings pages in behind the ink', () {
      final builders =
          OpenBudgetTheme.light.pageTransitionsTheme.builders.values;
      expect(builders, everyElement(isA<ObInkPageTransitionsBuilder>()));
    });

    test('amounts use tabular figures in the numeral face', () {
      final style = ObTextStyles.amount(const TextStyle(fontSize: 14));
      expect(style.fontFamily, obNumeralFontFamily);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });
}
