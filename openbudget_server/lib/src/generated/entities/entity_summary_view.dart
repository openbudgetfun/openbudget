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

import '../entities/entity.dart' as _im38gx2o;

/// One entity's headline figures for the home screen. `entity.listSummaries`
/// returns one per entity, so the home screen loads with one call.
abstract class EntitySummaryView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EntitySummaryView._({
    required this.entity,
    required this.month,
    this.readyToAssignMinor,
    required this.overspentEnvelopeCount,
    required this.netWorthMinor,
    required this.netWorthComplete,
    required this.uncategorizedCount,
    required this.pendingProposalCount,
    required this.dueRecurringCount,
  });

  factory EntitySummaryView({
    required _im38gx2o.Entity entity,
    required int month,
    int? readyToAssignMinor,
    required int overspentEnvelopeCount,
    required int netWorthMinor,
    required bool netWorthComplete,
    required int uncategorizedCount,
    required int pendingProposalCount,
    required int dueRecurringCount,
  }) = _EntitySummaryViewImpl;

  factory EntitySummaryView.fromJson(Map<String, dynamic> jsonSerialization) {
    return EntitySummaryView(
      entity: _is0sbm8r.Protocol().deserialize<_im38gx2o.Entity>(
        jsonSerialization['entity'],
      ),
      month: jsonSerialization['month'] as int,
      readyToAssignMinor: jsonSerialization['readyToAssignMinor'] as int?,
      overspentEnvelopeCount:
          jsonSerialization['overspentEnvelopeCount'] as int,
      netWorthMinor: jsonSerialization['netWorthMinor'] as int,
      netWorthComplete: _is.BoolJsonExtension.fromJson(
        jsonSerialization['netWorthComplete'],
      ),
      uncategorizedCount: jsonSerialization['uncategorizedCount'] as int,
      pendingProposalCount: jsonSerialization['pendingProposalCount'] as int,
      dueRecurringCount: jsonSerialization['dueRecurringCount'] as int,
    );
  }

  _im38gx2o.Entity entity;

  /// The current budget month (yyyymm) in the entity's time zone.
  int month;

  /// Ready to Assign this month in base minor units. Null when the entity
  /// has no on-budget account.
  int? readyToAssignMinor;

  int overspentEnvelopeCount;

  /// Assets plus liabilities in base minor units, at today's rates.
  int netWorthMinor;

  /// False when some account could not be converted; netWorthMinor then
  /// leaves it out.
  bool netWorthComplete;

  /// Transactions this month with an uncategorised outflow line on budget.
  int uncategorizedCount;

  int pendingProposalCount;

  int dueRecurringCount;

  /// Returns a shallow copy of this [EntitySummaryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EntitySummaryView copyWith({
    _im38gx2o.Entity? entity,
    int? month,
    int? readyToAssignMinor,
    int? overspentEnvelopeCount,
    int? netWorthMinor,
    bool? netWorthComplete,
    int? uncategorizedCount,
    int? pendingProposalCount,
    int? dueRecurringCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EntitySummaryView',
      'entity': entity.toJson(),
      'month': month,
      if (readyToAssignMinor != null) 'readyToAssignMinor': readyToAssignMinor,
      'overspentEnvelopeCount': overspentEnvelopeCount,
      'netWorthMinor': netWorthMinor,
      'netWorthComplete': netWorthComplete,
      'uncategorizedCount': uncategorizedCount,
      'pendingProposalCount': pendingProposalCount,
      'dueRecurringCount': dueRecurringCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EntitySummaryView',
      'entity': entity.toJsonForProtocol(),
      'month': month,
      if (readyToAssignMinor != null) 'readyToAssignMinor': readyToAssignMinor,
      'overspentEnvelopeCount': overspentEnvelopeCount,
      'netWorthMinor': netWorthMinor,
      'netWorthComplete': netWorthComplete,
      'uncategorizedCount': uncategorizedCount,
      'pendingProposalCount': pendingProposalCount,
      'dueRecurringCount': dueRecurringCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EntitySummaryViewImpl extends EntitySummaryView {
  _EntitySummaryViewImpl({
    required _im38gx2o.Entity entity,
    required int month,
    int? readyToAssignMinor,
    required int overspentEnvelopeCount,
    required int netWorthMinor,
    required bool netWorthComplete,
    required int uncategorizedCount,
    required int pendingProposalCount,
    required int dueRecurringCount,
  }) : super._(
         entity: entity,
         month: month,
         readyToAssignMinor: readyToAssignMinor,
         overspentEnvelopeCount: overspentEnvelopeCount,
         netWorthMinor: netWorthMinor,
         netWorthComplete: netWorthComplete,
         uncategorizedCount: uncategorizedCount,
         pendingProposalCount: pendingProposalCount,
         dueRecurringCount: dueRecurringCount,
       );

  /// Returns a shallow copy of this [EntitySummaryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EntitySummaryView copyWith({
    _im38gx2o.Entity? entity,
    int? month,
    Object? readyToAssignMinor = _Undefined,
    int? overspentEnvelopeCount,
    int? netWorthMinor,
    bool? netWorthComplete,
    int? uncategorizedCount,
    int? pendingProposalCount,
    int? dueRecurringCount,
  }) {
    return EntitySummaryView(
      entity: entity ?? this.entity.copyWith(),
      month: month ?? this.month,
      readyToAssignMinor: readyToAssignMinor is int?
          ? readyToAssignMinor
          : this.readyToAssignMinor,
      overspentEnvelopeCount:
          overspentEnvelopeCount ?? this.overspentEnvelopeCount,
      netWorthMinor: netWorthMinor ?? this.netWorthMinor,
      netWorthComplete: netWorthComplete ?? this.netWorthComplete,
      uncategorizedCount: uncategorizedCount ?? this.uncategorizedCount,
      pendingProposalCount: pendingProposalCount ?? this.pendingProposalCount,
      dueRecurringCount: dueRecurringCount ?? this.dueRecurringCount,
    );
  }
}
