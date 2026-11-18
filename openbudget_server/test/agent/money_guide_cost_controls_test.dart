import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/context_budget.dart';
import 'package:openbudget_server/src/money_guide/money_guide_prompt.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

const _encryptionKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';

const _sinkingFunds = 'universal-budgeting-sinking-funds';

/// The other four sample cards. Asking for all of them at once, twice, makes
/// each turn after the first carry about 4,600 estimated tokens of tool
/// results, the doc's figure for a typical turn.
const _otherCards = [
  'universal-budgeting-zero-based-envelopes',
  'universal-crypto-crypto-tax-reporting',
  'universal-money-what-aer-means',
  'universal-money-emergency-fund',
];

const _turns = 12;

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '91000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

Map<String, Object?> _completion(
  Map<String, Object?> message,
  String finishReason,
) => {
  'id': 'chatcmpl-test',
  'object': 'chat.completion',
  'model': 'test-model',
  'choices': [
    {'index': 0, 'message': message, 'finish_reason': finishReason},
  ],
  'usage': {'prompt_tokens': 1000, 'completion_tokens': 200},
};

Map<String, Object?> _textResponse(String text) =>
    _completion({'role': 'assistant', 'content': text}, 'stop');

/// An assistant reply that asks for several `search_knowledge` calls at once.
Map<String, Object?> _searchResponse(
  String entityId,
  int turn,
  List<List<String>> idGroups,
) => _completion({
  'role': 'assistant',
  'content': null,
  'tool_calls': [
    for (var index = 0; index < idGroups.length; index++)
      {
        'id': 'call_${turn}_$index',
        'type': 'function',
        'function': {
          'name': 'search_knowledge',
          'arguments': jsonEncode({
            'entityId': entityId,
            'ids': idGroups[index],
          }),
        },
      },
  ],
}, 'tool_calls');

/// The estimated tokens of a whole request, as the doc measures a call.
int _tokensOf(http.Request request) => estimateTokens(request.body);

List<Map<String, Object?>> _messagesOf(http.Request request) {
  final body = jsonDecode(request.body) as Map<String, Object?>;
  return [
    for (final message in body['messages']! as List<Object?>)
      message! as Map<String, Object?>,
  ];
}

/// The tool results of a request, by the call that asked for them.
Map<String, Map<String, Object?>> _toolResults(http.Request request) => {
  for (final message in _messagesOf(request))
    if (message['role'] == 'tool')
      message['tool_call_id']! as String:
          jsonDecode(message['content']! as String) as Map<String, Object?>,
};

/// The requests that changed a message an earlier request had already sent.
/// The history is append-only except when it is compacted, so each such
/// request is one compaction, and it breaks the provider's cache once.
List<int> _compactingRequests(List<http.Request> requests) => [
  for (var index = 1; index < requests.length; index++)
    if (_changesEarlierMessages(requests[index - 1], requests[index])) index,
];

bool _changesEarlierMessages(http.Request before, http.Request after) {
  final sent = _messagesOf(before);
  final next = _messagesOf(after);
  for (var position = 0; position < sent.length; position++) {
    if (jsonEncode(sent[position]) != jsonEncode(next[position])) return true;
  }
  return false;
}

