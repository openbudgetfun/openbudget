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

import '../fx_rates/fx_rate_quote.dart' as _i2nu4x3y;

/// The latest daily rates, for display only. Conversions that are stored
/// happen on the server.
abstract class FxLatestSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FxLatestSnapshot._({
    required this.baseCurrencyCode,
    required this.rateDate,
    required this.fetchedAt,
    required this.isStale,
    required this.rates,
  });

  factory FxLatestSnapshot({
    required String baseCurrencyCode,
    required DateTime rateDate,
    required DateTime fetchedAt,
    required bool isStale,
    required List<_i2nu4x3y.FxRateQuote> rates,
  }) = _FxLatestSnapshotImpl;

  factory FxLatestSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxLatestSnapshot(
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      rateDate: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['rateDate'],
      ),
      fetchedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isStale: _isc.BoolJsonExtension.fromJson(jsonSerialization['isStale']),
      rates: _irkl4crj.Protocol().deserialize<List<_i2nu4x3y.FxRateQuote>>(
        jsonSerialization['rates'],
      ),
    );
  }

  /// Always USD.
  String baseCurrencyCode;

  /// Calendar date of the rates.
  DateTime rateDate;

  DateTime fetchedAt;

  /// True when fetchedAt is more than 48 hours old.
  bool isStale;

  List<_i2nu4x3y.FxRateQuote> rates;

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? rateDate,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2nu4x3y.FxRateQuote>? rates,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxLatestSnapshot',
      'baseCurrencyCode': baseCurrencyCode,
      'rateDate': rateDate.toJson(),
      'fetchedAt': fetchedAt.toJson(),
      'isStale': isStale,
      'rates': rates.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxLatestSnapshot',
      'baseCurrencyCode': baseCurrencyCode,
      'rateDate': rateDate.toJson(),
      'fetchedAt': fetchedAt.toJson(),
      'isStale': isStale,
      'rates': rates.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _FxLatestSnapshotImpl extends FxLatestSnapshot {
  _FxLatestSnapshotImpl({
    required String baseCurrencyCode,
    required DateTime rateDate,
    required DateTime fetchedAt,
    required bool isStale,
    required List<_i2nu4x3y.FxRateQuote> rates,
  }) : super._(
         baseCurrencyCode: baseCurrencyCode,
         rateDate: rateDate,
         fetchedAt: fetchedAt,
         isStale: isStale,
         rates: rates,
       );

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? rateDate,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2nu4x3y.FxRateQuote>? rates,
  }) {
    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      rateDate: rateDate ?? this.rateDate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isStale: isStale ?? this.isStale,
      rates: rates ?? this.rates.map((e0) => e0.copyWith()).toList(),
    );
  }
}
