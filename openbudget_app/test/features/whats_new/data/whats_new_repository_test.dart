import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';

import '../whats_new_test_helpers.dart';

void main() {
  group('WhatsNewRepository', () {
    test('loads the notes file for the requested version', () async {
      final repository = WhatsNewRepository(
        bundle: FakeAssetBundle({
          releaseNotesAssetPath(fixtureNotesVersion): loadReleaseNotesFixture(),
        }),
      );

      final result = await repository.loadForVersion(fixtureNotesVersion);

      final notes = switch (result) {
        WhatsNewNotesAvailable(:final notes) => notes,
        WhatsNewNotesNotFound() => fail('Expected the notes to be found'),
        WhatsNewNotesInvalid(:final message) => fail(message),
      };
      expect(notes.sections, hasLength(2));
    });

    test('returns not found when the version has no file', () async {
      final repository = WhatsNewRepository(
        bundle: FakeAssetBundle(<String, String>{}),
      );

      final result = await repository.loadForVersion(fixtureNotesVersion);

      expect(result, isA<WhatsNewNotesNotFound>());
      expect(
        switch (result) {
          WhatsNewNotesNotFound(:final version) => version,
          _ => null,
        },
        fixtureNotesVersion,
      );
    });

    test('returns invalid when the file is malformed', () async {
      final repository = WhatsNewRepository(
        bundle: FakeAssetBundle({
          releaseNotesAssetPath(fixtureNotesVersion): '{not json',
        }),
      );

      final result = await repository.loadForVersion(fixtureNotesVersion);

      expect(result, isA<WhatsNewNotesInvalid>());
    });

    test(
      'normalizes a v prefix and a build suffix for the asset path',
      () async {
        final repository = WhatsNewRepository(
          bundle: FakeAssetBundle({
            releaseNotesAssetPath(fixtureNotesVersion):
                loadReleaseNotesFixture(),
          }),
        );

        final result = await repository.loadForVersion('v2.4.0+42');

        expect(result, isA<WhatsNewNotesAvailable>());
      },
    );
  });
}
