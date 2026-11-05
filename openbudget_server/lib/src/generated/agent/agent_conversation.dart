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

/// One chat between a user and the financial assistant about a budget.
abstract class AgentConversation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentConversation._({
    this.id,
    required this.userId,
    required this.budgetId,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AgentConversation({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue budgetId,
    required String title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AgentConversationImpl;

  factory AgentConversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentConversation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      title: jsonSerialization['title'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AgentConversationTable();

  static const db = AgentConversationRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _is.UuidValue budgetId;

  /// Short title, taken from the first message.
  String title;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentConversation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentConversation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? budgetId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentConversation',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      'title': title,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AgentConversationInclude include() {
    return AgentConversationInclude._();
  }

  static AgentConversationIncludeList includeList({
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    AgentConversationInclude? include,
  }) {
    return AgentConversationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentConversationImpl extends AgentConversation {
  _AgentConversationImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue budgetId,
    required String title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         budgetId: budgetId,
         title: title,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AgentConversation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentConversation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? budgetId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentConversation(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AgentConversationUpdateTable
    extends _is.UpdateTable<AgentConversationTable> {
  AgentConversationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
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

class AgentConversationTable extends _is.Table<_is.UuidValue?> {
  AgentConversationTable({super.tableRelation})
    : super(tableName: 'agent_conversation') {
    updateTable = AgentConversationUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    title = _is.ColumnString(
      'title',
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

  late final AgentConversationUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnUuid budgetId;

  /// Short title, taken from the first message.
  late final _is.ColumnString title;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    budgetId,
    title,
    createdAt,
    updatedAt,
  ];
}

class AgentConversationInclude extends _is.IncludeObject {
  AgentConversationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentConversation.t;
}

class AgentConversationIncludeList extends _is.IncludeList {
  AgentConversationIncludeList._({
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentConversation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentConversation.t;
}

class AgentConversationRepository {
  const AgentConversationRepository._();

  /// Returns a list of [AgentConversation]s matching the given query parameters.
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
  Future<List<AgentConversation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentConversation>(
      where: where?.call(AgentConversation.t),
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentConversation]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentConversation.t`.
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
  _ida.Stream<List<AgentConversation>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentConversation>(
      where: where?.call(AgentConversation.t),
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentConversation] matching the given query parameters.
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
  Future<AgentConversation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentConversation>(
      where: where?.call(AgentConversation.t),
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentConversation] by its [id] or null if no such row exists.
  Future<AgentConversation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentConversation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentConversation]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentConversation]s will have their `id` fields set.
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
  Future<List<AgentConversation>> insert(
    _is.DatabaseSession session,
    List<AgentConversation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentConversation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentConversation] and returns the inserted row.
  ///
  /// The returned [AgentConversation] will have its `id` field set.
  Future<AgentConversation> insertRow(
    _is.DatabaseSession session,
    AgentConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentConversation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentConversation]s in the list and returns the resulting rows.
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
  /// The returned [AgentConversation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentConversation>> upsert(
    _is.DatabaseSession session,
    List<AgentConversation> rows, {
    required _is.ColumnSelections<AgentConversationTable> conflictColumns,
    _is.ColumnSelections<AgentConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentConversationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentConversation>(
      rows,
      conflictColumns: conflictColumns(AgentConversation.t),
      updateColumns: updateColumns?.call(AgentConversation.t),
      updateWhere: updateWhere?.call(AgentConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentConversation] and returns the resulting row.
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
  /// The returned [AgentConversation] will have its `id` field set.
  Future<AgentConversation?> upsertRow(
    _is.DatabaseSession session,
    AgentConversation row, {
    required _is.ColumnSelections<AgentConversationTable> conflictColumns,
    _is.ColumnSelections<AgentConversationTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentConversationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentConversation>(
      row,
      conflictColumns: conflictColumns(AgentConversation.t),
      updateColumns: updateColumns?.call(AgentConversation.t),
      updateWhere: updateWhere?.call(AgentConversation.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentConversation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentConversation>> update(
    _is.DatabaseSession session,
    List<AgentConversation> rows, {
    _is.ColumnSelections<AgentConversationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentConversation>(
      rows,
      columns: columns?.call(AgentConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentConversation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentConversation> updateRow(
    _is.DatabaseSession session,
    AgentConversation row, {
    _is.ColumnSelections<AgentConversationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentConversation>(
      row,
      columns: columns?.call(AgentConversation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentConversation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentConversation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentConversationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentConversation>(
      id,
      columnValues: columnValues(AgentConversation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentConversation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentConversation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentConversationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AgentConversationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentConversation>(
      columnValues: columnValues(AgentConversation.t.updateTable),
      where: where(AgentConversation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentConversation]s in the list and returns the deleted rows.
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
  Future<List<AgentConversation>> delete(
    _is.DatabaseSession session,
    List<AgentConversation> rows, {
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentConversation>(
      rows,
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentConversation].
  Future<AgentConversation> deleteRow(
    _is.DatabaseSession session,
    AgentConversation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentConversation>(
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
  Future<List<AgentConversation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentConversationTable> where,
    _is.OrderByBuilder<AgentConversationTable>? orderBy,
    _is.OrderByListBuilder<AgentConversationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentConversation>(
      where: where(AgentConversation.t),
      orderBy: orderBy?.call(AgentConversation.t),
      orderByList: orderByList?.call(AgentConversation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentConversationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentConversation>(
      where: where?.call(AgentConversation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentConversation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentConversationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentConversation>(
      where: where(AgentConversation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
