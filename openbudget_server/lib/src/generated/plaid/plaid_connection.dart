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

import '../common/sync_status.dart' as _ijl385hj;

/// A Plaid item linked to an entity, for syncing its bank accounts.
abstract class PlaidConnection
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  PlaidConnection._({
    this.id,
    required this.entityId,
    required this.plaidItemId,
    this.accessTokenCiphertext,
    this.accessTokenNonce,
    this.plaidInstitutionId,
    this.institutionName,
    this.transactionsCursor,
    _ijl385hj.SyncStatus? syncStatus,
    this.lastSyncedAt,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : syncStatus = syncStatus ?? _ijl385hj.SyncStatus.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PlaidConnection({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String plaidItemId,
    String? accessTokenCiphertext,
    String? accessTokenNonce,
    String? plaidInstitutionId,
    String? institutionName,
    String? transactionsCursor,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlaidConnectionImpl;

  factory PlaidConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaidConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      plaidItemId: jsonSerialization['plaidItemId'] as String,
      accessTokenCiphertext:
          jsonSerialization['accessTokenCiphertext'] as String?,
      accessTokenNonce: jsonSerialization['accessTokenNonce'] as String?,
      plaidInstitutionId: jsonSerialization['plaidInstitutionId'] as String?,
      institutionName: jsonSerialization['institutionName'] as String?,
      transactionsCursor: jsonSerialization['transactionsCursor'] as String?,
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

  static final t = PlaidConnectionTable();

  static const db = PlaidConnectionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  String plaidItemId;

  /// Base64 AES-256-GCM ciphertext of the access token, with its MAC tag.
  String? accessTokenCiphertext;

  /// Base64 nonce for accessTokenCiphertext.
  String? accessTokenNonce;

  String? plaidInstitutionId;

  String? institutionName;

  /// Cursor for Plaid /transactions/sync; null until the first sync.
  String? transactionsCursor;

  _ijl385hj.SyncStatus syncStatus;

  DateTime? lastSyncedAt;

  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlaidConnection copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? plaidItemId,
    String? accessTokenCiphertext,
    String? accessTokenNonce,
    String? plaidInstitutionId,
    String? institutionName,
    String? transactionsCursor,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'plaidItemId': plaidItemId,
      if (accessTokenCiphertext != null)
        'accessTokenCiphertext': accessTokenCiphertext,
      if (accessTokenNonce != null) 'accessTokenNonce': accessTokenNonce,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      if (institutionName != null) 'institutionName': institutionName,
      if (transactionsCursor != null) 'transactionsCursor': transactionsCursor,
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
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'plaidItemId': plaidItemId,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      if (institutionName != null) 'institutionName': institutionName,
      'syncStatus': syncStatus.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static PlaidConnectionInclude include() {
    return PlaidConnectionInclude._();
  }

  static PlaidConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    PlaidConnectionInclude? include,
  }) {
    return PlaidConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlaidConnectionImpl extends PlaidConnection {
  _PlaidConnectionImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String plaidItemId,
    String? accessTokenCiphertext,
    String? accessTokenNonce,
    String? plaidInstitutionId,
    String? institutionName,
    String? transactionsCursor,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         plaidItemId: plaidItemId,
         accessTokenCiphertext: accessTokenCiphertext,
         accessTokenNonce: accessTokenNonce,
         plaidInstitutionId: plaidInstitutionId,
         institutionName: institutionName,
         transactionsCursor: transactionsCursor,
         syncStatus: syncStatus,
         lastSyncedAt: lastSyncedAt,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlaidConnection copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? plaidItemId,
    Object? accessTokenCiphertext = _Undefined,
    Object? accessTokenNonce = _Undefined,
    Object? plaidInstitutionId = _Undefined,
    Object? institutionName = _Undefined,
    Object? transactionsCursor = _Undefined,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaidConnection(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      plaidItemId: plaidItemId ?? this.plaidItemId,
      accessTokenCiphertext: accessTokenCiphertext is String?
          ? accessTokenCiphertext
          : this.accessTokenCiphertext,
      accessTokenNonce: accessTokenNonce is String?
          ? accessTokenNonce
          : this.accessTokenNonce,
      plaidInstitutionId: plaidInstitutionId is String?
          ? plaidInstitutionId
          : this.plaidInstitutionId,
      institutionName: institutionName is String?
          ? institutionName
          : this.institutionName,
      transactionsCursor: transactionsCursor is String?
          ? transactionsCursor
          : this.transactionsCursor,
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

class PlaidConnectionUpdateTable extends _is.UpdateTable<PlaidConnectionTable> {
  PlaidConnectionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<String, String> plaidItemId(String value) => _is.ColumnValue(
    table.plaidItemId,
    value,
  );

  _is.ColumnValue<String, String> accessTokenCiphertext(String? value) =>
      _is.ColumnValue(
        table.accessTokenCiphertext,
        value,
      );

  _is.ColumnValue<String, String> accessTokenNonce(String? value) =>
      _is.ColumnValue(
        table.accessTokenNonce,
        value,
      );

  _is.ColumnValue<String, String> plaidInstitutionId(String? value) =>
      _is.ColumnValue(
        table.plaidInstitutionId,
        value,
      );

  _is.ColumnValue<String, String> institutionName(String? value) =>
      _is.ColumnValue(
        table.institutionName,
        value,
      );

  _is.ColumnValue<String, String> transactionsCursor(String? value) =>
      _is.ColumnValue(
        table.transactionsCursor,
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

class PlaidConnectionTable extends _is.Table<_is.UuidValue?> {
  PlaidConnectionTable({super.tableRelation})
    : super(tableName: 'plaid_connection') {
    updateTable = PlaidConnectionUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    plaidItemId = _is.ColumnString(
      'plaidItemId',
      this,
    );
    accessTokenCiphertext = _is.ColumnString(
      'accessTokenCiphertext',
      this,
    );
    accessTokenNonce = _is.ColumnString(
      'accessTokenNonce',
      this,
    );
    plaidInstitutionId = _is.ColumnString(
      'plaidInstitutionId',
      this,
    );
    institutionName = _is.ColumnString(
      'institutionName',
      this,
    );
    transactionsCursor = _is.ColumnString(
      'transactionsCursor',
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

  late final PlaidConnectionUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnString plaidItemId;

  /// Base64 AES-256-GCM ciphertext of the access token, with its MAC tag.
  late final _is.ColumnString accessTokenCiphertext;

  /// Base64 nonce for accessTokenCiphertext.
  late final _is.ColumnString accessTokenNonce;

  late final _is.ColumnString plaidInstitutionId;

  late final _is.ColumnString institutionName;

  /// Cursor for Plaid /transactions/sync; null until the first sync.
  late final _is.ColumnString transactionsCursor;

  late final _is.ColumnEnum<_ijl385hj.SyncStatus> syncStatus;

  late final _is.ColumnDateTime lastSyncedAt;

  late final _is.ColumnString lastSyncError;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    plaidItemId,
    accessTokenCiphertext,
    accessTokenNonce,
    plaidInstitutionId,
    institutionName,
    transactionsCursor,
    syncStatus,
    lastSyncedAt,
    lastSyncError,
    createdAt,
    updatedAt,
  ];
}

class PlaidConnectionInclude extends _is.IncludeObject {
  PlaidConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => PlaidConnection.t;
}

class PlaidConnectionIncludeList extends _is.IncludeList {
  PlaidConnectionIncludeList._({
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlaidConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => PlaidConnection.t;
}

class PlaidConnectionRepository {
  const PlaidConnectionRepository._();

  /// Returns a list of [PlaidConnection]s matching the given query parameters.
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
  Future<List<PlaidConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PlaidConnection]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PlaidConnection.t`.
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
  _ida.Stream<List<PlaidConnection>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PlaidConnection] matching the given query parameters.
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
  Future<PlaidConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlaidConnection] by its [id] or null if no such row exists.
  Future<PlaidConnection?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlaidConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlaidConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [PlaidConnection]s will have their `id` fields set.
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
  Future<List<PlaidConnection>> insert(
    _is.DatabaseSession session,
    List<PlaidConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlaidConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlaidConnection] and returns the inserted row.
  ///
  /// The returned [PlaidConnection] will have its `id` field set.
  Future<PlaidConnection> insertRow(
    _is.DatabaseSession session,
    PlaidConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlaidConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PlaidConnection]s in the list and returns the resulting rows.
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
  /// The returned [PlaidConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaidConnection>> upsert(
    _is.DatabaseSession session,
    List<PlaidConnection> rows, {
    required _is.ColumnSelections<PlaidConnectionTable> conflictColumns,
    _is.ColumnSelections<PlaidConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaidConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlaidConnection>(
      rows,
      conflictColumns: conflictColumns(PlaidConnection.t),
      updateColumns: updateColumns?.call(PlaidConnection.t),
      updateWhere: updateWhere?.call(PlaidConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlaidConnection] and returns the resulting row.
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
  /// The returned [PlaidConnection] will have its `id` field set.
  Future<PlaidConnection?> upsertRow(
    _is.DatabaseSession session,
    PlaidConnection row, {
    required _is.ColumnSelections<PlaidConnectionTable> conflictColumns,
    _is.ColumnSelections<PlaidConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaidConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlaidConnection>(
      row,
      conflictColumns: conflictColumns(PlaidConnection.t),
      updateColumns: updateColumns?.call(PlaidConnection.t),
      updateWhere: updateWhere?.call(PlaidConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlaidConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaidConnection>> update(
    _is.DatabaseSession session,
    List<PlaidConnection> rows, {
    _is.ColumnSelections<PlaidConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlaidConnection>(
      rows,
      columns: columns?.call(PlaidConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlaidConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlaidConnection> updateRow(
    _is.DatabaseSession session,
    PlaidConnection row, {
    _is.ColumnSelections<PlaidConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlaidConnection>(
      row,
      columns: columns?.call(PlaidConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlaidConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlaidConnection?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PlaidConnectionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlaidConnection>(
      id,
      columnValues: columnValues(PlaidConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlaidConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaidConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlaidConnectionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<PlaidConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlaidConnection>(
      columnValues: columnValues(PlaidConnection.t.updateTable),
      where: where(PlaidConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlaidConnection]s in the list and returns the deleted rows.
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
  Future<List<PlaidConnection>> delete(
    _is.DatabaseSession session,
    List<PlaidConnection> rows, {
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlaidConnection>(
      rows,
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlaidConnection].
  Future<PlaidConnection> deleteRow(
    _is.DatabaseSession session,
    PlaidConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlaidConnection>(
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
  Future<List<PlaidConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaidConnectionTable> where,
    _is.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _is.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlaidConnection>(
      where: where(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlaidConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaidConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlaidConnection>(
      where: where(PlaidConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
