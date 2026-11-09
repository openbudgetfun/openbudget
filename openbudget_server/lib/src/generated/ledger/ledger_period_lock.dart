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

/// The per-entity period lock date.
///
/// Posting, reversing or editing a transaction dated on or before lockDate
/// is rejected. Every change writes an audit_event, so the lock's history
/// lives in the audit trail.
abstract class LedgerPeriodLock
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  LedgerPeriodLock._({
    this.id,
    required this.entityId,
    required this.lockDate,
    required this.setBy,
    DateTime? setAt,
  }) : setAt = setAt ?? DateTime.now();

  factory LedgerPeriodLock({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required DateTime lockDate,
    required _is.UuidValue setBy,
    DateTime? setAt,
  }) = _LedgerPeriodLockImpl;

  factory LedgerPeriodLock.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerPeriodLock(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      lockDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lockDate'],
      ),
      setBy: _is.UuidValueJsonExtension.fromJson(jsonSerialization['setBy']),
      setAt: jsonSerialization['setAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['setAt']),
    );
  }

  static final t = LedgerPeriodLockTable();

  static const db = LedgerPeriodLockRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  /// Calendar dates on or before this one are locked.
  DateTime lockDate;

  _is.UuidValue setBy;

  DateTime setAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [LedgerPeriodLock]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LedgerPeriodLock copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    DateTime? lockDate,
    _is.UuidValue? setBy,
    DateTime? setAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerPeriodLock',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'lockDate': lockDate.toJson(),
      'setBy': setBy.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerPeriodLock',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'lockDate': lockDate.toJson(),
      'setBy': setBy.toJson(),
      'setAt': setAt.toJson(),
    };
  }

  static LedgerPeriodLockInclude include() {
    return LedgerPeriodLockInclude._();
  }

  static LedgerPeriodLockIncludeList includeList({
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    LedgerPeriodLockInclude? include,
  }) {
    return LedgerPeriodLockIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _LedgerPeriodLockImpl extends LedgerPeriodLock {
  _LedgerPeriodLockImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required DateTime lockDate,
    required _is.UuidValue setBy,
    DateTime? setAt,
  }) : super._(
         id: id,
         entityId: entityId,
         lockDate: lockDate,
         setBy: setBy,
         setAt: setAt,
       );

  /// Returns a shallow copy of this [LedgerPeriodLock]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LedgerPeriodLock copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    DateTime? lockDate,
    _is.UuidValue? setBy,
    DateTime? setAt,
  }) {
    return LedgerPeriodLock(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      lockDate: lockDate ?? this.lockDate,
      setBy: setBy ?? this.setBy,
      setAt: setAt ?? this.setAt,
    );
  }
}

