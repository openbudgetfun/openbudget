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

import '../agent/agent_message_role.dart' as _ilmyi46t;

/// One message in an agent conversation, including hidden tool traffic.
abstract class AgentMessage
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentMessage._({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.toolCallsJson,
    this.toolCallId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentMessage({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
    required _ilmyi46t.AgentMessageRole role,
    required String content,
    String? toolCallsJson,
    String? toolCallId,
    DateTime? createdAt,
  }) = _AgentMessageImpl;

  factory AgentMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      role: _ilmyi46t.AgentMessageRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      content: jsonSerialization['content'] as String,
      toolCallsJson: jsonSerialization['toolCallsJson'] as String?,
      toolCallId: jsonSerialization['toolCallId'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AgentMessageTable();

  static const db = AgentMessageRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue conversationId;

  _ilmyi46t.AgentMessageRole role;

  /// The message text. Empty for an assistant turn that only calls tools.
  String content;

  /// JSON list of OpenAI tool calls the assistant requested, when any.
  String? toolCallsJson;

  /// The tool call this message answers, for role tool.
  String? toolCallId;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentMessage copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? conversationId,
    _ilmyi46t.AgentMessageRole? role,
    String? content,
    String? toolCallsJson,
    String? toolCallId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'role': role.toJson(),
      'content': content,
      if (toolCallsJson != null) 'toolCallsJson': toolCallsJson,
      if (toolCallId != null) 'toolCallId': toolCallId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'role': role.toJson(),
      'content': content,
      if (toolCallsJson != null) 'toolCallsJson': toolCallsJson,
      if (toolCallId != null) 'toolCallId': toolCallId,
      'createdAt': createdAt.toJson(),
    };
  }

  static AgentMessageInclude include() {
    return AgentMessageInclude._();
  }

  static AgentMessageIncludeList includeList({
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    AgentMessageInclude? include,
  }) {
    return AgentMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentMessageImpl extends AgentMessage {
  _AgentMessageImpl({
    _is.UuidValue? id,
    required _is.UuidValue conversationId,
    required _ilmyi46t.AgentMessageRole role,
    required String content,
    String? toolCallsJson,
    String? toolCallId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         role: role,
         content: content,
         toolCallsJson: toolCallsJson,
         toolCallId: toolCallId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AgentMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentMessage copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? conversationId,
    _ilmyi46t.AgentMessageRole? role,
    String? content,
    Object? toolCallsJson = _Undefined,
    Object? toolCallId = _Undefined,
    DateTime? createdAt,
  }) {
    return AgentMessage(
      id: id is _is.UndefinedSentinel ? this.id : id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCallsJson: toolCallsJson is String?
          ? toolCallsJson
          : this.toolCallsJson,
      toolCallId: toolCallId is String? ? toolCallId : this.toolCallId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AgentMessageUpdateTable extends _is.UpdateTable<AgentMessageTable> {
  AgentMessageUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<_ilmyi46t.AgentMessageRole, _ilmyi46t.AgentMessageRole> role(
    _ilmyi46t.AgentMessageRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> content(String value) => _is.ColumnValue(
    table.content,
    value,
  );

  _is.ColumnValue<String, String> toolCallsJson(String? value) =>
      _is.ColumnValue(
        table.toolCallsJson,
        value,
      );

  _is.ColumnValue<String, String> toolCallId(String? value) => _is.ColumnValue(
    table.toolCallId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AgentMessageTable extends _is.Table<_is.UuidValue?> {
  AgentMessageTable({super.tableRelation}) : super(tableName: 'agent_message') {
    updateTable = AgentMessageUpdateTable(this);
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    content = _is.ColumnString(
      'content',
      this,
    );
    toolCallsJson = _is.ColumnString(
      'toolCallsJson',
      this,
    );
    toolCallId = _is.ColumnString(
      'toolCallId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AgentMessageUpdateTable updateTable;

  late final _is.ColumnUuid conversationId;

  late final _is.ColumnEnum<_ilmyi46t.AgentMessageRole> role;

  /// The message text. Empty for an assistant turn that only calls tools.
  late final _is.ColumnString content;

  /// JSON list of OpenAI tool calls the assistant requested, when any.
  late final _is.ColumnString toolCallsJson;

  /// The tool call this message answers, for role tool.
  late final _is.ColumnString toolCallId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    conversationId,
    role,
    content,
    toolCallsJson,
    toolCallId,
    createdAt,
  ];
}

class AgentMessageInclude extends _is.IncludeObject {
  AgentMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentMessage.t;
}

class AgentMessageIncludeList extends _is.IncludeList {
  AgentMessageIncludeList._({
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentMessage.t;
}

class AgentMessageRepository {
  const AgentMessageRepository._();

  /// Returns a list of [AgentMessage]s matching the given query parameters.
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
  Future<List<AgentMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentMessage>(
      where: where?.call(AgentMessage.t),
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentMessage]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentMessage.t`.
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
  _ida.Stream<List<AgentMessage>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentMessage>(
      where: where?.call(AgentMessage.t),
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentMessage] matching the given query parameters.
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
  Future<AgentMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentMessage>(
      where: where?.call(AgentMessage.t),
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentMessage] by its [id] or null if no such row exists.
  Future<AgentMessage?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentMessage]s will have their `id` fields set.
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
  Future<List<AgentMessage>> insert(
    _is.DatabaseSession session,
    List<AgentMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentMessage] and returns the inserted row.
  ///
  /// The returned [AgentMessage] will have its `id` field set.
  Future<AgentMessage> insertRow(
    _is.DatabaseSession session,
    AgentMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentMessage]s in the list and returns the resulting rows.
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
  /// The returned [AgentMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentMessage>> upsert(
    _is.DatabaseSession session,
    List<AgentMessage> rows, {
    required _is.ColumnSelections<AgentMessageTable> conflictColumns,
    _is.ColumnSelections<AgentMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentMessage>(
      rows,
      conflictColumns: conflictColumns(AgentMessage.t),
      updateColumns: updateColumns?.call(AgentMessage.t),
      updateWhere: updateWhere?.call(AgentMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentMessage] and returns the resulting row.
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
  /// The returned [AgentMessage] will have its `id` field set.
  Future<AgentMessage?> upsertRow(
    _is.DatabaseSession session,
    AgentMessage row, {
    required _is.ColumnSelections<AgentMessageTable> conflictColumns,
    _is.ColumnSelections<AgentMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentMessage>(
      row,
      conflictColumns: conflictColumns(AgentMessage.t),
      updateColumns: updateColumns?.call(AgentMessage.t),
      updateWhere: updateWhere?.call(AgentMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentMessage>> update(
    _is.DatabaseSession session,
    List<AgentMessage> rows, {
    _is.ColumnSelections<AgentMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentMessage>(
      rows,
      columns: columns?.call(AgentMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentMessage> updateRow(
    _is.DatabaseSession session,
    AgentMessage row, {
    _is.ColumnSelections<AgentMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentMessage>(
      row,
      columns: columns?.call(AgentMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentMessage?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentMessage>(
      id,
      columnValues: columnValues(AgentMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AgentMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentMessage>(
      columnValues: columnValues(AgentMessage.t.updateTable),
      where: where(AgentMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentMessage]s in the list and returns the deleted rows.
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
  Future<List<AgentMessage>> delete(
    _is.DatabaseSession session,
    List<AgentMessage> rows, {
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentMessage>(
      rows,
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentMessage].
  Future<AgentMessage> deleteRow(
    _is.DatabaseSession session,
    AgentMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentMessage>(
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
  Future<List<AgentMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentMessageTable> where,
    _is.OrderByBuilder<AgentMessageTable>? orderBy,
    _is.OrderByListBuilder<AgentMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentMessage>(
      where: where(AgentMessage.t),
      orderBy: orderBy?.call(AgentMessage.t),
      orderByList: orderByList?.call(AgentMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentMessage>(
      where: where?.call(AgentMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentMessage>(
      where: where(AgentMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
