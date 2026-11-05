// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_usage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How much of the included assistant usage is left this month.

@ProviderFor(assistantUsage)
final assistantUsageProvider = AssistantUsageProvider._();

/// How much of the included assistant usage is left this month.

final class AssistantUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<AgentUsageView>,
          AgentUsageView,
          FutureOr<AgentUsageView>
        >
    with $FutureModifier<AgentUsageView>, $FutureProvider<AgentUsageView> {
  /// How much of the included assistant usage is left this month.
  AssistantUsageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantUsageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantUsageHash();

  @$internal
  @override
  $FutureProviderElement<AgentUsageView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AgentUsageView> create(Ref ref) {
    return assistantUsage(ref);
  }
}

String _$assistantUsageHash() => r'51402336906d4cdbab7265348bd239c0ec718ced';
