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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Net worth on one date, in the reporting currency.
abstract class NetWorthPoint
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  NetWorthPoint._({
    required this.date,
    required this.assetsMinor,
    required this.liabilitiesMinor,
    required this.netWorthMinor,
    required this.isComplete,
  });

  factory NetWorthPoint({
    required DateTime date,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
  }) = _NetWorthPointImpl;

  factory NetWorthPoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthPoint(
      date: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      assetsMinor: jsonSerialization['assetsMinor'] as int,
      liabilitiesMinor: jsonSerialization['liabilitiesMinor'] as int,
      netWorthMinor: jsonSerialization['netWorthMinor'] as int,
      isComplete: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isComplete'],
      ),
    );
  }

  /// Calendar date: the last day of the period, or today for the last point.
  DateTime date;

  int assetsMinor;

  int liabilitiesMinor;

  int netWorthMinor;

  bool isComplete;

  /// Returns a shallow copy of this [NetWorthPoint]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NetWorthPoint copyWith({
    DateTime? date,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthPoint',
      'date': date.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthPoint',
      'date': date.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _NetWorthPointImpl extends NetWorthPoint {
  _NetWorthPointImpl({
    required DateTime date,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
  }) : super._(
         date: date,
         assetsMinor: assetsMinor,
         liabilitiesMinor: liabilitiesMinor,
         netWorthMinor: netWorthMinor,
         isComplete: isComplete,
       );

  /// Returns a shallow copy of this [NetWorthPoint]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NetWorthPoint copyWith({
    DateTime? date,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
  }) {
    return NetWorthPoint(
      date: date ?? this.date,
      assetsMinor: assetsMinor ?? this.assetsMinor,
      liabilitiesMinor: liabilitiesMinor ?? this.liabilitiesMinor,
      netWorthMinor: netWorthMinor ?? this.netWorthMinor,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
