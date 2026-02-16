// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_match_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Finds the matching envelope for a payee based on transaction rules.
///
/// Returns null if no rule matches or the payee has no rule.

@ProviderFor(ruleMatchEnvelope)
final ruleMatchEnvelopeProvider = RuleMatchEnvelopeFamily._();

/// Finds the matching envelope for a payee based on transaction rules.
///
/// Returns null if no rule matches or the payee has no rule.

final class RuleMatchEnvelopeProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Finds the matching envelope for a payee based on transaction rules.
  ///
  /// Returns null if no rule matches or the payee has no rule.
  RuleMatchEnvelopeProvider._({
    required RuleMatchEnvelopeFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'ruleMatchEnvelopeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ruleMatchEnvelopeHash();

  @override
  String toString() {
    return r'ruleMatchEnvelopeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return ruleMatchEnvelope(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is RuleMatchEnvelopeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ruleMatchEnvelopeHash() => r'7e166f600d4917dc98570a7960a498744c0b4060';

/// Finds the matching envelope for a payee based on transaction rules.
///
/// Returns null if no rule matches or the payee has no rule.

final class RuleMatchEnvelopeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (String, String)> {
  RuleMatchEnvelopeFamily._()
    : super(
        retry: null,
        name: r'ruleMatchEnvelopeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Finds the matching envelope for a payee based on transaction rules.
  ///
  /// Returns null if no rule matches or the payee has no rule.

  RuleMatchEnvelopeProvider call(String payeeId, String budgetId) =>
      RuleMatchEnvelopeProvider._(argument: (payeeId, budgetId), from: this);

  @override
  String toString() => r'ruleMatchEnvelopeProvider';
}
