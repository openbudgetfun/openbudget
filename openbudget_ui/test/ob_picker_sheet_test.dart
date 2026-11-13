import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _options = <ObPickerOption<String>>[
  ObPickerOption(value: 'GB', label: 'United Kingdom', code: 'GB'),
  ObPickerOption(value: 'US', label: 'United States', code: 'US'),
  ObPickerOption(
    value: 'CI',
    label: 'Côte d’Ivoire',
    code: 'CI',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'KE',
    label: 'Kenya',
    code: 'KE',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'TR',
    label: 'Türkiye',
    code: 'TR',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'AU',
    label: 'Australia',
    code: 'AU',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'KW',
    label: 'Kuwait',
    code: 'KW',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'IE',
    label: 'Ireland',
    code: 'IE',
    section: 'All countries',
  ),
  ObPickerOption(
    value: 'NG',
    label: 'Nigeria',
    code: 'NG',
    section: 'All countries',
  ),
];

String _count(int count) => '$count results';
String _noMatch(String query) => 'Nothing matches “$query”';

/// Opens the sheet from a button and resolves with whatever it returns.
class _Harness {
  String? result;
  bool resolved = false;

  Future<void> pump(
    WidgetTester tester, {
    List<ObPickerOption<String>> options = _options,
    String? selected,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? OpenBudgetTheme.light,
        home: ObWiredScope(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showObPickerSheet<String>(
                    context,
                    title: 'Country',
                    options: options,
                    selected: selected,
                    searchHint: 'Search countries',
                    clearSearchLabel: 'Clear search',
                    selectedLabel: 'Selected',
                    resultCountLabel: _count,
                    noMatchLabel: _noMatch,
                  );
                  resolved = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }
}

/// The labels of the option rows currently built, top to bottom.
List<String> _rowLabels(WidgetTester tester) {
  final found = <(double, String)>[
    for (final option in _options)
      if (find.text(option.label).evaluate().isNotEmpty)
        (tester.getTopLeft(find.text(option.label)).dy, option.label),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, label) in found) label];
}

