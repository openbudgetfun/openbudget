// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_entitlement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The subscription that currently grants OpenBudget Plus, or null on the
/// free plan.
///
/// Other features watch this provider to unlock paid surfaces. Refresh it
/// after any purchase or portal visit with `ref.invalidate`.

@ProviderFor(plusEntitlement)
final plusEntitlementProvider = PlusEntitlementProvider._();

/// The subscription that currently grants OpenBudget Plus, or null on the
/// free plan.
///
/// Other features watch this provider to unlock paid surfaces. Refresh it
/// after any purchase or portal visit with `ref.invalidate`.

final class PlusEntitlementProvider
    extends
        $FunctionalProvider<
          AsyncValue<Entitlement?>,
          Entitlement?,
          FutureOr<Entitlement?>
        >
    with $FutureModifier<Entitlement?>, $FutureProvider<Entitlement?> {
  /// The subscription that currently grants OpenBudget Plus, or null on the
  /// free plan.
  ///
  /// Other features watch this provider to unlock paid surfaces. Refresh it
  /// after any purchase or portal visit with `ref.invalidate`.
  PlusEntitlementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusEntitlementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusEntitlementHash();

  @$internal
  @override
  $FutureProviderElement<Entitlement?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Entitlement?> create(Ref ref) {
    return plusEntitlement(ref);
  }
}

String _$plusEntitlementHash() => r'd1e6ef4e1071422dc8201dd7594084d509c4c6e0';
