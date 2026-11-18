import 'dart:convert';
import 'dart:math' as math;

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/citation_resolver.dart';
import 'package:openbudget_server/src/money_guide/money_guide_prompt.dart';

/// The conversation part of one model call after compaction.
final class ContextWindow {
  const ContextWindow({
    required this.messages,
    required this.historyTokens,
    required this.compactionPositions,
    required this.elidedResults,
    required this.squeezedResults,
    required this.fits,
  });

  /// The history as chat messages, oldest first.
  final List<Map<String, Object?>> messages;

  /// The estimated tokens of [messages].
  final int historyTokens;

  /// The index in [messages] at which each compaction of the conversation
  /// fired, oldest first. Its length is how many times the conversation has
  /// crossed the high-water mark.
  final List<int> compactionPositions;

  /// How many tool results are replaced by an elision stub in this window.
  final int elidedResults;

  /// How many of those were elided only to stay under the ceiling, after
  /// compaction had already run.
  final int squeezedResults;

  /// False when even a history with every tool result elided is over the
  /// ceiling, so the call must not be made.
  final bool fits;
}

/// Keeps every model call under the context ceiling (docs/money-guide.md,
/// sections 5.4 and 9.3).
///
/// **Compaction with hysteresis.** When the history of a call passes
/// [highWaterTokens], the bodies of tool results older than the last
/// [keptTurns] turns are replaced by `{"elided": true, "tool": "...",
/// "citeAs": "..."}`. The history then sits well under the mark and nothing
/// more happens until it crosses again, so the provider's prompt cache breaks
/// once per crossing and not on every call. The doc sets no separate
/// low-water mark: it is whatever the history measures after the elision.
///
/// **Nothing is stored.** The compaction is a pure function of the stored
/// rows, replayed from the first message on every call. Replaying gives the
/// same boundaries every time, so later turns reuse earlier compactions
/// byte for byte without a column to keep them in. The rows themselves are
/// never rewritten, so the citation catalogue, which reads the stored tool
/// results, still resolves every key an elided result carried.
///
/// **The ceiling.** If a window is still over [ceilingTokens] after
/// compaction, for example because one turn fetched very large results,
/// tool results are elided oldest first, for this call only, until it fits.
/// If it cannot fit even then, [ContextWindow.fits] is false.
abstract final class ContextBudget {
  /// The most estimated tokens one model call may carry.
  static const int ceilingTokens = 40000;

  /// The estimated tokens of history that start a compaction.
  static const int highWaterTokens = 32000;

  /// How many of the newest turns keep their tool results.
  static const int keptTurns = 2;

  /// The most estimated tokens one user message may carry. It leaves room
  /// under the ceiling for a turn of tool traffic after it.
  static const int maxMessageTokens = 4000;

  /// Tokens set aside for the request fields around the messages and tools,
  /// such as the model name and the streaming flag.
  static const int requestOverheadTokens = 100;

  /// Builds the history of the next call from the conversation's stored
  /// [messages], oldest first.
  ///
  /// [fixedTokens] is the estimate of everything else the call carries: the
  /// system messages and the tool definitions.
  static ContextWindow window(
    List<AgentMessage> messages, {
    required int fixedTokens,
  }) {
    final entries = _entriesOf(messages);
    final ceiling = ceilingTokens - fixedTokens - requestOverheadTokens;
    final highWater = math.min(highWaterTokens, ceiling);

    var elideBefore = 0;
    final positions = <int>[];
    var tokens = 0;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      tokens += entry.tokensWhenElidingBefore(elideBefore);
      // A model call follows a user message and a batch of tool results.
      if (!entry.precedesModelCall || tokens <= highWater) continue;

      final boundary = entry.turn - (keptTurns - 1);
      if (boundary <= elideBefore) continue;
      elideBefore = boundary;
      positions.add(index);
      tokens = _tokensOf(entries.take(index + 1), elideBefore);
    }

    final squeezed = <int>{};
    var overflow = tokens - ceiling;
    for (var index = 0; index < entries.length && overflow > 0; index++) {
      final entry = entries[index];
      if (!entry.canElide || entry.turn < elideBefore) continue;
      squeezed.add(index);
      overflow -= entry.fullTokens - entry.stubTokens;
    }

