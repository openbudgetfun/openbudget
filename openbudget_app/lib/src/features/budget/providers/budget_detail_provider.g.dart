// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetDetail)
final budgetDetailProvider = BudgetDetailFamily._();

final class BudgetDetailProvider
    extends $FunctionalProvider<AsyncValue<Budget>, Budget, FutureOr<Budget>>
    with $FutureModifier<Budget>, $FutureProvider<Budget> {
  BudgetDetailProvider._({
    required BudgetDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetDetailHash();

  @override
  String toString() {
    return r'budgetDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Budget> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Budget> create(Ref ref) {
    final argument = this.argument as String;
    return budgetDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetDetailHash() => r'b0848a16ed17dafa74f250b34396a1191006bac4';

final class BudgetDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Budget>, String> {
  BudgetDetailFamily._()
    : super(
        retry: null,
        name: r'budgetDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetDetailProvider call(String budgetId) =>
      BudgetDetailProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetDetailProvider';
}

@ProviderFor(categoryList)
final categoryListProvider = CategoryListFamily._();

final class CategoryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  CategoryListProvider._({
    required CategoryListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @override
  String toString() {
    return r'categoryListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryListHash() => r'660df302417a7f84be7d9dd68a491a347945f3ba';

final class CategoryListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Category>>, String> {
  CategoryListFamily._()
    : super(
        retry: null,
        name: r'categoryListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryListProvider call(String budgetId) =>
      CategoryListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'categoryListProvider';
}

@ProviderFor(envelopeList)
final envelopeListProvider = EnvelopeListFamily._();

final class EnvelopeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Envelope>>,
          List<Envelope>,
          FutureOr<List<Envelope>>
        >
    with $FutureModifier<List<Envelope>>, $FutureProvider<List<Envelope>> {
  EnvelopeListProvider._({
    required EnvelopeListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'envelopeListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$envelopeListHash();

  @override
  String toString() {
    return r'envelopeListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Envelope>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Envelope>> create(Ref ref) {
    final argument = this.argument as String;
    return envelopeList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EnvelopeListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$envelopeListHash() => r'be97129b512adf7c47396ba6c2b5b9bb7e5770eb';

final class EnvelopeListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Envelope>>, String> {
  EnvelopeListFamily._()
    : super(
        retry: null,
        name: r'envelopeListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EnvelopeListProvider call(String categoryId) =>
      EnvelopeListProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'envelopeListProvider';
}

@ProviderFor(transactionList)
final transactionListProvider = TransactionListFamily._();

final class TransactionListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  TransactionListProvider._({
    required TransactionListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @override
  String toString() {
    return r'transactionListProvider'
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
    return transactionList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionListHash() => r'eadc9adabdebf71bc4c981ad73f921948fd40b25';

final class TransactionListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Transaction>>, String> {
  TransactionListFamily._()
    : super(
        retry: null,
        name: r'transactionListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionListProvider call(String budgetId) =>
      TransactionListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'transactionListProvider';
}
