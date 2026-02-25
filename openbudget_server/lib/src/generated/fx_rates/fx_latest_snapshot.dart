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
import 'package:serverpod/serverpod.dart' as _i1;
import '../fx_rates/fx_rate_quote.dart' as _i2;
import 'package:openbudget_server/src/generated/protocol.dart' as _i3;

/// Latest FX rates payload returned to clients.
abstract class FxLatestSnapshot
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
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
    required List<_i2.FxRateQuote> rates,
  }) = _FxLatestSnapshotImpl;

  factory FxLatestSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxLatestSnapshot(
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isStale: jsonSerialization['isStale'] as bool,
      rates: _i3.Protocol().deserialize<List<_i2.FxRateQuote>>(
        jsonSerialization['rates'],
      ),
    );
  }

  String baseCurrencyCode;

  DateTime fetchedAt;

  bool isStale;

  List<_i2.FxRateQuote> rates;

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2.FxRateQuote>? rates,
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
    return _i1.SerializationManager.encode(this);
  }
}

class _FxLatestSnapshotImpl extends FxLatestSnapshot {
  _FxLatestSnapshotImpl({
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    required bool isStale,
    required List<_i2.FxRateQuote> rates,
  }) : super._(
         baseCurrencyCode: baseCurrencyCode,
         fetchedAt: fetchedAt,
         isStale: isStale,
         rates: rates,
       );

  /// Returns a shallow copy of this [FxLatestSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxLatestSnapshot copyWith({
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isStale,
    List<_i2.FxRateQuote>? rates,
  }) {
    return FxLatestSnapshot(
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isStale: isStale ?? this.isStale,
      rates: rates ?? this.rates.map((e0) => e0.copyWith()).toList(),
    );
  }
}
