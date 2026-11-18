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
import 'dart:async' as _ida;

import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod/serverpod.dart' as _is;

/// A person, household or business whose money OpenBudget keeps: the root
/// that owns accounts, transactions, the envelope plan and the books.
///
/// One entity is one set of books in one base currency.
abstract class Entity
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    required int fiscalYearEndMonth,
    required int fiscalYearEndDay,
    bool? includeInNetWorth,
    _is.UuidValue? linkedPersonalEntityId,
    int? sortOrder,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EntityImpl;

  factory Entity.fromJson(Map<String, dynamic> jsonSerialization) {
    return Entity(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ownerId: _is.UuidValueJsonExtension.fromJson(
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
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['includeInNetWorth'],
            ),
      linkedPersonalEntityId:
          jsonSerialization['linkedPersonalEntityId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['linkedPersonalEntityId'],
            ),
      sortOrder: jsonSerialization['sortOrder'] as int?,
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = EntityTable();

  static const db = EntityRepository._();

  @override
  _is.UuidValue? id;

  /// The signed-in user who owns the entity.
  _is.UuidValue ownerId;

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
  _is.UuidValue? linkedPersonalEntityId;

  int sortOrder;

  DateTime? archivedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Entity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Entity copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ownerId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    String? countryCode,
    String? baseCurrencyCode,
    String? timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _is.UuidValue? linkedPersonalEntityId = const _is.$UndefinedUuidValue(),
    int? sortOrder,
    DateTime? archivedAt = const _is.$UndefinedDateTime(),
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

  static EntityInclude include() {
    return EntityInclude._();
  }

  static EntityIncludeList includeList({
    _is.WhereExpressionBuilder<EntityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    EntityInclude? include,
  }) {
    return EntityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EntityImpl extends Entity {
  _EntityImpl({
    _is.UuidValue? id,
    required _is.UuidValue ownerId,
    required String name,
    required _ifz8weqz.EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    required int fiscalYearEndMonth,
    required int fiscalYearEndDay,
    bool? includeInNetWorth,
    _is.UuidValue? linkedPersonalEntityId,
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
  @_is.useResult
  @override
  Entity copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ownerId,
    String? name,
    _ifz8weqz.EntityKind? kind,
    String? countryCode,
    String? baseCurrencyCode,
    String? timeZone,
    _ifz8weqz.AccountingMode? accountingMode,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    _is.UuidValue? linkedPersonalEntityId = const _is.$UndefinedUuidValue(),
    int? sortOrder,
    DateTime? archivedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entity(
      id: id is _is.UndefinedSentinel ? this.id : id,
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
      linkedPersonalEntityId: linkedPersonalEntityId is _is.UndefinedSentinel
          ? this.linkedPersonalEntityId
          : linkedPersonalEntityId,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAt: archivedAt is _is.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EntityUpdateTable extends _is.UpdateTable<EntityTable> {
  EntityUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ownerId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.ownerId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_ifz8weqz.EntityKind, _ifz8weqz.EntityKind> kind(
    _ifz8weqz.EntityKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> countryCode(String value) => _is.ColumnValue(
    table.countryCode,
    value,
  );

  _is.ColumnValue<String, String> baseCurrencyCode(String value) =>
      _is.ColumnValue(
        table.baseCurrencyCode,
        value,
      );

  _is.ColumnValue<String, String> timeZone(String value) => _is.ColumnValue(
    table.timeZone,
    value,
  );

  _is.ColumnValue<_ifz8weqz.AccountingMode, _ifz8weqz.AccountingMode>
  accountingMode(_ifz8weqz.AccountingMode value) => _is.ColumnValue(
    table.accountingMode,
    value,
  );

  _is.ColumnValue<int, int> fiscalYearEndMonth(int value) => _is.ColumnValue(
    table.fiscalYearEndMonth,
    value,
  );

  _is.ColumnValue<int, int> fiscalYearEndDay(int value) => _is.ColumnValue(
    table.fiscalYearEndDay,
    value,
  );

  _is.ColumnValue<bool, bool> includeInNetWorth(bool value) => _is.ColumnValue(
    table.includeInNetWorth,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> linkedPersonalEntityId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.linkedPersonalEntityId,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> archivedAt(DateTime? value) =>
      _is.ColumnValue(
        table.archivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class EntityTable extends _is.Table<_is.UuidValue?> {
  EntityTable({super.tableRelation}) : super(tableName: 'entity') {
    updateTable = EntityUpdateTable(this);
    ownerId = _is.ColumnUuid(
      'ownerId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    countryCode = _is.ColumnString(
      'countryCode',
      this,
    );
    baseCurrencyCode = _is.ColumnString(
      'baseCurrencyCode',
      this,
    );
    timeZone = _is.ColumnString(
      'timeZone',
      this,
    );
    accountingMode = _is.ColumnEnum(
      'accountingMode',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    fiscalYearEndMonth = _is.ColumnInt(
      'fiscalYearEndMonth',
      this,
    );
    fiscalYearEndDay = _is.ColumnInt(
      'fiscalYearEndDay',
      this,
    );
    includeInNetWorth = _is.ColumnBool(
      'includeInNetWorth',
      this,
      hasDefault: true,
    );
    linkedPersonalEntityId = _is.ColumnUuid(
      'linkedPersonalEntityId',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
      hasDefault: true,
    );
    archivedAt = _is.ColumnDateTime(
      'archivedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final EntityUpdateTable updateTable;

  /// The signed-in user who owns the entity.
  late final _is.ColumnUuid ownerId;

  late final _is.ColumnString name;

  /// Fixed after creation.
  late final _is.ColumnEnum<_ifz8weqz.EntityKind> kind;

  /// ISO 3166-1 alpha-2 country of residence or incorporation, upper case.
  /// Picks the tax rule pack and the chart-of-accounts template.
  late final _is.ColumnString countryCode;

  /// ISO 4217 base (functional) currency. Envelopes, reports, tax and the
  /// books are kept in it. Fixed once the entity has a transaction.
  late final _is.ColumnString baseCurrencyCode;

  /// IANA time zone, such as `Europe/London`. Defines "today" and which
  /// calendar date an instant belongs to.
  late final _is.ColumnString timeZone;

  late final _is.ColumnEnum<_ifz8weqz.AccountingMode> accountingMode;

  /// Month (1-12) the financial year ends in.
  late final _is.ColumnInt fiscalYearEndMonth;

  /// Day of fiscalYearEndMonth the financial year ends on.
  late final _is.ColumnInt fiscalYearEndDay;

  /// Whether the entity counts towards the owner's combined net worth.
  late final _is.ColumnBool includeInNetWorth;

  /// For a sole trader or company: the owner's personal entity that the
  /// business's profit, drawings and dividends feed.
  late final _is.ColumnUuid linkedPersonalEntityId;

  late final _is.ColumnInt sortOrder;

  late final _is.ColumnDateTime archivedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    ownerId,
    name,
    kind,
    countryCode,
    baseCurrencyCode,
    timeZone,
    accountingMode,
    fiscalYearEndMonth,
    fiscalYearEndDay,
    includeInNetWorth,
    linkedPersonalEntityId,
    sortOrder,
    archivedAt,
    createdAt,
    updatedAt,
  ];
}

class EntityInclude extends _is.IncludeObject {
  EntityInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Entity.t;
}

class EntityIncludeList extends _is.IncludeList {
  EntityIncludeList._({
    _is.WhereExpressionBuilder<EntityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Entity.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Entity.t;
}

class EntityRepository {
  const EntityRepository._();

  /// Returns a list of [Entity]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Entity>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Entity>(
      where: where?.call(Entity.t),
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Entity]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `Entity.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<Entity>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntityTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Entity>(
      where: where?.call(Entity.t),
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Entity] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Entity?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntityTable>? where,
    int? offset,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Entity>(
      where: where?.call(Entity.t),
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Entity] by its [id] or null if no such row exists.
  Future<Entity?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Entity>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Entity]s in the list and returns the inserted rows.
  ///
  /// The returned [Entity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> insert(
    _is.DatabaseSession session,
    List<Entity> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Entity>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Entity] and returns the inserted row.
  ///
  /// The returned [Entity] will have its `id` field set.
  Future<Entity> insertRow(
    _is.DatabaseSession session,
    Entity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Entity>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Entity]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Entity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> upsert(
    _is.DatabaseSession session,
    List<Entity> rows, {
    required _is.ColumnSelections<EntityTable> conflictColumns,
    _is.ColumnSelections<EntityTable>? updateColumns,
    _is.WhereExpressionBuilder<EntityTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Entity>(
      rows,
      conflictColumns: conflictColumns(Entity.t),
      updateColumns: updateColumns?.call(Entity.t),
      updateWhere: updateWhere?.call(Entity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Entity] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Entity] will have its `id` field set.
  Future<Entity?> upsertRow(
    _is.DatabaseSession session,
    Entity row, {
    required _is.ColumnSelections<EntityTable> conflictColumns,
    _is.ColumnSelections<EntityTable>? updateColumns,
    _is.WhereExpressionBuilder<EntityTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Entity>(
      row,
      conflictColumns: conflictColumns(Entity.t),
      updateColumns: updateColumns?.call(Entity.t),
      updateWhere: updateWhere?.call(Entity.t),
      transaction: transaction,
    );
  }

  /// Updates all [Entity]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> update(
    _is.DatabaseSession session,
    List<Entity> rows, {
    _is.ColumnSelections<EntityTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Entity>(
      rows,
      columns: columns?.call(Entity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Entity]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Entity> updateRow(
    _is.DatabaseSession session,
    Entity row, {
    _is.ColumnSelections<EntityTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Entity>(
      row,
      columns: columns?.call(Entity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Entity] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Entity?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<EntityUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Entity>(
      id,
      columnValues: columnValues(Entity.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Entity]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EntityUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EntityTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Entity>(
      columnValues: columnValues(Entity.t.updateTable),
      where: where(Entity.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Entity]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> delete(
    _is.DatabaseSession session,
    List<Entity> rows, {
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Entity>(
      rows,
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Entity].
  Future<Entity> deleteRow(
    _is.DatabaseSession session,
    Entity row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Entity>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entity>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EntityTable> where,
    _is.OrderByBuilder<EntityTable>? orderBy,
    _is.OrderByListBuilder<EntityTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Entity>(
      where: where(Entity.t),
      orderBy: orderBy?.call(Entity.t),
      orderByList: orderByList?.call(Entity.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntityTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Entity>(
      where: where?.call(Entity.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Entity] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EntityTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Entity>(
      where: where(Entity.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
