// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One headline summary per entity for the home screen, straight from
/// `entity.listSummaries`. The server composes Ready to Assign, overspent
/// envelopes, net worth, uncategorised transactions, due recurring
/// transactions and pending proposals in that one call.

@ProviderFor(entitySummaries)
final entitySummariesProvider = EntitySummariesProvider._();

/// One headline summary per entity for the home screen, straight from
/// `entity.listSummaries`. The server composes Ready to Assign, overspent
/// envelopes, net worth, uncategorised transactions, due recurring
/// transactions and pending proposals in that one call.

final class EntitySummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EntitySummaryView>>,
          List<EntitySummaryView>,
          FutureOr<List<EntitySummaryView>>
        >
    with
        $FutureModifier<List<EntitySummaryView>>,
        $FutureProvider<List<EntitySummaryView>> {
  /// One headline summary per entity for the home screen, straight from
  /// `entity.listSummaries`. The server composes Ready to Assign, overspent
  /// envelopes, net worth, uncategorised transactions, due recurring
  /// transactions and pending proposals in that one call.
  EntitySummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitySummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitySummariesHash();

  @$internal
  @override
  $FutureProviderElement<List<EntitySummaryView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EntitySummaryView>> create(Ref ref) {
    return entitySummaries(ref);
  }
}

String _$entitySummariesHash() => r'3ab6d4d011e656cad3c52dc1ced3c2d63b0ba450';
