// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One owned account.

@ProviderFor(accountDetail)
final accountDetailProvider = AccountDetailFamily._();

/// One owned account.

final class AccountDetailProvider
    extends $FunctionalProvider<AsyncValue<Account>, Account, FutureOr<Account>>
    with $FutureModifier<Account>, $FutureProvider<Account> {
  /// One owned account.
  AccountDetailProvider._({
    required AccountDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountDetailHash();

  @override
  String toString() {
    return r'accountDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Account> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Account> create(Ref ref) {
    final argument = this.argument as String;
    return accountDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountDetailHash() => r'77e8d9fb21c24c7f3321bcbec759be7509d0659b';

/// One owned account.

final class AccountDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Account>, String> {
  AccountDetailFamily._()
    : super(
        retry: null,
        name: r'accountDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One owned account.

  AccountDetailProvider call(String accountId) =>
      AccountDetailProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountDetailProvider';
}

/// The account's cached and cleared balances, plus the bank's reported one.

@ProviderFor(accountBalances)
final accountBalancesProvider = AccountBalancesFamily._();

/// The account's cached and cleared balances, plus the bank's reported one.

final class AccountBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<AccountBalancesView>,
          AccountBalancesView,
          FutureOr<AccountBalancesView>
        >
    with
        $FutureModifier<AccountBalancesView>,
        $FutureProvider<AccountBalancesView> {
  /// The account's cached and cleared balances, plus the bank's reported one.
  AccountBalancesProvider._({
    required AccountBalancesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountBalancesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountBalancesHash();

  @override
  String toString() {
    return r'accountBalancesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AccountBalancesView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AccountBalancesView> create(Ref ref) {
    final argument = this.argument as String;
    return accountBalances(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBalancesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBalancesHash() => r'ea9da0403382112b66b22a84383ea994bfe19c36';

/// The account's cached and cleared balances, plus the bank's reported one.

final class AccountBalancesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AccountBalancesView>, String> {
  AccountBalancesFamily._()
    : super(
        retry: null,
        name: r'accountBalancesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account's cached and cleared balances, plus the bank's reported one.

  AccountBalancesProvider call(String accountId) =>
      AccountBalancesProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountBalancesProvider';
}

/// The value history of a track-by-value account, newest first.

@ProviderFor(accountValuations)
final accountValuationsProvider = AccountValuationsFamily._();

/// The value history of a track-by-value account, newest first.

final class AccountValuationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AccountValuation>>,
          List<AccountValuation>,
          FutureOr<List<AccountValuation>>
        >
    with
        $FutureModifier<List<AccountValuation>>,
        $FutureProvider<List<AccountValuation>> {
  /// The value history of a track-by-value account, newest first.
  AccountValuationsProvider._({
    required AccountValuationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountValuationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountValuationsHash();

  @override
  String toString() {
    return r'accountValuationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AccountValuation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AccountValuation>> create(Ref ref) {
    final argument = this.argument as String;
    return accountValuations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountValuationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountValuationsHash() => r'6b2afd5de024160a8dc0a5b2b5eaa50b8b70215b';

/// The value history of a track-by-value account, newest first.

final class AccountValuationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AccountValuation>>, String> {
  AccountValuationsFamily._()
    : super(
        retry: null,
        name: r'accountValuationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The value history of a track-by-value account, newest first.

  AccountValuationsProvider call(String accountId) =>
      AccountValuationsProvider._(argument: accountId, from: this);

  @override
  String toString() => r'accountValuationsProvider';
}
