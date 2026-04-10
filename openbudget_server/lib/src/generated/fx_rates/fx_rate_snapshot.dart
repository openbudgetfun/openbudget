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

/// Snapshot of exchange rates fetched from an upstream FX provider.
abstract class FxRateSnapshot
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  FxRateSnapshot._({
    this.id,
    required this.provider,
    required this.baseCurrencyCode,
    required this.fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : isLatest = isLatest ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory FxRateSnapshot({
    _i1.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) = _FxRateSnapshotImpl;

  factory FxRateSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateSnapshot(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      provider: jsonSerialization['provider'] as String,
      baseCurrencyCode: jsonSerialization['baseCurrencyCode'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      isLatest: jsonSerialization['isLatest'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isLatest']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FxRateSnapshotTable();

  static const db = FxRateSnapshotRepository._();

  @override
  _i1.UuidValue? id;

  String provider;

  String baseCurrencyCode;

  DateTime fetchedAt;

  bool isLatest;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxRateSnapshot copyWith({
    _i1.UuidValue? id,
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateSnapshot',
      if (id != null) 'id': id?.toJson(),
      'provider': provider,
      'baseCurrencyCode': baseCurrencyCode,
      'fetchedAt': fetchedAt.toJson(),
      'isLatest': isLatest,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateSnapshot',
      if (id != null) 'id': id?.toJson(),
      'provider': provider,
      'baseCurrencyCode': baseCurrencyCode,
      'fetchedAt': fetchedAt.toJson(),
      'isLatest': isLatest,
      'createdAt': createdAt.toJson(),
    };
  }

  static FxRateSnapshotInclude include() {
    return FxRateSnapshotInclude._();
  }

  static FxRateSnapshotIncludeList includeList({
    _i1.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    FxRateSnapshotInclude? include,
  }) {
    return FxRateSnapshotIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FxRateSnapshot.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FxRateSnapshotImpl extends FxRateSnapshot {
  _FxRateSnapshotImpl({
    _i1.UuidValue? id,
    required String provider,
    required String baseCurrencyCode,
    required DateTime fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) : super._(
         id: id,
         provider: provider,
         baseCurrencyCode: baseCurrencyCode,
         fetchedAt: fetchedAt,
         isLatest: isLatest,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxRateSnapshot copyWith({
    Object? id = _Undefined,
    String? provider,
    String? baseCurrencyCode,
    DateTime? fetchedAt,
    bool? isLatest,
    DateTime? createdAt,
  }) {
    return FxRateSnapshot(
      id: id is _i1.UuidValue? ? id : this.id,
      provider: provider ?? this.provider,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLatest: isLatest ?? this.isLatest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FxRateSnapshotUpdateTable extends _i1.UpdateTable<FxRateSnapshotTable> {
  FxRateSnapshotUpdateTable(super.table);

  _i1.ColumnValue<String, String> provider(String value) => _i1.ColumnValue(
    table.provider,
    value,
  );

  _i1.ColumnValue<String, String> baseCurrencyCode(String value) =>
      _i1.ColumnValue(
        table.baseCurrencyCode,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _i1.ColumnValue(
        table.fetchedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isLatest(bool value) => _i1.ColumnValue(
    table.isLatest,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class FxRateSnapshotTable extends _i1.Table<_i1.UuidValue?> {
  FxRateSnapshotTable({super.tableRelation})
    : super(tableName: 'fx_rate_snapshot') {
    updateTable = FxRateSnapshotUpdateTable(this);
    provider = _i1.ColumnString(
      'provider',
      this,
    );
    baseCurrencyCode = _i1.ColumnString(
      'baseCurrencyCode',
      this,
    );
    fetchedAt = _i1.ColumnDateTime(
      'fetchedAt',
      this,
    );
    isLatest = _i1.ColumnBool(
      'isLatest',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final FxRateSnapshotUpdateTable updateTable;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString baseCurrencyCode;

  late final _i1.ColumnDateTime fetchedAt;

  late final _i1.ColumnBool isLatest;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    provider,
    baseCurrencyCode,
    fetchedAt,
    isLatest,
    createdAt,
  ];
}

class FxRateSnapshotInclude extends _i1.IncludeObject {
  FxRateSnapshotInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxRateSnapshot.t;
}

class FxRateSnapshotIncludeList extends _i1.IncludeList {
  FxRateSnapshotIncludeList._({
    _i1.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxRateSnapshot.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxRateSnapshot.t;
}

class FxRateSnapshotRepository {
  const FxRateSnapshotRepository._();

  /// Returns a list of [FxRateSnapshot]s matching the given query parameters.
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
  Future<List<FxRateSnapshot>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FxRateSnapshot] matching the given query parameters.
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
  Future<FxRateSnapshot?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? offset,
    _i1.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FxRateSnapshot] by its [id] or null if no such row exists.
  Future<FxRateSnapshot?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FxRateSnapshot>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FxRateSnapshot]s in the list and returns the inserted rows.
  ///
  /// The returned [FxRateSnapshot]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<FxRateSnapshot>> insert(
    _i1.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<FxRateSnapshot>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [FxRateSnapshot] and returns the inserted row.
  ///
  /// The returned [FxRateSnapshot] will have its `id` field set.
  Future<FxRateSnapshot> insertRow(
    _i1.DatabaseSession session,
    FxRateSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxRateSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FxRateSnapshot]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FxRateSnapshot>> update(
    _i1.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _i1.ColumnSelections<FxRateSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FxRateSnapshot>(
      rows,
      columns: columns?.call(FxRateSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateSnapshot]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxRateSnapshot> updateRow(
    _i1.DatabaseSession session,
    FxRateSnapshot row, {
    _i1.ColumnSelections<FxRateSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxRateSnapshot>(
      row,
      columns: columns?.call(FxRateSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateSnapshot] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxRateSnapshot?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<FxRateSnapshotUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FxRateSnapshot>(
      id,
      columnValues: columnValues(FxRateSnapshot.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateSnapshot]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FxRateSnapshot>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<FxRateSnapshotUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FxRateSnapshotTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateSnapshotTable>? orderBy,
    _i1.OrderByListBuilder<FxRateSnapshotTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FxRateSnapshot>(
      columnValues: columnValues(FxRateSnapshot.t.updateTable),
      where: where(FxRateSnapshot.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateSnapshot.t),
      orderByList: orderByList?.call(FxRateSnapshot.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FxRateSnapshot]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FxRateSnapshot>> delete(
    _i1.DatabaseSession session,
    List<FxRateSnapshot> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FxRateSnapshot>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FxRateSnapshot].
  Future<FxRateSnapshot> deleteRow(
    _i1.DatabaseSession session,
    FxRateSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxRateSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FxRateSnapshot>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FxRateSnapshotTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FxRateSnapshot>(
      where: where(FxRateSnapshot.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateSnapshotTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FxRateSnapshot>(
      where: where?.call(FxRateSnapshot.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FxRateSnapshot] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FxRateSnapshotTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FxRateSnapshot>(
      where: where(FxRateSnapshot.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
