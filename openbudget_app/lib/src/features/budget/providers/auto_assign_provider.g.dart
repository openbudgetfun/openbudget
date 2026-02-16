// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_assign_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes an auto-assign proposal that distributes Ready to Assign money
/// across underfunded envelopes based on their goals.

@ProviderFor(autoAssignProposal)
final autoAssignProposalProvider = AutoAssignProposalFamily._();

/// Computes an auto-assign proposal that distributes Ready to Assign money
/// across underfunded envelopes based on their goals.

final class AutoAssignProposalProvider
    extends
        $FunctionalProvider<
          AsyncValue<AutoAssignProposal>,
          AutoAssignProposal,
          FutureOr<AutoAssignProposal>
        >
    with
        $FutureModifier<AutoAssignProposal>,
        $FutureProvider<AutoAssignProposal> {
  /// Computes an auto-assign proposal that distributes Ready to Assign money
  /// across underfunded envelopes based on their goals.
  AutoAssignProposalProvider._({
    required AutoAssignProposalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'autoAssignProposalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$autoAssignProposalHash();

  @override
  String toString() {
    return r'autoAssignProposalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AutoAssignProposal> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AutoAssignProposal> create(Ref ref) {
    final argument = this.argument as String;
    return autoAssignProposal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AutoAssignProposalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$autoAssignProposalHash() =>
    r'1f3cbe112382e1fca9f467d99660eb290ed0718b';

/// Computes an auto-assign proposal that distributes Ready to Assign money
/// across underfunded envelopes based on their goals.

final class AutoAssignProposalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AutoAssignProposal>, String> {
  AutoAssignProposalFamily._()
    : super(
        retry: null,
        name: r'autoAssignProposalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Computes an auto-assign proposal that distributes Ready to Assign money
  /// across underfunded envelopes based on their goals.

  AutoAssignProposalProvider call(String budgetId) =>
      AutoAssignProposalProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'autoAssignProposalProvider';
}

@ProviderFor(AutoAssignActions)
final autoAssignActionsProvider = AutoAssignActionsProvider._();

final class AutoAssignActionsProvider
    extends $NotifierProvider<AutoAssignActions, AsyncValue<void>> {
  AutoAssignActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoAssignActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoAssignActionsHash();

  @$internal
  @override
  AutoAssignActions create() => AutoAssignActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$autoAssignActionsHash() => r'b541e2fcd4eb4b864fca1dc1f5c4a779db158ba6';

abstract class _$AutoAssignActions extends $Notifier<AsyncValue<void>> {
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
