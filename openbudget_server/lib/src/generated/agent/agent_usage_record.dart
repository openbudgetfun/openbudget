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

import '../agent/agent_provider.dart' as _ice504k4;

/// Token usage and cost of one model call.
abstract class AgentUsageRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentUsageRecord._({
    this.id,
    required this.userId,
    this.conversationId,
    required this.provider,
    required this.model,
    required this.promptTokens,
    required this.cachedTokens,
    required this.completionTokens,
    required this.costMicroUsd,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentUsageRecord({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _is.UuidValue? conversationId,
    required _ice504k4.AgentProvider provider,
    required String model,
    required int promptTokens,
    required int cachedTokens,
    required int completionTokens,
    required int costMicroUsd,
    DateTime? createdAt,
  }) = _AgentUsageRecordImpl;

  factory AgentUsageRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentUsageRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['conversationId'],
            ),
      provider: _ice504k4.AgentProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      model: jsonSerialization['model'] as String,
      promptTokens: jsonSerialization['promptTokens'] as int,
      cachedTokens: jsonSerialization['cachedTokens'] as int,
      completionTokens: jsonSerialization['completionTokens'] as int,
      costMicroUsd: jsonSerialization['costMicroUsd'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AgentUsageRecordTable();

  static const db = AgentUsageRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _is.UuidValue? conversationId;

  _ice504k4.AgentProvider provider;

  String model;

  int promptTokens;

  /// Prompt tokens served from the provider's cache.
  int cachedTokens;

  int completionTokens;

  /// Cost in micro-dollars. BYO calls are recorded at zero.
  int costMicroUsd;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentUsageRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentUsageRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? conversationId = const _is.$UndefinedUuidValue(),
    _ice504k4.AgentProvider? provider,
    String? model,
    int? promptTokens,
    int? cachedTokens,
    int? completionTokens,
    int? costMicroUsd,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentUsageRecord',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'provider': provider.toJson(),
      'model': model,
      'promptTokens': promptTokens,
      'cachedTokens': cachedTokens,
      'completionTokens': completionTokens,
      'costMicroUsd': costMicroUsd,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentUsageRecord',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'provider': provider.toJson(),
      'model': model,
      'promptTokens': promptTokens,
      'cachedTokens': cachedTokens,
      'completionTokens': completionTokens,
      'costMicroUsd': costMicroUsd,
      'createdAt': createdAt.toJson(),
    };
  }

  static AgentUsageRecordInclude include() {
    return AgentUsageRecordInclude._();
  }

  static AgentUsageRecordIncludeList includeList({
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    AgentUsageRecordInclude? include,
  }) {
    return AgentUsageRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentUsageRecordImpl extends AgentUsageRecord {
  _AgentUsageRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    _is.UuidValue? conversationId,
    required _ice504k4.AgentProvider provider,
    required String model,
    required int promptTokens,
    required int cachedTokens,
    required int completionTokens,
    required int costMicroUsd,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         conversationId: conversationId,
         provider: provider,
         model: model,
         promptTokens: promptTokens,
         cachedTokens: cachedTokens,
         completionTokens: completionTokens,
         costMicroUsd: costMicroUsd,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AgentUsageRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentUsageRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _is.UuidValue? conversationId = const _is.$UndefinedUuidValue(),
    _ice504k4.AgentProvider? provider,
    String? model,
    int? promptTokens,
    int? cachedTokens,
    int? completionTokens,
    int? costMicroUsd,
    DateTime? createdAt,
  }) {
    return AgentUsageRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      conversationId: conversationId is _is.UndefinedSentinel
          ? this.conversationId
          : conversationId,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      promptTokens: promptTokens ?? this.promptTokens,
      cachedTokens: cachedTokens ?? this.cachedTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      costMicroUsd: costMicroUsd ?? this.costMicroUsd,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AgentUsageRecordUpdateTable
    extends _is.UpdateTable<AgentUsageRecordTable> {
  AgentUsageRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> conversationId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<_ice504k4.AgentProvider, _ice504k4.AgentProvider> provider(
    _ice504k4.AgentProvider value,
  ) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<String, String> model(String value) => _is.ColumnValue(
    table.model,
    value,
  );

  _is.ColumnValue<int, int> promptTokens(int value) => _is.ColumnValue(
    table.promptTokens,
    value,
  );

  _is.ColumnValue<int, int> cachedTokens(int value) => _is.ColumnValue(
    table.cachedTokens,
    value,
  );

  _is.ColumnValue<int, int> completionTokens(int value) => _is.ColumnValue(
    table.completionTokens,
    value,
  );

  _is.ColumnValue<int, int> costMicroUsd(int value) => _is.ColumnValue(
    table.costMicroUsd,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AgentUsageRecordTable extends _is.Table<_is.UuidValue?> {
  AgentUsageRecordTable({super.tableRelation})
    : super(tableName: 'agent_usage_record') {
    updateTable = AgentUsageRecordUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    conversationId = _is.ColumnUuid(
      'conversationId',
      this,
    );
    provider = _is.ColumnEnum(
      'provider',
      this,
      _is.EnumSerialization.byName,
    );
    model = _is.ColumnString(
      'model',
      this,
    );
    promptTokens = _is.ColumnInt(
      'promptTokens',
      this,
    );
    cachedTokens = _is.ColumnInt(
      'cachedTokens',
      this,
    );
    completionTokens = _is.ColumnInt(
      'completionTokens',
      this,
    );
    costMicroUsd = _is.ColumnInt(
      'costMicroUsd',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AgentUsageRecordUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnUuid conversationId;

  late final _is.ColumnEnum<_ice504k4.AgentProvider> provider;

  late final _is.ColumnString model;

  late final _is.ColumnInt promptTokens;

  /// Prompt tokens served from the provider's cache.
  late final _is.ColumnInt cachedTokens;

  late final _is.ColumnInt completionTokens;

  /// Cost in micro-dollars. BYO calls are recorded at zero.
  late final _is.ColumnInt costMicroUsd;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    conversationId,
    provider,
    model,
    promptTokens,
    cachedTokens,
    completionTokens,
    costMicroUsd,
    createdAt,
  ];
}

class AgentUsageRecordInclude extends _is.IncludeObject {
  AgentUsageRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentUsageRecord.t;
}

class AgentUsageRecordIncludeList extends _is.IncludeList {
  AgentUsageRecordIncludeList._({
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentUsageRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentUsageRecord.t;
}

class AgentUsageRecordRepository {
  const AgentUsageRecordRepository._();

  /// Returns a list of [AgentUsageRecord]s matching the given query parameters.
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
  Future<List<AgentUsageRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentUsageRecord>(
      where: where?.call(AgentUsageRecord.t),
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentUsageRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentUsageRecord.t`.
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
  _ida.Stream<List<AgentUsageRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentUsageRecord>(
      where: where?.call(AgentUsageRecord.t),
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentUsageRecord] matching the given query parameters.
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
  Future<AgentUsageRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentUsageRecord>(
      where: where?.call(AgentUsageRecord.t),
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentUsageRecord] by its [id] or null if no such row exists.
  Future<AgentUsageRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentUsageRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentUsageRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentUsageRecord]s will have their `id` fields set.
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
  Future<List<AgentUsageRecord>> insert(
    _is.DatabaseSession session,
    List<AgentUsageRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentUsageRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentUsageRecord] and returns the inserted row.
  ///
  /// The returned [AgentUsageRecord] will have its `id` field set.
  Future<AgentUsageRecord> insertRow(
    _is.DatabaseSession session,
    AgentUsageRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentUsageRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentUsageRecord]s in the list and returns the resulting rows.
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
  /// The returned [AgentUsageRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentUsageRecord>> upsert(
    _is.DatabaseSession session,
    List<AgentUsageRecord> rows, {
    required _is.ColumnSelections<AgentUsageRecordTable> conflictColumns,
    _is.ColumnSelections<AgentUsageRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentUsageRecord>(
      rows,
      conflictColumns: conflictColumns(AgentUsageRecord.t),
      updateColumns: updateColumns?.call(AgentUsageRecord.t),
      updateWhere: updateWhere?.call(AgentUsageRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentUsageRecord] and returns the resulting row.
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
  /// The returned [AgentUsageRecord] will have its `id` field set.
  Future<AgentUsageRecord?> upsertRow(
    _is.DatabaseSession session,
    AgentUsageRecord row, {
    required _is.ColumnSelections<AgentUsageRecordTable> conflictColumns,
    _is.ColumnSelections<AgentUsageRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentUsageRecord>(
      row,
      conflictColumns: conflictColumns(AgentUsageRecord.t),
      updateColumns: updateColumns?.call(AgentUsageRecord.t),
      updateWhere: updateWhere?.call(AgentUsageRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentUsageRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentUsageRecord>> update(
    _is.DatabaseSession session,
    List<AgentUsageRecord> rows, {
    _is.ColumnSelections<AgentUsageRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentUsageRecord>(
      rows,
      columns: columns?.call(AgentUsageRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentUsageRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentUsageRecord> updateRow(
    _is.DatabaseSession session,
    AgentUsageRecord row, {
    _is.ColumnSelections<AgentUsageRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentUsageRecord>(
      row,
      columns: columns?.call(AgentUsageRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentUsageRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentUsageRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentUsageRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentUsageRecord>(
      id,
      columnValues: columnValues(AgentUsageRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentUsageRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentUsageRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentUsageRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AgentUsageRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentUsageRecord>(
      columnValues: columnValues(AgentUsageRecord.t.updateTable),
      where: where(AgentUsageRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentUsageRecord]s in the list and returns the deleted rows.
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
  Future<List<AgentUsageRecord>> delete(
    _is.DatabaseSession session,
    List<AgentUsageRecord> rows, {
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentUsageRecord>(
      rows,
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentUsageRecord].
  Future<AgentUsageRecord> deleteRow(
    _is.DatabaseSession session,
    AgentUsageRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentUsageRecord>(
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
  Future<List<AgentUsageRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentUsageRecordTable> where,
    _is.OrderByBuilder<AgentUsageRecordTable>? orderBy,
    _is.OrderByListBuilder<AgentUsageRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentUsageRecord>(
      where: where(AgentUsageRecord.t),
      orderBy: orderBy?.call(AgentUsageRecord.t),
      orderByList: orderByList?.call(AgentUsageRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentUsageRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentUsageRecord>(
      where: where?.call(AgentUsageRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentUsageRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentUsageRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentUsageRecord>(
      where: where(AgentUsageRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
