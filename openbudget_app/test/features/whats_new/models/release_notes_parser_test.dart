import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes_parser.dart';

import '../whats_new_test_helpers.dart';

void main() {
  group('parseReleaseNotes', () {
    test('reads the title, sections, and entries', () {
      final result = parseReleaseNotes(loadReleaseNotesFixture());

      final notes = switch (result) {
        ReleaseNotesParseSuccess(:final notes) => notes,
        ReleaseNotesParseFailure(:final message) => fail(message),
      };

      expect(notes.title, contains('2.4.0'));
      expect(notes.summary, hasLength(1));
      expect(notes.sections, hasLength(2));

      final newSection = notes.sections.first;
      expect(newSection.title, 'New');
      expect(newSection.collapsed, isFalse);
      expect(newSection.entries, hasLength(1));

      final entry = newSection.entries.first;
      expect(entry.summary, 'See what changed after each update');
      expect(entry.changeType, 'user_feat');
      expect(entry.detailsMarkdown, contains('OpenBudget now opens'));
      expect(entry.detailsMarkdown, contains('- **Every update.**'));
    });

    test('ignores unknown fields and fields the app does not display', () {
      final result = parseReleaseNotes(
        '''
        {
          "title": "2.4.0",
          "summary": [],
          "sections": [
            {
              "title": "New",
              "collapsed": false,
              "entries": [
                {
                  "summary": "A change",
                  "details_markdown": "Words.",
                  "change_type": "user_feat",
                  "packages": [{"name": "openbudget_app"}],
                  "provenance": {"source_path": ".changeset/a.md"},
                  "a_future_field": [1, 2, 3]
                }
              ],
              "another_future_field": true
            }
          ],
          "root_future_field": {"nested": true}
        }
        ''',
      );

      expect(result, isA<ReleaseNotesParseSuccess>());
    });

    test('returns a failure for malformed JSON', () {
      final result = parseReleaseNotes('{not json');

      expect(result, isA<ReleaseNotesParseFailure>());
    });

    test('returns a failure when a value has the wrong type', () {
      final result = parseReleaseNotes(
        '{"title": 4, "sections": [{"title": "New", "entries": []}]}',
      );

      expect(result, isA<ReleaseNotesParseFailure>());
    });

    test('returns a failure when the root is not an object', () {
      final result = parseReleaseNotes('["a list"]');

      expect(result, isA<ReleaseNotesParseFailure>());
    });
  });
}
