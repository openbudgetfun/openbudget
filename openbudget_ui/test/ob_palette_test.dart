import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// WCAG 2.2 AA for body text.
const double _text = 4.5;

void main() {
  for (final (name, palette) in [
    ('paper', const ObPalette.paper()),
    ('night', const ObPalette.night()),
  ]) {
    group('$name palette', () {
      test('ink and muted ink read on the page and on sheets', () {
        for (final ground in [palette.canvas, palette.surface]) {
          expect(obContrastRatio(palette.ink, ground), greaterThan(7));
          expect(
            obContrastRatio(palette.mutedInk, ground),
            greaterThanOrEqualTo(_text),
          );
        }
      });

      test('the brand text colour reads on sheets and the page', () {
        for (final ground in [palette.canvas, palette.surface]) {
          expect(
            obContrastRatio(palette.brand, ground),
            greaterThanOrEqualTo(_text),
          );
        }
      });

      test('the action label reads on the action fill', () {
        expect(
          obContrastRatio(palette.onAction, palette.action),
          greaterThanOrEqualTo(_text),
        );
      });

      test('text on the highlighter reads', () {
        expect(
          obContrastRatio(palette.onHighlighter, palette.highlighter),
          greaterThanOrEqualTo(_text),
        );
      });

      test('every spot ink carries the action label', () {
        expect(palette.spots, hasLength(6));
        for (final spot in palette.spots) {
          expect(
            obContrastRatio(palette.onAction, spot),
            greaterThanOrEqualTo(_text),
            reason: spot.toString(),
          );
        }
      });

      for (final tone in ObTone.values) {
        test('${tone.name}: hue and ink read on its wash and on sheets', () {
          final wash = palette.wash(tone);
          expect(
            obContrastRatio(palette.hue(tone), wash),
            greaterThanOrEqualTo(_text),
          );
          expect(
            obContrastRatio(palette.ink, wash),
            greaterThanOrEqualTo(_text),
          );
          expect(
            obContrastRatio(palette.hue(tone), palette.surface),
            greaterThanOrEqualTo(_text),
          );
        });
      }
    });
  }

  test('spot picks wrap around the six inks', () {
    const palette = ObPalette.paper();
    expect(palette.spot(0), ObSwatch.pink);
    expect(palette.spot(6), ObSwatch.pink);
    expect(palette.spot(7), ObSwatch.teal);
  });

  test('isNight follows the sheet colour', () {
    expect(const ObPalette.paper().isNight, isFalse);
    expect(const ObPalette.night().isNight, isTrue);
  });

  test('lerp lands on the target at t = 1, spots included', () {
    const paper = ObPalette.paper();
    const night = ObPalette.night();
    final mixed = paper.lerp(night, 1);
    expect(mixed, night);
    expect(paper.lerp(night, 0), paper);
  });

  test('copyWith replaces only what it is given', () {
    const paper = ObPalette.paper();
    final changed = paper.copyWith(action: ObSwatch.teal);
    expect(changed.action, ObSwatch.teal);
    expect(changed.ink, paper.ink);
    expect(changed, isNot(paper));
  });

  test('a bare theme falls back to the palette for its brightness', () {
    expect(ThemeData().ob, const ObPalette.paper());
    expect(
      ThemeData(brightness: Brightness.dark).ob,
      const ObPalette.night(),
    );
  });
}
