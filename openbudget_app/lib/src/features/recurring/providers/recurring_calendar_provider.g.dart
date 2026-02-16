// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Generates future occurrences for all active recurring transactions
/// within a given month.

@ProviderFor(recurringCalendar)
final recurringCalendarProvider = RecurringCalendarFamily._();

/// Generates future occurrences for all active recurring transactions
/// within a given month.

final class RecurringCalendarProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, List<ScheduledOccurrence>>>,
          Map<int, List<ScheduledOccurrence>>,
          FutureOr<Map<int, List<ScheduledOccurrence>>>
        >
    with
        $FutureModifier<Map<int, List<ScheduledOccurrence>>>,
        $FutureProvider<Map<int, List<ScheduledOccurrence>>> {
  /// Generates future occurrences for all active recurring transactions
  /// within a given month.
  RecurringCalendarProvider._({
    required RecurringCalendarFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'recurringCalendarProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringCalendarHash();

  @override
  String toString() {
    return r'recurringCalendarProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, List<ScheduledOccurrence>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, List<ScheduledOccurrence>>> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return recurringCalendar(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringCalendarProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringCalendarHash() => r'57abfd79783b81fa0927d1748a9f398b3055201f';

/// Generates future occurrences for all active recurring transactions
/// within a given month.

final class RecurringCalendarFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<int, List<ScheduledOccurrence>>>,
          (String, int, int)
        > {
  RecurringCalendarFamily._()
    : super(
        retry: null,
        name: r'recurringCalendarProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Generates future occurrences for all active recurring transactions
  /// within a given month.

  RecurringCalendarProvider call(String budgetId, int year, int month) =>
      RecurringCalendarProvider._(
        argument: (budgetId, year, month),
        from: this,
      );

  @override
  String toString() => r'recurringCalendarProvider';
}
