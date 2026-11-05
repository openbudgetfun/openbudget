// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_proposal_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies and dismisses proposals, then refreshes everything that shows
/// them.

@ProviderFor(AssistantProposalActions)
final assistantProposalActionsProvider = AssistantProposalActionsProvider._();

/// Applies and dismisses proposals, then refreshes everything that shows
/// them.
final class AssistantProposalActionsProvider
    extends $NotifierProvider<AssistantProposalActions, void> {
  /// Applies and dismisses proposals, then refreshes everything that shows
  /// them.
  AssistantProposalActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantProposalActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantProposalActionsHash();

  @$internal
  @override
  AssistantProposalActions create() => AssistantProposalActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$assistantProposalActionsHash() =>
    r'c98005b9070ecb2c8bc75a3aa563a9338c05aa1d';

/// Applies and dismisses proposals, then refreshes everything that shows
/// them.

abstract class _$AssistantProposalActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
