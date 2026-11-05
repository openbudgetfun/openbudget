import 'package:flutter/services.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whats_new_providers.g.dart';

/// Preference keys owned by the What's new feature.
abstract final class WhatsNewPreferenceKeys {
  static const lastSeenVersion = 'whatsNew.lastSeenVersion';
}

/// Remembers the last app version whose notes were shown.
abstract interface class WhatsNewSeenStore {
  String? readLastSeenVersion();

  Future<void> writeLastSeenVersion(String version);
}

/// Stores the last seen version in the app's existing preference store.
class PreferencesWhatsNewSeenStore implements WhatsNewSeenStore {
  const PreferencesWhatsNewSeenStore(this._preferences);

  final UiPreferencesStore _preferences;

  @override
  String? readLastSeenVersion() =>
      _preferences.readString(WhatsNewPreferenceKeys.lastSeenVersion);

  @override
  Future<void> writeLastSeenVersion(String version) => _preferences.writeString(
    key: WhatsNewPreferenceKeys.lastSeenVersion,
    value: version,
  );
}

@riverpod
WhatsNewSeenStore whatsNewSeenStore(Ref ref) =>
    PreferencesWhatsNewSeenStore(ref.watch(uiPreferencesStoreProvider));

@riverpod
AssetBundle whatsNewAssetBundle(Ref ref) => rootBundle;

/// The version people see in the app, without the build number.
///
/// A widget test has no platform plugin, so the fallback keeps the automatic
/// check quiet instead of turning it into an error state. Tests that care
/// about a version override this provider.
@riverpod
Future<String> appVersion(Ref ref) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version.trim();
    return version.isEmpty ? '0.0.0' : version;
  } on MissingPluginException {
    return '0.0.0';
  } on PlatformException {
    return '0.0.0';
  }
}

@riverpod
WhatsNewRepository whatsNewRepository(Ref ref) =>
    WhatsNewRepository(bundle: ref.watch(whatsNewAssetBundleProvider));

/// The version whose notes were last recorded as seen.
@riverpod
class WhatsNewSeenVersion extends _$WhatsNewSeenVersion {
  @override
  String? build() => ref.watch(whatsNewSeenStoreProvider).readLastSeenVersion();

  Future<void> markSeen(String version) async {
    state = version;
    await ref.read(whatsNewSeenStoreProvider).writeLastSeenVersion(version);
  }
}

/// The notes for the running version, or the reason there are none.
///
/// Used when someone opens What's new from Settings.
@riverpod
Future<WhatsNewNotesResult> whatsNewCurrentNotes(Ref ref) async {
  final versionFuture = ref.watch(appVersionProvider.future);
  final repository = ref.watch(whatsNewRepositoryProvider);
  final version = await versionFuture;
  return repository.loadForVersion(version);
}

/// The notes to open automatically after an update, or null when there is
/// nothing to show.
///
/// The first launch on a device stores the running version without opening
/// anything. When the stored version differs, a bundled notes file opens the
/// sheet; a release without a notes file is recorded silently so the check
/// does not run again.
@riverpod
Future<WhatsNewNotesResult?> whatsNewAutoPrompt(Ref ref) async {
  final versionFuture = ref.watch(appVersionProvider.future);
  final seenVersion = ref.watch(whatsNewSeenVersionProvider);
  final seenStore = ref.watch(whatsNewSeenStoreProvider);
  final repository = ref.watch(whatsNewRepositoryProvider);
  final version = await versionFuture;

  if (seenVersion == version) {
    return null;
  }

  if (seenVersion == null) {
    await seenStore.writeLastSeenVersion(version);
    return null;
  }

  final result = await repository.loadForVersion(version);
  if (result case WhatsNewNotesAvailable(:final notes)) {
    return WhatsNewNotesResult.available(version: version, notes: notes);
  }

  await seenStore.writeLastSeenVersion(version);
  return null;
}
