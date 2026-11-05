// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs one assistant conversation in a budget.

@ProviderFor(AssistantChat)
final assistantChatProvider = AssistantChatFamily._();

/// Runs one assistant conversation in a budget.
final class AssistantChatProvider
    extends $NotifierProvider<AssistantChat, AssistantChatState> {
  /// Runs one assistant conversation in a budget.
  AssistantChatProvider._({
    required AssistantChatFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assistantChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assistantChatHash();

  @override
  String toString() {
    return r'assistantChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AssistantChat create() => AssistantChat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssistantChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assistantChatHash() => r'80e729a063dc4784cfcec544d1fac4ecbc1416d6';

/// Runs one assistant conversation in a budget.

final class AssistantChatFamily extends $Family
    with
        $ClassFamilyOverride<
          AssistantChat,
          AssistantChatState,
          AssistantChatState,
          AssistantChatState,
          String
        > {
  AssistantChatFamily._()
    : super(
        retry: null,
        name: r'assistantChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Runs one assistant conversation in a budget.

  AssistantChatProvider call(String budgetId) =>
      AssistantChatProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'assistantChatProvider';
}

/// Runs one assistant conversation in a budget.

abstract class _$AssistantChat extends $Notifier<AssistantChatState> {
  late final _$args = ref.$arg as String;
  String get budgetId => _$args;

  AssistantChatState build(String budgetId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AssistantChatState, AssistantChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssistantChatState, AssistantChatState>,
              AssistantChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
