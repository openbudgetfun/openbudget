import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

const _encryptionKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';

const _sinkingFunds = 'universal-budgeting-sinking-funds';
const _zeroBased = 'universal-budgeting-zero-based-envelopes';

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '90000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

Map<String, Object?> _usage() => {
  'prompt_tokens': 1000,
  'completion_tokens': 200,
};

Map<String, Object?> _textResponse(String text) => {
  'id': 'chatcmpl-test',
  'object': 'chat.completion',
  'model': 'test-model',
  'choices': [
    {
      'index': 0,
      'message': {'role': 'assistant', 'content': text},
      'finish_reason': 'stop',
    },
  ],
  'usage': _usage(),
};

Map<String, Object?> _toolResponse(
  String name,
  Map<String, Object?> arguments, {
  String id = 'call_1',
}) => {
  'id': 'chatcmpl-tool',
  'object': 'chat.completion',
  'model': 'test-model',
  'choices': [
    {
      'index': 0,
      'message': {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': id,
            'type': 'function',
            'function': {'name': name, 'arguments': jsonEncode(arguments)},
          },
        ],
      },
      'finish_reason': 'tool_calls',
    },
  ],
  'usage': _usage(),
};

/// The assistant text a client would see once the turn is over.
String _textOf(List<AgentEvent> events) => events
    .where((event) => event.kind == AgentEventKind.textDelta)
    .map((event) => event.text!)
    .join();

