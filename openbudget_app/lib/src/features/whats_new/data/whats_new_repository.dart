import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes_parser.dart';

part 'whats_new_repository.freezed.dart';

/// What the app found when it looked for one version's notes.
@freezed
sealed class WhatsNewNotesResult with _$WhatsNewNotesResult {
  /// The file exists and could be read.
  const factory WhatsNewNotesResult.available({
    required String version,
    required ReleaseNotes notes,
  }) = WhatsNewNotesAvailable;

  /// No notes file is bundled for this version. This is expected for releases
  /// with no user-facing changes.
  const factory WhatsNewNotesResult.notFound({required String version}) =
      WhatsNewNotesNotFound;

  /// The file exists but could not be parsed.
  const factory WhatsNewNotesResult.invalid({
    required String version,
    required String message,
  }) = WhatsNewNotesInvalid;
}

/// Loads the release notes bundled into `assets/release_notes/`.
class WhatsNewRepository {
  const WhatsNewRepository({required this.bundle});

  final AssetBundle bundle;

  /// Reads `assets/release_notes/<version>.json`.
  ///
  /// A missing asset becomes [WhatsNewNotesNotFound]; a malformed one becomes
  /// [WhatsNewNotesInvalid]. Neither throws.
  Future<WhatsNewNotesResult> loadForVersion(String version) async {
    final normalized = _normalizeVersion(version);
    final path = _assetPathFor(normalized);

    final ByteData data;
    try {
      data = await bundle.load(path);
    } on Object catch (error) {
      // AssetBundle reports a missing asset as a FlutterError (an Error, not
      // an Exception). Anything else is a real failure.
      if (error is! FlutterError) {
        rethrow;
      }
      return WhatsNewNotesResult.notFound(version: normalized);
    }

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final String source;
    try {
      source = utf8.decode(bytes);
    } on FormatException {
      return WhatsNewNotesResult.invalid(
        version: normalized,
        message: 'Release notes are not valid UTF-8.',
      );
    }

    return switch (parseReleaseNotes(source)) {
      ReleaseNotesParseSuccess(:final notes) => WhatsNewNotesResult.available(
        version: normalized,
        notes: notes,
      ),
      ReleaseNotesParseFailure(:final message) => WhatsNewNotesResult.invalid(
        version: normalized,
        message: message,
      ),
    };
  }

  static String _assetPathFor(String version) =>
      'assets/release_notes/$version.json';

  /// Package versions can arrive with a `v` prefix or a `+build` suffix. The
  /// notes files are named after the plain version monochange releases.
  static String _normalizeVersion(String version) {
    final trimmed = version.trim();
    final withoutPrefix = trimmed.startsWith('v')
        ? trimmed.substring(1)
        : trimmed;
    return withoutPrefix.split('+').first;
  }
}
