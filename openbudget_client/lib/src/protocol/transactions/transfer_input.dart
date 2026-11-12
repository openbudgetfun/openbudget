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

import '../transactions/transaction_status.dart' as _i45koviu;

/// A move between two accounts the user owns, possibly in two currencies
/// and two entities.
abstract class TransferInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TransferInput._({
    required this.fromAccountId,
    required this.toAccountId,
    required this.date,
    required this.fromAmountMinor,
    this.toAmountMinor,
    bool? useMarketRate,
    this.envelopeId,
    this.memo,
    _i45koviu.TransactionStatus? status,
  }) : useMarketRate = useMarketRate ?? false,
       status = status ?? _i45koviu.TransactionStatus.uncleared;

  factory TransferInput({
    required _isc.UuidValue fromAccountId,
    required _isc.UuidValue toAccountId,
    required DateTime date,
    required int fromAmountMinor,
    int? toAmountMinor,
    bool? useMarketRate,
    _isc.UuidValue? envelopeId,
    String? memo,
    _i45koviu.TransactionStatus? status,
  }) = _TransferInputImpl;

  factory TransferInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransferInput(
      fromAccountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['fromAccountId'],
      ),
      toAccountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['toAccountId'],
      ),
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      fromAmountMinor: jsonSerialization['fromAmountMinor'] as int,
      toAmountMinor: jsonSerialization['toAmountMinor'] as int?,
      useMarketRate: jsonSerialization['useMarketRate'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['useMarketRate']),
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      memo: jsonSerialization['memo'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i45koviu.TransactionStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
    );
  }

  _isc.UuidValue fromAccountId;

  _isc.UuidValue toAccountId;

  /// Calendar date of both legs.
  DateTime date;

  /// What left, positive, in the from-account's minor units.
  int fromAmountMinor;

  /// What arrived, positive, in the to-account's minor units. Required
  /// when the currencies differ unless useMarketRate is true; must be null
  /// or equal to fromAmountMinor when they match.
  int? toAmountMinor;

  /// Compute toAmountMinor at the market rate when it is null.
  bool useMarketRate;

  /// Envelope of the outflow leg. Allowed only when the money leaves the
  /// entity's envelope plan: the from-account is on budget and the
  /// to-account is off budget or in another entity.
  _isc.UuidValue? envelopeId;

  String? memo;

  _i45koviu.TransactionStatus status;

  /// Returns a shallow copy of this [TransferInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransferInput copyWith({
    _isc.UuidValue? fromAccountId,
    _isc.UuidValue? toAccountId,
    DateTime? date,
    int? fromAmountMinor,
    int? toAmountMinor,
    bool? useMarketRate,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    String? memo,
    _i45koviu.TransactionStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransferInput',
      'fromAccountId': fromAccountId.toJson(),
      'toAccountId': toAccountId.toJson(),
      'date': date.toJson(),
      'fromAmountMinor': fromAmountMinor,
      if (toAmountMinor != null) 'toAmountMinor': toAmountMinor,
      'useMarketRate': useMarketRate,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (memo != null) 'memo': memo,
      'status': status.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransferInput',
      'fromAccountId': fromAccountId.toJson(),
      'toAccountId': toAccountId.toJson(),
      'date': date.toJson(),
      'fromAmountMinor': fromAmountMinor,
      if (toAmountMinor != null) 'toAmountMinor': toAmountMinor,
      'useMarketRate': useMarketRate,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (memo != null) 'memo': memo,
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransferInputImpl extends TransferInput {
  _TransferInputImpl({
    required _isc.UuidValue fromAccountId,
    required _isc.UuidValue toAccountId,
    required DateTime date,
    required int fromAmountMinor,
    int? toAmountMinor,
    bool? useMarketRate,
    _isc.UuidValue? envelopeId,
    String? memo,
    _i45koviu.TransactionStatus? status,
  }) : super._(
         fromAccountId: fromAccountId,
         toAccountId: toAccountId,
         date: date,
         fromAmountMinor: fromAmountMinor,
         toAmountMinor: toAmountMinor,
         useMarketRate: useMarketRate,
         envelopeId: envelopeId,
         memo: memo,
         status: status,
       );

  /// Returns a shallow copy of this [TransferInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TransferInput copyWith({
    _isc.UuidValue? fromAccountId,
    _isc.UuidValue? toAccountId,
    DateTime? date,
    int? fromAmountMinor,
    Object? toAmountMinor = _Undefined,
    bool? useMarketRate,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    Object? memo = _Undefined,
    _i45koviu.TransactionStatus? status,
  }) {
    return TransferInput(
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      fromAmountMinor: fromAmountMinor ?? this.fromAmountMinor,
      toAmountMinor: toAmountMinor is int? ? toAmountMinor : this.toAmountMinor,
      useMarketRate: useMarketRate ?? this.useMarketRate,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      memo: memo is String? ? memo : this.memo,
      status: status ?? this.status,
    );
  }
}
