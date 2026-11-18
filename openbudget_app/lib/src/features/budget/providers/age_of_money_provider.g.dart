// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'age_of_money_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The mean age in days of the entity's last ten outflows' money, straight
/// from `report.ageOfMoney`. Null means the entity has too little history
/// for a meaningful figure.

@ProviderFor(ageOfMoney)
final ageOfMoneyProvider = AgeOfMoneyFamily._();

/// The mean age in days of the entity's last ten outflows' money, straight
/// from `report.ageOfMoney`. Null means the entity has too little history
/// for a meaningful figure.

final class AgeOfMoneyProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// The mean age in days of the entity's last ten outflows' money, straight
  /// from `report.ageOfMoney`. Null means the entity has too little history
  /// for a meaningful figure.
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

String _$ageOfMoneyHash() => r'24a89977f81f6b10dc96f7de6697ac1da651fcee';

/// The mean age in days of the entity's last ten outflows' money, straight
/// from `report.ageOfMoney`. Null means the entity has too little history
/// for a meaningful figure.

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

  /// The mean age in days of the entity's last ten outflows' money, straight
  /// from `report.ageOfMoney`. Null means the entity has too little history
  /// for a meaningful figure.

  AgeOfMoneyProvider call(String entityId) =>
      AgeOfMoneyProvider._(argument: entityId, from: this);

  @override
  String toString() => r'ageOfMoneyProvider';
}
