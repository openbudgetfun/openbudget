import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes_parser.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/screens/whats_new_sheet.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../whats_new_test_helpers.dart';

WhatsNewNotesResult _availableNotes() {
  final parsed = parseReleaseNotes(loadReleaseNotesFixture());
  final notes = switch (parsed) {
    ReleaseNotesParseSuccess(:final notes) => notes,
    ReleaseNotesParseFailure(:final message) => fail(message),
  };
  return WhatsNewNotesResult.available(
    version: fixtureNotesVersion,
    notes: notes,
  );
}

class _SheetHost extends HookWidget {
  const _SheetHost({required this.result});

  final WhatsNewNotesResult result;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => showWhatsNewSheet(context, result: result),
        child: const Text('Open sheet'),
      ),
    ),
  );
}

Future<InMemoryUiPreferencesStore> _openSheet(
  WidgetTester tester,
  WhatsNewNotesResult result,
) async {
  final store = InMemoryUiPreferencesStore();
  final container = ProviderContainer(
    overrides: [uiPreferencesStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);

  await tester.pumpApp(
    _SheetHost(result: result),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.tap(find.text('Open sheet'));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  group('WhatsNewSheet', () {
    testWidgets('renders every section and entry', (tester) async {
      await _openSheet(tester, _availableNotes());

      expect(find.byType(WhatsNewSheet), findsOneWidget);
      expect(find.text('Version 2.4.0'), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(
        find.text('See what changed after each update'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Every update.', findRichText: true),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Improved'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Improved'), findsOneWidget);
      expect(find.text('Envelope notes read better'), findsOneWidget);
    });

    testWidgets('Got it closes the sheet and records the version', (
      tester,
    ) async {
      final store = await _openSheet(tester, _availableNotes());

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsNothing);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        fixtureNotesVersion,
      );
    });

    testWidgets('shows an empty state when the version has no notes', (
      tester,
    ) async {
      final store = await _openSheet(
        tester,
        const WhatsNewNotesResult.notFound(version: fixtureNotesVersion),
      );

      expect(find.text('Nothing new to read'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.byType(WhatsNewSheet), findsNothing);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        isNull,
      );
    });

    testWidgets('shows a problem state for a malformed file', (tester) async {
      await _openSheet(
        tester,
        const WhatsNewNotesResult.invalid(
          version: fixtureNotesVersion,
          message: 'Broken',
        ),
      );

      expect(find.text("We couldn't read these notes"), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
    });
  });
}
