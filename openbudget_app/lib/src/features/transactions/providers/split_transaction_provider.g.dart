// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(splitTransactions)
final splitTransactionsProvider = SplitTransactionsFamily._();

final class SplitTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  SplitTransactionsProvider._({
    required SplitTransactionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'splitTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$splitTransactionsHash();

  @override
  String toString() {
    return r'splitTransactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as String;
    return splitTransactions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SplitTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$splitTransactionsHash() => r'f6f9e1074d675080cea6eb5d7d326b11ca65f523';

final class SplitTransactionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Transaction>>, String> {
  SplitTransactionsFamily._()
    : super(
        retry: null,
        name: r'splitTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SplitTransactionsProvider call(String parentTransactionId) =>
      SplitTransactionsProvider._(argument: parentTransactionId, from: this);

  @override
  String toString() => r'splitTransactionsProvider';
}

@ProviderFor(SplitTransactionActions)
final splitTransactionActionsProvider = SplitTransactionActionsProvider._();

final class SplitTransactionActionsProvider
    extends $NotifierProvider<SplitTransactionActions, AsyncValue<void>> {
  SplitTransactionActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitTransactionActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitTransactionActionsHash();

  @$internal
  @override
  SplitTransactionActions create() => SplitTransactionActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$splitTransactionActionsHash() =>
    r'8b9d40505015c1e58e0ea0b670aac2fa2041972a';

abstract class _$SplitTransactionActions extends $Notifier<AsyncValue<void>> {
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
