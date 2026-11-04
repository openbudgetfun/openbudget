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

/// A Solana wallet linked to an OpenBudget account.
abstract class SolanaWallet
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  SolanaWallet._({
    this.id,
    required this.accountId,
    required this.budgetId,
    required this.address,
    this.label,
    required this.cluster,
    this.lastSignature,
    this.lastSyncedAt,
    required this.syncStatus,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory SolanaWallet({
    _is.UuidValue? id,
    required _is.UuidValue accountId,
    required _is.UuidValue budgetId,
    required String address,
    String? label,
    required String cluster,
    String? lastSignature,
    DateTime? lastSyncedAt,
    required String syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SolanaWalletImpl;

  factory SolanaWallet.fromJson(Map<String, dynamic> jsonSerialization) {
    return SolanaWallet(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      cluster: jsonSerialization['cluster'] as String,
      lastSignature: jsonSerialization['lastSignature'] as String?,
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String,
      lastSyncError: jsonSerialization['lastSyncError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletTable();

  static const db = SolanaWalletRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue accountId;

  _is.UuidValue budgetId;

  /// Solana wallet address (base58).
  String address;

  /// Optional wallet label shown in the UI.
  String? label;

  /// Solana cluster: mainnet or devnet.
  String cluster;

  /// Last processed signature for incremental syncing.
  String? lastSignature;

  /// Last successful sync timestamp.
  DateTime? lastSyncedAt;

  /// Current sync status: pending, success, error.
  String syncStatus;

  /// Last sync error, if any.
  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWallet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SolanaWallet copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? accountId,
    _is.UuidValue? budgetId,
    String? address,
    String? label,
    String? cluster,
    String? lastSignature,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWallet',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'budgetId': budgetId.toJson(),
      'address': address,
      if (label != null) 'label': label,
      'cluster': cluster,
      if (lastSignature != null) 'lastSignature': lastSignature,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncStatus': syncStatus,
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWallet',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'budgetId': budgetId.toJson(),
      'address': address,
      if (label != null) 'label': label,
      'cluster': cluster,
      if (lastSignature != null) 'lastSignature': lastSignature,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncStatus': syncStatus,
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SolanaWalletInclude include() {
    return SolanaWalletInclude._();
  }

  static SolanaWalletIncludeList includeList({
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    SolanaWalletInclude? include,
  }) {
    return SolanaWalletIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletImpl extends SolanaWallet {
  _SolanaWalletImpl({
    _is.UuidValue? id,
    required _is.UuidValue accountId,
    required _is.UuidValue budgetId,
    required String address,
    String? label,
    required String cluster,
    String? lastSignature,
    DateTime? lastSyncedAt,
    required String syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         accountId: accountId,
         budgetId: budgetId,
         address: address,
         label: label,
         cluster: cluster,
         lastSignature: lastSignature,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SolanaWallet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SolanaWallet copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? accountId,
    _is.UuidValue? budgetId,
    String? address,
    Object? label = _Undefined,
    String? cluster,
    Object? lastSignature = _Undefined,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? syncStatus,
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolanaWallet(
      id: id is _is.UndefinedSentinel ? this.id : id,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      cluster: cluster ?? this.cluster,
      lastSignature: lastSignature is String?
          ? lastSignature
          : this.lastSignature,
      lastSyncedAt: lastSyncedAt is _is.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: lastSyncError is String?
          ? lastSyncError
          : this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SolanaWalletUpdateTable extends _is.UpdateTable<SolanaWalletTable> {
  SolanaWalletUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.accountId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
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

  _is.ColumnValue<String, String> cluster(String value) => _is.ColumnValue(
    table.cluster,
    value,
  );

  _is.ColumnValue<String, String> lastSignature(String? value) =>
      _is.ColumnValue(
        table.lastSignature,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _is.ColumnValue<String, String> syncStatus(String value) => _is.ColumnValue(
    table.syncStatus,
    value,
  );

  _is.ColumnValue<String, String> lastSyncError(String? value) =>
      _is.ColumnValue(
        table.lastSyncError,
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

class SolanaWalletTable extends _is.Table<_is.UuidValue?> {
  SolanaWalletTable({super.tableRelation}) : super(tableName: 'solana_wallet') {
    updateTable = SolanaWalletUpdateTable(this);
    accountId = _is.ColumnUuid(
      'accountId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
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
    cluster = _is.ColumnString(
      'cluster',
      this,
    );
    lastSignature = _is.ColumnString(
      'lastSignature',
      this,
    );
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _is.ColumnString(
      'syncStatus',
      this,
    );
    lastSyncError = _is.ColumnString(
      'lastSyncError',
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

  late final SolanaWalletUpdateTable updateTable;

  late final _is.ColumnUuid accountId;

  late final _is.ColumnUuid budgetId;

  /// Solana wallet address (base58).
  late final _is.ColumnString address;

  /// Optional wallet label shown in the UI.
  late final _is.ColumnString label;

  /// Solana cluster: mainnet or devnet.
  late final _is.ColumnString cluster;

  /// Last processed signature for incremental syncing.
  late final _is.ColumnString lastSignature;

  /// Last successful sync timestamp.
  late final _is.ColumnDateTime lastSyncedAt;

  /// Current sync status: pending, success, error.
  late final _is.ColumnString syncStatus;

  /// Last sync error, if any.
  late final _is.ColumnString lastSyncError;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    accountId,
    budgetId,
    address,
    label,
    cluster,
    lastSignature,
    lastSyncedAt,
    syncStatus,
    lastSyncError,
    createdAt,
    updatedAt,
  ];
}

class SolanaWalletInclude extends _is.IncludeObject {
  SolanaWalletInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWallet.t;
}

class SolanaWalletIncludeList extends _is.IncludeList {
  SolanaWalletIncludeList._({
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWallet.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWallet.t;
}

class SolanaWalletRepository {
  const SolanaWalletRepository._();

  /// Returns a list of [SolanaWallet]s matching the given query parameters.
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
  Future<List<SolanaWallet>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SolanaWallet]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SolanaWallet.t`.
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
  _ida.Stream<List<SolanaWallet>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SolanaWallet] matching the given query parameters.
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
  Future<SolanaWallet?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWallet] by its [id] or null if no such row exists.
  Future<SolanaWallet?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SolanaWallet>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SolanaWallet]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaWallet]s will have their `id` fields set.
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
  Future<List<SolanaWallet>> insert(
    _is.DatabaseSession session,
    List<SolanaWallet> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SolanaWallet>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SolanaWallet] and returns the inserted row.
  ///
  /// The returned [SolanaWallet] will have its `id` field set.
  Future<SolanaWallet> insertRow(
    _is.DatabaseSession session,
    SolanaWallet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWallet>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SolanaWallet]s in the list and returns the resulting rows.
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
  /// The returned [SolanaWallet]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWallet>> upsert(
    _is.DatabaseSession session,
    List<SolanaWallet> rows, {
    required _is.ColumnSelections<SolanaWalletTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SolanaWallet>(
      rows,
      conflictColumns: conflictColumns(SolanaWallet.t),
      updateColumns: updateColumns?.call(SolanaWallet.t),
      updateWhere: updateWhere?.call(SolanaWallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SolanaWallet] and returns the resulting row.
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
  /// The returned [SolanaWallet] will have its `id` field set.
  Future<SolanaWallet?> upsertRow(
    _is.DatabaseSession session,
    SolanaWallet row, {
    required _is.ColumnSelections<SolanaWalletTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SolanaWallet>(
      row,
      conflictColumns: conflictColumns(SolanaWallet.t),
      updateColumns: updateColumns?.call(SolanaWallet.t),
      updateWhere: updateWhere?.call(SolanaWallet.t),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWallet]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWallet>> update(
    _is.DatabaseSession session,
    List<SolanaWallet> rows, {
    _is.ColumnSelections<SolanaWalletTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SolanaWallet>(
      rows,
      columns: columns?.call(SolanaWallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SolanaWallet]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWallet> updateRow(
    _is.DatabaseSession session,
    SolanaWallet row, {
    _is.ColumnSelections<SolanaWalletTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaWallet>(
      row,
      columns: columns?.call(SolanaWallet.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWallet] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaWallet?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SolanaWalletUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWallet>(
      id,
      columnValues: columnValues(SolanaWallet.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWallet]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWallet>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SolanaWalletUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SolanaWalletTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SolanaWallet>(
      columnValues: columnValues(SolanaWallet.t.updateTable),
      where: where(SolanaWallet.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SolanaWallet]s in the list and returns the deleted rows.
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
  Future<List<SolanaWallet>> delete(
    _is.DatabaseSession session,
    List<SolanaWallet> rows, {
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SolanaWallet>(
      rows,
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SolanaWallet].
  Future<SolanaWallet> deleteRow(
    _is.DatabaseSession session,
    SolanaWallet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWallet>(
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
  Future<List<SolanaWallet>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletTable> where,
    _is.OrderByBuilder<SolanaWalletTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SolanaWallet>(
      where: where(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWallet] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWallet>(
      where: where(SolanaWallet.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
