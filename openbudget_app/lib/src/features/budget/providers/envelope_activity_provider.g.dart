// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One envelope's month activity: transactions carrying the envelope,
/// within the selected month's dates, paged by the server's keyset cursor.

@ProviderFor(EnvelopeActivity)
final envelopeActivityProvider = EnvelopeActivityFamily._();

/// One envelope's month activity: transactions carrying the envelope,
/// within the selected month's dates, paged by the server's keyset cursor.
final class EnvelopeActivityProvider
    extends $AsyncNotifierProvider<EnvelopeActivity, EnvelopeActivityState> {
  /// One envelope's month activity: transactions carrying the envelope,
  /// within the selected month's dates, paged by the server's keyset cursor.
  EnvelopeActivityProvider._({
    required EnvelopeActivityFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'envelopeActivityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$envelopeActivityHash();

  @override
  String toString() {
    return r'envelopeActivityProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EnvelopeActivity create() => EnvelopeActivity();

  @override
  bool operator ==(Object other) {
    return other is EnvelopeActivityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$envelopeActivityHash() => r'dfeb33515fcc0e6e5a53d4a3d9c0bc5b177b6c70';

/// One envelope's month activity: transactions carrying the envelope,
/// within the selected month's dates, paged by the server's keyset cursor.

final class EnvelopeActivityFamily extends $Family
    with
        $ClassFamilyOverride<
          EnvelopeActivity,
          AsyncValue<EnvelopeActivityState>,
          EnvelopeActivityState,
          FutureOr<EnvelopeActivityState>,
          (String, String)
        > {
  EnvelopeActivityFamily._()
    : super(
        retry: null,
        name: r'envelopeActivityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One envelope's month activity: transactions carrying the envelope,
  /// within the selected month's dates, paged by the server's keyset cursor.

  EnvelopeActivityProvider call(String entityId, String envelopeId) =>
      EnvelopeActivityProvider._(argument: (entityId, envelopeId), from: this);

  @override
  String toString() => r'envelopeActivityProvider';
}

/// One envelope's month activity: transactions carrying the envelope,
/// within the selected month's dates, paged by the server's keyset cursor.

abstract class _$EnvelopeActivity
    extends $AsyncNotifier<EnvelopeActivityState> {
  late final _$args = ref.$arg as (String, String);
  String get entityId => _$args.$1;
  String get envelopeId => _$args.$2;

  FutureOr<EnvelopeActivityState> build(String entityId, String envelopeId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<EnvelopeActivityState>, EnvelopeActivityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<EnvelopeActivityState>,
                EnvelopeActivityState
              >,
              AsyncValue<EnvelopeActivityState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
