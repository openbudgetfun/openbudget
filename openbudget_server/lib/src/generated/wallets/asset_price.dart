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

import '../wallets/price_source.dart' as _ip9y7dom;
import '../wallets/wallet_network.dart' as _ilag50y5;

/// Cached price of one on-chain asset.
abstract class AssetPrice
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AssetPrice._({
    this.id,
    required this.network,
    required this.assetId,
    this.symbol,
    required this.currencyCode,
    required this.unitPrice,
    required this.source,
    required this.fetchedAt,
    required this.expiresAt,
  });

  factory AssetPrice({
    _is.UuidValue? id,
    required _ilag50y5.WalletNetwork network,
    required String assetId,
    String? symbol,
    required String currencyCode,
    required String unitPrice,
    required _ip9y7dom.PriceSource source,
    required DateTime fetchedAt,
    required DateTime expiresAt,
  }) = _AssetPriceImpl;

  factory AssetPrice.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetPrice(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      network: _ilag50y5.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String?,
      currencyCode: jsonSerialization['currencyCode'] as String,
      unitPrice: jsonSerialization['unitPrice'] as String,
      source: _ip9y7dom.PriceSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      fetchedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = AssetPriceTable();

  static const db = AssetPriceRepository._();

  @override
  _is.UuidValue? id;

  _ilag50y5.WalletNetwork network;

  String assetId;

  String? symbol;

  /// ISO 4217 code of unitPrice (USD today).
  String currencyCode;

  /// Price of one whole token, exact decimal string.
  String unitPrice;

  _ip9y7dom.PriceSource source;

  DateTime fetchedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AssetPrice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssetPrice copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _ilag50y5.WalletNetwork? network,
    String? assetId,
    String? symbol,
    String? currencyCode,
    String? unitPrice,
    _ip9y7dom.PriceSource? source,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetPrice',
      if (id != null) 'id': id?.toJson(),
      'network': network.toJson(),
      'assetId': assetId,
      if (symbol != null) 'symbol': symbol,
      'currencyCode': currencyCode,
      'unitPrice': unitPrice,
      'source': source.toJson(),
      'fetchedAt': fetchedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AssetPriceInclude include() {
    return AssetPriceInclude._();
  }

  static AssetPriceIncludeList includeList({
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    AssetPriceInclude? include,
  }) {
    return AssetPriceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetPriceImpl extends AssetPrice {
  _AssetPriceImpl({
    _is.UuidValue? id,
    required _ilag50y5.WalletNetwork network,
    required String assetId,
    String? symbol,
    required String currencyCode,
    required String unitPrice,
    required _ip9y7dom.PriceSource source,
    required DateTime fetchedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         network: network,
         assetId: assetId,
         symbol: symbol,
         currencyCode: currencyCode,
         unitPrice: unitPrice,
         source: source,
         fetchedAt: fetchedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AssetPrice]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssetPrice copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _ilag50y5.WalletNetwork? network,
    String? assetId,
    Object? symbol = _Undefined,
    String? currencyCode,
    String? unitPrice,
    _ip9y7dom.PriceSource? source,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) {
    return AssetPrice(
      id: id is _is.UndefinedSentinel ? this.id : id,
      network: network ?? this.network,
      assetId: assetId ?? this.assetId,
      symbol: symbol is String? ? symbol : this.symbol,
      currencyCode: currencyCode ?? this.currencyCode,
      unitPrice: unitPrice ?? this.unitPrice,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class AssetPriceUpdateTable extends _is.UpdateTable<AssetPriceTable> {
  AssetPriceUpdateTable(super.table);

  _is.ColumnValue<_ilag50y5.WalletNetwork, _ilag50y5.WalletNetwork> network(
    _ilag50y5.WalletNetwork value,
  ) => _is.ColumnValue(
    table.network,
    value,
  );

  _is.ColumnValue<String, String> assetId(String value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<String, String> symbol(String? value) => _is.ColumnValue(
    table.symbol,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<String, String> unitPrice(String value) => _is.ColumnValue(
    table.unitPrice,
    value,
  );

  _is.ColumnValue<_ip9y7dom.PriceSource, _ip9y7dom.PriceSource> source(
    _ip9y7dom.PriceSource value,
  ) => _is.ColumnValue(
    table.source,
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

class AssetPriceTable extends _is.Table<_is.UuidValue?> {
  AssetPriceTable({super.tableRelation}) : super(tableName: 'asset_price') {
    updateTable = AssetPriceUpdateTable(this);
    network = _is.ColumnEnum(
      'network',
      this,
      _is.EnumSerialization.byName,
    );
    assetId = _is.ColumnString(
      'assetId',
      this,
    );
    symbol = _is.ColumnString(
      'symbol',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    unitPrice = _is.ColumnString(
      'unitPrice',
      this,
    );
    source = _is.ColumnEnum(
      'source',
      this,
      _is.EnumSerialization.byName,
    );
    fetchedAt = _is.ColumnDateTime(
      'fetchedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final AssetPriceUpdateTable updateTable;

  late final _is.ColumnEnum<_ilag50y5.WalletNetwork> network;

  late final _is.ColumnString assetId;

  late final _is.ColumnString symbol;

  /// ISO 4217 code of unitPrice (USD today).
  late final _is.ColumnString currencyCode;

  /// Price of one whole token, exact decimal string.
  late final _is.ColumnString unitPrice;

  late final _is.ColumnEnum<_ip9y7dom.PriceSource> source;

  late final _is.ColumnDateTime fetchedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    network,
    assetId,
    symbol,
    currencyCode,
    unitPrice,
    source,
    fetchedAt,
    expiresAt,
  ];
}

class AssetPriceInclude extends _is.IncludeObject {
  AssetPriceInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AssetPrice.t;
}

class AssetPriceIncludeList extends _is.IncludeList {
  AssetPriceIncludeList._({
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssetPrice.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AssetPrice.t;
}

class AssetPriceRepository {
  const AssetPriceRepository._();

  /// Returns a list of [AssetPrice]s matching the given query parameters.
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
  Future<List<AssetPrice>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssetPrice>(
      where: where?.call(AssetPrice.t),
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AssetPrice]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AssetPrice.t`.
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
  _ida.Stream<List<AssetPrice>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AssetPrice>(
      where: where?.call(AssetPrice.t),
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AssetPrice] matching the given query parameters.
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
  Future<AssetPrice?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    int? offset,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssetPrice>(
      where: where?.call(AssetPrice.t),
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssetPrice] by its [id] or null if no such row exists.
  Future<AssetPrice?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssetPrice>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssetPrice]s in the list and returns the inserted rows.
  ///
  /// The returned [AssetPrice]s will have their `id` fields set.
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
  Future<List<AssetPrice>> insert(
    _is.DatabaseSession session,
    List<AssetPrice> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssetPrice>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssetPrice] and returns the inserted row.
  ///
  /// The returned [AssetPrice] will have its `id` field set.
  Future<AssetPrice> insertRow(
    _is.DatabaseSession session,
    AssetPrice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssetPrice>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AssetPrice]s in the list and returns the resulting rows.
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
  /// The returned [AssetPrice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetPrice>> upsert(
    _is.DatabaseSession session,
    List<AssetPrice> rows, {
    required _is.ColumnSelections<AssetPriceTable> conflictColumns,
    _is.ColumnSelections<AssetPriceTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetPriceTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssetPrice>(
      rows,
      conflictColumns: conflictColumns(AssetPrice.t),
      updateColumns: updateColumns?.call(AssetPrice.t),
      updateWhere: updateWhere?.call(AssetPrice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssetPrice] and returns the resulting row.
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
  /// The returned [AssetPrice] will have its `id` field set.
  Future<AssetPrice?> upsertRow(
    _is.DatabaseSession session,
    AssetPrice row, {
    required _is.ColumnSelections<AssetPriceTable> conflictColumns,
    _is.ColumnSelections<AssetPriceTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetPriceTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssetPrice>(
      row,
      conflictColumns: conflictColumns(AssetPrice.t),
      updateColumns: updateColumns?.call(AssetPrice.t),
      updateWhere: updateWhere?.call(AssetPrice.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssetPrice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetPrice>> update(
    _is.DatabaseSession session,
    List<AssetPrice> rows, {
    _is.ColumnSelections<AssetPriceTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssetPrice>(
      rows,
      columns: columns?.call(AssetPrice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssetPrice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssetPrice> updateRow(
    _is.DatabaseSession session,
    AssetPrice row, {
    _is.ColumnSelections<AssetPriceTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssetPrice>(
      row,
      columns: columns?.call(AssetPrice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssetPrice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssetPrice?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssetPriceUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssetPrice>(
      id,
      columnValues: columnValues(AssetPrice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssetPrice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetPrice>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssetPriceUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssetPriceTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssetPrice>(
      columnValues: columnValues(AssetPrice.t.updateTable),
      where: where(AssetPrice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssetPrice]s in the list and returns the deleted rows.
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
  Future<List<AssetPrice>> delete(
    _is.DatabaseSession session,
    List<AssetPrice> rows, {
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssetPrice>(
      rows,
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssetPrice].
  Future<AssetPrice> deleteRow(
    _is.DatabaseSession session,
    AssetPrice row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssetPrice>(
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
  Future<List<AssetPrice>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetPriceTable> where,
    _is.OrderByBuilder<AssetPriceTable>? orderBy,
    _is.OrderByListBuilder<AssetPriceTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssetPrice>(
      where: where(AssetPrice.t),
      orderBy: orderBy?.call(AssetPrice.t),
      orderByList: orderByList?.call(AssetPrice.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetPriceTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssetPrice>(
      where: where?.call(AssetPrice.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssetPrice] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetPriceTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssetPrice>(
      where: where(AssetPrice.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
