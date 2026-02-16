// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EnvelopeActions)
final envelopeActionsProvider = EnvelopeActionsProvider._();

final class EnvelopeActionsProvider
    extends $NotifierProvider<EnvelopeActions, AsyncValue<void>> {
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

String _$envelopeActionsHash() => r'e4040801102a8ad57fb13d295006e97a31b54029';

abstract class _$EnvelopeActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
