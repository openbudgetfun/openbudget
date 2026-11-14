import 'dart:convert';

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/context_budget.dart';
import 'package:openbudget_server/src/money_guide/money_guide_prompt.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

final UuidValue _conversationId = UuidValue.fromString(
  '90000000-0000-4000-a000-000000000001',
);
final DateTime _storedAt = DateTime.utc(2026, 11, 14);

/// A fixed overhead of a call, standing in for the static rules and tools.
const int _fixedTokens = 6500;

AgentMessage _message(
  AgentMessageRole role,
  String content, {
  String? toolCallsJson,
  String? toolCallId,
}) => AgentMessage(
  conversationId: _conversationId,
  role: role,
  content: content,
  toolCallsJson: toolCallsJson,
  toolCallId: toolCallId,
  createdAt: _storedAt,
);

/// A knowledge-card result, padded to about [tokens] estimated tokens.
String _cardResult(String citeAs, {required int tokens}) => jsonEncode({
  'cards': [
    {
      'id': citeAs,
      'citeAs': citeAs,
      'sources': [
        {'title': 'Source of $citeAs', 'url': 'https://example.org/$citeAs'},
      ],
      'body': 'x' * (tokens * 4),
    },
  ],
});

/// The assistant asking for a tool, and the tool's [result].
List<AgentMessage> _toolRound(String callId, String result) => [
  _message(
    AgentMessageRole.assistant,
    '',
    toolCallsJson: jsonEncode([
      {
        'id': callId,
        'type': 'function',
        'function': {'name': 'search_knowledge', 'arguments': '{}'},
      },
    ]),
  ),
  _message(AgentMessageRole.tool, result, toolCallId: callId),
];

/// One turn: the question, the assistant's tool request, and the result.
List<AgentMessage> _turn(int turn, {required String result}) => [
  _message(AgentMessageRole.user, 'Question $turn?'),
  ..._toolRound('call_$turn', result),
];

/// The turn's closing reply, which a finished turn has.
AgentMessage _reply(int turn) =>
    _message(AgentMessageRole.assistant, 'Answer $turn.');

/// [count] finished turns, each with a tool result of [resultTokens].
List<AgentMessage> _conversation(int count, {required int resultTokens}) => [
  for (var turn = 0; turn < count; turn++) ...[
    ..._turn(turn, result: _cardResult('card-$turn', tokens: resultTokens)),
    _reply(turn),
  ],
];

/// One turn that fetches three results of 12,000 tokens, about 36,000 in all.
List<AgentMessage> _turnWithThreeLargeResults() => [
  _message(AgentMessageRole.user, 'Show everything.'),
  for (var index = 0; index < 3; index++)
    ..._toolRound('call_$index', _cardResult('card-$index', tokens: 12000)),
];

String _toolContent(Map<String, Object?> message) =>
    message['content']! as String;

bool _isElided(Map<String, Object?> message) =>
    message['role'] == 'tool' &&
    (jsonDecode(_toolContent(message)) as Map<String, Object?>)['elided'] ==
        true;

List<Map<String, Object?>> _toolMessages(ContextWindow window) => [
  for (final message in window.messages)
    if (message['role'] == 'tool') message,
];

