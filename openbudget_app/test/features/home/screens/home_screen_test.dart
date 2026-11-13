import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

EntitySummaryView _summary({
  Entity? entity,
  int? readyToAssignMinor,
  int overspentEnvelopeCount = 0,
  int netWorthMinor = 0,
  int uncategorizedCount = 0,
  int dueRecurringCount = 0,
  int pendingProposalCount = 0,
  bool netWorthComplete = true,
}) => EntitySummaryView(
  entity: entity ?? testEntity(),
  month: 202611,
  readyToAssignMinor: readyToAssignMinor,
  overspentEnvelopeCount: overspentEnvelopeCount,
  netWorthMinor: netWorthMinor,
  netWorthComplete: netWorthComplete,
  uncategorizedCount: uncategorizedCount,
  pendingProposalCount: pendingProposalCount,
  dueRecurringCount: dueRecurringCount,
);

NetWorthView _netWorth({
  String currencyCode = 'USD',
  int assetsMinor = 1000000,
  int liabilitiesMinor = 0,
  bool isComplete = true,
  List<String> missingCurrencyCodes = const [],
}) => NetWorthView(
  currencyCode: currencyCode,
  asOf: DateTime.utc(2026, 11, 5),
  assetsMinor: assetsMinor,
  liabilitiesMinor: liabilitiesMinor,
  netWorthMinor: assetsMinor + liabilitiesMinor,
  isComplete: isComplete,
  missingCurrencyCodes: missingCurrencyCodes,
  hasStaleRates: false,
  currencies: const [],
  entities: const [],
  accounts: const [],
);

Widget _buildSubject({
  Object? summaries,
  NetWorthView? netWorth,
}) => ProviderScope(
  overrides: [
    if (summaries is Completer<List<EntitySummaryView>>)
      entitySummariesProvider.overrideWith((ref) => summaries.future)
    else if (summaries is Exception)
      entitySummariesProvider.overrideWith((ref) => throw summaries)
    else
      entitySummariesProvider.overrideWith(
        (ref) async =>
            summaries as List<EntitySummaryView>? ?? <EntitySummaryView>[],
      ),
    netWorthProvider.overrideWith((ref) async => netWorth ?? _netWorth()),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomeScreen(),
  ),
);

Finder _skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
  (widget) => widget is SkribbleIcon && widget.data == data,
);

void main() {
  group('HomeScreen', () {
    testWidgets('renders loading indicator while budgets load', (tester) async {
      final never = Completer<List<EntitySummaryView>>();
      await tester.pumpWidget(_buildSubject(summaries: never));
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      await tester.pumpWidget(
        _buildSubject(summaries: Exception('Network error')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load budgets'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('renders empty state when no budgets', (tester) async {
      await tester.pumpWidget(_buildSubject(summaries: <EntitySummaryView>[]));
      await tester.pumpAndSettle();

      expect(find.text('No Budgets Yet'), findsOneWidget);
      expect(find.text('Create Your First Budget'), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
    });

    testWidgets('does not show FAB in empty state', (tester) async {
      await tester.pumpWidget(_buildSubject(summaries: <EntitySummaryView>[]));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('renders budget card with name and currency', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [
            _summary(
              entity: testEntity(
                name: 'Family Budget',
                baseCurrencyCode: 'EUR',
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Family Budget'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('shows FAB when budgets exist', (tester) async {
      await tester.pumpWidget(
        _buildSubject(summaries: [_summary()]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders per-entity net worth on the budget card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(summaries: [_summary(netWorthMinor: 1250000)]),
      );
      await tester.pumpAndSettle();

      // The server's per-entity net worth renders straight on the card.
      expect(find.textContaining('Net worth'), findsOneWidget);
      expect(find.textContaining('12,500.00'), findsOneWidget);
    });

    testWidgets('renders ready-to-assign amount on budget card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [_summary(readyToAssignMinor: 200000)],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('to assign'), findsOneWidget);
    });

    testWidgets('renders overspent count when envelopes are overspent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(summaries: [_summary(overspentEnvelopeCount: 1)]),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 overspent'), findsOneWidget);
      expect(_skribbleIcon(OpenBudgetIcons.warning), findsOneWidget);
    });

    testWidgets('omits the overspent chip when nothing is overspent', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(summaries: [_summary()]));
      await tester.pumpAndSettle();

      expect(find.textContaining('overspent'), findsNothing);
      expect(_skribbleIcon(OpenBudgetIcons.warning), findsNothing);
    });

    testWidgets('flags an entity net worth that leaves out accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(summaries: [_summary(netWorthComplete: false)]),
      );
      await tester.pumpAndSettle();

      expect(_skribbleIcon(OpenBudgetIcons.warning), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Leaves out unconverted accounts')),
        findsOneWidget,
      );
    });

    testWidgets('renders net worth summary with assets and liabilities', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [_summary()],
          netWorth: _netWorth(liabilitiesMinor: -250000),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text(r'Assets $10,000.00'), findsOneWidget);
      expect(find.text(r'Liabilities -$2,500.00'), findsOneWidget);
    });

    testWidgets('renders every entity card with its base currency', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [
            _summary(
              entity: testEntity(name: 'Personal', baseCurrencyCode: 'USD'),
            ),
            _summary(entity: testEntity(name: 'Business')),
          ],
          // The combined card is EUR, so each entity's chip is unique.
          netWorth: _netWorth(currencyCode: 'EUR'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('GBP'), findsOneWidget);
    });

    testWidgets('renders the reporting currency on the net worth card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [_summary()],
          netWorth: _netWorth(currencyCode: 'GBP', assetsMinor: 100000),
        ),
      );
      await tester.pumpAndSettle();

      // The server reports in the user's reporting currency; the card
      // shows those figures and its chip.
      expect(find.text('GBP'), findsWidgets);
      expect(find.textContaining('£1,000.00'), findsWidgets);
    });

    testWidgets('warns when a currency has no rate', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [_summary()],
          netWorth: _netWorth(
            isComplete: false,
            missingCurrencyCodes: ['EUR'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Not included'), findsOneWidget);
      expect(find.textContaining('EUR'), findsWidgets);
    });

    testWidgets('renders logout button in app bar', (tester) async {
      await tester.pumpWidget(_buildSubject(summaries: <EntitySummaryView>[]));
      await tester.pumpAndSettle();

      expect(_skribbleIcon(OpenBudgetIcons.logout), findsOneWidget);
      expect(find.byTooltip('Sign Out'), findsOneWidget);
    });

    testWidgets('renders app title in app bar', (tester) async {
      await tester.pumpWidget(_buildSubject(summaries: <EntitySummaryView>[]));
      await tester.pumpAndSettle();

      expect(find.text('OpenBudget'), findsOneWidget);
    });

    testWidgets('renders uncategorised, recurring and proposal chips', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          summaries: [
            _summary(
              uncategorizedCount: 3,
              dueRecurringCount: 2,
              pendingProposalCount: 1,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 uncategorised'), findsOneWidget);
      expect(find.text('2 recurring due'), findsOneWidget);
      expect(find.text('1 proposals'), findsOneWidget);
    });
  });
}
