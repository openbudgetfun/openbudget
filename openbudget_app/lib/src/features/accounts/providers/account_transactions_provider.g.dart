// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountTransactions)
final accountTransactionsProvider = AccountTransactionsFamily._();

final class AccountTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  AccountTransactionsProvider._({
    required AccountTransactionsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'accountTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountTransactionsHash();

  @override
  String toString() {
    return r'accountTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return accountTransactions(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountTransactionsHash() =>
    r'2a1ca5c04e5d941f0941740e91c58c1bad6becb7';

final class AccountTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Transaction>>,
          (String, String)
        > {
  AccountTransactionsFamily._()
    : super(
        retry: null,
        name: r'accountTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountTransactionsProvider call(String budgetId, String accountId) =>
      AccountTransactionsProvider._(
        argument: (budgetId, accountId),
        from: this,
      );

  @override
  String toString() => r'accountTransactionsProvider';
}

@ProviderFor(AccountTransactionActions)
final accountTransactionActionsProvider = AccountTransactionActionsProvider._();

final class AccountTransactionActionsProvider
    extends $AsyncNotifierProvider<AccountTransactionActions, void> {
  AccountTransactionActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountTransactionActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountTransactionActionsHash();

  @$internal
  @override
  AccountTransactionActions create() => AccountTransactionActions();
}

String _$accountTransactionActionsHash() =>
    r'a87aa2f42326e011477e0a2fc35741fab5082f93';

abstract class _$AccountTransactionActions extends $AsyncNotifier<void> {
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
