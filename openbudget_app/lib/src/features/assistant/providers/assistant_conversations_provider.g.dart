// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_conversations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The conversations in one budget, newest first.

@ProviderFor(assistantConversations)
final assistantConversationsProvider = AssistantConversationsFamily._();

/// The conversations in one budget, newest first.

final class AssistantConversationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AgentConversation>>,
          List<AgentConversation>,
          FutureOr<List<AgentConversation>>
        >
    with
        $FutureModifier<List<AgentConversation>>,
        $FutureProvider<List<AgentConversation>> {
  /// The conversations in one budget, newest first.
  AssistantConversationsProvider._({
    required AssistantConversationsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assistantConversationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assistantConversationsHash();

  @override
  String toString() {
    return r'assistantConversationsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AgentConversation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AgentConversation>> create(Ref ref) {
    final argument = this.argument as String;
    return assistantConversations(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AssistantConversationsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assistantConversationsHash() =>
    r'f631b939c21046df9796fac7ab74add2e8ccc082';

/// The conversations in one budget, newest first.

final class AssistantConversationsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AgentConversation>>, String> {
  AssistantConversationsFamily._()
    : super(
        retry: null,
        name: r'assistantConversationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The conversations in one budget, newest first.

  AssistantConversationsProvider call(String entityId) =>
      AssistantConversationsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'assistantConversationsProvider';
}
