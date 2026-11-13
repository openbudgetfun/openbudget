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

import '../common/sync_status.dart' as _ijl385hj;

/// A read-only blockchain wallet whose holdings value one crypto account.
abstract class Wallet
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Wallet._({
    this.id,
    required this.entityId,
    required this.accountId,
    required this.network,
    required this.address,
    this.label,
    this.lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    this.lastSyncedAt,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : syncStatus = syncStatus ?? _ijl385hj.SyncStatus.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Wallet({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue accountId,
    required _ifz8weqz.WalletNetwork network,
    required String address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletImpl;

  factory Wallet.fromJson(Map<String, dynamic> jsonSerialization) {
    return Wallet(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      lastSignature: jsonSerialization['lastSignature'] as String?,
      syncStatus: jsonSerialization['syncStatus'] == null
          ? null
          : _ijl385hj.SyncStatus.fromJson(
              (jsonSerialization['syncStatus'] as String),
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      lastSyncError: jsonSerialization['lastSyncError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = WalletTable();

  static const db = WalletRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  /// The crypto account carrying the wallet's value into net worth.
  _is.UuidValue accountId;

  _ifz8weqz.WalletNetwork network;

  /// Base58 address.
  String address;

  String? label;

  /// Newest signature already processed, for incremental sync.
  String? lastSignature;

  _ijl385hj.SyncStatus syncStatus;

  DateTime? lastSyncedAt;

  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Wallet copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? accountId,
    _ifz8weqz.WalletNetwork? network,
    String? address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'network': network.toJson(),
      'address': address,
      if (label != null) 'label': label,
      if (lastSignature != null) 'lastSignature': lastSignature,
      'syncStatus': syncStatus.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'network': network.toJson(),
      'address': address,
      if (label != null) 'label': label,
      if (lastSignature != null) 'lastSignature': lastSignature,
      'syncStatus': syncStatus.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static WalletInclude include() {
    return WalletInclude._();
  }

  static WalletIncludeList includeList({
    _is.WhereExpressionBuilder<WalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    WalletInclude? include,
  }) {
    return WalletIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletImpl extends Wallet {
  _WalletImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue accountId,
    required _ifz8weqz.WalletNetwork network,
    required String address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         accountId: accountId,
         network: network,
         address: address,
         label: label,
         lastSignature: lastSignature,
         syncStatus: syncStatus,
         lastSyncedAt: lastSyncedAt,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Wallet copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? accountId,
    _ifz8weqz.WalletNetwork? network,
    String? address,
    Object? label = _Undefined,
    Object? lastSignature = _Undefined,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      accountId: accountId ?? this.accountId,
      network: network ?? this.network,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      lastSignature: lastSignature is String?
          ? lastSignature
          : this.lastSignature,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt is _is.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      lastSyncError: lastSyncError is String?
          ? lastSyncError
          : this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WalletUpdateTable extends _is.UpdateTable<WalletTable> {
  WalletUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.accountId,
    value,
  );

  _is.ColumnValue<_ifz8weqz.WalletNetwork, _ifz8weqz.WalletNetwork> network(
    _ifz8weqz.WalletNetwork value,
  ) => _is.ColumnValue(
    table.network,
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

  _is.ColumnValue<String, String> lastSignature(String? value) =>
      _is.ColumnValue(
        table.lastSignature,
        value,
      );

  _is.ColumnValue<_ijl385hj.SyncStatus, _ijl385hj.SyncStatus> syncStatus(
    _ijl385hj.SyncStatus value,
  ) => _is.ColumnValue(
    table.syncStatus,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
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

class WalletTable extends _is.Table<_is.UuidValue?> {
  WalletTable({super.tableRelation}) : super(tableName: 'wallet') {
    updateTable = WalletUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    accountId = _is.ColumnUuid(
      'accountId',
      this,
    );
    network = _is.ColumnEnum(
      'network',
      this,
      _is.EnumSerialization.byName,
    );
    address = _is.ColumnString(
      'address',
      this,
    );
    label = _is.ColumnString(
      'label',
      this,
    );
    lastSignature = _is.ColumnString(
      'lastSignature',
      this,
    );
    syncStatus = _is.ColumnEnum(
      'syncStatus',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
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

  late final WalletUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  /// The crypto account carrying the wallet's value into net worth.
  late final _is.ColumnUuid accountId;

  late final _is.ColumnEnum<_ifz8weqz.WalletNetwork> network;

  /// Base58 address.
  late final _is.ColumnString address;

  late final _is.ColumnString label;

  /// Newest signature already processed, for incremental sync.
  late final _is.ColumnString lastSignature;

  late final _is.ColumnEnum<_ijl385hj.SyncStatus> syncStatus;

  late final _is.ColumnDateTime lastSyncedAt;

  late final _is.ColumnString lastSyncError;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    accountId,
    network,
    address,
    label,
    lastSignature,
    syncStatus,
    lastSyncedAt,
    lastSyncError,
    createdAt,
    updatedAt,
  ];
}

class WalletInclude extends _is.IncludeObject {
  WalletInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Wallet.t;
}

class WalletIncludeList extends _is.IncludeList {
  WalletIncludeList._({
    _is.WhereExpressionBuilder<WalletTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Wallet.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Wallet.t;
}

class WalletRepository {
  const WalletRepository._();

  /// Returns a list of [Wallet]s matching the given query parameters.
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
  Future<List<Wallet>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Wallet>(
      where: where?.call(Wallet.t),
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Wallet]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Wallet.t`.
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
  _ida.Stream<List<Wallet>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Wallet>(
      where: where?.call(Wallet.t),
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Wallet] matching the given query parameters.
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
  Future<Wallet?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Wallet>(
      where: where?.call(Wallet.t),
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Wallet] by its [id] or null if no such row exists.
  Future<Wallet?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Wallet>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Wallet]s in the list and returns the inserted rows.
  ///
  /// The returned [Wallet]s will have their `id` fields set.
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
  Future<List<Wallet>> insert(
    _is.DatabaseSession session,
    List<Wallet> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Wallet>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Wallet] and returns the inserted row.
  ///
  /// The returned [Wallet] will have its `id` field set.
  Future<Wallet> insertRow(
    _is.DatabaseSession session,
    Wallet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Wallet>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Wallet]s in the list and returns the resulting rows.
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
  /// The returned [Wallet]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Wallet>> upsert(
    _is.DatabaseSession session,
    List<Wallet> rows, {
    required _is.ColumnSelections<WalletTable> conflictColumns,
    _is.ColumnSelections<WalletTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Wallet>(
      rows,
      conflictColumns: conflictColumns(Wallet.t),
      updateColumns: updateColumns?.call(Wallet.t),
      updateWhere: updateWhere?.call(Wallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Wallet] and returns the resulting row.
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
  /// The returned [Wallet] will have its `id` field set.
  Future<Wallet?> upsertRow(
    _is.DatabaseSession session,
    Wallet row, {
    required _is.ColumnSelections<WalletTable> conflictColumns,
    _is.ColumnSelections<WalletTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Wallet>(
      row,
      conflictColumns: conflictColumns(Wallet.t),
      updateColumns: updateColumns?.call(Wallet.t),
      updateWhere: updateWhere?.call(Wallet.t),
      transaction: transaction,
    );
  }

  /// Updates all [Wallet]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Wallet>> update(
    _is.DatabaseSession session,
    List<Wallet> rows, {
    _is.ColumnSelections<WalletTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Wallet>(
      rows,
      columns: columns?.call(Wallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Wallet]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Wallet> updateRow(
    _is.DatabaseSession session,
    Wallet row, {
    _is.ColumnSelections<WalletTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Wallet>(
      row,
      columns: columns?.call(Wallet.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Wallet] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Wallet?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Wallet>(
      id,
      columnValues: columnValues(Wallet.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Wallet]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Wallet>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WalletTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Wallet>(
      columnValues: columnValues(Wallet.t.updateTable),
      where: where(Wallet.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Wallet]s in the list and returns the deleted rows.
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
  Future<List<Wallet>> delete(
    _is.DatabaseSession session,
    List<Wallet> rows, {
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Wallet>(
      rows,
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Wallet].
  Future<Wallet> deleteRow(
    _is.DatabaseSession session,
    Wallet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Wallet>(
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
  Future<List<Wallet>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletTable> where,
    _is.OrderByBuilder<WalletTable>? orderBy,
    _is.OrderByListBuilder<WalletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Wallet>(
      where: where(Wallet.t),
      orderBy: orderBy?.call(Wallet.t),
      orderByList: orderByList?.call(Wallet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Wallet>(
      where: where?.call(Wallet.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Wallet] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Wallet>(
      where: where(Wallet.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
