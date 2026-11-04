import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme ?? OpenBudgetTheme.light,
        home: ObWiredScope(
          child: Scaffold(
            body: Center(child: SingleChildScrollView(child: child)),
          ),
        ),
      ),
    );

void main() {
  group('ObAmount', () {
    testWidgets('colours the figure with its tone', (tester) async {
      await _pump(tester, const ObAmount(r'-$12.00', tone: ObTone.overspent));
      final text = tester.widget<Text>(find.text(r'-$12.00'));
      expect(text.style?.color, ObSwatch.overspent);
      expect(text.style?.fontFamily, obNumeralFontFamily);
    });

    testWidgets('a highlighted figure is ink on the highlighter', (
      tester,
    ) async {
      await _pump(
        tester,
        const ObAmount(r'$240.00', tone: ObTone.funded, highlighted: true),
      );
      final text = tester.widget<Text>(find.text(r'$240.00'));
      expect(text.style?.color, ObSwatch.ink);
      expect(find.byType(ObHighlighter), findsOneWidget);
    });

    testWidgets('announces its spoken form', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObAmount(r'-$5', semanticsLabel: 'minus five dollars'),
      );
      expect(find.bySemanticsLabel('minus five dollars'), findsOneWidget);
      handle.dispose();
    });
  });

  group('ObEnvelopeGauge', () {
    for (final (name, fraction, overspent) in [
      ('empty', 0.0, false),
      ('half funded', 0.5, false),
      ('full', 1.0, false),
      ('overspent', 1.4, true),
      ('not a number', double.nan, false),
    ]) {
      testWidgets('paints when $name', (tester) async {
        await _pump(
          tester,
          ObEnvelopeGauge(
            fraction: fraction,
            overspent: overspent,
            semanticLabel: name,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(ObEnvelopeGauge), findsOneWidget);
      });
    }

    testWidgets('says its state in words', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObEnvelopeGauge(fraction: 0.8, semanticLabel: '80% funded'),
      );
      expect(find.bySemanticsLabel('80% funded'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('keeps a 10:7 envelope with headroom for the flap', (
      tester,
    ) async {
      await _pump(
        tester,
        const ObEnvelopeGauge(fraction: 1, semanticLabel: 'full', width: 100),
      );
      final size = tester.getSize(find.byType(ObEnvelopeGauge));
      expect(size.width, 100);
      expect(size.height, closeTo(86, 0.001));
    });

    testWidgets('settles immediately when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OpenBudgetTheme.light,
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: ObEnvelopeGauge(fraction: 0.5, semanticLabel: 'half'),
          ),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('ObStatePanel', () {
    testWidgets('an empty state offers its actions', (tester) async {
      var tapped = 0;
      await _pump(
        tester,
        ObStatePanel.empty(
          title: 'No envelopes yet',
          message: 'Add one to start planning.',
          action: ObStateAction(
            label: 'Add envelope',
            onPressed: () => tapped++,
          ),
          secondaryAction: ObStateAction(
            label: 'Use a template',
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('No envelopes yet'), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
      await tester.tap(find.text('Add envelope'));
      expect(tapped, 1);
      expect(
        find.widgetWithText(OutlinedButton, 'Use a template'),
        findsOneWidget,
      );
    });

    testWidgets('a problem keeps its message selectable', (tester) async {
      await _pump(
        tester,
        const ObStatePanel.problem(
          title: 'Could not load accounts',
          message: 'Connection refused',
        ),
      );
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('the title is a header', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObStatePanel.empty(title: 'Nothing here'));
      expect(
        tester.getSemantics(find.text('Nothing here')),
        matchesSemantics(label: 'Nothing here', isHeader: true),
      );
      handle.dispose();
    });
  });

  group('ObLoadingPanel', () {
    testWidgets('announces its label once', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObLoadingPanel(label: 'Loading budget'));
      expect(find.bySemanticsLabel('Loading budget'), findsOneWidget);
      handle.dispose();
    });
  });

  group('ObToneChip', () {
    testWidgets('sets ink on the tone wash in both modes', (tester) async {
      for (final theme in [OpenBudgetTheme.light, OpenBudgetTheme.dark]) {
        await _pump(
          tester,
          const ObToneChip(label: 'Overspent', tone: ObTone.overspent),
          theme: theme,
        );
        // MaterialApp animates between themes.
        await tester.pumpAndSettle();
        final text = tester.widget<Text>(find.text('Overspent'));
        expect(text.style?.color, theme.ob.ink);
      }
    });
  });

  group('ObFilledButton', () {
    testWidgets('is disabled and shows a loader while loading', (tester) async {
      await _pump(
        tester,
        ObFilledButton(
          onPressed: () {},
          isLoading: true,
          child: const Text('Save'),
        ),
      );
      expect(find.text('Save'), findsNothing);
      expect(find.byType(WiredLoadingIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('ObCard', () {
    testWidgets('takes its tone wash and handles taps', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        ObCard(
          tone: ObTone.funded,
          onTap: () => taps++,
          padding: const EdgeInsets.all(16),
          child: const Text('Groceries'),
        ),
      );
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, ObSwatch.fundedWash);
      await tester.tap(find.text('Groceries'));
      expect(taps, 1);
    });
  });

  group('ObSectionHeader', () {
    testWidgets('shows a trailing action', (tester) async {
      await _pump(
        tester,
        ObSectionHeader(
          title: 'Bills',
          subtitle: '3 envelopes',
          trailing: TextButton(onPressed: () {}, child: const Text('Edit')),
        ),
      );
      expect(find.text('Bills'), findsOneWidget);
      expect(find.text('3 envelopes'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });
  });

  group('icons', () {
    testWidgets('generated icons render through SkribbleIcon', (tester) async {
      await _pump(
        tester,
        const Row(
          children: [
            SkribbleIcon(data: OpenBudgetIcons.envelope),
            SkribbleIcon(data: OpenBudgetIcons.wallet),
            SkribbleIcon(data: OpenBudgetIcons.solana),
          ],
        ),
      );
      expect(find.byType(SkribbleIcon), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });
}
