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

/// A user's own OpenAI-compatible provider for the financial assistant.
///
/// The API key is encrypted with AES-256-GCM before it reaches the database
/// and is never returned to a client.
abstract class AgentProviderSettings
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AgentProviderSettings._({
    this.id,
    required this.userId,
    required this.baseUrl,
    required this.model,
    required this.encryptedApiKey,
    required this.nonce,
    required this.keyHint,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory AgentProviderSettings({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String baseUrl,
    required String model,
    required String encryptedApiKey,
    required String nonce,
    required String keyHint,
    DateTime? updatedAt,
  }) = _AgentProviderSettingsImpl;

  factory AgentProviderSettings.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentProviderSettings(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      baseUrl: jsonSerialization['baseUrl'] as String,
      model: jsonSerialization['model'] as String,
      encryptedApiKey: jsonSerialization['encryptedApiKey'] as String,
      nonce: jsonSerialization['nonce'] as String,
      keyHint: jsonSerialization['keyHint'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AgentProviderSettingsTable();

  static const db = AgentProviderSettingsRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  /// HTTPS base URL of the provider's OpenAI-compatible API.
  String baseUrl;

  String model;

  /// Base64 AES-GCM ciphertext of the API key, including its MAC tag.
  String encryptedApiKey;

  /// Base64 nonce used for encryptedApiKey.
  String nonce;

  /// The last four characters of the key, for display only.
  String keyHint;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AgentProviderSettings]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentProviderSettings copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? baseUrl,
    String? model,
    String? encryptedApiKey,
    String? nonce,
    String? keyHint,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProviderSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'baseUrl': baseUrl,
      'model': model,
      'encryptedApiKey': encryptedApiKey,
      'nonce': nonce,
      'keyHint': keyHint,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AgentProviderSettingsInclude include() {
    return AgentProviderSettingsInclude._();
  }

  static AgentProviderSettingsIncludeList includeList({
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    AgentProviderSettingsInclude? include,
  }) {
    return AgentProviderSettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentProviderSettingsImpl extends AgentProviderSettings {
  _AgentProviderSettingsImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String baseUrl,
    required String model,
    required String encryptedApiKey,
    required String nonce,
    required String keyHint,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         baseUrl: baseUrl,
         model: model,
         encryptedApiKey: encryptedApiKey,
         nonce: nonce,
         keyHint: keyHint,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AgentProviderSettings]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentProviderSettings copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? baseUrl,
    String? model,
    String? encryptedApiKey,
    String? nonce,
    String? keyHint,
    DateTime? updatedAt,
  }) {
    return AgentProviderSettings(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      encryptedApiKey: encryptedApiKey ?? this.encryptedApiKey,
      nonce: nonce ?? this.nonce,
      keyHint: keyHint ?? this.keyHint,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AgentProviderSettingsUpdateTable
    extends _is.UpdateTable<AgentProviderSettingsTable> {
  AgentProviderSettingsUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> baseUrl(String value) => _is.ColumnValue(
    table.baseUrl,
    value,
  );

  _is.ColumnValue<String, String> model(String value) => _is.ColumnValue(
    table.model,
    value,
  );

  _is.ColumnValue<String, String> encryptedApiKey(String value) =>
      _is.ColumnValue(
        table.encryptedApiKey,
        value,
      );

  _is.ColumnValue<String, String> nonce(String value) => _is.ColumnValue(
    table.nonce,
    value,
  );

  _is.ColumnValue<String, String> keyHint(String value) => _is.ColumnValue(
    table.keyHint,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AgentProviderSettingsTable extends _is.Table<_is.UuidValue?> {
  AgentProviderSettingsTable({super.tableRelation})
    : super(tableName: 'agent_provider_settings') {
    updateTable = AgentProviderSettingsUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    baseUrl = _is.ColumnString(
      'baseUrl',
      this,
    );
    model = _is.ColumnString(
      'model',
      this,
    );
    encryptedApiKey = _is.ColumnString(
      'encryptedApiKey',
      this,
    );
    nonce = _is.ColumnString(
      'nonce',
      this,
    );
    keyHint = _is.ColumnString(
      'keyHint',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final AgentProviderSettingsUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  /// HTTPS base URL of the provider's OpenAI-compatible API.
  late final _is.ColumnString baseUrl;

  late final _is.ColumnString model;

  /// Base64 AES-GCM ciphertext of the API key, including its MAC tag.
  late final _is.ColumnString encryptedApiKey;

  /// Base64 nonce used for encryptedApiKey.
  late final _is.ColumnString nonce;

  /// The last four characters of the key, for display only.
  late final _is.ColumnString keyHint;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    baseUrl,
    model,
    encryptedApiKey,
    nonce,
    keyHint,
    updatedAt,
  ];
}

class AgentProviderSettingsInclude extends _is.IncludeObject {
  AgentProviderSettingsInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentProviderSettings.t;
}

class AgentProviderSettingsIncludeList extends _is.IncludeList {
  AgentProviderSettingsIncludeList._({
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AgentProviderSettings.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AgentProviderSettings.t;
}

class AgentProviderSettingsRepository {
  const AgentProviderSettingsRepository._();

  /// Returns a list of [AgentProviderSettings]s matching the given query parameters.
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
  Future<List<AgentProviderSettings>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AgentProviderSettings>(
      where: where?.call(AgentProviderSettings.t),
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AgentProviderSettings]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AgentProviderSettings.t`.
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
  _ida.Stream<List<AgentProviderSettings>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AgentProviderSettings>(
      where: where?.call(AgentProviderSettings.t),
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AgentProviderSettings] matching the given query parameters.
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
  Future<AgentProviderSettings?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    int? offset,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AgentProviderSettings>(
      where: where?.call(AgentProviderSettings.t),
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AgentProviderSettings] by its [id] or null if no such row exists.
  Future<AgentProviderSettings?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AgentProviderSettings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AgentProviderSettings]s in the list and returns the inserted rows.
  ///
  /// The returned [AgentProviderSettings]s will have their `id` fields set.
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
  Future<List<AgentProviderSettings>> insert(
    _is.DatabaseSession session,
    List<AgentProviderSettings> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AgentProviderSettings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AgentProviderSettings] and returns the inserted row.
  ///
  /// The returned [AgentProviderSettings] will have its `id` field set.
  Future<AgentProviderSettings> insertRow(
    _is.DatabaseSession session,
    AgentProviderSettings row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AgentProviderSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AgentProviderSettings]s in the list and returns the resulting rows.
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
  /// The returned [AgentProviderSettings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProviderSettings>> upsert(
    _is.DatabaseSession session,
    List<AgentProviderSettings> rows, {
    required _is.ColumnSelections<AgentProviderSettingsTable> conflictColumns,
    _is.ColumnSelections<AgentProviderSettingsTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AgentProviderSettings>(
      rows,
      conflictColumns: conflictColumns(AgentProviderSettings.t),
      updateColumns: updateColumns?.call(AgentProviderSettings.t),
      updateWhere: updateWhere?.call(AgentProviderSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AgentProviderSettings] and returns the resulting row.
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
  /// The returned [AgentProviderSettings] will have its `id` field set.
  Future<AgentProviderSettings?> upsertRow(
    _is.DatabaseSession session,
    AgentProviderSettings row, {
    required _is.ColumnSelections<AgentProviderSettingsTable> conflictColumns,
    _is.ColumnSelections<AgentProviderSettingsTable>? updateColumns,
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AgentProviderSettings>(
      row,
      conflictColumns: conflictColumns(AgentProviderSettings.t),
      updateColumns: updateColumns?.call(AgentProviderSettings.t),
      updateWhere: updateWhere?.call(AgentProviderSettings.t),
      transaction: transaction,
    );
  }

  /// Updates all [AgentProviderSettings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProviderSettings>> update(
    _is.DatabaseSession session,
    List<AgentProviderSettings> rows, {
    _is.ColumnSelections<AgentProviderSettingsTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AgentProviderSettings>(
      rows,
      columns: columns?.call(AgentProviderSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AgentProviderSettings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AgentProviderSettings> updateRow(
    _is.DatabaseSession session,
    AgentProviderSettings row, {
    _is.ColumnSelections<AgentProviderSettingsTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AgentProviderSettings>(
      row,
      columns: columns?.call(AgentProviderSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AgentProviderSettings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AgentProviderSettings?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AgentProviderSettingsUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AgentProviderSettings>(
      id,
      columnValues: columnValues(AgentProviderSettings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AgentProviderSettings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AgentProviderSettings>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AgentProviderSettingsUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AgentProviderSettingsTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AgentProviderSettings>(
      columnValues: columnValues(AgentProviderSettings.t.updateTable),
      where: where(AgentProviderSettings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AgentProviderSettings]s in the list and returns the deleted rows.
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
  Future<List<AgentProviderSettings>> delete(
    _is.DatabaseSession session,
    List<AgentProviderSettings> rows, {
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AgentProviderSettings>(
      rows,
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AgentProviderSettings].
  Future<AgentProviderSettings> deleteRow(
    _is.DatabaseSession session,
    AgentProviderSettings row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AgentProviderSettings>(
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
  Future<List<AgentProviderSettings>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentProviderSettingsTable> where,
    _is.OrderByBuilder<AgentProviderSettingsTable>? orderBy,
    _is.OrderByListBuilder<AgentProviderSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AgentProviderSettings>(
      where: where(AgentProviderSettings.t),
      orderBy: orderBy?.call(AgentProviderSettings.t),
      orderByList: orderByList?.call(AgentProviderSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AgentProviderSettingsTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AgentProviderSettings>(
      where: where?.call(AgentProviderSettings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AgentProviderSettings] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AgentProviderSettingsTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AgentProviderSettings>(
      where: where(AgentProviderSettings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
