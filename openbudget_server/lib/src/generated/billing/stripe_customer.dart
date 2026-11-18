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

/// Links an OpenBudget user to their Stripe customer for checkout and the
/// billing portal.
abstract class StripeCustomer
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  StripeCustomer._({
    this.id,
    required this.userId,
    required this.customerId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StripeCustomer({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String customerId,
    DateTime? createdAt,
  }) = _StripeCustomerImpl;

  factory StripeCustomer.fromJson(Map<String, dynamic> jsonSerialization) {
    return StripeCustomer(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      customerId: jsonSerialization['customerId'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = StripeCustomerTable();

  static const db = StripeCustomerRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  String customerId;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [StripeCustomer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StripeCustomer copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? customerId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StripeCustomer',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'customerId': customerId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StripeCustomerInclude include() {
    return StripeCustomerInclude._();
  }

  static StripeCustomerIncludeList includeList({
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    StripeCustomerInclude? include,
  }) {
    return StripeCustomerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _StripeCustomerImpl extends StripeCustomer {
  _StripeCustomerImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String customerId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         customerId: customerId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [StripeCustomer]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StripeCustomer copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? customerId,
    DateTime? createdAt,
  }) {
    return StripeCustomer(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StripeCustomerUpdateTable extends _is.UpdateTable<StripeCustomerTable> {
  StripeCustomerUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> customerId(String value) => _is.ColumnValue(
    table.customerId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class StripeCustomerTable extends _is.Table<_is.UuidValue?> {
  StripeCustomerTable({super.tableRelation})
    : super(tableName: 'stripe_customer') {
    updateTable = StripeCustomerUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    customerId = _is.ColumnString(
      'customerId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final StripeCustomerUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnString customerId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    customerId,
    createdAt,
  ];
}

class StripeCustomerInclude extends _is.IncludeObject {
  StripeCustomerInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => StripeCustomer.t;
}

class StripeCustomerIncludeList extends _is.IncludeList {
  StripeCustomerIncludeList._({
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StripeCustomer.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => StripeCustomer.t;
}

class StripeCustomerRepository {
  const StripeCustomerRepository._();

  /// Returns a list of [StripeCustomer]s matching the given query parameters.
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
  Future<List<StripeCustomer>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StripeCustomer>(
      where: where?.call(StripeCustomer.t),
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StripeCustomer]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StripeCustomer.t`.
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
  _ida.Stream<List<StripeCustomer>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StripeCustomer>(
      where: where?.call(StripeCustomer.t),
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StripeCustomer] matching the given query parameters.
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
  Future<StripeCustomer?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    int? offset,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StripeCustomer>(
      where: where?.call(StripeCustomer.t),
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StripeCustomer] by its [id] or null if no such row exists.
  Future<StripeCustomer?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StripeCustomer>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StripeCustomer]s in the list and returns the inserted rows.
  ///
  /// The returned [StripeCustomer]s will have their `id` fields set.
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
  Future<List<StripeCustomer>> insert(
    _is.DatabaseSession session,
    List<StripeCustomer> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StripeCustomer>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StripeCustomer] and returns the inserted row.
  ///
  /// The returned [StripeCustomer] will have its `id` field set.
  Future<StripeCustomer> insertRow(
    _is.DatabaseSession session,
    StripeCustomer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StripeCustomer>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StripeCustomer]s in the list and returns the resulting rows.
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
  /// The returned [StripeCustomer]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StripeCustomer>> upsert(
    _is.DatabaseSession session,
    List<StripeCustomer> rows, {
    required _is.ColumnSelections<StripeCustomerTable> conflictColumns,
    _is.ColumnSelections<StripeCustomerTable>? updateColumns,
    _is.WhereExpressionBuilder<StripeCustomerTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StripeCustomer>(
      rows,
      conflictColumns: conflictColumns(StripeCustomer.t),
      updateColumns: updateColumns?.call(StripeCustomer.t),
      updateWhere: updateWhere?.call(StripeCustomer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StripeCustomer] and returns the resulting row.
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
  /// The returned [StripeCustomer] will have its `id` field set.
  Future<StripeCustomer?> upsertRow(
    _is.DatabaseSession session,
    StripeCustomer row, {
    required _is.ColumnSelections<StripeCustomerTable> conflictColumns,
    _is.ColumnSelections<StripeCustomerTable>? updateColumns,
    _is.WhereExpressionBuilder<StripeCustomerTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StripeCustomer>(
      row,
      conflictColumns: conflictColumns(StripeCustomer.t),
      updateColumns: updateColumns?.call(StripeCustomer.t),
      updateWhere: updateWhere?.call(StripeCustomer.t),
      transaction: transaction,
    );
  }

  /// Updates all [StripeCustomer]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StripeCustomer>> update(
    _is.DatabaseSession session,
    List<StripeCustomer> rows, {
    _is.ColumnSelections<StripeCustomerTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StripeCustomer>(
      rows,
      columns: columns?.call(StripeCustomer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StripeCustomer]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StripeCustomer> updateRow(
    _is.DatabaseSession session,
    StripeCustomer row, {
    _is.ColumnSelections<StripeCustomerTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StripeCustomer>(
      row,
      columns: columns?.call(StripeCustomer.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StripeCustomer] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StripeCustomer?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StripeCustomerUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StripeCustomer>(
      id,
      columnValues: columnValues(StripeCustomer.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StripeCustomer]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StripeCustomer>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StripeCustomerUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StripeCustomerTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StripeCustomer>(
      columnValues: columnValues(StripeCustomer.t.updateTable),
      where: where(StripeCustomer.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StripeCustomer]s in the list and returns the deleted rows.
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
  Future<List<StripeCustomer>> delete(
    _is.DatabaseSession session,
    List<StripeCustomer> rows, {
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StripeCustomer>(
      rows,
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StripeCustomer].
  Future<StripeCustomer> deleteRow(
    _is.DatabaseSession session,
    StripeCustomer row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StripeCustomer>(
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
  Future<List<StripeCustomer>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StripeCustomerTable> where,
    _is.OrderByBuilder<StripeCustomerTable>? orderBy,
    _is.OrderByListBuilder<StripeCustomerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StripeCustomer>(
      where: where(StripeCustomer.t),
      orderBy: orderBy?.call(StripeCustomer.t),
      orderByList: orderByList?.call(StripeCustomer.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StripeCustomerTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StripeCustomer>(
      where: where?.call(StripeCustomer.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StripeCustomer] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StripeCustomerTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StripeCustomer>(
      where: where(StripeCustomer.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
