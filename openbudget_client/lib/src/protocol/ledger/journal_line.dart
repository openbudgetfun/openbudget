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

/// One line of a [Journal]: a one-sided amount on one ledger account.
///
/// Every line carries the transaction-currency amount and the functional
/// amount (the budget's currencyCode) with the exact exchange rate that
/// produced it. `functionalDebitMinor`/`functionalCreditMinor` follow the
/// same direction as the transaction side; exactly one of each pair is
/// positive. A zero functional amount is legitimate only where the stated
/// rate rounds a small amount to zero.
abstract class JournalLine
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  JournalLine._({
    this.id,
    required this.journalId,
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

  factory JournalLine({
    _isc.UuidValue? id,
    required _isc.UuidValue journalId,
    required _isc.UuidValue ledgerAccountId,
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
  }) = _JournalLineImpl;

  factory JournalLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalLine(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      journalId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['journalId'],
      ),
      ledgerAccountId: _isc.UuidValueJsonExtension.fromJson(
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
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['rateDate']),
      rateSource: jsonSerialization['rateSource'] as String?,
      taxCode: jsonSerialization['taxCode'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue journalId;

  _isc.UuidValue ledgerAccountId;

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

  /// Returns a shallow copy of this [JournalLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  JournalLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? journalId,
    _isc.UuidValue? ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate = const _isc.$UndefinedDateTime(),
    String? rateSource,
    String? taxCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalLine',
      if (id != null) 'id': id?.toJson(),
      'journalId': journalId.toJson(),
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
      '__className__': 'JournalLine',
      if (id != null) 'id': id?.toJson(),
      'journalId': journalId.toJson(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalLineImpl extends JournalLine {
  _JournalLineImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue journalId,
    required _isc.UuidValue ledgerAccountId,
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
         id: id,
         journalId: journalId,
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

  /// Returns a shallow copy of this [JournalLine]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  JournalLine copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? journalId,
    _isc.UuidValue? ledgerAccountId,
    Object? description = _Undefined,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? functionalDebitMinor,
    int? functionalCreditMinor,
    String? exchangeRate,
    DateTime? rateDate = const _isc.$UndefinedDateTime(),
    Object? rateSource = _Undefined,
    Object? taxCode = _Undefined,
  }) {
    return JournalLine(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      journalId: journalId ?? this.journalId,
      ledgerAccountId: ledgerAccountId ?? this.ledgerAccountId,
      description: description is String? ? description : this.description,
      debitMinor: debitMinor ?? this.debitMinor,
      creditMinor: creditMinor ?? this.creditMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      functionalDebitMinor: functionalDebitMinor ?? this.functionalDebitMinor,
      functionalCreditMinor:
          functionalCreditMinor ?? this.functionalCreditMinor,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      rateDate: rateDate is _isc.UndefinedSentinel ? this.rateDate : rateDate,
      rateSource: rateSource is String? ? rateSource : this.rateSource,
      taxCode: taxCode is String? ? taxCode : this.taxCode,
    );
  }
}
