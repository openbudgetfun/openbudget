import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_overview_screen.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_profile_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;

/// The entity drives the jurisdiction and kind; the profile screen reads
/// both from it.
Entity _gbEntity() => TestData.gbpEntity();

TaxReportView _makeReport(int startYear) => TaxReportView(
  jurisdiction: 'GB',
  startYear: startYear,
  yearLabel: '$startYear/${(startYear + 1) % 100}',
  yearStart: DateTime.utc(startYear, 4, 6),
  yearEnd: DateTime.utc(startYear + 1, 4, 6),
  entityKind: EntityKind.individual,
  currencyCode: 'GBP',
  lines: [
    TaxReportLineView(
      label: 'Employment income',
      amountMinor: 4200000,
      code: 'gb.ind.employment',
      reportReference: 'SA100 box 1',
      entryCount: 12,
    ),
  ],
  liabilities: [
    TaxLiabilityView(
      label: 'Income tax',
      amountMinor: 748000,
      bands: [
        TaxBandSliceView(
          label: 'Basic rate',
          baseMinor: 3770000,
          rateBasisPoints: 2000,
          taxMinor: 754000,
        ),
      ],
    ),
  ],
  totalLiabilityMinor: 748000,
  alreadyPaidMinor: 0,
  balanceDueMinor: 748000,
  assumptions: const ['No other income outside OpenBudget.'],
  sources: const ['https://www.gov.uk/income-tax-rates'],
  rulesVerifiedOn: DateTime.utc(2026, 4),
  rulesVersion: 'gb-$startYear-r1',
  maturity: 'preview',
  coverage: const {'personalReturn': 'full'},
  uncategorizedCount: 0,
  convertedEntryCount: 0,
  opportunities: const [],
);

class _FakeTaxRepository implements TaxRepository {
  TaxProfileRecord? profile;
  final List<
    ({
      String entityId,
      String jurisdiction,
      String entityKind,
      String profileJson,
    })
  >
  savedProfiles = [];

  @override
  Future<TaxProfileRecord?> getProfile(String entityId) async => profile;

  @override
  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) async {
    savedProfiles.add((
      entityId: entityId,
      jurisdiction: jurisdiction,
      entityKind: entityKind,
      profileJson: profileJson,
    ));
    final record = TaxProfileRecord(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000703'),
      entityId: UuidValue.fromString(entityId),
      profileJson: profileJson,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 7),
    );
    profile = record;
    return record;
  }

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
  Future<TaxReportView> getReport(String entityId, int startYear) async =>
      _makeReport(startYear);
}

Widget _buildApp(_FakeTaxRepository repository) {
  final router = GoRouter(
    initialLocation: morePath.replaceFirst(':entityId', _entityId),
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) => MoreScreen(
          entityId: state.pathParameters['entityId']!,
        ),
      ),
      GoRoute(
        name: taxOverviewRoute,
        path: taxOverviewPath,
        builder: (context, state) => TaxOverviewScreen(
          entityId: state.pathParameters['entityId']!,
        ),
        routes: [
          GoRoute(
            name: taxProfileRoute,
            path: 'profile',
            builder: (context, state) => TaxProfileScreen(
              entityId: state.pathParameters['entityId']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      taxRepositoryProvider.overrideWithValue(repository),
      entityDetailProvider.overrideWith((ref, id) async => _gbEntity()),
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
    'opens taxes from More, sets up a UK individual, and sees the report',
    ($) async {
      final tester = $.tester;
      final repository = _FakeTaxRepository();
      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      final more = MoreTabPage(tester);
      await tester.tap(more.taxesTile);
      await tester.pumpAndSettle();

      final overview = TaxOverviewPage(tester);
      expect(overview.title, findsOneWidget);
      expect(find.text(TestData.taxSetupTitle), findsWidgets);

      await tester.tap(overview.setupButton);
      await tester.pumpAndSettle();

      final profile = TaxProfilePage(tester);
      expect(find.text(TestData.taxProfileTitle), findsOneWidget);
      expect(find.text('United Kingdom'), findsWidgets);
      expect(find.text('Individual'), findsOneWidget);

      await tester.tap(profile.scottishTaxpayerToggle);
      await tester.pumpAndSettle();
      await profile.save();

      expect(repository.savedProfiles, hasLength(1));
      expect(repository.savedProfiles.single.entityId, _entityId);
      expect(repository.savedProfiles.single.jurisdiction, 'GB');
      expect(repository.savedProfiles.single.entityKind, 'individual');
      expect(
        repository.savedProfiles.single.profileJson,
        contains('"scottishTaxpayer":true'),
      );

      expect(overview.yearLabel, findsOneWidget);
      expect(find.text(TestData.taxYearLabel), findsOneWidget);
      expect(find.text(TestData.taxBalanceDue), findsOneWidget);
      expect(find.text('Income tax'), findsOneWidget);
      expect(find.text(TestData.taxDisclaimer), findsOneWidget);
    },
  );
}
