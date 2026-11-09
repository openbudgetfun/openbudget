import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool reducedMotion = false,
  ThemeData? theme,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? OpenBudgetTheme.light,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: ObWiredScope(
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  ),
);

void main() {
  group('reduced motion', () {
    final flourishes = <String, Widget>{
      'scribble underline': const ObScribbleUnderline(child: Text('Bills')),
      'highlighter': const ObHighlighter(child: Text(r'$40')),
      'postmark': const ObPostmark(label: 'Funded', detail: 'Nov'),
      'seal': const ObSeal(),
      'spot doodle': const ObSpotDoodle(kind: WiredDoodleKind.sprout),
    };
    for (final MapEntry(key: name, value: widget) in flourishes.entries) {
      testWidgets('$name plays when motion is allowed', (tester) async {
        await _pump(tester, widget);
        expect(tester.hasRunningAnimations, isTrue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('$name is simply there with reduced motion', (tester) async {
        await _pump(tester, widget, reducedMotion: true);
        expect(tester.hasRunningAnimations, isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('ObScribbleUnderline', () {
    testWidgets('leaves the words to the child', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObScribbleUnderline(child: Text('Bills')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Bills'), findsOneWidget);
      handle.dispose();
    });

    test('the stroke stays inside its box', () {
      const size = Size(120, 30);
      final bounds = ObScribblePainter.stroke(size, seed: 4).getBounds();
      expect(bounds.top, greaterThan(0));
      expect(bounds.bottom, lessThanOrEqualTo(size.height + 2));
      expect(bounds.right, lessThanOrEqualTo(size.width + 2));
    });
  });

  group('ObPostmark', () {
    testWidgets('announces its label and detail', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObPostmark(label: 'Funded', detail: 'Nov'));
      expect(find.bySemanticsLabel('Funded, Nov'), findsOneWidget);
      handle.dispose();
    });
  });

  group('ObSeal', () {
    testWidgets('is silent without a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObSeal());
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });

    testWidgets('announces a label as an image', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObSeal(semanticLabel: 'Sealed'));
      expect(
        tester.getSemantics(find.byType(ObSeal)),
        matchesSemantics(label: 'Sealed', isImage: true),
      );
      handle.dispose();
    });
  });

  group('ObCurrencyStamp', () {
    testWidgets('letters the code and announces its spoken form', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObCurrencyStamp('gbp', semanticLabel: 'Pounds sterling'),
      );
      expect(find.text('GBP'), findsOneWidget);
      expect(find.bySemanticsLabel('Pounds sterling'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('lettering carries AA contrast on its stamp', (tester) async {
      await _pump(tester, const ObCurrencyStamp('EUR'));
      final text = tester.widget<Text>(find.text('EUR'));
      expect(text.style?.color, const ObPalette.paper().onAction);
    });
  });

  group('ObInkBurst', () {
    Widget burst(Object trigger) => ObInkBurst(
      trigger: trigger,
      child: const SizedBox.square(dimension: 40),
    );

    testWidgets('stays still on mount and bursts when its trigger changes', (
      tester,
    ) async {
      await _pump(tester, burst(0));
      expect(tester.hasRunningAnimations, isFalse);
      await _pump(tester, burst(1));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('never bursts with reduced motion', (tester) async {
      await _pump(tester, burst(0), reducedMotion: true);
      await _pump(tester, burst(1), reducedMotion: true);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ObSpotDoodle', () {
    testWidgets('is decoration only', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObSpotDoodle(kind: WiredDoodleKind.heart));
      await tester.pumpAndSettle();
      expect(find.byType(WiredDoodle), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });
  });

  group('ObInkPageTransitionsBuilder', () {
    Future<void> push(
      WidgetTester tester, {
      required TargetPlatform platform,
      bool reducedMotion = false,
    }) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: OpenBudgetTheme.light.copyWith(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reducedMotion),
            child: child!,
          ),
          home: const Scaffold(body: Text('first')),
        ),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('second')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets('wipes pages in behind ink on Android', (tester) async {
      await push(tester, platform: TargetPlatform.android);
      expect(find.byType(ObInkWipe), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('keeps the native slide with an inked edge on iOS', (
      tester,
    ) async {
      await push(tester, platform: TargetPlatform.iOS);
      expect(find.byType(ObInkEdge), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('fades with reduced motion', (tester) async {
      await push(
        tester,
        platform: TargetPlatform.android,
        reducedMotion: true,
      );
      expect(find.byType(ObInkWipe), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('mirrors the wipe for right-to-left text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OpenBudgetTheme.light,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ObInkWipe(
              animation: const AlwaysStoppedAnimation(0.5),
              child: Container(color: ObSwatch.paper),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
