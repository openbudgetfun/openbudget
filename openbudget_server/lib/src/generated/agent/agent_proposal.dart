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

import '../agent/agent_proposal_kind.dart' as _i4huex49;
import '../agent/agent_proposal_status.dart' as _irqal209;

/// A change the assistant suggests but never makes itself.
abstract class AgentProposal
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentProposal._({
    this.id,
    required this.userId,
    required this.budgetId,
    this.conversationId,
    required this.kind,
    required this.payloadJson,
    required this.summary,
    required this.status,
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentProposal({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue budgetId,
    _is.UuidValue? conversationId,
    required _i4huex49.AgentProposalKind kind,
    required String payloadJson,
    required String summary,
    required _irqal209.AgentProposalStatus status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) = _AgentProposalImpl;

  factory AgentProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentProposal(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['conversationId'],
            ),
      kind: _i4huex49.AgentProposalKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      payloadJson: jsonSerialization['payloadJson'] as String,
      summary: jsonSerialization['summary'] as String,
      status: _irqal209.AgentProposalStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
    );
  }

  static final t = AgentProposalTable();

  static const db = AgentProposalRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _is.UuidValue budgetId;

  /// The conversation that produced it, when it came from chat.
  _is.UuidValue? conversationId;

  _i4huex49.AgentProposalKind kind;

  /// Kind-specific arguments, as a JSON object.
  String payloadJson;

  /// One sentence the user can decide on.
  String summary;

  _irqal209.AgentProposalStatus status;

  DateTime createdAt;

  DateTime? resolvedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentProposal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? budgetId,
    _is.UuidValue? conversationId = const _is.$UndefinedUuidValue(),
    _i4huex49.AgentProposalKind? kind,
    String? payloadJson,
    String? summary,
    _irqal209.AgentProposalStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProposal',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'kind': kind.toJson(),
      'payloadJson': payloadJson,
      'summary': summary,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentProposal',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'budgetId': budgetId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'kind': kind.toJson(),
      'payloadJson': payloadJson,
      'summary': summary,
      'status': status.toJson(),
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  static AgentProposalInclude include() {
    return AgentProposalInclude._();
  }

  static AgentProposalIncludeList includeList({
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    AgentProposalInclude? include,
  }) {
    return AgentProposalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentProposalImpl extends AgentProposal {
  _AgentProposalImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _is.UuidValue budgetId,
    _is.UuidValue? conversationId,
    required _i4huex49.AgentProposalKind kind,
    required String payloadJson,
    required String summary,
    required _irqal209.AgentProposalStatus status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) : super._(
         id: id,
         userId: userId,
         budgetId: budgetId,
         conversationId: conversationId,
         kind: kind,
         payloadJson: payloadJson,
         summary: summary,
         status: status,
         createdAt: createdAt,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [AgentProposal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentProposal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? budgetId,
    _is.UuidValue? conversationId = const _is.$UndefinedUuidValue(),
    _i4huex49.AgentProposalKind? kind,
    String? payloadJson,
    String? summary,
    _irqal209.AgentProposalStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt = const _is.$UndefinedDateTime(),
  }) {
    return AgentProposal(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      conversationId: conversationId is _is.UndefinedSentinel
          ? this.conversationId
          : conversationId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt is _is.UndefinedSentinel
          ? this.resolvedAt
          : resolvedAt,
    );
  }
}

class AgentProposalUpdateTable extends _is.UpdateTable<AgentProposalTable> {
  AgentProposalUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<_i4huex49.AgentProposalKind, _i4huex49.AgentProposalKind>
  kind(_i4huex49.AgentProposalKind value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<String, String> summary(String value) => _is.ColumnValue(
    table.summary,
    value,
  );

  _is.ColumnValue<_irqal209.AgentProposalStatus, _irqal209.AgentProposalStatus>
  status(_irqal209.AgentProposalStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );
}

class AgentProposalTable extends _is.Table<_is.UuidValue?> {
  AgentProposalTable({super.tableRelation})
    : super(tableName: 'agent_proposal') {
    updateTable = AgentProposalUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    payloadJson = _is.ColumnString(
      'payloadJson',
      this,
    );
    summary = _is.ColumnString(
      'summary',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    resolvedAt = _is.ColumnDateTime(
      'resolvedAt',
      this,
    );
  }

  late final AgentProposalUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnUuid budgetId;

  /// The conversation that produced it, when it came from chat.
  late final _is.ColumnUuid conversationId;

  late final _is.ColumnEnum<_i4huex49.AgentProposalKind> kind;

  /// Kind-specific arguments, as a JSON object.
  late final _is.ColumnString payloadJson;

  /// One sentence the user can decide on.
  late final _is.ColumnString summary;

  late final _is.ColumnEnum<_irqal209.AgentProposalStatus> status;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime resolvedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    budgetId,
    conversationId,
    kind,
    payloadJson,
    summary,
    status,
    createdAt,
    resolvedAt,
  ];
}

class AgentProposalInclude extends _is.IncludeObject {
  AgentProposalInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentProposal.t;
}

class AgentProposalIncludeList extends _is.IncludeList {
  AgentProposalIncludeList._({
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentProposal.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentProposal.t;
}

class AgentProposalRepository {
  const AgentProposalRepository._();

  /// Returns a list of [AgentProposal]s matching the given query parameters.
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
  Future<List<AgentProposal>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentProposal>(
      where: where?.call(AgentProposal.t),
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentProposal]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentProposal.t`.
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
  _ida.Stream<List<AgentProposal>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentProposal>(
      where: where?.call(AgentProposal.t),
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentProposal] matching the given query parameters.
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
  Future<AgentProposal?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentProposal>(
      where: where?.call(AgentProposal.t),
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentProposal] by its [id] or null if no such row exists.
  Future<AgentProposal?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentProposal>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentProposal]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentProposal]s will have their `id` fields set.
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
  Future<List<AgentProposal>> insert(
    _is.DatabaseSession session,
    List<AgentProposal> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentProposal>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentProposal] and returns the inserted row.
  ///
  /// The returned [AgentProposal] will have its `id` field set.
  Future<AgentProposal> insertRow(
    _is.DatabaseSession session,
    AgentProposal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentProposal>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentProposal]s in the list and returns the resulting rows.
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
  /// The returned [AgentProposal]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProposal>> upsert(
    _is.DatabaseSession session,
    List<AgentProposal> rows, {
    required _is.ColumnSelections<AgentProposalTable> conflictColumns,
    _is.ColumnSelections<AgentProposalTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentProposalTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentProposal>(
      rows,
      conflictColumns: conflictColumns(AgentProposal.t),
      updateColumns: updateColumns?.call(AgentProposal.t),
      updateWhere: updateWhere?.call(AgentProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentProposal] and returns the resulting row.
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
  /// The returned [AgentProposal] will have its `id` field set.
  Future<AgentProposal?> upsertRow(
    _is.DatabaseSession session,
    AgentProposal row, {
    required _is.ColumnSelections<AgentProposalTable> conflictColumns,
    _is.ColumnSelections<AgentProposalTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentProposalTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentProposal>(
      row,
      conflictColumns: conflictColumns(AgentProposal.t),
      updateColumns: updateColumns?.call(AgentProposal.t),
      updateWhere: updateWhere?.call(AgentProposal.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentProposal]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProposal>> update(
    _is.DatabaseSession session,
    List<AgentProposal> rows, {
    _is.ColumnSelections<AgentProposalTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentProposal>(
      rows,
      columns: columns?.call(AgentProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentProposal]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentProposal> updateRow(
    _is.DatabaseSession session,
    AgentProposal row, {
    _is.ColumnSelections<AgentProposalTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentProposal>(
      row,
      columns: columns?.call(AgentProposal.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentProposal] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentProposal?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentProposalUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentProposal>(
      id,
      columnValues: columnValues(AgentProposal.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentProposal]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProposal>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentProposalUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AgentProposalTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentProposal>(
      columnValues: columnValues(AgentProposal.t.updateTable),
      where: where(AgentProposal.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentProposal]s in the list and returns the deleted rows.
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
  Future<List<AgentProposal>> delete(
    _is.DatabaseSession session,
    List<AgentProposal> rows, {
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentProposal>(
      rows,
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentProposal].
  Future<AgentProposal> deleteRow(
    _is.DatabaseSession session,
    AgentProposal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentProposal>(
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
  Future<List<AgentProposal>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentProposalTable> where,
    _is.OrderByBuilder<AgentProposalTable>? orderBy,
    _is.OrderByListBuilder<AgentProposalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentProposal>(
      where: where(AgentProposal.t),
      orderBy: orderBy?.call(AgentProposal.t),
      orderByList: orderByList?.call(AgentProposal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProposalTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentProposal>(
      where: where?.call(AgentProposal.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentProposal] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentProposalTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentProposal>(
      where: where(AgentProposal.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
