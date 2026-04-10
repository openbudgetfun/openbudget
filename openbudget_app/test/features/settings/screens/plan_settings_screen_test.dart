// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/plan_settings_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000001');

Budget _makeBudget({
  String name = 'OpenBudget Plan',
  String currencyCode = 'USD',
}) => Budget(name: name, currencyCode: currencyCode, ownerId: _ownerUuid);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PlanSettingsScreen', () {
    testWidgets('renders budget details and option rows', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(name: "Sam's Plan"),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PlanSettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plan Settings'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text("Sam's Plan"), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Number Format'), findsOneWidget);
      expect(find.text('Currency Placement'), findsOneWidget);
      expect(find.text('Date Format'), findsOneWidget);
      expect(find.text('Delete Plan'), findsOneWidget);
    });
  });
}
