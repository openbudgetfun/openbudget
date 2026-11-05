// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseNotes _$ReleaseNotesFromJson(
  Map<String, dynamic> json,
) => _ReleaseNotes(
  title: json['title'] as String,
  summary:
      (json['summary'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  sections:
      (json['sections'] as List<dynamic>?)
          ?.map((e) => ReleaseNotesSection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ReleaseNotesSection>[],
);

Map<String, dynamic> _$ReleaseNotesToJson(_ReleaseNotes instance) =>
    <String, dynamic>{
      'title': instance.title,
      'summary': instance.summary,
      'sections': instance.sections,
    };

_ReleaseNotesSection _$ReleaseNotesSectionFromJson(Map<String, dynamic> json) =>
    _ReleaseNotesSection(
      title: json['title'] as String,
      collapsed: json['collapsed'] as bool? ?? false,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map(
                (e) => ReleaseNotesEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <ReleaseNotesEntry>[],
    );

Map<String, dynamic> _$ReleaseNotesSectionToJson(
  _ReleaseNotesSection instance,
) => <String, dynamic>{
  'title': instance.title,
  'collapsed': instance.collapsed,
  'entries': instance.entries,
};

_ReleaseNotesEntry _$ReleaseNotesEntryFromJson(Map<String, dynamic> json) =>
    _ReleaseNotesEntry(
      summary: json['summary'] as String,
      detailsMarkdown: json['details_markdown'] as String? ?? '',
      changeType: json['change_type'] as String?,
    );

Map<String, dynamic> _$ReleaseNotesEntryToJson(_ReleaseNotesEntry instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'details_markdown': instance.detailsMarkdown,
      'change_type': instance.changeType,
    };
