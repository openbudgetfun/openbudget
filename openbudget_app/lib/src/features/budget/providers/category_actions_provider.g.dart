// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryActions)
final categoryActionsProvider = CategoryActionsProvider._();

final class CategoryActionsProvider
    extends $NotifierProvider<CategoryActions, AsyncValue<void>> {
  CategoryActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryActionsHash();

  @$internal
  @override
  CategoryActions create() => CategoryActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$categoryActionsHash() => r'7dde7d8fd2201da3523863b9bef209797b7c3afb';

abstract class _$CategoryActions extends $Notifier<AsyncValue<void>> {
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
