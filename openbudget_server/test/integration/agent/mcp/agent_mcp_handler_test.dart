import 'dart:convert';

import 'package:openbudget_server/src/agent/mcp/agent_access_token_service.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_handler.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_rate_limiter.dart';
import 'package:openbudget_server/src/agent/mcp/agent_mcp_response.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../../helpers/auth_helper.dart';
import '../../test_tools/serverpod_test_tools.dart';

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '50000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

String _request(
  String method, {
  Object? id = 1,
  Map<String, Object?>? params,
}) => jsonEncode({
  'jsonrpc': '2.0',
  'id': id,
  'method': method,
  'params': ?params,
});

Map<String, Object?> _body(AgentMcpResponse response) =>
    jsonDecode(response.body) as Map<String, Object?>;

Map<String, Object?> _error(AgentMcpResponse response) =>
    _body(response)['error']! as Map<String, Object?>;

Map<String, Object?> _result(AgentMcpResponse response) =>
    _body(response)['result']! as Map<String, Object?>;

String _month(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

void main() {
  withServerpod('Given AgentMcpHandler', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late String secret;

    setUp(() async {
      final user = _newUser(sessionBuilder);
      authedSession = user.session;
      userId = user.userId;
      rawSession = sessionBuilder.build();
      rawSession.passwords.remove(AgentMcpHandler.allowedOriginsPassword);
      final created = await AgentAccessTokenService().create(
        rawSession,
        userId: userId,
        name: 'Claude Code',
        canPropose: true,
      );
      secret = created.token;
    });

    Future<String> createToken({bool canPropose = true}) async {
      final created = await AgentAccessTokenService().create(
        rawSession,
        userId: userId,
        name: canPropose ? 'Writer' : 'Reader',
        canPropose: canPropose,
      );
      return created.token;
    }

    Future<AgentMcpResponse> send(
      String body, {
      AgentMcpHandler? handler,
      String? token,
      String? origin,
      String method = 'POST',
    }) => (handler ?? AgentMcpHandler()).handle(
      rawSession,
      httpMethod: method,
      rawBody: body,
      authorization: 'Bearer ${token ?? secret}',
      origin: origin,
    );

    Future<Budget> createBudget(String name) =>
        endpoints.budget.create(authedSession, name, 'GBP');

    Future<({Budget budget, Envelope from, Envelope to, String month})>
    createMoveSetup() async {
      final budget = await createBudget('Household');
      final category = await endpoints.category.create(
        authedSession,
        'Everyday',
        budget.id!,
        0,
      );
      final from = await endpoints.envelope.create(
        authedSession,
        'Groceries',
        category.id!,
        10000,
        'GBP',
      );
      final to = await endpoints.envelope.create(
        authedSession,
        'Dining',
        category.id!,
        0,
        'GBP',
      );
      return (
        budget: budget,
        from: from,
        to: to,
        month: _month(DateTime.now()),
      );
    }

    group('when initializing', () {
      test('then it negotiates a supported version', () async {
        final response = await send(
          _request(
            'initialize',
            params: {
              'protocolVersion': '2025-03-26',
              'capabilities': <String, Object?>{},
              'clientInfo': {'name': 'test', 'version': '1.0.0'},
            },
          ),
        );

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/json');
        final result = _result(response);
        expect(result['protocolVersion'], '2025-03-26');
        expect(result['capabilities'], {
          'tools': {'listChanged': false},
        });
        expect(result['serverInfo'], {
          'name': 'openbudget',
          'version': '1.0.0',
        });
        expect(result['instructions'], contains('guidance'));
        expect(result['instructions'], contains('proposals'));
      });

      test('then an unknown version falls back to the newest', () async {
        final response = await send(
          _request(
            'initialize',
            params: {'protocolVersion': '2024-01-01'},
          ),
        );

        expect(_result(response)['protocolVersion'], '2025-06-18');
      });

      test('then every supported version is echoed', () async {
        for (final version in AgentMcpHandler.supportedProtocolVersions) {
          final response = await send(
            _request(
              'initialize',
              params: {'protocolVersion': version},
            ),
          );
          expect(_result(response)['protocolVersion'], version);
        }
      });
    });

    group('when receiving notifications', () {
      test('then it answers 202 with an empty body', () async {
        final response = await send(
          jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
        );

        expect(response.statusCode, 202);
        expect(response.body, isEmpty);
      });
    });

    group('when pinging', () {
      test('then it returns an empty result', () async {
        final response = await send(_request('ping'));

        expect(response.statusCode, 200);
        expect(_result(response), isEmpty);
      });
    });

    group('when listing tools', () {
      test('then read-only tokens see only the read tools', () async {
        final readOnly = await createToken(canPropose: false);
        final response = await send(
          _request('tools/list'),
          token: readOnly,
        );

        final tools = _result(response)['tools']! as List<Object?>;
        final names = [
          for (final tool in tools)
            (tool! as Map<String, Object?>)['name']! as String,
        ];
        expect(names, hasLength(5));
        expect(names, contains('list_budgets'));
        expect(names, contains('list_envelopes'));
        expect(names, contains('search_transactions'));
        expect(names, contains('get_tax_report'));
        expect(names, contains('list_tax_categories'));
        expect(names, isNot(contains('propose_move_money')));
        expect(names, isNot(contains('propose_transaction_tax_category')));
        expect(names, isNot(contains('propose_envelope_tax_category')));

        final first = tools.first! as Map<String, Object?>;
        expect(first.keys, containsAll(['name', 'description', 'inputSchema']));
        expect(first.containsKey('function'), isFalse);
        expect(first['inputSchema'], isA<Map<String, Object?>>());
      });

      test('then write tokens see the propose tools too', () async {
        final response = await send(_request('tools/list'));

        final tools = _result(response)['tools']! as List<Object?>;
        final names = [
          for (final tool in tools)
            (tool! as Map<String, Object?>)['name']! as String,
        ];
        expect(names, hasLength(8));
        expect(names, contains('propose_move_money'));
        expect(names, contains('propose_transaction_tax_category'));
        expect(names, contains('propose_envelope_tax_category'));
      });
    });

    group('when calling a read tool', () {
      test("then it returns only the token owner's data", () async {
        final mine = await createBudget('Mine');
        final other = _newUser(sessionBuilder);
        await endpoints.budget.create(other.session, 'Theirs', 'GBP');

        final response = await send(
          _request(
            'tools/call',
            params: {'name': 'list_budgets', 'arguments': <String, Object?>{}},
          ),
        );

        expect(response.statusCode, 200);
        final result = _result(response);
        expect(result['isError'], isFalse);
        final content = result['content']! as List<Object?>;
        final text =
            (content.single! as Map<String, Object?>)['text']! as String;
        final budgets =
            (jsonDecode(text) as Map<String, Object?>)['budgets']!
                as List<Object?>;
        expect(budgets, hasLength(1));
        expect(
          (budgets.single! as Map<String, Object?>)['name'],
          mine.name,
        );
      });

      test('then a tool error is flagged in the MCP result', () async {
        final response = await send(
          _request(
            'tools/call',
            params: {
              'name': 'list_envelopes',
              'arguments': {'budgetId': 'not-a-uuid'},
            },
          ),
        );

        final result = _result(response);
        expect(result['isError'], isTrue);
        final content = result['content']! as List<Object?>;
        final text =
            (content.single! as Map<String, Object?>)['text']! as String;
        expect(
          jsonDecode(text),
          containsPair('error', contains('must be a UUID')),
        );
      });
    });

    group('when calling a propose tool', () {
      test('then it creates a pending proposal the user can see', () async {
        final setup = await createMoveSetup();

        final response = await send(
          _request(
            'tools/call',
            params: {
              'name': 'propose_move_money',
              'arguments': {
                'budgetId': setup.budget.id.toString(),
                'fromEnvelopeId': setup.from.id.toString(),
                'toEnvelopeId': setup.to.id.toString(),
                'amountMinor': 2500,
                'month': setup.month,
                'reason': 'Dining is short this month.',
              },
            },
          ),
        );

        final result = _result(response);
        expect(result['isError'], isFalse);
        final content = result['content']! as List<Object?>;
        final text =
            (content.single! as Map<String, Object?>)['text']! as String;
        final created = jsonDecode(text) as Map<String, Object?>;
        expect(created['status'], 'pending');
        expect(created['proposalId'], isNotNull);

        final proposals = await endpoints.agent.listProposals(
          authedSession,
          setup.budget.id!,
          pendingOnly: true,
        );
        expect(proposals, hasLength(1));
        expect(proposals.single.id.toString(), created['proposalId']);
        expect(proposals.single.kind, AgentProposalKind.moveMoney);
        expect(proposals.single.status, AgentProposalStatus.pending);
      });

      test('then a read-only token gets an error and no proposal', () async {
        final setup = await createMoveSetup();
        final readOnly = await createToken(canPropose: false);

        final response = await send(
          _request(
            'tools/call',
            params: {
              'name': 'propose_move_money',
              'arguments': {
                'budgetId': setup.budget.id.toString(),
                'fromEnvelopeId': setup.from.id.toString(),
                'toEnvelopeId': setup.to.id.toString(),
                'amountMinor': 2500,
                'month': setup.month,
                'reason': 'Dining is short this month.',
              },
            },
          ),
          token: readOnly,
        );

        expect(response.statusCode, 200);
        final result = _result(response);
        expect(result['isError'], isTrue);
        final content = result['content']! as List<Object?>;
        final text =
            (content.single! as Map<String, Object?>)['text']! as String;
        expect(text, contains('read-only'));
        expect(
          await endpoints.agent.listProposals(
            authedSession,
            setup.budget.id!,
            pendingOnly: true,
          ),
          isEmpty,
        );
      });
    });

    group('when the request is invalid', () {
      test('then a broken body is a parse error', () async {
        final response = await send('{"jsonrpc":');

        expect(response.statusCode, 400);
        expect(_error(response)['code'], -32700);
      });

      test('then a batch array is rejected', () async {
        final response = await send('[]');

        expect(response.statusCode, 400);
        expect(_error(response)['code'], -32600);
      });

      test('then a non-object body is rejected', () async {
        final response = await send('42');

        expect(response.statusCode, 400);
        expect(_error(response)['code'], -32600);
      });

      test('then a missing method is rejected', () async {
        final response = await send(
          jsonEncode({'jsonrpc': '2.0', 'id': 7}),
        );

        expect(_error(response)['code'], -32600);
        expect(_body(response)['id'], 7);
      });

      test('then an unknown method is method not found', () async {
        final response = await send(_request('tools/dance'));

        expect(response.statusCode, 200);
        expect(_error(response)['code'], -32601);
      });

      test('then missing tool parameters are invalid params', () async {
        final response = await send(
          _request('tools/call', params: {'arguments': <String, Object?>{}}),
        );

        expect(_error(response)['code'], -32602);
      });

      test('then non-object arguments are invalid params', () async {
        final response = await send(
          _request(
            'tools/call',
            params: {'name': 'list_budgets', 'arguments': 'nope'},
          ),
        );

        expect(_error(response)['code'], -32602);
      });

      test('then an unknown tool is invalid params', () async {
        final response = await send(
          _request(
            'tools/call',
            params: {'name': 'not_a_tool', 'arguments': <String, Object?>{}},
          ),
        );

        expect(_error(response)['code'], -32602);
      });
    });

    group('when authenticating', () {
      test('then a missing header is 401 with a challenge', () async {
        final response = await AgentMcpHandler().handle(
          rawSession,
          httpMethod: 'POST',
          rawBody: _request('ping'),
        );

        expect(response.statusCode, 401);
        expect(response.headers['www-authenticate'], 'Bearer');
        expect(_error(response)['code'], isA<int>());
      });

      test('then an unknown or revoked token is 401', () async {
        final unknown = await send(
          _request('ping'),
          token: AgentAccessTokenService.generateToken(),
        );
        expect(unknown.statusCode, 401);
        expect(unknown.headers['www-authenticate'], 'Bearer');
        expect(unknown.body, isNot(contains(secret)));

        final created = await AgentAccessTokenService().create(
          rawSession,
          userId: userId,
          name: 'Revoked',
          canPropose: true,
        );
        await AgentAccessTokenService().revoke(
          rawSession,
          userId: userId,
          id: created.view.id,
        );

        final revoked = await send(_request('ping'), token: created.token);
        expect(revoked.statusCode, 401);
        expect(revoked.headers['www-authenticate'], 'Bearer');
        expect(revoked.body, isNot(contains(created.token)));
      });
    });

    group('when the request comes from a browser', () {
      test('then an allow-listed origin is accepted', () async {
        rawSession.passwords[AgentMcpHandler.allowedOriginsPassword] =
            'https://app.example.com, https://second.example.com';

        final response = await send(
          _request('ping'),
          origin: 'https://second.example.com',
        );

        expect(response.statusCode, 200);
      });

      test('then any other origin is 403', () async {
        rawSession.passwords[AgentMcpHandler.allowedOriginsPassword] =
            'https://app.example.com';

        final response = await send(
          _request('ping'),
          origin: 'https://evil.example.com',
        );

        expect(response.statusCode, 403);
      });

      test('then an origin is refused when none are configured', () async {
        final response = await send(
          _request('ping'),
          origin: 'https://app.example.com',
        );

        expect(response.statusCode, 403);
      });

      test('then a request without an origin is allowed', () async {
        final response = await send(_request('ping'));

        expect(response.statusCode, 200);
      });
    });

    group('when the request method is wrong', () {
      test('then GET and DELETE are 405', () async {
        for (final method in ['GET', 'DELETE']) {
          final response = await send(_request('ping'), method: method);

          expect(response.statusCode, 405, reason: method);
          expect(response.headers['allow'], 'POST');
        }
      });
    });

    group('when a token is rate limited', () {
      test('then the fourth request in the window is 429', () async {
        final limiter = AgentMcpRateLimiter(limit: 3);
        final limited = AgentMcpHandler(rateLimiter: limiter);

        for (var index = 0; index < 3; index++) {
          final response = await send(_request('ping'), handler: limited);
          expect(response.statusCode, 200);
        }
        final response = await send(_request('ping'), handler: limited);

        expect(response.statusCode, 429);
        expect(response.headers['retry-after'], '60');
        expect(AgentMcpRateLimiter().limit, 120);
      });
    });

    group('when a token is used', () {
      test('then lastUsedAt is written at most once a minute', () async {
        var now = DateTime.utc(2026, 1, 1, 12);
        final service = AgentAccessTokenService(clock: () => now);
        final created = await service.create(
          rawSession,
          userId: userId,
          name: 'Clock',
          canPropose: false,
        );
        final clockHandler = AgentMcpHandler(tokens: service);

        await send(
          _request('ping'),
          handler: clockHandler,
          token: created.token,
        );
        var row = await AgentAccessToken.db.findById(
          rawSession,
          created.view.id,
        );
        expect(row!.lastUsedAt!.toUtc(), now);

        now = now.add(const Duration(seconds: 30));
        await send(
          _request('ping'),
          handler: clockHandler,
          token: created.token,
        );
        row = await AgentAccessToken.db.findById(rawSession, created.view.id);
        expect(row!.lastUsedAt!.toUtc(), DateTime.utc(2026, 1, 1, 12));

        now = now.add(const Duration(seconds: 31));
        await send(
          _request('ping'),
          handler: clockHandler,
          token: created.token,
        );
        row = await AgentAccessToken.db.findById(rawSession, created.view.id);
        expect(row!.lastUsedAt!.toUtc(), DateTime.utc(2026, 1, 1, 12, 1, 1));
      });
    });
  });
}
