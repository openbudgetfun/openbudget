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

/// One line of a TransactionInput. Base amounts are always computed on the
/// server.
abstract class TransactionLineInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TransactionLineInput._({
    required this.amountMinor,
    this.envelopeId,
    this.ledgerAccountId,
    this.taxCategoryCode,
    this.businessUsePercent,
    this.salesTaxMinor,
    this.memo,
  });

  factory TransactionLineInput({
    required int amountMinor,
    _is.UuidValue? envelopeId,
    _is.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
  }) = _TransactionLineInputImpl;

  factory TransactionLineInput.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TransactionLineInput(
      amountMinor: jsonSerialization['amountMinor'] as int,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      ledgerAccountId: jsonSerialization['ledgerAccountId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['ledgerAccountId'],
            ),
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      businessUsePercent: jsonSerialization['businessUsePercent'] as int?,
      salesTaxMinor: jsonSerialization['salesTaxMinor'] as int?,
      memo: jsonSerialization['memo'] as String?,
    );
  }

  /// Signed account minor units; the lines must sum to the transaction.
  int amountMinor;

  _is.UuidValue? envelopeId;

  _is.UuidValue? ledgerAccountId;

  String? taxCategoryCode;

  int? businessUsePercent;

  int? salesTaxMinor;

  String? memo;

  /// Returns a shallow copy of this [TransactionLineInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionLineInput copyWith({
    int? amountMinor,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionLineInput',
      'amountMinor': amountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionLineInput',
      'amountMinor': amountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionLineInputImpl extends TransactionLineInput {
  _TransactionLineInputImpl({
    required int amountMinor,
    _is.UuidValue? envelopeId,
    _is.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
  }) : super._(
         amountMinor: amountMinor,
         envelopeId: envelopeId,
         ledgerAccountId: ledgerAccountId,
         taxCategoryCode: taxCategoryCode,
         businessUsePercent: businessUsePercent,
         salesTaxMinor: salesTaxMinor,
         memo: memo,
       );

  /// Returns a shallow copy of this [TransactionLineInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionLineInput copyWith({
    int? amountMinor,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    Object? taxCategoryCode = _Undefined,
    Object? businessUsePercent = _Undefined,
    Object? salesTaxMinor = _Undefined,
    Object? memo = _Undefined,
  }) {
    return TransactionLineInput(
      amountMinor: amountMinor ?? this.amountMinor,
      envelopeId: envelopeId is _is.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      ledgerAccountId: ledgerAccountId is _is.UndefinedSentinel
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
    );
  }
}
