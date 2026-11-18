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

import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod/serverpod.dart' as _is;

/// One network's read state for one wallet: when its holdings were last read,
/// why the last read failed, and where history sync stopped.
abstract class WalletNetworkState
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WalletNetworkState._({
    this.id,
    required this.walletId,
    required this.network,
    this.lastReadAt,
    this.lastError,
    this.historyCursor,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory WalletNetworkState({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    DateTime? lastReadAt,
    String? lastError,
    String? historyCursor,
    DateTime? updatedAt,
  }) = _WalletNetworkStateImpl;

  factory WalletNetworkState.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletNetworkState(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      lastReadAt: jsonSerialization['lastReadAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastReadAt']),
      lastError: jsonSerialization['lastError'] as String?,
      historyCursor: jsonSerialization['historyCursor'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = WalletNetworkStateTable();

  static const db = WalletNetworkStateRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletId;

  _ifz8weqz.WalletNetwork network;

  /// When holdings on this network were last read successfully.
  DateTime? lastReadAt;

  /// The last read's failure in plain words, cleared by the next success.
  String? lastError;

  /// Provider-defined history position (a block number, ledger index, page
  /// key or transaction id). Null until history sync covers this network.
  String? historyCursor;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletNetworkState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletNetworkState copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    DateTime? lastReadAt = const _is.$UndefinedDateTime(),
    String? lastError,
    String? historyCursor,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletNetworkState',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
      if (lastReadAt != null) 'lastReadAt': lastReadAt?.toJson(),
      if (lastError != null) 'lastError': lastError,
      if (historyCursor != null) 'historyCursor': historyCursor,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletNetworkState',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
      if (lastReadAt != null) 'lastReadAt': lastReadAt?.toJson(),
      if (lastError != null) 'lastError': lastError,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static WalletNetworkStateInclude include() {
    return WalletNetworkStateInclude._();
  }

  static WalletNetworkStateIncludeList includeList({
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    WalletNetworkStateInclude? include,
  }) {
    return WalletNetworkStateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletNetworkStateImpl extends WalletNetworkState {
  _WalletNetworkStateImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    DateTime? lastReadAt,
    String? lastError,
    String? historyCursor,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         network: network,
         lastReadAt: lastReadAt,
         lastError: lastError,
         historyCursor: historyCursor,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WalletNetworkState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletNetworkState copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    DateTime? lastReadAt = const _is.$UndefinedDateTime(),
    Object? lastError = _Undefined,
    Object? historyCursor = _Undefined,
    DateTime? updatedAt,
  }) {
    return WalletNetworkState(
      id: id is _is.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      network: network ?? this.network,
      lastReadAt: lastReadAt is _is.UndefinedSentinel
          ? this.lastReadAt
          : lastReadAt,
      lastError: lastError is String? ? lastError : this.lastError,
      historyCursor: historyCursor is String?
          ? historyCursor
          : this.historyCursor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WalletNetworkStateUpdateTable
    extends _is.UpdateTable<WalletNetworkStateTable> {
  WalletNetworkStateUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.walletId,
        value,
      );

  _is.ColumnValue<_ifz8weqz.WalletNetwork, _ifz8weqz.WalletNetwork> network(
    _ifz8weqz.WalletNetwork value,
  ) => _is.ColumnValue(
    table.network,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastReadAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastReadAt,
        value,
      );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<String, String> historyCursor(String? value) =>
      _is.ColumnValue(
        table.historyCursor,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class WalletNetworkStateTable extends _is.Table<_is.UuidValue?> {
  WalletNetworkStateTable({super.tableRelation})
    : super(tableName: 'wallet_network_state') {
    updateTable = WalletNetworkStateUpdateTable(this);
    walletId = _is.ColumnUuid(
      'walletId',
      this,
    );
    network = _is.ColumnEnum(
      'network',
      this,
      _is.EnumSerialization.byName,
    );
    lastReadAt = _is.ColumnDateTime(
      'lastReadAt',
      this,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    historyCursor = _is.ColumnString(
      'historyCursor',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final WalletNetworkStateUpdateTable updateTable;

  late final _is.ColumnUuid walletId;

  late final _is.ColumnEnum<_ifz8weqz.WalletNetwork> network;

  /// When holdings on this network were last read successfully.
  late final _is.ColumnDateTime lastReadAt;

  /// The last read's failure in plain words, cleared by the next success.
  late final _is.ColumnString lastError;

  /// Provider-defined history position (a block number, ledger index, page
  /// key or transaction id). Null until history sync covers this network.
  late final _is.ColumnString historyCursor;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    walletId,
    network,
    lastReadAt,
    lastError,
    historyCursor,
    updatedAt,
  ];
}

class WalletNetworkStateInclude extends _is.IncludeObject {
  WalletNetworkStateInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletNetworkState.t;
}

class WalletNetworkStateIncludeList extends _is.IncludeList {
  WalletNetworkStateIncludeList._({
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletNetworkState.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletNetworkState.t;
}

class WalletNetworkStateRepository {
  const WalletNetworkStateRepository._();

  /// Returns a list of [WalletNetworkState]s matching the given query parameters.
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
  Future<List<WalletNetworkState>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletNetworkState>(
      where: where?.call(WalletNetworkState.t),
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [WalletNetworkState]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `WalletNetworkState.t`.
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
  _ida.Stream<List<WalletNetworkState>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<WalletNetworkState>(
      where: where?.call(WalletNetworkState.t),
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [WalletNetworkState] matching the given query parameters.
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
  Future<WalletNetworkState?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletNetworkState>(
      where: where?.call(WalletNetworkState.t),
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletNetworkState] by its [id] or null if no such row exists.
  Future<WalletNetworkState?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WalletNetworkState>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WalletNetworkState]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletNetworkState]s will have their `id` fields set.
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
  Future<List<WalletNetworkState>> insert(
    _is.DatabaseSession session,
    List<WalletNetworkState> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WalletNetworkState>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WalletNetworkState] and returns the inserted row.
  ///
  /// The returned [WalletNetworkState] will have its `id` field set.
  Future<WalletNetworkState> insertRow(
    _is.DatabaseSession session,
    WalletNetworkState row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletNetworkState>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WalletNetworkState]s in the list and returns the resulting rows.
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
  /// The returned [WalletNetworkState]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletNetworkState>> upsert(
    _is.DatabaseSession session,
    List<WalletNetworkState> rows, {
    required _is.ColumnSelections<WalletNetworkStateTable> conflictColumns,
    _is.ColumnSelections<WalletNetworkStateTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WalletNetworkState>(
      rows,
      conflictColumns: conflictColumns(WalletNetworkState.t),
      updateColumns: updateColumns?.call(WalletNetworkState.t),
      updateWhere: updateWhere?.call(WalletNetworkState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WalletNetworkState] and returns the resulting row.
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
  /// The returned [WalletNetworkState] will have its `id` field set.
  Future<WalletNetworkState?> upsertRow(
    _is.DatabaseSession session,
    WalletNetworkState row, {
    required _is.ColumnSelections<WalletNetworkStateTable> conflictColumns,
    _is.ColumnSelections<WalletNetworkStateTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WalletNetworkState>(
      row,
      conflictColumns: conflictColumns(WalletNetworkState.t),
      updateColumns: updateColumns?.call(WalletNetworkState.t),
      updateWhere: updateWhere?.call(WalletNetworkState.t),
      transaction: transaction,
    );
  }

  /// Updates all [WalletNetworkState]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletNetworkState>> update(
    _is.DatabaseSession session,
    List<WalletNetworkState> rows, {
    _is.ColumnSelections<WalletNetworkStateTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WalletNetworkState>(
      rows,
      columns: columns?.call(WalletNetworkState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WalletNetworkState]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletNetworkState> updateRow(
    _is.DatabaseSession session,
    WalletNetworkState row, {
    _is.ColumnSelections<WalletNetworkStateTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WalletNetworkState>(
      row,
      columns: columns?.call(WalletNetworkState.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletNetworkState] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WalletNetworkState?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletNetworkStateUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletNetworkState>(
      id,
      columnValues: columnValues(WalletNetworkState.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletNetworkState]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletNetworkState>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletNetworkStateUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WalletNetworkStateTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WalletNetworkState>(
      columnValues: columnValues(WalletNetworkState.t.updateTable),
      where: where(WalletNetworkState.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WalletNetworkState]s in the list and returns the deleted rows.
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
  Future<List<WalletNetworkState>> delete(
    _is.DatabaseSession session,
    List<WalletNetworkState> rows, {
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WalletNetworkState>(
      rows,
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WalletNetworkState].
  Future<WalletNetworkState> deleteRow(
    _is.DatabaseSession session,
    WalletNetworkState row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletNetworkState>(
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
  Future<List<WalletNetworkState>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletNetworkStateTable> where,
    _is.OrderByBuilder<WalletNetworkStateTable>? orderBy,
    _is.OrderByListBuilder<WalletNetworkStateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WalletNetworkState>(
      where: where(WalletNetworkState.t),
      orderBy: orderBy?.call(WalletNetworkState.t),
      orderByList: orderByList?.call(WalletNetworkState.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletNetworkStateTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WalletNetworkState>(
      where: where?.call(WalletNetworkState.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletNetworkState] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletNetworkStateTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletNetworkState>(
      where: where(WalletNetworkState.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
