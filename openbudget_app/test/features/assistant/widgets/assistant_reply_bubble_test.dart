import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_source.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_message_bubble.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_source_number.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_sources_sheet.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../tax/tax_test_data.dart';
import '../support/fake_assistant_api.dart';

const _reply =
    'The annual exempt amount is £3,000[^gb-cgt-aea]. Disposals are matched '
    'first with tokens bought the same day[^gb-cgt-crypto-matching], then the '
    'next 30 days. The exempt amount applies once a year[^gb-cgt-aea].';

final List<AgentCitation> _citations = [
  testCitation('gb-cgt-aea'),
  testCitation(
    'gb-cgt-crypto-matching',
    title: 'Cryptoassets Manual: pooling',
    url: 'https://www.koinly.io/guides/hmrc-pooling',
    authority: 'koinly.io',
    grade: 'secondary',
  ),
  testCitation(
    'gb-cgt-crypto-matching',
    title: 'Draft rules for reporting cryptoasset disposals',
    url: 'https://www.gov.uk/government/consultations/crypto-reporting',
    grade: 'inferred',
    announced: true,
    verifiedOn: DateTime.utc(2026, 10, 15),
  ),
];

const _phone = Size(390, 844);

Future<FakeTaxUrlLauncher> _pumpReply(
  WidgetTester tester, {
  String text = _reply,
  List<AgentCitation>? citations,
  bool touchesTaxOrInvestment = true,
  TaxJurisdiction? jurisdiction,
  ThemeData? theme,
  double textScale = 1,
  Size size = _phone,
  Widget? reference,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final launcher = FakeTaxUrlLauncher();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [taxUrlLauncherProvider.overrideWithValue(launcher)],
      child: MaterialApp(
        theme: theme ?? OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AssistantReplyBubble(
                text: text,
                sources: [
                  for (final citation in citations ?? _citations)
                    assistantSourceFrom(citation),
                ],
                touchesTaxOrInvestment: touchesTaxOrInvestment,
                jurisdiction: jurisdiction,
              ),
              ?reference,
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return launcher;
}

Finder get _replyText => find
    .descendant(
      of: find.byType(AssistantReplyBubble),
      matching: find.byType(RichText),
    )
    .first;

/// The citation marks in the reply, in reading order.
List<TextSpan> _marks(WidgetTester tester) {
  final marks = <TextSpan>[];
  tester.widget<RichText>(_replyText).text.visitChildren((span) {
    if (span is TextSpan && span.recognizer != null) marks.add(span);
    return true;
  });
  return marks;
}

/// Where the first mark for [number] is drawn, in global coordinates.
Rect _markRect(WidgetTester tester, int number) {
  final paragraph = tester.renderObject<RenderParagraph>(_replyText);
  final mark = assistantCitationMark('$number');
  final start = paragraph.text
      .toPlainText(includeSemanticsLabels: false)
      .indexOf(mark);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + mark.length),
      )
      .single
      .toRect();
  return box.shift(paragraph.localToGlobal(Offset.zero));
}

Future<void> _tapMark(WidgetTester tester, int number) async {
  await tester.tapAt(_markRect(tester, number).center);
  await tester.pumpAndSettle();
}

Finder get _sheet => find.byKey(AssistantSourcesSheet.sheetKey);

