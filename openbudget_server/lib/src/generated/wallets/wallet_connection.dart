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

/// Read-only blockchain wallet connection.
abstract class WalletConnection
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      chain: jsonSerialization['chain'] as String,
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
    );
  }

  static final t = WalletConnectionTable();

  static const db = WalletConnectionRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  String chain;

  String address;

  String? label;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastSyncedAt;

  String? syncStatus;

  String? lastError;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WalletConnection copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    String? chain,
    String? address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
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
    _i1.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletConnectionTable>? orderByList,
    WalletConnectionInclude? include,
  }) {
    return WalletConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletConnection.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(WalletConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletConnectionImpl extends WalletConnection {
  _WalletConnectionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
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
  @_i1.useResult
  @override
  WalletConnection copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    String? chain,
    String? address,
    Object? label = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastSyncedAt = _Undefined,
    Object? syncStatus = _Undefined,
    Object? lastError = _Undefined,
  }) {
    return WalletConnection(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      chain: chain ?? this.chain,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      lastError: lastError is String? ? lastError : this.lastError,
    );
  }
}

class WalletConnectionUpdateTable
    extends _i1.UpdateTable<WalletConnectionTable> {
  WalletConnectionUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<String, String> chain(String value) => _i1.ColumnValue(
    table.chain,
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

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _i1.ColumnValue<String, String> syncStatus(String? value) => _i1.ColumnValue(
    table.syncStatus,
    value,
  );

  _i1.ColumnValue<String, String> lastError(String? value) => _i1.ColumnValue(
    table.lastError,
    value,
  );
}

class WalletConnectionTable extends _i1.Table<_i1.UuidValue?> {
  WalletConnectionTable({super.tableRelation})
    : super(tableName: 'wallet_connection') {
    updateTable = WalletConnectionUpdateTable(this);
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    chain = _i1.ColumnString(
      'chain',
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
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _i1.ColumnString(
      'syncStatus',
      this,
    );
    lastError = _i1.ColumnString(
      'lastError',
      this,
    );
  }

  late final WalletConnectionUpdateTable updateTable;

  late final _i1.ColumnUuid budgetId;

  late final _i1.ColumnString chain;

  late final _i1.ColumnString address;

  late final _i1.ColumnString label;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime lastSyncedAt;

  late final _i1.ColumnString syncStatus;

  late final _i1.ColumnString lastError;

  @override
  List<_i1.Column> get columns => [
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

class WalletConnectionInclude extends _i1.IncludeObject {
  WalletConnectionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => WalletConnection.t;
}

class WalletConnectionIncludeList extends _i1.IncludeList {
  WalletConnectionIncludeList._({
    _i1.WhereExpressionBuilder<WalletConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletConnection.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => WalletConnection.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<WalletConnection>(
      where: where?.call(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? offset,
    _i1.OrderByBuilder<WalletConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<WalletConnection>(
      where: where?.call(WalletConnection.t),
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [WalletConnection] by its [id] or null if no such row exists.
  Future<WalletConnection?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<WalletConnection>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [WalletConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<WalletConnection>> insert(
    _i1.Session session,
    List<WalletConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<WalletConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [WalletConnection] and returns the inserted row.
  ///
  /// The returned [WalletConnection] will have its `id` field set.
  Future<WalletConnection> insertRow(
    _i1.Session session,
    WalletConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [WalletConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<WalletConnection>> update(
    _i1.Session session,
    List<WalletConnection> rows, {
    _i1.ColumnSelections<WalletConnectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<WalletConnection>(
      rows,
      columns: columns?.call(WalletConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletConnection> updateRow(
    _i1.Session session,
    WalletConnection row, {
    _i1.ColumnSelections<WalletConnectionTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<WalletConnectionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletConnection>(
      id,
      columnValues: columnValues(WalletConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<WalletConnection>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<WalletConnectionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<WalletConnectionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletConnectionTable>? orderBy,
    _i1.OrderByListBuilder<WalletConnectionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<WalletConnection>(
      columnValues: columnValues(WalletConnection.t.updateTable),
      where: where(WalletConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletConnection.t),
      orderByList: orderByList?.call(WalletConnection.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [WalletConnection]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<WalletConnection>> delete(
    _i1.Session session,
    List<WalletConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<WalletConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [WalletConnection].
  Future<WalletConnection> deleteRow(
    _i1.Session session,
    WalletConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<WalletConnection>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<WalletConnectionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<WalletConnection>(
      where: where(WalletConnection.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalletConnectionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<WalletConnection>(
      where: where?.call(WalletConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
