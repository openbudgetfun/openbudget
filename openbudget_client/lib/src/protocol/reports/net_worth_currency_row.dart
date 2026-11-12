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

/// Accounts held in one currency, in that currency and converted.
abstract class NetWorthCurrencyRow
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  NetWorthCurrencyRow._({
    required this.currencyCode,
    required this.nativeMinor,
    this.convertedMinor,
    this.fxRate,
    this.fxRateDate,
    this.fxRateSource,
    required this.isStale,
    required this.accountCount,
  });

  factory NetWorthCurrencyRow({
    required String currencyCode,
    required int nativeMinor,
    int? convertedMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    required bool isStale,
    required int accountCount,
  }) = _NetWorthCurrencyRowImpl;

  factory NetWorthCurrencyRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthCurrencyRow(
      currencyCode: jsonSerialization['currencyCode'] as String,
      nativeMinor: jsonSerialization['nativeMinor'] as int,
      convertedMinor: jsonSerialization['convertedMinor'] as int?,
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
      isStale: _isc.BoolJsonExtension.fromJson(jsonSerialization['isStale']),
      accountCount: jsonSerialization['accountCount'] as int,
    );
  }

  /// ISO 4217 code the accounts are held in.
  String currencyCode;

  /// Sum of balances in this currency's minor units.
  int nativeMinor;

  /// Sum of the converted accounts in the reporting currency; null when
  /// no rate was available.
  int? convertedMinor;

  /// Reporting currency per one unit of this currency, exact decimal.
  String? fxRate;

  DateTime? fxRateDate;

  _ifz8weqz.FxRateSource? fxRateSource;

  bool isStale;

  int accountCount;

  /// Returns a shallow copy of this [NetWorthCurrencyRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NetWorthCurrencyRow copyWith({
    String? currencyCode,
    int? nativeMinor,
    int? convertedMinor,
    String? fxRate,
    DateTime? fxRateDate = const _isc.$UndefinedDateTime(),
    _ifz8weqz.FxRateSource? fxRateSource,
    bool? isStale,
    int? accountCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthCurrencyRow',
      'currencyCode': currencyCode,
      'nativeMinor': nativeMinor,
      if (convertedMinor != null) 'convertedMinor': convertedMinor,
      if (fxRate != null) 'fxRate': fxRate,
      if (fxRateDate != null) 'fxRateDate': fxRateDate?.toJson(),
      if (fxRateSource != null) 'fxRateSource': fxRateSource?.toJson(),
      'isStale': isStale,
      'accountCount': accountCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthCurrencyRow',
      'currencyCode': currencyCode,
      'nativeMinor': nativeMinor,
      if (convertedMinor != null) 'convertedMinor': convertedMinor,
      if (fxRate != null) 'fxRate': fxRate,
      if (fxRateDate != null) 'fxRateDate': fxRateDate?.toJson(),
      if (fxRateSource != null) 'fxRateSource': fxRateSource?.toJson(),
      'isStale': isStale,
      'accountCount': accountCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NetWorthCurrencyRowImpl extends NetWorthCurrencyRow {
  _NetWorthCurrencyRowImpl({
    required String currencyCode,
    required int nativeMinor,
    int? convertedMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    required bool isStale,
    required int accountCount,
  }) : super._(
         currencyCode: currencyCode,
         nativeMinor: nativeMinor,
         convertedMinor: convertedMinor,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
         isStale: isStale,
         accountCount: accountCount,
       );

  /// Returns a shallow copy of this [NetWorthCurrencyRow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NetWorthCurrencyRow copyWith({
    String? currencyCode,
    int? nativeMinor,
    Object? convertedMinor = _Undefined,
    Object? fxRate = _Undefined,
    DateTime? fxRateDate = const _isc.$UndefinedDateTime(),
    Object? fxRateSource = _Undefined,
    bool? isStale,
    int? accountCount,
  }) {
    return NetWorthCurrencyRow(
      currencyCode: currencyCode ?? this.currencyCode,
      nativeMinor: nativeMinor ?? this.nativeMinor,
      convertedMinor: convertedMinor is int?
          ? convertedMinor
          : this.convertedMinor,
      fxRate: fxRate is String? ? fxRate : this.fxRate,
      fxRateDate: fxRateDate is _isc.UndefinedSentinel
          ? this.fxRateDate
          : fxRateDate,
      fxRateSource: fxRateSource is _ifz8weqz.FxRateSource?
          ? fxRateSource
          : this.fxRateSource,
      isStale: isStale ?? this.isStale,
      accountCount: accountCount ?? this.accountCount,
    );
  }
}
