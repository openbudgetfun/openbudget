import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

import '../../integration/helpers/auth_helper.dart';
import '../../integration/test_tools/serverpod_test_tools.dart';
import 'eval_fixtures.dart';
import 'eval_grader.dart';
import 'golden_schema.dart';

/// The encryption key the tests give the session so a provider key can be
/// stored. It protects nothing: the database rolls back after each test.
const String _testEncryptionKey =
    'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';

final RegExp _citationMarker = RegExp(r'\[\^[A-Za-z0-9][A-Za-z0-9_-]*\]');

/// What one model call returned, as far as the grader needs it.
final class RecordedCompletion {
  const RecordedCompletion({required this.content, required this.usage});

  /// The assistant text before the server resolved its citation keys.
  final String? content;

  final ChatCompletionUsage usage;
}

/// An HTTP client that forwards to [inner] and remembers each completion's
/// text and token usage, so the harness can see what the model wrote before
/// the server stripped unresolved citation keys, and what the call cost.
///
/// It keeps responses in memory for the current run only and never logs.
final class RecordingClient extends http.BaseClient {
  RecordingClient(this.inner);

  /// The client that really answers: a replay in the offline test, the
  /// network in the live one.
  http.Client inner;

  final List<RecordedCompletion> completions = [];

  /// Forgets the previous run.
  void reset() => completions.clear();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await inner.send(request);
    final bytes = await response.stream.toBytes();
    _remember(utf8.decode(bytes, allowMalformed: true));
    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => inner.close();

  void _remember(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, Object?>) return;
    final choices = decoded['choices'];
    // An error body is not a completion and costs nothing.
    if (choices is! List || choices.isEmpty) return;
    final first = choices.first;
    final message = first is Map<String, Object?> ? first['message'] : null;
    final usage = decoded['usage'];
    completions.add(
      RecordedCompletion(
        content: message is Map<String, Object?>
            ? message['content'] as String?
            : null,
        usage: usage is Map<String, Object?>
            ? ChatCompletionUsage.fromJson(usage)
            : ChatCompletionUsage.empty,
      ),
    );
  }
}

/// Drives the real `AgentService` (the Money guide prompt, the tools and the
/// citation resolver) one golden question at a time, over a transport the
/// caller chooses.
///
/// The user's provider is a bring-your-own provider, which needs no
/// subscription, so a run depends on nothing but the transport. Each run is
/// a fresh conversation on the fixture's entity.
final class EvalHarness {
  EvalHarness._({
    required this.transport,
    required this._endpoints,
    required this._authedSession,
    required this._rawSession,
    required this.fixtures,
  });

  /// Starts a harness whose model calls go through [transport]. The provider
  /// settings hold [baseUrl], [model] and [apiKey]; the key only ever goes to
  /// that provider's `Authorization` header.
  static Future<EvalHarness> start({
    required TestSessionBuilder sessionBuilder,
    required TestEndpoints endpoints,
    required Map<String, EvalFixture> fixtures,
    required RecordingClient transport,
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async {
    final user = await createAuthenticatedUser(sessionBuilder);
    final rawSession = sessionBuilder.build()
      ..updateAuthenticated(
        AuthenticationInfo(
          user.userId.toString(),
          const {},
          authId: 'money-guide-eval-${user.userId}',
        ),
      )
      ..passwords['agentKeyEncryptionKey'] = _testEncryptionKey;
    await endpoints.agent.saveProviderSettings(
      user.session,
      baseUrl,
      model,
      apiKey,
    );
    AgentService.chatClientOverride = ChatCompletionsClient(
      httpClient: transport,
    );
    return EvalHarness._(
      transport: transport,
      endpoints: endpoints,
      authedSession: user.session,
      rawSession: rawSession,
      fixtures: fixtures,
    );
  }

  final RecordingClient transport;
  final Map<String, EvalFixture> fixtures;
  final TestEndpoints _endpoints;
  final TestSessionBuilder _authedSession;
  final Session _rawSession;
  final Map<String, Entity> _entities = {};

  /// The seeded entity of [fixtureId], created on first use.
  Future<Entity> entityFor(String fixtureId) async {
    final cached = _entities[fixtureId];
    if (cached != null) return cached;
    final fixture = fixtures[fixtureId];
    if (fixture == null) {
      throw StateError('Unknown fixture "$fixtureId".');
    }
    return _entities[fixtureId] = await _endpoints.entity.create(
      _authedSession,
      'Money guide eval ${fixture.id}',
      fixture.kind,
      fixture.countryCode,
      fixture.currencyCode,
      fixture.timeZone,
    );
  }

  /// Asks [ask] against [fixtureId] and records the turn.
  Future<EvalRun> run({
    required String questionId,
    required String ask,
    required String fixtureId,
    int runIndex = 0,
  }) async {
    final entity = await entityFor(fixtureId);
    transport.reset();

    final events = <AgentEvent>[];
    String? error;
    try {
      await _endpoints.agent
          .chat(_authedSession, entity.id!, null, ask)
          .forEach(events.add);
    } on AgentProviderException {
      error = 'AgentProviderException';
    }

    final replies = events
        .where((event) => event.kind == AgentEventKind.textDelta)
        .toList();
    final finalReply = replies.isEmpty ? null : replies.last;
    final conversationId = events.firstOrNull?.conversationId;

    return EvalRun(
      questionId: questionId,
      runIndex: runIndex,
      replyText: finalReply?.text ?? '',
      toolsCalled: [
        for (final event in events)
          if (event.kind == AgentEventKind.toolCall) event.toolName!,
      ],
      resolvedKeys: {
        for (final citation in finalReply?.citations ?? const <AgentCitation>[])
          citation.key,
      },
      strippedCount: conversationId == null
          ? 0
          : await _strippedCount(conversationId),
      promptTokens: _sum((usage) => usage.promptTokens),
      cachedTokens: _sum((usage) => usage.cachedTokens),
      completionTokens: _sum((usage) => usage.completionTokens),
      modelCalls: transport.completions.length,
      costMicroUsd: _sum((usage) => usage.costMicroUsd),
      error: error,
    );
  }

  /// Asks [question] against the fixture of its file.
  Future<EvalRun> runQuestion(
    GoldenFile file,
    GoldenQuestion question, {
    int runIndex = 0,
  }) => run(
    questionId: question.id,
    ask: question.ask,
    fixtureId: file.fixture,
    runIndex: runIndex,
  );

  /// Restores the transport and the passwords the harness changed.
  void close() {
    AgentService.chatClientOverride = null;
    AgentEgressGuard.lookup = InternetAddress.lookup;
    _rawSession.passwords.remove('agentKeyEncryptionKey');
  }

  int _sum(int Function(ChatCompletionUsage usage) field) => transport
      .completions
      .fold<int>(0, (total, completion) => total + field(completion.usage));

  /// The citation markers the model wrote minus the ones the server kept in
  /// the stored replies: the markers it stripped.
  Future<int> _strippedCount(UuidValue conversationId) async {
    final written = transport.completions.fold<int>(
      0,
      (total, completion) =>
          total + _citationMarker.allMatches(completion.content ?? '').length,
    );
    final stored = await AgentMessage.db.find(
      _rawSession,
      where: (t) =>
          t.conversationId.equals(conversationId) &
          t.role.equals(AgentMessageRole.assistant),
    );
    final kept = stored.fold<int>(
      0,
      (total, message) =>
          total + _citationMarker.allMatches(message.content).length,
    );
    return written > kept ? written - kept : 0;
  }
}
