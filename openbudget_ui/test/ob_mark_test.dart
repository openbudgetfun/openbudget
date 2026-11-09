import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The `d` attribute of every path in an SVG file.
Set<String> _svgPathData(String name) {
  final source = File('../brand/$name').readAsStringSync();
  return {
    for (final match in RegExp('<path[^>]* d="([^"]+)"').allMatches(source))
      match.group(1)!,
  };
}

const _boundary = Key('mark');

Future<void> _pumpMark(
  WidgetTester tester,
  ObMark mark, {
  ThemeData? theme,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? OpenBudgetTheme.light,
    home: Center(
      child: RepaintBoundary(key: _boundary, child: mark),
    ),
  ),
);

/// The colour at ([x], [y]) on the mark's 128-unit artboard.
Future<Color> _pixel(WidgetTester tester, double x, double y) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundary),
  );
  final width = boundary.size.width;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data!;
  });
  final px = (x / 128 * width).round();
  final py = (y / 128 * width).round();
  final offset = (py * width.round() + px) * 4;
  return Color.fromARGB(
    bytes!.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}

// Points on the 128-unit artboard.
const _coin = (62.0, 46.0);
const _pocket = (30.0, 75.0);
const _lining = (30.0, 54.0);
const _shadow = (100.0, 118.0);
const _halo = (5.0, 90.0);

void main() {
  group('ObMark path data', () {
    final widgetPaths = obMarkPathData.toSet();

    for (final name in ['mark.svg', 'mark-night.svg', 'mark-mono.svg']) {
      test('is exactly the drawing in brand/$name', () {
        expect(_svgPathData(name), widgetPaths);
      });
    }

    for (final name in ['lockup.svg', 'lockup-night.svg', 'lockup-mono.svg']) {
      test('draws the mark in brand/$name', () {
        expect(_svgPathData(name), containsAll(widgetPaths));
      });
    }
  });

  group('ObMark', () {
    testWidgets('prints the spot inks on paper', (tester) async {
      await _pumpMark(tester, const ObMark(size: 128));
      expect(await _pixel(tester, _coin.$1, _coin.$2), ObSwatch.sunflower);
      expect(await _pixel(tester, _pocket.$1, _pocket.$2), ObSwatch.pink);
      expect(await _pixel(tester, _lining.$1, _lining.$2), ObSwatch.pinkWash);
      expect(await _pixel(tester, _shadow.$1, _shadow.$2), ObSwatch.teal);
      expect((await _pixel(tester, _halo.$1, _halo.$2)).a, 0);
    });

    testWidgets('wears a chalk halo in the dark theme', (tester) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128),
        theme: OpenBudgetTheme.dark,
      );
      expect(await _pixel(tester, _halo.$1, _halo.$2), ObSwatch.chalk);
      expect(await _pixel(tester, _pocket.$1, _pocket.$2), ObSwatch.pink);
    });

    testWidgets('an explicit variant wins over the theme', (tester) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128, variant: ObMarkVariant.night),
      );
      expect(await _pixel(tester, _halo.$1, _halo.$2), ObSwatch.chalk);
    });

    testWidgets('the ink mark is one colour with the lining knocked out', (
      tester,
    ) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128, variant: ObMarkVariant.ink),
      );
      expect((await _pixel(tester, _lining.$1, _lining.$2)).a, 0);
      expect(await _pixel(tester, _coin.$1, _coin.$2), ObSwatch.ink);
      expect(await _pixel(tester, _pocket.$1, _pocket.$2), ObSwatch.ink);
    });

    testWidgets('a tile takes its variant ground', (tester) async {
      for (final (variant, ground) in [
        (ObMarkVariant.paper, ObSwatch.newsprint),
        (ObMarkVariant.night, ObSwatch.night),
        (ObMarkVariant.ink, ObSwatch.newsprint),
      ]) {
        await _pumpMark(
          tester,
          ObMark(size: 128, variant: variant, tile: true),
          theme: OpenBudgetTheme.dark,
        );
        expect(await _pixel(tester, 64, 6), ground, reason: variant.name);
      }
    });

    testWidgets('fills the square it is given', (tester) async {
      await _pumpMark(tester, const ObMark(size: 72));
      expect(tester.getSize(find.byType(ObMark)), const Size.square(72));
    });

    testWidgets('announces its label as an image', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpMark(tester, const ObMark(semanticLabel: 'OpenBudget'));
      expect(
        tester.getSemantics(find.byType(ObMark)),
        matchesSemantics(label: 'OpenBudget', isImage: true),
      );
      handle.dispose();
    });

    testWidgets('stays silent without a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpMark(tester, const ObMark());
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });
  });
}
