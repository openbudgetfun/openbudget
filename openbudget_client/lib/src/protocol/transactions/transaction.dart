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

/// A financial transaction within a budget, optionally assigned to an envelope.
abstract class Transaction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Transaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    this.payeeId,
    required this.transactionDate,
    this.transferPairId,
    this.parentTransactionId,
    this.memo,
    bool? cleared,
    bool? reconciled,
    this.flagColor,
    DateTime? createdAt,
  }) : cleared = cleared ?? false,
       reconciled = reconciled ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Transaction({
    _isc.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _isc.UuidValue? envelopeId,
    required _isc.UuidValue budgetId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    required DateTime transactionDate,
    _isc.UuidValue? transferPairId,
    _isc.UuidValue? parentTransactionId,
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  }) = _TransactionImpl;

  factory Transaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transaction(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['accountId'],
            ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      transactionDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionDate'],
      ),
      transferPairId: jsonSerialization['transferPairId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['transferPairId'],
            ),
      parentTransactionId: jsonSerialization['parentTransactionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['parentTransactionId'],
            ),
      memo: jsonSerialization['memo'] as String?,
      cleared: jsonSerialization['cleared'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['cleared']),
      reconciled: jsonSerialization['reconciled'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['reconciled']),
      flagColor: jsonSerialization['flagColor'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _isc.UuidValue? envelopeId;

  _isc.UuidValue budgetId;

  /// The account this transaction belongs to (optional for backwards compat).
  _isc.UuidValue? accountId;

  /// The payee associated with this transaction.
  _isc.UuidValue? payeeId;

  DateTime transactionDate;

  /// If this transaction is part of a transfer, this links to the paired transaction.
  _isc.UuidValue? transferPairId;

  /// If this is a split sub-transaction, links to the parent transaction.
  _isc.UuidValue? parentTransactionId;

  /// Optional user memo or note for additional context.
  String? memo;

  /// Whether this transaction has been cleared by the user.
  bool cleared;

  /// Whether this transaction has been reconciled.
  bool reconciled;

  /// Optional flag color for marking transactions (red, orange, yellow, green, blue, purple).
  String? flagColor;

  DateTime createdAt;

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Transaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    DateTime? transactionDate,
    _isc.UuidValue? transferPairId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? parentTransactionId = const _isc.$UndefinedUuidValue(),
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'transactionDate': transactionDate.toJson(),
      if (transferPairId != null) 'transferPairId': transferPairId?.toJson(),
      if (parentTransactionId != null)
        'parentTransactionId': parentTransactionId?.toJson(),
      if (memo != null) 'memo': memo,
      'cleared': cleared,
      'reconciled': reconciled,
      if (flagColor != null) 'flagColor': flagColor,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'transactionDate': transactionDate.toJson(),
      if (transferPairId != null) 'transferPairId': transferPairId?.toJson(),
      if (parentTransactionId != null)
        'parentTransactionId': parentTransactionId?.toJson(),
      if (memo != null) 'memo': memo,
      'cleared': cleared,
      'reconciled': reconciled,
      if (flagColor != null) 'flagColor': flagColor,
      'createdAt': createdAt.toJson(),
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
    required String description,
    required int amountCents,
    required String currencyCode,
    _isc.UuidValue? envelopeId,
    required _isc.UuidValue budgetId,
    _isc.UuidValue? accountId,
    _isc.UuidValue? payeeId,
    required DateTime transactionDate,
    _isc.UuidValue? transferPairId,
    _isc.UuidValue? parentTransactionId,
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         payeeId: payeeId,
         transactionDate: transactionDate,
         transferPairId: transferPairId,
         parentTransactionId: parentTransactionId,
         memo: memo,
         cleared: cleared,
         reconciled: reconciled,
         flagColor: flagColor,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Transaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    _isc.UuidValue? accountId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? payeeId = const _isc.$UndefinedUuidValue(),
    DateTime? transactionDate,
    _isc.UuidValue? transferPairId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? parentTransactionId = const _isc.$UndefinedUuidValue(),
    Object? memo = _Undefined,
    bool? cleared,
    bool? reconciled,
    Object? flagColor = _Undefined,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId is _isc.UndefinedSentinel
          ? this.accountId
          : accountId,
      payeeId: payeeId is _isc.UndefinedSentinel ? this.payeeId : payeeId,
      transactionDate: transactionDate ?? this.transactionDate,
      transferPairId: transferPairId is _isc.UndefinedSentinel
          ? this.transferPairId
          : transferPairId,
      parentTransactionId: parentTransactionId is _isc.UndefinedSentinel
          ? this.parentTransactionId
          : parentTransactionId,
      memo: memo is String? ? memo : this.memo,
      cleared: cleared ?? this.cleared,
      reconciled: reconciled ?? this.reconciled,
      flagColor: flagColor is String? ? flagColor : this.flagColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
