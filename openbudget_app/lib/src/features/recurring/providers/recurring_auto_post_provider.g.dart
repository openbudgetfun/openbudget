// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_auto_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the count of due recurring transactions for a budget.

@ProviderFor(recurringDueCount)
final recurringDueCountProvider = RecurringDueCountFamily._();

/// Fetches the count of due recurring transactions for a budget.

final class RecurringDueCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Fetches the count of due recurring transactions for a budget.
  RecurringDueCountProvider._({
    required RecurringDueCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringDueCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringDueCountHash();

  @override
  String toString() {
    return r'recurringDueCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return recurringDueCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringDueCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringDueCountHash() => r'b80a0324a1ac47b7cb1225133da4cc50d9ab1797';

/// Fetches the count of due recurring transactions for a budget.

final class RecurringDueCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  RecurringDueCountFamily._()
    : super(
        retry: null,
        name: r'recurringDueCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the count of due recurring transactions for a budget.

  RecurringDueCountProvider call(String budgetId) =>
      RecurringDueCountProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'recurringDueCountProvider';
}

/// Posts all due recurring transactions and returns the count posted.

@ProviderFor(RecurringAutoPostActions)
final recurringAutoPostActionsProvider = RecurringAutoPostActionsProvider._();

/// Posts all due recurring transactions and returns the count posted.
final class RecurringAutoPostActionsProvider
    extends $NotifierProvider<RecurringAutoPostActions, AsyncValue<void>> {
  /// Posts all due recurring transactions and returns the count posted.
  RecurringAutoPostActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringAutoPostActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringAutoPostActionsHash();

  @$internal
  @override
  RecurringAutoPostActions create() => RecurringAutoPostActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$recurringAutoPostActionsHash() =>
    r'b424c733c8b6fb867d912dcce4393ba71956269c';

/// Posts all due recurring transactions and returns the count posted.

abstract class _$RecurringAutoPostActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
