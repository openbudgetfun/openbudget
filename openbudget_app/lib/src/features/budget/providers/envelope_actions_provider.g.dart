// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Envelope writes: create, edit, hide, reorder and delete. Deleting an
/// envelope with history asks which envelope to move it to; allocations and
/// goals are plan data, edited through `budget.*` elsewhere.

@ProviderFor(EnvelopeActions)
final envelopeActionsProvider = EnvelopeActionsProvider._();

/// Envelope writes: create, edit, hide, reorder and delete. Deleting an
/// envelope with history asks which envelope to move it to; allocations and
/// goals are plan data, edited through `budget.*` elsewhere.
final class EnvelopeActionsProvider
    extends $NotifierProvider<EnvelopeActions, AsyncValue<void>> {
  /// Envelope writes: create, edit, hide, reorder and delete. Deleting an
  /// envelope with history asks which envelope to move it to; allocations and
  /// goals are plan data, edited through `budget.*` elsewhere.
  EnvelopeActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envelopeActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envelopeActionsHash();

  @$internal
  @override
  EnvelopeActions create() => EnvelopeActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$envelopeActionsHash() => r'7650d020e5a0244fb051af283b7fcbbb34cf9879';

/// Envelope writes: create, edit, hide, reorder and delete. Deleting an
/// envelope with history asks which envelope to move it to; allocations and
/// goals are plan data, edited through `budget.*` elsewhere.

abstract class _$EnvelopeActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
