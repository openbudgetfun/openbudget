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

/// Cached USD quote for a blockchain asset.
abstract class AssetQuoteCache
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AssetQuoteCache._({
    this.id,
    required this.chain,
    required this.assetId,
    required this.symbol,
    required this.usdPrice,
    DateTime? fetchedAt,
    required this.expiresAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory AssetQuoteCache({
    _is.UuidValue? id,
    required String chain,
    required String assetId,
    required String symbol,
    required double usdPrice,
    DateTime? fetchedAt,
    required DateTime expiresAt,
  }) = _AssetQuoteCacheImpl;

  factory AssetQuoteCache.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetQuoteCache(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chain: jsonSerialization['chain'] as String,
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String,
      usdPrice: (jsonSerialization['usdPrice'] as num).toDouble(),
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = AssetQuoteCacheTable();

  static const db = AssetQuoteCacheRepository._();

  @override
  _is.UuidValue? id;

  String chain;

  String assetId;

  String symbol;

  double usdPrice;

  DateTime fetchedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssetQuoteCache]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssetQuoteCache copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? chain,
    String? assetId,
    String? symbol,
    double? usdPrice,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetQuoteCache',
      if (id != null) 'id': id?.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'usdPrice': usdPrice,
      'fetchedAt': fetchedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssetQuoteCache',
      if (id != null) 'id': id?.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'usdPrice': usdPrice,
      'fetchedAt': fetchedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  static AssetQuoteCacheInclude include() {
    return AssetQuoteCacheInclude._();
  }

  static AssetQuoteCacheIncludeList includeList({
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    AssetQuoteCacheInclude? include,
  }) {
    return AssetQuoteCacheIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AssetQuoteCacheImpl extends AssetQuoteCache {
  _AssetQuoteCacheImpl({
    _is.UuidValue? id,
    required String chain,
    required String assetId,
    required String symbol,
    required double usdPrice,
    DateTime? fetchedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         chain: chain,
         assetId: assetId,
         symbol: symbol,
         usdPrice: usdPrice,
         fetchedAt: fetchedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AssetQuoteCache]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssetQuoteCache copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? chain,
    String? assetId,
    String? symbol,
    double? usdPrice,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) {
    return AssetQuoteCache(
      id: id is _is.UndefinedSentinel ? this.id : id,
      chain: chain ?? this.chain,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      usdPrice: usdPrice ?? this.usdPrice,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AssetQuoteCacheUpdateTable extends _is.UpdateTable<AssetQuoteCacheTable> {
  AssetQuoteCacheUpdateTable(super.table);

  _is.ColumnValue<String, String> chain(String value) => _is.ColumnValue(
    table.chain,
    value,
  );

  _is.ColumnValue<String, String> assetId(String value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<String, String> symbol(String value) => _is.ColumnValue(
    table.symbol,
    value,
  );

  _is.ColumnValue<double, double> usdPrice(double value) => _is.ColumnValue(
    table.usdPrice,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _is.ColumnValue(
        table.fetchedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class AssetQuoteCacheTable extends _is.Table<_is.UuidValue?> {
  AssetQuoteCacheTable({super.tableRelation})
    : super(tableName: 'asset_quote_cache') {
    updateTable = AssetQuoteCacheUpdateTable(this);
    chain = _is.ColumnString(
      'chain',
      this,
    );
    assetId = _is.ColumnString(
      'assetId',
      this,
    );
    symbol = _is.ColumnString(
      'symbol',
      this,
    );
    usdPrice = _is.ColumnDouble(
      'usdPrice',
      this,
    );
    fetchedAt = _is.ColumnDateTime(
      'fetchedAt',
      this,
      hasDefault: true,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final AssetQuoteCacheUpdateTable updateTable;

  late final _is.ColumnString chain;

  late final _is.ColumnString assetId;

  late final _is.ColumnString symbol;

  late final _is.ColumnDouble usdPrice;

  late final _is.ColumnDateTime fetchedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    chain,
    assetId,
    symbol,
    usdPrice,
    fetchedAt,
    expiresAt,
  ];
}

class AssetQuoteCacheInclude extends _is.IncludeObject {
  AssetQuoteCacheInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssetQuoteCache.t;
}

class AssetQuoteCacheIncludeList extends _is.IncludeList {
  AssetQuoteCacheIncludeList._({
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssetQuoteCache.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssetQuoteCache.t;
}

class AssetQuoteCacheRepository {
  const AssetQuoteCacheRepository._();

  /// Returns a list of [AssetQuoteCache]s matching the given query parameters.
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
  Future<List<AssetQuoteCache>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AssetQuoteCache]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AssetQuoteCache.t`.
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
  _ida.Stream<List<AssetQuoteCache>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AssetQuoteCache] matching the given query parameters.
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
  Future<AssetQuoteCache?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? offset,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssetQuoteCache] by its [id] or null if no such row exists.
  Future<AssetQuoteCache?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssetQuoteCache>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssetQuoteCache]s in the list and returns the inserted rows.
  ///
  /// The returned [AssetQuoteCache]s will have their `id` fields set.
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
  Future<List<AssetQuoteCache>> insert(
    _is.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssetQuoteCache>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssetQuoteCache] and returns the inserted row.
  ///
  /// The returned [AssetQuoteCache] will have its `id` field set.
  Future<AssetQuoteCache> insertRow(
    _is.DatabaseSession session,
    AssetQuoteCache row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssetQuoteCache>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssetQuoteCache]s in the list and returns the resulting rows.
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
  /// The returned [AssetQuoteCache]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetQuoteCache>> upsert(
    _is.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    required _is.ColumnSelections<AssetQuoteCacheTable> conflictColumns,
    _is.ColumnSelections<AssetQuoteCacheTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssetQuoteCache>(
      rows,
      conflictColumns: conflictColumns(AssetQuoteCache.t),
      updateColumns: updateColumns?.call(AssetQuoteCache.t),
      updateWhere: updateWhere?.call(AssetQuoteCache.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssetQuoteCache] and returns the resulting row.
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
  /// The returned [AssetQuoteCache] will have its `id` field set.
  Future<AssetQuoteCache?> upsertRow(
    _is.DatabaseSession session,
    AssetQuoteCache row, {
    required _is.ColumnSelections<AssetQuoteCacheTable> conflictColumns,
    _is.ColumnSelections<AssetQuoteCacheTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssetQuoteCache>(
      row,
      conflictColumns: conflictColumns(AssetQuoteCache.t),
      updateColumns: updateColumns?.call(AssetQuoteCache.t),
      updateWhere: updateWhere?.call(AssetQuoteCache.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssetQuoteCache]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetQuoteCache>> update(
    _is.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _is.ColumnSelections<AssetQuoteCacheTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssetQuoteCache>(
      rows,
      columns: columns?.call(AssetQuoteCache.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssetQuoteCache]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssetQuoteCache> updateRow(
    _is.DatabaseSession session,
    AssetQuoteCache row, {
    _is.ColumnSelections<AssetQuoteCacheTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssetQuoteCache>(
      row,
      columns: columns?.call(AssetQuoteCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssetQuoteCache] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssetQuoteCache?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssetQuoteCacheUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssetQuoteCache>(
      id,
      columnValues: columnValues(AssetQuoteCache.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssetQuoteCache]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetQuoteCache>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssetQuoteCacheUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssetQuoteCache>(
      columnValues: columnValues(AssetQuoteCache.t.updateTable),
      where: where(AssetQuoteCache.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssetQuoteCache]s in the list and returns the deleted rows.
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
  Future<List<AssetQuoteCache>> delete(
    _is.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssetQuoteCache>(
      rows,
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssetQuoteCache].
  Future<AssetQuoteCache> deleteRow(
    _is.DatabaseSession session,
    AssetQuoteCache row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssetQuoteCache>(
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
  Future<List<AssetQuoteCache>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    _is.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _is.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssetQuoteCache>(
      where: where(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssetQuoteCache] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssetQuoteCache>(
      where: where(AssetQuoteCache.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