class LedgerPeriodLockUpdateTable
    extends _is.UpdateTable<LedgerPeriodLockTable> {
  LedgerPeriodLockUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lockDate(DateTime value) =>
      _is.ColumnValue(
        table.lockDate,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> setBy(_is.UuidValue value) =>
      _is.ColumnValue(
        table.setBy,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> setAt(DateTime value) => _is.ColumnValue(
    table.setAt,
    value,
  );
}

class LedgerPeriodLockTable extends _is.Table<_is.UuidValue?> {
  LedgerPeriodLockTable({super.tableRelation})
    : super(tableName: 'ledger_period_lock') {
    updateTable = LedgerPeriodLockUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    lockDate = _is.ColumnDateTime(
      'lockDate',
      this,
    );
    setBy = _is.ColumnUuid(
      'setBy',
      this,
    );
    setAt = _is.ColumnDateTime(
      'setAt',
      this,
      hasDefault: true,
    );
  }

  late final LedgerPeriodLockUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  /// Calendar dates on or before this one are locked.
  late final _is.ColumnDateTime lockDate;

  late final _is.ColumnUuid setBy;

  late final _is.ColumnDateTime setAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    lockDate,
    setBy,
    setAt,
  ];
}

class LedgerPeriodLockInclude extends _is.IncludeObject {
  LedgerPeriodLockInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => LedgerPeriodLock.t;
}

class LedgerPeriodLockIncludeList extends _is.IncludeList {
  LedgerPeriodLockIncludeList._({
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LedgerPeriodLock.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => LedgerPeriodLock.t;
}

class LedgerPeriodLockRepository {
  const LedgerPeriodLockRepository._();

  /// Returns a list of [LedgerPeriodLock]s matching the given query parameters.
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
  Future<List<LedgerPeriodLock>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LedgerPeriodLock>(
      where: where?.call(LedgerPeriodLock.t),
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [LedgerPeriodLock]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `LedgerPeriodLock.t`.
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
  _ida.Stream<List<LedgerPeriodLock>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<LedgerPeriodLock>(
      where: where?.call(LedgerPeriodLock.t),
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [LedgerPeriodLock] matching the given query parameters.
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
  Future<LedgerPeriodLock?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    int? offset,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LedgerPeriodLock>(
      where: where?.call(LedgerPeriodLock.t),
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LedgerPeriodLock] by its [id] or null if no such row exists.
  Future<LedgerPeriodLock?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LedgerPeriodLock>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LedgerPeriodLock]s in the list and returns the inserted rows.
  ///
  /// The returned [LedgerPeriodLock]s will have their `id` fields set.
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
  Future<List<LedgerPeriodLock>> insert(
    _is.DatabaseSession session,
    List<LedgerPeriodLock> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LedgerPeriodLock>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LedgerPeriodLock] and returns the inserted row.
  ///
  /// The returned [LedgerPeriodLock] will have its `id` field set.
  Future<LedgerPeriodLock> insertRow(
    _is.DatabaseSession session,
    LedgerPeriodLock row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LedgerPeriodLock>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LedgerPeriodLock]s in the list and returns the resulting rows.
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
  /// The returned [LedgerPeriodLock]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerPeriodLock>> upsert(
    _is.DatabaseSession session,
    List<LedgerPeriodLock> rows, {
    required _is.ColumnSelections<LedgerPeriodLockTable> conflictColumns,
    _is.ColumnSelections<LedgerPeriodLockTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LedgerPeriodLock>(
      rows,
      conflictColumns: conflictColumns(LedgerPeriodLock.t),
      updateColumns: updateColumns?.call(LedgerPeriodLock.t),
      updateWhere: updateWhere?.call(LedgerPeriodLock.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LedgerPeriodLock] and returns the resulting row.
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
  /// The returned [LedgerPeriodLock] will have its `id` field set.
  Future<LedgerPeriodLock?> upsertRow(
    _is.DatabaseSession session,
    LedgerPeriodLock row, {
    required _is.ColumnSelections<LedgerPeriodLockTable> conflictColumns,
    _is.ColumnSelections<LedgerPeriodLockTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LedgerPeriodLock>(
      row,
      conflictColumns: conflictColumns(LedgerPeriodLock.t),
      updateColumns: updateColumns?.call(LedgerPeriodLock.t),
      updateWhere: updateWhere?.call(LedgerPeriodLock.t),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerPeriodLock]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerPeriodLock>> update(
    _is.DatabaseSession session,
    List<LedgerPeriodLock> rows, {
    _is.ColumnSelections<LedgerPeriodLockTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LedgerPeriodLock>(
      rows,
      columns: columns?.call(LedgerPeriodLock.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LedgerPeriodLock]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LedgerPeriodLock> updateRow(
    _is.DatabaseSession session,
    LedgerPeriodLock row, {
    _is.ColumnSelections<LedgerPeriodLockTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LedgerPeriodLock>(
      row,
      columns: columns?.call(LedgerPeriodLock.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LedgerPeriodLock] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LedgerPeriodLock?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<LedgerPeriodLockUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LedgerPeriodLock>(
      id,
      columnValues: columnValues(LedgerPeriodLock.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerPeriodLock]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerPeriodLock>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LedgerPeriodLockUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<LedgerPeriodLockTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LedgerPeriodLock>(
      columnValues: columnValues(LedgerPeriodLock.t.updateTable),
      where: where(LedgerPeriodLock.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LedgerPeriodLock]s in the list and returns the deleted rows.
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
  Future<List<LedgerPeriodLock>> delete(
    _is.DatabaseSession session,
    List<LedgerPeriodLock> rows, {
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LedgerPeriodLock>(
      rows,
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LedgerPeriodLock].
  Future<LedgerPeriodLock> deleteRow(
    _is.DatabaseSession session,
    LedgerPeriodLock row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LedgerPeriodLock>(
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
  Future<List<LedgerPeriodLock>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerPeriodLockTable> where,
    _is.OrderByBuilder<LedgerPeriodLockTable>? orderBy,
    _is.OrderByListBuilder<LedgerPeriodLockTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LedgerPeriodLock>(
      where: where(LedgerPeriodLock.t),
      orderBy: orderBy?.call(LedgerPeriodLock.t),
      orderByList: orderByList?.call(LedgerPeriodLock.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerPeriodLockTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LedgerPeriodLock>(
      where: where?.call(LedgerPeriodLock.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LedgerPeriodLock] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerPeriodLockTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LedgerPeriodLock>(
      where: where(LedgerPeriodLock.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
