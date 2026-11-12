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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../envelope_goals/envelope_goal.dart' as _ibjfpsgz;
import '../envelopes/envelope.dart' as _im7oo7f2;

/// One envelope's figures for one month, in base minor units.
abstract class EnvelopeMonthView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EnvelopeMonthView._({
    required this.envelope,
    this.goal,
    required this.carryoverMinor,
    required this.allocatedMinor,
    required this.activityMinor,
    required this.availableMinor,
    required this.goalUnderfundedMinor,
  });

  factory EnvelopeMonthView({
    required _im7oo7f2.Envelope envelope,
    _ibjfpsgz.EnvelopeGoal? goal,
    required int carryoverMinor,
    required int allocatedMinor,
    required int activityMinor,
    required int availableMinor,
    required int goalUnderfundedMinor,
  }) = _EnvelopeMonthViewImpl;

  factory EnvelopeMonthView.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvelopeMonthView(
      envelope: _is0sbm8r.Protocol().deserialize<_im7oo7f2.Envelope>(
        jsonSerialization['envelope'],
      ),
      goal: jsonSerialization['goal'] == null
          ? null
          : _is0sbm8r.Protocol().deserialize<_ibjfpsgz.EnvelopeGoal>(
              jsonSerialization['goal'],
            ),
      carryoverMinor: jsonSerialization['carryoverMinor'] as int,
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
      activityMinor: jsonSerialization['activityMinor'] as int,
      availableMinor: jsonSerialization['availableMinor'] as int,
      goalUnderfundedMinor: jsonSerialization['goalUnderfundedMinor'] as int,
    );
  }

  _im7oo7f2.Envelope envelope;

  _ibjfpsgz.EnvelopeGoal? goal;

  /// Available at the end of last month, floored at 0.
  int carryoverMinor;

  /// Assigned this month.
  int allocatedMinor;

  /// Sum of this month's lines; negative is spending.
  int activityMinor;

  /// carryoverMinor + allocatedMinor + activityMinor. Negative means
  /// overspent.
  int availableMinor;

  /// What the goal still needs this month, from goal_math; 0 when met or
  /// when there is no goal.
  int goalUnderfundedMinor;

  /// Returns a shallow copy of this [EnvelopeMonthView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EnvelopeMonthView copyWith({
    _im7oo7f2.Envelope? envelope,
    _ibjfpsgz.EnvelopeGoal? goal = const _UndefinedEnvelopeMonthView$goal(),
    int? carryoverMinor,
    int? allocatedMinor,
    int? activityMinor,
    int? availableMinor,
    int? goalUnderfundedMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvelopeMonthView',
      'envelope': envelope.toJson(),
      if (goal != null) 'goal': goal?.toJson(),
      'carryoverMinor': carryoverMinor,
      'allocatedMinor': allocatedMinor,
      'activityMinor': activityMinor,
      'availableMinor': availableMinor,
      'goalUnderfundedMinor': goalUnderfundedMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EnvelopeMonthView',
      'envelope': envelope.toJsonForProtocol(),
      if (goal != null) 'goal': goal?.toJsonForProtocol(),
      'carryoverMinor': carryoverMinor,
      'allocatedMinor': allocatedMinor,
      'activityMinor': activityMinor,
      'availableMinor': availableMinor,
      'goalUnderfundedMinor': goalUnderfundedMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UndefinedEnvelopeMonthView$goal extends _is.UndefinedSentinel
    implements _ibjfpsgz.EnvelopeGoal {
  const _UndefinedEnvelopeMonthView$goal();
}

class _EnvelopeMonthViewImpl extends EnvelopeMonthView {
  _EnvelopeMonthViewImpl({
    required _im7oo7f2.Envelope envelope,
    _ibjfpsgz.EnvelopeGoal? goal,
    required int carryoverMinor,
    required int allocatedMinor,
    required int activityMinor,
    required int availableMinor,
    required int goalUnderfundedMinor,
  }) : super._(
         envelope: envelope,
         goal: goal,
         carryoverMinor: carryoverMinor,
         allocatedMinor: allocatedMinor,
         activityMinor: activityMinor,
         availableMinor: availableMinor,
         goalUnderfundedMinor: goalUnderfundedMinor,
       );

  /// Returns a shallow copy of this [EnvelopeMonthView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EnvelopeMonthView copyWith({
    _im7oo7f2.Envelope? envelope,
    _ibjfpsgz.EnvelopeGoal? goal = const _UndefinedEnvelopeMonthView$goal(),
    int? carryoverMinor,
    int? allocatedMinor,
    int? activityMinor,
    int? availableMinor,
    int? goalUnderfundedMinor,
  }) {
    return EnvelopeMonthView(
      envelope: envelope ?? this.envelope.copyWith(),
      goal: goal is _is.UndefinedSentinel ? this.goal?.copyWith() : goal,
      carryoverMinor: carryoverMinor ?? this.carryoverMinor,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
      activityMinor: activityMinor ?? this.activityMinor,
      availableMinor: availableMinor ?? this.availableMinor,
      goalUnderfundedMinor: goalUnderfundedMinor ?? this.goalUnderfundedMinor,
    );
  }
}
