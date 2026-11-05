import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';

import '../whats_new_test_helpers.dart';

ProviderContainer _buildContainer({
  required InMemoryUiPreferencesStore store,
  required AssetBundle bundle,
  String version = fixtureNotesVersion,
}) {
  final container = ProviderContainer(
    overrides: [
      uiPreferencesStoreProvider.overrideWithValue(store),
      appVersionProvider.overrideWith((ref) async => version),
      whatsNewAssetBundleProvider.overrideWithValue(bundle),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

FakeAssetBundle _bundleWithNotes() => FakeAssetBundle({
  releaseNotesAssetPath(fixtureNotesVersion): loadReleaseNotesFixture(),
});

void main() {
  group('WhatsNew providers', () {
    test('current notes load from the app version', () async {
      final container = _buildContainer(
        store: InMemoryUiPreferencesStore(),
        bundle: _bundleWithNotes(),
      );

      final result = await container.read(whatsNewCurrentNotesProvider.future);

      final available = switch (result) {
        WhatsNewNotesAvailable(:final version, :final notes) => (
          version,
          notes,
        ),
        WhatsNewNotesNotFound() => fail('Expected notes for the app version'),
        WhatsNewNotesInvalid(:final message) => fail(message),
      };
      expect(available.$1, fixtureNotesVersion);
      expect(available.$2.sections, hasLength(2));
    });

    test('first launch stores the version without opening notes', () async {
      final store = InMemoryUiPreferencesStore();
      final container = _buildContainer(
        store: store,
        bundle: _bundleWithNotes(),
      );

      final prompt = await container.read(whatsNewAutoPromptProvider.future);

      expect(prompt, isNull);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        fixtureNotesVersion,
      );
    });

    test('an update opens notes once and then records the version', () async {
      final store = InMemoryUiPreferencesStore();
      await store.writeString(
        key: WhatsNewPreferenceKeys.lastSeenVersion,
        value: '2.3.0',
      );
      final container = _buildContainer(
        store: store,
        bundle: _bundleWithNotes(),
      );

      final prompt = await container.read(whatsNewAutoPromptProvider.future);

      expect(prompt, isA<WhatsNewNotesAvailable>());
      expect(
        switch (prompt) {
          WhatsNewNotesAvailable(:final notes) => notes.sections.first.title,
          _ => null,
        },
        'New',
      );

      await container
          .read(whatsNewSeenVersionProvider.notifier)
          .markSeen(fixtureNotesVersion);
      container.invalidate(whatsNewAutoPromptProvider);

      expect(
        await container.read(whatsNewAutoPromptProvider.future),
        isNull,
      );
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        fixtureNotesVersion,
      );
    });

    test('a missing notes file is recorded without opening a sheet', () async {
      final store = InMemoryUiPreferencesStore();
      await store.writeString(
        key: WhatsNewPreferenceKeys.lastSeenVersion,
        value: '2.3.0',
      );
      final container = _buildContainer(
        store: store,
        bundle: FakeAssetBundle(<String, String>{}),
      );

      final prompt = await container.read(whatsNewAutoPromptProvider.future);

      expect(prompt, isNull);
      expect(
        store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
        fixtureNotesVersion,
      );
    });

    test(
      'a malformed notes file is recorded without opening a sheet',
      () async {
        final store = InMemoryUiPreferencesStore();
        await store.writeString(
          key: WhatsNewPreferenceKeys.lastSeenVersion,
          value: '2.3.0',
        );
        final container = _buildContainer(
          store: store,
          bundle: FakeAssetBundle({
            releaseNotesAssetPath(fixtureNotesVersion): '{not json',
          }),
        );

        final prompt = await container.read(whatsNewAutoPromptProvider.future);

        expect(prompt, isNull);
        expect(
          store.readString(WhatsNewPreferenceKeys.lastSeenVersion),
          fixtureNotesVersion,
        );
      },
    );
  });
}
