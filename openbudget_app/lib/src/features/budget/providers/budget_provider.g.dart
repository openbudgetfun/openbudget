// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateBudget)
final createBudgetProvider = CreateBudgetProvider._();

final class CreateBudgetProvider
    extends $NotifierProvider<CreateBudget, AsyncValue<String?>> {
  CreateBudgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createBudgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createBudgetHash();

  @$internal
  @override
  CreateBudget create() => CreateBudget();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$createBudgetHash() => r'14f75bef27b19ed2eaad26f6b7185f19935a1f5b';

abstract class _$CreateBudget extends $Notifier<AsyncValue<String?>> {
  AsyncValue<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, AsyncValue<String?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, AsyncValue<String?>>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
