import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The heaviest pen a field outline is drawn with (focused and invalid).
const double _heaviestPen = 3;

Future<void> _pumpField(
  WidgetTester tester,
  Widget field, {
  required ThemeData theme,
  double textScale = 1,
}) async {
  // A fresh tree, so the theme is never caught mid-transition.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: ObWiredScope(
        child: Scaffold(
          body: Center(child: SizedBox(width: 320, child: field)),
        ),
      ),
    ),
  );
}

/// Expects the one Skribble glyph to sit inside the field's outline: the
/// rect inside the hand-drawn stroke, wobble and pen width included.
void _expectGlyphInsideOutline(WidgetTester tester, {double glyph = 24}) {
  final field = tester.getRect(find.byType(InputDecorator));
  final inner = field.deflate(
    ObPen.inset(strokeWidth: _heaviestPen) + _heaviestPen,
  );
  final icon = tester.getRect(find.byType(SkribbleIcon));
  // The icon's box is the glyph itself, not a 48pt slot it draws in a
  // corner of.
  expect(icon.size, Size.square(glyph));
  expect(
    icon.left >= inner.left &&
        icon.top >= inner.top &&
        icon.right <= inner.right &&
        icon.bottom <= inner.bottom,
    isTrue,
    reason: "the glyph at $icon leaves the outline's inner rect $inner",
  );
  expect(icon.center.dy, moreOrLessEquals(field.center.dy, epsilon: 1));
}

void main() {
  group('ObFieldIcon', () {
    for (final (name, theme) in [
      ('light', OpenBudgetTheme.light),
      ('dark', OpenBudgetTheme.dark),
    ]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        testWidgets('centres a prefix glyph inside the outline '
            '($name, text x$scale)', (tester) async {
          await _pumpField(
            tester,
            const TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: ObFieldIcon(data: OpenBudgetIcons.email),
              ),
            ),
            theme: theme,
            textScale: scale,
          );
          _expectGlyphInsideOutline(tester);
        });
      }
    }

    testWidgets('keeps an explicit size', (tester) async {
      await _pumpField(
        tester,
        const TextField(
          decoration: InputDecoration(
            hintText: 'Amount',
            prefixIcon: ObFieldIcon(data: OpenBudgetIcons.money, size: 18),
          ),
        ),
        theme: OpenBudgetTheme.light,
      );
      _expectGlyphInsideOutline(tester, glyph: 18);
    });

    testWidgets('a bare Skribble icon lands on the outline', (tester) async {
      // Documents the bug ObFieldIcon exists for, so a fix upstream in
      // skribble shows up here as a failure to clean up.
      await _pumpField(
        tester,
        const TextField(
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: SkribbleIcon(data: OpenBudgetIcons.email),
          ),
        ),
        theme: OpenBudgetTheme.light,
      );
      final icon = tester.getRect(find.byType(SkribbleIcon));
      expect(icon.size, isNot(const Size.square(24)));
    });
  });

  group('ObTextField', () {
    testWidgets('centres any prefix icon inside the outline', (tester) async {
      await _pumpField(
        tester,
        const ObTextField(
          hintText: 'Password',
          prefixIcon: SkribbleIcon(data: OpenBudgetIcons.lock),
        ),
        theme: OpenBudgetTheme.dark,
        textScale: 1.3,
      );
      _expectGlyphInsideOutline(tester);
    });
  });
}
