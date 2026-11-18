import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_upcoming_section.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeTaxRepository repository, {
  FakeTaxUrlLauncher? launcher,
  TextScaler textScaler = TextScaler.noScaling,
  Size size = const Size(390, 900),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taxRepositoryProvider.overrideWithValue(repository),
        taxUrlLauncherProvider.overrideWithValue(
          launcher ?? FakeTaxUrlLauncher(),
        ),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: TaxUpcomingSection(entityId: testEntityId),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('TaxUpcomingSection', () {
    testWidgets('lists the next four dates, soonest first, and fetches once', (
      tester,
    ) async {
      final repository = FakeTaxRepository(deadlines: testDeadlines());
      await _pump(tester, repository);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              RegExp(
                r'^tax-deadline-.*-\d{8}$',
              ).hasMatch((widget.key! as ValueKey<String>).value),
        ),
        findsNWidgets(4),
      );
      final dates = [
        for (final widget in tester.widgetList<Text>(
          find.byKey(const Key('tax-deadline-date')),
        ))
          widget.data,
      ];
      expect(dates, [
        'Dec 30, 2026',
        'Jan 31, 2027',
        'Jan 31, 2027',
        'Jan 31, 2027',
      ]);
      expect(repository.deadlineCalls, [testEntityId]);
    });

    testWidgets(
      'says what each date is, what it covers and how far off it is',
      (
        tester,
      ) async {
        await _pump(tester, FakeTaxRepository(deadlines: testDeadlines()));

        expect(
          find.text('Self Assessment online return for tax-code collection'),
          findsOneWidget,
        );
        expect(find.text('In 49 days'), findsOneWidget);
        expect(find.text('For 2025/26'), findsWidgets);
        expect(find.text('Filing'), findsWidgets);
        expect(find.text('Payment'), findsWidgets);
        expect(
          find.textContaining('collected through the tax code'),
          findsOneWidget,
        );
      },
    );

    testWidgets('words a date today, tomorrow and later', (tester) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [
            taxDeadline(id: 'gb.test.today', daysLeft: 0),
            taxDeadline(id: 'gb.test.tomorrow', daysLeft: 1),
            taxDeadline(id: 'gb.test.later', daysLeft: 12),
          ],
        ),
      );

      expect(find.text('Due today'), findsOneWidget);
      expect(find.text('Due tomorrow'), findsOneWidget);
      expect(find.text('In 12 days'), findsOneWidget);
    });

    testWidgets('shows the date as the calendar day, not a shifted one', (
      tester,
    ) async {
      // A server date is a UTC midnight; no local zone may move it a day.
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [taxDeadline(dueDate: DateTime.utc(2027, 3))],
        ),
      );

      expect(find.text('Mar 1, 2027'), findsOneWidget);
    });

    testWidgets('names the kind when return and payment fall together', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [
            taxDeadline(id: 'gb.vat.return', kind: 'filingAndPayment'),
          ],
        ),
      );

      expect(find.text('Filing and payment'), findsOneWidget);
    });

    testWidgets('shows the rest only when asked', (tester) async {
      await _pump(tester, FakeTaxRepository(deadlines: testDeadlines()));

      expect(find.text('Second payment on account'), findsNothing);
      expect(find.text('Show all 5 dates'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('tax-upcoming-toggle')));
      await tester.tap(find.byKey(const Key('tax-upcoming-toggle')));
      await tester.pumpAndSettle();

      expect(find.text('Second payment on account'), findsOneWidget);
      expect(find.text('Show fewer dates'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('tax-upcoming-toggle')));
      await tester.tap(find.byKey(const Key('tax-upcoming-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('Second payment on account'), findsNothing);
    });

    testWidgets('offers no toggle for four dates or fewer', (tester) async {
      await _pump(
        tester,
        FakeTaxRepository(deadlines: testDeadlines().take(4).toList()),
      );

      expect(find.byKey(const Key('tax-upcoming-toggle')), findsNothing);
    });

    testWidgets('marks a date that comes from the profile', (tester) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [taxDeadline(dependsOnProfile: true)],
        ),
      );

      expect(find.text('Based on your tax profile'), findsOneWidget);
    });

    testWidgets('shows the date a weekend or holiday moved it from', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [
            taxDeadline(
              dueDate: DateTime.utc(2027, 8, 2),
              rolledFrom: DateTime.utc(2027, 7, 31),
            ),
          ],
        ),
      );

      expect(
        find.text('Moved from Jul 31, 2027, a weekend or holiday'),
        findsOneWidget,
      );
    });

    testWidgets('badges a date that is not from the authority itself', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [
            taxDeadline(id: 'ng.paye.monthly-remittance', grade: 'secondary'),
            taxDeadline(id: 'ng.pit.annual-return', grade: 'inferred'),
            taxDeadline(),
          ],
        ),
      );

      expect(
        find.byKey(const Key('tax-deadline-grade-badge')),
        findsNWidgets(2),
      );
      expect(find.text('From a secondary source'), findsOneWidget);
      expect(find.text('Date not confirmed by the authority'), findsOneWidget);
    });

    testWidgets('opens the source page the date came from', (tester) async {
      final launcher = FakeTaxUrlLauncher();
      await _pump(
        tester,
        FakeTaxRepository(deadlines: [taxDeadline()]),
        launcher: launcher,
      );

      expect(
        find.text('Source: GOV.UK Self Assessment deadlines'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('tax-deadline-source')));
      await tester.pumpAndSettle();

      expect(launcher.openedPages, [
        Uri.parse('https://www.gov.uk/self-assessment-tax-returns/deadlines'),
      ]);
    });

    testWidgets('says so when the device cannot open the page', (tester) async {
      await _pump(
        tester,
        FakeTaxRepository(deadlines: [taxDeadline()]),
        launcher: FakeTaxUrlLauncher(opens: false),
      );

      await tester.tap(find.byKey(const Key('tax-deadline-source')));
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't open that page. Try again in a moment."),
        findsOneWidget,
      );
    });

    testWidgets('says so when the calendar is empty', (tester) async {
      await _pump(tester, FakeTaxRepository());

      expect(find.byKey(const Key('tax-upcoming-empty')), findsOneWidget);
      expect(
        find.text('No filing or payment dates in the next year.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a loading panel while the dates load', (tester) async {
      final completer = Completer<List<TaxDeadlineView>>();
      final repository = _PendingRepository(completer.future);
      tester.view
        ..physicalSize = const Size(390, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [taxRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: TaxUpcomingSection(entityId: testEntityId),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
      completer.complete(const []);
      await tester.pumpAndSettle();
      expect(find.byType(ObLoadingPanel), findsNothing);
    });

    testWidgets('offers a retry when the dates fail to load', (tester) async {
      final repository = FakeTaxRepository(
        deadlinesError: Exception('server down'),
      );
      await _pump(tester, repository);

      expect(
        find.text("We couldn't load your upcoming dates."),
        findsOneWidget,
      );

      repository
        ..deadlinesError = null
        ..deadlines = testDeadlines();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tax-upcoming-error')), findsNothing);
      // Riverpod retries a failed read before it surfaces the error, so the
      // count only has to show that the retry button asked again.
      expect(repository.deadlineCalls.length, greaterThan(1));
      expect(find.text('Self Assessment online return'), findsOneWidget);
    });

    testWidgets('lays out at the largest text size on a narrow phone', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          deadlines: [
            taxDeadline(
              dependsOnProfile: true,
              grade: 'secondary',
              note:
                  'A long note that has to wrap across several lines '
                  'without overflowing the card.',
              rolledFrom: DateTime.utc(2027, 1, 30),
            ),
          ],
        ),
        textScaler: const TextScaler.linear(2),
        size: const Size(320, 900),
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('tax-deadline-source')), findsOneWidget);
    });
  });
}

class _PendingRepository extends FakeTaxRepository {
  _PendingRepository(this._pending);

  final Future<List<TaxDeadlineView>> _pending;

  @override
  Future<List<TaxDeadlineView>> listDeadlines(String entityId) => _pending;
}
