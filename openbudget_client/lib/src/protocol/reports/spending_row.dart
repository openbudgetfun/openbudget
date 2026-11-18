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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// One group's spending and income over a month range, in base minor units.
abstract class SpendingRow
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SpendingRow._({
    this.groupId,
    required this.name,
    this.month,
    required this.outflowMinor,
    required this.inflowMinor,
    required this.transactionCount,
  });

  factory SpendingRow({
    _isc.UuidValue? groupId,
    required String name,
    int? month,
    required int outflowMinor,
    required int inflowMinor,
    required int transactionCount,
  }) = _SpendingRowImpl;

  factory SpendingRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return SpendingRow(
      groupId: jsonSerialization['groupId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['groupId']),
      name: jsonSerialization['name'] as String,
      month: jsonSerialization['month'] as int?,
      outflowMinor: jsonSerialization['outflowMinor'] as int,
      inflowMinor: jsonSerialization['inflowMinor'] as int,
      transactionCount: jsonSerialization['transactionCount'] as int,
    );
  }

  /// Envelope, category or payee id; null for the "no envelope" or "no
  /// payee" group.
  _isc.UuidValue? groupId;

  String name;

  /// yyyymm, or null when the row covers the whole range.
  int? month;

  /// Sum of negative lines, as a negative number.
  int outflowMinor;

  /// Sum of positive lines.
  int inflowMinor;

  int transactionCount;

  /// Returns a shallow copy of this [SpendingRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SpendingRow copyWith({
    _isc.UuidValue? groupId = const _isc.$UndefinedUuidValue(),
    String? name,
    int? month,
    int? outflowMinor,
    int? inflowMinor,
    int? transactionCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SpendingRow',
      if (groupId != null) 'groupId': groupId?.toJson(),
      'name': name,
      if (month != null) 'month': month,
      'outflowMinor': outflowMinor,
      'inflowMinor': inflowMinor,
      'transactionCount': transactionCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SpendingRow',
      if (groupId != null) 'groupId': groupId?.toJson(),
      'name': name,
      if (month != null) 'month': month,
      'outflowMinor': outflowMinor,
      'inflowMinor': inflowMinor,
      'transactionCount': transactionCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SpendingRowImpl extends SpendingRow {
  _SpendingRowImpl({
    _isc.UuidValue? groupId,
    required String name,
    int? month,
    required int outflowMinor,
    required int inflowMinor,
    required int transactionCount,
  }) : super._(
         groupId: groupId,
         name: name,
         month: month,
         outflowMinor: outflowMinor,
         inflowMinor: inflowMinor,
         transactionCount: transactionCount,
       );

  /// Returns a shallow copy of this [SpendingRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SpendingRow copyWith({
    _isc.UuidValue? groupId = const _isc.$UndefinedUuidValue(),
    String? name,
    Object? month = _Undefined,
    int? outflowMinor,
    int? inflowMinor,
    int? transactionCount,
  }) {
    return SpendingRow(
      groupId: groupId is _isc.UndefinedSentinel ? this.groupId : groupId,
      name: name ?? this.name,
      month: month is int? ? month : this.month,
      outflowMinor: outflowMinor ?? this.outflowMinor,
      inflowMinor: inflowMinor ?? this.inflowMinor,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }
}
