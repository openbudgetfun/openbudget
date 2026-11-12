import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../../../fixtures/budget_month.dart';

const _entityId = 'test-budget-id';

void main() {
  testWidgets('settings shows the installed app version', (tester) async {
    final container = ProviderContainer(
      overrides: [
        entityDetailProvider.overrideWith(
          (ref, entityId) async => testEntity(baseCurrencyCode: 'USD'),
        ),
        uiPreferencesStoreProvider.overrideWithValue(
          InMemoryUiPreferencesStore(),
        ),
        appVersionProvider.overrideWith((ref) async => '1.4.2'),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpApp(
      const SettingsScreen(entityId: _entityId),
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
