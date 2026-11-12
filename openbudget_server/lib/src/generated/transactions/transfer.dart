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

/// Links the two legs of a move between two accounts.
abstract class Transfer
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Transfer._({
    this.id,
    required this.fromTransactionId,
    required this.toTransactionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Transfer({
    _is.UuidValue? id,
    required _is.UuidValue fromTransactionId,
    required _is.UuidValue toTransactionId,
    DateTime? createdAt,
  }) = _TransferImpl;

  factory Transfer.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transfer(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      fromTransactionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['fromTransactionId'],
      ),
      toTransactionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['toTransactionId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TransferTable();

  static const db = TransferRepository._();

  @override
  _is.UuidValue? id;

  /// The outflow leg.
  _is.UuidValue fromTransactionId;

  /// The inflow leg.
  _is.UuidValue toTransactionId;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Transfer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Transfer copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? fromTransactionId,
    _is.UuidValue? toTransactionId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transfer',
      if (id != null) 'id': id?.toJson(),
      'fromTransactionId': fromTransactionId.toJson(),
      'toTransactionId': toTransactionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transfer',
      if (id != null) 'id': id?.toJson(),
      'fromTransactionId': fromTransactionId.toJson(),
      'toTransactionId': toTransactionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static TransferInclude include() {
    return TransferInclude._();
  }

  static TransferIncludeList includeList({
    _is.WhereExpressionBuilder<TransferTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    TransferInclude? include,
  }) {
    return TransferIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TransferImpl extends Transfer {
  _TransferImpl({
    _is.UuidValue? id,
    required _is.UuidValue fromTransactionId,
    required _is.UuidValue toTransactionId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         fromTransactionId: fromTransactionId,
         toTransactionId: toTransactionId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Transfer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Transfer copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? fromTransactionId,
    _is.UuidValue? toTransactionId,
    DateTime? createdAt,
  }) {
    return Transfer(
      id: id is _is.UndefinedSentinel ? this.id : id,
      fromTransactionId: fromTransactionId ?? this.fromTransactionId,
      toTransactionId: toTransactionId ?? this.toTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransferUpdateTable extends _is.UpdateTable<TransferTable> {
  TransferUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> fromTransactionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.fromTransactionId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> toTransactionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.toTransactionId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TransferTable extends _is.Table<_is.UuidValue?> {
  TransferTable({super.tableRelation}) : super(tableName: 'transfer') {
    updateTable = TransferUpdateTable(this);
    fromTransactionId = _is.ColumnUuid(
      'fromTransactionId',
      this,
    );
    toTransactionId = _is.ColumnUuid(
      'toTransactionId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TransferUpdateTable updateTable;

  /// The outflow leg.
  late final _is.ColumnUuid fromTransactionId;

  /// The inflow leg.
  late final _is.ColumnUuid toTransactionId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    fromTransactionId,
    toTransactionId,
    createdAt,
  ];
}

class TransferInclude extends _is.IncludeObject {
  TransferInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Transfer.t;
}

class TransferIncludeList extends _is.IncludeList {
  TransferIncludeList._({
    _is.WhereExpressionBuilder<TransferTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Transfer.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Transfer.t;
}

class TransferRepository {
  const TransferRepository._();

  /// Returns a list of [Transfer]s matching the given query parameters.
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
  Future<List<Transfer>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransferTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Transfer>(
      where: where?.call(Transfer.t),
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Transfer]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Transfer.t`.
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
  _ida.Stream<List<Transfer>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransferTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Transfer>(
      where: where?.call(Transfer.t),
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Transfer] matching the given query parameters.
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
  Future<Transfer?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransferTable>? where,
    int? offset,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Transfer>(
      where: where?.call(Transfer.t),
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Transfer] by its [id] or null if no such row exists.
  Future<Transfer?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Transfer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Transfer]s in the list and returns the inserted rows.
  ///
  /// The returned [Transfer]s will have their `id` fields set.
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
  Future<List<Transfer>> insert(
    _is.DatabaseSession session,
    List<Transfer> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Transfer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Transfer] and returns the inserted row.
  ///
  /// The returned [Transfer] will have its `id` field set.
  Future<Transfer> insertRow(
    _is.DatabaseSession session,
    Transfer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Transfer>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Transfer]s in the list and returns the resulting rows.
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
  /// The returned [Transfer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transfer>> upsert(
    _is.DatabaseSession session,
    List<Transfer> rows, {
    required _is.ColumnSelections<TransferTable> conflictColumns,
    _is.ColumnSelections<TransferTable>? updateColumns,
    _is.WhereExpressionBuilder<TransferTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Transfer>(
      rows,
      conflictColumns: conflictColumns(Transfer.t),
      updateColumns: updateColumns?.call(Transfer.t),
      updateWhere: updateWhere?.call(Transfer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Transfer] and returns the resulting row.
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
  /// The returned [Transfer] will have its `id` field set.
  Future<Transfer?> upsertRow(
    _is.DatabaseSession session,
    Transfer row, {
    required _is.ColumnSelections<TransferTable> conflictColumns,
    _is.ColumnSelections<TransferTable>? updateColumns,
    _is.WhereExpressionBuilder<TransferTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Transfer>(
      row,
      conflictColumns: conflictColumns(Transfer.t),
      updateColumns: updateColumns?.call(Transfer.t),
      updateWhere: updateWhere?.call(Transfer.t),
      transaction: transaction,
    );
  }

  /// Updates all [Transfer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transfer>> update(
    _is.DatabaseSession session,
    List<Transfer> rows, {
    _is.ColumnSelections<TransferTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Transfer>(
      rows,
      columns: columns?.call(Transfer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Transfer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Transfer> updateRow(
    _is.DatabaseSession session,
    Transfer row, {
    _is.ColumnSelections<TransferTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Transfer>(
      row,
      columns: columns?.call(Transfer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Transfer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Transfer?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TransferUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Transfer>(
      id,
      columnValues: columnValues(Transfer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Transfer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transfer>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TransferUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TransferTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Transfer>(
      columnValues: columnValues(Transfer.t.updateTable),
      where: where(Transfer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Transfer]s in the list and returns the deleted rows.
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
  Future<List<Transfer>> delete(
    _is.DatabaseSession session,
    List<Transfer> rows, {
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Transfer>(
      rows,
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Transfer].
  Future<Transfer> deleteRow(
    _is.DatabaseSession session,
    Transfer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Transfer>(
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
  Future<List<Transfer>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransferTable> where,
    _is.OrderByBuilder<TransferTable>? orderBy,
    _is.OrderByListBuilder<TransferTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Transfer>(
      where: where(Transfer.t),
      orderBy: orderBy?.call(Transfer.t),
      orderByList: orderByList?.call(Transfer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransferTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Transfer>(
      where: where?.call(Transfer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Transfer] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransferTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Transfer>(
      where: where(Transfer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
