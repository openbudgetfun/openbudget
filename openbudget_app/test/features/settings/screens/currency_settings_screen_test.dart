// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/currency_settings_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _entityId = 'test-budget-id';
Entity _makeBudget({String name = "Sam's Plan", String currencyCode = 'USD'}) =>
    testEntity(name: name, baseCurrencyCode: currencyCode);

UserSettings _settings(String currencyCode) => UserSettings(
  userId: UuidValue.fromString(fixtureOwnerId),
  reportingCurrencyCode: currencyCode,
);

Widget _buildSubject({String currencyCode = 'USD'}) => ProviderScope(
  overrides: [
    entityDetailProvider.overrideWith((ref, entityId) async => _makeBudget()),
    userSettingsProvider.overrideWith((ref) async => _settings(currencyCode)),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const CurrencySettingsScreen(entityId: _entityId),
  ),
);

void main() {
  group('CurrencySettingsScreen', () {
    testWidgets('renders currency, number format, and placement rows', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Currency'), findsWidgets);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Currency Placement'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Currency Placement'), findsOneWidget);
    });

    testWidgets('opens currency picker modal', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      // The tile is labelled with the entity's base currency at first.
      await tester.scrollUntilVisible(
        find.text('Reporting currency'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Reporting currency'));
      await tester.pumpAndSettle();

      expect(find.textContaining('(USD)'), findsWidgets);
    });
  });
}
