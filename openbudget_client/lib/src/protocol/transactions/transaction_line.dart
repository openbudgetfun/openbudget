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

/// One allocation of a transaction to an envelope, a ledger account and a
/// tax treatment. A transaction has one or more lines that sum exactly to it.
abstract class TransactionLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TransactionLine._({
    this.id,
    required this.transactionId,
    required this.amountMinor,
    required this.baseAmountMinor,
    this.envelopeId,
    this.ledgerAccountId,
    this.taxCategoryCode,
    this.businessUsePercent,
    this.salesTaxMinor,
    this.memo,
    int? sortOrder,
  }) : sortOrder = sortOrder ?? 0;

  factory TransactionLine({
    _isc.UuidValue? id,
    required _isc.UuidValue transactionId,
    required int amountMinor,
    required int baseAmountMinor,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  }) = _TransactionLineImpl;

  factory TransactionLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionLine(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      transactionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['transactionId'],
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      baseAmountMinor: jsonSerialization['baseAmountMinor'] as int,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      ledgerAccountId: jsonSerialization['ledgerAccountId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['ledgerAccountId'],
            ),
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      businessUsePercent: jsonSerialization['businessUsePercent'] as int?,
      salesTaxMinor: jsonSerialization['salesTaxMinor'] as int?,
      memo: jsonSerialization['memo'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue transactionId;

  /// Part of the transaction amount, account-currency minor units, signed.
  int amountMinor;

  /// Part of the base amount, base-currency minor units, signed.
  int baseAmountMinor;

  /// Null on an on-budget account means Ready to Assign (inflow) or
  /// uncategorised (outflow). Always null on off-budget accounts.
  _isc.UuidValue? envelopeId;

  /// Coding in ledger-mode books; null posts to the suspense account.
  _isc.UuidValue? ledgerAccountId;

  /// Tax category code; overrides the envelope's default when set.
  String? taxCategoryCode;

  /// Share of the line used for business, 0-100.
  int? businessUsePercent;

  /// Sales tax included in amountMinor, account-currency minor units.
  int? salesTaxMinor;

  String? memo;

  int sortOrder;

  /// Returns a shallow copy of this [TransactionLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TransactionLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? transactionId,
    int? amountMinor,
    int? baseAmountMinor,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? ledgerAccountId = const _isc.$UndefinedUuidValue(),
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionLine',
      if (id != null) 'id': id?.toJson(),
      'transactionId': transactionId.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionLine',
      if (id != null) 'id': id?.toJson(),
      'transactionId': transactionId.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionLineImpl extends TransactionLine {
  _TransactionLineImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue transactionId,
    required int amountMinor,
    required int baseAmountMinor,
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  }) : super._(
         id: id,
         transactionId: transactionId,
         amountMinor: amountMinor,
         baseAmountMinor: baseAmountMinor,
         envelopeId: envelopeId,
         ledgerAccountId: ledgerAccountId,
         taxCategoryCode: taxCategoryCode,
         businessUsePercent: businessUsePercent,
         salesTaxMinor: salesTaxMinor,
         memo: memo,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [TransactionLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TransactionLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? transactionId,
    int? amountMinor,
    int? baseAmountMinor,
    _isc.UuidValue? envelopeId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? ledgerAccountId = const _isc.$UndefinedUuidValue(),
    Object? taxCategoryCode = _Undefined,
    Object? businessUsePercent = _Undefined,
    Object? salesTaxMinor = _Undefined,
    Object? memo = _Undefined,
    int? sortOrder,
  }) {
    return TransactionLine(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      transactionId: transactionId ?? this.transactionId,
      amountMinor: amountMinor ?? this.amountMinor,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      envelopeId: envelopeId is _isc.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      ledgerAccountId: ledgerAccountId is _isc.UndefinedSentinel
          ? this.ledgerAccountId
          : ledgerAccountId,
      taxCategoryCode: taxCategoryCode is String?
          ? taxCategoryCode
          : this.taxCategoryCode,
      businessUsePercent: businessUsePercent is int?
          ? businessUsePercent
          : this.businessUsePercent,
      salesTaxMinor: salesTaxMinor is int? ? salesTaxMinor : this.salesTaxMinor,
      memo: memo is String? ? memo : this.memo,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
