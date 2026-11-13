import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/tax/screens/tax_overview_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../tax_test_data.dart';

Widget _buildApp(
  FakeTaxRepository repository, {
  Future<TaxProfileRecord?> Function(Ref ref, String entityId)? profileBuilder,
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
      entityDetailProvider.overrideWith((ref, entityId) async => testEntity()),
      entityListProvider.overrideWith((ref) async => [testEntity()]),
      if (profileBuilder != null)
        taxProfileProvider.overrideWith(profileBuilder),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('TaxOverviewScreen', () {
    testWidgets('shows a loading panel while the profile loads', (
      tester,
    ) async {
      final completer = Completer<TaxProfileRecord?>();
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(),
          profileBuilder: (ref, entityId) => completer.future,
        ),
      );
      await tester.pump();

      expect(find.text('Loading your tax report'), findsOneWidget);
    });

    testWidgets('invites the person to set up taxes when no profile exists', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(FakeTaxRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Set up taxes'), findsWidgets);
      expect(find.textContaining('Choose your country'), findsOneWidget);

      await tester.tap(find.text('Set up taxes').last);
      await tester.pumpAndSettle();

      expect(find.text('Profile stub'), findsOneWidget);
    });

    testWidgets('shows a problem panel when the profile fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(FakeTaxRepository(profileError: Exception('server down'))),
      );
      await tester.pumpAndSettle();

      expect(find.text("We couldn't load your tax profile."), findsWidgets);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('renders the balance, lines, opportunities, and disclaimer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            defaultReport: taxReportView(uncategorizedCount: 3),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tax year 2026'), findsOneWidget);
      expect(find.text('Balance due'), findsOneWidget);
      expect(find.text('£7,480.00'), findsWidgets);
      await tester.scrollUntilVisible(find.text('£42,000.00'), 120);
      expect(find.text('£42,000.00'), findsOneWidget);
      expect(find.text('SA100 box 1'), findsOneWidget);
      expect(find.text('Uncategorized: 3'), findsOneWidget);
      expect(
        find.text(
          'Guidance only, not tax advice. Check figures with a qualified '
          'adviser before filing.',
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Use your pension annual allowance'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Use your pension annual allowance'), findsOneWidget);
      expect(find.text('Estimated saving £1,200.00'), findsOneWidget);
    });

    testWidgets('warns that preview figures are not professionally checked', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            defaultReport: taxReportView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tax-preview-banner')), findsOneWidget);
      expect(
        find.text(
          'Preview: these figures have not yet been checked by a tax '
          'professional.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides the preview banner once a pack is reviewed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            defaultReport: taxReportView(maturity: 'reviewed'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tax-preview-banner')), findsNothing);
    });

    testWidgets('uses refund wording when the year is in credit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            defaultReport: refundTaxReport(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Refund due'), findsOneWidget);
      expect(find.text('£1,500.00'), findsOneWidget);
      expect(find.text('Balance due'), findsNothing);
    });

    testWidgets('expands a liability to show its rate bands', (tester) async {
      await tester.pumpWidget(
        _buildApp(FakeTaxRepository(profile: taxProfileRecord())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Basic rate'), findsNothing);

      await tester.tap(find.text('Income tax'));
      await tester.pumpAndSettle();

      expect(find.text('Basic rate'), findsOneWidget);
      expect(find.text('20%'), findsOneWidget);
      expect(find.text('£37,700.00'), findsOneWidget);
      expect(find.text('£7,540.00'), findsOneWidget);
    });

    testWidgets('moves to the previous tax year', (tester) async {
      final fake = FakeTaxRepository(
        profile: taxProfileRecord(),
        reports: {
          2026: taxReportView(),
          2025: taxReportView(
            startYear: 2025,
            yearLabel: '2025/26',
            balanceDueMinor: 0,
            totalLiabilityMinor: 0,
          ),
        },
      );
      await tester.pumpWidget(_buildApp(fake));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tax-year-previous')));
      await tester.pumpAndSettle();

      expect(find.text('Tax year 2025'), findsOneWidget);
      expect(find.text('Nothing to pay'), findsOneWidget);
      expect(
        fake.reportCalls.map((call) => call.startYear),
        containsAll([2026, 2025]),
      );
    });

    testWidgets('explains that a year has no rates', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            reportError: TaxRulesUnavailableException(
              message: 'No GB tax rates for 2030.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No rates for this year'), findsOneWidget);
      expect(find.textContaining("doesn't have the tax rates"), findsOneWidget);
    });

    testWidgets('sends uncategorised entries to the transaction list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(
          FakeTaxRepository(
            profile: taxProfileRecord(),
            defaultReport: taxReportView(uncategorizedCount: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('tax-uncategorized-chip')));
      await tester.pumpAndSettle();

      expect(find.text('Transactions stub'), findsOneWidget);
    });

    testWidgets('reveals assumptions and sources in the workings section', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildApp(FakeTaxRepository(profile: taxProfileRecord())),
      );
      await tester.pumpAndSettle();

      expect(find.text('No other income outside OpenBudget.'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('How this was worked out'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('How this was worked out'));
      await tester.pumpAndSettle();

      expect(find.text('No other income outside OpenBudget.'), findsOneWidget);
      expect(find.text('https://www.gov.uk/income-tax-rates'), findsOneWidget);
    });
  });
}
