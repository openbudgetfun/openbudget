import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/screens/whats_new_sheet.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../whats_new/whats_new_test_helpers.dart';

const _entityId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000401',
);

Budget _makeBudget() => Budget(
  name: 'My Budget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
);

void main() {
  group("Settings What's new row", () {
    testWidgets('opens the sheet and shows the empty state without notes', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith(
            (ref, entityId) async => _makeBudget(),
          ),
          uiPreferencesStoreProvider.overrideWithValue(
            InMemoryUiPreferencesStore(),
          ),
          appVersionProvider.overrideWith((ref) async => fixtureNotesVersion),
          whatsNewAssetBundleProvider.overrideWithValue(
            FakeAssetBundle(<String, String>{}),
          ),
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

      final whatsNewRow = find.text("What's new");
      await tester.scrollUntilVisible(
        whatsNewRow,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(whatsNewRow);
      await tester.pumpAndSettle();
      await tester.tap(whatsNewRow);
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('Nothing new to read'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('opens the sheet with notes for the current version', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith(
            (ref, entityId) async => _makeBudget(),
          ),
          uiPreferencesStoreProvider.overrideWithValue(
            InMemoryUiPreferencesStore(),
          ),
          appVersionProvider.overrideWith((ref) async => fixtureNotesVersion),
          whatsNewAssetBundleProvider.overrideWithValue(
            FakeAssetBundle({
              releaseNotesAssetPath(fixtureNotesVersion):
                  loadReleaseNotesFixture(),
            }),
          ),
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

      final whatsNewRow = find.text("What's new");
      await tester.scrollUntilVisible(
        whatsNewRow,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(whatsNewRow);
      await tester.pumpAndSettle();
      await tester.tap(whatsNewRow);
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('See what changed after each update'), findsOneWidget);
    });
  });
}
