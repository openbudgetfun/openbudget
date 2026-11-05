import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes.dart';

part 'release_notes_parser.freezed.dart';

/// The outcome of reading one release-notes file.
///
/// A malformed file is a normal failure result, never a thrown exception at
/// the call site: bundled assets can be wrong, and the app must stay open.
@freezed
sealed class ReleaseNotesParseResult with _$ReleaseNotesParseResult {
  const factory ReleaseNotesParseResult.success(ReleaseNotes notes) =
      ReleaseNotesParseSuccess;

  const factory ReleaseNotesParseResult.failure(String message) =
      ReleaseNotesParseFailure;
}

/// Parses a release-notes JSON document.
///
/// Unknown keys are ignored, so monochange can add fields without breaking
/// older app versions. Missing required keys or values of the wrong type
/// produce [ReleaseNotesParseFailure].
ReleaseNotesParseResult parseReleaseNotes(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    return const ReleaseNotesParseResult.failure(
      'Release notes are not valid JSON.',
    );
  }

  if (decoded is! Map) {
    return const ReleaseNotesParseResult.failure(
      'Release notes must be a JSON object.',
    );
  }

  try {
    final notes = ReleaseNotes.fromJson(Map<String, dynamic>.from(decoded));
    return ReleaseNotesParseResult.success(notes);
  } on Object catch (error) {
    // The generated decoder reports a bad shape as a TypeError. Anything else
    // is a real bug and should keep propagating.
    if (error is! TypeError) {
      rethrow;
    }
    return const ReleaseNotesParseResult.failure(
      'Release notes have an unexpected shape.',
    );
  }
}