void main() {
  group('ContextBudget', () {
    group('below the high-water mark', () {
      test('keeps every message untouched', () {
        final messages = _conversation(4, resultTokens: 5000);

        final window = ContextBudget.window(
          messages,
          fixedTokens: _fixedTokens,
        );

        expect(window.fits, isTrue);
        expect(window.compactionPositions, isEmpty);
        expect(window.elidedResults, 0);
        expect(window.messages, hasLength(messages.length));
        expect(_toolMessages(window).any(_isElided), isFalse);
        expect(window.historyTokens, lessThan(ContextBudget.highWaterTokens));
      });
    });

    group('when the history crosses the high-water mark', () {
      // Six turns of 6,000 tokens: the fifth result brings the history to
      // about 30,000, the sixth to about 36,000.
      final messages = _conversation(6, resultTokens: 6000);
      final window = ContextBudget.window(
        messages,
        fixedTokens: _fixedTokens,
      );

      test('then results older than the last two turns are elided', () {
        final tools = _toolMessages(window);

        expect(tools.map(_isElided), [
          true, true, true, true, //
          false, false,
        ]);
        expect(window.elidedResults, 4);
        expect(window.squeezedResults, 0);
      });

      test('then the stub names the tool and the keys it carried', () {
        final first = _toolMessages(window).first;

        expect(first['tool_call_id'], 'call_0');
        expect(jsonDecode(_toolContent(first)), {
          'elided': true,
          'tool': 'search_knowledge',
          'citeAs': 'card-0',
        });
      });

      test(
        'then it happens once and leaves the history well under the mark',
        () {
          expect(window.compactionPositions, hasLength(1));
          expect(window.historyTokens, lessThan(14000));
          expect(window.fits, isTrue);
        },
      );

      test('then the stored rows are not rewritten', () {
        expect(
          messages
              .where((message) => message.role == AgentMessageRole.tool)
              .every((message) => !message.content.contains('"elided"')),
          isTrue,
        );
      });
    });

    group('when the history keeps growing after a compaction', () {
      test('then nothing more is elided until it crosses again', () {
        // After the compaction the history is about 12,000 tokens. Two more
        // turns take it to about 24,000, which is under the mark.
        final compacted = _conversation(6, resultTokens: 6000);
        final grown = _conversation(8, resultTokens: 6000);

        final before = ContextBudget.window(
          compacted,
          fixedTokens: _fixedTokens,
        );
        final after = ContextBudget.window(grown, fixedTokens: _fixedTokens);

        expect(before.compactionPositions, hasLength(1));
        expect(after.compactionPositions, before.compactionPositions);
        // Turns 4 and 5 stay full until the next compaction, so the prefix
        // the provider cached does not change.
        final tools = _toolMessages(after).map(_isElided).toList();
        expect(tools.take(4), everyElement(isTrue));
        expect(tools.skip(4), everyElement(isFalse));
      });

      test('then each new crossing compacts exactly once', () {
        // The first compaction leaves about 12,000 tokens. Four more turns of
        // 6,000 pass 32,000 again, which is the second crossing.
        final window = ContextBudget.window(
          _conversation(12, resultTokens: 6000),
          fixedTokens: _fixedTokens,
        );

        expect(window.compactionPositions, hasLength(2));
        expect(
          window.compactionPositions.first,
          lessThan(window.compactionPositions.last),
        );
        // The second compaction fired during turn 9 and kept turns 8 and 9.
        final tools = _toolMessages(window).map(_isElided).toList();
        expect(tools.take(8), everyElement(isTrue));
        expect(tools.skip(8), everyElement(isFalse));
      });

      test('then replaying a longer conversation keeps the earlier prefix', () {
        final shorter = ContextBudget.window(
          _conversation(7, resultTokens: 6000),
          fixedTokens: _fixedTokens,
        );
        final longer = ContextBudget.window(
          _conversation(8, resultTokens: 6000),
          fixedTokens: _fixedTokens,
        );

        expect(
          longer.messages.take(shorter.messages.length),
          shorter.messages,
        );
      });
    });

    group('when one turn is over the mark and nothing older can go', () {
      test('then calls in that turn do not compact', () {
        final window = ContextBudget.window(
          _turnWithThreeLargeResults(),
          fixedTokens: _fixedTokens,
        );

        expect(window.compactionPositions, isEmpty);
      });
    });

    group('at the ceiling', () {
      test('then the oldest results of the turn are elided to fit', () {
        // 36,000 tokens of history and 6,500 of rules and tools are over
        // 40,000, so the oldest result goes for this call.
        final window = ContextBudget.window(
          _turnWithThreeLargeResults(),
          fixedTokens: _fixedTokens,
        );

        expect(window.fits, isTrue);
        expect(window.squeezedResults, 1);
        expect(_toolMessages(window).map(_isElided), [true, false, false]);
        expect(
          window.historyTokens +
              _fixedTokens +
              ContextBudget.requestOverheadTokens,
          lessThanOrEqualTo(ContextBudget.ceilingTokens),
        );
      });

      test('then a history that cannot fit even elided does not fit', () {
        final window = ContextBudget.window(
          [
            _message(AgentMessageRole.user, 'y' * 4000),
            ..._turnWithThreeLargeResults().skip(1),
          ],
          fixedTokens: ContextBudget.ceilingTokens - 500,
        );

        expect(window.fits, isFalse);
      });
    });

    group('stubs', () {
      test('list every key of a result that carried several', () {
        final several = jsonEncode({
          'cards': [
            for (final key in ['card-a', 'card-b'])
              {
                'id': key,
                'citeAs': key,
                'sources': [
                  {'title': key, 'url': 'https://example.org/$key'},
                ],
                'body': 'x' * 40000,
              },
          ],
        });
        final messages = [
          ..._turn(0, result: several),
          _reply(0),
          ..._conversation(3, resultTokens: 6000),
        ];

        final window = ContextBudget.window(
          messages,
          fixedTokens: _fixedTokens,
        );

        expect(window.compactionPositions, isNotEmpty);
        expect(jsonDecode(_toolContent(_toolMessages(window).first)), {
          'elided': true,
          'tool': 'search_knowledge',
          'citeAs': ['card-a', 'card-b'],
        });
      });

      test('are not used for a result that is already smaller', () {
        const tiny = '{"error":"no"}';
        final messages = [
          ..._turn(0, result: tiny),
          _reply(0),
          ..._conversation(6, resultTokens: 6000),
        ];

        final window = ContextBudget.window(
          messages,
          fixedTokens: _fixedTokens,
        );

        expect(window.compactionPositions, isNotEmpty);
        expect(_toolContent(_toolMessages(window).first), tiny);
      });
    });

    test('estimates the history with the shared token estimate', () {
      final messages = _conversation(2, resultTokens: 1000);

      final window = ContextBudget.window(messages, fixedTokens: _fixedTokens);

      expect(
        window.historyTokens,
        window.messages.fold<int>(
          0,
          (sum, message) => sum + estimateTokens(jsonEncode(message)),
        ),
      );
    });
  });
}
