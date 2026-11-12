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

/// Money assigned to an envelope for one month. The only stored figure of
/// the envelope plan; activity, carryover and available are derived.
abstract class MonthlyAllocation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  MonthlyAllocation._({
    this.id,
    required this.entityId,
    required this.envelopeId,
    required this.month,
    required this.allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MonthlyAllocation({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue envelopeId,
    required int month,
    required int allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonthlyAllocationImpl;

  factory MonthlyAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlyAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      envelopeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      month: jsonSerialization['month'] as int,
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = MonthlyAllocationTable();

  static const db = MonthlyAllocationRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  _is.UuidValue envelopeId;

  /// Budget month as yyyymm, such as 202611.
  int month;

  /// Assigned amount in base-currency minor units. Negative when more was
  /// moved out than was assigned this month. Never 0: a zero deletes the row.
  int allocatedMinor;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MonthlyAllocation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? envelopeId,
    int? month,
    int? allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'month': month,
      'allocatedMinor': allocatedMinor,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'month': month,
      'allocatedMinor': allocatedMinor,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MonthlyAllocationInclude include() {
    return MonthlyAllocationInclude._();
  }

  static MonthlyAllocationIncludeList includeList({
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    MonthlyAllocationInclude? include,
  }) {
    return MonthlyAllocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _MonthlyAllocationImpl extends MonthlyAllocation {
  _MonthlyAllocationImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue envelopeId,
    required int month,
    required int allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         envelopeId: envelopeId,
         month: month,
         allocatedMinor: allocatedMinor,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MonthlyAllocation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? envelopeId,
    int? month,
    int? allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyAllocation(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      envelopeId: envelopeId ?? this.envelopeId,
      month: month ?? this.month,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MonthlyAllocationUpdateTable
    extends _is.UpdateTable<MonthlyAllocationTable> {
  MonthlyAllocationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> envelopeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.envelopeId,
    value,
  );

  _is.ColumnValue<int, int> month(int value) => _is.ColumnValue(
    table.month,
    value,
  );

  _is.ColumnValue<int, int> allocatedMinor(int value) => _is.ColumnValue(
    table.allocatedMinor,
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

class MonthlyAllocationTable extends _is.Table<_is.UuidValue?> {
  MonthlyAllocationTable({super.tableRelation})
    : super(tableName: 'monthly_allocation') {
    updateTable = MonthlyAllocationUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    envelopeId = _is.ColumnUuid(
      'envelopeId',
      this,
    );
    month = _is.ColumnInt(
      'month',
      this,
    );
    allocatedMinor = _is.ColumnInt(
      'allocatedMinor',
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

  late final MonthlyAllocationUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnUuid envelopeId;

  /// Budget month as yyyymm, such as 202611.
  late final _is.ColumnInt month;

  /// Assigned amount in base-currency minor units. Negative when more was
  /// moved out than was assigned this month. Never 0: a zero deletes the row.
  late final _is.ColumnInt allocatedMinor;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    envelopeId,
    month,
    allocatedMinor,
    createdAt,
    updatedAt,
  ];
}

class MonthlyAllocationInclude extends _is.IncludeObject {
  MonthlyAllocationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => MonthlyAllocation.t;
}

class MonthlyAllocationIncludeList extends _is.IncludeList {
  MonthlyAllocationIncludeList._({
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MonthlyAllocation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => MonthlyAllocation.t;
}

class MonthlyAllocationRepository {
  const MonthlyAllocationRepository._();

  /// Returns a list of [MonthlyAllocation]s matching the given query parameters.
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
  Future<List<MonthlyAllocation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [MonthlyAllocation]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `MonthlyAllocation.t`.
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
  _ida.Stream<List<MonthlyAllocation>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [MonthlyAllocation] matching the given query parameters.
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
  Future<MonthlyAllocation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? offset,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MonthlyAllocation] by its [id] or null if no such row exists.
  Future<MonthlyAllocation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MonthlyAllocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MonthlyAllocation]s in the list and returns the inserted rows.
  ///
  /// The returned [MonthlyAllocation]s will have their `id` fields set.
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
  Future<List<MonthlyAllocation>> insert(
    _is.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MonthlyAllocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MonthlyAllocation] and returns the inserted row.
  ///
  /// The returned [MonthlyAllocation] will have its `id` field set.
  Future<MonthlyAllocation> insertRow(
    _is.DatabaseSession session,
    MonthlyAllocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MonthlyAllocation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MonthlyAllocation]s in the list and returns the resulting rows.
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
  /// The returned [MonthlyAllocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MonthlyAllocation>> upsert(
    _is.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    required _is.ColumnSelections<MonthlyAllocationTable> conflictColumns,
    _is.ColumnSelections<MonthlyAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MonthlyAllocation>(
      rows,
      conflictColumns: conflictColumns(MonthlyAllocation.t),
      updateColumns: updateColumns?.call(MonthlyAllocation.t),
      updateWhere: updateWhere?.call(MonthlyAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MonthlyAllocation] and returns the resulting row.
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
  /// The returned [MonthlyAllocation] will have its `id` field set.
  Future<MonthlyAllocation?> upsertRow(
    _is.DatabaseSession session,
    MonthlyAllocation row, {
    required _is.ColumnSelections<MonthlyAllocationTable> conflictColumns,
    _is.ColumnSelections<MonthlyAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MonthlyAllocation>(
      row,
      conflictColumns: conflictColumns(MonthlyAllocation.t),
      updateColumns: updateColumns?.call(MonthlyAllocation.t),
      updateWhere: updateWhere?.call(MonthlyAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates all [MonthlyAllocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MonthlyAllocation>> update(
    _is.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _is.ColumnSelections<MonthlyAllocationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MonthlyAllocation>(
      rows,
      columns: columns?.call(MonthlyAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MonthlyAllocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MonthlyAllocation> updateRow(
    _is.DatabaseSession session,
    MonthlyAllocation row, {
    _is.ColumnSelections<MonthlyAllocationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MonthlyAllocation>(
      row,
      columns: columns?.call(MonthlyAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MonthlyAllocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MonthlyAllocation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<MonthlyAllocationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MonthlyAllocation>(
      id,
      columnValues: columnValues(MonthlyAllocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MonthlyAllocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MonthlyAllocation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MonthlyAllocationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<MonthlyAllocationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MonthlyAllocation>(
      columnValues: columnValues(MonthlyAllocation.t.updateTable),
      where: where(MonthlyAllocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MonthlyAllocation]s in the list and returns the deleted rows.
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
  Future<List<MonthlyAllocation>> delete(
    _is.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MonthlyAllocation>(
      rows,
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MonthlyAllocation].
  Future<MonthlyAllocation> deleteRow(
    _is.DatabaseSession session,
    MonthlyAllocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MonthlyAllocation>(
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
  Future<List<MonthlyAllocation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MonthlyAllocationTable> where,
    _is.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _is.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MonthlyAllocation>(
      where: where(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MonthlyAllocation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MonthlyAllocationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MonthlyAllocation>(
      where: where(MonthlyAllocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