void main() {
  withServerpod('Given a long Money guide conversation', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late List<http.Request> requests;
    late Entity entity;
    final originalClock = TaxSummaryService.clock;

    setUp(() async {
      final user = _newUser(sessionBuilder);
      final base = sessionBuilder.build();
      await base.db.unsafeExecute(
        'INSERT INTO serverpod_auth_core_user '
        '(id, "createdAt", "scopeNames", blocked) '
        "VALUES (@id::uuid, now(), '[]'::json, false) "
        'ON CONFLICT (id) DO NOTHING',
        parameters: QueryParameters.named({'id': user.userId.toString()}),
      );
      await base.close();
      authedSession = user.session;
      userId = user.userId;
      rawSession = sessionBuilder.build()
        ..updateAuthenticated(
          AuthenticationInfo(
            userId.toString(),
            const {},
            authId: 'test-agent-$userId',
          ),
        )
        ..passwords['agentKeyEncryptionKey'] = _encryptionKey;
      requests = [];
      AgentEgressGuard.lookup = (_) async => [InternetAddress('203.0.113.10')];
      TaxSummaryService.clock = () => DateTime.utc(2026, 11, 14, 9);

      // A bring-your-own provider needs no subscription, so the tests stay
      // clear of the entitlement clock.
      await endpoints.agent.saveProviderSettings(
        authedSession,
        'https://api.example.test/v1',
        'byo-model',
        'sk-test-secret-1234',
      );
      entity = await endpoints.entity.create(
        authedSession,
        'Household',
        EntityKind.individual,
        'GB',
        'GBP',
        'Europe/London',
      );
    });

    tearDown(() {
      AgentService.chatClientOverride = null;
      AgentEgressGuard.lookup = InternetAddress.lookup;
      TaxSummaryService.clock = originalClock;
      rawSession.passwords.remove('agentKeyEncryptionKey');
    });

    void useMock(List<Map<String, Object?>> responses) {
      final client = MockClient((request) async {
        requests.add(request);
        final index = requests.length - 1;
        if (index >= responses.length) {
          return http.Response('{"error":"no response queued"}', 500);
        }
        return http.Response(
          jsonEncode(responses[index]),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });
      AgentService.chatClientOverride = ChatCompletionsClient(
        httpClient: client,
      );
    }

    Future<List<AgentEvent>> chat(
      String message, {
      UuidValue? conversationId,
    }) => endpoints.agent
        .chat(authedSession, entity.id!, conversationId, message)
        .toList();

    /// Turn 1 reads the sinking-funds card. Every later turn reads the other
    /// four sample cards twice, and the last turn cites turn 1's card.
    List<Map<String, Object?>> scriptTwelveTurns() {
      final entityId = entity.id.toString();
      return [
        for (var turn = 1; turn <= _turns; turn++) ...[
          _searchResponse(
            entityId,
            turn,
            turn == 1
                ? const [
                    [_sinkingFunds],
                  ]
                : const [_otherCards, _otherCards, _otherCards],
          ),
          _textResponse(
            turn == _turns
                ? 'Spread the renewal over twelve months [^$_sinkingFunds].'
                : 'Answer for turn $turn.',
          ),
        ],
      ];
    }

    Future<List<AgentEvent>> runTwelveTurns() async {
      useMock(scriptTwelveTurns());
      UuidValue? conversationId;
      late List<AgentEvent> last;
      for (var turn = 1; turn <= _turns; turn++) {
        last = await chat(
          'Question $turn about my plan?',
          conversationId: conversationId,
        );
        conversationId = last.first.conversationId;
      }
      return last;
    }

    group('when twelve turns each fetch a typical set of cards', () {
      test('then no call is over 40,000 estimated tokens', () async {
        await runTwelveTurns();

        expect(requests, hasLength(_turns * 2));
        for (final request in requests) {
          expect(_tokensOf(request), lessThanOrEqualTo(40000));
        }
      });

      test('then the script really would have outgrown the ceiling', () async {
        final events = await runTwelveTurns();
        final stored = await AgentMessage.db.find(
          rawSession,
          where: (t) => t.conversationId.equals(events.first.conversationId),
        );

        // Without compaction the last call would carry every stored message
        // on top of the static rules, the brief and the tool definitions,
        // which the first call shows with a single short question.
        final uncompacted = stored.fold<int>(
          _tokensOf(requests.first),
          (sum, message) => sum + estimateTokens(message.content),
        );
        expect(uncompacted, greaterThan(ContextBudget.ceilingTokens));
        expect(
          requests.map(_tokensOf).reduce((a, b) => a > b ? a : b),
          greaterThan(ContextBudget.highWaterTokens),
        );
      });

      test('then the history is compacted once per crossing', () async {
        await runTwelveTurns();

        // Each turn after the first adds about 5,300 tokens, so the history
        // passes 32,000 for the first time on turn 7's second call (request
        // 13, counting from 0) and, after dropping to about 13,000, for the
        // second time on turn 11's second call (request 21). Every call in
        // between sends the same compacted prefix, so the provider's cache
        // breaks twice in the whole conversation.
        expect(_compactingRequests(requests), [13, 21]);
      });

      test("then the first turn's result is elided and still named", () async {
        await runTwelveTurns();

        final firstCall = _toolResults(requests.first);
        expect(firstCall, isEmpty);
        // Before the crossing the card is whole; after it only the stub is
        // left.
        final early = _toolResults(requests[2])['call_1_0']!;
        expect(early['elided'], isNull);
        expect(early['cards'], isNotEmpty);
        final late = _toolResults(requests.last)['call_1_0']!;
        expect(late, {
          'elided': true,
          'tool': 'search_knowledge',
          'citeAs': _sinkingFunds,
        });
        // The most recent results are still whole.
        expect(_toolResults(requests.last)['call_12_0']!['cards'], isNotEmpty);
      });

      test('then the stored tool results are never rewritten', () async {
        final events = await runTwelveTurns();

        final stored = await AgentMessage.db.find(
          rawSession,
          where: (t) =>
              t.conversationId.equals(events.first.conversationId) &
              t.role.equals(AgentMessageRole.tool),
        );
        expect(stored, isNotEmpty);
        expect(
          stored.any((message) => message.content.contains('"elided"')),
          isFalse,
        );
      });

      test(
        'then a card read in turn 1 and cited in turn 12 resolves',
        () async {
          final events = await runTwelveTurns();

          final textEvent = events.singleWhere(
            (event) => event.kind == AgentEventKind.textDelta,
          );
          expect(
            textEvent.text,
            'Spread the renewal over twelve months [^$_sinkingFunds].',
          );
          expect(textEvent.citations, isNotEmpty);
          expect(
            textEvent.citations!.every(
              (citation) => citation.key == _sinkingFunds,
            ),
            isTrue,
          );

          final stored = (await AgentMessage.db.find(
            rawSession,
            where: (t) =>
                t.conversationId.equals(events.first.conversationId) &
                t.role.equals(AgentMessageRole.assistant),
            orderBy: (t) => t.createdAt,
          )).last;
          expect(stored.content, textEvent.text);
          expect(stored.citationsJson, isNotNull);
        },
      );
    });

    group('when one turn alone fetches more than the ceiling', () {
      test('then the oldest results of the turn are elided to fit', () async {
        // 24 parallel searches of four cards each are about 43,000 tokens
        // in one turn, and no older turn exists to compact.
        useMock([
          _searchResponse(entity.id.toString(), 1, [
            for (var index = 0; index < 24; index++) _otherCards,
          ]),
          _textResponse('That was a lot of cards.'),
        ]);

        final events = await chat('Read everything you have.');

        expect(events.last.kind, AgentEventKind.done);
        expect(requests, hasLength(2));
        expect(_tokensOf(requests.last), lessThanOrEqualTo(40000));
        final results = _toolResults(requests.last);
        expect(results, hasLength(24));
        expect(results['call_1_0']!['elided'], isTrue);
        expect(results['call_1_23']!['elided'], isNull);
        expect(_compactingRequests(requests), isEmpty);
      });
    });

    group('when a message is longer than the limit', () {
      test('then it is refused before any call is made', () async {
        useMock([_textResponse('This will not be reached.')]);
        final tooLong = 'x' * (ContextBudget.maxMessageTokens * 4 + 1);

        await expectLater(chat(tooLong), throwsA(isA<ValidationException>()));
        expect(requests, isEmpty);
      });

      test('then a message at the limit is accepted', () async {
        useMock([_textResponse('Fine.')]);
        final atLimit = 'x' * (ContextBudget.maxMessageTokens * 4);

        final events = await chat(atLimit);

        expect(events.last.kind, AgentEventKind.done);
        expect(requests, hasLength(1));
      });
    });
  });
}
