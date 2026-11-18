// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The add-a-wallet flow.
///
/// It holds the look-ahead at an address's networks, the networks picked and
/// the connect. It never holds what the person pasted: the paste field owns
/// the text, and only an address the core parser accepted is passed in,
/// where it goes to the server and nowhere else.

@ProviderFor(AddWalletFlow)
final addWalletFlowProvider = AddWalletFlowProvider._();

/// The add-a-wallet flow.
///
/// It holds the look-ahead at an address's networks, the networks picked and
/// the connect. It never holds what the person pasted: the paste field owns
/// the text, and only an address the core parser accepted is passed in,
/// where it goes to the server and nowhere else.
final class AddWalletFlowProvider
    extends $NotifierProvider<AddWalletFlow, AddWalletState> {
  /// The add-a-wallet flow.
  ///
  /// It holds the look-ahead at an address's networks, the networks picked and
  /// the connect. It never holds what the person pasted: the paste field owns
  /// the text, and only an address the core parser accepted is passed in,
  /// where it goes to the server and nowhere else.
  AddWalletFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addWalletFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addWalletFlowHash();

  @$internal
  @override
  AddWalletFlow create() => AddWalletFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddWalletState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddWalletState>(value),
    );
  }
}

String _$addWalletFlowHash() => r'720f27a65c77df8a126810fdc59d54b54e5b4274';

/// The add-a-wallet flow.
///
/// It holds the look-ahead at an address's networks, the networks picked and
/// the connect. It never holds what the person pasted: the paste field owns
/// the text, and only an address the core parser accepted is passed in,
/// where it goes to the server and nowhere else.

abstract class _$AddWalletFlow extends $Notifier<AddWalletState> {
  AddWalletState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddWalletState, AddWalletState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddWalletState, AddWalletState>,
              AddWalletState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
