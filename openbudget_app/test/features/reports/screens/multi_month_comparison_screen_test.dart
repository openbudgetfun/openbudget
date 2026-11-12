import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/multi_month_comparison_screen.dart';
import 'package:openbudget_app/src/features/reports/utils/report_group_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const String _entityId = fixtureEntityId;

void main() {
  group('reportGroupLabel', () {
    test('translates the uncategorised bucket and leaves real names', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(reportGroupLabel(l10n, reportUncategorisedGroup), 'Uncategorised');
      expect(reportGroupLabel(l10n, reportUnknownPayeeGroup), 'Unknown payee');
      expect(reportGroupLabel(l10n, 'Groceries'), 'Groceries');
    });
  });

  group('MultiMonthComparisonScreen', () {
    testWidgets('renders the uncategorised row under the month totals', (
      tester,
    ) async {
      final comparison = MultiMonthComparison(
        currencyCode: 'GBP',
        months: const [
          MonthColumn(month: 202610, totalActivityMinor: 90000),
          MonthColumn(month: 202611, totalActivityMinor: 25000),
        ],
        categories: [
          CategoryComparison(
            category: testCategory(),
            envelopes: const [],
            monthlyActivityMinor: const {202610: -10000, 202611: -5000},
          ),
        ],
        uncategorisedMonthlyActivityMinor: const {
          202610: 100000,
          202611: 30000,
        },
      );
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          multiMonthComparisonProvider.overrideWith(
            (ref, args) async => comparison,
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MultiMonthComparisonScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Uncategorised'), findsOneWidget);
      expect(find.text(reportUncategorisedGroup), findsNothing);
      // The row shows its own amount for each month.
      expect(find.text('£1,000.00'), findsOneWidget);
      expect(find.text('£300.00'), findsOneWidget);
    });
  });
}
