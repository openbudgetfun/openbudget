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

/// Snapshot of exchange rates fetched from an upstream FX provider.
abstract class FxRateSnapshot
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  FxRateSnapshot._({
    this.id,
    required this.provider,
    required this.baseCurrencyCode,
    required this.fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : isLatest = isLatest ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory FxRateSnapshot({
    _is.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) = _FxRateSnapshotImpl;

  factory FxRateSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateSnapshot(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      provider: jsonSerialization['provider'] as String,
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      fetchedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isLatest: jsonSerialization['isLatest'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isLatest']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FxRateSnapshotTable();

  static const db = FxRateSnapshotRepository._();

  @override
  _is.UuidValue? id;

  String provider;

  String baseCurrencyCode;

  DateTime fetchedAt;

  bool isLatest;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxRateSnapshot copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateSnapshot',
      if (id != null) 'id': id?.toJson(),
      'provider': provider,
      'baseCurrencyCode': baseCurrencyCode,
      'fetchedAt': fetchedAt.toJson(),
      'isLatest': isLatest,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateSnapshot',
      if (id != null) 'id': id?.toJson(),
      'provider': provider,
      'baseCurrencyCode': baseCurrencyCode,
      'fetchedAt': fetchedAt.toJson(),
      'isLatest': isLatest,
      'createdAt': createdAt.toJson(),
    };
  }

  static FxRateSnapshotInclude include() {
    return FxRateSnapshotInclude._();
  }

  static FxRateSnapshotIncludeList includeList({
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    FxRateSnapshotInclude? include,
  }) {
    return FxRateSnapshotIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxRateSnapshotImpl extends FxRateSnapshot {
  _FxRateSnapshotImpl({
    _is.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : super._(
         id: id,
         provider: provider,
         baseCurrencyCode: baseCurrencyCode,
         fetchedAt: fetchedAt,
         isLatest: isLatest,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxRateSnapshot copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) {
    return FxRateSnapshot(
      id: id is _is.UndefinedSentinel ? this.id : id,
      provider: provider ?? this.provider,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLatest: isLatest ?? this.isLatest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FxRateSnapshotUpdateTable extends _is.UpdateTable<FxRateSnapshotTable> {
  FxRateSnapshotUpdateTable(super.table);

  _is.ColumnValue<String, String> provider(String value) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> baseCurrencyCode(String value) =>
      _is.ColumnValue(
        table.baseCurrencyCode,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _is.ColumnValue(
        table.fetchedAt,
        value,
      );

  _is.ColumnValue<bool, bool> isLatest(bool value) => _is.ColumnValue(
    table.isLatest,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class FxRateSnapshotTable extends _is.Table<_is.UuidValue?> {
  FxRateSnapshotTable({super.tableRelation})
    : super(tableName: 'fx_rate_snapshot') {
    updateTable = FxRateSnapshotUpdateTable(this);
    provider = _is.ColumnString(
      'provider',
      this,
    );
    baseCurrencyCode = _is.ColumnString(
      'baseCurrencyCode',
      this,
    );
    fetchedAt = _is.ColumnDateTime(
      'fetchedAt',
      this,
    );
    isLatest = _is.ColumnBool(
      'isLatest',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final FxRateSnapshotUpdateTable updateTable;

  late final _is.ColumnString provider;

  late final _is.ColumnString baseCurrencyCode;

  late final _is.ColumnDateTime fetchedAt;

  late final _is.ColumnBool isLatest;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    provider,
    baseCurrencyCode,
    fetchedAt,
    isLatest,
    createdAt,
  ];
}

class FxRateSnapshotInclude extends _is.IncludeObject {
  FxRateSnapshotInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRateSnapshot.t;
}

class FxRateSnapshotIncludeList extends _is.IncludeList {
  FxRateSnapshotIncludeList._({
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxRateSnapshot.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRateSnapshot.t;
}

class FxRateSnapshotRepository {
  const FxRateSnapshotRepository._();

  /// Returns a list of [FxRateSnapshot]s matching the given query parameters.
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
  Future<List<FxRateSnapshot>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [FxRateSnapshot]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `FxRateSnapshot.t`.
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
  _ida.Stream<List<FxRateSnapshot>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [FxRateSnapshot] matching the given query parameters.
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
  Future<FxRateSnapshot?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? offset,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FxRateSnapshot] by its [id] or null if no such row exists.
  Future<FxRateSnapshot?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FxRateSnapshot>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FxRateSnapshot]s in the list and returns the inserted rows.
  ///
  /// The returned [FxRateSnapshot]s will have their `id` fields set.
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
  Future<List<FxRateSnapshot>> insert(
    _is.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FxRateSnapshot>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FxRateSnapshot] and returns the inserted row.
  ///
  /// The returned [FxRateSnapshot] will have its `id` field set.
  Future<FxRateSnapshot> insertRow(
    _is.DatabaseSession session,
    FxRateSnapshot row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxRateSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FxRateSnapshot]s in the list and returns the resulting rows.
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
  /// The returned [FxRateSnapshot]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateSnapshot>> upsert(
    _is.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    required _is.ColumnSelections<FxRateSnapshotTable> conflictColumns,
    _is.ColumnSelections<FxRateSnapshotTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FxRateSnapshot>(
      rows,
      conflictColumns: conflictColumns(FxRateSnapshot.t),
      updateColumns: updateColumns?.call(FxRateSnapshot.t),
      updateWhere: updateWhere?.call(FxRateSnapshot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FxRateSnapshot] and returns the resulting row.
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
  /// The returned [FxRateSnapshot] will have its `id` field set.
  Future<FxRateSnapshot?> upsertRow(
    _is.DatabaseSession session,
    FxRateSnapshot row, {
    required _is.ColumnSelections<FxRateSnapshotTable> conflictColumns,
    _is.ColumnSelections<FxRateSnapshotTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FxRateSnapshot>(
      row,
      conflictColumns: conflictColumns(FxRateSnapshot.t),
      updateColumns: updateColumns?.call(FxRateSnapshot.t),
      updateWhere: updateWhere?.call(FxRateSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateSnapshot]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateSnapshot>> update(
    _is.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _is.ColumnSelections<FxRateSnapshotTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FxRateSnapshot>(
      rows,
      columns: columns?.call(FxRateSnapshot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FxRateSnapshot]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxRateSnapshot> updateRow(
    _is.DatabaseSession session,
    FxRateSnapshot row, {
    _is.ColumnSelections<FxRateSnapshotTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxRateSnapshot>(
      row,
      columns: columns?.call(FxRateSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateSnapshot] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxRateSnapshot?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<FxRateSnapshotUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FxRateSnapshot>(
      id,
      columnValues: columnValues(FxRateSnapshot.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateSnapshot]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRateSnapshot>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FxRateSnapshotUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FxRateSnapshotTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FxRateSnapshot>(
      columnValues: columnValues(FxRateSnapshot.t.updateTable),
      where: where(FxRateSnapshot.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FxRateSnapshot]s in the list and returns the deleted rows.
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
  Future<List<FxRateSnapshot>> delete(
    _is.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FxRateSnapshot>(
      rows,
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FxRateSnapshot].
  Future<FxRateSnapshot> deleteRow(
    _is.DatabaseSession session,
    FxRateSnapshot row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxRateSnapshot>(
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
  Future<List<FxRateSnapshot>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateSnapshotTable> where,
    _is.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _is.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FxRateSnapshot>(
      where: where(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FxRateSnapshot] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateSnapshotTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FxRateSnapshot>(
      where: where(FxRateSnapshot.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
