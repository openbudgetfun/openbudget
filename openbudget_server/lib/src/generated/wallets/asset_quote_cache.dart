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

/// Cached USD quote for a blockchain asset.
abstract class AssetQuoteCache
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chain: jsonSerialization['chain'] as String,
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String,
      usdPrice: (jsonSerialization['usdPrice'] as num).toDouble(),
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = AssetQuoteCacheTable();

  static const db = AssetQuoteCacheRepository._();

  @override
  _i1.UuidValue? id;

  String chain;

  String assetId;

  String symbol;

  double usdPrice;

  DateTime fetchedAt;

  DateTime expiresAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssetQuoteCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssetQuoteCache copyWith({
    _i1.UuidValue? id,
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
    _i1.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    AssetQuoteCacheInclude? include,
  }) {
    return AssetQuoteCacheIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(AssetQuoteCache.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetQuoteCacheImpl extends AssetQuoteCache {
  _AssetQuoteCacheImpl({
    _i1.UuidValue? id,
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
  @_i1.useResult
  @override
  AssetQuoteCache copyWith({
    Object? id = _Undefined,
    String? chain,
    String? assetId,
    String? symbol,
    double? usdPrice,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) {
    return AssetQuoteCache(
      id: id is _i1.UuidValue? ? id : this.id,
      chain: chain ?? this.chain,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      usdPrice: usdPrice ?? this.usdPrice,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AssetQuoteCacheUpdateTable extends _i1.UpdateTable<AssetQuoteCacheTable> {
  AssetQuoteCacheUpdateTable(super.table);

  _i1.ColumnValue<String, String> chain(String value) => _i1.ColumnValue(
    table.chain,
    value,
  );

  _i1.ColumnValue<String, String> assetId(String value) => _i1.ColumnValue(
    table.assetId,
    value,
  );

  _i1.ColumnValue<String, String> symbol(String value) => _i1.ColumnValue(
    table.symbol,
    value,
  );

  _i1.ColumnValue<double, double> usdPrice(double value) => _i1.ColumnValue(
    table.usdPrice,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _i1.ColumnValue(
        table.fetchedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );
}

class AssetQuoteCacheTable extends _i1.Table<_i1.UuidValue?> {
  AssetQuoteCacheTable({super.tableRelation})
    : super(tableName: 'asset_quote_cache') {
    updateTable = AssetQuoteCacheUpdateTable(this);
    chain = _i1.ColumnString(
      'chain',
      this,
    );
    assetId = _i1.ColumnString(
      'assetId',
      this,
    );
    symbol = _i1.ColumnString(
      'symbol',
      this,
    );
    usdPrice = _i1.ColumnDouble(
      'usdPrice',
      this,
    );
    fetchedAt = _i1.ColumnDateTime(
      'fetchedAt',
      this,
      hasDefault: true,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final AssetQuoteCacheUpdateTable updateTable;

  late final _i1.ColumnString chain;

  late final _i1.ColumnString assetId;

  late final _i1.ColumnString symbol;

  late final _i1.ColumnDouble usdPrice;

  late final _i1.ColumnDateTime fetchedAt;

  late final _i1.ColumnDateTime expiresAt;

  @override
  List<_i1.Column> get columns => [
    id,
    chain,
    assetId,
    symbol,
    usdPrice,
    fetchedAt,
    expiresAt,
  ];
}

class AssetQuoteCacheInclude extends _i1.IncludeObject {
  AssetQuoteCacheInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AssetQuoteCache.t;
}

class AssetQuoteCacheIncludeList extends _i1.IncludeList {
  AssetQuoteCacheIncludeList._({
    _i1.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssetQuoteCache.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => AssetQuoteCache.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? offset,
    _i1.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssetQuoteCache] by its [id] or null if no such row exists.
  Future<AssetQuoteCache?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<AssetQuoteCache>> insert(
    _i1.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<AssetQuoteCache>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [AssetQuoteCache] and returns the inserted row.
  ///
  /// The returned [AssetQuoteCache] will have its `id` field set.
  Future<AssetQuoteCache> insertRow(
    _i1.DatabaseSession session,
    AssetQuoteCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssetQuoteCache>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [AssetQuoteCache]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<AssetQuoteCache>> update(
    _i1.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _i1.ColumnSelections<AssetQuoteCacheTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<AssetQuoteCache>(
      rows,
      columns: columns?.call(AssetQuoteCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssetQuoteCache]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssetQuoteCache> updateRow(
    _i1.DatabaseSession session,
    AssetQuoteCache row, {
    _i1.ColumnSelections<AssetQuoteCacheTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AssetQuoteCacheUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<AssetQuoteCache>(
      id,
      columnValues: columnValues(AssetQuoteCache.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssetQuoteCache]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<AssetQuoteCache>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AssetQuoteCacheUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetQuoteCacheTable>? orderBy,
    _i1.OrderByListBuilder<AssetQuoteCacheTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<AssetQuoteCache>(
      columnValues: columnValues(AssetQuoteCache.t.updateTable),
      where: where(AssetQuoteCache.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetQuoteCache.t),
      orderByList: orderByList?.call(AssetQuoteCache.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [AssetQuoteCache]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<AssetQuoteCache>> delete(
    _i1.DatabaseSession session,
    List<AssetQuoteCache> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<AssetQuoteCache>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [AssetQuoteCache].
  Future<AssetQuoteCache> deleteRow(
    _i1.DatabaseSession session,
    AssetQuoteCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssetQuoteCache>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<AssetQuoteCache>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<AssetQuoteCache>(
      where: where(AssetQuoteCache.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AssetQuoteCacheTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<AssetQuoteCache>(
      where: where?.call(AssetQuoteCache.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssetQuoteCache] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AssetQuoteCacheTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssetQuoteCache>(
      where: where(AssetQuoteCache.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
