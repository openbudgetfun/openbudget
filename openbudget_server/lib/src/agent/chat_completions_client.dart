import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openbudget_server/src/agent/agent_pricing.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';

/// Token counts a provider reports for one completion.
class ChatCompletionUsage {
  const ChatCompletionUsage({
    required this.promptTokens,
    required this.cachedTokens,
    required this.completionTokens,
  });

  factory ChatCompletionUsage.fromJson(Map<String, Object?> json) {
    final details = json['prompt_tokens_details'];
    final cached = details is Map<String, Object?>
        ? _asInt(details['cached_tokens'])
        : 0;
    return ChatCompletionUsage(
      promptTokens: _asInt(json['prompt_tokens']),
      cachedTokens: cached,
      completionTokens: _asInt(json['completion_tokens']),
    );
  }

  /// No usage was reported, so nothing can be charged.
  static const empty = ChatCompletionUsage(
    promptTokens: 0,
    cachedTokens: 0,
    completionTokens: 0,
  );

  final int promptTokens;

  /// Prompt tokens the provider served from its cache.
  final int cachedTokens;

  final int completionTokens;

  /// The cost of this call at the built-in provider's prices.
  int get costMicroUsd => AgentPricing.costMicroUsd(
    promptTokens: promptTokens,
    cachedTokens: cachedTokens,
    completionTokens: completionTokens,
  );

  static int _asInt(Object? value) => switch (value) {
    final int number => number < 0 ? 0 : number,
    final num number => number < 0 ? 0 : number.toInt(),
    _ => 0,
  };
}

/// One tool call the model asked for.
class ChatCompletionToolCall {
  const ChatCompletionToolCall({
    required this.id,
    required this.name,
    required this.argumentsJson,
  });

  factory ChatCompletionToolCall.fromJson(
    Map<String, Object?> json,
    int index,
  ) {
    final function = json['function'];
    final name = function is Map<String, Object?> ? function['name'] : null;
    if (name is! String || name.isEmpty) {
      throw AgentProviderException(
        'The provider returned a tool call without a function name.',
      );
    }
    final rawArguments = function is Map<String, Object?>
        ? function['arguments']
        : null;
    return ChatCompletionToolCall(
      id: switch (json['id']) {
        final String id when id.isNotEmpty => id,
        _ => 'call_$index',
      },
      name: name,
      argumentsJson: switch (rawArguments) {
        final String arguments => arguments,
        final Map<String, Object?> arguments => jsonEncode(arguments),
        null => '{}',
        _ => jsonEncode(rawArguments),
      },
    );
  }

  final String id;
  final String name;

  /// The arguments as a JSON string, ready to decode.
  final String argumentsJson;

  /// The wire form used for both persisted history and assistant messages.
  Map<String, Object?> toJson() => {
    'id': id,
    'type': 'function',
    'function': {'name': name, 'arguments': argumentsJson},
  };
}

/// The assistant message one completion produced.
class ChatCompletionMessage {
  const ChatCompletionMessage({required this.content, required this.toolCalls});

  final String? content;
  final List<ChatCompletionToolCall> toolCalls;
}

/// One non-streamed completion plus its usage.
class ChatCompletionResult {
  const ChatCompletionResult({required this.message, required this.usage});

  final ChatCompletionMessage message;
  final ChatCompletionUsage usage;
}

/// Talks to an OpenAI-compatible Chat Completions endpoint.
///
/// The request is deliberately small: the model, the messages, the tools and
/// `stream: false`. No user identity is sent, and the API key only ever goes
/// in the `Authorization` header of the provider that issued it.
class ChatCompletionsClient {
  ChatCompletionsClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const Duration requestTimeout = Duration(seconds: 90);

  final http.Client _httpClient;

  Future<ChatCompletionResult> complete({
    required Uri endpoint,
    required String apiKey,
    required String model,
    required List<Map<String, Object?>> messages,
    required List<Map<String, Object?>> tools,
  }) async {
    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'tools': tools,
      'tool_choice': 'auto',
      'stream': false,
    });

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            endpoint,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw AgentProviderException('The provider did not answer in time.');
    } on http.ClientException catch (error) {
      throw AgentProviderException(
        'The provider request failed: ${error.message}',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AgentProviderException(
        'The provider returned HTTP ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw AgentProviderException('The provider did not return JSON.');
    }
    if (decoded is! Map<String, Object?>) {
      throw AgentProviderException(
        'The provider returned an unexpected response shape.',
      );
    }
    return _parse(decoded);
  }

  ChatCompletionResult _parse(Map<String, Object?> json) {
    final choices = json['choices'];
    if (choices is! List || choices.isEmpty) {
      throw AgentProviderException('The provider returned no choices.');
    }
    final choice = choices.first;
    final message = choice is Map<String, Object?> ? choice['message'] : null;
    if (message is! Map<String, Object?>) {
      throw AgentProviderException('The provider returned no message.');
    }

    final rawToolCalls = message['tool_calls'];
    final toolCalls = <ChatCompletionToolCall>[];
    if (rawToolCalls is List) {
      for (var index = 0; index < rawToolCalls.length; index++) {
        final raw = rawToolCalls[index];
        if (raw is Map<String, Object?>) {
          toolCalls.add(ChatCompletionToolCall.fromJson(raw, index));
        }
      }
    }

    final usage = json['usage'];
    return ChatCompletionResult(
      message: ChatCompletionMessage(
        content: message['content'] as String?,
        toolCalls: toolCalls,
      ),
      usage: usage is Map<String, Object?>
          ? ChatCompletionUsage.fromJson(usage)
          : ChatCompletionUsage.empty,
    );
  }
}
