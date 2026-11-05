// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solana_wallet_subscribe_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Solana flow the Plus screen uses. Only web offers the Solana rail.

@ProviderFor(solanaSubscribeFlow)
final solanaSubscribeFlowProvider = SolanaSubscribeFlowProvider._();

/// The Solana flow the Plus screen uses. Only web offers the Solana rail.

final class SolanaSubscribeFlowProvider
    extends
        $FunctionalProvider<
          SolanaSubscribeFlow,
          SolanaSubscribeFlow,
          SolanaSubscribeFlow
        >
    with $Provider<SolanaSubscribeFlow> {
  /// The Solana flow the Plus screen uses. Only web offers the Solana rail.
  SolanaSubscribeFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'solanaSubscribeFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$solanaSubscribeFlowHash();

  @$internal
  @override
  $ProviderElement<SolanaSubscribeFlow> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SolanaSubscribeFlow create(Ref ref) {
    return solanaSubscribeFlow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SolanaSubscribeFlow value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SolanaSubscribeFlow>(value),
    );
  }
}

String _$solanaSubscribeFlowHash() =>
    r'd33656a5e4fe1d811b76d5d2bcc3ecef35997d0f';
