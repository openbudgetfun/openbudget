import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_notes.freezed.dart';
part 'release_notes.g.dart';

/// One release's notes, as written by monochange into
/// `assets/release_notes/<version>.json`.
@freezed
abstract class ReleaseNotes with _$ReleaseNotes {
  const factory ReleaseNotes({
    required String title,
    @Default(<String>[]) List<String> summary,
    @Default(<ReleaseNotesSection>[]) List<ReleaseNotesSection> sections,
  }) = _ReleaseNotes;

  factory ReleaseNotes.fromJson(Map<String, dynamic> json) =>
      _$ReleaseNotesFromJson(json);
}

/// A group of entries under one heading, such as "New" or "Fixed".
@freezed
abstract class ReleaseNotesSection with _$ReleaseNotesSection {
  const factory ReleaseNotesSection({
    required String title,
    @Default(false) bool collapsed,
    @Default(<ReleaseNotesEntry>[]) List<ReleaseNotesEntry> entries,
  }) = _ReleaseNotesSection;

  factory ReleaseNotesSection.fromJson(Map<String, dynamic> json) =>
      _$ReleaseNotesSectionFromJson(json);
}

/// One change someone can read about in the What's new sheet.
///
/// [detailsMarkdown] is deliberately a small subset of Markdown: paragraphs,
/// `- ` bullets, and `**bold**`. The app renders it without a Markdown
/// package.
@freezed
abstract class ReleaseNotesEntry with _$ReleaseNotesEntry {
  const factory ReleaseNotesEntry({
    required String summary,
    @JsonKey(name: 'details_markdown') @Default('') String detailsMarkdown,
    @JsonKey(name: 'change_type') String? changeType,
  }) = _ReleaseNotesEntry;

  factory ReleaseNotesEntry.fromJson(Map<String, dynamic> json) =>
      _$ReleaseNotesEntryFromJson(json);
}
