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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A financial transaction within a budget, optionally assigned to an envelope.
abstract class Transaction implements _i1.SerializableModel {
  Transaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    required this.transactionDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Transaction({
    _i1.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _i1.UuidValue? envelopeId,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? accountId,
    required DateTime transactionDate,
    DateTime? createdAt,
  }) = _TransactionImpl;

  factory Transaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transaction(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['accountId']),
      transactionDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionDate'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _i1.UuidValue? envelopeId;

  _i1.UuidValue budgetId;

  /// The account this transaction belongs to (optional for backwards compat).
  _i1.UuidValue? accountId;

  DateTime transactionDate;

  DateTime createdAt;

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Transaction copyWith({
    _i1.UuidValue? id,
    String? description,
    int? amountCents,
    String? currencyCode,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? accountId,
    DateTime? transactionDate,
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
      'transactionDate': transactionDate.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionImpl extends Transaction {
  _TransactionImpl({
    _i1.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _i1.UuidValue? envelopeId,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? accountId,
    required DateTime transactionDate,
    DateTime? createdAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         transactionDate: transactionDate,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Transaction copyWith({
    Object? id = _Undefined,
    String? description,
    int? amountCents,
    String? currencyCode,
    Object? envelopeId = _Undefined,
    _i1.UuidValue? budgetId,
    Object? accountId = _Undefined,
    DateTime? transactionDate,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id is _i1.UuidValue? ? id : this.id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      envelopeId: envelopeId is _i1.UuidValue? ? envelopeId : this.envelopeId,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId is _i1.UuidValue? ? accountId : this.accountId,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
