// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combined net worth in the user's reporting currency, straight from
/// `report.netWorth`. No conversion happens in the app: incomplete
/// currencies are listed, never guessed.

@ProviderFor(netWorth)
final netWorthProvider = NetWorthProvider._();

/// Combined net worth in the user's reporting currency, straight from
/// `report.netWorth`. No conversion happens in the app: incomplete
/// currencies are listed, never guessed.

final class NetWorthProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetWorthView>,
          NetWorthView,
          FutureOr<NetWorthView>
        >
    with $FutureModifier<NetWorthView>, $FutureProvider<NetWorthView> {
  /// Combined net worth in the user's reporting currency, straight from
  /// `report.netWorth`. No conversion happens in the app: incomplete
  /// currencies are listed, never guessed.
  NetWorthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'netWorthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$netWorthHash();

  @$internal
  @override
  $FutureProviderElement<NetWorthView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetWorthView> create(Ref ref) {
    return netWorth(ref);
  }
}

String _$netWorthHash() => r'ea734fe4e27371936f61554cb513216090ede2d6';

/// Net worth scoped to the included entities only, for the chip filter on
/// the breakdown tab. A changed id set re-queries.

@ProviderFor(netWorthForEntities)
final netWorthForEntitiesProvider = NetWorthForEntitiesFamily._();

/// Net worth scoped to the included entities only, for the chip filter on
/// the breakdown tab. A changed id set re-queries.

final class NetWorthForEntitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetWorthView>,
          NetWorthView,
          FutureOr<NetWorthView>
        >
    with $FutureModifier<NetWorthView>, $FutureProvider<NetWorthView> {
  /// Net worth scoped to the included entities only, for the chip filter on
  /// the breakdown tab. A changed id set re-queries.
  NetWorthForEntitiesProvider._({
    required NetWorthForEntitiesFamily super.from,
    required Set<String> super.argument,
  }) : super(
         retry: null,
         name: r'netWorthForEntitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$netWorthForEntitiesHash();

  @override
  String toString() {
    return r'netWorthForEntitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NetWorthView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetWorthView> create(Ref ref) {
    final argument = this.argument as Set<String>;
    return netWorthForEntities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NetWorthForEntitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$netWorthForEntitiesHash() =>
    r'9b92a3fc9b57e21ac1a9327628f16197e485f241';

/// Net worth scoped to the included entities only, for the chip filter on
/// the breakdown tab. A changed id set re-queries.

final class NetWorthForEntitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NetWorthView>, Set<String>> {
  NetWorthForEntitiesFamily._()
    : super(
        retry: null,
        name: r'netWorthForEntitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Net worth scoped to the included entities only, for the chip filter on
  /// the breakdown tab. A changed id set re-queries.

  NetWorthForEntitiesProvider call(Set<String> entityIds) =>
      NetWorthForEntitiesProvider._(argument: entityIds, from: this);

  @override
  String toString() => r'netWorthForEntitiesProvider';
}

/// Net worth history for one range toggle, from `report.netWorthHistory`.
///
/// `all` asks for a bounded window starting at the earliest possible point
/// the server accepts; the server limits and clamps ranges itself.

@ProviderFor(netWorthHistory)
final netWorthHistoryProvider = NetWorthHistoryFamily._();

/// Net worth history for one range toggle, from `report.netWorthHistory`.
///
/// `all` asks for a bounded window starting at the earliest possible point
/// the server accepts; the server limits and clamps ranges itself.

final class NetWorthHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetWorthHistoryView>,
          NetWorthHistoryView,
          FutureOr<NetWorthHistoryView>
        >
    with
        $FutureModifier<NetWorthHistoryView>,
        $FutureProvider<NetWorthHistoryView> {
  /// Net worth history for one range toggle, from `report.netWorthHistory`.
  ///
  /// `all` asks for a bounded window starting at the earliest possible point
  /// the server accepts; the server limits and clamps ranges itself.
  NetWorthHistoryProvider._({
    required NetWorthHistoryFamily super.from,
    required NetWorthRange super.argument,
  }) : super(
         retry: null,
         name: r'netWorthHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$netWorthHistoryHash();

  @override
  String toString() {
    return r'netWorthHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NetWorthHistoryView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetWorthHistoryView> create(Ref ref) {
    final argument = this.argument as NetWorthRange;
    return netWorthHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NetWorthHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$netWorthHistoryHash() => r'fcbc6cc3435c8b100f26ac54ada1f932947b5094';

/// Net worth history for one range toggle, from `report.netWorthHistory`.
///
/// `all` asks for a bounded window starting at the earliest possible point
/// the server accepts; the server limits and clamps ranges itself.

final class NetWorthHistoryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<NetWorthHistoryView>,
          NetWorthRange
        > {
  NetWorthHistoryFamily._()
    : super(
        retry: null,
        name: r'netWorthHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Net worth history for one range toggle, from `report.netWorthHistory`.
  ///
  /// `all` asks for a bounded window starting at the earliest possible point
  /// the server accepts; the server limits and clamps ranges itself.

  NetWorthHistoryProvider call(NetWorthRange range) =>
      NetWorthHistoryProvider._(argument: range, from: this);

  @override
  String toString() => r'netWorthHistoryProvider';
}
