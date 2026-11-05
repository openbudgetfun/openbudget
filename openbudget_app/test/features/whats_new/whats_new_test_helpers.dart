import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The version covered by the checked-in sample notes.
const fixtureNotesVersion = '2.4.0';

/// Reads the sample notes from `test/fixtures/release_notes/`.
String loadReleaseNotesFixture() =>
    File('test/fixtures/release_notes/$fixtureNotesVersion.json')
        .readAsStringSync();

/// An [AssetBundle] backed by an in-memory map.
///
/// Asking for a key that is not present throws the same [FlutterError] the
/// real bundle throws for a missing asset.
class FakeAssetBundle extends AssetBundle {
  FakeAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final contents = files[key];
    if (contents == null) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    final bytes = Uint8List.fromList(utf8.encode(contents));
    return ByteData.sublistView(bytes);
  }
}

String releaseNotesAssetPath(String version) =>
    'assets/release_notes/$version.json';
