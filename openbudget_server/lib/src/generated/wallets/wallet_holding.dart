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

/// Native-asset holding for a wallet connection.
abstract class WalletHolding
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WalletHolding._({
    this.id,
    required this.walletConnectionId,
    required this.chain,
    required this.assetId,
    required this.symbol,
    required this.decimals,
    required this.quantityBaseUnits,
    required this.quantityDisplay,
    this.usdPrice,
    this.usdValue,
    DateTime? lastSyncedAt,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  factory WalletHolding({
    _is.UuidValue? id,
    required _is.UuidValue walletConnectionId,
    required String chain,
    required String assetId,
    required String symbol,
    required int decimals,
    required String quantityBaseUnits,
    required double quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  }) = _WalletHoldingImpl;

  factory WalletHolding.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletHolding(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletConnectionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletConnectionId'],
      ),
      chain: jsonSerialization['chain'] as String,
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String,
      decimals: jsonSerialization['decimals'] as int,
      quantityBaseUnits: jsonSerialization['quantityBaseUnits'] as String,
      quantityDisplay: (jsonSerialization['quantityDisplay'] as num).toDouble(),
      usdPrice: (jsonSerialization['usdPrice'] as num?)?.toDouble(),
      usdValue: (jsonSerialization['usdValue'] as num?)?.toDouble(),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
    );
  }

  static final t = WalletHoldingTable();

  static const db = WalletHoldingRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletConnectionId;

  String chain;

  String assetId;

  String symbol;

  int decimals;

  String quantityBaseUnits;

  double quantityDisplay;

  double? usdPrice;

  double? usdValue;

  DateTime lastSyncedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletConnectionId,
    String? chain,
    String? assetId,
    String? symbol,
    int? decimals,
    String? quantityBaseUnits,
    double? quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletConnectionId': walletConnectionId.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'decimals': decimals,
      'quantityBaseUnits': quantityBaseUnits,
      'quantityDisplay': quantityDisplay,
      if (usdPrice != null) 'usdPrice': usdPrice,
      if (usdValue != null) 'usdValue': usdValue,
      'lastSyncedAt': lastSyncedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletConnectionId': walletConnectionId.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'decimals': decimals,
      'quantityBaseUnits': quantityBaseUnits,
      'quantityDisplay': quantityDisplay,
      if (usdPrice != null) 'usdPrice': usdPrice,
      if (usdValue != null) 'usdValue': usdValue,
      'lastSyncedAt': lastSyncedAt.toJson(),
    };
  }

  static WalletHoldingInclude include() {
    return WalletHoldingInclude._();
  }

  static WalletHoldingIncludeList includeList({
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    WalletHoldingInclude? include,
  }) {
    return WalletHoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletHoldingImpl extends WalletHolding {
  _WalletHoldingImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletConnectionId,
    required String chain,
    required String assetId,
    required String symbol,
    required int decimals,
    required String quantityBaseUnits,
    required double quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  }) : super._(
         id: id,
         walletConnectionId: walletConnectionId,
         chain: chain,
         assetId: assetId,
         symbol: symbol,
         decimals: decimals,
         quantityBaseUnits: quantityBaseUnits,
         quantityDisplay: quantityDisplay,
         usdPrice: usdPrice,
         usdValue: usdValue,
         lastSyncedAt: lastSyncedAt,
       );

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletConnectionId,
    String? chain,
    String? assetId,
    String? symbol,
    int? decimals,
    String? quantityBaseUnits,
    double? quantityDisplay,
    Object? usdPrice = _Undefined,
    Object? usdValue = _Undefined,
    DateTime? lastSyncedAt,
  }) {
    return WalletHolding(
      id: id is _is.UndefinedSentinel ? this.id : id,
      walletConnectionId: walletConnectionId ?? this.walletConnectionId,
      chain: chain ?? this.chain,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      quantityBaseUnits: quantityBaseUnits ?? this.quantityBaseUnits,
      quantityDisplay: quantityDisplay ?? this.quantityDisplay,
      usdPrice: usdPrice is double? ? usdPrice : this.usdPrice,
      usdValue: usdValue is double? ? usdValue : this.usdValue,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class WalletHoldingUpdateTable extends _is.UpdateTable<WalletHoldingTable> {
  WalletHoldingUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletConnectionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.walletConnectionId,
    value,
  );

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

  _is.ColumnValue<int, int> decimals(int value) => _is.ColumnValue(
    table.decimals,
    value,
  );

  _is.ColumnValue<String, String> quantityBaseUnits(String value) =>
      _is.ColumnValue(
        table.quantityBaseUnits,
        value,
      );

  _is.ColumnValue<double, double> quantityDisplay(double value) =>
      _is.ColumnValue(
        table.quantityDisplay,
        value,
      );

  _is.ColumnValue<double, double> usdPrice(double? value) => _is.ColumnValue(
    table.usdPrice,
    value,
  );

  _is.ColumnValue<double, double> usdValue(double? value) => _is.ColumnValue(
    table.usdValue,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
        value,
      );
}

class WalletHoldingTable extends _is.Table<_is.UuidValue?> {
  WalletHoldingTable({super.tableRelation})
    : super(tableName: 'wallet_holding') {
    updateTable = WalletHoldingUpdateTable(this);
    walletConnectionId = _is.ColumnUuid(
      'walletConnectionId',
      this,
    );
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
    decimals = _is.ColumnInt(
      'decimals',
      this,
    );
    quantityBaseUnits = _is.ColumnString(
      'quantityBaseUnits',
      this,
    );
    quantityDisplay = _is.ColumnDouble(
      'quantityDisplay',
      this,
    );
    usdPrice = _is.ColumnDouble(
      'usdPrice',
      this,
    );
    usdValue = _is.ColumnDouble(
      'usdValue',
      this,
    );
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
      this,
      hasDefault: true,
    );
  }

  late final WalletHoldingUpdateTable updateTable;

  late final _is.ColumnUuid walletConnectionId;

  late final _is.ColumnString chain;

  late final _is.ColumnString assetId;

  late final _is.ColumnString symbol;

  late final _is.ColumnInt decimals;

  late final _is.ColumnString quantityBaseUnits;

  late final _is.ColumnDouble quantityDisplay;

  late final _is.ColumnDouble usdPrice;

  late final _is.ColumnDouble usdValue;

  late final _is.ColumnDateTime lastSyncedAt;

  @override
  List<_is.Column> get columns => [
    id,
    walletConnectionId,
    chain,
    assetId,
    symbol,
    decimals,
    quantityBaseUnits,
    quantityDisplay,
    usdPrice,
    usdValue,
    lastSyncedAt,
  ];
}

