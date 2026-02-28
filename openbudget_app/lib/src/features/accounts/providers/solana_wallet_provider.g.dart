// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solana_wallet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountSolanaWallet)
final accountSolanaWalletProvider = AccountSolanaWalletFamily._();

final class AccountSolanaWalletProvider
    extends
        $FunctionalProvider<
          AsyncValue<SolanaWallet?>,
          SolanaWallet?,
          FutureOr<SolanaWallet?>
        >
    with $FutureModifier<SolanaWallet?>, $FutureProvider<SolanaWallet?> {
  AccountSolanaWalletProvider._({
    required AccountSolanaWalletFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'accountSolanaWalletProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountSolanaWalletHash();

  @override
  String toString() {
    return r'accountSolanaWalletProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SolanaWallet?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SolanaWallet?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return accountSolanaWallet(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountSolanaWalletProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountSolanaWalletHash() =>
    r'df7bd1245802d2b9f49726c71a82055aab5f463e';

final class AccountSolanaWalletFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SolanaWallet?>, (String, String)> {
  AccountSolanaWalletFamily._()
    : super(
        retry: null,
        name: r'accountSolanaWalletProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountSolanaWalletProvider call(String budgetId, String accountId) =>
      AccountSolanaWalletProvider._(
        argument: (budgetId, accountId),
        from: this,
      );

  @override
  String toString() => r'accountSolanaWalletProvider';
}

@ProviderFor(solanaWalletHoldings)
final solanaWalletHoldingsProvider = SolanaWalletHoldingsFamily._();

final class SolanaWalletHoldingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SolanaWalletHolding>>,
          List<SolanaWalletHolding>,
          FutureOr<List<SolanaWalletHolding>>
        >
    with
        $FutureModifier<List<SolanaWalletHolding>>,
        $FutureProvider<List<SolanaWalletHolding>> {
  SolanaWalletHoldingsProvider._({
    required SolanaWalletHoldingsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'solanaWalletHoldingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$solanaWalletHoldingsHash();

  @override
  String toString() {
    return r'solanaWalletHoldingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SolanaWalletHolding>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SolanaWalletHolding>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return solanaWalletHoldings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SolanaWalletHoldingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$solanaWalletHoldingsHash() =>
    r'b0fbca3d2be59d0d819257a57bcf27f5a9ccb658';

final class SolanaWalletHoldingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SolanaWalletHolding>>,
          (String, String)
        > {
  SolanaWalletHoldingsFamily._()
    : super(
        retry: null,
        name: r'solanaWalletHoldingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SolanaWalletHoldingsProvider call(String budgetId, String walletId) =>
      SolanaWalletHoldingsProvider._(
        argument: (budgetId, walletId),
        from: this,
      );

  @override
  String toString() => r'solanaWalletHoldingsProvider';
}

@ProviderFor(solanaWalletTransactions)
final solanaWalletTransactionsProvider = SolanaWalletTransactionsFamily._();

final class SolanaWalletTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SolanaWalletTransaction>>,
          List<SolanaWalletTransaction>,
          FutureOr<List<SolanaWalletTransaction>>
        >
    with
        $FutureModifier<List<SolanaWalletTransaction>>,
        $FutureProvider<List<SolanaWalletTransaction>> {
  SolanaWalletTransactionsProvider._({
    required SolanaWalletTransactionsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'solanaWalletTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$solanaWalletTransactionsHash();

  @override
  String toString() {
    return r'solanaWalletTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SolanaWalletTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SolanaWalletTransaction>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return solanaWalletTransactions(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SolanaWalletTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$solanaWalletTransactionsHash() =>
    r'f436ebfdff46f5cb46ebf68703d675a30afbe37d';

final class SolanaWalletTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SolanaWalletTransaction>>,
          (String, String)
        > {
  SolanaWalletTransactionsFamily._()
    : super(
        retry: null,
        name: r'solanaWalletTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SolanaWalletTransactionsProvider call(String budgetId, String walletId) =>
      SolanaWalletTransactionsProvider._(
        argument: (budgetId, walletId),
        from: this,
      );

  @override
  String toString() => r'solanaWalletTransactionsProvider';
}

@ProviderFor(SolanaWalletActions)
final solanaWalletActionsProvider = SolanaWalletActionsProvider._();

final class SolanaWalletActionsProvider
    extends $AsyncNotifierProvider<SolanaWalletActions, void> {
  SolanaWalletActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'solanaWalletActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$solanaWalletActionsHash();

  @$internal
  @override
  SolanaWalletActions create() => SolanaWalletActions();
}

String _$solanaWalletActionsHash() =>
    r'2013b6812817c6145108039d358f6423019df3d7';

abstract class _$SolanaWalletActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
