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

/// One exchange rate a summary's converted lines used.
///
/// The rate facts are the exact daily quotes the tax conversion applied,
/// mirroring how a net-worth row reports its own rates. The rate text is
/// the summary currency per one unit of [currencyCode].
abstract class TaxSummaryFxNoteView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxSummaryFxNoteView._({
    required this.currencyCode,
    required this.fxRate,
    required this.fxRateDate,
    required this.fxRateSource,
    required this.isStale,
    required this.lineCount,
    required this.convertedMinor,
  });

  factory TaxSummaryFxNoteView({
    required String currencyCode,
    required String fxRate,
    required DateTime fxRateDate,
    required _ifz8weqz.FxRateSource fxRateSource,
    required bool isStale,
    required int lineCount,
    required int convertedMinor,
  }) = _TaxSummaryFxNoteViewImpl;

  factory TaxSummaryFxNoteView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxSummaryFxNoteView(
      currencyCode: jsonSerialization['currencyCode'] as String,
      fxRate: jsonSerialization['fxRate'] as String,
      fxRateDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fxRateDate'],
      ),
      fxRateSource: _ifz8weqz.FxRateSource.fromJson(
        (jsonSerialization['fxRateSource'] as String),
      ),
      isStale: _isc.BoolJsonExtension.fromJson(jsonSerialization['isStale']),
      lineCount: jsonSerialization['lineCount'] as int,
      convertedMinor: jsonSerialization['convertedMinor'] as int,
    );
  }

  /// ISO 4217 code the lines were converted from.
  String currencyCode;

  /// The exact decimal rate the conversion applied.
  String fxRate;

  /// The quote's date, which may fall back within seven days of a line.
  DateTime fxRateDate;

  /// Where the quote came from: `market` or `identity`.
  _ifz8weqz.FxRateSource fxRateSource;

  /// True when the quote is older than the staleness rule allows.
  bool isStale;

  /// The converted lines that used this rate.
  int lineCount;

  /// The lines' converted magnitudes added together.
  int convertedMinor;

  /// Returns a shallow copy of this [TaxSummaryFxNoteView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxSummaryFxNoteView copyWith({
    String? currencyCode,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    bool? isStale,
    int? lineCount,
    int? convertedMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummaryFxNoteView',
      'currencyCode': currencyCode,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'isStale': isStale,
      'lineCount': lineCount,
      'convertedMinor': convertedMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummaryFxNoteView',
      'currencyCode': currencyCode,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'isStale': isStale,
      'lineCount': lineCount,
      'convertedMinor': convertedMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TaxSummaryFxNoteViewImpl extends TaxSummaryFxNoteView {
  _TaxSummaryFxNoteViewImpl({
    required String currencyCode,
    required String fxRate,
    required DateTime fxRateDate,
    required _ifz8weqz.FxRateSource fxRateSource,
    required bool isStale,
    required int lineCount,
    required int convertedMinor,
  }) : super._(
         currencyCode: currencyCode,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
         isStale: isStale,
         lineCount: lineCount,
         convertedMinor: convertedMinor,
       );

  /// Returns a shallow copy of this [TaxSummaryFxNoteView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxSummaryFxNoteView copyWith({
    String? currencyCode,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    bool? isStale,
    int? lineCount,
    int? convertedMinor,
  }) {
    return TaxSummaryFxNoteView(
      currencyCode: currencyCode ?? this.currencyCode,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate ?? this.fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      isStale: isStale ?? this.isStale,
      lineCount: lineCount ?? this.lineCount,
      convertedMinor: convertedMinor ?? this.convertedMinor,
    );
  }
}
