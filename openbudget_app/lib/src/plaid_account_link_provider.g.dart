// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plaid_account_link_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The entity's Plaid connections: sync status, last error and Remove.

@ProviderFor(plaidConnections)
final plaidConnectionsProvider = PlaidConnectionsFamily._();

/// The entity's Plaid connections: sync status, last error and Remove.

final class PlaidConnectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlaidConnection>>,
          List<PlaidConnection>,
          FutureOr<List<PlaidConnection>>
        >
    with
        $FutureModifier<List<PlaidConnection>>,
        $FutureProvider<List<PlaidConnection>> {
  /// The entity's Plaid connections: sync status, last error and Remove.
  PlaidConnectionsProvider._({
    required PlaidConnectionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'plaidConnectionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$plaidConnectionsHash();

  @override
  String toString() {
    return r'plaidConnectionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlaidConnection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlaidConnection>> create(Ref ref) {
    final argument = this.argument as String;
    return plaidConnections(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaidConnectionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$plaidConnectionsHash() => r'cf3b48fd753a45b190e8b8700e499f03994d4793';

/// The entity's Plaid connections: sync status, last error and Remove.

final class PlaidConnectionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PlaidConnection>>, String> {
  PlaidConnectionsFamily._()
    : super(
        retry: null,
        name: r'plaidConnectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The entity's Plaid connections: sync status, last error and Remove.

  PlaidConnectionsProvider call(String entityId) =>
      PlaidConnectionsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'plaidConnectionsProvider';
}

@ProviderFor(PlaidAccountLink)
final plaidAccountLinkProvider = PlaidAccountLinkProvider._();

final class PlaidAccountLinkProvider
    extends $AsyncNotifierProvider<PlaidAccountLink, void> {
  PlaidAccountLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plaidAccountLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plaidAccountLinkHash();

  @$internal
  @override
  PlaidAccountLink create() => PlaidAccountLink();
}

String _$plaidAccountLinkHash() => r'9e36b88151f18301949bbfcfc26b5ec6afb7d140';

abstract class _$PlaidAccountLink extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
