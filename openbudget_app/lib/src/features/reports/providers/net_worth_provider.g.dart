// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes net worth from all active accounts in a budget.

@ProviderFor(netWorth)
final netWorthProvider = NetWorthFamily._();

/// Computes net worth from all active accounts in a budget.

final class NetWorthProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetWorthData>,
          NetWorthData,
          FutureOr<NetWorthData>
        >
    with $FutureModifier<NetWorthData>, $FutureProvider<NetWorthData> {
  /// Computes net worth from all active accounts in a budget.
  NetWorthProvider._({
    required NetWorthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'netWorthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$netWorthHash();

  @override
  String toString() {
    return r'netWorthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NetWorthData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetWorthData> create(Ref ref) {
    final argument = this.argument as String;
    return netWorth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NetWorthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$netWorthHash() => r'6db8fdc18b4132bdc096db573a2a190037dbb626';

/// Computes net worth from all active accounts in a budget.

final class NetWorthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NetWorthData>, String> {
  NetWorthFamily._()
    : super(
        retry: null,
        name: r'netWorthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Computes net worth from all active accounts in a budget.

  NetWorthProvider call(String budgetId) =>
      NetWorthProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'netWorthProvider';
}
