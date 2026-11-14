// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The crypto wallets of one entity, merged Solana and generic surface on
/// `client.wallet`.

@ProviderFor(walletList)
final walletListProvider = WalletListFamily._();

/// The crypto wallets of one entity, merged Solana and generic surface on
/// `client.wallet`.

final class WalletListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Wallet>>,
          List<Wallet>,
          FutureOr<List<Wallet>>
        >
    with $FutureModifier<List<Wallet>>, $FutureProvider<List<Wallet>> {
  /// The crypto wallets of one entity, merged Solana and generic surface on
  /// `client.wallet`.
  WalletListProvider._({
    required WalletListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletListHash();

  @override
  String toString() {
    return r'walletListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Wallet>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Wallet>> create(Ref ref) {
    final argument = this.argument as String;
    return walletList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletListHash() => r'f5f74ecf058b6f323b2e0fc15d141a1374e366a8';

/// The crypto wallets of one entity, merged Solana and generic surface on
/// `client.wallet`.

final class WalletListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Wallet>>, String> {
  WalletListFamily._()
    : super(
        retry: null,
        name: r'walletListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The crypto wallets of one entity, merged Solana and generic surface on
  /// `client.wallet`.

  WalletListProvider call(String entityId) =>
      WalletListProvider._(argument: entityId, from: this);

  @override
  String toString() => r'walletListProvider';
}

/// The wallet that values one account, if any.

@ProviderFor(walletForAccount)
final walletForAccountProvider = WalletForAccountFamily._();

/// The wallet that values one account, if any.

final class WalletForAccountProvider
    extends $FunctionalProvider<AsyncValue<Wallet?>, Wallet?, FutureOr<Wallet?>>
    with $FutureModifier<Wallet?>, $FutureProvider<Wallet?> {
  /// The wallet that values one account, if any.
  WalletForAccountProvider._({
    required WalletForAccountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletForAccountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletForAccountHash();

  @override
  String toString() {
    return r'walletForAccountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Wallet?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Wallet?> create(Ref ref) {
    final argument = this.argument as String;
    return walletForAccount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletForAccountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletForAccountHash() => r'f3ab43c1ce0e317e0559fe10cd55214f6366f088';

/// The wallet that values one account, if any.

final class WalletForAccountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Wallet?>, String> {
  WalletForAccountFamily._()
    : super(
        retry: null,
        name: r'walletForAccountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The wallet that values one account, if any.

  WalletForAccountProvider call(String accountId) =>
      WalletForAccountProvider._(argument: accountId, from: this);

  @override
  String toString() => r'walletForAccountProvider';
}

/// The wallet's persisted holdings.

@ProviderFor(walletHoldings)
final walletHoldingsProvider = WalletHoldingsFamily._();

/// The wallet's persisted holdings.

final class WalletHoldingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletHolding>>,
          List<WalletHolding>,
          FutureOr<List<WalletHolding>>
        >
    with
        $FutureModifier<List<WalletHolding>>,
        $FutureProvider<List<WalletHolding>> {
  /// The wallet's persisted holdings.
  WalletHoldingsProvider._({
    required WalletHoldingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletHoldingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletHoldingsHash();

  @override
  String toString() {
    return r'walletHoldingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WalletHolding>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WalletHolding>> create(Ref ref) {
    final argument = this.argument as String;
    return walletHoldings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletHoldingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletHoldingsHash() => r'0a0d89ea3816a9ba39d13afaa86d648c3f7393df';

/// The wallet's persisted holdings.

final class WalletHoldingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WalletHolding>>, String> {
  WalletHoldingsFamily._()
    : super(
        retry: null,
        name: r'walletHoldingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The wallet's persisted holdings.

  WalletHoldingsProvider call(String walletId) =>
      WalletHoldingsProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletHoldingsProvider';
}

/// How the last read of each of the wallet's networks went: when it
/// succeeded, and why it failed.

@ProviderFor(walletNetworkStates)
final walletNetworkStatesProvider = WalletNetworkStatesFamily._();

/// How the last read of each of the wallet's networks went: when it
/// succeeded, and why it failed.

final class WalletNetworkStatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletNetworkState>>,
          List<WalletNetworkState>,
          FutureOr<List<WalletNetworkState>>
        >
    with
        $FutureModifier<List<WalletNetworkState>>,
        $FutureProvider<List<WalletNetworkState>> {
  /// How the last read of each of the wallet's networks went: when it
  /// succeeded, and why it failed.
  WalletNetworkStatesProvider._({
    required WalletNetworkStatesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletNetworkStatesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletNetworkStatesHash();

  @override
  String toString() {
    return r'walletNetworkStatesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WalletNetworkState>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WalletNetworkState>> create(Ref ref) {
    final argument = this.argument as String;
    return walletNetworkStates(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletNetworkStatesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletNetworkStatesHash() =>
    r'8f555c494e76eaaac879121c76999e4ab6abddd3';

/// How the last read of each of the wallet's networks went: when it
/// succeeded, and why it failed.

final class WalletNetworkStatesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WalletNetworkState>>, String> {
  WalletNetworkStatesFamily._()
    : super(
        retry: null,
        name: r'walletNetworkStatesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How the last read of each of the wallet's networks went: when it
  /// succeeded, and why it failed.

  WalletNetworkStatesProvider call(String walletId) =>
      WalletNetworkStatesProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletNetworkStatesProvider';
}

/// The wallet's on-chain transactions, newest first.

@ProviderFor(walletTransactions)
final walletTransactionsProvider = WalletTransactionsFamily._();

/// The wallet's on-chain transactions, newest first.

final class WalletTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletTransaction>>,
          List<WalletTransaction>,
          FutureOr<List<WalletTransaction>>
        >
    with
        $FutureModifier<List<WalletTransaction>>,
        $FutureProvider<List<WalletTransaction>> {
  /// The wallet's on-chain transactions, newest first.
  WalletTransactionsProvider._({
    required WalletTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletTransactionsHash();

  @override
  String toString() {
    return r'walletTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WalletTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WalletTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return walletTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletTransactionsHash() =>
    r'962ee87c764fd1f4b6cf04840855acd3f89ff5a8';

/// The wallet's on-chain transactions, newest first.

final class WalletTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WalletTransaction>>, String> {
  WalletTransactionsFamily._()
    : super(
        retry: null,
        name: r'walletTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The wallet's on-chain transactions, newest first.

  WalletTransactionsProvider call(String walletId) =>
      WalletTransactionsProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletTransactionsProvider';
}

/// Estimated realised P&L grouped by fiscal year and currency.

@ProviderFor(walletTaxYearSummaries)
final walletTaxYearSummariesProvider = WalletTaxYearSummariesFamily._();

/// Estimated realised P&L grouped by fiscal year and currency.

final class WalletTaxYearSummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WalletTaxYearSummary>>,
          List<WalletTaxYearSummary>,
          FutureOr<List<WalletTaxYearSummary>>
        >
    with
        $FutureModifier<List<WalletTaxYearSummary>>,
        $FutureProvider<List<WalletTaxYearSummary>> {
  /// Estimated realised P&L grouped by fiscal year and currency.
  WalletTaxYearSummariesProvider._({
    required WalletTaxYearSummariesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'walletTaxYearSummariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$walletTaxYearSummariesHash();

  @override
  String toString() {
    return r'walletTaxYearSummariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WalletTaxYearSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WalletTaxYearSummary>> create(Ref ref) {
    final argument = this.argument as String;
    return walletTaxYearSummaries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WalletTaxYearSummariesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$walletTaxYearSummariesHash() =>
    r'cfbd800e8b3099ec329a6bdc89add4abb85166c6';

/// Estimated realised P&L grouped by fiscal year and currency.

final class WalletTaxYearSummariesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<WalletTaxYearSummary>>,
          String
        > {
  WalletTaxYearSummariesFamily._()
    : super(
        retry: null,
        name: r'walletTaxYearSummariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Estimated realised P&L grouped by fiscal year and currency.

  WalletTaxYearSummariesProvider call(String walletId) =>
      WalletTaxYearSummariesProvider._(argument: walletId, from: this);

  @override
  String toString() => r'walletTaxYearSummariesProvider';
}

/// Wallet mutations. Kept alive so the invalidations that follow each await
/// still reach the providers they refresh: an auto-disposed notifier is
/// unmounted by then and its `ref.invalidate` does nothing.

@ProviderFor(WalletActions)
final walletActionsProvider = WalletActionsProvider._();

/// Wallet mutations. Kept alive so the invalidations that follow each await
/// still reach the providers they refresh: an auto-disposed notifier is
/// unmounted by then and its `ref.invalidate` does nothing.
final class WalletActionsProvider
    extends $AsyncNotifierProvider<WalletActions, void> {
  /// Wallet mutations. Kept alive so the invalidations that follow each await
  /// still reach the providers they refresh: an auto-disposed notifier is
  /// unmounted by then and its `ref.invalidate` does nothing.
  WalletActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletActionsHash();

  @$internal
  @override
  WalletActions create() => WalletActions();
}

String _$walletActionsHash() => r'8ad7acfc325daed002304cd396f228d3a154bf17';

/// Wallet mutations. Kept alive so the invalidations that follow each await
/// still reach the providers they refresh: an auto-disposed notifier is
/// unmounted by then and its `ref.invalidate` does nothing.

abstract class _$WalletActions extends $AsyncNotifier<void> {
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
