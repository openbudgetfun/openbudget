import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

part 'assistant_source.freezed.dart';

/// One source behind a citation in a Money guide reply, detached from the
/// server model.
///
/// A citation key can resolve to several sources: a knowledge card lists each
/// of its sources, and a tax report lists the authority pages it used.
@freezed
abstract class AssistantSource with _$AssistantSource {
  const factory AssistantSource({
    /// The key the reply cites it by, as in `[^key]`.
    required String key,

    /// What the source is called.
    required String title,

    /// Where the source lives.
    required String url,

    /// Who publishes it: the source's website without `www.`.
    required String authority,

    /// How firmly the source backs the rule, or null for a grade this app
    /// does not know yet.
    required SourceGrade? grade,

    /// Whether the source describes a rule that is announced but not yet law.
    required bool announced,

    /// When the source was last checked.
    DateTime? verifiedOn,
  }) = _AssistantSource;
}

/// Maps one streamed or stored citation to its source.
AssistantSource assistantSourceFrom(AgentCitation citation) => AssistantSource(
  key: citation.key,
  title: citation.title,
  url: citation.url,
  authority: citation.authority,
  grade: _gradeFrom(citation.grade),
  announced: citation.announced,
  verifiedOn: citation.verifiedOn,
);

/// Reads the sources a stored message carries in its `citationsJson`.
///
/// A message stored before citations existed has no JSON and no sources.
List<AssistantSource> assistantSourcesFromJson(String? citationsJson) {
  if (citationsJson == null || citationsJson.isEmpty) return const [];
  final decoded = jsonDecode(citationsJson);
  if (decoded is! List<Object?>) {
    throw FormatException('citationsJson is not a list', citationsJson);
  }
  return [
    for (final item in decoded)
      if (item is Map<String, dynamic>)
        assistantSourceFrom(AgentCitation.fromJson(item))
      else
        throw FormatException('citation is not an object', citationsJson),
  ];
}

SourceGrade? _gradeFrom(String grade) => switch (grade) {
  'primary' => SourceGrade.primary,
  'secondary' => SourceGrade.secondary,
  'inferred' => SourceGrade.inferred,
  'background' => SourceGrade.background,
  _ => null,
};
