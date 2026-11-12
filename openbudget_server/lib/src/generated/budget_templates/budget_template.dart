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

import 'package:serverpod/serverpod.dart' as _is;

/// A saved set of allocations that can be applied to any month.
abstract class BudgetTemplate
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  BudgetTemplate._({
    this.id,
    required this.entityId,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BudgetTemplate({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetTemplateImpl;

  factory BudgetTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetTemplate(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = BudgetTemplateTable();

  static const db = BudgetTemplateRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  /// User-chosen name, such as "Standard month".
  String name;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BudgetTemplate copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetTemplate',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetTemplate',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static BudgetTemplateInclude include() {
    return BudgetTemplateInclude._();
  }

  static BudgetTemplateIncludeList includeList({
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    BudgetTemplateInclude? include,
  }) {
    return BudgetTemplateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _BudgetTemplateImpl extends BudgetTemplate {
  _BudgetTemplateImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         name: name,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BudgetTemplate copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetTemplate(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetTemplateUpdateTable extends _is.UpdateTable<BudgetTemplateTable> {
  BudgetTemplateUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
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

class BudgetTemplateTable extends _is.Table<_is.UuidValue?> {
  BudgetTemplateTable({super.tableRelation})
    : super(tableName: 'budget_template') {
    updateTable = BudgetTemplateUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    name = _is.ColumnString(
      'name',
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

  late final BudgetTemplateUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  /// User-chosen name, such as "Standard month".
  late final _is.ColumnString name;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    name,
    createdAt,
    updatedAt,
  ];
}

class BudgetTemplateInclude extends _is.IncludeObject {
  BudgetTemplateInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => BudgetTemplate.t;
}

class BudgetTemplateIncludeList extends _is.IncludeList {
  BudgetTemplateIncludeList._({
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BudgetTemplate.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => BudgetTemplate.t;
}

class BudgetTemplateRepository {
  const BudgetTemplateRepository._();

  /// Returns a list of [BudgetTemplate]s matching the given query parameters.
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
  Future<List<BudgetTemplate>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [BudgetTemplate]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `BudgetTemplate.t`.
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
  _ida.Stream<List<BudgetTemplate>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [BudgetTemplate] matching the given query parameters.
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
  Future<BudgetTemplate?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BudgetTemplate] by its [id] or null if no such row exists.
  Future<BudgetTemplate?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BudgetTemplate>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BudgetTemplate]s in the list and returns the inserted rows.
  ///
  /// The returned [BudgetTemplate]s will have their `id` fields set.
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
  Future<List<BudgetTemplate>> insert(
    _is.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BudgetTemplate>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BudgetTemplate] and returns the inserted row.
  ///
  /// The returned [BudgetTemplate] will have its `id` field set.
  Future<BudgetTemplate> insertRow(
    _is.DatabaseSession session,
    BudgetTemplate row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BudgetTemplate>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BudgetTemplate]s in the list and returns the resulting rows.
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
  /// The returned [BudgetTemplate]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplate>> upsert(
    _is.DatabaseSession session,
    List<BudgetTemplate> rows, {
    required _is.ColumnSelections<BudgetTemplateTable> conflictColumns,
    _is.ColumnSelections<BudgetTemplateTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTemplateTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BudgetTemplate>(
      rows,
      conflictColumns: conflictColumns(BudgetTemplate.t),
      updateColumns: updateColumns?.call(BudgetTemplate.t),
      updateWhere: updateWhere?.call(BudgetTemplate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BudgetTemplate] and returns the resulting row.
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
  /// The returned [BudgetTemplate] will have its `id` field set.
  Future<BudgetTemplate?> upsertRow(
    _is.DatabaseSession session,
    BudgetTemplate row, {
    required _is.ColumnSelections<BudgetTemplateTable> conflictColumns,
    _is.ColumnSelections<BudgetTemplateTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTemplateTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BudgetTemplate>(
      row,
      conflictColumns: conflictColumns(BudgetTemplate.t),
      updateColumns: updateColumns?.call(BudgetTemplate.t),
      updateWhere: updateWhere?.call(BudgetTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates all [BudgetTemplate]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplate>> update(
    _is.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _is.ColumnSelections<BudgetTemplateTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BudgetTemplate>(
      rows,
      columns: columns?.call(BudgetTemplate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BudgetTemplate]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BudgetTemplate> updateRow(
    _is.DatabaseSession session,
    BudgetTemplate row, {
    _is.ColumnSelections<BudgetTemplateTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BudgetTemplate>(
      row,
      columns: columns?.call(BudgetTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BudgetTemplate] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BudgetTemplate?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<BudgetTemplateUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BudgetTemplate>(
      id,
      columnValues: columnValues(BudgetTemplate.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BudgetTemplate]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplate>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BudgetTemplateUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BudgetTemplateTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BudgetTemplate>(
      columnValues: columnValues(BudgetTemplate.t.updateTable),
      where: where(BudgetTemplate.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BudgetTemplate]s in the list and returns the deleted rows.
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
  Future<List<BudgetTemplate>> delete(
    _is.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BudgetTemplate>(
      rows,
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BudgetTemplate].
  Future<BudgetTemplate> deleteRow(
    _is.DatabaseSession session,
    BudgetTemplate row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BudgetTemplate>(
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
  Future<List<BudgetTemplate>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTemplateTable> where,
    _is.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BudgetTemplate>(
      where: where(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BudgetTemplate] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTemplateTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BudgetTemplate>(
      where: where(BudgetTemplate.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
