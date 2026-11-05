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

/// One proposed journal line as sent to `LedgerEndpoint.saveDraftJournal`.
abstract class JournalLineInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  JournalLineInput._({
    required this.ledgerAccountId,
    this.description,
    int? debitMinor,
    int? creditMinor,
    required this.currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    this.rateDate,
    this.rateSource,
    this.taxCode,
  }) : debitMinor = debitMinor ?? 0,
       creditMinor = creditMinor ?? 0,
       functionalDebitMinor = functionalDebitMinor ?? 0,
       functionalCreditMinor = functionalCreditMinor ?? 0,
       exchangeRate = exchangeRate ?? '1';

  factory JournalLineInput({
    required _is.UuidValue ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate,
    String? rateSource,
    String? taxCode,
  }) = _JournalLineInputImpl;

  factory JournalLineInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalLineInput(
      ledgerAccountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ledgerAccountId'],
      ),
      description: jsonSerialization['description'] as String?,
      debitMinor: jsonSerialization['debitMinor'] as int?,
      creditMinor: jsonSerialization['creditMinor'] as int?,
      currencyCode: jsonSerialization['currencyCode'] as String,
      functionalDebitMinor: jsonSerialization['functionalDebitMinor'] as int?,
      functionalCreditMinor: jsonSerialization['functionalCreditMinor'] as int?,
      exchangeRate: jsonSerialization['exchangeRate'] as String?,
      rateDate: jsonSerialization['rateDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['rateDate']),
      rateSource: jsonSerialization['rateSource'] as String?,
      taxCode: jsonSerialization['taxCode'] as String?,
    );
  }

  _is.UuidValue ledgerAccountId;

  String? description;

  /// Debit in transaction-currency minor units, or 0.
  int debitMinor;

  /// Credit in transaction-currency minor units, or 0.
  int creditMinor;

  /// ISO 4217 code of the transaction currency.
  String currencyCode;

  /// Debit in functional-currency minor units, or 0.
  int functionalDebitMinor;

  /// Credit in functional-currency minor units, or 0.
  int functionalCreditMinor;

  /// Functional per 1 transaction currency, exact decimal string such as
  /// `1.234567`. Never a double.
  String exchangeRate;

  /// The calendar date the rate was struck on.
  DateTime? rateDate;

  /// Where the rate came from, such as `manual` or a provider name.
  String? rateSource;

  /// Optional sales-tax code applied to this line.
  String? taxCode;

  /// Returns a shallow copy of this [JournalLineInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  JournalLineInput copyWith({
    _is.UuidValue? ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate = const _is.$UndefinedDateTime(),
    String? rateSource,
    String? taxCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalLineInput',
      'ledgerAccountId': ledgerAccountId.toJson(),
      if (description != null) 'description': description,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'currencyCode': currencyCode,
      'functionalDebitMinor': functionalDebitMinor,
      'functionalCreditMinor': functionalCreditMinor,
      'exchangeRate': exchangeRate,
      if (rateDate != null) 'rateDate': rateDate?.toJson(),
      if (rateSource != null) 'rateSource': rateSource,
      if (taxCode != null) 'taxCode': taxCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JournalLineInput',
      'ledgerAccountId': ledgerAccountId.toJson(),
      if (description != null) 'description': description,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'currencyCode': currencyCode,
      'functionalDebitMinor': functionalDebitMinor,
      'functionalCreditMinor': functionalCreditMinor,
      'exchangeRate': exchangeRate,
      if (rateDate != null) 'rateDate': rateDate?.toJson(),
      if (rateSource != null) 'rateSource': rateSource,
      if (taxCode != null) 'taxCode': taxCode,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalLineInputImpl extends JournalLineInput {
  _JournalLineInputImpl({
    required _is.UuidValue ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate,
    String? rateSource,
    String? taxCode,
  }) : super._(
         ledgerAccountId: ledgerAccountId,
         description: description,
         debitMinor: debitMinor,
         creditMinor: creditMinor,
         currencyCode: currencyCode,
         functionalDebitMinor: functionalDebitMinor,
         functionalCreditMinor: functionalCreditMinor,
         exchangeRate: exchangeRate,
         rateDate: rateDate,
         rateSource: rateSource,
         taxCode: taxCode,
       );

  /// Returns a shallow copy of this [JournalLineInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  JournalLineInput copyWith({
    _is.UuidValue? ledgerAccountId,
    Object? description = _Undefined,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate = const _is.$UndefinedDateTime(),
    Object? rateSource = _Undefined,
    Object? taxCode = _Undefined,
  }) {
    return JournalLineInput(
      ledgerAccountId: ledgerAccountId ?? this.ledgerAccountId,
      description: description is String? ? description : this.description,
      debitMinor: debitMinor ?? this.debitMinor,
      creditMinor: creditMinor ?? this.creditMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      functionalDebitMinor: functionalDebitMinor ?? this.functionalDebitMinor,
      functionalCreditMinor:
          functionalCreditMinor ?? this.functionalCreditMinor,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      rateDate: rateDate is _is.UndefinedSentinel ? this.rateDate : rateDate,
      rateSource: rateSource is String? ? rateSource : this.rateSource,
      taxCode: taxCode is String? ? taxCode : this.taxCode,
    );
  }
}
