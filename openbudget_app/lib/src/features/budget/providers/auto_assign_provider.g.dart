// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_assign_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes an auto-assign proposal from the month view alone: Ready to
/// Assign money goes to underfunded envelopes, in envelope order. Nothing
/// is written until [AutoAssignActions.execute] sends one `setAllocations`.

@ProviderFor(autoAssignProposal)
final autoAssignProposalProvider = AutoAssignProposalFamily._();

/// Computes an auto-assign proposal from the month view alone: Ready to
/// Assign money goes to underfunded envelopes, in envelope order. Nothing
/// is written until [AutoAssignActions.execute] sends one `setAllocations`.

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
  /// Computes an auto-assign proposal from the month view alone: Ready to
  /// Assign money goes to underfunded envelopes, in envelope order. Nothing
  /// is written until [AutoAssignActions.execute] sends one `setAllocations`.
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
    r'6608a0f118c25a273d358154bbc985a29a0e10ac';

/// Computes an auto-assign proposal from the month view alone: Ready to
/// Assign money goes to underfunded envelopes, in envelope order. Nothing
/// is written until [AutoAssignActions.execute] sends one `setAllocations`.

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

  /// Computes an auto-assign proposal from the month view alone: Ready to
  /// Assign money goes to underfunded envelopes, in envelope order. Nothing
  /// is written until [AutoAssignActions.execute] sends one `setAllocations`.

  AutoAssignProposalProvider call(String entityId) =>
      AutoAssignProposalProvider._(argument: entityId, from: this);

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

String _$autoAssignActionsHash() => r'20ff4d02107a1913bef883bea54da984d5b287fe';

abstract class _$AutoAssignActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
