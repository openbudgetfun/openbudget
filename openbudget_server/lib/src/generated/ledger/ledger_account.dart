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

/// One account in an entity's double-entry chart of accounts.
///
/// Codes are user-visible labels; nothing keys on them. Accounts with a
/// systemRole are structural: one per role, never archived.
abstract class LedgerAccount
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue entityId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = LedgerAccountTable();

  static const db = LedgerAccountRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

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

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [LedgerAccount]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LedgerAccount copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? code,
    String? name,
    _ifz8weqz.LedgerAccountType? type,
    _ifz8weqz.LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
    DateTime? archivedAt = const _is.$UndefinedDateTime(),
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

  static LedgerAccountInclude include() {
    return LedgerAccountInclude._();
  }

  static LedgerAccountIncludeList includeList({
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    LedgerAccountInclude? include,
  }) {
    return LedgerAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LedgerAccountImpl extends LedgerAccount {
  _LedgerAccountImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
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
  @_is.useResult
  @override
  LedgerAccount copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? code,
    String? name,
    _ifz8weqz.LedgerAccountType? type,
    Object? systemRole = _Undefined,
    Object? currencyCode = _Undefined,
    Object? taxCategoryCode = _Undefined,
    DateTime? archivedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
  }) {
    return LedgerAccount(
      id: id is _is.UndefinedSentinel ? this.id : id,
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
      archivedAt: archivedAt is _is.UndefinedSentinel
          ? this.archivedAt
          : archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LedgerAccountUpdateTable extends _is.UpdateTable<LedgerAccountTable> {
  LedgerAccountUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_ifz8weqz.LedgerAccountType, _ifz8weqz.LedgerAccountType>
  type(_ifz8weqz.LedgerAccountType value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<_ifz8weqz.LedgerSystemRole, _ifz8weqz.LedgerSystemRole>
  systemRole(_ifz8weqz.LedgerSystemRole? value) => _is.ColumnValue(
    table.systemRole,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String? value) =>
      _is.ColumnValue(
        table.currencyCode,
        value,
      );

  _is.ColumnValue<String, String> taxCategoryCode(String? value) =>
      _is.ColumnValue(
        table.taxCategoryCode,
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
}

class LedgerAccountTable extends _is.Table<_is.UuidValue?> {
  LedgerAccountTable({super.tableRelation})
    : super(tableName: 'ledger_account') {
    updateTable = LedgerAccountUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    code = _is.ColumnString(
      'code',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    type = _is.ColumnEnum(
      'type',
      this,
      _is.EnumSerialization.byName,
    );
    systemRole = _is.ColumnEnum(
      'systemRole',
      this,
      _is.EnumSerialization.byName,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    taxCategoryCode = _is.ColumnString(
      'taxCategoryCode',
      this,
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
  }

  late final LedgerAccountUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  /// Code from the template chart, unique per entity.
  late final _is.ColumnString code;

  late final _is.ColumnString name;

  late final _is.ColumnEnum<_ifz8weqz.LedgerAccountType> type;

  late final _is.ColumnEnum<_ifz8weqz.LedgerSystemRole> systemRole;

  /// ISO 4217 code for foreign-currency bank and control accounts.
  late final _is.ColumnString currencyCode;

  /// Tax category feeding the tax engine.
  late final _is.ColumnString taxCategoryCode;

  /// Archived accounts keep their lines but accept no new postings.
  late final _is.ColumnDateTime archivedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    code,
    name,
    type,
    systemRole,
    currencyCode,
    taxCategoryCode,
    archivedAt,
    createdAt,
  ];
}

class LedgerAccountInclude extends _is.IncludeObject {
  LedgerAccountInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => LedgerAccount.t;
}

class LedgerAccountIncludeList extends _is.IncludeList {
  LedgerAccountIncludeList._({
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LedgerAccount.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => LedgerAccount.t;
}

class LedgerAccountRepository {
  const LedgerAccountRepository._();

  /// Returns a list of [LedgerAccount]s matching the given query parameters.
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
  Future<List<LedgerAccount>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LedgerAccount>(
      where: where?.call(LedgerAccount.t),
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [LedgerAccount]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `LedgerAccount.t`.
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
  _ida.Stream<List<LedgerAccount>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<LedgerAccount>(
      where: where?.call(LedgerAccount.t),
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [LedgerAccount] matching the given query parameters.
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
  Future<LedgerAccount?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    int? offset,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LedgerAccount>(
      where: where?.call(LedgerAccount.t),
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LedgerAccount] by its [id] or null if no such row exists.
  Future<LedgerAccount?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LedgerAccount>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LedgerAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [LedgerAccount]s will have their `id` fields set.
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
  Future<List<LedgerAccount>> insert(
    _is.DatabaseSession session,
    List<LedgerAccount> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LedgerAccount>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LedgerAccount] and returns the inserted row.
  ///
  /// The returned [LedgerAccount] will have its `id` field set.
  Future<LedgerAccount> insertRow(
    _is.DatabaseSession session,
    LedgerAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LedgerAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LedgerAccount]s in the list and returns the resulting rows.
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
  /// The returned [LedgerAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAccount>> upsert(
    _is.DatabaseSession session,
    List<LedgerAccount> rows, {
    required _is.ColumnSelections<LedgerAccountTable> conflictColumns,
    _is.ColumnSelections<LedgerAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LedgerAccount>(
      rows,
      conflictColumns: conflictColumns(LedgerAccount.t),
      updateColumns: updateColumns?.call(LedgerAccount.t),
      updateWhere: updateWhere?.call(LedgerAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LedgerAccount] and returns the resulting row.
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
  /// The returned [LedgerAccount] will have its `id` field set.
  Future<LedgerAccount?> upsertRow(
    _is.DatabaseSession session,
    LedgerAccount row, {
    required _is.ColumnSelections<LedgerAccountTable> conflictColumns,
    _is.ColumnSelections<LedgerAccountTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LedgerAccount>(
      row,
      conflictColumns: conflictColumns(LedgerAccount.t),
      updateColumns: updateColumns?.call(LedgerAccount.t),
      updateWhere: updateWhere?.call(LedgerAccount.t),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAccount>> update(
    _is.DatabaseSession session,
    List<LedgerAccount> rows, {
    _is.ColumnSelections<LedgerAccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LedgerAccount>(
      rows,
      columns: columns?.call(LedgerAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LedgerAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LedgerAccount> updateRow(
    _is.DatabaseSession session,
    LedgerAccount row, {
    _is.ColumnSelections<LedgerAccountTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LedgerAccount>(
      row,
      columns: columns?.call(LedgerAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LedgerAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LedgerAccount?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<LedgerAccountUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LedgerAccount>(
      id,
      columnValues: columnValues(LedgerAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAccount>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LedgerAccountUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<LedgerAccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LedgerAccount>(
      columnValues: columnValues(LedgerAccount.t.updateTable),
      where: where(LedgerAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LedgerAccount]s in the list and returns the deleted rows.
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
  Future<List<LedgerAccount>> delete(
    _is.DatabaseSession session,
    List<LedgerAccount> rows, {
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LedgerAccount>(
      rows,
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LedgerAccount].
  Future<LedgerAccount> deleteRow(
    _is.DatabaseSession session,
    LedgerAccount row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LedgerAccount>(
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
  Future<List<LedgerAccount>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAccountTable> where,
    _is.OrderByBuilder<LedgerAccountTable>? orderBy,
    _is.OrderByListBuilder<LedgerAccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LedgerAccount>(
      where: where(LedgerAccount.t),
      orderBy: orderBy?.call(LedgerAccount.t),
      orderByList: orderByList?.call(LedgerAccount.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LedgerAccount>(
      where: where?.call(LedgerAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LedgerAccount] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LedgerAccount>(
      where: where(LedgerAccount.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
