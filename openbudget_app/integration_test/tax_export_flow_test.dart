import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_overview_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;

/// A Kenyan individual: a country with no tax rule pack.
Entity _kenyanEntity() => TestData.gbpEntity().copyWith(
  countryCode: 'KE',
  baseCurrencyCode: 'KES',
  timeZone: 'Africa/Nairobi',
  fiscalYearEndMonth: 12,
  fiscalYearEndDay: 31,
);

TaxSummaryView _summary() => TaxSummaryView(
  entityId: UuidValue.fromString(_entityId),
  entityKind: EntityKind.individual,
  countryCode: 'KE',
  currencyCode: 'KES',
  startYear: TaxExportData.taxYear,
  yearLabel: '${TaxExportData.taxYear}',
  yearStart: DateTime.utc(TaxExportData.taxYear),
  yearEnd: DateTime.utc(TaxExportData.taxYear + 1),
  generatedAt: DateTime.utc(2026, 11, 13),
  isUniversal: true,
  rulesVerifiedOn: DateTime.utc(2026, 11, 13),
  disclaimerKey: 'taxSummaryDisclaimer',
  incomeTotals: const [],
  expenseTotals: const [],
  reliefTotals: const [],
  taxPaidTotals: const [],
  totalIncomeMinor: 120000000,
  totalExpenseMinor: 45000000,
  totalReliefMinor: 0,
  totalTaxPaidMinor: 8000000,
  salesTaxCollectedMinor: 0,
  salesTaxPaidMinor: 0,
  salesTaxByRate: const [],
  salesTaxByQuarter: const [],
  wallets: const [],
  fxNotes: const [],
  rateSourcesUsed: const [],
  uncategorizedCount: 0,
);

/// Answers the summary and export calls the universal panel makes, and
/// records the years it was asked for.
class _FakeTaxRepository implements TaxRepository {
  final List<int?> exportYears = [];

  @override
  Future<TaxProfileRecord?> getProfile(String entityId) async => null;

  @override
  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) => throw UnimplementedError();

  @override
  Future<List<TaxCategoryView>> listCategories(String entityId) async => [];

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) => throw UnimplementedError();

  @override
  Future<TransactionView> setLineTax({
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) => throw UnimplementedError();

  @override
  Future<TaxReportView> getReport(String entityId, int startYear) =>
      throw UnimplementedError();

  /// A country with no rule pack has no calendar.
  @override
  Future<List<TaxDeadlineView>> listDeadlines(String entityId) async => [];

  @override
  Future<TaxSummaryView> getSummary(String entityId, {int? startYear}) async =>
      _summary();

  @override
  Future<String> createExportLink(String entityId, {int? startYear}) async {
    exportYears.add(startYear);
    return TaxExportData.exportLink;
  }
}

/// Records the links the app opens instead of leaving the app.
class _RecordingLauncher implements TaxUrlLauncher {
  final List<Uri> pages = [];
  final List<Uri> downloads = [];

  @override
  Future<bool> openPage(Uri url) async {
    pages.add(url);
    return true;
  }

  @override
  Future<bool> openDownload(Uri url) async {
    downloads.add(url);
    return true;
  }
}

Widget _buildApp(_FakeTaxRepository repository, _RecordingLauncher launcher) {
  final router = GoRouter(
    initialLocation: morePath.replaceFirst(':entityId', _entityId),
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) =>
            MoreScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: taxOverviewRoute,
        path: taxOverviewPath,
        builder: (context, state) =>
            TaxOverviewScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      taxUrlLauncherProvider.overrideWithValue(launcher),
      entityDetailProvider.overrideWith((ref, id) async => _kenyanEntity()),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      darkTheme: OpenBudgetTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  patrolWidgetTest(
    'a Kenyan entity sees the universal tax panel and exports its summary',
    ($) async {
      final tester = $.tester;
      final repository = _FakeTaxRepository();
      final launcher = _RecordingLauncher();
      await tester.pumpWidget(_buildApp(repository, launcher));
      await tester.pumpAndSettle();

      await tester.tap(MoreTabPage(tester).taxesTile);
      await tester.pumpAndSettle();

      // The panel replaces the "no tax rules" dead end and the profile setup.
      final panel = UniversalTaxPage(tester);
      expect(panel.introTitle, findsOneWidget);
      expect(find.text(TestData.taxSetupTitle), findsNothing);
      expect(panel.yearLabel, findsOneWidget);
      expect(find.text(TaxExportData.taxYearLabel), findsOneWidget);
      expect(panel.summaryHero, findsOneWidget);

      await scrollIntoView(tester, panel.ratesTitle);
      expect(panel.ratesTitle, findsOneWidget);
      expect(panel.standardRate, findsOneWidget);
      // The standard rate and the registration threshold both cite a
      // secondary source, so the badge shows on each.
      expect(panel.secondaryBadge, findsWidgets);
      expect(panel.authorityLink, findsOneWidget);

      // The export opens the signed link the server made.
      await panel.export();

      expect(repository.exportYears, [TaxExportData.taxYear]);
      expect(launcher.downloads, [Uri.parse(TaxExportData.exportLink)]);
      expect(panel.exportError, findsNothing);

      // And the authority link opens outside the app.
      await panel.openAuthority();
      expect(launcher.pages, [Uri.parse(TaxExportData.kenyaAuthorityUrl)]);
    },
  );
}
