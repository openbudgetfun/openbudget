import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

const _budgetId = 'test-budget-id';

void main() {
  testWidgets('settings shows the installed app version', (tester) async {
    final container = ProviderContainer(
      overrides: [
        budgetDetailProvider.overrideWith(
          (ref, budgetId) async => Budget(
            name: 'My Budget',
            currencyCode: 'USD',
            ownerId: UuidValue.fromString(
              '00000000-0000-0000-0000-000000000402',
            ),
          ),
        ),
        uiPreferencesStoreProvider.overrideWithValue(
          InMemoryUiPreferencesStore(),
        ),
        appVersionProvider.overrideWith((ref) async => '1.4.2'),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpApp(
      const SettingsScreen(budgetId: _budgetId),
      container: container,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
    await tester.pumpAndSettle();

    final version = find.text('App Version 1.4.2');
    await tester.scrollUntilVisible(
      version,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(version, findsOneWidget);
  });
}
