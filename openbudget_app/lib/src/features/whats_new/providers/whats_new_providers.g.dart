// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whats_new_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(whatsNewSeenStore)
final whatsNewSeenStoreProvider = WhatsNewSeenStoreProvider._();

final class WhatsNewSeenStoreProvider
    extends
        $FunctionalProvider<
          WhatsNewSeenStore,
          WhatsNewSeenStore,
          WhatsNewSeenStore
        >
    with $Provider<WhatsNewSeenStore> {
  WhatsNewSeenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewSeenStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewSeenStoreHash();

  @$internal
  @override
  $ProviderElement<WhatsNewSeenStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatsNewSeenStore create(Ref ref) {
    return whatsNewSeenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatsNewSeenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatsNewSeenStore>(value),
    );
  }
}

String _$whatsNewSeenStoreHash() => r'e4fcea37c1fbca43a5561cf71c9ebaba25199439';

@ProviderFor(whatsNewAssetBundle)
final whatsNewAssetBundleProvider = WhatsNewAssetBundleProvider._();

final class WhatsNewAssetBundleProvider
    extends $FunctionalProvider<AssetBundle, AssetBundle, AssetBundle>
    with $Provider<AssetBundle> {
  WhatsNewAssetBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewAssetBundleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewAssetBundleHash();

  @$internal
  @override
  $ProviderElement<AssetBundle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetBundle create(Ref ref) {
    return whatsNewAssetBundle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetBundle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetBundle>(value),
    );
  }
}

String _$whatsNewAssetBundleHash() =>
    r'2a8e11dd1d5ab26fa794b8d6c631a6c54560c8f1';

/// The version people see in the app, without the build number.
///
/// A widget test has no platform plugin, so the fallback keeps the automatic
/// check quiet instead of turning it into an error state. Tests that care
/// about a version override this provider.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The version people see in the app, without the build number.
///
/// A widget test has no platform plugin, so the fallback keeps the automatic
/// check quiet instead of turning it into an error state. Tests that care
/// about a version override this provider.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The version people see in the app, without the build number.
  ///
  /// A widget test has no platform plugin, so the fallback keeps the automatic
  /// check quiet instead of turning it into an error state. Tests that care
  /// about a version override this provider.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'091cde695c1dce4bc50444cc1796557f050c0dc6';

@ProviderFor(whatsNewRepository)
final whatsNewRepositoryProvider = WhatsNewRepositoryProvider._();

final class WhatsNewRepositoryProvider
    extends
        $FunctionalProvider<
          WhatsNewRepository,
          WhatsNewRepository,
          WhatsNewRepository
        >
    with $Provider<WhatsNewRepository> {
  WhatsNewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewRepositoryHash();

  @$internal
  @override
  $ProviderElement<WhatsNewRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WhatsNewRepository create(Ref ref) {
    return whatsNewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WhatsNewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WhatsNewRepository>(value),
    );
  }
}

String _$whatsNewRepositoryHash() =>
    r'dd7454166f8f9f15a970f54a50e59533eaaaea0d';

/// The version whose notes were last recorded as seen.

@ProviderFor(WhatsNewSeenVersion)
final whatsNewSeenVersionProvider = WhatsNewSeenVersionProvider._();

/// The version whose notes were last recorded as seen.
final class WhatsNewSeenVersionProvider
    extends $NotifierProvider<WhatsNewSeenVersion, String?> {
  /// The version whose notes were last recorded as seen.
  WhatsNewSeenVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewSeenVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewSeenVersionHash();

  @$internal
  @override
  WhatsNewSeenVersion create() => WhatsNewSeenVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$whatsNewSeenVersionHash() =>
    r'4d2e8801fac97715400aa30c1f01e6896513c1c4';

/// The version whose notes were last recorded as seen.

abstract class _$WhatsNewSeenVersion extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The notes for the running version, or the reason there are none.
///
/// Used when someone opens What's new from Settings.

@ProviderFor(whatsNewCurrentNotes)
final whatsNewCurrentNotesProvider = WhatsNewCurrentNotesProvider._();

/// The notes for the running version, or the reason there are none.
///
/// Used when someone opens What's new from Settings.

final class WhatsNewCurrentNotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<WhatsNewNotesResult>,
          WhatsNewNotesResult,
          FutureOr<WhatsNewNotesResult>
        >
    with
        $FutureModifier<WhatsNewNotesResult>,
        $FutureProvider<WhatsNewNotesResult> {
  /// The notes for the running version, or the reason there are none.
  ///
  /// Used when someone opens What's new from Settings.
  WhatsNewCurrentNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewCurrentNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewCurrentNotesHash();

  @$internal
  @override
  $FutureProviderElement<WhatsNewNotesResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WhatsNewNotesResult> create(Ref ref) {
    return whatsNewCurrentNotes(ref);
  }
}

String _$whatsNewCurrentNotesHash() =>
    r'0f03040136e02419d50b3504ca6b0d8b42bae3a5';

/// The notes to open automatically after an update, or null when there is
/// nothing to show.
///
/// The first launch on a device stores the running version without opening
/// anything. When the stored version differs, a bundled notes file opens the
/// sheet; a release without a notes file is recorded silently so the check
/// does not run again.

@ProviderFor(whatsNewAutoPrompt)
final whatsNewAutoPromptProvider = WhatsNewAutoPromptProvider._();

/// The notes to open automatically after an update, or null when there is
/// nothing to show.
///
/// The first launch on a device stores the running version without opening
/// anything. When the stored version differs, a bundled notes file opens the
/// sheet; a release without a notes file is recorded silently so the check
/// does not run again.

final class WhatsNewAutoPromptProvider
    extends
        $FunctionalProvider<
          AsyncValue<WhatsNewNotesResult?>,
          WhatsNewNotesResult?,
          FutureOr<WhatsNewNotesResult?>
        >
    with
        $FutureModifier<WhatsNewNotesResult?>,
        $FutureProvider<WhatsNewNotesResult?> {
  /// The notes to open automatically after an update, or null when there is
  /// nothing to show.
  ///
  /// The first launch on a device stores the running version without opening
  /// anything. When the stored version differs, a bundled notes file opens the
  /// sheet; a release without a notes file is recorded silently so the check
  /// does not run again.
  WhatsNewAutoPromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'whatsNewAutoPromptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$whatsNewAutoPromptHash();

  @$internal
  @override
  $FutureProviderElement<WhatsNewNotesResult?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WhatsNewNotesResult?> create(Ref ref) {
    return whatsNewAutoPrompt(ref);
  }
}

String _$whatsNewAutoPromptHash() =>
    r'f59222e74b523f8589ce4f5ddf4a6848ed0920d9';
