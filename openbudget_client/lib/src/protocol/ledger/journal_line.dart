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

/// One line of a journal: a one-sided amount on one ledger account.
///
/// Each line carries the transaction-currency amount and the base amount
/// with the exact rate that produced it. Exactly one of debitMinor and
/// creditMinor is positive, and the base pair follows the same side.
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
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required this.fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    this.taxCode,
  }) : debitMinor = debitMinor ?? 0,
       creditMinor = creditMinor ?? 0,
       baseDebitMinor = baseDebitMinor ?? 0,
       baseCreditMinor = baseCreditMinor ?? 0,
       fxRate = fxRate ?? '1',
       fxRateSource = fxRateSource ?? _ifz8weqz.FxRateSource.identity;

  factory JournalLine({
    _isc.UuidValue? id,
    required _isc.UuidValue journalId,
    required _isc.UuidValue ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
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
      baseDebitMinor: jsonSerialization['baseDebitMinor'] as int?,
      baseCreditMinor: jsonSerialization['baseCreditMinor'] as int?,
      fxRate: jsonSerialization['fxRate'] as String?,
      fxRateDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fxRateDate'],
      ),
      fxRateSource: jsonSerialization['fxRateSource'] == null
          ? null
          : _ifz8weqz.FxRateSource.fromJson(
              (jsonSerialization['fxRateSource'] as String),
            ),
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

  /// Debit in base-currency minor units, or 0.
  int baseDebitMinor;

  /// Credit in base-currency minor units, or 0.
  int baseCreditMinor;

  /// Base currency per one transaction-currency unit, exact decimal.
  String fxRate;

  /// Calendar date of the rate.
  DateTime fxRateDate;

  _ifz8weqz.FxRateSource fxRateSource;

  /// Sales-tax code applied to this line.
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
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
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
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
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
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
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
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  }) : super._(
         id: id,
         journalId: journalId,
         ledgerAccountId: ledgerAccountId,
         description: description,
         debitMinor: debitMinor,
         creditMinor: creditMinor,
         currencyCode: currencyCode,
         baseDebitMinor: baseDebitMinor,
         baseCreditMinor: baseCreditMinor,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
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
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
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
      baseDebitMinor: baseDebitMinor ?? this.baseDebitMinor,
      baseCreditMinor: baseCreditMinor ?? this.baseCreditMinor,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate ?? this.fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      taxCode: taxCode is String? ? taxCode : this.taxCode,
    );
  }
}