    final output = <Map<String, Object?>>[];
    var outputTokens = 0;
    var elided = 0;
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final isElided =
          entry.canElide &&
          (entry.turn < elideBefore || squeezed.contains(index));
      if (isElided) elided++;
      output.add(isElided ? entry.stub! : entry.full);
      outputTokens += isElided ? entry.stubTokens : entry.fullTokens;
    }

    return ContextWindow(
      messages: output,
      historyTokens: outputTokens,
      compactionPositions: positions,
      elidedResults: elided,
      squeezedResults: squeezed.length,
      fits: overflow <= 0,
    );
  }

  static int _tokensOf(Iterable<_Entry> entries, int elideBefore) =>
      entries.fold(
        0,
        (sum, entry) => sum + entry.tokensWhenElidingBefore(elideBefore),
      );

  static List<_Entry> _entriesOf(List<AgentMessage> messages) {
    final entries = <_Entry>[];
    final toolNames = <String, String>{};
    var turn = 0;
    var seenUser = false;
    for (final message in messages) {
      switch (message.role) {
        case AgentMessageRole.user:
          if (seenUser) turn++;
          seenUser = true;
          entries.add(
            _Entry(
              turn: turn,
              full: {'role': 'user', 'content': message.content},
              precedesModelCall: true,
            ),
          );
        case AgentMessageRole.assistant:
          final toolCalls = _decodeToolCalls(message.toolCallsJson);
          for (final call in toolCalls ?? const <Object?>[]) {
            if (call is! Map<String, Object?>) continue;
            final function = call['function'];
            final id = call['id'];
            if (id is String && function is Map<String, Object?>) {
              final name = function['name'];
              if (name is String) toolNames[id] = name;
            }
          }
          entries.add(
            _Entry(
              turn: turn,
              full: {
                'role': 'assistant',
                'content': message.content.isEmpty ? null : message.content,
                'tool_calls': ?toolCalls,
              },
            ),
          );
        case AgentMessageRole.tool:
          final toolCallId = message.toolCallId;
          if (toolCallId == null) continue;
          entries.add(
            _Entry(
              turn: turn,
              full: {
                'role': 'tool',
                'tool_call_id': toolCallId,
                'content': message.content,
              },
              stub: {
                'role': 'tool',
                'tool_call_id': toolCallId,
                'content': _stubFor(toolNames[toolCallId], message.content),
              },
              precedesModelCall: true,
            ),
          );
      }
    }
    return entries;
  }

  /// `{"elided": true, "tool": "...", "citeAs": "..."}`: what is left of a
  /// tool result. The keys it made citable stay named, so the model can still
  /// cite them, and the stored result keeps them resolvable.
  static String _stubFor(String? toolName, String content) {
    final keys = (CitationCatalogue()..addToolResult(content)).keys.toList();
    return jsonEncode({
      'elided': true,
      'tool': ?toolName,
      if (keys.length == 1) 'citeAs': keys.single,
      if (keys.length > 1) 'citeAs': keys,
    });
  }

  static List<Object?>? _decodeToolCalls(String? json) {
    if (json == null || json.isEmpty) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return null;
    }
    return decoded is List ? decoded : null;
  }
}

/// One chat message of the history, with the stub that can replace it.
final class _Entry {
  _Entry({
    required this.turn,
    required this.full,
    Map<String, Object?>? stub,
    this.precedesModelCall = false,
  }) : fullTokens = estimateTokens(jsonEncode(full)),
       stubTokens = stub == null ? 0 : estimateTokens(jsonEncode(stub)),
       stub = stub;

  /// The index of the turn the message belongs to; each user message starts
  /// one.
  final int turn;

  final Map<String, Object?> full;
  final int fullTokens;

  /// What replaces a tool result. Null for every other message.
  final Map<String, Object?>? stub;
  final int stubTokens;

  /// True for a user message and a tool result: a model call comes next.
  final bool precedesModelCall;

  /// A result smaller than its stub gains nothing from being elided.
  bool get canElide => stub != null && stubTokens < fullTokens;

  int tokensWhenElidingBefore(int elideBefore) =>
      canElide && turn < elideBefore ? stubTokens : fullTokens;
}
