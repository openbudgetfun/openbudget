// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_api_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The assistant API the app uses. Tests override this with a fake.

@ProviderFor(assistantApi)
final assistantApiProvider = AssistantApiProvider._();

/// The assistant API the app uses. Tests override this with a fake.

final class AssistantApiProvider
    extends $FunctionalProvider<AssistantApi, AssistantApi, AssistantApi>
    with $Provider<AssistantApi> {
  /// The assistant API the app uses. Tests override this with a fake.
  AssistantApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantApiHash();

  @$internal
  @override
  $ProviderElement<AssistantApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssistantApi create(Ref ref) {
    return assistantApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantApi>(value),
    );
  }
}

String _$assistantApiHash() => r'd0054fd21e6d8fe818711aab49f99970d64449fc';
