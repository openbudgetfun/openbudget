// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(duplicateCheck)
final duplicateCheckProvider = DuplicateCheckFamily._();

final class DuplicateCheckProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  DuplicateCheckProvider._({
    required DuplicateCheckFamily super.from,
    required (String, int, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'duplicateCheckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$duplicateCheckHash();

  @override
  String toString() {
    return r'duplicateCheckProvider'
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
    final argument = this.argument as (String, int, DateTime);
    return duplicateCheck(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is DuplicateCheckProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$duplicateCheckHash() => r'01d463d05a2ae78a8935a01a03f2ee658cc12064';

final class DuplicateCheckFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Transaction>>,
          (String, int, DateTime)
        > {
  DuplicateCheckFamily._()
    : super(
        retry: null,
        name: r'duplicateCheckProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DuplicateCheckProvider call(
    String budgetId,
    int amountCents,
    DateTime transactionDate,
  ) => DuplicateCheckProvider._(
    argument: (budgetId, amountCents, transactionDate),
    from: this,
  );

  @override
  String toString() => r'duplicateCheckProvider';
}
