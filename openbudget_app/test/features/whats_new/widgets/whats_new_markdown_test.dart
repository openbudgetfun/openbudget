import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/whats_new/widgets/whats_new_markdown.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

void main() {
  group('WhatsNewMarkdown', () {
    testWidgets('renders paragraphs, bullets, and bold text', (tester) async {
      await tester.pumpApp(
        const WhatsNewMarkdown(
          text:
              'First paragraph.\n\n'
              '- **Every update.** Read what changed.\n'
              '- A second item.\n\n'
              'Last paragraph.',
        ),
      );

      expect(
        find.text('First paragraph.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Last paragraph.', findRichText: true), findsOneWidget);
      expect(
        find.textContaining('Every update.', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('A second item.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('•'), findsNWidgets(2));

      final boldSpans = tester
          .widgetList<Text>(find.byType(Text))
          .where((text) => text.textSpan != null)
          .expand((text) => (text.textSpan! as TextSpan).children ?? const [])
          .whereType<TextSpan>()
          .where(
            (span) =>
                span.text == 'Every update.' &&
                span.style?.fontWeight == FontWeight.w700,
          );

      expect(boldSpans, isNotEmpty);
    });

    testWidgets('joins wrapped lines into one paragraph', (tester) async {
      await tester.pumpApp(
        const WhatsNewMarkdown(text: 'One line\ncontinues here.\n\nNext.'),
      );

      expect(
        find.text('One line continues here.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Next.', findRichText: true), findsOneWidget);
    });

    testWidgets('leaves an unmatched bold marker visible', (tester) async {
      await tester.pumpApp(const WhatsNewMarkdown(text: 'Half **bold'));

      expect(find.text('Half **bold', findRichText: true), findsOneWidget);
    });

    testWidgets('renders nothing for empty details', (tester) async {
      await tester.pumpApp(const WhatsNewMarkdown(text: '   '));

      expect(find.byType(Text), findsNothing);
    });
  });
}
