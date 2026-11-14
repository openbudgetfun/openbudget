import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_source.dart';

part 'assistant_cited_reply.freezed.dart';

/// A Money guide reply split into running text and numbered citations, ready
/// to draw.
@freezed
abstract class AssistantCitedReply with _$AssistantCitedReply {
  const factory AssistantCitedReply({
    /// The reply in reading order.
    required List<AssistantReplySegment> segments,

    /// Every source the reply cites, in number order.
    required List<AssistantNumberedSource> sources,
  }) = _AssistantCitedReply;

  const AssistantCitedReply._();

  /// Whether the reply cites anything.
  bool get hasSources => sources.isNotEmpty;

  /// How many distinct citation numbers the reply uses.
  int get citationCount =>
      sources.map((source) => source.number).toSet().length;
}

/// One run of a reply: plain text, or a citation drawn as a numbered chip.
@freezed
sealed class AssistantReplySegment with _$AssistantReplySegment {
  /// Words of the reply.
  const factory AssistantReplySegment.text(String text) = AssistantReplyText;

  /// A `[^key]` marker, shown as its number.
  const factory AssistantReplySegment.citation({
    required int number,
    required String key,

    /// The title of the key's first source, for the chip's spoken label.
    required String title,
  }) = AssistantReplyCitation;
}

/// A source with the number its key was given in the reply.
@freezed
abstract class AssistantNumberedSource with _$AssistantNumberedSource {
  const factory AssistantNumberedSource({
    required int number,
    required AssistantSource source,
  }) = _AssistantNumberedSource;
}

/// The `[^key]` marker the server leaves in a reply.
final _citationMarker = RegExp(r'\[\^([^\]\s]+)\]');

/// Splits [text] at its `[^key]` markers and numbers the keys.
///
/// Keys are numbered from 1 in order of first appearance, and a key cited
/// again reuses its number. A marker whose key has no source is dropped: the
/// server strips unresolved keys, so this only guards against an older or
/// partial reply. A source whose key never appears in the text is still
/// listed, numbered after the cited ones, so no source the server sent goes
/// missing.
AssistantCitedReply parseCitedReply(
  String text,
  List<AssistantSource> sources,
) {
  final byKey = <String, List<AssistantSource>>{};
  for (final source in sources) {
    byKey.putIfAbsent(source.key, () => []).add(source);
  }

  final numbers = <String, int>{};
  final segments = <AssistantReplySegment>[];
  final pending = StringBuffer();

  void flushText() {
    if (pending.isEmpty) return;
    segments.add(AssistantReplySegment.text(pending.toString()));
    pending.clear();
  }

  var cursor = 0;
  for (final match in _citationMarker.allMatches(text)) {
    pending.write(text.substring(cursor, match.start));
    cursor = match.end;

    final key = match.group(1)!;
    final keySources = byKey[key];
    if (keySources == null) continue;

    flushText();
    final number = numbers.putIfAbsent(key, () => numbers.length + 1);
    segments.add(
      AssistantReplySegment.citation(
        number: number,
        key: key,
        title: keySources.first.title,
      ),
    );
  }
  pending.write(text.substring(cursor));
  flushText();

  for (final key in byKey.keys) {
    numbers.putIfAbsent(key, () => numbers.length + 1);
  }

  final numbered = [
    for (final MapEntry(:key, value: number) in numbers.entries)
      for (final source in byKey[key]!)
        AssistantNumberedSource(number: number, source: source),
  ];

  return AssistantCitedReply(segments: segments, sources: numbered);
}