void main() {
  group('ObPickerSheet', () {
    testWidgets('lists every option under its section headings', (
      tester,
    ) async {
      await _Harness().pump(tester);

      expect(find.text('Country'), findsOneWidget);
      expect(find.text('All countries'), findsOneWidget);
      expect(find.text('9 results'), findsOneWidget);
      expect(find.text('Kenya'), findsOneWidget);
    });

    testWidgets('finds a country by name, ignoring case', (tester) async {
      await _Harness().pump(tester);
      await tester.enterText(find.byType(TextField), 'KENYA');
      await tester.pumpAndSettle();

      expect(_rowLabels(tester), ['Kenya']);
      expect(find.text('1 results'), findsOneWidget);
      // Headings go once the person is searching.
      expect(find.text('All countries'), findsNothing);
    });

    testWidgets('finds a country by its code, ranked before name matches', (
      tester,
    ) async {
      await _Harness().pump(tester);
      await tester.enterText(find.byType(TextField), 'ke');
      await tester.pumpAndSettle();

      // "KE" is Kenya's code, so it leads "Kuwait"-style prefix matches and
      // names that merely contain "ke".
      expect(_rowLabels(tester).first, 'Kenya');
    });

    testWidgets('an exact keyword ranks before names that start with it', (
      tester,
    ) async {
      await _Harness().pump(
        tester,
        options: const [
          ObPickerOption(value: 'UA', label: 'Ukraine', code: 'UA'),
          ObPickerOption(
            value: 'GB',
            label: 'United Kingdom',
            code: 'GB',
            keywords: ['UK'],
          ),
          ObPickerOption(value: 'US', label: 'United States', code: 'US'),
          ObPickerOption(value: 'KE', label: 'Kenya', code: 'KE'),
          ObPickerOption(value: 'TR', label: 'Türkiye', code: 'TR'),
          ObPickerOption(value: 'AU', label: 'Australia', code: 'AU'),
          ObPickerOption(value: 'KW', label: 'Kuwait', code: 'KW'),
          ObPickerOption(value: 'IE', label: 'Ireland', code: 'IE'),
          ObPickerOption(value: 'NG', label: 'Nigeria', code: 'NG'),
        ],
      );
      await tester.enterText(find.byType(TextField), 'uk');
      await tester.pumpAndSettle();

      final uk = tester.getTopLeft(find.text('United Kingdom')).dy;
      final ukraine = tester.getTopLeft(find.text('Ukraine')).dy;
      expect(uk, lessThan(ukraine));
    });

    testWidgets('ignores accents and apostrophes', (tester) async {
      await _Harness().pump(tester);

      await tester.enterText(find.byType(TextField), 'turkiye');
      await tester.pumpAndSettle();
      expect(_rowLabels(tester), ['Türkiye']);

      await tester.enterText(find.byType(TextField), 'cote divoire');
      await tester.pumpAndSettle();
      expect(_rowLabels(tester), ['Côte d’Ivoire']);
    });

    testWidgets('ranks names that start with the query first', (tester) async {
      await _Harness().pump(tester);
      await tester.enterText(find.byType(TextField), 'united');
      await tester.pumpAndSettle();
      expect(_rowLabels(tester), ['United Kingdom', 'United States']);

      // "n" starts "Nigeria", starts a word of nothing else, and is merely
      // inside the rest, so the prefix hit leads.
      await tester.enterText(find.byType(TextField), 'n');
      await tester.pumpAndSettle();
      expect(_rowLabels(tester).first, 'Nigeria');
    });

    testWidgets('says so when nothing matches', (tester) async {
      await _Harness().pump(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches “zzz”'), findsOneWidget);
      expect(find.text('0 results'), findsOneWidget);
    });

    testWidgets('the clear button empties the search', (tester) async {
      await _Harness().pump(tester);
      expect(find.byTooltip('Clear search'), findsNothing);

      await tester.enterText(find.byType(TextField), 'kenya');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();

      expect(find.text('9 results'), findsOneWidget);
      expect(find.byTooltip('Clear search'), findsNothing);
    });

    testWidgets('tapping a row returns its value', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await tester.tap(find.text('Kenya'));
      await tester.pumpAndSettle();

      expect(harness.result, 'KE');
      expect(find.text('Country'), findsNothing);
    });

    testWidgets('Enter picks the top result', (tester) async {
      final harness = _Harness();
      await harness.pump(tester);
      await tester.enterText(find.byType(TextField), 'nig');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(harness.result, 'NG');
    });

    testWidgets('Enter on an empty result keeps the sheet open', (
      tester,
    ) async {
      final harness = _Harness();
      await harness.pump(tester);
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(harness.resolved, isFalse);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('the down arrow moves from the field into the list', (
      tester,
    ) async {
      final harness = _Harness();
      await harness.pump(tester);
      await tester.enterText(find.byType(TextField), 'u');
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      // Focus now sits on a row, so Enter activates it.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(harness.result, isNotNull);
    });

    testWidgets('marks the selected option with a check and its state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _Harness().pump(tester, selected: 'KE');

      expect(
        find.descendant(
          of: find.byType(ObPickerSheet<String>),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is SkribbleIcon && widget.data == OpenBudgetIcons.check,
          ),
        ),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(find.text('Kenya')),
        matchesSemantics(
          label: 'Kenya\nKE',
          value: 'Selected',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('opens scrolled to the selection', (tester) async {
      final options = [
        for (var i = 0; i < 120; i++)
          ObPickerOption(value: 'v$i', label: 'Option $i', code: 'C$i'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: OpenBudgetTheme.light,
          home: ObWiredScope(
            child: Scaffold(
              body: ObPickerSheet<String>(
                title: 'Pick',
                options: options,
                selected: 'v100',
                searchHint: 'Search',
                clearSearchLabel: 'Clear',
                selectedLabel: 'Selected',
                resultCountLabel: _count,
                noMatchLabel: _noMatch,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Option 100'), findsOneWidget);
      expect(find.text('Option 0'), findsNothing);
    });

    testWidgets('a short list skips the search field', (tester) async {
      await _Harness().pump(
        tester,
        options: _options.take(3).toList(),
      );

      expect(find.byType(TextField), findsNothing);
      expect(find.text('3 results'), findsNothing);
      expect(find.text('Côte d’Ivoire'), findsOneWidget);
    });

    for (final (name, size) in [
      ('phone', const Size(360, 640)),
      ('desktop', const Size(1280, 800)),
    ]) {
      testWidgets('lays out without overflow on a $name', (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await _Harness().pump(tester, selected: 'GB');
        await tester.enterText(find.byType(TextField), 'u');
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(ObPickerSheet<String>), findsOneWidget);
      });
    }

    testWidgets('renders in the night theme', (tester) async {
      await _Harness().pump(
        tester,
        selected: 'KE',
        theme: OpenBudgetTheme.dark,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Kenya'), findsOneWidget);
    });
  });

  group('foldForSearch', () {
    test('lowercases and strips accents and apostrophes', () {
      expect(foldForSearch('Côte d’Ivoire'), 'cote divoire');
      expect(foldForSearch('São Tomé and Príncipe'), 'sao tome and principe');
      expect(foldForSearch('  Curaçao '), 'curacao');
      expect(foldForSearch('Åland Islands'), 'aland islands');
    });
  });
}
