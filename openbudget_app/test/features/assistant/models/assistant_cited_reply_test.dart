import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_cited_reply.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_source.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../support/fake_assistant_api.dart';

AssistantSource _source(String key, {String? title, String? url}) =>
    assistantSourceFrom(
      testCitation(
        key,
        title: title ?? 'Title of $key',
        url: url ?? 'https://www.gov.uk/$key',
      ),
    );

List<Object> _shape(AssistantCitedReply reply) => [
  for (final segment in reply.segments)
    switch (segment) {
      AssistantReplyText(:final text) => text,
      AssistantReplyCitation(:final number) => number,
    },
];

void main() {
  group('parseCitedReply', () {
    test('numbers keys in order of first appearance', () {
      final reply = parseCitedReply(
        'The allowance is £3,000[^b]. The rate is 18%[^a].',
        [_source('a'), _source('b')],
      );

      expect(_shape(reply), [
        'The allowance is £3,000',
        1,
        '. The rate is 18%',
        2,
        '.',
      ]);
      expect(
        reply.segments.whereType<AssistantReplyCitation>().map((c) => c.key),
        ['b', 'a'],
      );
      expect(
        [for (final entry in reply.sources) (entry.number, entry.source.key)],
        [(1, 'b'), (2, 'a')],
      );
      expect(reply.citationCount, 2);
    });

    test('reuses the number when a key is cited again', () {
      final reply = parseCitedReply('One[^a] two[^b] three[^a].', [
        _source('a'),
        _source('b'),
      ]);

      expect(_shape(reply), ['One', 1, ' two', 2, ' three', 1, '.']);
      expect(reply.sources.map((entry) => entry.number), [1, 2]);
    });

    test('gives every source of one key the same number', () {
      final reply = parseCitedReply('Cited[^card].', [
        _source('card', url: 'https://www.gov.uk/one'),
        _source('card', url: 'https://www.legislation.gov.uk/two'),
      ]);

      expect(reply.sources.map((entry) => entry.number), [1, 1]);
      expect(reply.citationCount, 1);
    });

    test('drops a marker whose key has no source', () {
      final reply = parseCitedReply('Known[^a], unknown[^gone].', [
        _source('a'),
      ]);

      expect(_shape(reply), ['Known', 1, ', unknown.']);
    });

    test('lists a source the text never cites after the cited ones', () {
      final reply = parseCitedReply('Only[^a].', [
        _source('extra'),
        _source('a'),
      ]);

      expect(
        [for (final entry in reply.sources) (entry.number, entry.source.key)],
        [(1, 'a'), (2, 'extra')],
      );
    });

    test('leaves a reply without markers as one run of text', () {
      final reply = parseCitedReply('Move £40 to Groceries.', const []);

      expect(_shape(reply), ['Move £40 to Groceries.']);
      expect(reply.hasSources, isFalse);
    });

    test('carries the first source title for the spoken label', () {
      final reply = parseCitedReply('Cited[^a].', [
        _source('a', title: 'HMRC manual'),
      ]);

      expect(
        reply.segments.whereType<AssistantReplyCitation>().single.title,
        'HMRC manual',
      );
    });
  });

  group('assistantSourcesFromJson', () {
    test('reads the stored citations with their grades', () {
      final json = jsonEncode([
        testCitation('a', grade: 'secondary', announced: true).toJson(),
        testCitation('b', grade: 'inferred').toJson(),
        testCitation('c', grade: 'something-new').toJson(),
      ]);

      final sources = assistantSourcesFromJson(json);

      expect(sources.map((source) => source.grade), [
        SourceGrade.secondary,
        SourceGrade.inferred,
        null,
      ]);
      expect(sources.first.announced, isTrue);
      expect(sources.first.verifiedOn, DateTime.utc(2026, 11, 2));
    });

    test('has no sources for a message stored without citations', () {
      expect(assistantSourcesFromJson(null), isEmpty);
    });

    test('rejects JSON that is not a list of citations', () {
      expect(
        () => assistantSourcesFromJson('{"key": "a"}'),
        throwsFormatException,
      );
    });
  });
}
