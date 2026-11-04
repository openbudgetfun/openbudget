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

/// Individual currency exchange rate value in a snapshot.
abstract class FxRateEntry
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  FxRateEntry._({
    this.id,
    required this.snapshotId,
    required this.currencyCode,
    required this.rate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FxRateEntry({
    _is.UuidValue? id,
    required _is.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) = _FxRateEntryImpl;

  factory FxRateEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      snapshotId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['snapshotId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      rate: (jsonSerialization['rate'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FxRateEntryTable();

  static const db = FxRateEntryRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue snapshotId;

  String currencyCode;

  double rate;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxRateEntry copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateEntry',
      if (id != null) 'id': id?.toJson(),
      'snapshotId': snapshotId.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateEntry',
      if (id != null) 'id': id?.toJson(),
      'snapshotId': snapshotId.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'createdAt': createdAt.toJson(),
    };
  }

  static FxRateEntryInclude include() {
    return FxRateEntryInclude._();
  }

  static FxRateEntryIncludeList includeList({
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    FxRateEntryInclude? include,
  }) {
    return FxRateEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxRateEntryImpl extends FxRateEntry {
  _FxRateEntryImpl({
    _is.UuidValue? id,
    required _is.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) : super._(
         id: id,
         snapshotId: snapshotId,
         currencyCode: currencyCode,
         rate: rate,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxRateEntry copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  }) {
    return FxRateEntry(
      id: id is _is.UndefinedSentinel ? this.id : id,
      snapshotId: snapshotId ?? this.snapshotId,
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FxRateEntryUpdateTable extends _is.UpdateTable<FxRateEntryTable> {
  FxRateEntryUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> snapshotId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.snapshotId,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<double, double> rate(double value) => _is.ColumnValue(
    table.rate,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class FxRateEntryTable extends _is.Table<_is.UuidValue?> {
  FxRateEntryTable({super.tableRelation}) : super(tableName: 'fx_rate_entry') {
    updateTable = FxRateEntryUpdateTable(this);
    snapshotId = _is.ColumnUuid(
      'snapshotId',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    rate = _is.ColumnDouble(
      'rate',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final FxRateEntryUpdateTable updateTable;

  late final _is.ColumnUuid snapshotId;

  late final _is.ColumnString currencyCode;

  late final _is.ColumnDouble rate;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    snapshotId,
    currencyCode,
    rate,
    createdAt,
  ];
}

class FxRateEntryInclude extends _is.IncludeObject {
  FxRateEntryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRateEntry.t;
}

class FxRateEntryIncludeList extends _is.IncludeList {
  FxRateEntryIncludeList._({
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxRateEntry.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRateEntry.t;
}

class FxRateEntryRepository {
  const FxRateEntryRepository._();

  /// Returns a list of [FxRateEntry]s matching the given query parameters.
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
  Future<List<FxRateEntry>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [FxRateEntry]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `FxRateEntry.t`.
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
  _ida.Stream<List<FxRateEntry>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [FxRateEntry] matching the given query parameters.
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
  Future<FxRateEntry?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? offset,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FxRateEntry] by its [id] or null if no such row exists.
  Future<FxRateEntry?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FxRateEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FxRateEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [FxRateEntry]s will have their `id` fields set.
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
  Future<List<FxRateEntry>> insert(
    _is.DatabaseSession session,
    List<FxRateEntry> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FxRateEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FxRateEntry] and returns the inserted row.
  ///
  /// The returned [FxRateEntry] will have its `id` field set.
  Future<FxRateEntry> insertRow(
    _is.DatabaseSession session,
    FxRateEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxRateEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FxRateEntry]s in the list and returns the resulting rows.
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
  /// The returned [FxRateEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateEntry>> upsert(
    _is.DatabaseSession session,
    List<FxRateEntry> rows, {
    required _is.ColumnSelections<FxRateEntryTable> conflictColumns,
    _is.ColumnSelections<FxRateEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateEntryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FxRateEntry>(
      rows,
      conflictColumns: conflictColumns(FxRateEntry.t),
      updateColumns: updateColumns?.call(FxRateEntry.t),
      updateWhere: updateWhere?.call(FxRateEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FxRateEntry] and returns the resulting row.
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
  /// The returned [FxRateEntry] will have its `id` field set.
  Future<FxRateEntry?> upsertRow(
    _is.DatabaseSession session,
    FxRateEntry row, {
    required _is.ColumnSelections<FxRateEntryTable> conflictColumns,
    _is.ColumnSelections<FxRateEntryTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateEntryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FxRateEntry>(
      row,
      conflictColumns: conflictColumns(FxRateEntry.t),
      updateColumns: updateColumns?.call(FxRateEntry.t),
      updateWhere: updateWhere?.call(FxRateEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateEntry>> update(
    _is.DatabaseSession session,
    List<FxRateEntry> rows, {
    _is.ColumnSelections<FxRateEntryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FxRateEntry>(
      rows,
      columns: columns?.call(FxRateEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FxRateEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxRateEntry> updateRow(
    _is.DatabaseSession session,
    FxRateEntry row, {
    _is.ColumnSelections<FxRateEntryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxRateEntry>(
      row,
      columns: columns?.call(FxRateEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxRateEntry?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<FxRateEntryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FxRateEntry>(
      id,
      columnValues: columnValues(FxRateEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateEntry>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FxRateEntryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FxRateEntryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FxRateEntry>(
      columnValues: columnValues(FxRateEntry.t.updateTable),
      where: where(FxRateEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FxRateEntry]s in the list and returns the deleted rows.
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
  Future<List<FxRateEntry>> delete(
    _is.DatabaseSession session,
    List<FxRateEntry> rows, {
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FxRateEntry>(
      rows,
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FxRateEntry].
  Future<FxRateEntry> deleteRow(
    _is.DatabaseSession session,
    FxRateEntry row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxRateEntry>(
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
  Future<List<FxRateEntry>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateEntryTable> where,
    _is.OrderByBuilder<FxRateEntryTable>? orderBy,
    _is.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FxRateEntry>(
      where: where(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FxRateEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateEntryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FxRateEntry>(
      where: where(FxRateEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
