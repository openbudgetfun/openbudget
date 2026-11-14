// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_look_ahead_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Look for assets on other chains" for one connected wallet: a fresh
/// `wallet.preview` of its address, which the wallet settings read to offer
/// networks the wallet does not scan yet.
///
/// It lives only while the settings are open, so every visit starts without
/// a stale answer. The address goes to the server and nowhere else.

@ProviderFor(WalletLookAhead)
final walletLookAheadProvider = WalletLookAheadFamily._();

/// "Look for assets on other chains" for one connected wallet: a fresh
/// `wallet.preview` of its address, which the wallet settings read to offer
/// networks the wallet does not scan yet.
///
/// It lives only while the settings are open, so every visit starts without
/// a stale answer. The address goes to the server and nowhere else.
final class WalletLookAheadProvider
    extends $NotifierProvider<WalletLookAhead, WalletPreviewState> {
  /// "Look for assets on other chains" for one connected wallet: a fresh
  /// `wallet.preview` of its address, which the wallet settings read to offer
  /// networks the wallet does not scan yet.
  ///
  /// It lives only while the settings are open, so every visit starts without
  /// a stale answer. The address goes to the server and nowhere else.
  WalletLookAheadProvider._({
    required WalletLookAheadFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletLookAheadProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletLookAheadHash();

  @override
  String toString() {
    return r'walletLookAheadProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WalletLookAhead create() => WalletLookAhead();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletPreviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletPreviewState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WalletLookAheadProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletLookAheadHash() => r'9a02ca82b63268d0a58b95a0cc84376dbde509b9';

/// "Look for assets on other chains" for one connected wallet: a fresh
/// `wallet.preview` of its address, which the wallet settings read to offer
/// networks the wallet does not scan yet.
///
/// It lives only while the settings are open, so every visit starts without
/// a stale answer. The address goes to the server and nowhere else.

final class WalletLookAheadFamily extends $Family
    with
        $ClassFamilyOverride<
          WalletLookAhead,
          WalletPreviewState,
          WalletPreviewState,
          WalletPreviewState,
          String
        > {
  WalletLookAheadFamily._()
    : super(
        retry: null,
        name: r'walletLookAheadProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// "Look for assets on other chains" for one connected wallet: a fresh
  /// `wallet.preview` of its address, which the wallet settings read to offer
  /// networks the wallet does not scan yet.
  ///
  /// It lives only while the settings are open, so every visit starts without
  /// a stale answer. The address goes to the server and nowhere else.

  WalletLookAheadProvider call(String walletId) =>
      WalletLookAheadProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletLookAheadProvider';
}

/// "Look for assets on other chains" for one connected wallet: a fresh
/// `wallet.preview` of its address, which the wallet settings read to offer
/// networks the wallet does not scan yet.
///
/// It lives only while the settings are open, so every visit starts without
/// a stale answer. The address goes to the server and nowhere else.

abstract class _$WalletLookAhead extends $Notifier<WalletPreviewState> {
  late final _$args = ref.$arg as String;
  String get walletId => _$args;

  WalletPreviewState build(String walletId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WalletPreviewState, WalletPreviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WalletPreviewState, WalletPreviewState>,
              WalletPreviewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
