import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_provider_resolver.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/common/secret_box.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/money_guide_prompt.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

const _encryptionKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';
const _zenKey = 'test-zen-key';

var _userCounter = 0;

/// Inserts the auth user row that entity-owned tables reference.
Future<void> _ensureAuthUser(
  TestSessionBuilder base,
  UuidValue userId,
) async {
  final session = base.build();
  await session.db.unsafeExecute(
    'INSERT INTO serverpod_auth_core_user '
    '(id, "createdAt", "scopeNames", blocked) '
    "VALUES (@id::uuid, now(), '[]'::json, false) "
    'ON CONFLICT (id) DO NOTHING',
    parameters: QueryParameters.named({'id': userId.toString()}),
  );
  await session.close();
}

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '30000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

Map<String, Object?> _usage({
  int promptTokens = 1000,
  int? cachedTokens,
  int completionTokens = 200,
}) => {
  'prompt_tokens': promptTokens,
  if (cachedTokens != null)
    'prompt_tokens_details': {'cached_tokens': cachedTokens},
  'completion_tokens': completionTokens,
};

Map<String, Object?> _textResponse(
  String text, {
  int promptTokens = 1000,
  int? cachedTokens,
  int completionTokens = 200,
}) => {
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
  'usage': _usage(
    promptTokens: promptTokens,
    cachedTokens: cachedTokens,
    completionTokens: completionTokens,
  ),
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

/// The plan month as yyyymm.
int _month(DateTime date) => date.year * 100 + date.month;

void main() {
  withServerpod('Given AgentEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late List<http.Request> requests;

    setUp(() async {
      final user = _newUser(sessionBuilder);
      await _ensureAuthUser(sessionBuilder, user.userId);
      authedSession = user.session;
      userId = user.userId;
      // The tools call session-authenticated services. Production sessions
      // arrive signed in (endpoint) or elevated (the MCP handler), so the
      // raw tool sessions do the same.
      rawSession = sessionBuilder.build()
        ..updateAuthenticated(
          AuthenticationInfo(
            userId.toString(),
            const {},
            authId: 'test-agent-$userId',
          ),
        )
        ..passwords['opencodeZenApiKey'] = _zenKey
        ..passwords['agentKeyEncryptionKey'] = _encryptionKey;
      requests = [];
      AgentEgressGuard.lookup = (_) async => [InternetAddress('203.0.113.10')];
    });

    tearDown(() {
      AgentService.chatClientOverride = null;
      AgentEgressGuard.lookup = InternetAddress.lookup;
      rawSession.passwords.remove('opencodeZenApiKey');
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

    Future<void> subscribe(Session session, UuidValue id) async {
      final now = DateTime.now().toUtc();
      await EntitlementService.record(
        session,
        userId: id,
        source: EntitlementSource.stripe,
        externalId: 'sub-$id',
        status: EntitlementStatus.active,
        currentPeriodStart: now.subtract(const Duration(days: 1)),
        currentPeriodEnd: now.add(const Duration(days: 30)),
      );
    }

    Future<Entity> createEntity([String name = 'Household']) =>
        endpoints.entity.create(
          authedSession,
          name,
          EntityKind.individual,
          'GB',
          'GBP',
          'Europe/London',
        );

    Future<Category> createCategory(
      Entity entity, [
      String name = 'Everyday',
    ]) => endpoints.category.create(authedSession, entity.id!, name);

    Future<Envelope> createEnvelope(Category category, String name) =>
        endpoints.envelope.create(authedSession, category.id!, name);

    group('when chatting', () {
      test('then a plain reply streams usage, text and done and stores the '
          'turn', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        useMock([_textResponse('You have two envelopes.', cachedTokens: 400)]);

        final message = 'x' * 80;
        final events = await endpoints.agent
            .chat(authedSession, entity.id!, null, message)
            .toList();

        expect(events.map((event) => event.kind), [
          AgentEventKind.usage,
          AgentEventKind.textDelta,
          AgentEventKind.done,
        ]);
        expect(events[1].text, 'You have two envelopes.');
        expect(events.first.costMicroUsd, 423);
        expect(events.last.conversationId, events.first.conversationId);

        final conversations = await endpoints.agent.listConversations(
          authedSession,
          entity.id!,
        );
        expect(conversations, hasLength(1));
        expect(conversations.single.title, message.substring(0, 60));

        final messages = await endpoints.agent.getMessages(
          authedSession,
          events.first.conversationId,
        );
        expect(messages.map((message) => message.role), [
          AgentMessageRole.user,
          AgentMessageRole.assistant,
        ]);
        expect(messages.first.content, message);
        expect(messages.last.content, 'You have two envelopes.');

        final usageRows = await AgentUsageRecord.db.find(
          rawSession,
          where: (t) => t.userId.equals(userId),
        );
        expect(usageRows, hasLength(1));
        expect(usageRows.single.provider, AgentProvider.zen);
        expect(usageRows.single.costMicroUsd, 423);
      });

      test('then the provider request carries no user identity', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        useMock([_textResponse('Fine.')]);

        await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Hi')
            .toList();

        final request = requests.single;
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(request.body, isNot(contains(userId.toString())));
        expect(request.body, isNot(contains('@example.com')));
        expect(body.containsKey('user'), isFalse);
        expect(body['stream'], isFalse);
        expect(body['tool_choice'], 'auto');
        final tools = body['tools']! as List<Object?>;
        final names = [
          for (final tool in tools)
            ((tool! as Map<String, Object?>)['function']!
                as Map<String, Object?>)['name'],
        ];
        expect(names, contains('list_entities'));
        expect(names, contains('propose_move_money'));
      });

      test('then the request opens with the static rules and the entity '
          'brief', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity('Zebediah Quillfeather');
        useMock([_textResponse('Fine.')]);
        final previousClock = TaxSummaryService.clock;
        TaxSummaryService.clock = () => DateTime.utc(2026, 11, 14);
        addTearDown(() => TaxSummaryService.clock = previousClock);

        await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Hi')
            .toList();

        final body = jsonDecode(requests.single.body) as Map<String, Object?>;
        final messages = (body['messages']! as List<Object?>)
            .cast<Map<String, Object?>>();
        expect(messages[0]['role'], 'system');
        expect(messages[0]['content'], MoneyGuidePrompt.staticRules);
        expect(messages[1]['role'], 'system');
        final brief = messages[1]['content']! as String;
        expect(
          brief,
          startsWith('Entity: individual in GB, base currency GBP'),
        );
        expect(brief, contains('Tax year now: 2026/27, 2026-04-06'));
        expect(brief, contains('Jurisdiction: preview'));
        expect(brief, contains('Profile: tax resident of GB not recorded'));
        expect(brief, isNot(contains('Zebediah')));
        expect(brief, isNot(contains(entity.id!.uuid)));
        expect(messages[2]['role'], 'user');
      });

      test(
        'then a tool call is persisted and answered before the reply',
        () async {
          await subscribe(rawSession, userId);
          final entity = await createEntity();
          useMock([
            _toolResponse('list_entities', const {}),
            _textResponse('You have one entity called Household.'),
          ]);

          final events = await endpoints.agent
              .chat(authedSession, entity.id!, null, 'Which entities do I own?')
              .toList();

          expect(events.map((event) => event.kind), [
            AgentEventKind.usage,
            AgentEventKind.toolCall,
            AgentEventKind.usage,
            AgentEventKind.textDelta,
            AgentEventKind.done,
          ]);
          expect(events[1].toolName, 'list_entities');
          final conversationId = events.first.conversationId;

          final messages = await AgentMessage.db.find(
            rawSession,
            where: (t) => t.conversationId.equals(conversationId),
          );
          final toolMessage = messages.singleWhere(
            (message) => message.role == AgentMessageRole.tool,
          );
          expect(toolMessage.toolCallId, 'call_1');
          final toolResult =
              jsonDecode(toolMessage.content) as Map<String, Object?>;
          expect(toolResult['entities'], isA<List<Object?>>());

          final visible = await endpoints.agent.getMessages(
            authedSession,
            conversationId,
          );
          expect(visible, hasLength(2));
          expect(visible.map((message) => message.role), [
            AgentMessageRole.user,
            AgentMessageRole.assistant,
          ]);

          final secondBody =
              jsonDecode(requests[1].body) as Map<String, Object?>;
          final sent = secondBody['messages']! as List<Object?>;
          expect(
            sent.any(
              (message) => (message! as Map<String, Object?>)['role'] == 'tool',
            ),
            isTrue,
          );
        },
      );

      test('then deleting a conversation removes its messages', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        useMock([_textResponse('Done.')]);

        final events = await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Hello')
            .toList();
        final conversationId = events.first.conversationId;

        await endpoints.agent.deleteConversation(
          authedSession,
          conversationId,
        );

        expect(
          await endpoints.agent.listConversations(authedSession, entity.id!),
          isEmpty,
        );
        expect(
          await AgentMessage.db.find(
            rawSession,
            where: (t) => t.conversationId.equals(conversationId),
          ),
          isEmpty,
        );
        await expectLater(
          endpoints.agent.getMessages(authedSession, conversationId),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when proposing a change', () {
      Future<({Entity entity, Envelope from, Envelope to, int month})>
      setUpMove() async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        final category = await createCategory(entity);
        final from = await createEnvelope(category, 'Groceries');
        final to = await createEnvelope(category, 'Dining');
        final today = EntityClock.today(entity);
        final month = MonthKey.fromDate(today);
        await endpoints.budget.setAllocations(
          authedSession,
          entity.id!,
          month,
          [
            AllocationInput(envelopeId: from.id!, allocatedMinor: 10000),
            AllocationInput(envelopeId: to.id!, allocatedMinor: 0),
          ],
        );
        return (entity: entity, from: from, to: to, month: month);
      }

      Future<AgentProposal> chatProposal(
        Entity entity,
        Envelope from,
        Envelope to,
        int month,
      ) async {
        useMock([
          _toolResponse('propose_move_money', {
            'entityId': entity.id.toString(),
            'fromEnvelopeId': from.id.toString(),
            'toEnvelopeId': to.id.toString(),
            'amountMinor': 2500,
            'month': month,
            'reason': 'Dining is short this month.',
          }),
          _textResponse('I proposed moving 25.00 GBP to Dining.'),
        ]);
        final events = await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Move 25 to dining')
            .toList();
        expect(events.map((event) => event.kind), [
          AgentEventKind.usage,
          AgentEventKind.toolCall,
          AgentEventKind.proposal,
          AgentEventKind.usage,
          AgentEventKind.textDelta,
          AgentEventKind.done,
        ]);
        final proposal = events[2].proposal;
        expect(proposal, isNotNull);
        expect(proposal!.status, AgentProposalStatus.pending);
        expect(proposal.kind, AgentProposalKind.moveMoney);
        return proposal;
      }

      Future<Map<UuidValue, int>> allocations(
        Entity entity,
        int month,
      ) async {
        final view = await endpoints.budget.getMonth(
          authedSession,
          entity.id!,
          month,
        );
        return {
          for (final row in view.envelopes)
            row.envelope.id!: row.allocatedMinor,
        };
      }

      test('then applying a money move actually moves it', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.entity,
          setup.from,
          setup.to,
          setup.month,
        );

        final pending = await endpoints.agent.listProposals(
          authedSession,
          setup.entity.id!,
          pendingOnly: true,
        );
        expect(pending, hasLength(1));

        final applied = await endpoints.agent.applyProposal(
          authedSession,
          proposal.id!,
        );
        expect(applied.status, AgentProposalStatus.applied);
        expect(applied.resolvedAt, isNotNull);

        final after = await allocations(setup.entity, setup.month);
        expect(after[setup.from.id], 7500);
        expect(after[setup.to.id], 2500);

        expect(
          await endpoints.agent.listProposals(
            authedSession,
            setup.entity.id!,
            pendingOnly: true,
          ),
          isEmpty,
        );
        expect(
          await endpoints.agent.listProposals(
            authedSession,
            setup.entity.id!,
            pendingOnly: false,
          ),
          hasLength(1),
        );
        await expectLater(
          endpoints.agent.applyProposal(authedSession, proposal.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then a move that fails leaves the proposal pending', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.entity,
          setup.from,
          setup.to,
          setup.month,
        );
        // Point the move at an envelope that no longer exists.
        final stored = await AgentProposal.db.findById(
          rawSession,
          proposal.id!,
        );
        final payload = jsonDecode(stored!.payloadJson) as Map<String, Object?>;
        payload['toEnvelopeId'] = '01900000-0000-7000-8000-000000000000';
        await AgentProposal.db.updateRow(
          rawSession,
          stored.copyWith(payloadJson: jsonEncode(payload)),
        );

        await expectLater(
          endpoints.agent.applyProposal(authedSession, proposal.id!),
          throwsA(anything),
        );

        final pending = await endpoints.agent.listProposals(
          authedSession,
          setup.entity.id!,
          pendingOnly: true,
        );
        expect(pending.single.id, proposal.id);
        expect(pending.single.resolvedAt, isNull);
      });

      test('then dismissing leaves the allocations alone', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.entity,
          setup.from,
          setup.to,
          setup.month,
        );

        final dismissed = await endpoints.agent.dismissProposal(
          authedSession,
          proposal.id!,
        );
        expect(dismissed.status, AgentProposalStatus.dismissed);

        final after = await allocations(setup.entity, setup.month);
        expect(after[setup.from.id], 10000);
        expect(after[setup.to.id], 0);

        await expectLater(
          endpoints.agent.applyProposal(authedSession, proposal.id!),
          throwsA(isA<ValidationException>()),
        );
      });

      test('then another user cannot apply the proposal', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.entity,
          setup.from,
          setup.to,
          setup.month,
        );
        final other = _newUser(sessionBuilder);

        await expectLater(
          endpoints.agent.applyProposal(other.session, proposal.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.agent.dismissProposal(other.session, proposal.id!),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.agent.listProposals(
            other.session,
            setup.entity.id!,
            pendingOnly: true,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when proposing a tax category', () {
      test('then applying sets it and keeps the other tax fields', () async {
        final entity = await createEntity();
        final category = await createCategory(entity);
        final envelope = await createEnvelope(category, 'Office');
        await endpoints.tax.saveProfile(
          authedSession,
          entity.id!,
          'GB',
          EntityKind.individual.name,
          jsonEncode(
            const GbTaxProfile(entityKind: EntityKind.individual).toJson(),
          ),
        );
        final account = await endpoints.account.create(
          authedSession,
          entity.id!,
          'Checking',
          AccountKind.checking,
          'GBP',
          onBudget: true,
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 6, 10),
            amountMinor: -5000,
            description: 'Printer paper',
            lines: [
              TransactionLineInput(
                amountMinor: -5000,
                envelopeId: envelope.id,
                taxCategoryCode: 'gb.ind.employment',
                businessUsePercent: 40,
                salesTaxMinor: -500,
              ),
            ],
          ),
        );
        final line = transaction.lines.single;

        const registry = AgentToolRegistry();
        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: true,
        );
        final result = jsonDecode(
          await registry.call(
            context,
            'propose_transaction_tax_category',
            {
              'transactionLineId': line.id.toString(),
              'code': 'gb.ind.property',
              'reason': 'Printer paper is an office cost.',
            },
          ),
        ) as Map<String, Object?>;
        final proposalId = result['proposalId']! as String;

        final applied = await endpoints.agent.applyProposal(
          authedSession,
          UuidValue.fromString(proposalId),
        );
        expect(applied.kind, AgentProposalKind.setTransactionTaxCategory);
        expect(applied.status, AgentProposalStatus.applied);

        final updated = await endpoints.transaction.get(
          authedSession,
          transaction.transaction.id!,
        );
        expect(updated.lines.single.taxCategoryCode, 'gb.ind.property');
        expect(updated.lines.single.businessUsePercent, 40);
        expect(updated.lines.single.salesTaxMinor, -500);
      });
    });

    group('when the allowance is spent', () {
      test('then a recorded dollar of usage stops the next Zen call', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        await AgentUsageRecord.db.insertRow(
          rawSession,
          AgentUsageRecord(
            userId: userId,
            provider: AgentProvider.zen,
            model: AgentProviderResolver.zenModel,
            promptTokens: 0,
            cachedTokens: 0,
            completionTokens: 0,
            costMicroUsd: BillingPlan.includedAgentUsageMicroUsd,
          ),
        );
        useMock([_textResponse('This will not be reached.')]);

        await expectLater(
          endpoints.agent
              .chat(authedSession, entity.id!, null, 'Hello')
              .toList(),
          throwsA(isA<AgentAllowanceExhaustedException>()),
        );
        expect(requests, isEmpty);
      });
    });

    group('when the subscription is missing', () {
      test('then Zen chat needs OpenBudget Plus', () async {
        final entity = await createEntity();
        useMock([_textResponse('This will not be reached.')]);

        await expectLater(
          endpoints.agent
              .chat(authedSession, entity.id!, null, 'Hello')
              .toList(),
          throwsA(isA<EntitlementRequiredException>()),
        );
        expect(requests, isEmpty);
      });
    });

    group('when the Zen key is missing', () {
      test('then the provider is reported unavailable', () async {
        await subscribe(rawSession, userId);
        rawSession.passwords.remove('opencodeZenApiKey');
        final entity = await createEntity();
        useMock([_textResponse('This will not be reached.')]);

        await expectLater(
          endpoints.agent
              .chat(authedSession, entity.id!, null, 'Hello')
              .toList(),
          throwsA(isA<AgentProviderUnavailableException>()),
        );
        expect(requests, isEmpty);
      });
    });

    group('when the user brings their own provider', () {
      test('then it works without a subscription and is not metered', () async {
        final entity = await createEntity();
        final view = await endpoints.agent.saveProviderSettings(
          authedSession,
          'https://api.example.test/v1',
          'byo-model',
          'sk-test-secret-1234',
        );
        expect(view.baseUrl, 'https://api.example.test/v1');
        expect(view.model, 'byo-model');
        expect(view.keyHint, '1234');

        final stored = await AgentProviderSettings.db.findFirstRow(
          rawSession,
          where: (t) => t.userId.equals(userId),
        );
        expect(stored, isNotNull);
        expect(stored!.encryptedApiKey, isNot('sk-test-secret-1234'));
        expect(stored.encryptedApiKey, isNot(contains('sk-test')));
        expect(stored.nonce, isNotEmpty);
        expect(
          await SecretBox.open(
            cipherText: stored.encryptedApiKey,
            nonce: stored.nonce,
            base64Key: _encryptionKey,
          ),
          'sk-test-secret-1234',
        );

        final settings = await endpoints.agent.getProviderSettings(
          authedSession,
        );
        expect(settings?.keyHint, '1234');

        useMock([_textResponse('Hello from your own provider.')]);
        final events = await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Hello')
            .toList();
        expect(events.last.kind, AgentEventKind.done);
        expect(events[1].text, 'Hello from your own provider.');

        expect(
          requests.single.url.toString(),
          'https://api.example.test/v1/chat/completions',
        );
        expect(
          requests.single.headers['Authorization'],
          'Bearer sk-test-secret-1234',
        );

        final usageRows = await AgentUsageRecord.db.find(
          rawSession,
          where: (t) => t.userId.equals(userId),
        );
        expect(usageRows, hasLength(1));
        expect(usageRows.single.provider, AgentProvider.byo);
        expect(usageRows.single.costMicroUsd, 0);

        final usage = await endpoints.agent.getUsage(authedSession);
        expect(usage.provider, AgentProvider.byo);
        expect(usage.usedMicroUsd, 0);
        expect(usage.allowanceMicroUsd, 0);

        await endpoints.agent.clearProviderSettings(authedSession);
        expect(
          await endpoints.agent.getProviderSettings(authedSession),
          isNull,
        );
        expect(
          (await endpoints.agent.getUsage(authedSession)).provider,
          AgentProvider.zen,
        );
      });

      test('then a non-HTTPS base URL is rejected', () async {
        await expectLater(
          endpoints.agent.saveProviderSettings(
            authedSession,
            'http://api.example.test/v1',
            'byo-model',
            'sk-test-secret-1234',
          ),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('when tools read another user', () {
      test('then every entity-bound tool refuses the entity', () async {
        final entity = await createEntity();
        final category = await createCategory(entity);
        final from = await createEnvelope(category, 'Groceries');
        final to = await createEnvelope(category, 'Dining');
        final account = await endpoints.account.create(
          authedSession,
          entity.id!,
          'Checking',
          AccountKind.checking,
          'GBP',
          onBudget: true,
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 6, 10),
            amountMinor: -2500,
            description: 'Supermarket',
            lines: [
              TransactionLineInput(
                amountMinor: -2500,
                envelopeId: from.id,
              ),
            ],
          ),
        );
        final other = _newUser(sessionBuilder);
        await _ensureAuthUser(sessionBuilder, other.userId);
        final otherSession = other.session.build()
          ..updateAuthenticated(
            AuthenticationInfo(
              other.userId.toString(),
              const {},
              authId: 'test-agent-${other.userId}',
            ),
          );
        const registry = AgentToolRegistry();
        final context = AgentToolContext(
          session: otherSession,
          userId: other.userId,
          canPropose: true,
        );

        final calls = <(String, Map<String, Object?>)>[
          ('list_envelopes', {'entityId': entity.id.toString()}),
          ('search_transactions', {'entityId': entity.id.toString()}),
          ('get_tax_report', {'entityId': entity.id.toString()}),
          ('list_tax_categories', {'entityId': entity.id.toString()}),
          ('get_net_worth', {'entityId': entity.id.toString()}),
          ('get_spending_summary', {'entityId': entity.id.toString()}),
          ('get_tax_calendar', {'entityId': entity.id.toString()}),
          ('get_tax_summary', {'entityId': entity.id.toString()}),
          (
            'propose_move_money',
            {
              'entityId': entity.id.toString(),
              'fromEnvelopeId': from.id.toString(),
              'toEnvelopeId': to.id.toString(),
              'amountMinor': 100,
              'month': _month(DateTime.now()),
              'reason': 'Test',
            },
          ),
          (
            'propose_transaction_tax_category',
            {
              'transactionLineId': transaction.lines.single.id.toString(),
              'code': 'gb.se.office_costs',
              'reason': 'Test',
            },
          ),
          (
            'propose_envelope_tax_category',
            {
              'envelopeId': from.id.toString(),
              'code': 'gb.se.office_costs',
              'reason': 'Test',
            },
          ),
        ];

        for (final (name, arguments) in calls) {
          final result = await registry.call(context, name, arguments);
          expect(
            jsonDecode(result),
            containsPair('error', 'Entity not found'),
            reason: name,
          );
        }

        final entities = await registry.call(
          context,
          'list_entities',
          const {},
        );
        expect(
          (jsonDecode(entities) as Map<String, Object?>)['entities'],
          isEmpty,
        );
        expect(
          jsonDecode(
            await registry.call(context, 'not_a_tool', const {}),
          ),
          containsPair('error', contains('Unknown tool')),
        );
        expect(
          jsonDecode(
            await registry.call(context, 'list_envelopes', {
              'entityId': 'not-a-uuid',
            }),
          ),
          containsPair('error', contains('must be a UUID')),
        );
      });
    });

    group('when reading through the registry', () {
      test('then envelopes carry this month’s assigned and available amounts '
          'and proposed tools honour canPropose', () async {
        final entity = await createEntity();
        final category = await createCategory(entity);
        final envelope = await createEnvelope(category, 'Groceries');
        final today = EntityClock.today(entity);
        final month = MonthKey.fromDate(today);
        await endpoints.budget.setAllocations(
          authedSession,
          entity.id!,
          month,
          [
            AllocationInput(envelopeId: envelope.id!, allocatedMinor: 10000),
          ],
        );
        final account = await endpoints.account.create(
          authedSession,
          entity.id!,
          'Checking',
          AccountKind.checking,
          'GBP',
          onBudget: true,
        );
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: today,
            amountMinor: -2500,
            description: 'Supermarket',
            lines: [
              TransactionLineInput(
                amountMinor: -2500,
                envelopeId: envelope.id,
              ),
            ],
          ),
        );

        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: false,
        );
        const registry = AgentToolRegistry();

        final result = await registry.call(context, 'list_envelopes', {
          'entityId': entity.id.toString(),
        });
        final decoded = jsonDecode(result) as Map<String, Object?>;
        expect(decoded['currencyCode'], 'GBP');
        final envelopes = decoded['envelopes']! as List<Object?>;
        final first = envelopes.single! as Map<Object?, Object?>;
        expect(first['name'], 'Groceries');
        expect(first['assignedMinor'], 10000);
        expect(first['activityMinor'], -2500);
        expect(first['availableMinor'], 7500);

        final readOnlyTools = registry.definitions(canPropose: false);
        expect(
          readOnlyTools.map(
            (tool) =>
                (tool['function']! as Map<String, Object?>)['name']! as String,
          ),
          isNot(contains('propose_move_money')),
        );
        expect(
          jsonDecode(
            await registry.call(context, 'propose_move_money', {
              'entityId': entity.id.toString(),
              'fromEnvelopeId': envelope.id.toString(),
              'toEnvelopeId': envelope.id.toString(),
              'amountMinor': 100,
              'month': month,
              'reason': 'Test',
            }),
          ),
          containsPair('error', 'The propose tools are not available.'),
        );
      });

      test('then a search finds transactions by text and date', () async {
        final entity = await createEntity();
        final category = await createCategory(entity);
        final envelope = await createEnvelope(category, 'Groceries');
        final account = await endpoints.account.create(
          authedSession,
          entity.id!,
          'Checking',
          AccountKind.checking,
          'GBP',
          onBudget: true,
        );
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 3, 10),
            amountMinor: -2500,
            description: 'Tesco Supermarket',
            lines: [
              TransactionLineInput(
                amountMinor: -2500,
                envelopeId: envelope.id,
              ),
            ],
          ),
        );
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 4, 10),
            amountMinor: -400,
            description: 'Coffee',
            lines: const [],
          ),
        );

        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: true,
        );
        const registry = AgentToolRegistry();
        final result = await registry.call(context, 'search_transactions', {
          'entityId': entity.id.toString(),
          'query': 'market',
          'fromDate': '2026-03-01',
          'toDate': '2026-03-31',
        });
        final decoded = jsonDecode(result) as Map<String, Object?>;
        expect(decoded['baseCurrencyCode'], 'GBP');
        final rows = decoded['transactions']! as List<Object?>;
        expect(rows, hasLength(1));
        final row = rows.single! as Map<String, Object?>;
        expect(row['description'], 'Tesco Supermarket');
        expect(row['amountMinor'], -2500);
        expect(row['currencyCode'], 'GBP');
        expect(row['baseAmountMinor'], -2500);
        expect(row['lines']! as List<Object?>, hasLength(1));
      });
    });

    group('when reading tax through the registry', () {
      test(
        'then the report and categories come from the entity books',
        () async {
          final entity = await createEntity();
          final category = await createCategory(entity);
          final envelope = await createEnvelope(category, 'Salary');
          await endpoints.tax.saveProfile(
            authedSession,
            entity.id!,
            'GB',
            EntityKind.individual.name,
            jsonEncode(
              const GbTaxProfile(entityKind: EntityKind.individual).toJson(),
            ),
          );
          final account = await endpoints.account.create(
            authedSession,
            entity.id!,
            'Checking',
            AccountKind.checking,
            'GBP',
            onBudget: true,
          );
          final transaction = await endpoints.transaction.create(
            authedSession,
            TransactionInput(
              accountId: account.id!,
              date: DateTime.utc(2026, 6, 30),
              amountMinor: 1200000,
              description: 'Monthly salary',
              lines: [
                TransactionLineInput(
                  amountMinor: 1200000,
                  envelopeId: envelope.id,
                  taxCategoryCode: 'gb.ind.employment',
                ),
              ],
            ),
          );
          expect(transaction.lines.single.taxCategoryCode, 'gb.ind.employment');

          final context = AgentToolContext(
            session: rawSession,
            userId: userId,
            canPropose: true,
          );
          const registry = AgentToolRegistry();

          final reportResult = await registry.call(context, 'get_tax_report', {
            'entityId': entity.id.toString(),
            'startYear': 2026,
          });
          final report = jsonDecode(reportResult) as Map<String, Object?>;
          expect(report['jurisdiction'], 'GB');
          expect(report['currencyCode'], 'GBP');
          expect(report['startYear'], 2026);
          expect(report['uncategorizedCount'], 0);
          expect(report['sources'], isNotEmpty);
          expect(report['assumptions'], isNotEmpty);
          expect(
            (report['lines']! as List<Object?>).any(
              (line) =>
                  (line! as Map<String, Object?>)['code'] ==
                  'gb.ind.employment',
            ),
            isTrue,
          );

          final categoriesResult = await registry.call(
            context,
            'list_tax_categories',
            {'entityId': entity.id.toString()},
          );
          final categories =
              jsonDecode(categoriesResult) as Map<String, Object?>;
          final rows = categories['categories']! as List<Object?>;
          expect(
            rows.any(
              (row) =>
                  (row! as Map<String, Object?>)['code'] == 'gb.ind.employment',
            ),
            isTrue,
          );
        },
      );

      test('then a tax proposal records the rule version', () async {
        final entity = await createEntity();
        final category = await createCategory(entity);
        final envelope = await createEnvelope(category, 'Salary');
        await endpoints.tax.saveProfile(
          authedSession,
          entity.id!,
          'GB',
          EntityKind.individual.name,
          jsonEncode(
            const GbTaxProfile(entityKind: EntityKind.individual).toJson(),
          ),
        );

        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: true,
        );
        const registry = AgentToolRegistry();
        final result = await registry.call(
          context,
          'propose_envelope_tax_category',
          {
            'envelopeId': envelope.id.toString(),
            'code': 'gb.ind.employment',
            'reason': 'Test',
          },
        );
        final proposalId =
            (jsonDecode(result) as Map<String, Object?>)['proposalId']!
                as String;
        final stored = await AgentProposal.db.findById(
          rawSession,
          UuidValue.fromString(proposalId),
        );

        final pack = TaxRules.forJurisdiction(TaxJurisdiction.gb);
        final year = pack.taxYearFor(EntityClock.today(entity));
        final expected = pack
            .ruleSet(year.startYear)
            .versionFor(
              TaxJurisdiction.gb,
            );
        expect(stored, isNotNull);
        expect(stored!.rulesVersion, expected);
        expect(stored.rulesVersion, matches(RegExp(r'^gb-\d{4}-r\d+$')));
      });
    });

    group('when reading a conversation', () {
      test('then another user cannot see it', () async {
        await subscribe(rawSession, userId);
        final entity = await createEntity();
        useMock([_textResponse('Hello.')]);
        final events = await endpoints.agent
            .chat(authedSession, entity.id!, null, 'Hi')
            .toList();
        final other = _newUser(sessionBuilder);

        await expectLater(
          endpoints.agent.getMessages(
            other.session,
            events.first.conversationId,
          ),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.agent.deleteConversation(
            other.session,
            events.first.conversationId,
          ),
          throwsA(isA<NotFoundException>()),
        );
        await expectLater(
          endpoints.agent.listConversations(other.session, entity.id!),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when the agent is not signed in', () {
      test('then it rejects the caller', () async {
        final entity = await createEntity();
        final anonymous = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );

        await expectLater(
          endpoints.agent.listConversations(anonymous, entity.id!),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        await expectLater(
          endpoints.agent.getUsage(anonymous),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });

    group('when usage is read', () {
      test('then it reports the period and the spend', () async {
        final now = DateTime.now().toUtc();
        await EntitlementService.record(
          rawSession,
          userId: userId,
          source: EntitlementSource.stripe,
          externalId: 'sub-usage',
          status: EntitlementStatus.active,
          currentPeriodStart: now.subtract(const Duration(days: 1)),
          currentPeriodEnd: now.add(const Duration(days: 29)),
        );
        await AgentUsageRecord.db.insertRow(
          rawSession,
          AgentUsageRecord(
            userId: userId,
            provider: AgentProvider.zen,
            model: AgentProviderResolver.zenModel,
            promptTokens: 100,
            cachedTokens: 0,
            completionTokens: 10,
            costMicroUsd: 42000,
          ),
        );

        final usage = await endpoints.agent.getUsage(authedSession);
        expect(usage.provider, AgentProvider.zen);
        expect(usage.allowanceMicroUsd, BillingPlan.includedAgentUsageMicroUsd);
        expect(usage.usedMicroUsd, 42000);
        expect(usage.periodEnd, isNotNull);
      });
    });
  });
}
