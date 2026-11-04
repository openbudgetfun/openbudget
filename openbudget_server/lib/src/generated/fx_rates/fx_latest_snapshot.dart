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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../fx_rates/fx_rate_quote.dart' as _i2nu4x3y;

/// Latest FX rates payload returned to clients.
abstract class FxLatestSnapshot
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FxLatestSnapshot._({
    required this.baseCurrencyCode,
    required this.fetchedAt,
    required this.isStale,
    required this.rates,
  });

  factory FxLatestSnapshot({
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    required bool isStale,
    required List<_i2nu4x3y.FxRateQuote> rates,
  }) = _FxLatestSnapshotImpl;

  factory FxLatestSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxLatestSnapshot(
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      fetchedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isStale: _is.BoolJsonExtension.fromJson(jsonSerialization['isStale']),
      rates: _is0sbm8r.Protocol().deserialize<List<_i2nu4x3y.FxRateQuote>>(
        jsonSerialization['rates'],
      ),
    );
  }

  String baseCurrencyCode;

  DateTime fetchedAt;

  bool isStale;

  List<_i2nu4x3y.FxRateQuote> rates;

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2nu4x3y.FxRateQuote>? rates,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxLatestSnapshot',
      'baseCurrencyCode': baseCurrencyCode,
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
      'fetchedAt': fetchedAt.toJson(),
      'isStale': isStale,
      'rates': rates.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxLatestSnapshotImpl extends FxLatestSnapshot {
  _FxLatestSnapshotImpl({
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    required bool isStale,
    required List<_i2nu4x3y.FxRateQuote> rates,
  }) : super._(
         baseCurrencyCode: baseCurrencyCode,
         fetchedAt: fetchedAt,
         isStale: isStale,
         rates: rates,
       );

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2nu4x3y.FxRateQuote>? rates,
  }) {
    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isStale: isStale ?? this.isStale,
      rates: rates ?? this.rates.map((e0) => e0.copyWith()).toList(),
    );
  }
}
