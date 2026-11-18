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

/// One account's part of a net worth.
abstract class NetWorthAccountRow
    implements _is.SerializableModel, _is.ProtocolSerialization {
  NetWorthAccountRow._({
    required this.accountId,
    required this.entityId,
    required this.name,
    required this.kind,
    required this.isLiability,
    required this.currencyCode,
    required this.balanceMinor,
    this.convertedMinor,
    this.valuationDate,
  });

  factory NetWorthAccountRow({
    required _is.UuidValue accountId,
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required bool isLiability,
    required String currencyCode,
    required int balanceMinor,
    int? convertedMinor,
    DateTime? valuationDate,
  }) = _NetWorthAccountRowImpl;

  factory NetWorthAccountRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return NetWorthAccountRow(
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      kind: _ifz8weqz.AccountKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      isLiability: _is.BoolJsonExtension.fromJson(
        jsonSerialization['isLiability'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      balanceMinor: jsonSerialization['balanceMinor'] as int,
      convertedMinor: jsonSerialization['convertedMinor'] as int?,
      valuationDate: jsonSerialization['valuationDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['valuationDate'],
            ),
    );
  }

  _is.UuidValue accountId;

  _is.UuidValue entityId;

  String name;

  _ifz8weqz.AccountKind kind;

  bool isLiability;

  String currencyCode;

  /// Balance on asOf in account minor units.
  int balanceMinor;

  /// The same in the reporting currency; null when no rate was available.
  int? convertedMinor;

  /// For valuation-sourced accounts: the date of the valuation used.
  DateTime? valuationDate;

  /// Returns a shallow copy of this [NetWorthAccountRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NetWorthAccountRow copyWith({
    _is.UuidValue? accountId,
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    bool? isLiability,
    String? currencyCode,
    int? balanceMinor,
    int? convertedMinor,
    DateTime? valuationDate = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NetWorthAccountRow',
      'accountId': accountId.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'isLiability': isLiability,
      'currencyCode': currencyCode,
      'balanceMinor': balanceMinor,
      if (convertedMinor != null) 'convertedMinor': convertedMinor,
      if (valuationDate != null) 'valuationDate': valuationDate?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NetWorthAccountRow',
      'accountId': accountId.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'isLiability': isLiability,
      'currencyCode': currencyCode,
      'balanceMinor': balanceMinor,
      if (convertedMinor != null) 'convertedMinor': convertedMinor,
      if (valuationDate != null) 'valuationDate': valuationDate?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NetWorthAccountRowImpl extends NetWorthAccountRow {
  _NetWorthAccountRowImpl({
    required _is.UuidValue accountId,
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required bool isLiability,
    required String currencyCode,
    required int balanceMinor,
    int? convertedMinor,
    DateTime? valuationDate,
  }) : super._(
         accountId: accountId,
         entityId: entityId,
         name: name,
         kind: kind,
         isLiability: isLiability,
         currencyCode: currencyCode,
         balanceMinor: balanceMinor,
         convertedMinor: convertedMinor,
         valuationDate: valuationDate,
       );

  /// Returns a shallow copy of this [NetWorthAccountRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NetWorthAccountRow copyWith({
    _is.UuidValue? accountId,
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    bool? isLiability,
    String? currencyCode,
    int? balanceMinor,
    Object? convertedMinor = _Undefined,
    DateTime? valuationDate = const _is.$UndefinedDateTime(),
  }) {
    return NetWorthAccountRow(
      accountId: accountId ?? this.accountId,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      isLiability: isLiability ?? this.isLiability,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      convertedMinor: convertedMinor is int?
          ? convertedMinor
          : this.convertedMinor,
      valuationDate: valuationDate is _is.UndefinedSentinel
          ? this.valuationDate
          : valuationDate,
    );
  }
}
