// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'age_of_money_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the "Age of Money" metric for a budget.
///
/// Returns the average number of days between income receipt and spending,
/// or null if there is insufficient data.

@ProviderFor(ageOfMoney)
final ageOfMoneyProvider = AgeOfMoneyFamily._();

/// Fetches the "Age of Money" metric for a budget.
///
/// Returns the average number of days between income receipt and spending,
/// or null if there is insufficient data.

final class AgeOfMoneyProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// Fetches the "Age of Money" metric for a budget.
  ///
  /// Returns the average number of days between income receipt and spending,
  /// or null if there is insufficient data.
  AgeOfMoneyProvider._({
    required AgeOfMoneyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ageOfMoneyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ageOfMoneyHash();

  @override
  String toString() {
    return r'ageOfMoneyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as String;
    return ageOfMoney(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AgeOfMoneyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ageOfMoneyHash() => r'39cb7fa90a0efd88133affeaffe2f60b44555dc8';

/// Fetches the "Age of Money" metric for a budget.
///
/// Returns the average number of days between income receipt and spending,
/// or null if there is insufficient data.

final class AgeOfMoneyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, String> {
  AgeOfMoneyFamily._()
    : super(
        retry: null,
        name: r'ageOfMoneyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the "Age of Money" metric for a budget.
  ///
  /// Returns the average number of days between income receipt and spending,
  /// or null if there is insufficient data.

  AgeOfMoneyProvider call(String budgetId) =>
      AgeOfMoneyProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'ageOfMoneyProvider';
}