void main() {
  group('citation chips', () {
    testWidgets('number in order of first appearance and reuse numbers', (
      tester,
    ) async {
      await _pumpReply(tester);

      final numbers = _marks(tester).map((mark) => mark.text!.trim());
      expect(numbers, ['1', '2', '1']);
      expect(find.textContaining('[^'), findsNothing);
    });

    testWidgets('say which source they stand for', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpReply(tester);

      final labelled = <SemanticsData>[];
      void collect(SemanticsNode node) {
        if (node.label.startsWith('Source ')) {
          labelled.add(node.getSemanticsData());
        }
        node.visitChildren((child) {
          collect(child);
          return true;
        });
      }

      collect(tester.getSemantics(find.byType(AssistantReplyBubble)));

      expect(labelled.map((data) => data.label), [
        'Source 1: Capital gains tax: allowances',
        'Source 2: Cryptoassets Manual: pooling',
        'Source 1: Capital gains tax: allowances',
      ]);
      expect(
        labelled.every((data) => data.hasAction(SemanticsAction.tap)),
        isTrue,
      );
      semantics.dispose();
    });

    testWidgets('open the sources sheet at the tapped source', (tester) async {
      await _pumpReply(tester);

      await _tapMark(tester, 2);

      expect(_sheet, findsOneWidget);
      final highlighted = tester
          .widgetList<AssistantSourceNumber>(
            find.descendant(
              of: _sheet,
              matching: find.byType(AssistantSourceNumber),
            ),
          )
          .where((number) => number.highlighted)
          .map((number) => number.number);
      // Key 2 has two sources, and both are marked.
      expect(highlighted, [2, 2]);
    });

    testWidgets('open from a tap beside the chip within a 44-point target', (
      tester,
    ) async {
      await _pumpReply(tester);

      final mark = _markRect(tester, 1);
      expect(mark.height, lessThan(44));

      await tester.tapAt(mark.center.translate(0, -20));
      await tester.pumpAndSettle();
      expect(_sheet, findsOneWidget);
    });

    testWidgets('a tap far from every chip opens nothing', (tester) async {
      await _pumpReply(tester);

      final bubble = tester.getRect(find.byType(AssistantReplyBubble));
      await tester.tapAt(bubble.topLeft.translate(14, 14));
      await tester.pumpAndSettle();

      expect(_sheet, findsNothing);
    });

    for (final textScale in [1.0, 2.0]) {
      testWidgets('keep the line height at ${textScale}x text', (
        tester,
      ) async {
        const referenceKey = Key('reference');
        await _pumpReply(
          tester,
          text: 'Cited[^gb-cgt-aea]',
          textScale: textScale,
          reference: Builder(
            builder: (context) => Text(
              'Cited',
              key: referenceKey,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        );

        final cited = tester.getSize(_replyText);
        final plain = tester.getSize(find.byKey(referenceKey));
        expect(cited.height, plain.height);
      });
    }
  });

  group('sources button', () {
    testWidgets('counts every listed source and opens the sheet', (
      tester,
    ) async {
      await _pumpReply(tester);

      expect(find.text('3 sources'), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(AssistantReplyBubble.sourcesButtonKey))
            .height,
        greaterThanOrEqualTo(44),
      );

      await tester.tap(find.byKey(AssistantReplyBubble.sourcesButtonKey));
      await tester.pumpAndSettle();

      expect(_sheet, findsOneWidget);
    });

    testWidgets('is absent when the reply cites nothing', (tester) async {
      await _pumpReply(
        tester,
        text: 'Moving £40 covers the overspend.',
        citations: const [],
      );

      expect(find.byKey(AssistantReplyBubble.sourcesButtonKey), findsNothing);
      expect(_marks(tester), isEmpty);
    });
  });

  group('sources sheet', () {
    Future<FakeTaxUrlLauncher> openSheet(WidgetTester tester) async {
      final launcher = await _pumpReply(tester);
      await tester.tap(find.byKey(AssistantReplyBubble.sourcesButtonKey));
      await tester.pumpAndSettle();
      return launcher;
    }

    Finder inSheet(Finder finder) =>
        find.descendant(of: _sheet, matching: finder);

    testWidgets('lists sources in number order with who and when', (
      tester,
    ) async {
      await openSheet(tester);

      expect(inSheet(find.text('Sources')), findsOneWidget);
      final titles = [
        'Capital gains tax: allowances',
        'Cryptoassets Manual: pooling',
        'Draft rules for reporting cryptoasset disposals',
      ];
      final tops = [
        for (final title in titles)
          tester.getTopLeft(inSheet(find.text(title))).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(inSheet(find.text('koinly.io')), findsOneWidget);
      expect(inSheet(find.text('Checked Nov 2, 2026')), findsNWidgets(2));
      expect(inSheet(find.text('Checked Oct 15, 2026')), findsOneWidget);
    });

    testWidgets('badges secondary, inferred and announced sources only', (
      tester,
    ) async {
      await openSheet(tester);

      expect(
        inSheet(find.byKey(const ValueKey('assistant-source-2-secondary'))),
        findsOneWidget,
      );
      expect(inSheet(find.text('From a secondary source')), findsOneWidget);
      expect(inSheet(find.text('Our best estimate')), findsOneWidget);
      expect(
        inSheet(find.byKey(const ValueKey('assistant-source-2-announced'))),
        findsOneWidget,
      );
      expect(inSheet(find.text('Announced, not yet law')), findsOneWidget);
      expect(inSheet(find.text('From the tax authority')), findsNothing);
    });

    testWidgets('opens a source in the browser', (tester) async {
      final launcher = await openSheet(tester);

      await tester.tap(inSheet(find.text('Open koinly.io')));
      await tester.pumpAndSettle();

      expect(launcher.openedPages, [
        Uri.parse('https://www.koinly.io/guides/hmrc-pooling'),
      ]);
    });
  });

  group('disclaimer', () {
    const footer = 'Guidance, not regulated financial advice.';

    String shown(WidgetTester tester) => tester
        .widget<Text>(find.byKey(AssistantReplyBubble.disclaimerKey))
        .data!;

    testWidgets('shows the country wording under a reply about tax', (
      tester,
    ) async {
      await _pumpReply(tester, jurisdiction: TaxJurisdiction.gb);

      expect(find.byKey(AssistantReplyBubble.disclaimerKey), findsOneWidget);
      expect(
        shown(tester),
        "Information only, not tax, legal or investment advice, and it doesn't "
        'recommend any investment, pension or ISA product. Rules change, so '
        'check with a qualified professional.',
      );
      expect(find.text(footer), findsNothing);
    });

    testWidgets('falls back to the generic wording without a jurisdiction', (
      tester,
    ) async {
      await _pumpReply(tester);

      expect(shown(tester), contains('before you act on it'));
      expect(shown(tester), isNot(footer));
    });

    testWidgets('is absent from a reply without the flag', (tester) async {
      await _pumpReply(tester, touchesTaxOrInvestment: false);

      expect(find.byKey(AssistantReplyBubble.disclaimerKey), findsNothing);
    });
  });

  for (final (name, theme) in [
    ('light', OpenBudgetTheme.light),
    ('dark', OpenBudgetTheme.dark),
  ]) {
    testWidgets('fits a 320-point phone at 2x text in $name', (tester) async {
      await _pumpReply(
        tester,
        theme: theme,
        textScale: 2,
        size: const Size(320, 700),
      );
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(
        find.byKey(AssistantReplyBubble.sourcesButtonKey),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(AssistantReplyBubble.sourcesButtonKey));
      await tester.pumpAndSettle();
      expect(_sheet, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Announced, not yet law'),
        120,
        scrollable: find.descendant(
          of: _sheet,
          matching: find.byType(Scrollable),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
