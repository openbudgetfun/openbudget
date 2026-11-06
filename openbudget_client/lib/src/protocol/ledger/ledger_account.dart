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

/// One account in a budget's double-entry chart of accounts.
///
/// Codes are user-visible labels; nothing keys on them. Accounts with a
/// [LedgerSystemRole]-style `systemRole` are structural: one active account
/// per role, and they cannot be deleted.
abstract class LedgerAccount
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LedgerAccount._({
    this.id,
    required this.budgetId,
    required this.code,
    required this.name,
    required this.type,
    this.systemRole,
    this.currencyCode,
    this.taxCategoryCode,
    bool? archived,
    DateTime? createdAt,
  }) : archived = archived ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory LedgerAccount({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    bool? archived,
    DateTime? createdAt,
  }) = _LedgerAccountImpl;

  factory LedgerAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      type: jsonSerialization['type'] as String,
      systemRole: jsonSerialization['systemRole'] as String?,
      currencyCode: jsonSerialization['currencyCode'] as String?,
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      archived: jsonSerialization['archived'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['archived']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue budgetId;

  /// Illustrative code from the template chart, unique per budget.
  String code;

  String name;

  /// LedgerAccountType name: asset, liability, equity, income or expense.
  String type;

  /// LedgerSystemRole name, when this is a structural account.
  String? systemRole;

  /// ISO 4217 code for foreign-currency bank or control accounts.
  String? currencyCode;

  /// Optional tax category feeding the tax engine.
  String? taxCategoryCode;

  /// Archived accounts keep their lines but accept no new postings.
  bool archived;

  DateTime createdAt;

  /// Returns a shallow copy of this [LedgerAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LedgerAccount copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? code,
    String? name,
    String? type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    bool? archived,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerAccount',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'code': code,
      'name': name,
      'type': type,
      if (systemRole != null) 'systemRole': systemRole,
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      'archived': archived,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerAccount',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'code': code,
      'name': name,
      'type': type,
      if (systemRole != null) 'systemRole': systemRole,
      if (currencyCode != null) 'currencyCode': currencyCode,
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      'archived': archived,
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
    required _isc.UuidValue budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    bool? archived,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         code: code,
         name: name,
         type: type,
         systemRole: systemRole,
         currencyCode: currencyCode,
         taxCategoryCode: taxCategoryCode,
         archived: archived,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [LedgerAccount]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LedgerAccount copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? code,
    String? name,
    String? type,
    Object? systemRole = _Undefined,
    Object? currencyCode = _Undefined,
    Object? taxCategoryCode = _Undefined,
    bool? archived,
    DateTime? createdAt,
  }) {
    return LedgerAccount(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      systemRole: systemRole is String? ? systemRole : this.systemRole,
      currencyCode: currencyCode is String? ? currencyCode : this.currencyCode,
      taxCategoryCode: taxCategoryCode is String?
          ? taxCategoryCode
          : this.taxCategoryCode,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
