import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Widget _subject(Widget child) => MaterialApp(
  theme: OpenBudgetTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

List<ReportChartDatum> _segments(ThemeData theme) {
  final series = reportSeriesColors(theme);
  return [
    ReportChartDatum(
      label: 'Rent',
      amountLabel: r'$1,200.00',
      value: 120000,
      color: series[0],
    ),
    ReportChartDatum(
      label: 'Groceries',
      amountLabel: r'$420.00',
      value: 42000,
      color: series[1],
    ),
  ];
}

void main() {
  group('ReportShareBar', () {
    testWidgets('renders its segments and legend under a summary label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final theme = OpenBudgetTheme.light;
      final segments = _segments(theme);

      await tester.pumpWidget(
        _subject(
          Column(
            children: [
              ReportShareBar(
                segments: segments,
                semanticsLabel: r'Spending by category. Rent $1,200.00',
              ),
              ReportChartLegend(entries: segments),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReportShareBar), findsOneWidget);
      expect(
        find.bySemanticsLabel(r'Spending by category. Rent $1,200.00'),
        findsOneWidget,
      );
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text(r'$420.00'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('shows an empty panel when there is nothing to draw', (
      tester,
    ) async {
      await tester.pumpWidget(
        _subject(
          const ReportShareBar(segments: [], semanticsLabel: 'Nothing'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ObStatePanel), findsOneWidget);
      expect(find.text('Nothing to chart yet'), findsOneWidget);
      expect(
        find.text('Add a few transactions and this drawing fills in.'),
        findsOneWidget,
      );
    });

    testWidgets('draws without motion when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _subject(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: ReportShareBar(
              segments: _segments(OpenBudgetTheme.light),
              semanticsLabel: 'Spending by category',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ReportShareBar), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('ReportColumnChart', () {
    testWidgets('renders columns with labels and a summary label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final series = reportSeriesColors(OpenBudgetTheme.light);

      await tester.pumpWidget(
        _subject(
          ReportColumnChart(
            columns: [
              ReportChartColumn(
                label: 'Jan',
                values: [
                  ReportChartDatum(
                    label: 'Income',
                    amountLabel: r'$800.00',
                    value: 80000,
                    color: series[1],
                  ),
                ],
              ),
              ReportChartColumn(
                label: 'Feb',
                values: [
                  ReportChartDatum(
                    label: 'Income',
                    amountLabel: r'$640.00',
                    value: 64000,
                    color: series[1],
                  ),
                ],
              ),
            ],
            semanticsLabel:
                r'Monthly comparison. January $800.00, February $640.00',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jan'), findsOneWidget);
      expect(find.text('Feb'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          r'Monthly comparison. January $800.00, February $640.00',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('shows an empty panel for empty columns', (tester) async {
      await tester.pumpWidget(
        _subject(
          const ReportColumnChart(columns: [], semanticsLabel: 'Nothing'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ObStatePanel), findsOneWidget);
      expect(find.text('Nothing to chart yet'), findsOneWidget);
    });
  });
}
