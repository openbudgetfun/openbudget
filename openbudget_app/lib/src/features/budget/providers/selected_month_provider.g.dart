// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month the plan screens show, as an int yyyymm (202611).
///
/// An integer has no time-zone ambiguity, compares directly, and goes
/// straight into `budget.getMonth` and `MonthKey`.

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthFamily._();

/// The month the plan screens show, as an int yyyymm (202611).
///
/// An integer has no time-zone ambiguity, compares directly, and goes
/// straight into `budget.getMonth` and `MonthKey`.
final class SelectedMonthProvider
    extends $NotifierProvider<SelectedMonth, int> {
  /// The month the plan screens show, as an int yyyymm (202611).
  ///
  /// An integer has no time-zone ambiguity, compares directly, and goes
  /// straight into `budget.getMonth` and `MonthKey`.
  SelectedMonthProvider._({
    required SelectedMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectedMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @override
  String toString() {
    return r'selectedMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedMonthHash() => r'594c065f6154a065f57b6a592a02542c8dd53bc8';

/// The month the plan screens show, as an int yyyymm (202611).
///
/// An integer has no time-zone ambiguity, compares directly, and goes
/// straight into `budget.getMonth` and `MonthKey`.

final class SelectedMonthFamily extends $Family
    with $ClassFamilyOverride<SelectedMonth, int, int, int, String> {
  SelectedMonthFamily._()
    : super(
        retry: null,
        name: r'selectedMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The month the plan screens show, as an int yyyymm (202611).
  ///
  /// An integer has no time-zone ambiguity, compares directly, and goes
  /// straight into `budget.getMonth` and `MonthKey`.

  SelectedMonthProvider call(String entityId) =>
      SelectedMonthProvider._(argument: entityId, from: this);

  @override
  String toString() => r'selectedMonthProvider';
}

/// The month the plan screens show, as an int yyyymm (202611).
///
/// An integer has no time-zone ambiguity, compares directly, and goes
/// straight into `budget.getMonth` and `MonthKey`.

abstract class _$SelectedMonth extends $Notifier<int> {
  late final _$args = ref.$arg as String;
  String get entityId => _$args;

  int build(String entityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
