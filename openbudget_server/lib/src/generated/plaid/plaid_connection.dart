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

/// Plaid item connection persisted for syncing linked bank accounts.
abstract class PlaidConnection
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PlaidConnection._({
    this.id,
    required this.budgetId,
    required this.plaidItemId,
    required this.accessToken,
    this.institutionName,
    this.institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PlaidConnection({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String plaidItemId,
    required String accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) = _PlaidConnectionImpl;

  factory PlaidConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaidConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      plaidItemId: jsonSerialization['plaidItemId'] as String,
      accessToken: jsonSerialization['accessToken'] as String,
      institutionName: jsonSerialization['institutionName'] as String?,
      institutionId: jsonSerialization['institutionId'] as String?,
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
    );
  }

  static final t = PlaidConnectionTable();

  static const db = PlaidConnectionRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  String plaidItemId;

  String accessToken;

  String? institutionName;

  String? institutionId;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastSyncedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlaidConnection copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    String? plaidItemId,
    String? accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'plaidItemId': plaidItemId,
      'accessToken': accessToken,
      if (institutionName != null) 'institutionName': institutionName,
      if (institutionId != null) 'institutionId': institutionId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'plaidItemId': plaidItemId,
      'accessToken': accessToken,
      if (institutionName != null) 'institutionName': institutionName,
      if (institutionId != null) 'institutionId': institutionId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
    };
  }

  static PlaidConnectionInclude include() {
    return PlaidConnectionInclude._();
  }

  static PlaidConnectionIncludeList includeList({
    _i1.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PlaidConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    PlaidConnectionInclude? include,
  }) {
    return PlaidConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaidConnection.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PlaidConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlaidConnectionImpl extends PlaidConnection {
  _PlaidConnectionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String plaidItemId,
    required String accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         plaidItemId: plaidItemId,
         accessToken: accessToken,
         institutionName: institutionName,
         institutionId: institutionId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastSyncedAt: lastSyncedAt,
       );

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlaidConnection copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    String? plaidItemId,
    String? accessToken,
    Object? institutionName = _Undefined,
    Object? institutionId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastSyncedAt = _Undefined,
  }) {
    return PlaidConnection(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      plaidItemId: plaidItemId ?? this.plaidItemId,
      accessToken: accessToken ?? this.accessToken,
      institutionName: institutionName is String?
          ? institutionName
          : this.institutionName,
      institutionId: institutionId is String?
          ? institutionId
          : this.institutionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
    );
  }
}

class PlaidConnectionUpdateTable extends _i1.UpdateTable<PlaidConnectionTable> {
  PlaidConnectionUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<String, String> plaidItemId(String value) => _i1.ColumnValue(
    table.plaidItemId,
    value,
  );

  _i1.ColumnValue<String, String> accessToken(String value) => _i1.ColumnValue(
    table.accessToken,
    value,
  );

  _i1.ColumnValue<String, String> institutionName(String? value) =>
      _i1.ColumnValue(
        table.institutionName,
        value,
      );

  _i1.ColumnValue<String, String> institutionId(String? value) =>
      _i1.ColumnValue(
        table.institutionId,
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
}

class PlaidConnectionTable extends _i1.Table<_i1.UuidValue?> {
  PlaidConnectionTable({super.tableRelation})
    : super(tableName: 'plaid_connection') {
    updateTable = PlaidConnectionUpdateTable(this);
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    plaidItemId = _i1.ColumnString(
      'plaidItemId',
      this,
    );
    accessToken = _i1.ColumnString(
      'accessToken',
      this,
    );
    institutionName = _i1.ColumnString(
      'institutionName',
      this,
    );
    institutionId = _i1.ColumnString(
      'institutionId',
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
  }

  late final PlaidConnectionUpdateTable updateTable;

  late final _i1.ColumnUuid budgetId;

  late final _i1.ColumnString plaidItemId;

  late final _i1.ColumnString accessToken;

  late final _i1.ColumnString institutionName;

  late final _i1.ColumnString institutionId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime lastSyncedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    budgetId,
    plaidItemId,
    accessToken,
    institutionName,
    institutionId,
    createdAt,
    updatedAt,
    lastSyncedAt,
  ];
}

class PlaidConnectionInclude extends _i1.IncludeObject {
  PlaidConnectionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PlaidConnection.t;
}

class PlaidConnectionIncludeList extends _i1.IncludeList {
  PlaidConnectionIncludeList._({
    _i1.WhereExpressionBuilder<PlaidConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlaidConnection.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PlaidConnection.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PlaidConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? offset,
    _i1.OrderByBuilder<PlaidConnectionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PlaidConnection] by its [id] or null if no such row exists.
  Future<PlaidConnection?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PlaidConnection>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PlaidConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [PlaidConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PlaidConnection>> insert(
    _i1.Session session,
    List<PlaidConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PlaidConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PlaidConnection] and returns the inserted row.
  ///
  /// The returned [PlaidConnection] will have its `id` field set.
  Future<PlaidConnection> insertRow(
    _i1.Session session,
    PlaidConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlaidConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PlaidConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PlaidConnection>> update(
    _i1.Session session,
    List<PlaidConnection> rows, {
    _i1.ColumnSelections<PlaidConnectionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PlaidConnection>(
      rows,
      columns: columns?.call(PlaidConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlaidConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlaidConnection> updateRow(
    _i1.Session session,
    PlaidConnection row, {
    _i1.ColumnSelections<PlaidConnectionTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PlaidConnectionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PlaidConnection>(
      id,
      columnValues: columnValues(PlaidConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlaidConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PlaidConnection>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PlaidConnectionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PlaidConnectionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PlaidConnectionTable>? orderBy,
    _i1.OrderByListBuilder<PlaidConnectionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PlaidConnection>(
      columnValues: columnValues(PlaidConnection.t.updateTable),
      where: where(PlaidConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaidConnection.t),
      orderByList: orderByList?.call(PlaidConnection.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PlaidConnection]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PlaidConnection>> delete(
    _i1.Session session,
    List<PlaidConnection> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PlaidConnection>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PlaidConnection].
  Future<PlaidConnection> deleteRow(
    _i1.Session session,
    PlaidConnection row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlaidConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PlaidConnection>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PlaidConnectionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PlaidConnection>(
      where: where(PlaidConnection.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PlaidConnectionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PlaidConnection>(
      where: where?.call(PlaidConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
