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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../reports/crypto_breakdown_grouping.dart' as _i6plhsy1;
import '../reports/crypto_breakdown_row.dart' as _imucixug;

/// What an entity's wallets are worth, split by chain or by asset, in one
/// reporting currency. Only counted holdings are summed: priced ones whose
/// spam verdict is clean or allowedByUser, converted with the same daily FX
/// the net worth report uses.
abstract class CryptoBreakdownView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CryptoBreakdownView._({
    required this.currencyCode,
    required this.asOf,
    required this.grouping,
    required this.totalMinor,
    required this.walletCount,
    required this.isComplete,
    required this.missingCurrencyCodes,
    required this.hasStaleRates,
    required this.rows,
  });

  factory CryptoBreakdownView({
    required String currencyCode,
    required DateTime asOf,
    required _i6plhsy1.CryptoBreakdownGrouping grouping,
    required int totalMinor,
    required int walletCount,
    required bool isComplete,
    required List<String> missingCurrencyCodes,
    required bool hasStaleRates,
    required List<_imucixug.CryptoBreakdownRow> rows,
  }) = _CryptoBreakdownViewImpl;

  factory CryptoBreakdownView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CryptoBreakdownView(
      currencyCode: jsonSerialization['currencyCode'] as String,
      asOf: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['asOf']),
      grouping: _i6plhsy1.CryptoBreakdownGrouping.fromJson(
        (jsonSerialization['grouping'] as String),
      ),
      totalMinor: jsonSerialization['totalMinor'] as int,
      walletCount: jsonSerialization['walletCount'] as int,
      isComplete: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isComplete'],
      ),
      missingCurrencyCodes: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['missingCurrencyCodes'],
      ),
      hasStaleRates: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasStaleRates'],
      ),
      rows: _irkl4crj.Protocol()
          .deserialize<List<_imucixug.CryptoBreakdownRow>>(
            jsonSerialization['rows'],
          ),
    );
  }

  /// ISO 4217 reporting currency every value is in.
  String currencyCode;

  /// Calendar date the rates are for: today in the entity's time zone.
  DateTime asOf;

  _i6plhsy1.CryptoBreakdownGrouping grouping;

  /// The sum of every row's valueMinor.
  int totalMinor;

  /// How many wallets the entity has, counted or not. Zero means the app
  /// hides the section.
  int walletCount;

  /// False when some holding's currency had no rate; those holdings are left
  /// out of every figure and their codes are in missingCurrencyCodes.
  bool isComplete;

  List<String> missingCurrencyCodes;

  /// True when any rate used is stale.
  bool hasStaleRates;

  /// Largest first; empty when nothing is counted.
  List<_imucixug.CryptoBreakdownRow> rows;

  /// Returns a shallow copy of this [CryptoBreakdownView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CryptoBreakdownView copyWith({
    String? currencyCode,
    DateTime? asOf,
    _i6plhsy1.CryptoBreakdownGrouping? grouping,
    int? totalMinor,
    int? walletCount,
    bool? isComplete,
    List<String>? missingCurrencyCodes,
    bool? hasStaleRates,
    List<_imucixug.CryptoBreakdownRow>? rows,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CryptoBreakdownView',
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'grouping': grouping.toJson(),
      'totalMinor': totalMinor,
      'walletCount': walletCount,
      'isComplete': isComplete,
      'missingCurrencyCodes': missingCurrencyCodes.toJson(),
      'hasStaleRates': hasStaleRates,
      'rows': rows.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CryptoBreakdownView',
      'currencyCode': currencyCode,
      'asOf': asOf.toJson(),
      'grouping': grouping.toJson(),
      'totalMinor': totalMinor,
      'walletCount': walletCount,
      'isComplete': isComplete,
      'missingCurrencyCodes': missingCurrencyCodes.toJson(),
      'hasStaleRates': hasStaleRates,
      'rows': rows.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CryptoBreakdownViewImpl extends CryptoBreakdownView {
  _CryptoBreakdownViewImpl({
    required String currencyCode,
    required DateTime asOf,
    required _i6plhsy1.CryptoBreakdownGrouping grouping,
    required int totalMinor,
    required int walletCount,
    required bool isComplete,
    required List<String> missingCurrencyCodes,
    required bool hasStaleRates,
    required List<_imucixug.CryptoBreakdownRow> rows,
  }) : super._(
         currencyCode: currencyCode,
         asOf: asOf,
         grouping: grouping,
         totalMinor: totalMinor,
         walletCount: walletCount,
         isComplete: isComplete,
         missingCurrencyCodes: missingCurrencyCodes,
         hasStaleRates: hasStaleRates,
         rows: rows,
       );

  /// Returns a shallow copy of this [CryptoBreakdownView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CryptoBreakdownView copyWith({
    String? currencyCode,
    DateTime? asOf,
    _i6plhsy1.CryptoBreakdownGrouping? grouping,
    int? totalMinor,
    int? walletCount,
    bool? isComplete,
    List<String>? missingCurrencyCodes,
    bool? hasStaleRates,
    List<_imucixug.CryptoBreakdownRow>? rows,
  }) {
    return CryptoBreakdownView(
      currencyCode: currencyCode ?? this.currencyCode,
      asOf: asOf ?? this.asOf,
      grouping: grouping ?? this.grouping,
      totalMinor: totalMinor ?? this.totalMinor,
      walletCount: walletCount ?? this.walletCount,
      isComplete: isComplete ?? this.isComplete,
      missingCurrencyCodes:
          missingCurrencyCodes ??
          this.missingCurrencyCodes.map((e0) => e0).toList(),
      hasStaleRates: hasStaleRates ?? this.hasStaleRates,
      rows: rows ?? this.rows.map((e0) => e0.copyWith()).toList(),
    );
  }
}
