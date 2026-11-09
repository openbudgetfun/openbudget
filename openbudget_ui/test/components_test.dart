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
  group('ObHeroAmount', () {
    test('splits off two minor digits', () {
      expect(ObHeroAmount.split(r'$1,204.50'), (r'$1,204', '.50'));
      expect(ObHeroAmount.split('1.204,50 €'), ('1.204', ',50 €'));
      expect(ObHeroAmount.split('¥12,000'), ('¥12,000', ''));
      expect(ObHeroAmount.split('BHD 1.250'), ('BHD 1.250', ''));
    });

    testWidgets('letters the figure and announces it whole', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const ObHeroAmount(
          '£840.25',
          semanticsLabel: 'Eight hundred forty pounds',
        ),
      );
      expect(find.bySemanticsLabel('Eight hundred forty pounds'), findsOne);
      expect(find.text('.25'), findsOneWidget);
      handle.dispose();
    });
  });

  group('ObCard', () {
    testWidgets('a raised card is a sticker with a print shadow', (
      tester,
    ) async {
      await _pump(tester, const ObCard(raised: true, child: Text('Ready')));
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape! as ObStickerBorder;
      expect(shape.shadowColor, const ObPalette.paper().printShadow);
    });

    testWidgets('a flat card takes the theme outline', (tester) async {
      await _pump(tester, const ObCard(child: Text('Rent')));
      expect(tester.widget<Card>(find.byType(Card)).shape, isNull);
    });
  });

  group('ObSectionHeader', () {
    testWidgets('sweeps a scribble under its title', (tester) async {
      await _pump(tester, const ObSectionHeader(title: 'Bills'));
      expect(find.byType(ObScribbleUnderline), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('can go without the scribble', (tester) async {
      await _pump(
        tester,
        const ObSectionHeader(title: 'Bills', underline: false),
      );
      expect(find.byType(ObScribbleUnderline), findsNothing);
    });

    testWidgets('the title is a header', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const ObSectionHeader(title: 'Bills'));
      expect(
        tester.getSemantics(find.text('Bills')),
        matchesSemantics(label: 'Bills', isHeader: true),
      );
      handle.dispose();
    });
  });

  group('ObListRow', () {
    testWidgets('is a 56-point target with its badge and figure', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        ObListRow(
          title: 'Corner shop',
          subtitle: 'Groceries',
          leading: const ObIconBadge(
            icon: SkribbleIcon(data: OpenBudgetIcons.envelope),
          ),
          trailing: const ObAmount(r'-$12.40', tone: ObTone.overspent),
          onTap: () => taps++,
        ),
      );
      expect(
        tester.getSize(find.byType(ObListRow)).height,
        greaterThanOrEqualTo(56),
      );
      await tester.tap(find.text('Corner shop'));
      expect(taps, 1);
    });

    test('a badge key always lands on the same spot', () {
      expect(ObIconBadge.spotFor('Rent'), ObIconBadge.spotFor('Rent'));
    });
  });

  group('ObEnvelopeGauge', () {
    testWidgets('bursts when it fills and stays still otherwise', (
      tester,
    ) async {
      await _pump(
        tester,
        const ObEnvelopeGauge(fraction: 0.6, semanticLabel: 'filling'),
      );
      await tester.pumpAndSettle();
      await _pump(
        tester,
        const ObEnvelopeGauge(fraction: 1, semanticLabel: 'filling'),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('ObToneChip', () {
    testWidgets('marks its tone with a dot when it has no icon', (
      tester,
    ) async {
      await _pump(
        tester,
        const ObToneChip(label: 'Funded', tone: ObTone.funded),
      );
      final dot = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ExcludeSemantics),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (dot.decoration! as BoxDecoration).color,
        const ObPalette.paper().funded,
      );
    });
  });
}
