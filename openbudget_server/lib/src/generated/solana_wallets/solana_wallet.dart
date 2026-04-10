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
import 'package:serverpod/serverpod.dart' as _i1;

/// A Solana wallet linked to an OpenBudget account.
abstract class SolanaWallet
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    required _i1.UuidValue budgetId,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      cluster: jsonSerialization['cluster'] as String,
      lastSignature: jsonSerialization['lastSignature'] as String?,
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String,
      lastSyncError: jsonSerialization['lastSyncError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletTable();

  static const db = SolanaWalletRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue accountId;

  _i1.UuidValue budgetId;

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
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWallet]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWallet copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? accountId,
    _i1.UuidValue? budgetId,
    String? address,
    String? label,
    String? cluster,
    String? lastSignature,
    DateTime? lastSyncedAt,
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
    _i1.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTable>? orderByList,
    SolanaWalletInclude? include,
  }) {
    return SolanaWalletIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWallet.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SolanaWallet.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletImpl extends SolanaWallet {
  _SolanaWalletImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    required _i1.UuidValue budgetId,
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
  @_i1.useResult
  @override
  SolanaWallet copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountId,
    _i1.UuidValue? budgetId,
    String? address,
    Object? label = _Undefined,
    String? cluster,
    Object? lastSignature = _Undefined,
    Object? lastSyncedAt = _Undefined,
    String? syncStatus,
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolanaWallet(
      id: id is _i1.UuidValue? ? id : this.id,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      cluster: cluster ?? this.cluster,
      lastSignature: lastSignature is String?
          ? lastSignature
          : this.lastSignature,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: lastSyncError is String?
          ? lastSyncError
          : this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SolanaWalletUpdateTable extends _i1.UpdateTable<SolanaWalletTable> {
  SolanaWalletUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<String, String> address(String value) => _i1.ColumnValue(
    table.address,
    value,
  );

  _i1.ColumnValue<String, String> label(String? value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<String, String> cluster(String value) => _i1.ColumnValue(
    table.cluster,
    value,
  );

  _i1.ColumnValue<String, String> lastSignature(String? value) =>
      _i1.ColumnValue(
        table.lastSignature,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _i1.ColumnValue<String, String> syncStatus(String value) => _i1.ColumnValue(
    table.syncStatus,
    value,
  );

  _i1.ColumnValue<String, String> lastSyncError(String? value) =>
      _i1.ColumnValue(
        table.lastSyncError,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class SolanaWalletTable extends _i1.Table<_i1.UuidValue?> {
  SolanaWalletTable({super.tableRelation}) : super(tableName: 'solana_wallet') {
    updateTable = SolanaWalletUpdateTable(this);
    accountId = _i1.ColumnUuid(
      'accountId',
      this,
    );
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    address = _i1.ColumnString(
      'address',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    cluster = _i1.ColumnString(
      'cluster',
      this,
    );
    lastSignature = _i1.ColumnString(
      'lastSignature',
      this,
    );
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _i1.ColumnString(
      'syncStatus',
      this,
    );
    lastSyncError = _i1.ColumnString(
      'lastSyncError',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final SolanaWalletUpdateTable updateTable;

  late final _i1.ColumnUuid accountId;

  late final _i1.ColumnUuid budgetId;

  /// Solana wallet address (base58).
  late final _i1.ColumnString address;

  /// Optional wallet label shown in the UI.
  late final _i1.ColumnString label;

  /// Solana cluster: mainnet or devnet.
  late final _i1.ColumnString cluster;

  /// Last processed signature for incremental syncing.
  late final _i1.ColumnString lastSignature;

  /// Last successful sync timestamp.
  late final _i1.ColumnDateTime lastSyncedAt;

  /// Current sync status: pending, success, error.
  late final _i1.ColumnString syncStatus;

  /// Last sync error, if any.
  late final _i1.ColumnString lastSyncError;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
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

class SolanaWalletInclude extends _i1.IncludeObject {
  SolanaWalletInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWallet.t;
}

class SolanaWalletIncludeList extends _i1.IncludeList {
  SolanaWalletIncludeList._({
    _i1.WhereExpressionBuilder<SolanaWalletTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWallet.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWallet.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWallet] by its [id] or null if no such row exists.
  Future<SolanaWallet?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<SolanaWallet>> insert(
    _i1.DatabaseSession session,
    List<SolanaWallet> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SolanaWallet>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SolanaWallet] and returns the inserted row.
  ///
  /// The returned [SolanaWallet] will have its `id` field set.
  Future<SolanaWallet> insertRow(
    _i1.DatabaseSession session,
    SolanaWallet row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWallet>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWallet]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SolanaWallet>> update(
    _i1.DatabaseSession session,
    List<SolanaWallet> rows, {
    _i1.ColumnSelections<SolanaWalletTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SolanaWallet>(
      rows,
      columns: columns?.call(SolanaWallet.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWallet]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWallet> updateRow(
    _i1.DatabaseSession session,
    SolanaWallet row, {
    _i1.ColumnSelections<SolanaWalletTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SolanaWalletUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWallet>(
      id,
      columnValues: columnValues(SolanaWallet.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWallet]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SolanaWallet>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SolanaWalletUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SolanaWalletTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTable>? orderBy,
    _i1.OrderByListBuilder<SolanaWalletTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SolanaWallet>(
      columnValues: columnValues(SolanaWallet.t.updateTable),
      where: where(SolanaWallet.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWallet.t),
      orderByList: orderByList?.call(SolanaWallet.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SolanaWallet]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SolanaWallet>> delete(
    _i1.DatabaseSession session,
    List<SolanaWallet> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SolanaWallet>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SolanaWallet].
  Future<SolanaWallet> deleteRow(
    _i1.DatabaseSession session,
    SolanaWallet row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWallet>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SolanaWallet>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SolanaWallet>(
      where: where(SolanaWallet.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWallet>(
      where: where?.call(SolanaWallet.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWallet] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWallet>(
      where: where(SolanaWallet.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
