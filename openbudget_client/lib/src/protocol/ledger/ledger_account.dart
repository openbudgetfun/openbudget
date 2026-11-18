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

/// One account in an entity's double-entry chart of accounts.
///
/// Codes are user-visible labels; nothing keys on them. Accounts with a
/// systemRole are structural: one per role, never archived.
abstract class LedgerAccount
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LedgerAccount._({
    this.id,
    required this.entityId,
    required this.code,
    required this.name,
    required this.type,
    this.systemRole,
    this.currencyCode,
    this.taxCategoryCode,
    this.archivedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LedgerAccount({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String code,
    required String name,
    required _ifz8weqz.LedgerAccountType type,
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) = _LedgerAccountImpl;

  factory LedgerAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      type: _ifz8weqz.LedgerAccountType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      systemRole: jsonSerialization['systemRole'] == null
          ? null
          : _ifz8weqz.LedgerSystemRole.fromJson(
              (jsonSerialization['systemRole'] as String),
            ),
      currencyCode: jsonSerialization['currencyCode'] as String?,
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue entityId;

  /// Code from the template chart, unique per entity.
  String code;

  String name;

  _ifz8weqz.LedgerAccountType type;

  _ifz8weqz.LedgerSystemRole? systemRole;

  /// ISO 4217 code for foreign-currency bank and control accounts.
  String? currencyCode;

  /// Tax category feeding the tax engine.
  String? taxCategoryCode;

  /// Archived accounts keep their lines but accept no new postings.
  DateTime? archivedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [LedgerAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LedgerAccount copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? code,
    String? name,
    _ifz8weqz.LedgerAccountType? type,
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerAccount',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'code': code,
      'name': name,
      'type': type.toJson(),
      if (systemRole != null) 'systemRole': systemRole?.toJson(),
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerAccount',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'code': code,
      'name': name,
      'type': type.toJson(),
      if (systemRole != null) 'systemRole': systemRole?.toJson(),
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LedgerAccountImpl extends LedgerAccount {
  _LedgerAccountImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String code,
    required String name,
    required _ifz8weqz.LedgerAccountType type,
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    DateTime? archivedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entityId: entityId,
         code: code,
         name: name,
         type: type,
         systemRole: systemRole,
         currencyCode: currencyCode,
         taxCategoryCode: taxCategoryCode,
         archivedAt: archivedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [LedgerAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LedgerAccount copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? code,
    String? name,
    _ifz8weqz.LedgerAccountType? type,
    Object? systemRole = _Undefined,
    Object? currencyCode = _Undefined,
    Object? taxCategoryCode = _Undefined,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
  }) {
    return LedgerAccount(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      systemRole: systemRole is _ifz8weqz.LedgerSystemRole?
          ? systemRole
          : this.systemRole,
      currencyCode: currencyCode is String? ? currencyCode : this.currencyCode,
      taxCategoryCode: taxCategoryCode is String?
          ? taxCategoryCode
          : this.taxCategoryCode,
      archivedAt: archivedAt is _isc.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
