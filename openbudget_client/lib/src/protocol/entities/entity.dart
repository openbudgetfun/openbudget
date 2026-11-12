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

/// A person, household or business whose money OpenBudget keeps: the root
/// that owns accounts, transactions, the envelope plan and the books.
///
/// One entity is one set of books in one base currency.
abstract class Entity
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Entity._({
    this.id,
    required this.ownerId,
    required this.name,
    required this.kind,
    required this.countryCode,
    required this.baseCurrencyCode,
    required this.timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    required this.fiscalYearEndMonth,
    required this.fiscalYearEndDay,
    bool? includeInNetWorth,
    this.linkedPersonalEntityId,
    int? sortOrder,
    this.archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : accountingMode = accountingMode ?? _ifz8weqz.AccountingMode.envelope,
       includeInNetWorth = includeInNetWorth ?? true,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Entity({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    required int fiscalYearEndMonth,
    required int fiscalYearEndDay,
    bool? includeInNetWorth,
    _isc.UuidValue? linkedPersonalEntityId,
    int? sortOrder,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EntityImpl;

  factory Entity.fromJson(Map<String, dynamic> jsonSerialization) {
    return Entity(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      name: jsonSerialization['name'] as String,
      kind: _ifz8weqz.EntityKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      countryCode: jsonSerialization['countryCode'] as String,
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      timeZone: jsonSerialization['timeZone'] as String,
      accountingMode: jsonSerialization['accountingMode'] == null
          ? null
          : _ifz8weqz.AccountingMode.fromJson(
              (jsonSerialization['accountingMode'] as String),
            ),
      fiscalYearEndMonth: jsonSerialization['fiscalYearEndMonth'] as int,
      fiscalYearEndDay: jsonSerialization['fiscalYearEndDay'] as int,
      includeInNetWorth: jsonSerialization['includeInNetWorth'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['includeInNetWorth'],
            ),
      linkedPersonalEntityId:
          jsonSerialization['linkedPersonalEntityId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['linkedPersonalEntityId'],
            ),
      sortOrder: jsonSerialization['sortOrder'] as int?,
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['archivedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  /// The signed-in user who owns the entity.
  _isc.UuidValue ownerId;

  String name;

  /// Fixed after creation.
  _ifz8weqz.EntityKind kind;

  /// ISO 3166-1 alpha-2 country of residence or incorporation, upper case.
  /// Picks the tax rule pack and the chart-of-accounts template.
  String countryCode;

  /// ISO 4217 base (functional) currency. Envelopes, reports, tax and the
  /// books are kept in it. Fixed once the entity has a transaction.
  String baseCurrencyCode;

  /// IANA time zone, such as `Europe/London`. Defines "today" and which
  /// calendar date an instant belongs to.
  String timeZone;

  _ifz8weqz.AccountingMode accountingMode;

  /// Month (1-12) the financial year ends in.
  int fiscalYearEndMonth;

  /// Day of fiscalYearEndMonth the financial year ends on.
  int fiscalYearEndDay;

  /// Whether the entity counts towards the owner's combined net worth.
  bool includeInNetWorth;

  /// For a sole trader or company: the owner's personal entity that the
  /// business's profit, drawings and dividends feed.
  _isc.UuidValue? linkedPersonalEntityId;

  int sortOrder;

  DateTime? archivedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Entity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Entity copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? ownerId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    String? countryCode,
    String? baseCurrencyCode,
    String? timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _isc.UuidValue? linkedPersonalEntityId = const _isc.$UndefinedUuidValue(),
    int? sortOrder,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Entity',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'countryCode': countryCode,
      'baseCurrencyCode': baseCurrencyCode,
      'timeZone': timeZone,
      'accountingMode': accountingMode.toJson(),
      'fiscalYearEndMonth': fiscalYearEndMonth,
      'fiscalYearEndDay': fiscalYearEndDay,
      'includeInNetWorth': includeInNetWorth,
      if (linkedPersonalEntityId != null)
        'linkedPersonalEntityId': linkedPersonalEntityId?.toJson(),
      'sortOrder': sortOrder,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Entity',
      if (id != null) 'id': id?.toJson(),
      'ownerId': ownerId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'countryCode': countryCode,
      'baseCurrencyCode': baseCurrencyCode,
      'timeZone': timeZone,
      'accountingMode': accountingMode.toJson(),
      'fiscalYearEndMonth': fiscalYearEndMonth,
      'fiscalYearEndDay': fiscalYearEndDay,
      'includeInNetWorth': includeInNetWorth,
      if (linkedPersonalEntityId != null)
        'linkedPersonalEntityId': linkedPersonalEntityId?.toJson(),
      'sortOrder': sortOrder,
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EntityImpl extends Entity {
  _EntityImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue ownerId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    required int fiscalYearEndMonth,
    required int fiscalYearEndDay,
    bool? includeInNetWorth,
    _isc.UuidValue? linkedPersonalEntityId,
    int? sortOrder,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         name: name,
         kind: kind,
         countryCode: countryCode,
         baseCurrencyCode: baseCurrencyCode,
         timeZone: timeZone,
         accountingMode: accountingMode,
         fiscalYearEndMonth: fiscalYearEndMonth,
         fiscalYearEndDay: fiscalYearEndDay,
         includeInNetWorth: includeInNetWorth,
         linkedPersonalEntityId: linkedPersonalEntityId,
         sortOrder: sortOrder,
         archivedAt: archivedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Entity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Entity copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? ownerId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    String? countryCode,
    String? baseCurrencyCode,
    String? timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _isc.UuidValue? linkedPersonalEntityId = const _isc.$UndefinedUuidValue(),
    int? sortOrder,
    DateTime? archivedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entity(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      countryCode: countryCode ?? this.countryCode,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      timeZone: timeZone ?? this.timeZone,
      accountingMode: accountingMode ?? this.accountingMode,
      fiscalYearEndMonth: fiscalYearEndMonth ?? this.fiscalYearEndMonth,
      fiscalYearEndDay: fiscalYearEndDay ?? this.fiscalYearEndDay,
      includeInNetWorth: includeInNetWorth ?? this.includeInNetWorth,
      linkedPersonalEntityId: linkedPersonalEntityId is _isc.UndefinedSentinel
          ? this.linkedPersonalEntityId
          : linkedPersonalEntityId,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAt: archivedAt is _isc.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