class WalletHoldingInclude extends _is.IncludeObject {
  WalletHoldingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletHolding.t;
}

class WalletHoldingIncludeList extends _is.IncludeList {
  WalletHoldingIncludeList._({
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletHolding.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletHolding.t;
}

class WalletHoldingRepository {
  const WalletHoldingRepository._();

  /// Returns a list of [WalletHolding]s matching the given query parameters.
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
  Future<List<WalletHolding>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [WalletHolding]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `WalletHolding.t`.
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
  _ida.Stream<List<WalletHolding>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [WalletHolding] matching the given query parameters.
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
  Future<WalletHolding?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletHolding] by its [id] or null if no such row exists.
  Future<WalletHolding?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WalletHolding>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WalletHolding]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletHolding]s will have their `id` fields set.
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
  Future<List<WalletHolding>> insert(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WalletHolding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WalletHolding] and returns the inserted row.
  ///
  /// The returned [WalletHolding] will have its `id` field set.
  Future<WalletHolding> insertRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WalletHolding]s in the list and returns the resulting rows.
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
  /// The returned [WalletHolding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> upsert(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    required _is.ColumnSelections<WalletHoldingTable> conflictColumns,
    _is.ColumnSelections<WalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WalletHolding>(
      rows,
      conflictColumns: conflictColumns(WalletHolding.t),
      updateColumns: updateColumns?.call(WalletHolding.t),
      updateWhere: updateWhere?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WalletHolding] and returns the resulting row.
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
  /// The returned [WalletHolding] will have its `id` field set.
  Future<WalletHolding?> upsertRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    required _is.ColumnSelections<WalletHoldingTable> conflictColumns,
    _is.ColumnSelections<WalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WalletHolding>(
      row,
      conflictColumns: conflictColumns(WalletHolding.t),
      updateColumns: updateColumns?.call(WalletHolding.t),
      updateWhere: updateWhere?.call(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> update(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.ColumnSelections<WalletHoldingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WalletHolding>(
      rows,
      columns: columns?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WalletHolding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletHolding> updateRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.ColumnSelections<WalletHoldingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WalletHolding>(
      row,
      columns: columns?.call(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletHolding] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WalletHolding?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletHolding>(
      id,
      columnValues: columnValues(WalletHolding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WalletHolding>(
      columnValues: columnValues(WalletHolding.t.updateTable),
      where: where(WalletHolding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WalletHolding]s in the list and returns the deleted rows.
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
  Future<List<WalletHolding>> delete(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WalletHolding>(
      rows,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WalletHolding].
  Future<WalletHolding> deleteRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletHolding>(
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
  Future<List<WalletHolding>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WalletHolding>(
      where: where(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WalletHolding>(
      where: where?.call(WalletHolding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletHolding] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletHolding>(
      where: where(WalletHolding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
