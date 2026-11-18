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

import '../transactions/transaction_status.dart' as _i45koviu;

/// Filters and keyset cursor for `transaction.list`. Rows come newest first,
/// ordered by (date desc, id desc).
abstract class TransactionQuery
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TransactionQuery._({
    required this.entityId,
    this.accountId,
    this.envelopeId,
    this.payeeId,
    this.fromDate,
    this.toDate,
    this.status,
    bool? uncategorizedOnly,
    this.search,
    int? limit,
    this.cursor,
  }) : uncategorizedOnly = uncategorizedOnly ?? false,
       limit = limit ?? 50;

  factory TransactionQuery({
    required _is.UuidValue entityId,
    _is.UuidValue? accountId,
    _is.UuidValue? envelopeId,
    _is.UuidValue? payeeId,
    DateTime? fromDate,
    DateTime? toDate,
    _i45koviu.TransactionStatus? status,
    bool? uncategorizedOnly,
    String? search,
    int? limit,
    String? cursor,
  }) = _TransactionQueryImpl;

  factory TransactionQuery.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionQuery(
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['accountId']),
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      fromDate: jsonSerialization['fromDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['fromDate']),
      toDate: jsonSerialization['toDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['toDate']),
      status: jsonSerialization['status'] == null
          ? null
          : _i45koviu.TransactionStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      uncategorizedOnly: jsonSerialization['uncategorizedOnly'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['uncategorizedOnly'],
            ),
      search: jsonSerialization['search'] as String?,
      limit: jsonSerialization['limit'] as int?,
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  _is.UuidValue entityId;

  _is.UuidValue? accountId;

  _is.UuidValue? envelopeId;

  _is.UuidValue? payeeId;

  /// Inclusive calendar dates.
  DateTime? fromDate;

  DateTime? toDate;

  _i45koviu.TransactionStatus? status;

  /// Only transactions with an uncategorised outflow line on budget.
  bool uncategorizedOnly;

  /// Case-insensitive match on description, memo and payee name.
  String? search;

  /// 1-200.
  int limit;

  /// The nextCursor of the previous page.
  String? cursor;

  /// Returns a shallow copy of this [TransactionQuery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionQuery copyWith({
    _is.UuidValue? entityId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    DateTime? fromDate = const _is.$UndefinedDateTime(),
    DateTime? toDate = const _is.$UndefinedDateTime(),
    _i45koviu.TransactionStatus? status,
    bool? uncategorizedOnly,
    String? search,
    int? limit,
    String? cursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionQuery',
      'entityId': entityId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (fromDate != null) 'fromDate': fromDate?.toJson(),
      if (toDate != null) 'toDate': toDate?.toJson(),
      if (status != null) 'status': status?.toJson(),
      'uncategorizedOnly': uncategorizedOnly,
      if (search != null) 'search': search,
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionQuery',
      'entityId': entityId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      if (fromDate != null) 'fromDate': fromDate?.toJson(),
      if (toDate != null) 'toDate': toDate?.toJson(),
      if (status != null) 'status': status?.toJson(),
      'uncategorizedOnly': uncategorizedOnly,
      if (search != null) 'search': search,
      'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionQueryImpl extends TransactionQuery {
  _TransactionQueryImpl({
    required _is.UuidValue entityId,
    _is.UuidValue? accountId,
    _is.UuidValue? envelopeId,
    _is.UuidValue? payeeId,
    DateTime? fromDate,
    DateTime? toDate,
    _i45koviu.TransactionStatus? status,
    bool? uncategorizedOnly,
    String? search,
    int? limit,
    String? cursor,
  }) : super._(
         entityId: entityId,
         accountId: accountId,
         envelopeId: envelopeId,
         payeeId: payeeId,
         fromDate: fromDate,
         toDate: toDate,
         status: status,
         uncategorizedOnly: uncategorizedOnly,
         search: search,
         limit: limit,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [TransactionQuery]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionQuery copyWith({
    _is.UuidValue? entityId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    DateTime? fromDate = const _is.$UndefinedDateTime(),
    DateTime? toDate = const _is.$UndefinedDateTime(),
    Object? status = _Undefined,
    bool? uncategorizedOnly,
    Object? search = _Undefined,
    int? limit,
    Object? cursor = _Undefined,
  }) {
    return TransactionQuery(
      entityId: entityId ?? this.entityId,
      accountId: accountId is _is.UndefinedSentinel
          ? this.accountId
          : accountId,
      envelopeId: envelopeId is _is.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      payeeId: payeeId is _is.UndefinedSentinel ? this.payeeId : payeeId,
      fromDate: fromDate is _is.UndefinedSentinel ? this.fromDate : fromDate,
      toDate: toDate is _is.UndefinedSentinel ? this.toDate : toDate,
      status: status is _i45koviu.TransactionStatus? ? status : this.status,
      uncategorizedOnly: uncategorizedOnly ?? this.uncategorizedOnly,
      search: search is String? ? search : this.search,
      limit: limit ?? this.limit,
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
