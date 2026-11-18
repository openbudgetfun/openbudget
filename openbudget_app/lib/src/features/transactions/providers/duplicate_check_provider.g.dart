// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duplicate_check_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Same account, same amount, date within ±3 days.

@ProviderFor(duplicateCheck)
final duplicateCheckProvider = DuplicateCheckFamily._();

/// Same account, same amount, date within ±3 days.

final class DuplicateCheckProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionView>>,
          List<TransactionView>,
          FutureOr<List<TransactionView>>
        >
    with
        $FutureModifier<List<TransactionView>>,
        $FutureProvider<List<TransactionView>> {
  /// Same account, same amount, date within ±3 days.
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
  $FutureProviderElement<List<TransactionView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransactionView>> create(Ref ref) {
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

String _$duplicateCheckHash() => r'ee4d9a5c94ed136d023a55f64bd980e0ff90c2a1';

/// Same account, same amount, date within ±3 days.

final class DuplicateCheckFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<TransactionView>>,
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

  /// Same account, same amount, date within ±3 days.

  DuplicateCheckProvider call(
    String accountId,
    int amountMinor,
    DateTime date,
  ) => DuplicateCheckProvider._(
    argument: (accountId, amountMinor, date),
    from: this,
  );

  @override
  String toString() => r'duplicateCheckProvider';
}
