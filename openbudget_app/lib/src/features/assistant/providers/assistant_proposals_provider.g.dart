// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_proposals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The proposals for one budget, newest first in both groups.

@ProviderFor(AssistantProposals)
final assistantProposalsProvider = AssistantProposalsFamily._();

/// The proposals for one budget, newest first in both groups.
final class AssistantProposalsProvider
    extends
        $AsyncNotifierProvider<AssistantProposals, AssistantProposalsState> {
  /// The proposals for one budget, newest first in both groups.
  AssistantProposalsProvider._({
    required AssistantProposalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assistantProposalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assistantProposalsHash();

  @override
  String toString() {
    return r'assistantProposalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AssistantProposals create() => AssistantProposals();

  @override
  bool operator ==(Object other) {
    return other is AssistantProposalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assistantProposalsHash() =>
    r'4687c54ab6ce3e36eaa681025a4ffc30daf3b12e';

/// The proposals for one budget, newest first in both groups.

final class AssistantProposalsFamily extends $Family
    with
        $ClassFamilyOverride<
          AssistantProposals,
          AsyncValue<AssistantProposalsState>,
          AssistantProposalsState,
          FutureOr<AssistantProposalsState>,
          String
        > {
  AssistantProposalsFamily._()
    : super(
        retry: null,
        name: r'assistantProposalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The proposals for one budget, newest first in both groups.

  AssistantProposalsProvider call(String budgetId) =>
      AssistantProposalsProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'assistantProposalsProvider';
}

/// The proposals for one budget, newest first in both groups.

abstract class _$AssistantProposals
    extends $AsyncNotifier<AssistantProposalsState> {
  late final _$args = ref.$arg as String;
  String get budgetId => _$args;

  FutureOr<AssistantProposalsState> build(String budgetId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AssistantProposalsState>,
              AssistantProposalsState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AssistantProposalsState>,
                AssistantProposalsState
              >,
              AsyncValue<AssistantProposalsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
