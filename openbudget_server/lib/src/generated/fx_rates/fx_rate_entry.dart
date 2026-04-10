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

/// Individual currency exchange rate value in a snapshot.
abstract class FxRateEntry
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  FxRateEntry._({
    this.id,
    required this.snapshotId,
    required this.currencyCode,
    required this.rate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FxRateEntry({
    _i1.UuidValue? id,
    required _i1.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) = _FxRateEntryImpl;

  factory FxRateEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRateEntry(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      snapshotId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['snapshotId'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      rate: (jsonSerialization['rate'] as num).toDouble(),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FxRateEntryTable();

  static const db = FxRateEntryRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue snapshotId;

  String currencyCode;

  double rate;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxRateEntry copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRateEntry',
      if (id != null) 'id': id?.toJson(),
      'snapshotId': snapshotId.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxRateEntry',
      if (id != null) 'id': id?.toJson(),
      'snapshotId': snapshotId.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'createdAt': createdAt.toJson(),
    };
  }

  static FxRateEntryInclude include() {
    return FxRateEntryInclude._();
  }

  static FxRateEntryIncludeList includeList({
    _i1.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateEntryTable>? orderByList,
    FxRateEntryInclude? include,
  }) {
    return FxRateEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateEntry.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FxRateEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FxRateEntryImpl extends FxRateEntry {
  _FxRateEntryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue snapshotId,
    required String currencyCode,
    required double rate,
    DateTime? createdAt,
  }) : super._(
         id: id,
         snapshotId: snapshotId,
         currencyCode: currencyCode,
         rate: rate,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FxRateEntry]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxRateEntry copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? snapshotId,
    String? currencyCode,
    double? rate,
    DateTime? createdAt,
  }) {
    return FxRateEntry(
      id: id is _i1.UuidValue? ? id : this.id,
      snapshotId: snapshotId ?? this.snapshotId,
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FxRateEntryUpdateTable extends _i1.UpdateTable<FxRateEntryTable> {
  FxRateEntryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> snapshotId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.snapshotId,
    value,
  );

  _i1.ColumnValue<String, String> currencyCode(String value) => _i1.ColumnValue(
    table.currencyCode,
    value,
  );

  _i1.ColumnValue<double, double> rate(double value) => _i1.ColumnValue(
    table.rate,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class FxRateEntryTable extends _i1.Table<_i1.UuidValue?> {
  FxRateEntryTable({super.tableRelation}) : super(tableName: 'fx_rate_entry') {
    updateTable = FxRateEntryUpdateTable(this);
    snapshotId = _i1.ColumnUuid(
      'snapshotId',
      this,
    );
    currencyCode = _i1.ColumnString(
      'currencyCode',
      this,
    );
    rate = _i1.ColumnDouble(
      'rate',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final FxRateEntryUpdateTable updateTable;

  late final _i1.ColumnUuid snapshotId;

  late final _i1.ColumnString currencyCode;

  late final _i1.ColumnDouble rate;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    snapshotId,
    currencyCode,
    rate,
    createdAt,
  ];
}

class FxRateEntryInclude extends _i1.IncludeObject {
  FxRateEntryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxRateEntry.t;
}

class FxRateEntryIncludeList extends _i1.IncludeList {
  FxRateEntryIncludeList._({
    _i1.WhereExpressionBuilder<FxRateEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxRateEntry.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxRateEntry.t;
}

class FxRateEntryRepository {
  const FxRateEntryRepository._();

  /// Returns a list of [FxRateEntry]s matching the given query parameters.
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
  Future<List<FxRateEntry>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FxRateEntry] matching the given query parameters.
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
  Future<FxRateEntry?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? offset,
    _i1.OrderByBuilder<FxRateEntryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxRateEntryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FxRateEntry] by its [id] or null if no such row exists.
  Future<FxRateEntry?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FxRateEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FxRateEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [FxRateEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<FxRateEntry>> insert(
    _i1.DatabaseSession session,
    List<FxRateEntry> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<FxRateEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [FxRateEntry] and returns the inserted row.
  ///
  /// The returned [FxRateEntry] will have its `id` field set.
  Future<FxRateEntry> insertRow(
    _i1.DatabaseSession session,
    FxRateEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxRateEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FxRateEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FxRateEntry>> update(
    _i1.DatabaseSession session,
    List<FxRateEntry> rows, {
    _i1.ColumnSelections<FxRateEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FxRateEntry>(
      rows,
      columns: columns?.call(FxRateEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxRateEntry> updateRow(
    _i1.DatabaseSession session,
    FxRateEntry row, {
    _i1.ColumnSelections<FxRateEntryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxRateEntry>(
      row,
      columns: columns?.call(FxRateEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRateEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxRateEntry?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<FxRateEntryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FxRateEntry>(
      id,
      columnValues: columnValues(FxRateEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxRateEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FxRateEntry>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<FxRateEntryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FxRateEntryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxRateEntryTable>? orderBy,
    _i1.OrderByListBuilder<FxRateEntryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FxRateEntry>(
      columnValues: columnValues(FxRateEntry.t.updateTable),
      where: where(FxRateEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRateEntry.t),
      orderByList: orderByList?.call(FxRateEntry.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FxRateEntry]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FxRateEntry>> delete(
    _i1.DatabaseSession session,
    List<FxRateEntry> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FxRateEntry>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FxRateEntry].
  Future<FxRateEntry> deleteRow(
    _i1.DatabaseSession session,
    FxRateEntry row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxRateEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FxRateEntry>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FxRateEntryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FxRateEntry>(
      where: where(FxRateEntry.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FxRateEntryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FxRateEntry>(
      where: where?.call(FxRateEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FxRateEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FxRateEntryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FxRateEntry>(
      where: where(FxRateEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
