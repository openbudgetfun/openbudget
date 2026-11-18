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

/// One entity's part of a net worth, in the reporting currency.
abstract class NetWorthEntityRow
    implements _is.SerializableModel, _is.ProtocolSerialization {
  NetWorthEntityRow._({
    required this.entityId,
    required this.name,
    required this.kind,
    required this.assetsMinor,
    required this.liabilitiesMinor,
    required this.netWorthMinor,
    required this.isComplete,
  });

  factory NetWorthEntityRow({
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
  }) = _NetWorthEntityRowImpl;

  factory NetWorthEntityRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthEntityRow(
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      kind: _ifz8weqz.EntityKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      assetsMinor: jsonSerialization['assetsMinor'] as int,
      liabilitiesMinor: jsonSerialization['liabilitiesMinor'] as int,
      netWorthMinor: jsonSerialization['netWorthMinor'] as int,
      isComplete: _is.BoolJsonExtension.fromJson(
        jsonSerialization['isComplete'],
      ),
    );
  }

  _is.UuidValue entityId;

  String name;

  _ifz8weqz.EntityKind kind;

  int assetsMinor;

  int liabilitiesMinor;

  int netWorthMinor;

  bool isComplete;

  /// Returns a shallow copy of this [NetWorthEntityRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NetWorthEntityRow copyWith({
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthEntityRow',
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthEntityRow',
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'assetsMinor': assetsMinor,
      'liabilitiesMinor': liabilitiesMinor,
      'netWorthMinor': netWorthMinor,
      'isComplete': isComplete,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _NetWorthEntityRowImpl extends NetWorthEntityRow {
  _NetWorthEntityRowImpl({
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required int assetsMinor,
    required int liabilitiesMinor,
    required int netWorthMinor,
    required bool isComplete,
  }) : super._(
         entityId: entityId,
         name: name,
         kind: kind,
         assetsMinor: assetsMinor,
         liabilitiesMinor: liabilitiesMinor,
         netWorthMinor: netWorthMinor,
         isComplete: isComplete,
       );

  /// Returns a shallow copy of this [NetWorthEntityRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NetWorthEntityRow copyWith({
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    int? assetsMinor,
    int? liabilitiesMinor,
    int? netWorthMinor,
    bool? isComplete,
  }) {
    return NetWorthEntityRow(
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      assetsMinor: assetsMinor ?? this.assetsMinor,
      liabilitiesMinor: liabilitiesMinor ?? this.liabilitiesMinor,
      netWorthMinor: netWorthMinor ?? this.netWorthMinor,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
