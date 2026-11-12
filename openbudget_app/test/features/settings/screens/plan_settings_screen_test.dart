// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/plan_settings_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _entityId = 'test-budget-id';
Entity _makeBudget({
  String name = 'OpenBudget Plan',
  String currencyCode = 'USD',
}) => testEntity(name: name, baseCurrencyCode: currencyCode);

void main() {
  group('PlanSettingsScreen', () {
    testWidgets('renders budget details and option rows', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            entityDetailProvider.overrideWith(
              (ref, entityId) async => _makeBudget(name: "Sam's Plan"),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PlanSettingsScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Plan Settings'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text("Sam's Plan"), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      // The delete action sits at the bottom of the scrollable form.
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      expect(find.text('Delete Plan'), findsOneWidget);
    });
  });
}
