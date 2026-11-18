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
import 'package:serverpod/serverpod.dart' as _is;

/// The rate the server would use to convert between two currencies on a date.
abstract class FxQuoteView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FxQuoteView._({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.rate,
    required this.rateDate,
    required this.source,
    this.fetchedAt,
    required this.isStale,
  });

  factory FxQuoteView({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required String rate,
    required DateTime rateDate,
    required _ifz8weqz.FxRateSource source,
    DateTime? fetchedAt,
    required bool isStale,
  }) = _FxQuoteViewImpl;

  factory FxQuoteView.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxQuoteView(
      fromCurrencyCode: jsonSerialization['fromCurrencyCode'] as String,
      toCurrencyCode: jsonSerialization['toCurrencyCode'] as String,
      rate: jsonSerialization['rate'] as String,
      rateDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['rateDate'],
      ),
      source: _ifz8weqz.FxRateSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      isStale: _is.BoolJsonExtension.fromJson(jsonSerialization['isStale']),
    );
  }

  String fromCurrencyCode;

  String toCurrencyCode;

  /// Units of toCurrencyCode per one fromCurrencyCode, exact decimal string.
  String rate;

  /// Calendar date of the rate actually used (on or before the asked date).
  DateTime rateDate;

  _ifz8weqz.FxRateSource source;

  DateTime? fetchedAt;

  bool isStale;

  /// Returns a shallow copy of this [FxQuoteView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxQuoteView copyWith({
    String? fromCurrencyCode,
    String? toCurrencyCode,
    String? rate,
    DateTime? rateDate,
    _ifz8weqz.FxRateSource? source,
    DateTime? fetchedAt = const _is.$UndefinedDateTime(),
    bool? isStale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxQuoteView',
      'fromCurrencyCode': fromCurrencyCode,
      'toCurrencyCode': toCurrencyCode,
      'rate': rate,
      'rateDate': rateDate.toJson(),
      'source': source.toJson(),
      if (fetchedAt != null) 'fetchedAt': fetchedAt?.toJson(),
      'isStale': isStale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxQuoteView',
      'fromCurrencyCode': fromCurrencyCode,
      'toCurrencyCode': toCurrencyCode,
      'rate': rate,
      'rateDate': rateDate.toJson(),
      'source': source.toJson(),
      if (fetchedAt != null) 'fetchedAt': fetchedAt?.toJson(),
      'isStale': isStale,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxQuoteViewImpl extends FxQuoteView {
  _FxQuoteViewImpl({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required String rate,
    required DateTime rateDate,
    required _ifz8weqz.FxRateSource source,
    DateTime? fetchedAt,
    required bool isStale,
  }) : super._(
         fromCurrencyCode: fromCurrencyCode,
         toCurrencyCode: toCurrencyCode,
         rate: rate,
         rateDate: rateDate,
         source: source,
         fetchedAt: fetchedAt,
         isStale: isStale,
       );

  /// Returns a shallow copy of this [FxQuoteView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxQuoteView copyWith({
    String? fromCurrencyCode,
    String? toCurrencyCode,
    String? rate,
    DateTime? rateDate,
    _ifz8weqz.FxRateSource? source,
    DateTime? fetchedAt = const _is.$UndefinedDateTime(),
    bool? isStale,
  }) {
    return FxQuoteView(
      fromCurrencyCode: fromCurrencyCode ?? this.fromCurrencyCode,
      toCurrencyCode: toCurrencyCode ?? this.toCurrencyCode,
      rate: rate ?? this.rate,
      rateDate: rateDate ?? this.rateDate,
      source: source ?? this.source,
      fetchedAt: fetchedAt is _is.UndefinedSentinel
          ? this.fetchedAt
          : fetchedAt,
      isStale: isStale ?? this.isStale,
    );
  }
}
