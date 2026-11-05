// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Payment actions offered by the Plus screen.
///
/// Every rail funnels through here so the screen only has to show one busy
/// state and one message. Successful purchases invalidate
/// [plusEntitlementProvider] so the plan card updates when the webhook lands.

@ProviderFor(PlusActions)
final plusActionsProvider = PlusActionsProvider._();

/// Payment actions offered by the Plus screen.
///
/// Every rail funnels through here so the screen only has to show one busy
/// state and one message. Successful purchases invalidate
/// [plusEntitlementProvider] so the plan card updates when the webhook lands.
final class PlusActionsProvider
    extends $NotifierProvider<PlusActions, PlusActionState> {
  /// Payment actions offered by the Plus screen.
  ///
  /// Every rail funnels through here so the screen only has to show one busy
  /// state and one message. Successful purchases invalidate
  /// [plusEntitlementProvider] so the plan card updates when the webhook lands.
  PlusActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusActionsHash();

  @$internal
  @override
  PlusActions create() => PlusActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusActionState>(value),
    );
  }
}

String _$plusActionsHash() => r'7ae870076d75fb5fe3d012468e797080302617ac';

/// Payment actions offered by the Plus screen.
///
/// Every rail funnels through here so the screen only has to show one busy
/// state and one message. Successful purchases invalidate
/// [plusEntitlementProvider] so the plan card updates when the webhook lands.

abstract class _$PlusActions extends $Notifier<PlusActionState> {
  PlusActionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlusActionState, PlusActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlusActionState, PlusActionState>,
              PlusActionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
