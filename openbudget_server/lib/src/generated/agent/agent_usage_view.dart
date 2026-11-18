/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

import '../agent/agent_provider.dart' as _ice504k4;

/// How much of the built-in agent allowance is left this period.
abstract class AgentUsageView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AgentUsageView._({
    required this.provider,
    required this.allowanceMicroUsd,
    required this.usedMicroUsd,
    this.periodEnd,
    this.conversationsLeft,
  });

  factory AgentUsageView({
    required _ice504k4.AgentProvider provider,
    required int allowanceMicroUsd,
    required int usedMicroUsd,
    DateTime? periodEnd,
    int? conversationsLeft,
  }) = _AgentUsageViewImpl;

  factory AgentUsageView.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentUsageView(
      provider: _ice504k4.AgentProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      allowanceMicroUsd: jsonSerialization['allowanceMicroUsd'] as int,
      usedMicroUsd: jsonSerialization['usedMicroUsd'] as int,
      periodEnd: jsonSerialization['periodEnd'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['periodEnd']),
      conversationsLeft: jsonSerialization['conversationsLeft'] as int?,
    );
  }

  _ice504k4.AgentProvider provider;

  /// Usage included in the plan this period, in micro-dollars. Zero for BYO.
  int allowanceMicroUsd;

  /// Metered usage this period, in micro-dollars. Zero for BYO.
  int usedMicroUsd;

  /// When the allowance next resets, when the user is subscribed.
  DateTime? periodEnd;

  /// About how many typical conversations the remaining allowance covers,
  /// from the user's own median cost per conversation. Null until the user
  /// has had three conversations, and for bring-your-own providers.
  int? conversationsLeft;

  /// Returns a shallow copy of this [AgentUsageView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentUsageView copyWith({
    _ice504k4.AgentProvider? provider,
    int? allowanceMicroUsd,
    int? usedMicroUsd,
    DateTime? periodEnd = const _is.$UndefinedDateTime(),
    int? conversationsLeft,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentUsageView',
      'provider': provider.toJson(),
      'allowanceMicroUsd': allowanceMicroUsd,
      'usedMicroUsd': usedMicroUsd,
      if (periodEnd != null) 'periodEnd': periodEnd?.toJson(),
      if (conversationsLeft != null) 'conversationsLeft': conversationsLeft,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentUsageView',
      'provider': provider.toJson(),
      'allowanceMicroUsd': allowanceMicroUsd,
      'usedMicroUsd': usedMicroUsd,
      if (periodEnd != null) 'periodEnd': periodEnd?.toJson(),
      if (conversationsLeft != null) 'conversationsLeft': conversationsLeft,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentUsageViewImpl extends AgentUsageView {
  _AgentUsageViewImpl({
    required _ice504k4.AgentProvider provider,
    required int allowanceMicroUsd,
    required int usedMicroUsd,
    DateTime? periodEnd,
    int? conversationsLeft,
  }) : super._(
         provider: provider,
         allowanceMicroUsd: allowanceMicroUsd,
         usedMicroUsd: usedMicroUsd,
         periodEnd: periodEnd,
         conversationsLeft: conversationsLeft,
       );

  /// Returns a shallow copy of this [AgentUsageView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentUsageView copyWith({
    _ice504k4.AgentProvider? provider,
    int? allowanceMicroUsd,
    int? usedMicroUsd,
    DateTime? periodEnd = const _is.$UndefinedDateTime(),
    Object? conversationsLeft = _Undefined,
  }) {
    return AgentUsageView(
      provider: provider ?? this.provider,
      allowanceMicroUsd: allowanceMicroUsd ?? this.allowanceMicroUsd,
      usedMicroUsd: usedMicroUsd ?? this.usedMicroUsd,
      periodEnd: periodEnd is _is.UndefinedSentinel
          ? this.periodEnd
          : periodEnd,
      conversationsLeft: conversationsLeft is int?
          ? conversationsLeft
          : this.conversationsLeft,
    );
  }
}
