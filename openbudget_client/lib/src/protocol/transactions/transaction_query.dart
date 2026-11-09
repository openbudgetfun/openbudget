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

/// Filters and keyset cursor for `transaction.list`. Rows come newest first,
/// ordered by (date desc, id desc).
abstract class TransactionQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue entityId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? payeeId,
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
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['accountId'],
            ),
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      fromDate: jsonSerialization['fromDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['fromDate']),
      toDate: jsonSerialization['toDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['toDate']),
      status: jsonSerialization['status'] == null
          ? null
          : _i45koviu.TransactionStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      uncategorizedOnly: jsonSerialization['uncategorizedOnly'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['uncategorizedOnly'],
            ),
      search: jsonSerialization['search'] as String?,
      limit: jsonSerialization['limit'] as int?,
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  _isc.UuidValue entityId;

  _isc.UuidValue? accountId;

  _isc.UuidValue? envelopeId;

  _isc.UuidValue? payeeId;

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
  @_isc.useResult
  TransactionQuery copyWith({
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    DateTime? fromDate = const _isc.$UndefinedDateTime(),
    DateTime? toDate = const _isc.$UndefinedDateTime(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionQueryImpl extends TransactionQuery {
  _TransactionQueryImpl({
    required _isc.UuidValue entityId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? payeeId,
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
  @_isc.useResult
  @override
  TransactionQuery copyWith({
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    DateTime? fromDate = const _isc.$UndefinedDateTime(),
    DateTime? toDate = const _isc.$UndefinedDateTime(),
    Object? status = _Undefined,
    bool? uncategorizedOnly,
    Object? search = _Undefined,
    int? limit,
    Object? cursor = _Undefined,
  }) {
    return TransactionQuery(
      entityId: entityId ?? this.entityId,
      accountId: accountId is _isc.UndefinedSentinel
          ? this.accountId
          : accountId,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      payeeId: payeeId is _isc.UndefinedSentinel ? this.payeeId : payeeId,
      fromDate: fromDate is _isc.UndefinedSentinel ? this.fromDate : fromDate,
      toDate: toDate is _isc.UndefinedSentinel ? this.toDate : toDate,
      status: status is _i45koviu.TransactionStatus? ? status : this.status,
      uncategorizedOnly: uncategorizedOnly ?? this.uncategorizedOnly,
      search: search is String? ? search : this.search,
      limit: limit ?? this.limit,
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
