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

/// Read-only blockchain wallet connection.
abstract class WalletConnection
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WalletConnection._({
    this.id,
    required this.budgetId,
    required this.chain,
    required this.address,
    this.label,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncedAt,
    this.syncStatus,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletConnection({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required String chain,
    required String address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    String? syncStatus,
    String? lastError,
  }) = _WalletConnectionImpl;

  factory WalletConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      chain: jsonSerialization['chain'] as String,
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
    );
  }

  static final t = WalletConnectionTable();

  static const db = WalletConnectionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue budgetId;

  String chain;

  String address;

  String? label;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastSyncedAt;

  String? syncStatus;

  String? lastError;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletConnection copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    String? chain,
    String? address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? syncStatus,
    String? lastError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'chain': chain,
      'address': address,
      if (label != null) 'label': label,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (lastError != null) 'lastError': lastError,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'chain': chain,
      'address': address,
      if (label != null) 'label': label,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (lastError != null) 'lastError': lastError,
    };
  }

  static WalletConnectionInclude include() {
    return WalletConnectionInclude._();
  }

  static WalletConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    WalletConnectionInclude? include,
  }) {
    return WalletConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletConnectionImpl extends WalletConnection {
  _WalletConnectionImpl({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required String chain,
    required String address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    String? syncStatus,
    String? lastError,
  }) : super._(
         id: id,
         budgetId: budgetId,
         chain: chain,
         address: address,
         label: label,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         lastError: lastError,
       );

  /// Returns a shallow copy of this [WalletConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletConnection copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    String? chain,
    String? address,
    Object? label = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    Object? syncStatus = _Undefined,
    Object? lastError = _Undefined,
  }) {
    return WalletConnection(
      id: id is _is.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      chain: chain ?? this.chain,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt is _is.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      lastError: lastError is String? ? lastError : this.lastError,
    );
  }
}

class WalletConnectionUpdateTable
    extends _is.UpdateTable<WalletConnectionTable> {
  WalletConnectionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<String, String> chain(String value) => _is.ColumnValue(
    table.chain,
    value,
  );

  _is.ColumnValue<String, String> address(String value) => _is.ColumnValue(
    table.address,
    value,
  );

  _is.ColumnValue<String, String> label(String? value) => _is.ColumnValue(
    table.label,
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

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _is.ColumnValue<String, String> syncStatus(String? value) => _is.ColumnValue(
    table.syncStatus,
    value,
  );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );
}

class WalletConnectionTable extends _is.Table<_is.UuidValue?> {
  WalletConnectionTable({super.tableRelation})
    : super(tableName: 'wallet_connection') {
    updateTable = WalletConnectionUpdateTable(this);
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    chain = _is.ColumnString(
      'chain',
      this,
    );
    address = _is.ColumnString(
      'address',
      this,
    );
    label = _is.ColumnString(
      'label',
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
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _is.ColumnString(
      'syncStatus',
      this,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
  }

  late final WalletConnectionUpdateTable updateTable;

  late final _is.ColumnUuid budgetId;

  late final _is.ColumnString chain;

  late final _is.ColumnString address;

  late final _is.ColumnString label;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime lastSyncedAt;

  late final _is.ColumnString syncStatus;

  late final _is.ColumnString lastError;

  @override
  List<_is.Column> get columns => [
    id,
    budgetId,
    chain,
    address,
    label,
    createdAt,
    updatedAt,
    lastSyncedAt,
    syncStatus,
    lastError,
  ];
}

class WalletConnectionInclude extends _is.IncludeObject {
  WalletConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletConnection.t;
}

class WalletConnectionIncludeList extends _is.IncludeList {
  WalletConnectionIncludeList._({
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletConnection.t;
}

class WalletConnectionRepository {
  const WalletConnectionRepository._();

  /// Returns a list of [WalletConnection]s matching the given query parameters.
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
  Future<List<WalletConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletConnection>(
      where: where?.call(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [WalletConnection]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `WalletConnection.t`.
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
  _ida.Stream<List<WalletConnection>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<WalletConnection>(
      where: where?.call(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [WalletConnection] matching the given query parameters.
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
  Future<WalletConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletConnection>(
      where: where?.call(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletConnection] by its [id] or null if no such row exists.
  Future<WalletConnection?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WalletConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WalletConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletConnection]s will have their `id` fields set.
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
  Future<List<WalletConnection>> insert(
    _is.DatabaseSession session,
    List<WalletConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WalletConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WalletConnection] and returns the inserted row.
  ///
  /// The returned [WalletConnection] will have its `id` field set.
  Future<WalletConnection> insertRow(
    _is.DatabaseSession session,
    WalletConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WalletConnection]s in the list and returns the resulting rows.
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
  /// The returned [WalletConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletConnection>> upsert(
    _is.DatabaseSession session,
    List<WalletConnection> rows, {
    required _is.ColumnSelections<WalletConnectionTable> conflictColumns,
    _is.ColumnSelections<WalletConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WalletConnection>(
      rows,
      conflictColumns: conflictColumns(WalletConnection.t),
      updateColumns: updateColumns?.call(WalletConnection.t),
      updateWhere: updateWhere?.call(WalletConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WalletConnection] and returns the resulting row.
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
  /// The returned [WalletConnection] will have its `id` field set.
  Future<WalletConnection?> upsertRow(
    _is.DatabaseSession session,
    WalletConnection row, {
    required _is.ColumnSelections<WalletConnectionTable> conflictColumns,
    _is.ColumnSelections<WalletConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WalletConnection>(
      row,
      conflictColumns: conflictColumns(WalletConnection.t),
      updateColumns: updateColumns?.call(WalletConnection.t),
      updateWhere: updateWhere?.call(WalletConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [WalletConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletConnection>> update(
    _is.DatabaseSession session,
    List<WalletConnection> rows, {
    _is.ColumnSelections<WalletConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WalletConnection>(
      rows,
      columns: columns?.call(WalletConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WalletConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletConnection> updateRow(
    _is.DatabaseSession session,
    WalletConnection row, {
    _is.ColumnSelections<WalletConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WalletConnection>(
      row,
      columns: columns?.call(WalletConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WalletConnection?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletConnectionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletConnection>(
      id,
      columnValues: columnValues(WalletConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletConnectionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WalletConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WalletConnection>(
      columnValues: columnValues(WalletConnection.t.updateTable),
      where: where(WalletConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WalletConnection]s in the list and returns the deleted rows.
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
  Future<List<WalletConnection>> delete(
    _is.DatabaseSession session,
    List<WalletConnection> rows, {
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WalletConnection>(
      rows,
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WalletConnection].
  Future<WalletConnection> deleteRow(
    _is.DatabaseSession session,
    WalletConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletConnection>(
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
  Future<List<WalletConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletConnectionTable> where,
    _is.OrderByBuilder<WalletConnectionTable>? orderBy,
    _is.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WalletConnection>(
      where: where(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WalletConnection>(
      where: where?.call(WalletConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletConnection>(
      where: where(WalletConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
