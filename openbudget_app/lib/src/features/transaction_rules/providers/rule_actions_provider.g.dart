// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides mutation operations for transaction rules.

@ProviderFor(RuleActions)
final ruleActionsProvider = RuleActionsProvider._();

/// Provides mutation operations for transaction rules.
final class RuleActionsProvider
    extends $AsyncNotifierProvider<RuleActions, void> {
  /// Provides mutation operations for transaction rules.
  RuleActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ruleActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ruleActionsHash();

  @$internal
  @override
  RuleActions create() => RuleActions();
}

String _$ruleActionsHash() => r'edcc1bab959e624a9d3da021c2733ebb5c76b3d2';

/// Provides mutation operations for transaction rules.

abstract class _$RuleActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
