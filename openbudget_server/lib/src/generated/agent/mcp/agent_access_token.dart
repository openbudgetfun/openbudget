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

/// A personal access token an external agent uses to reach the MCP server.
///
/// Only the SHA-256 hash is stored, so a lost token can never be recovered,
/// only revoked and replaced.
abstract class AgentAccessToken
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentAccessToken._({
    this.id,
    required this.userId,
    required this.name,
    required this.tokenHash,
    required this.tokenPrefix,
    required this.canPropose,
    DateTime? createdAt,
    this.lastUsedAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentAccessToken({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required bool canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) = _AgentAccessTokenImpl;

  factory AgentAccessToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentAccessToken(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      canPropose: _is.BoolJsonExtension.fromJson(
        jsonSerialization['canPropose'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = AgentAccessTokenTable();

  static const db = AgentAccessTokenRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  /// The user's label for the client, such as "Claude Code".
  String name;

  /// Lowercase hex SHA-256 of the full token.
  String tokenHash;

  /// The token's first 12 characters, for display only.
  String tokenPrefix;

  /// Whether the token may call the assistant's propose tools.
  bool canPropose;

  DateTime createdAt;

  /// Last time the token authenticated an MCP request.
  DateTime? lastUsedAt;

  /// When the user revoked it. Revoked tokens never authenticate again.
  DateTime? revokedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentAccessToken]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentAccessToken copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAccessToken',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'canPropose': canPropose,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentAccessToken',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'canPropose': canPropose,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  static AgentAccessTokenInclude include() {
    return AgentAccessTokenInclude._();
  }

  static AgentAccessTokenIncludeList includeList({
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    AgentAccessTokenInclude? include,
  }) {
    return AgentAccessTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentAccessTokenImpl extends AgentAccessToken {
  _AgentAccessTokenImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required bool canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         userId: userId,
         name: name,
         tokenHash: tokenHash,
         tokenPrefix: tokenPrefix,
         canPropose: canPropose,
         createdAt: createdAt,
         lastUsedAt: lastUsedAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [AgentAccessToken]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentAccessToken copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  }) {
    return AgentAccessToken(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      canPropose: canPropose ?? this.canPropose,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt is _is.UndefinedSentinel
          ? this.lastUsedAt
          : lastUsedAt,
      revokedAt: revokedAt is _is.UndefinedSentinel
          ? this.revokedAt
          : revokedAt,
    );
  }
}

class AgentAccessTokenUpdateTable
    extends _is.UpdateTable<AgentAccessTokenTable> {
  AgentAccessTokenUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<String, String> tokenPrefix(String value) => _is.ColumnValue(
    table.tokenPrefix,
    value,
  );

  _is.ColumnValue<bool, bool> canPropose(bool value) => _is.ColumnValue(
    table.canPropose,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastUsedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastUsedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class AgentAccessTokenTable extends _is.Table<_is.UuidValue?> {
  AgentAccessTokenTable({super.tableRelation})
    : super(tableName: 'agent_access_token') {
    updateTable = AgentAccessTokenUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    tokenPrefix = _is.ColumnString(
      'tokenPrefix',
      this,
    );
    canPropose = _is.ColumnBool(
      'canPropose',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    lastUsedAt = _is.ColumnDateTime(
      'lastUsedAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
  }

  late final AgentAccessTokenUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  /// The user's label for the client, such as "Claude Code".
  late final _is.ColumnString name;

  /// Lowercase hex SHA-256 of the full token.
  late final _is.ColumnString tokenHash;

  /// The token's first 12 characters, for display only.
  late final _is.ColumnString tokenPrefix;

  /// Whether the token may call the assistant's propose tools.
  late final _is.ColumnBool canPropose;

  late final _is.ColumnDateTime createdAt;

  /// Last time the token authenticated an MCP request.
  late final _is.ColumnDateTime lastUsedAt;

  /// When the user revoked it. Revoked tokens never authenticate again.
  late final _is.ColumnDateTime revokedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    name,
    tokenHash,
    tokenPrefix,
    canPropose,
    createdAt,
    lastUsedAt,
    revokedAt,
  ];
}

class AgentAccessTokenInclude extends _is.IncludeObject {
  AgentAccessTokenInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentAccessToken.t;
}

class AgentAccessTokenIncludeList extends _is.IncludeList {
  AgentAccessTokenIncludeList._({
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentAccessToken.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentAccessToken.t;
}

class AgentAccessTokenRepository {
  const AgentAccessTokenRepository._();

  /// Returns a list of [AgentAccessToken]s matching the given query parameters.
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
  Future<List<AgentAccessToken>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentAccessToken>(
      where: where?.call(AgentAccessToken.t),
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentAccessToken]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentAccessToken.t`.
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
  _ida.Stream<List<AgentAccessToken>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentAccessToken>(
      where: where?.call(AgentAccessToken.t),
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentAccessToken] matching the given query parameters.
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
  Future<AgentAccessToken?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentAccessToken>(
      where: where?.call(AgentAccessToken.t),
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentAccessToken] by its [id] or null if no such row exists.
  Future<AgentAccessToken?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentAccessToken>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentAccessToken]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentAccessToken]s will have their `id` fields set.
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
  Future<List<AgentAccessToken>> insert(
    _is.DatabaseSession session,
    List<AgentAccessToken> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentAccessToken>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentAccessToken] and returns the inserted row.
  ///
  /// The returned [AgentAccessToken] will have its `id` field set.
  Future<AgentAccessToken> insertRow(
    _is.DatabaseSession session,
    AgentAccessToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentAccessToken>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentAccessToken]s in the list and returns the resulting rows.
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
  /// The returned [AgentAccessToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAccessToken>> upsert(
    _is.DatabaseSession session,
    List<AgentAccessToken> rows, {
    required _is.ColumnSelections<AgentAccessTokenTable> conflictColumns,
    _is.ColumnSelections<AgentAccessTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentAccessToken>(
      rows,
      conflictColumns: conflictColumns(AgentAccessToken.t),
      updateColumns: updateColumns?.call(AgentAccessToken.t),
      updateWhere: updateWhere?.call(AgentAccessToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentAccessToken] and returns the resulting row.
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
  /// The returned [AgentAccessToken] will have its `id` field set.
  Future<AgentAccessToken?> upsertRow(
    _is.DatabaseSession session,
    AgentAccessToken row, {
    required _is.ColumnSelections<AgentAccessTokenTable> conflictColumns,
    _is.ColumnSelections<AgentAccessTokenTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentAccessToken>(
      row,
      conflictColumns: conflictColumns(AgentAccessToken.t),
      updateColumns: updateColumns?.call(AgentAccessToken.t),
      updateWhere: updateWhere?.call(AgentAccessToken.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentAccessToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAccessToken>> update(
    _is.DatabaseSession session,
    List<AgentAccessToken> rows, {
    _is.ColumnSelections<AgentAccessTokenTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentAccessToken>(
      rows,
      columns: columns?.call(AgentAccessToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentAccessToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentAccessToken> updateRow(
    _is.DatabaseSession session,
    AgentAccessToken row, {
    _is.ColumnSelections<AgentAccessTokenTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentAccessToken>(
      row,
      columns: columns?.call(AgentAccessToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentAccessToken] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentAccessToken?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentAccessTokenUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentAccessToken>(
      id,
      columnValues: columnValues(AgentAccessToken.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentAccessToken]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentAccessToken>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentAccessTokenUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AgentAccessTokenTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentAccessToken>(
      columnValues: columnValues(AgentAccessToken.t.updateTable),
      where: where(AgentAccessToken.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentAccessToken]s in the list and returns the deleted rows.
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
  Future<List<AgentAccessToken>> delete(
    _is.DatabaseSession session,
    List<AgentAccessToken> rows, {
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentAccessToken>(
      rows,
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentAccessToken].
  Future<AgentAccessToken> deleteRow(
    _is.DatabaseSession session,
    AgentAccessToken row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentAccessToken>(
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
  Future<List<AgentAccessToken>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentAccessTokenTable> where,
    _is.OrderByBuilder<AgentAccessTokenTable>? orderBy,
    _is.OrderByListBuilder<AgentAccessTokenTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentAccessToken>(
      where: where(AgentAccessToken.t),
      orderBy: orderBy?.call(AgentAccessToken.t),
      orderByList: orderByList?.call(AgentAccessToken.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentAccessTokenTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentAccessToken>(
      where: where?.call(AgentAccessToken.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentAccessToken] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentAccessTokenTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentAccessToken>(
      where: where(AgentAccessToken.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