void main() {
  withServerpod('Given a Money guide conversation', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late List<http.Request> requests;
    late Entity entity;

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

    Future<void> saveGbProfile() => endpoints.tax.saveProfile(
      authedSession,
      entity.id!,
      'GB',
      EntityKind.individual.name,
      jsonEncode(
        const GbTaxProfile(entityKind: EntityKind.individual).toJson(),
      ),
    );

    Future<List<AgentEvent>> chat(
      String message, {
      UuidValue? conversationId,
    }) => endpoints.agent
        .chat(authedSession, entity.id!, conversationId, message)
        .toList();

    Future<List<AgentMessage>> storedAssistantMessages(
      UuidValue conversationId,
    ) => AgentMessage.db.find(
      rawSession,
      where: (t) =>
          t.conversationId.equals(conversationId) &
          t.role.equals(AgentMessageRole.assistant),
      orderBy: (t) => t.createdAt,
    );

    List<Map<String, Object?>> decodeCitations(String? json) => [
      for (final item in jsonDecode(json!) as List<Object?>)
        item! as Map<String, Object?>,
    ];

    group('when the reply cites a retrieved card', () {
      test(
        'then the key resolves and its sources are stored and streamed',
        () async {
          useMock([
            _toolResponse('search_knowledge', {
              'entityId': entity.id.toString(),
              'ids': [_sinkingFunds],
            }),
            _textResponse(
              'Set aside £60 a month for the £480 renewal [^$_sinkingFunds].',
            ),
          ]);

          final events = await chat('How do I plan for my insurance renewal?');
          final textEvent = events.singleWhere(
            (event) => event.kind == AgentEventKind.textDelta,
          );

          expect(
            textEvent.text,
            'Set aside £60 a month for the £480 renewal [^$_sinkingFunds].',
          );
          final streamed = textEvent.citations!;
          expect(streamed, isNotEmpty);
          expect(
            streamed.every((citation) => citation.key == _sinkingFunds),
            isTrue,
          );
          expect(streamed.first.url, startsWith('https://www.moneyhelper.org'));
          expect(streamed.first.authority, 'moneyhelper.org.uk');
          expect(streamed.first.grade, 'primary');
          expect(streamed.first.announced, isFalse);
          expect(streamed.first.verifiedOn, DateTime.utc(2026, 11, 13));
          expect(textEvent.touchesTaxOrInvestment, isFalse);

          final conversationId = events.first.conversationId;
          final stored = (await storedAssistantMessages(conversationId)).last;
          expect(stored.content, textEvent.text);
          expect(stored.touchesTaxOrInvestment, isFalse);
          final storedCitations = decodeCitations(stored.citationsJson);
          expect(storedCitations.map((citation) => citation['key']).toSet(), {
            _sinkingFunds,
          });
          expect(
            storedCitations.map((citation) => citation['url']),
            streamed.map((citation) => citation.url),
          );

          final visible = await endpoints.agent.getMessages(
            authedSession,
            conversationId,
          );
          expect(visible.last.citationsJson, stored.citationsJson);
        },
      );
    });

    group('when the reply cites a card that was never retrieved', () {
      test('then the key is stripped and stored and streamed text agree', () async {
        useMock([
          _toolResponse('search_knowledge', {
            'entityId': entity.id.toString(),
            'ids': [_sinkingFunds],
          }),
          _textResponse(
            'A sinking fund spreads the cost [^$_sinkingFunds]. Zero-based '
            'envelopes also help [^$_zeroBased], and so does [^invented-key].',
          ),
        ]);

        final events = await chat('How do I plan for annual bills?');
        final textEvent = events.singleWhere(
          (event) => event.kind == AgentEventKind.textDelta,
        );

        const expected =
            'A sinking fund spreads the cost [^$_sinkingFunds]. Zero-based '
            'envelopes also help, and so does.';
        expect(textEvent.text, expected);
        expect(_textOf(events), expected);
        expect(
          textEvent.citations!.map((citation) => citation.key).toSet(),
          {_sinkingFunds},
        );

        final conversationId = events.first.conversationId;
        final stored = (await storedAssistantMessages(conversationId)).last;
        expect(stored.content, expected);
        expect(stored.content, isNot(contains(_zeroBased)));
        expect(stored.content, isNot(contains('invented-key')));
        expect(
          decodeCitations(stored.citationsJson)
              .map((citation) => citation['key'])
              .toSet(),
          {_sinkingFunds},
        );
      });

      test(
        'then a reply with no tool results has every key stripped',
        () async {
          useMock([_textResponse('Rule one [^$_sinkingFunds] and two.')]);

          final events = await chat('Tell me about sinking funds.');
          final textEvent = events.singleWhere(
            (event) => event.kind == AgentEventKind.textDelta,
          );

          expect(textEvent.text, 'Rule one and two.');
          expect(textEvent.citations, isEmpty);
          final stored = (await storedAssistantMessages(
            events.first.conversationId,
          )).last;
          expect(stored.content, 'Rule one and two.');
          expect(stored.citationsJson, isNull);
        },
      );
    });

    group('when the reply cites a tax report', () {
      test('then report-2026 resolves to the report sources', () async {
        await saveGbProfile();
        useMock([
          _toolResponse('get_tax_report', {
            'entityId': entity.id.toString(),
            'startYear': 2026,
          }),
          _textResponse('Your estimate is in the report [^report-2026].'),
        ]);

        final events = await chat('What will I owe for 2026/27?');
        final textEvent = events.singleWhere(
          (event) => event.kind == AgentEventKind.textDelta,
        );
        final conversationId = events.first.conversationId;

        final toolMessage = (await AgentMessage.db.find(
          rawSession,
          where: (t) =>
              t.conversationId.equals(conversationId) &
              t.role.equals(AgentMessageRole.tool),
        )).single;
        final report = jsonDecode(toolMessage.content) as Map<String, Object?>;
        expect(report['citeAs'], 'report-2026');
        final reportSources = [
          for (final source in report['sources']! as List<Object?>)
            source! as String,
        ];
        expect(reportSources, isNotEmpty);

        expect(
          textEvent.text,
          'Your estimate is in the report [^report-2026].',
        );
        final citations = textEvent.citations!;
        expect(
          citations.every((citation) => citation.key == 'report-2026'),
          isTrue,
        );
        expect(
          citations.map((citation) => citation.url),
          containsAll(reportSources),
        );
        expect(citations.first.title, startsWith('Tax report 2026/27'));
        expect(textEvent.touchesTaxOrInvestment, isTrue);

        final stored = (await storedAssistantMessages(conversationId)).last;
        expect(stored.touchesTaxOrInvestment, isTrue);
        expect(
          decodeCitations(stored.citationsJson).map((item) => item['url']),
          citations.map((citation) => citation.url),
        );
      });

      test('then the summary of a pack country can be cited', () async {
        await saveGbProfile();
        useMock([
          _toolResponse('get_tax_summary', {
            'entityId': entity.id.toString(),
            'startYear': 2026,
          }),
          _textResponse('Your totals are in the summary [^summary-2026].'),
        ]);

        final events = await chat('Show my tax-ready totals.');
        final textEvent = events.singleWhere(
          (event) => event.kind == AgentEventKind.textDelta,
        );

        expect(textEvent.text, contains('[^summary-2026]'));
        expect(textEvent.citations, isNotEmpty);
        expect(textEvent.touchesTaxOrInvestment, isTrue);
      });
    });

    group('when a later turn cites what an earlier turn retrieved', () {
      test('then it resolves from the stored tool result', () async {
        useMock([
          _toolResponse('search_knowledge', {
            'entityId': entity.id.toString(),
            'ids': [_sinkingFunds],
          }),
          _textResponse('Spread it out [^$_sinkingFunds] and [^$_zeroBased].'),
          _textResponse('Yes, the same card still applies [^$_sinkingFunds].'),
        ]);

        final first = await chat('How do I plan for annual bills?');
        final conversationId = first.first.conversationId;
        final second = await chat(
          'Does that still apply?',
          conversationId: conversationId,
        );

        final secondText = second.singleWhere(
          (event) => event.kind == AgentEventKind.textDelta,
        );
        expect(
          secondText.text,
          'Yes, the same card still applies [^$_sinkingFunds].',
        );
        expect(secondText.citations, isNotEmpty);

        // The model sees the stripped text of the first reply, never the
        // unresolved key.
        expect(requests, hasLength(3));
        // The brief lists every card id, so check the replayed assistant
        // message rather than the whole request.
        expect(
          requests.last.body,
          contains('"content":"Spread it out [^$_sinkingFunds] and."'),
        );
        expect(requests.last.body, isNot(contains('[^$_zeroBased]')));
      });
    });

    group('when the reply is only an unresolved key', () {
      test('then it is treated as an empty reply', () async {
        useMock([_textResponse('[^invented-key]')]);

        await expectLater(
          chat('Hello'),
          throwsA(isA<AgentProviderException>()),
        );
      });
    });
  });
}
