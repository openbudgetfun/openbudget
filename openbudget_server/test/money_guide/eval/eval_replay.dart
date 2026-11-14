import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'eval_fixtures.dart';

const int _defaultPromptTokens = 1200;
const int _defaultCompletionTokens = 150;

/// A transport that answers each request with the next step of `recording`,
/// in the shape an OpenAI-compatible endpoint returns. `entityId` fills the
/// `{{entityId}}` placeholder of tool arguments. Request bodies land in
/// `requests` so a test can check what the real prompt sent.
final class ReplayTransport {
  ReplayTransport(EvalRecording recording, {required String entityId})
    : _responses = [
        for (final step in recording.steps) _wire(step, entityId),
      ] {
    client = MockClient((request) async {
      requests.add(request.body);
      final index = requests.length - 1;
      if (index >= _responses.length) {
        // The recording ran out: the model asked for more calls than were
        // recorded, which the replay reports as a provider failure.
        return http.Response('{"error":"recording exhausted"}', 500);
      }
      return http.Response(
        jsonEncode(_responses[index]),
        200,
        headers: const {'content-type': 'application/json'},
      );
    });
  }

  final List<Map<String, Object?>> _responses;

  /// The request bodies the real service sent, in order.
  final List<String> requests = [];

  late final http.Client client;

  static Map<String, Object?> _wire(RecordedStep step, String entityId) {
    final cached = step.cachedTokens ?? 0;
    final usage = <String, Object?>{
      'prompt_tokens': step.promptTokens ?? _defaultPromptTokens,
      'completion_tokens': step.completionTokens ?? _defaultCompletionTokens,
      'prompt_tokens_details': {'cached_tokens': cached},
    };
    final message = switch (step) {
      RecordedReply(:final text) => {'role': 'assistant', 'content': text},
      RecordedToolCall(:final name, :final arguments) => {
        'role': 'assistant',
        'content': null,
        'tool_calls': [
          {
            'id': 'call_replay',
            'type': 'function',
            'function': {
              'name': name,
              'arguments': jsonEncode(_fill(arguments, entityId)),
            },
          },
        ],
      },
    };
    return {
      'id': 'chatcmpl-replay',
      'object': 'chat.completion',
      'model': 'recorded',
      'choices': [
        {
          'index': 0,
          'message': message,
          'finish_reason': step is RecordedToolCall ? 'tool_calls' : 'stop',
        },
      ],
      'usage': usage,
    };
  }

  static Object? _fill(Object? value, String entityId) => switch (value) {
    '{{entityId}}' => entityId,
    final Map<Object?, Object?> map => {
      for (final entry in map.entries) entry.key: _fill(entry.value, entityId),
    },
    final List<Object?> list => [
      for (final item in list) _fill(item, entityId),
    ],
    _ => value,
  };
}
