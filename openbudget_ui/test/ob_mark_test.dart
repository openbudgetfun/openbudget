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

void main() {
  group('ObMark path data', () {
    final widgetPaths = obMarkPathData.toSet();
    final hatching = {
      for (final path in obMarkPathData)
        if (RegExp(r'^(M[\d.]+ [\d.]+L[\d.]+ [\d.]+)+$').hasMatch(path)) path,
    };

    for (final name in ['mark.svg', 'mark-night.svg']) {
      test('is exactly the drawing in brand/$name', () {
        expect(_svgPathData(name), widgetPaths);
      });
    }

    for (final name in ['lockup.svg', 'lockup-night.svg']) {
      test('draws the mark in brand/$name', () {
        expect(_svgPathData(name), containsAll(widgetPaths));
      });
    }

    for (final name in ['mark-mono.svg', 'lockup-mono.svg']) {
      test('draws the one-colour mark in brand/$name without hatching', () {
        expect(hatching, hasLength(3));
        expect(
          _svgPathData(name),
          containsAll(widgetPaths.difference(hatching)),
        );
      });
    }
  });

  group('ObMark', () {
    // Inside the left envelope, between its flap and its funded share.
    const paperPoint = (20.0, 70.0);

    testWidgets('draws on paper in the light theme', (tester) async {
      await _pumpMark(tester, const ObMark(size: 128));
      expect(
        await _pixel(tester, paperPoint.$1, paperPoint.$2),
        ObSwatch.paper,
      );
    });

    testWidgets('draws on night paper in the dark theme', (tester) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128),
        theme: OpenBudgetTheme.dark,
      );
      expect(
        await _pixel(tester, paperPoint.$1, paperPoint.$2),
        ObSwatch.night,
      );
    });

    testWidgets('an explicit variant wins over the theme', (tester) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128, variant: ObMarkVariant.night),
      );
      expect(
        await _pixel(tester, paperPoint.$1, paperPoint.$2),
        ObSwatch.night,
      );
    });

    testWidgets('the ink mark knocks the paper out', (tester) async {
      await _pumpMark(
        tester,
        const ObMark(size: 128, variant: ObMarkVariant.ink),
      );
      final paper = await _pixel(tester, paperPoint.$1, paperPoint.$2);
      expect(paper.a, 0);
      // The full middle envelope is solid ink.
      final middle = await _pixel(tester, 64, 80);
      expect(middle.withValues(alpha: 1), ObSwatch.ink);
    });

    testWidgets('the seal is highlighter yellow on every ground', (
      tester,
    ) async {
      for (final variant in [ObMarkVariant.paper, ObMarkVariant.night]) {
        await _pumpMark(tester, ObMark(size: 128, variant: variant));
        expect(await _pixel(tester, 65, 36), ObSwatch.highlighter);
      }
    });

    testWidgets('a tile takes its variant ground', (tester) async {
      for (final (variant, ground) in [
        (ObMarkVariant.paper, ObSwatch.paper),
        (ObMarkVariant.night, ObSwatch.night),
        (ObMarkVariant.ink, ObSwatch.paper),
      ]) {
        await _pumpMark(
          tester,
          ObMark(size: 128, variant: variant, tile: true),
          theme: OpenBudgetTheme.dark,
        );
        expect(await _pixel(tester, 64, 8), ground, reason: variant.name);
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
