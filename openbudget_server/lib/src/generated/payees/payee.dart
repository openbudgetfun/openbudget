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

/// A merchant or person an entity pays or is paid by.
abstract class Payee
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Payee._({
    this.id,
    required this.entityId,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payee({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    DateTime? createdAt,
  }) = _PayeeImpl;

  factory Payee.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payee(
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
    );
  }

  static final t = PayeeTable();

  static const db = PayeeRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  String name;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Payee copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Payee',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Payee',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'createdAt': createdAt.toJson(),
    };
  }

  static PayeeInclude include() {
    return PayeeInclude._();
  }

  static PayeeIncludeList includeList({
    _is.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    PayeeInclude? include,
  }) {
    return PayeeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PayeeImpl extends Payee {
  _PayeeImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entityId: entityId,
         name: name,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Payee copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    DateTime? createdAt,
  }) {
    return Payee(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PayeeUpdateTable extends _is.UpdateTable<PayeeTable> {
  PayeeUpdateTable(super.table);

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
}

class PayeeTable extends _is.Table<_is.UuidValue?> {
  PayeeTable({super.tableRelation}) : super(tableName: 'payee') {
    updateTable = PayeeUpdateTable(this);
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
  }

  late final PayeeUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnString name;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    name,
    createdAt,
  ];
}

class PayeeInclude extends _is.IncludeObject {
  PayeeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Payee.t;
}

class PayeeIncludeList extends _is.IncludeList {
  PayeeIncludeList._({
    _is.WhereExpressionBuilder<PayeeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Payee.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Payee.t;
}

class PayeeRepository {
  const PayeeRepository._();

  /// Returns a list of [Payee]s matching the given query parameters.
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
  Future<List<Payee>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Payee>(
      where: where?.call(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Payee]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Payee.t`.
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
  _ida.Stream<List<Payee>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Payee>(
      where: where?.call(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Payee] matching the given query parameters.
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
  Future<Payee?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayeeTable>? where,
    int? offset,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Payee>(
      where: where?.call(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Payee] by its [id] or null if no such row exists.
  Future<Payee?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Payee>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Payee]s in the list and returns the inserted rows.
  ///
  /// The returned [Payee]s will have their `id` fields set.
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
  Future<List<Payee>> insert(
    _is.DatabaseSession session,
    List<Payee> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Payee>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Payee] and returns the inserted row.
  ///
  /// The returned [Payee] will have its `id` field set.
  Future<Payee> insertRow(
    _is.DatabaseSession session,
    Payee row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Payee>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Payee]s in the list and returns the resulting rows.
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
  /// The returned [Payee]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payee>> upsert(
    _is.DatabaseSession session,
    List<Payee> rows, {
    required _is.ColumnSelections<PayeeTable> conflictColumns,
    _is.ColumnSelections<PayeeTable>? updateColumns,
    _is.WhereExpressionBuilder<PayeeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Payee>(
      rows,
      conflictColumns: conflictColumns(Payee.t),
      updateColumns: updateColumns?.call(Payee.t),
      updateWhere: updateWhere?.call(Payee.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Payee] and returns the resulting row.
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
  /// The returned [Payee] will have its `id` field set.
  Future<Payee?> upsertRow(
    _is.DatabaseSession session,
    Payee row, {
    required _is.ColumnSelections<PayeeTable> conflictColumns,
    _is.ColumnSelections<PayeeTable>? updateColumns,
    _is.WhereExpressionBuilder<PayeeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Payee>(
      row,
      conflictColumns: conflictColumns(Payee.t),
      updateColumns: updateColumns?.call(Payee.t),
      updateWhere: updateWhere?.call(Payee.t),
      transaction: transaction,
    );
  }

  /// Updates all [Payee]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payee>> update(
    _is.DatabaseSession session,
    List<Payee> rows, {
    _is.ColumnSelections<PayeeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Payee>(
      rows,
      columns: columns?.call(Payee.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Payee]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Payee> updateRow(
    _is.DatabaseSession session,
    Payee row, {
    _is.ColumnSelections<PayeeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Payee>(
      row,
      columns: columns?.call(Payee.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Payee] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Payee?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PayeeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Payee>(
      id,
      columnValues: columnValues(Payee.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Payee]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payee>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PayeeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PayeeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Payee>(
      columnValues: columnValues(Payee.t.updateTable),
      where: where(Payee.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Payee]s in the list and returns the deleted rows.
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
  Future<List<Payee>> delete(
    _is.DatabaseSession session,
    List<Payee> rows, {
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Payee>(
      rows,
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Payee].
  Future<Payee> deleteRow(
    _is.DatabaseSession session,
    Payee row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Payee>(
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
  Future<List<Payee>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayeeTable> where,
    _is.OrderByBuilder<PayeeTable>? orderBy,
    _is.OrderByListBuilder<PayeeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Payee>(
      where: where(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Payee>(
      where: where?.call(Payee.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Payee] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PayeeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Payee>(
      where: where(Payee.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
