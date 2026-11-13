import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_overview_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

Entity _kenya() => testEntity(countryCode: 'KE', baseCurrencyCode: 'KES');

/// A repository whose export link arrives when the test says so.
class _PendingExportRepository extends FakeTaxRepository {
  final Completer<String> link = Completer<String>();

  @override
  Future<String> createExportLink(String entityId, {int? startYear}) {
    exportCalls.add((entityId: entityId, startYear: startYear));
    return link.future;
  }
}

/// [formatMinorForCode] spelled out, since the symbol and its spacing are the
/// formatter's to choose.
String _money(int minor, String code) => formatMinorForCode(minor, code);

Widget _buildApp(
  FakeTaxRepository repository, {
  Entity? entity,
  FakeTaxUrlLauncher? launcher,
  double textScale = 1,
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$testEntityId/tax',
    routes: [
      GoRoute(
        name: taxOverviewRoute,
        path: '/budgets/:entityId/tax',
        builder: (context, state) =>
            TaxOverviewScreen(entityId: state.pathParameters['entityId']!),
        routes: [
          GoRoute(
            name: taxProfileRoute,
            path: 'profile',
            builder: (_, _) => const Scaffold(body: Text('Profile stub')),
          ),
        ],
      ),
      GoRoute(
        name: transactionListRoute,
        path: '/budgets/:entityId/transactions',
        builder: (_, _) => const Scaffold(body: Text('Transactions stub')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      taxUrlLauncherProvider.overrideWithValue(
        launcher ?? FakeTaxUrlLauncher(),
      ),
      entityDetailProvider.overrideWith(
        (ref, entityId) async => entity ?? _kenya(),
      ),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    ),
  );
}

/// A phone's width with room for the whole panel, so content tests can read
/// every section without scrolling. Layout tests use real phone heights.
const Size _tallPhone = Size(390, 2400);

/// A typical phone.
const Size _phone = Size(390, 844);

Future<void> _pump(
  WidgetTester tester,
  FakeTaxRepository repository, {
  Entity? entity,
  FakeTaxUrlLauncher? launcher,
  Size size = _tallPhone,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _buildApp(
      repository,
      entity: entity,
      launcher: launcher,
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls [finder] to the middle of the list and lets it settle, building it
/// first when the list has not reached it yet.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await Scrollable.ensureVisible(tester.element(finder.first), alignment: 0.5);
  await tester.pumpAndSettle();
}

/// Reveals [finder], then taps it.
Future<void> _tapRevealed(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('TaxOverviewScreen for a country with no tax pack', () {
    testWidgets('shows the universal panel for a Kenyan entity', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository());

      // Not today's dead end, and no profile to set up.
      expect(find.text("We couldn't load your tax report."), findsNothing);
      expect(find.text('Set up taxes'), findsNothing);

      expect(find.text('No full tax rules for Kenya yet'), findsOneWidget);
      expect(find.text('Tax year 2026'), findsOneWidget);
      expect(find.text('Jan 1, 2026 to Dec 31, 2026'), findsOneWidget);
      expect(find.text('Kenya'), findsOneWidget);
      expect(find.text('Individual'), findsOneWidget);

      // The summary totals come from tax.getSummary.
      expect(find.text('Income this tax year'), findsOneWidget);
      expect(find.text(_money(120000000, 'KES')), findsWidgets);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Tax already paid'), findsOneWidget);

      // The rate is the standard 16%, with its source.
      expect(find.text('VAT rates'), findsOneWidget);
      expect(find.text('16%'), findsOneWidget);
      expect(find.text('Standard'), findsOneWidget);
      expect(find.textContaining('Source: afriref: Kenya'), findsOneWidget);

      expect(find.text('Kenya Revenue Authority (KRA)'), findsOneWidget);
      expect(find.text('Take it to your accountant'), findsOneWidget);
      expect(find.text('Export tax summary'), findsOneWidget);
      expect(find.textContaining('not a tax return'), findsOneWidget);
    });

    testWidgets('shows only the rates in force, not superseded ones', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository());

      expect(find.text('14%'), findsNothing);
      expect(find.text('8%'), findsNothing);
    });

    testWidgets('badges an S-graded rate as from a secondary source', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository());

      expect(
        find.byKey(const Key('tax-secondary-source-badge')),
        findsOneWidget,
      );
      expect(find.text('From a secondary source'), findsOneWidget);
      expect(find.text('From the tax authority'), findsNothing);
    });

    testWidgets('badges a P-graded rate as from the tax authority', (
      tester,
    ) async {
      // India's GST slabs are cited to the authority itself.
      await _pump(
        tester,
        FakeTaxRepository(
          defaultSummary: taxSummaryView(
            countryCode: 'IN',
            currencyCode: 'INR',
          ),
        ),
        entity: testEntity(countryCode: 'IN', baseCurrencyCode: 'INR'),
      );

      expect(find.text('From the tax authority'), findsWidgets);
      expect(find.text('From a secondary source'), findsNothing);
      expect(find.text('GST rates'), findsOneWidget);
    });

    testWidgets("writes Quebec's 9.975% exactly from the integer rate", (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          defaultSummary: taxSummaryView(
            countryCode: 'CA',
            currencyCode: 'CAD',
          ),
        ),
        entity: testEntity(countryCode: 'CA', baseCurrencyCode: 'CAD'),
      );

      expect(find.text('5%'), findsWidgets);
      await _tapRevealed(tester, find.text('Rates by region'));

      expect(find.textContaining('GST 5% · QST 9.975%'), findsOneWidget);
      expect(find.textContaining('9.98'), findsNothing);
      expect(find.textContaining('9.97%'), findsNothing);
    });

    testWidgets('says so when the country has no VAT or sales tax', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(defaultSummary: taxSummaryView(countryCode: 'AQ')),
        entity: testEntity(countryCode: 'AQ'),
      );

      expect(find.text('VAT or sales tax'), findsOneWidget);
      expect(
        find.textContaining("doesn't charge VAT or sales tax"),
        findsOneWidget,
      );
    });

    testWidgets('says so when the rates have not been looked up', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(defaultSummary: taxSummaryView(countryCode: 'AX')),
        entity: testEntity(countryCode: 'AX'),
      );

      expect(
        find.text(
          "We haven't looked up the VAT or sales tax rates for this country yet.",
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      "lists the country data's caveats under what we could not verify",
      (
        tester,
      ) async {
        await _pump(tester, FakeTaxRepository());

        await tester.scrollUntilVisible(
          find.text('What we could not verify'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('What we could not verify'), findsOneWidget);
        expect(find.byKey(const Key('tax-country-caveat-0')), findsOneWidget);
        expect(find.textContaining('Country facts checked on'), findsOneWidget);
      },
    );

    testWidgets(
      'shows sales tax totals once there is some, named for the tax',
      (
        tester,
      ) async {
        await _pump(
          tester,
          FakeTaxRepository(
            defaultSummary: taxSummaryView(
              salesTaxCollectedMinor: 1600000,
              salesTaxPaidMinor: 480000,
            ),
          ),
        );

        expect(find.text('VAT collected'), findsOneWidget);
        expect(find.text(_money(1600000, 'KES')), findsOneWidget);
        expect(find.text('VAT paid'), findsOneWidget);
      },
    );

    testWidgets('hides sales tax and relief tiles while they are zero', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository());

      expect(find.text('VAT collected'), findsNothing);
      expect(find.text('Reliefs'), findsNothing);
    });

    testWidgets('links uncategorised lines to the transaction list', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          defaultSummary: taxSummaryView(uncategorizedCount: 4),
        ),
      );

      expect(find.text('Uncategorized: 4'), findsOneWidget);
      await _tapRevealed(
        tester,
        find.byKey(const Key('tax-uncategorized-chip')),
      );

      expect(find.text('Transactions stub'), findsOneWidget);
    });

    testWidgets('steps to the next tax year and asks for its summary', (
      tester,
    ) async {
      final repository = FakeTaxRepository();
      await _pump(tester, repository);
      expect(repository.summaryCalls.first.startYear, isNull);

      await tester.tap(find.byKey(const Key('tax-year-next')));
      await tester.pumpAndSettle();

      expect(repository.summaryCalls.last.startYear, 2027);
      expect(find.text('Tax year 2027'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tax-year-previous')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tax-year-previous')));
      await tester.pumpAndSettle();
      expect(find.text('Tax year 2025'), findsOneWidget);
    });

    testWidgets('shows rates from the end of a past tax year', (tester) async {
      // 2020 ended after the temporary 14% cut and before the 16% restoration.
      await _pump(
        tester,
        FakeTaxRepository(
          defaultSummary: taxSummaryView(
            startYear: 2020,
            yearStart: DateTime.utc(2020),
            yearEnd: DateTime.utc(2021),
          ),
        ),
      );

      expect(find.text('14%'), findsOneWidget);
      expect(
        find.text('Applies to temporary COVID-19 reduction'),
        findsOneWidget,
      );
      expect(find.text('16%'), findsNothing);
    });

    testWidgets('shows a loading panel for the totals while they load', (
      tester,
    ) async {
      final repository = _PendingSummaryRepository();
      tester.view.physicalSize = _tallPhone;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_buildApp(repository));
      await tester.pump();
      await tester.pump();

      expect(find.text('Loading your tax report'), findsOneWidget);
      expect(find.text('Finding your tax year'), findsOneWidget);
      // The country facts do not wait for the server.
      expect(find.text('16%'), findsOneWidget);
      expect(find.text('Export tax summary'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('tax-year-next')))
            .onPressed,
        isNull,
      );

      repository.summary.complete(taxSummaryView());
      await tester.pumpAndSettle();
      expect(find.text('Tax year 2026'), findsOneWidget);
    });

    testWidgets(
      'keeps the rates and export when the summary fails, and retries',
      (
        tester,
      ) async {
        final repository = FakeTaxRepository(
          summaryError: Exception('server down'),
        );
        await _pump(tester, repository);

        expect(find.text("We couldn't load your summary."), findsOneWidget);
        expect(find.text('16%'), findsOneWidget);
        expect(find.text('Export tax summary'), findsOneWidget);

        repository.summaryError = null;
        await _tapRevealed(tester, find.text('Try again'));

        expect(find.text("We couldn't load your summary."), findsNothing);
        expect(find.text('Income this tax year'), findsOneWidget);
      },
    );

    testWidgets('shows a problem panel for a country code it does not know', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(),
        entity: testEntity(countryCode: 'ZZ'),
      );

      expect(find.text("We couldn't load your tax report."), findsOneWidget);
      expect(find.text('ZZ'), findsOneWidget);
    });
  });

  group('links out of the universal panel', () {
    testWidgets('opens the tax authority with the launcher', (tester) async {
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, FakeTaxRepository(), launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-authority-link')));

      expect(launcher.openedPages, [Uri.parse('https://www.kra.go.ke')]);
    });

    testWidgets("opens a rate's source with the launcher", (tester) async {
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, FakeTaxRepository(), launcher: launcher);

      await _tapRevealed(tester, find.textContaining('Source: afriref: Kenya'));

      expect(launcher.openedPages, [Uri.parse('https://afriref.dev/ke/vat')]);
    });

    testWidgets('tells the person when a link would not open', (tester) async {
      final launcher = FakeTaxUrlLauncher(opens: false);
      await _pump(tester, FakeTaxRepository(), launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-authority-link')));

      expect(
        find.text("We couldn't open that page. Try again in a moment."),
        findsOneWidget,
      );
    });
  });

  group('Export tax summary', () {
    testWidgets('opens the signed URL the server returned', (tester) async {
      final repository = FakeTaxRepository();
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, repository, launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(repository.exportCalls, [
        (entityId: testEntityId, startYear: 2026),
      ]);
      expect(launcher.openedDownloads, [Uri.parse(testExportLink)]);
      expect(find.byKey(const Key('tax-export-error')), findsNothing);
    });

    testWidgets('exports the year being looked at', (tester) async {
      final repository = FakeTaxRepository();
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, repository, launcher: launcher);

      await tester.tap(find.byKey(const Key('tax-year-previous')));
      await tester.pumpAndSettle();
      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(repository.exportCalls.single.startYear, 2025);
    });

    testWidgets('still exports when the summary could not load', (
      tester,
    ) async {
      final repository = FakeTaxRepository(
        summaryError: Exception('server down'),
      );
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, repository, launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(repository.exportCalls.single.startYear, isNull);
      expect(launcher.openedDownloads, hasLength(1));
    });

    testWidgets('shows a busy button while the link is made', (tester) async {
      final repository = _PendingExportRepository();
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, repository, launcher: launcher);

      await _reveal(tester, find.byKey(const Key('tax-export-button')));
      await tester.tap(find.byKey(const Key('tax-export-button')));
      await tester.pump();

      expect(find.text('Export tax summary'), findsNothing);
      expect(find.bySemanticsLabel('Preparing your download'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.descendant(
                of: find.byKey(const Key('tax-export-button')),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );

      repository.link.complete(testExportLink);
      await tester.pumpAndSettle();

      expect(find.text('Export tax summary'), findsOneWidget);
      expect(launcher.openedDownloads, hasLength(1));
    });

    testWidgets('says plainly when the link could not be made, then retries', (
      tester,
    ) async {
      final repository = FakeTaxRepository(
        exportError: Exception('server down'),
      );
      final launcher = FakeTaxUrlLauncher();
      await _pump(tester, repository, launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(
        find.text(
          "We couldn't prepare your download. Check your connection and try again.",
        ),
        findsOneWidget,
      );
      expect(launcher.openedDownloads, isEmpty);
      expect(find.text('Export tax summary'), findsOneWidget);

      repository.exportError = null;
      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(find.byKey(const Key('tax-export-error')), findsNothing);
      expect(launcher.openedDownloads, [Uri.parse(testExportLink)]);
    });

    testWidgets('says plainly when the device would not open the link', (
      tester,
    ) async {
      final launcher = FakeTaxUrlLauncher(opens: false);
      await _pump(tester, FakeTaxRepository(), launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(
        find.text(
          "Your download is ready, but this device wouldn't open it. Try again in a moment.",
        ),
        findsOneWidget,
      );
    });
  });

  group('TaxOverviewScreen for a country with a tax pack', () {
    Future<void> pumpGb(
      WidgetTester tester,
      FakeTaxRepository repository, {
      FakeTaxUrlLauncher? launcher,
    }) => _pump(
      tester,
      repository,
      entity: testEntity(),
      launcher: launcher,
    );

    testWidgets('keeps its sections and adds the export button', (
      tester,
    ) async {
      await pumpGb(
        tester,
        FakeTaxRepository(
          profile: taxProfileRecord(),
          defaultReport: taxReportView(
            caveats: [taxCaveat()],
            uncategorizedCount: 3,
          ),
        ),
      );

      // The existing screen, untouched.
      expect(find.text('Tax year 2026'), findsOneWidget);
      expect(find.text('Balance due'), findsOneWidget);
      expect(find.text('Income tax'), findsOneWidget);
      expect(find.text('Uncategorized: 3'), findsOneWidget);
      expect(find.text('Taxes'), findsOneWidget);
      expect(
        find.text(
          'Guidance only, not tax advice. Check figures with a qualified '
          'adviser before filing.',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('What we could not verify'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const Key('tax-caveat-gb.hmrc-rounding-inferences')),
        findsOneWidget,
      );
      await _reveal(tester, find.text('How this was worked out'));
      expect(find.text('How this was worked out'), findsOneWidget);

      // The one addition.
      expect(find.text('Export tax summary'), findsOneWidget);

      // None of the universal panel.
      expect(find.textContaining('No full tax rules'), findsNothing);
      expect(find.text('VAT rates'), findsNothing);
      expect(find.text('Your year so far'), findsNothing);
    });

    testWidgets('does not ask for the universal summary', (tester) async {
      final repository = FakeTaxRepository(
        profile: taxProfileRecord(),
        defaultReport: taxReportView(),
      );
      await pumpGb(tester, repository);

      expect(repository.summaryCalls, isEmpty);
    });

    testWidgets('still invites a GB entity without a profile to set up', (
      tester,
    ) async {
      await pumpGb(tester, FakeTaxRepository());

      expect(find.text('Set up taxes'), findsWidgets);
      expect(find.text('Export tax summary'), findsNothing);
    });

    testWidgets('exports the year the report shows', (tester) async {
      final repository = FakeTaxRepository(
        profile: taxProfileRecord(),
        defaultReport: taxReportView(),
      );
      final launcher = FakeTaxUrlLauncher();
      await pumpGb(tester, repository, launcher: launcher);

      await _tapRevealed(tester, find.byKey(const Key('tax-export-button')));

      expect(repository.exportCalls, [
        (entityId: testEntityId, startYear: 2026),
      ]);
      expect(launcher.openedDownloads, [Uri.parse(testExportLink)]);
    });
  });

  group('layout', () {
    testWidgets('sets the panel in two columns on a desktop window', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository(), size: const Size(1280, 900));

      final summary = tester.getTopLeft(
        find.byKey(const Key('tax-summary-hero')),
      );
      final rates = tester.getTopLeft(
        find.byKey(const Key('tax-rate-standard-160000')),
      );
      expect(rates.dx, greaterThan(summary.dx + 300));
      expect(
        tester.getSize(find.byKey(const Key('tax-summary-hero'))).width,
        lessThan(560),
      );
    });

    testWidgets('stacks the panel in one column on a phone', (tester) async {
      await _pump(tester, FakeTaxRepository());

      final summary = tester.getTopLeft(
        find.byKey(const Key('tax-summary-hero')),
      );
      final rates = tester.getTopLeft(
        find.byKey(const Key('tax-rate-standard-160000')),
      );
      expect(rates.dx, summary.dx);
      expect(rates.dy, greaterThan(summary.dy));
    });

    testWidgets('does not overflow on a phone at twice the text size', (
      tester,
    ) async {
      await _pump(
        tester,
        FakeTaxRepository(
          defaultSummary: taxSummaryView(
            salesTaxCollectedMinor: 1600000,
            salesTaxPaidMinor: 480000,
            totalReliefMinor: 100000,
            uncategorizedCount: 2,
          ),
        ),
        size: _phone,
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
      await _reveal(tester, find.text('What we could not verify'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a narrow phone', (tester) async {
      await _pump(tester, FakeTaxRepository(), size: const Size(320, 640));

      expect(tester.takeException(), isNull);
      await _reveal(tester, find.text('What we could not verify'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the disclaimer in view at normal text size', (
      tester,
    ) async {
      await _pump(tester, FakeTaxRepository(), size: _phone);

      final disclaimer = find.textContaining('not a tax return');
      expect(disclaimer, findsOneWidget);
      expect(tester.getBottomLeft(disclaimer).dy, lessThanOrEqualTo(844));
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(disclaimer, findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('announces each rate as one phrase and the links as links', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, FakeTaxRepository());
      await _reveal(tester, find.text('16%'));

      expect(
        find.bySemanticsLabel(RegExp(r'^16%\s+Standard')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('^Open source: afriref: Kenya')),
        findsOneWidget,
      );
      await _reveal(tester, find.byKey(const Key('tax-authority-link')));
      expect(
        find.bySemanticsLabel('Open the Kenya Revenue Authority (KRA) website'),
        findsWidgets,
      );
      handle.dispose();
    });

    testWidgets('keeps the sections apart for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, FakeTaxRepository());

      // A section's heading is its own stop, not fused with the figures
      // under it or with the section before it.
      final heading = tester.getSemantics(find.text('Your year so far'));
      expect(heading.label, 'Your year so far');
      final income = tester.getSemantics(find.text('Income this tax year'));
      expect(income.label, isNot(contains('Your year so far')));
      final link = tester.getSemantics(
        find.textContaining('Source: afriref: Kenya'),
      );
      expect(link.label, startsWith('Open source:'));
      expect(link.label, isNot(contains('In force since')));
      handle.dispose();
    });
  });
}

/// A repository whose summary arrives when the test says so.
class _PendingSummaryRepository extends FakeTaxRepository {
  final Completer<TaxSummaryView> summary = Completer<TaxSummaryView>();

  @override
  Future<TaxSummaryView> getSummary(String entityId, {int? startYear}) {
    summaryCalls.add((entityId: entityId, startYear: startYear));
    return summary.future;
  }
}
