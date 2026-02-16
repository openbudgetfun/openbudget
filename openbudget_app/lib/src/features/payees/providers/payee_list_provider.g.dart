// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payee_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(payeeList)
final payeeListProvider = PayeeListFamily._();

final class PayeeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Payee>>,
          List<Payee>,
          FutureOr<List<Payee>>
        >
    with $FutureModifier<List<Payee>>, $FutureProvider<List<Payee>> {
  PayeeListProvider._({
    required PayeeListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'payeeListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$payeeListHash();

  @override
  String toString() {
    return r'payeeListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Payee>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Payee>> create(Ref ref) {
    final argument = this.argument as String;
    return payeeList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PayeeListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$payeeListHash() => r'03706a6df255bf7d2528b1ceb69e073f7ac9844d';

final class PayeeListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Payee>>, String> {
  PayeeListFamily._()
    : super(
        retry: null,
        name: r'payeeListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PayeeListProvider call(String budgetId) =>
      PayeeListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'payeeListProvider';
}
