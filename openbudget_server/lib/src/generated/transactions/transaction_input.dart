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

import '../transactions/transaction_flag.dart' as _i2fej0yw;
import '../transactions/transaction_line_input.dart' as _ietm4bb9;
import '../transactions/transaction_status.dart' as _i45koviu;

/// Everything needed to create or replace a transaction. One shape for the
/// app, imports, recurring posting and the assistant.
abstract class TransactionInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TransactionInput._({
    required this.accountId,
    required this.date,
    required this.amountMinor,
    this.fxRate,
    this.payeeId,
    this.payeeName,
    String? description,
    this.memo,
    _i45koviu.TransactionStatus? status,
    this.flag,
    required this.lines,
  }) : description = description ?? '',
       status = status ?? _i45koviu.TransactionStatus.uncleared;

  factory TransactionInput({
    required _is.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    String? fxRate,
    _is.UuidValue? payeeId,
    String? payeeName,
    String? description,
    String? memo,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    required List<_ietm4bb9.TransactionLineInput> lines,
  }) = _TransactionInputImpl;

  factory TransactionInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionInput(
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      amountMinor: jsonSerialization['amountMinor'] as int,
      fxRate: jsonSerialization['fxRate'] as String?,
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      payeeName: jsonSerialization['payeeName'] as String?,
      description: jsonSerialization['description'] as String?,
      memo: jsonSerialization['memo'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i45koviu.TransactionStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      flag: jsonSerialization['flag'] == null
          ? null
          : _i2fej0yw.TransactionFlag.fromJson(
              (jsonSerialization['flag'] as String),
            ),
      lines: _is0sbm8r.Protocol()
          .deserialize<List<_ietm4bb9.TransactionLineInput>>(
            jsonSerialization['lines'],
          ),
    );
  }

  _is.UuidValue accountId;

  /// Calendar date.
  DateTime date;

  /// Signed amount in account minor units.
  int amountMinor;

  /// A manual rate (base per one account-currency unit, exact decimal).
  /// Null uses the market rate for the date.
  String? fxRate;

  _is.UuidValue? payeeId;

  /// Creates or reuses a payee by exact name when payeeId is null.
  String? payeeName;

  String description;

  String? memo;

  _i45koviu.TransactionStatus status;

  _i2fej0yw.TransactionFlag? flag;

  /// Empty means one line for the whole amount with no envelope; the
  /// payee's rule may then fill the envelope.
  List<_ietm4bb9.TransactionLineInput> lines;

  /// Returns a shallow copy of this [TransactionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionInput copyWith({
    _is.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    String? fxRate,
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    String? payeeName,
    String? description,
    String? memo,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    List<_ietm4bb9.TransactionLineInput>? lines,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionInput',
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      if (fxRate != null) 'fxRate': fxRate,
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (payeeName != null) 'payeeName': payeeName,
      'description': description,
      if (memo != null) 'memo': memo,
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      'lines': lines.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionInput',
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      if (fxRate != null) 'fxRate': fxRate,
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (payeeName != null) 'payeeName': payeeName,
      'description': description,
      if (memo != null) 'memo': memo,
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      'lines': lines.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionInputImpl extends TransactionInput {
  _TransactionInputImpl({
    required _is.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    String? fxRate,
    _is.UuidValue? payeeId,
    String? payeeName,
    String? description,
    String? memo,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    required List<_ietm4bb9.TransactionLineInput> lines,
  }) : super._(
         accountId: accountId,
         date: date,
         amountMinor: amountMinor,
         fxRate: fxRate,
         payeeId: payeeId,
         payeeName: payeeName,
         description: description,
         memo: memo,
         status: status,
         flag: flag,
         lines: lines,
       );

  /// Returns a shallow copy of this [TransactionInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionInput copyWith({
    _is.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    Object? fxRate = _Undefined,
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    Object? payeeName = _Undefined,
    String? description,
    Object? memo = _Undefined,
    _i45koviu.TransactionStatus? status,
    Object? flag = _Undefined,
    List<_ietm4bb9.TransactionLineInput>? lines,
  }) {
    return TransactionInput(
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      amountMinor: amountMinor ?? this.amountMinor,
      fxRate: fxRate is String? ? fxRate : this.fxRate,
      payeeId: payeeId is _is.UndefinedSentinel ? this.payeeId : payeeId,
      payeeName: payeeName is String? ? payeeName : this.payeeName,
      description: description ?? this.description,
      memo: memo is String? ? memo : this.memo,
      status: status ?? this.status,
      flag: flag is _i2fej0yw.TransactionFlag? ? flag : this.flag,
      lines: lines ?? this.lines.map((e0) => e0.copyWith()).toList(),
    );
  }
}
