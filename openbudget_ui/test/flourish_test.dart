import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_core/openbudget_core.dart' show ChainFamily;
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

  group('ObChainStamp', () {
    const named = <ChainFamily, Color>{
      ChainFamily.bitcoin: ObSwatch.tangerine,
      ChainFamily.evm: ObSwatch.lilac,
      ChainFamily.solana: ObSwatch.teal,
      ChainFamily.tron: ObSwatch.pink,
      ChainFamily.xrpl: ObSwatch.sky,
    };

    RenderObject stampPaint(WidgetTester tester) => tester.renderObject(
      find
          .descendant(
            of: find.byType(ObChainStamp),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

    for (final family in ChainFamily.values) {
      testWidgets('${family.name}: letters its name in its fixed ink', (
        tester,
      ) async {
        await _pump(tester, ObChainStamp(family: family, label: family.name));
        final palette = Theme.of(tester.element(find.byType(ObChainStamp))).ob;
        final ink = ObChainStamp.inkOf(family, palette);
        expect(find.text(family.name.toUpperCase()), findsOneWidget);
        expect(stampPaint(tester), paints..path(color: ink));
        final word = tester.widget<Text>(find.text(family.name.toUpperCase()));
        expect(word.style?.color, palette.onAction);
      });

      testWidgets('${family.name}: an outline stamp is bare paper', (
        tester,
      ) async {
        await _pump(
          tester,
          ObChainStamp(family: family, label: family.name, inked: false),
        );
        final palette = Theme.of(tester.element(find.byType(ObChainStamp))).ob;
        expect(stampPaint(tester), paints..path(color: palette.surface));
        final word = tester.widget<Text>(find.text(family.name.toUpperCase()));
        expect(word.style?.color, palette.ink);
      });
    }

    test('the five launch families print in their named inks', () {
      const palette = ObPalette.paper();
      for (final MapEntry(key: family, value: ink) in named.entries) {
        expect(ObChainStamp.inkOf(family, palette), ink, reason: family.name);
      }
    });

    test('each family has one ink, so two that sit together stay apart', () {
      const palette = ObPalette.paper();
      expect(
        ObChainStamp.inkOf(ChainFamily.sui, palette),
        isNot(ObChainStamp.inkOf(ChainFamily.aptos, palette)),
      );
      expect(
        ObChainStamp.inkOf(ChainFamily.dogecoin, palette),
        isNot(ObChainStamp.inkOf(ChainFamily.bitcoin, palette)),
      );
    });

    testWidgets('prints in the night inks in the dark print run', (
      tester,
    ) async {
      await _pump(
        tester,
        const ObChainStamp(family: ChainFamily.solana, label: 'Solana'),
        theme: OpenBudgetTheme.dark,
      );
      expect(stampPaint(tester), paints..path(color: ObSwatch.nightTeal));
    });

    testWidgets('announces the chain, its detail and its state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObChainStamp(
          family: ChainFamily.evm,
          label: 'Ethereum',
          detail: '+ 6',
          value: r'$12.40',
        ),
      );
      expect(
        find.bySemanticsLabel(r'Ethereum, + 6, $12.40, inked'),
        findsOneWidget,
      );
      await _pump(
        tester,
        const ObChainStamp(
          family: ChainFamily.bitcoin,
          label: 'Bitcoin',
          detail: 'zpub',
          inked: false,
        ),
      );
      expect(find.bySemanticsLabel('Bitcoin, zpub, outline'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('takes its state words from the app', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObChainStamp(
          family: ChainFamily.tron,
          label: 'Tron',
          inked: false,
          words: ObChainStampWords(outline: 'vide'),
        ),
      );
      expect(find.bySemanticsLabel('Tron, vide'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('sets the value line in tabular figures', (tester) async {
      await _pump(
        tester,
        const ObChainStamp(
          family: ChainFamily.evm,
          label: 'Base',
          value: '0.5 ETH',
        ),
      );
      final figure = tester.widget<Text>(find.text('0.5 ETH'));
      expect(figure.style?.fontFeatures, contains(isA<FontFeature>()));
      expect(figure.style?.fontFeatures?.first.feature, 'tnum');
    });

    for (final (name, palette) in [
      ('paper', const ObPalette.paper()),
      ('night', const ObPalette.night()),
    ]) {
      test('every family reads in the $name print run', () {
        // Words on the filled stamp and on the bare one, and the pencil edge
        // that outlines a bare stamp against its sheet.
        final edge = Color.alphaBlend(palette.quietPen, palette.surface);
        expect(obContrastRatio(edge, palette.surface), greaterThanOrEqualTo(3));
        expect(
          obContrastRatio(palette.ink, palette.surface),
          greaterThanOrEqualTo(4.5),
        );
        for (final family in ChainFamily.values) {
          expect(
            obContrastRatio(
              palette.onAction,
              ObChainStamp.inkOf(family, palette),
            ),
            greaterThanOrEqualTo(4.5),
            reason: family.name,
          );
        }
      });
    }
  });

  group('ObChainStampToggle', () {
    Widget toggle({
      required bool selected,
      ValueChanged<bool>? onChanged,
      String? detail,
    }) => ObChainStampToggle(
      family: ChainFamily.evm,
      label: 'Base',
      detail: detail,
      selected: selected,
      onChanged: onChanged,
    );

    testWidgets('toggles on tap', (tester) async {
      final taps = <bool>[];
      await _pump(tester, toggle(selected: false, onChanged: taps.add));
      await tester.tap(find.byType(ObChainStampToggle));
      await _pump(tester, toggle(selected: true, onChanged: taps.add));
      await tester.tap(find.byType(ObChainStampToggle));
      expect(taps, [true, false]);
    });

    testWidgets('is inked while selected and an outline while not', (
      tester,
    ) async {
      await _pump(tester, toggle(selected: true, onChanged: (_) {}));
      final palette = Theme.of(tester.element(find.byType(ObChainStampToggle)));
      RenderObject paint() => tester.renderObject(
        find
            .descendant(
              of: find.byType(ObChainStampToggle),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(paint(), paints..path(color: ObSwatch.lilac));
      await _pump(tester, toggle(selected: false, onChanged: (_) {}));
      expect(paint(), paints..path(color: palette.ob.surface));
    });

    testWidgets('announces the chain and whether it is selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        toggle(selected: true, detail: '0.5 ETH', onChanged: (_) {}),
      );
      expect(
        tester.getSemantics(find.byType(ObChainStampToggle)),
        matchesSemantics(
          label: 'Base, 0.5 ETH',
          value: 'selected',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await _pump(tester, toggle(selected: false, onChanged: (_) {}));
      expect(
        tester.getSemantics(find.byType(ObChainStampToggle)),
        matchesSemantics(
          label: 'Base',
          value: 'not selected',
          isButton: true,
          hasSelectedState: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('is a 48 point touch target even as a one-line stamp', (
      tester,
    ) async {
      await _pump(tester, toggle(selected: false, onChanged: (_) {}));
      final size = tester.getSize(find.byType(ObChainStampToggle));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('does nothing when disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, toggle(selected: false));
      await tester.tap(find.byType(ObChainStampToggle));
      expect(
        tester.getSemantics(find.byType(ObChainStampToggle)),
        matchesSemantics(
          label: 'Base',
          value: 'not selected',
          isButton: true,
          hasSelectedState: true,
          hasEnabledState: true,
        ),
      );
      handle.dispose();
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
