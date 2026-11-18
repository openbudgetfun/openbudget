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

/// One proposed journal line, as sent to `LedgerEndpoint.saveDraftJournal`.
abstract class JournalLineInput
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  JournalLineInput._({
    required this.ledgerAccountId,
    this.description,
    int? debitMinor,
    int? creditMinor,
    required this.currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    this.fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    this.taxCode,
  }) : debitMinor = debitMinor ?? 0,
       creditMinor = creditMinor ?? 0,
       baseDebitMinor = baseDebitMinor ?? 0,
       baseCreditMinor = baseCreditMinor ?? 0,
       fxRate = fxRate ?? '1',
       fxRateSource = fxRateSource ?? _ifz8weqz.FxRateSource.identity;

  factory JournalLineInput({
    required _isc.UuidValue ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  }) = _JournalLineInputImpl;

  factory JournalLineInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalLineInput(
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
      fxRateDate: jsonSerialization['fxRateDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
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

  /// Calendar date of the rate; the journal date when null.
  DateTime? fxRateDate;

  _ifz8weqz.FxRateSource fxRateSource;

  String? taxCode;

  /// Returns a shallow copy of this [JournalLineInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  JournalLineInput copyWith({
    _isc.UuidValue? ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate = const _isc.$UndefinedDateTime(),
    _ifz8weqz.FxRateSource? fxRateSource,
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
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      if (fxRateDate != null) 'fxRateDate': fxRateDate?.toJson(),
      'fxRateSource': fxRateSource.toJson(),
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
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      if (fxRateDate != null) 'fxRateDate': fxRateDate?.toJson(),
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

class _JournalLineInputImpl extends JournalLineInput {
  _JournalLineInputImpl({
    required _isc.UuidValue ledgerAccountId,
    String? description,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  }) : super._(
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

  /// Returns a shallow copy of this [JournalLineInput]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  JournalLineInput copyWith({
    _isc.UuidValue? ledgerAccountId,
    Object? description = _Undefined,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate = const _isc.$UndefinedDateTime(),
    _ifz8weqz.FxRateSource? fxRateSource,
    Object? taxCode = _Undefined,
  }) {
    return JournalLineInput(
      ledgerAccountId: ledgerAccountId ?? this.ledgerAccountId,
      description: description is String? ? description : this.description,
      debitMinor: debitMinor ?? this.debitMinor,
      creditMinor: creditMinor ?? this.creditMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      baseDebitMinor: baseDebitMinor ?? this.baseDebitMinor,
      baseCreditMinor: baseCreditMinor ?? this.baseCreditMinor,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate is _isc.UndefinedSentinel
          ? this.fxRateDate
          : fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      taxCode: taxCode is String? ? taxCode : this.taxCode,
    );
  }
}
