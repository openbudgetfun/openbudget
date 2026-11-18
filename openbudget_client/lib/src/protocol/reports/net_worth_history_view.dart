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

import '../reports/net_worth_granularity.dart' as _iyyb51w6;
import '../reports/net_worth_point.dart' as _i8hl6ajn;

/// Net worth at evenly spaced dates, for a chart.
abstract class NetWorthHistoryView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  NetWorthHistoryView._({
    required this.currencyCode,
    required this.granularity,
    required this.points,
  });

  factory NetWorthHistoryView({
    required String currencyCode,
    required _iyyb51w6.NetWorthGranularity granularity,
    required List<_i8hl6ajn.NetWorthPoint> points,
  }) = _NetWorthHistoryViewImpl;

  factory NetWorthHistoryView.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthHistoryView(
      currencyCode: jsonSerialization['currencyCode'] as String,
      granularity: _iyyb51w6.NetWorthGranularity.fromJson(
        (jsonSerialization['granularity'] as String),
      ),
      points: _irkl4crj.Protocol().deserialize<List<_i8hl6ajn.NetWorthPoint>>(
        jsonSerialization['points'],
      ),
    );
  }

  String currencyCode;

  _iyyb51w6.NetWorthGranularity granularity;

  List<_i8hl6ajn.NetWorthPoint> points;

  /// Returns a shallow copy of this [NetWorthHistoryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NetWorthHistoryView copyWith({
    String? currencyCode,
    _iyyb51w6.NetWorthGranularity? granularity,
    List<_i8hl6ajn.NetWorthPoint>? points,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthHistoryView',
      'currencyCode': currencyCode,
      'granularity': granularity.toJson(),
      'points': points.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthHistoryView',
      'currencyCode': currencyCode,
      'granularity': granularity.toJson(),
      'points': points.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _NetWorthHistoryViewImpl extends NetWorthHistoryView {
  _NetWorthHistoryViewImpl({
    required String currencyCode,
    required _iyyb51w6.NetWorthGranularity granularity,
    required List<_i8hl6ajn.NetWorthPoint> points,
  }) : super._(
         currencyCode: currencyCode,
         granularity: granularity,
         points: points,
       );

  /// Returns a shallow copy of this [NetWorthHistoryView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NetWorthHistoryView copyWith({
    String? currencyCode,
    _iyyb51w6.NetWorthGranularity? granularity,
    List<_i8hl6ajn.NetWorthPoint>? points,
  }) {
    return NetWorthHistoryView(
      currencyCode: currencyCode ?? this.currencyCode,
      granularity: granularity ?? this.granularity,
      points: points ?? this.points.map((e0) => e0.copyWith()).toList(),
    );
  }
}
