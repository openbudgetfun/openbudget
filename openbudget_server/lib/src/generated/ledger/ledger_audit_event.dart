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

/// One audit trail entry for a budget's books.
///
/// Every post, reversal, lock change and accounting-mode switch writes one
/// row: who did what, when, with a JSON payload of the details. Rows are
/// never updated or deleted.
abstract class LedgerAuditEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  LedgerAuditEvent._({
    this.id,
    required this.budgetId,
    required this.actor,
    required this.action,
    this.entity,
    this.entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) : payloadJson = payloadJson ?? '{}',
       createdAt = createdAt ?? DateTime.now();

  factory LedgerAuditEvent({
    int? id,
    required _is.UuidValue budgetId,
    required _is.UuidValue actor,
    required String action,
    String? entity,
    _is.UuidValue? entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) = _LedgerAuditEventImpl;

  factory LedgerAuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerAuditEvent(
      id: jsonSerialization['id'] as int?,
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      actor: _is.UuidValueJsonExtension.fromJson(jsonSerialization['actor']),
      action: jsonSerialization['action'] as String,
      entity: jsonSerialization['entity'] as String?,
      entityId: jsonSerialization['entityId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['entityId']),
      payloadJson: jsonSerialization['payloadJson'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = LedgerAuditEventTable();

  static const db = LedgerAuditEventRepository._();

  @override
  int? id;

  _is.UuidValue budgetId;

  /// The acting user, or the system identity for automated actions.
  _is.UuidValue actor;

  /// Stable action name, such as `journal.posted` or `lock.set`.
  String action;

  /// The affected entity kind, such as `journal`, when there is one.
  String? entity;

  /// The affected entity's id, when there is one.
  _is.UuidValue? entityId;

  /// JSON payload with the action's details.
  String payloadJson;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [LedgerAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LedgerAuditEvent copyWith({
    int? id,
    _is.UuidValue? budgetId,
    _is.UuidValue? actor,
    String? action,
    String? entity,
    _is.UuidValue? entityId = const _is.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerAuditEvent',
      if (id != null) 'id': id,
      'budgetId': budgetId.toJson(),
      'actor': actor.toJson(),
      'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entityId': entityId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerAuditEvent',
      if (id != null) 'id': id,
      'budgetId': budgetId.toJson(),
      'actor': actor.toJson(),
      'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entityId': entityId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  static LedgerAuditEventInclude include() {
    return LedgerAuditEventInclude._();
  }

  static LedgerAuditEventIncludeList includeList({
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    LedgerAuditEventInclude? include,
  }) {
    return LedgerAuditEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LedgerAuditEventImpl extends LedgerAuditEvent {
  _LedgerAuditEventImpl({
    int? id,
    required _is.UuidValue budgetId,
    required _is.UuidValue actor,
    required String action,
    String? entity,
    _is.UuidValue? entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         actor: actor,
         action: action,
         entity: entity,
         entityId: entityId,
         payloadJson: payloadJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [LedgerAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LedgerAuditEvent copyWith({
    Object? id = _Undefined,
    _is.UuidValue? budgetId,
    _is.UuidValue? actor,
    String? action,
    Object? entity = _Undefined,
    _is.UuidValue? entityId = const _is.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  }) {
    return LedgerAuditEvent(
      id: id is int? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      entity: entity is String? ? entity : this.entity,
      entityId: entityId is _is.UndefinedSentinel ? this.entityId : entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LedgerAuditEventUpdateTable
    extends _is.UpdateTable<LedgerAuditEventTable> {
  LedgerAuditEventUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> actor(_is.UuidValue value) =>
      _is.ColumnValue(
        table.actor,
        value,
      );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<String, String> entity(String? value) => _is.ColumnValue(
    table.entity,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.entityId,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class LedgerAuditEventTable extends _is.Table<int?> {
  LedgerAuditEventTable({super.tableRelation})
    : super(tableName: 'ledger_audit_event') {
    updateTable = LedgerAuditEventUpdateTable(this);
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    actor = _is.ColumnUuid(
      'actor',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    entity = _is.ColumnString(
      'entity',
      this,
    );
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final LedgerAuditEventUpdateTable updateTable;

  late final _is.ColumnUuid budgetId;

  /// The acting user, or the system identity for automated actions.
  late final _is.ColumnUuid actor;

  /// Stable action name, such as `journal.posted` or `lock.set`.
  late final _is.ColumnString action;

  /// The affected entity kind, such as `journal`, when there is one.
  late final _is.ColumnString entity;

  /// The affected entity's id, when there is one.
  late final _is.ColumnUuid entityId;

  /// JSON payload with the action's details.
  late final _is.ColumnString payloadJson;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    budgetId,
    actor,
    action,
    entity,
    entityId,
    payloadJson,
    createdAt,
  ];
}

class LedgerAuditEventInclude extends _is.IncludeObject {
  LedgerAuditEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => LedgerAuditEvent.t;
}

class LedgerAuditEventIncludeList extends _is.IncludeList {
  LedgerAuditEventIncludeList._({
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LedgerAuditEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => LedgerAuditEvent.t;
}

class LedgerAuditEventRepository {
  const LedgerAuditEventRepository._();

  /// Returns a list of [LedgerAuditEvent]s matching the given query parameters.
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
  Future<List<LedgerAuditEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LedgerAuditEvent>(
      where: where?.call(LedgerAuditEvent.t),
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [LedgerAuditEvent]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `LedgerAuditEvent.t`.
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
  _ida.Stream<List<LedgerAuditEvent>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<LedgerAuditEvent>(
      where: where?.call(LedgerAuditEvent.t),
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [LedgerAuditEvent] matching the given query parameters.
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
  Future<LedgerAuditEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    int? offset,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LedgerAuditEvent>(
      where: where?.call(LedgerAuditEvent.t),
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LedgerAuditEvent] by its [id] or null if no such row exists.
  Future<LedgerAuditEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LedgerAuditEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LedgerAuditEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [LedgerAuditEvent]s will have their `id` fields set.
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
  Future<List<LedgerAuditEvent>> insert(
    _is.DatabaseSession session,
    List<LedgerAuditEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LedgerAuditEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LedgerAuditEvent] and returns the inserted row.
  ///
  /// The returned [LedgerAuditEvent] will have its `id` field set.
  Future<LedgerAuditEvent> insertRow(
    _is.DatabaseSession session,
    LedgerAuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LedgerAuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LedgerAuditEvent]s in the list and returns the resulting rows.
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
  /// The returned [LedgerAuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAuditEvent>> upsert(
    _is.DatabaseSession session,
    List<LedgerAuditEvent> rows, {
    required _is.ColumnSelections<LedgerAuditEventTable> conflictColumns,
    _is.ColumnSelections<LedgerAuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LedgerAuditEvent>(
      rows,
      conflictColumns: conflictColumns(LedgerAuditEvent.t),
      updateColumns: updateColumns?.call(LedgerAuditEvent.t),
      updateWhere: updateWhere?.call(LedgerAuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LedgerAuditEvent] and returns the resulting row.
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
  /// The returned [LedgerAuditEvent] will have its `id` field set.
  Future<LedgerAuditEvent?> upsertRow(
    _is.DatabaseSession session,
    LedgerAuditEvent row, {
    required _is.ColumnSelections<LedgerAuditEventTable> conflictColumns,
    _is.ColumnSelections<LedgerAuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LedgerAuditEvent>(
      row,
      conflictColumns: conflictColumns(LedgerAuditEvent.t),
      updateColumns: updateColumns?.call(LedgerAuditEvent.t),
      updateWhere: updateWhere?.call(LedgerAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAuditEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAuditEvent>> update(
    _is.DatabaseSession session,
    List<LedgerAuditEvent> rows, {
    _is.ColumnSelections<LedgerAuditEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LedgerAuditEvent>(
      rows,
      columns: columns?.call(LedgerAuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LedgerAuditEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LedgerAuditEvent> updateRow(
    _is.DatabaseSession session,
    LedgerAuditEvent row, {
    _is.ColumnSelections<LedgerAuditEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LedgerAuditEvent>(
      row,
      columns: columns?.call(LedgerAuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LedgerAuditEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LedgerAuditEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<LedgerAuditEventUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LedgerAuditEvent>(
      id,
      columnValues: columnValues(LedgerAuditEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LedgerAuditEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LedgerAuditEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LedgerAuditEventUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<LedgerAuditEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LedgerAuditEvent>(
      columnValues: columnValues(LedgerAuditEvent.t.updateTable),
      where: where(LedgerAuditEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LedgerAuditEvent]s in the list and returns the deleted rows.
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
  Future<List<LedgerAuditEvent>> delete(
    _is.DatabaseSession session,
    List<LedgerAuditEvent> rows, {
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LedgerAuditEvent>(
      rows,
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LedgerAuditEvent].
  Future<LedgerAuditEvent> deleteRow(
    _is.DatabaseSession session,
    LedgerAuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LedgerAuditEvent>(
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
  Future<List<LedgerAuditEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAuditEventTable> where,
    _is.OrderByBuilder<LedgerAuditEventTable>? orderBy,
    _is.OrderByListBuilder<LedgerAuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LedgerAuditEvent>(
      where: where(LedgerAuditEvent.t),
      orderBy: orderBy?.call(LedgerAuditEvent.t),
      orderByList: orderByList?.call(LedgerAuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LedgerAuditEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LedgerAuditEvent>(
      where: where?.call(LedgerAuditEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LedgerAuditEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LedgerAuditEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LedgerAuditEvent>(
      where: where(LedgerAuditEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
