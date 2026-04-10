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

/// Native-asset holding for a wallet connection.
abstract class WalletHolding
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required _i1.UuidValue walletConnectionId,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletConnectionId: _i1.UuidValueJsonExtension.fromJson(
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
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
    );
  }

  static final t = WalletHoldingTable();

  static const db = WalletHoldingRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue walletConnectionId;

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
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WalletHolding copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? walletConnectionId,
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
    _i1.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletHoldingTable>? orderByList,
    WalletHoldingInclude? include,
  }) {
    return WalletHoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(WalletHolding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletHoldingImpl extends WalletHolding {
  _WalletHoldingImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue walletConnectionId,
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
  @_i1.useResult
  @override
  WalletHolding copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? walletConnectionId,
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
      id: id is _i1.UuidValue? ? id : this.id,
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

class WalletHoldingUpdateTable extends _i1.UpdateTable<WalletHoldingTable> {
  WalletHoldingUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> walletConnectionId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.walletConnectionId,
    value,
  );

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

  _i1.ColumnValue<int, int> decimals(int value) => _i1.ColumnValue(
    table.decimals,
    value,
  );

  _i1.ColumnValue<String, String> quantityBaseUnits(String value) =>
      _i1.ColumnValue(
        table.quantityBaseUnits,
        value,
      );

  _i1.ColumnValue<double, double> quantityDisplay(double value) =>
      _i1.ColumnValue(
        table.quantityDisplay,
        value,
      );

  _i1.ColumnValue<double, double> usdPrice(double? value) => _i1.ColumnValue(
    table.usdPrice,
    value,
  );

  _i1.ColumnValue<double, double> usdValue(double? value) => _i1.ColumnValue(
    table.usdValue,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );
}

class WalletHoldingTable extends _i1.Table<_i1.UuidValue?> {
  WalletHoldingTable({super.tableRelation})
    : super(tableName: 'wallet_holding') {
    updateTable = WalletHoldingUpdateTable(this);
    walletConnectionId = _i1.ColumnUuid(
      'walletConnectionId',
      this,
    );
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
    decimals = _i1.ColumnInt(
      'decimals',
      this,
    );
    quantityBaseUnits = _i1.ColumnString(
      'quantityBaseUnits',
      this,
    );
    quantityDisplay = _i1.ColumnDouble(
      'quantityDisplay',
      this,
    );
    usdPrice = _i1.ColumnDouble(
      'usdPrice',
      this,
    );
    usdValue = _i1.ColumnDouble(
      'usdValue',
      this,
    );
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
      hasDefault: true,
    );
  }

  late final WalletHoldingUpdateTable updateTable;

  late final _i1.ColumnUuid walletConnectionId;

  late final _i1.ColumnString chain;

  late final _i1.ColumnString assetId;

  late final _i1.ColumnString symbol;

  late final _i1.ColumnInt decimals;

  late final _i1.ColumnString quantityBaseUnits;

  late final _i1.ColumnDouble quantityDisplay;

  late final _i1.ColumnDouble usdPrice;

  late final _i1.ColumnDouble usdValue;

  late final _i1.ColumnDateTime lastSyncedAt;

  @override
  List<_i1.Column> get columns => [
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

class WalletHoldingInclude extends _i1.IncludeObject {
  WalletHoldingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => WalletHolding.t;
}

class WalletHoldingIncludeList extends _i1.IncludeList {
  WalletHoldingIncludeList._({
    _i1.WhereExpressionBuilder<WalletHoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletHolding.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => WalletHolding.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? offset,
    _i1.OrderByBuilder<WalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletHolding] by its [id] or null if no such row exists.
  Future<WalletHolding?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<WalletHolding>> insert(
    _i1.DatabaseSession session,
    List<WalletHolding> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<WalletHolding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [WalletHolding] and returns the inserted row.
  ///
  /// The returned [WalletHolding] will have its `id` field set.
  Future<WalletHolding> insertRow(
    _i1.DatabaseSession session,
    WalletHolding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<WalletHolding>> update(
    _i1.DatabaseSession session,
    List<WalletHolding> rows, {
    _i1.ColumnSelections<WalletHoldingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<WalletHolding>(
      rows,
      columns: columns?.call(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletHolding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletHolding> updateRow(
    _i1.DatabaseSession session,
    WalletHolding row, {
    _i1.ColumnSelections<WalletHoldingTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletHolding>(
      id,
      columnValues: columnValues(WalletHolding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<WalletHolding>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<WalletHoldingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalletHoldingTable>? orderBy,
    _i1.OrderByListBuilder<WalletHoldingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<WalletHolding>(
      columnValues: columnValues(WalletHolding.t.updateTable),
      where: where(WalletHolding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [WalletHolding]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<WalletHolding>> delete(
    _i1.DatabaseSession session,
    List<WalletHolding> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<WalletHolding>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [WalletHolding].
  Future<WalletHolding> deleteRow(
    _i1.DatabaseSession session,
    WalletHolding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<WalletHolding>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<WalletHoldingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<WalletHolding>(
      where: where(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<WalletHolding>(
      where: where?.call(WalletHolding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletHolding] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<WalletHoldingTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletHolding>(
      where: where(WalletHolding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
