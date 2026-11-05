import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_provider_resolver.dart';
import 'package:openbudget_server/src/agent/agent_secret_box.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

const _encryptionKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';
const _zenKey = 'test-zen-key';

var _userCounter = 0;

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

String _month(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

void main() {
  withServerpod('Given AgentEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late List<http.Request> requests;

    setUp(() {
      final user = _newUser(sessionBuilder);
      authedSession = user.session;
      userId = user.userId;
      rawSession = sessionBuilder.build();
      rawSession.passwords['opencodeZenApiKey'] = _zenKey;
      rawSession.passwords['agentKeyEncryptionKey'] = _encryptionKey;
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

    Future<Budget> createBudget([String name = 'Household']) =>
        endpoints.budget.create(authedSession, name, 'GBP');

    Future<Category> createCategory(
      Budget budget, [
      String name = 'Everyday',
    ]) => endpoints.category.create(authedSession, name, budget.id!, 0);

    Future<Envelope> createEnvelope(
      Category category,
      String name,
      int budgetedCents,
    ) => endpoints.envelope.create(
      authedSession,
      name,
      category.id!,
      budgetedCents,
      'GBP',
    );

    group('when chatting', () {
      test('then a plain reply streams usage, text and done and stores the '
          'turn', () async {
        await subscribe(rawSession, userId);
        final budget = await createBudget();
        useMock([_textResponse('You have two envelopes.', cachedTokens: 400)]);

        final message = 'x' * 80;
        final events = await endpoints.agent
            .chat(authedSession, budget.id!, null, message)
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
          budget.id!,
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
        final budget = await createBudget();
        useMock([_textResponse('Fine.')]);

        await endpoints.agent
            .chat(authedSession, budget.id!, null, 'Hi')
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
        expect(names, contains('list_budgets'));
        expect(names, contains('propose_move_money'));
      });

      test(
        'then a tool call is persisted and answered before the reply',
        () async {
          await subscribe(rawSession, userId);
          final budget = await createBudget();
          useMock([
            _toolResponse('list_budgets', const {}),
            _textResponse('You have one budget called Household.'),
          ]);

          final events = await endpoints.agent
              .chat(authedSession, budget.id!, null, 'Which budgets do I have?')
              .toList();

          expect(events.map((event) => event.kind), [
            AgentEventKind.usage,
            AgentEventKind.toolCall,
            AgentEventKind.usage,
            AgentEventKind.textDelta,
            AgentEventKind.done,
          ]);
          expect(events[1].toolName, 'list_budgets');
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
          expect(toolResult['budgets'], isA<List<Object?>>());

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
        final budget = await createBudget();
        useMock([_textResponse('Done.')]);

        final events = await endpoints.agent
            .chat(authedSession, budget.id!, null, 'Hello')
            .toList();
        final conversationId = events.first.conversationId;

        await endpoints.agent.deleteConversation(
          authedSession,
          conversationId,
        );

        expect(
          await endpoints.agent.listConversations(authedSession, budget.id!),
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
      Future<({Budget budget, Envelope from, Envelope to, String month})>
      setUpMove() async {
        await subscribe(rawSession, userId);
        final budget = await createBudget();
        final category = await createCategory(budget);
        final from = await createEnvelope(category, 'Groceries', 10000);
        final to = await createEnvelope(category, 'Dining', 0);
        final now = DateTime.now();
        await endpoints.monthlyAllocation.upsert(
          authedSession,
          from.id!,
          budget.id!,
          now.year,
          now.month,
          10000,
          carryoverCents: 0,
        );
        await endpoints.monthlyAllocation.upsert(
          authedSession,
          to.id!,
          budget.id!,
          now.year,
          now.month,
          0,
          carryoverCents: 0,
        );
        return (budget: budget, from: from, to: to, month: _month(now));
      }

      Future<AgentProposal> chatProposal(
        Budget budget,
        Envelope from,
        Envelope to,
        String month,
      ) async {
        useMock([
          _toolResponse('propose_move_money', {
            'budgetId': budget.id.toString(),
            'fromEnvelopeId': from.id.toString(),
            'toEnvelopeId': to.id.toString(),
            'amountMinor': 2500,
            'month': month,
            'reason': 'Dining is short this month.',
          }),
          _textResponse('I proposed moving 25.00 GBP to Dining.'),
        ]);
        final events = await endpoints.agent
            .chat(authedSession, budget.id!, null, 'Move 25 to dining')
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
        Budget budget,
        Envelope from,
        Envelope to,
        String month,
      ) async {
        final year = int.parse(month.substring(0, 4));
        final monthNumber = int.parse(month.substring(5));
        final rows = await endpoints.monthlyAllocation.list(
          authedSession,
          budget.id!,
          year,
          monthNumber,
        );
        return {
          for (final row in rows) row.envelopeId: row.allocatedCents,
        };
      }

      test('then applying a money move actually moves it', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.budget,
          setup.from,
          setup.to,
          setup.month,
        );

        final pending = await endpoints.agent.listProposals(
          authedSession,
          setup.budget.id!,
          pendingOnly: true,
        );
        expect(pending, hasLength(1));

        final applied = await endpoints.agent.applyProposal(
          authedSession,
          proposal.id!,
        );
        expect(applied.status, AgentProposalStatus.applied);
        expect(applied.resolvedAt, isNotNull);

        final after = await allocations(
          setup.budget,
          setup.from,
          setup.to,
          setup.month,
        );
        expect(after[setup.from.id], 7500);
        expect(after[setup.to.id], 2500);

        expect(
          await endpoints.agent.listProposals(
            authedSession,
            setup.budget.id!,
            pendingOnly: true,
          ),
          isEmpty,
        );
        expect(
          await endpoints.agent.listProposals(
            authedSession,
            setup.budget.id!,
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
          setup.budget,
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
          setup.budget.id!,
          pendingOnly: true,
        );
        expect(pending.single.id, proposal.id);
        expect(pending.single.resolvedAt, isNull);
      });

      test('then dismissing leaves the allocations alone', () async {
        final setup = await setUpMove();
        final proposal = await chatProposal(
          setup.budget,
          setup.from,
          setup.to,
          setup.month,
        );

        final dismissed = await endpoints.agent.dismissProposal(
          authedSession,
          proposal.id!,
        );
        expect(dismissed.status, AgentProposalStatus.dismissed);

        final after = await allocations(
          setup.budget,
          setup.from,
          setup.to,
          setup.month,
        );
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
          setup.budget,
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
            setup.budget.id!,
            pendingOnly: true,
          ),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when proposing a tax category', () {
      test('then applying sets it and keeps the other tax fields', () async {
        final budget = await createBudget();
        final category = await createCategory(budget);
        final envelope = await createEnvelope(category, 'Office', 0);
        await endpoints.tax.saveProfile(
          authedSession,
          budget.id!,
          'GB',
          TaxEntityKind.individual.name,
          jsonEncode(
            const GbTaxProfile(entityKind: TaxEntityKind.individual).toJson(),
          ),
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Printer paper',
          -5000,
          'GBP',
          budget.id!,
          DateTime.now(),
          envelopeId: envelope.id,
        );
        await endpoints.tax.setTransactionTax(
          authedSession,
          transaction.id!,
          code: 'gb.ind.employment',
          businessUsePercent: 40,
          salesTaxCents: 500,
        );

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
              'transactionId': transaction.id.toString(),
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
          transaction.id!,
        );
        expect(updated.taxCategoryCode, 'gb.ind.property');
        expect(updated.businessUsePercent, 40);
        expect(updated.salesTaxCents, 500);
      });
    });

    group('when the allowance is spent', () {
      test('then a recorded dollar of usage stops the next Zen call', () async {
        await subscribe(rawSession, userId);
        final budget = await createBudget();
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
              .chat(authedSession, budget.id!, null, 'Hello')
              .toList(),
          throwsA(isA<AgentAllowanceExhaustedException>()),
        );
        expect(requests, isEmpty);
      });
    });

    group('when the subscription is missing', () {
      test('then Zen chat needs OpenBudget Plus', () async {
        final budget = await createBudget();
        useMock([_textResponse('This will not be reached.')]);

        await expectLater(
          endpoints.agent
              .chat(authedSession, budget.id!, null, 'Hello')
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
        final budget = await createBudget();
        useMock([_textResponse('This will not be reached.')]);

        await expectLater(
          endpoints.agent
              .chat(authedSession, budget.id!, null, 'Hello')
              .toList(),
          throwsA(isA<AgentProviderUnavailableException>()),
        );
        expect(requests, isEmpty);
      });
    });

    group('when the user brings their own provider', () {
      test('then it works without a subscription and is not metered', () async {
        final budget = await createBudget();
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
          await AgentSecretBox.open(
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
            .chat(authedSession, budget.id!, null, 'Hello')
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
      test('then every budget-bound tool refuses the budget', () async {
        final budget = await createBudget();
        final category = await createCategory(budget);
        final from = await createEnvelope(category, 'Groceries', 10000);
        final to = await createEnvelope(category, 'Dining', 0);
        final transaction = await endpoints.transaction.create(
          authedSession,
          'Supermarket',
          -2500,
          'GBP',
          budget.id!,
          DateTime.now(),
          envelopeId: from.id,
        );
        final other = _newUser(sessionBuilder);
        final otherSession = other.session.build();
        const registry = AgentToolRegistry();
        final context = AgentToolContext(
          session: otherSession,
          userId: other.userId,
          canPropose: true,
        );

        final calls = <(String, Map<String, Object?>)>[
          ('list_envelopes', {'budgetId': budget.id.toString()}),
          ('search_transactions', {'budgetId': budget.id.toString()}),
          ('get_tax_report', {'budgetId': budget.id.toString()}),
          ('list_tax_categories', {'budgetId': budget.id.toString()}),
          (
            'propose_move_money',
            {
              'budgetId': budget.id.toString(),
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
              'transactionId': transaction.id.toString(),
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
            containsPair('error', 'Budget not found'),
            reason: name,
          );
        }

        final budgets = await registry.call(context, 'list_budgets', const {});
        expect(
          (jsonDecode(budgets) as Map<String, Object?>)['budgets'],
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
              'budgetId': 'not-a-uuid',
            }),
          ),
          containsPair('error', contains('must be a UUID')),
        );
      });
    });

    group('when reading through the registry', () {
      test('then envelopes carry this month’s assigned and available amounts '
          'and proposed tools honour canPropose', () async {
        final budget = await createBudget();
        final category = await createCategory(budget);
        final envelope = await createEnvelope(category, 'Groceries', 10000);
        final now = DateTime.now();
        await endpoints.monthlyAllocation.upsert(
          authedSession,
          envelope.id!,
          budget.id!,
          now.year,
          now.month,
          10000,
          carryoverCents: 0,
        );
        await endpoints.transaction.create(
          authedSession,
          'Supermarket',
          -2500,
          'GBP',
          budget.id!,
          now,
          envelopeId: envelope.id,
        );

        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: false,
        );
        const registry = AgentToolRegistry();

        final result = await registry.call(context, 'list_envelopes', {
          'budgetId': budget.id.toString(),
        });
        final decoded = jsonDecode(result) as Map<String, Object?>;
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
              'budgetId': budget.id.toString(),
              'fromEnvelopeId': envelope.id.toString(),
              'toEnvelopeId': envelope.id.toString(),
              'amountMinor': 100,
              'month': _month(now),
              'reason': 'Test',
            }),
          ),
          containsPair('error', 'The propose tools are not available.'),
        );
      });

      test('then a search finds transactions by text and date', () async {
        final budget = await createBudget();
        final category = await createCategory(budget);
        final envelope = await createEnvelope(category, 'Groceries', 0);
        await endpoints.transaction.create(
          authedSession,
          'Tesco Supermarket',
          -2500,
          'GBP',
          budget.id!,
          DateTime(2026, 3, 10),
          envelopeId: envelope.id,
        );
        await endpoints.transaction.create(
          authedSession,
          'Coffee',
          -400,
          'GBP',
          budget.id!,
          DateTime(2026, 4, 10),
        );

        final context = AgentToolContext(
          session: rawSession,
          userId: userId,
          canPropose: true,
        );
        const registry = AgentToolRegistry();
        final result = await registry.call(context, 'search_transactions', {
          'budgetId': budget.id.toString(),
          'query': 'market',
          'fromDate': '2026-03-01',
          'toDate': '2026-03-31',
        });
        final decoded = jsonDecode(result) as Map<String, Object?>;
        final rows = decoded['transactions']! as List<Object?>;
        expect(rows, hasLength(1));
        expect(
          (rows.single! as Map<String, Object?>)['description'],
          'Tesco Supermarket',
        );
      });
    });

    group('when reading tax through the registry', () {
      test(
        'then the report and categories come from the budget books',
        () async {
          final budget = await createBudget();
          final category = await createCategory(budget);
          final envelope = await createEnvelope(category, 'Salary', 0);
          await endpoints.tax.saveProfile(
            authedSession,
            budget.id!,
            'GB',
            TaxEntityKind.individual.name,
            jsonEncode(
              const GbTaxProfile(entityKind: TaxEntityKind.individual).toJson(),
            ),
          );
          final transaction = await endpoints.transaction.create(
            authedSession,
            'Monthly salary',
            1200000,
            'GBP',
            budget.id!,
            DateTime.utc(2026, 6, 30),
            envelopeId: envelope.id,
          );
          await endpoints.tax.setTransactionTax(
            authedSession,
            transaction.id!,
            code: 'gb.ind.employment',
          );

          final context = AgentToolContext(
            session: rawSession,
            userId: userId,
            canPropose: true,
          );
          const registry = AgentToolRegistry();

          final reportResult = await registry.call(context, 'get_tax_report', {
            'budgetId': budget.id.toString(),
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
            {'budgetId': budget.id.toString()},
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
    });

    group('when reading a conversation', () {
      test('then another user cannot see it', () async {
        await subscribe(rawSession, userId);
        final budget = await createBudget();
        useMock([_textResponse('Hello.')]);
        final events = await endpoints.agent
            .chat(authedSession, budget.id!, null, 'Hi')
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
          endpoints.agent.listConversations(other.session, budget.id!),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('when the agent is not signed in', () {
      test('then it rejects the caller', () async {
        final budget = await createBudget();
        final anonymous = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );

        await expectLater(
          endpoints.agent.listConversations(anonymous, budget.id!),
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
