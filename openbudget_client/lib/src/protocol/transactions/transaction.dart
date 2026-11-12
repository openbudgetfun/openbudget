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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../transactions/transaction_flag.dart' as _i2fej0yw;
import '../transactions/transaction_kind.dart' as _iwdxlbcu;
import '../transactions/transaction_status.dart' as _i45koviu;

/// Money moving into or out of one account on one calendar date.
///
/// The header is the movement; its lines allocate it to envelopes, ledger
/// accounts and tax treatments. Written only through TransactionWriter.
abstract class Transaction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Transaction._({
    this.id,
    required this.entityId,
    required this.accountId,
    required this.date,
    required this.amountMinor,
    required this.baseAmountMinor,
    String? fxRate,
    required this.fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    this.flag,
    this.payeeId,
    String? description,
    this.memo,
    this.externalId,
    this.recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fxRate = fxRate ?? '1',
       fxRateSource = fxRateSource ?? _ifz8weqz.FxRateSource.identity,
       kind = kind ?? _iwdxlbcu.TransactionKind.standard,
       status = status ?? _i45koviu.TransactionStatus.uncleared,
       description = description ?? '',
       revision = revision ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Transaction({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    required int baseAmountMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _isc.UuidValue? payeeId,
    String? description,
    String? memo,
    String? externalId,
    _isc.UuidValue? recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionImpl;

  factory Transaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transaction(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      amountMinor: jsonSerialization['amountMinor'] as int,
      baseAmountMinor: jsonSerialization['baseAmountMinor'] as int,
      fxRate: jsonSerialization['fxRate'] as String?,
      fxRateDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fxRateDate'],
      ),
      fxRateSource: jsonSerialization['fxRateSource'] == null
          ? null
          : _ifz8weqz.FxRateSource.fromJson(
              (jsonSerialization['fxRateSource'] as String),
            ),
      kind: jsonSerialization['kind'] == null
          ? null
          : _iwdxlbcu.TransactionKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
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
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      description: jsonSerialization['description'] as String?,
      memo: jsonSerialization['memo'] as String?,
      externalId: jsonSerialization['externalId'] as String?,
      recurringTransactionId:
          jsonSerialization['recurringTransactionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['recurringTransactionId'],
            ),
      revision: jsonSerialization['revision'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  /// Always the account's entity; never changes.
  _isc.UuidValue entityId;

  _isc.UuidValue accountId;

  /// Calendar date in the entity's time zone, at UTC midnight.
  DateTime date;

  /// Signed amount in account-currency minor units: positive in, negative out.
  int amountMinor;

  /// The same movement in the entity's base-currency minor units.
  int baseAmountMinor;

  /// Base currency per one unit of the account currency, exact decimal.
  String fxRate;

  /// Calendar date of the rate actually used.
  DateTime fxRateDate;

  _ifz8weqz.FxRateSource fxRateSource;

  _iwdxlbcu.TransactionKind kind;

  _i45koviu.TransactionStatus status;

  _i2fej0yw.TransactionFlag? flag;

  _isc.UuidValue? payeeId;

  /// Statement text or a short title.
  String description;

  String? memo;

  /// Provider id for imported rows (Plaid transaction_id, `csv:<sha256>`),
  /// unique per account, so imports are idempotent.
  String? externalId;

  _isc.UuidValue? recurringTransactionId;

  /// Increments whenever date, amount, account or lines change; ledger-mode
  /// books post one journal per revision.
  int revision;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Transaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    int? baseAmountMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    String? description,
    String? memo,
    String? externalId,
    _isc.UuidValue? recurringTransactionId = const _isc.$UndefinedUuidValue(),
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
      if (recurringTransactionId != null)
        'recurringTransactionId': recurringTransactionId?.toJson(),
      'revision': revision,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
      if (recurringTransactionId != null)
        'recurringTransactionId': recurringTransactionId?.toJson(),
      'revision': revision,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionImpl extends Transaction {
  _TransactionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    required int baseAmountMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _isc.UuidValue? payeeId,
    String? description,
    String? memo,
    String? externalId,
    _isc.UuidValue? recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         accountId: accountId,
         date: date,
         amountMinor: amountMinor,
         baseAmountMinor: baseAmountMinor,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
         kind: kind,
         status: status,
         flag: flag,
         payeeId: payeeId,
         description: description,
         memo: memo,
         externalId: externalId,
         recurringTransactionId: recurringTransactionId,
         revision: revision,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Transaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    int? baseAmountMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    Object? flag = _Undefined,
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    String? description,
    Object? memo = _Undefined,
    Object? externalId = _Undefined,
    _isc.UuidValue? recurringTransactionId = const _isc.$UndefinedUuidValue(),
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      amountMinor: amountMinor ?? this.amountMinor,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate ?? this.fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      flag: flag is _i2fej0yw.TransactionFlag? ? flag : this.flag,
      payeeId: payeeId is _isc.UndefinedSentinel ? this.payeeId : payeeId,
      description: description ?? this.description,
      memo: memo is String? ? memo : this.memo,
      externalId: externalId is String? ? externalId : this.externalId,
      recurringTransactionId: recurringTransactionId is _isc.UndefinedSentinel
          ? this.recurringTransactionId
          : recurringTransactionId,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
