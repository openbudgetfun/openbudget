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

/// Per-month allocation for an envelope, enabling monthly budget cycles.
abstract class MonthlyAllocation
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  MonthlyAllocation._({
    this.id,
    required this.envelopeId,
    required this.budgetId,
    required this.year,
    required this.month,
    required this.allocatedCents,
    required this.carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MonthlyAllocation({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required _i1.UuidValue budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    required int carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonthlyAllocationImpl;

  factory MonthlyAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlyAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      envelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      year: jsonSerialization['year'] as int,
      month: jsonSerialization['month'] as int,
      allocatedCents: jsonSerialization['allocatedCents'] as int,
      carryoverCents: jsonSerialization['carryoverCents'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = MonthlyAllocationTable();

  static const db = MonthlyAllocationRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue envelopeId;

  _i1.UuidValue budgetId;

  /// The year of the budget month (e.g. 2026).
  int year;

  /// The month of the budget month (1-12).
  int month;

  /// Amount allocated to this envelope for this month, in integer cents.
  int allocatedCents;

  /// Amount carried over from the previous month, in integer cents.
  int carryoverCents;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MonthlyAllocation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
    int? year,
    int? month,
    int? allocatedCents,
    int? carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'budgetId': budgetId.toJson(),
      'year': year,
      'month': month,
      'allocatedCents': allocatedCents,
      'carryoverCents': carryoverCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'budgetId': budgetId.toJson(),
      'year': year,
      'month': month,
      'allocatedCents': allocatedCents,
      'carryoverCents': carryoverCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static MonthlyAllocationInclude include() {
    return MonthlyAllocationInclude._();
  }

  static MonthlyAllocationIncludeList includeList({
    _i1.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    MonthlyAllocationInclude? include,
  }) {
    return MonthlyAllocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MonthlyAllocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MonthlyAllocationImpl extends MonthlyAllocation {
  _MonthlyAllocationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required _i1.UuidValue budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    required int carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         envelopeId: envelopeId,
         budgetId: budgetId,
         year: year,
         month: month,
         allocatedCents: allocatedCents,
         carryoverCents: carryoverCents,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MonthlyAllocation copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
    int? year,
    int? month,
    int? allocatedCents,
    int? carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyAllocation(
      id: id is _i1.UuidValue? ? id : this.id,
      envelopeId: envelopeId ?? this.envelopeId,
      budgetId: budgetId ?? this.budgetId,
      year: year ?? this.year,
      month: month ?? this.month,
      allocatedCents: allocatedCents ?? this.allocatedCents,
      carryoverCents: carryoverCents ?? this.carryoverCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MonthlyAllocationUpdateTable
    extends _i1.UpdateTable<MonthlyAllocationTable> {
  MonthlyAllocationUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> envelopeId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(table.envelopeId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.budgetId, value);

  _i1.ColumnValue<int, int> year(int value) =>
      _i1.ColumnValue(table.year, value);

  _i1.ColumnValue<int, int> month(int value) =>
      _i1.ColumnValue(table.month, value);

  _i1.ColumnValue<int, int> allocatedCents(int value) =>
      _i1.ColumnValue(table.allocatedCents, value);

  _i1.ColumnValue<int, int> carryoverCents(int value) =>
      _i1.ColumnValue(table.carryoverCents, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class MonthlyAllocationTable extends _i1.Table<_i1.UuidValue?> {
  MonthlyAllocationTable({super.tableRelation})
    : super(tableName: 'monthly_allocation') {
    updateTable = MonthlyAllocationUpdateTable(this);
    envelopeId = _i1.ColumnUuid('envelopeId', this);
    budgetId = _i1.ColumnUuid('budgetId', this);
    year = _i1.ColumnInt('year', this);
    month = _i1.ColumnInt('month', this);
    allocatedCents = _i1.ColumnInt('allocatedCents', this);
    carryoverCents = _i1.ColumnInt('carryoverCents', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
    updatedAt = _i1.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final MonthlyAllocationUpdateTable updateTable;

  late final _i1.ColumnUuid envelopeId;

  late final _i1.ColumnUuid budgetId;

  /// The year of the budget month (e.g. 2026).
  late final _i1.ColumnInt year;

  /// The month of the budget month (1-12).
  late final _i1.ColumnInt month;

  /// Amount allocated to this envelope for this month, in integer cents.
  late final _i1.ColumnInt allocatedCents;

  /// Amount carried over from the previous month, in integer cents.
  late final _i1.ColumnInt carryoverCents;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    envelopeId,
    budgetId,
    year,
    month,
    allocatedCents,
    carryoverCents,
    createdAt,
    updatedAt,
  ];
}

class MonthlyAllocationInclude extends _i1.IncludeObject {
  MonthlyAllocationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => MonthlyAllocation.t;
}

class MonthlyAllocationIncludeList extends _i1.IncludeList {
  MonthlyAllocationIncludeList._({
    _i1.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MonthlyAllocation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => MonthlyAllocation.t;
}

class MonthlyAllocationRepository {
  const MonthlyAllocationRepository._();

  /// Returns a list of [MonthlyAllocation]s matching the given query parameters.
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
  Future<List<MonthlyAllocation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MonthlyAllocation] matching the given query parameters.
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
  Future<MonthlyAllocation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? offset,
    _i1.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MonthlyAllocation] by its [id] or null if no such row exists.
  Future<MonthlyAllocation?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MonthlyAllocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MonthlyAllocation]s in the list and returns the inserted rows.
  ///
  /// The returned [MonthlyAllocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MonthlyAllocation>> insert(
    _i1.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MonthlyAllocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MonthlyAllocation] and returns the inserted row.
  ///
  /// The returned [MonthlyAllocation] will have its `id` field set.
  Future<MonthlyAllocation> insertRow(
    _i1.DatabaseSession session,
    MonthlyAllocation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MonthlyAllocation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MonthlyAllocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MonthlyAllocation>> update(
    _i1.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _i1.ColumnSelections<MonthlyAllocationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MonthlyAllocation>(
      rows,
      columns: columns?.call(MonthlyAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MonthlyAllocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MonthlyAllocation> updateRow(
    _i1.DatabaseSession session,
    MonthlyAllocation row, {
    _i1.ColumnSelections<MonthlyAllocationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MonthlyAllocation>(
      row,
      columns: columns?.call(MonthlyAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MonthlyAllocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MonthlyAllocation?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MonthlyAllocationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MonthlyAllocation>(
      id,
      columnValues: columnValues(MonthlyAllocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MonthlyAllocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MonthlyAllocation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MonthlyAllocationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MonthlyAllocationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MonthlyAllocationTable>? orderBy,
    _i1.OrderByListBuilder<MonthlyAllocationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MonthlyAllocation>(
      columnValues: columnValues(MonthlyAllocation.t.updateTable),
      where: where(MonthlyAllocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MonthlyAllocation.t),
      orderByList: orderByList?.call(MonthlyAllocation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MonthlyAllocation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MonthlyAllocation>> delete(
    _i1.DatabaseSession session,
    List<MonthlyAllocation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MonthlyAllocation>(rows, transaction: transaction);
  }

  /// Deletes a single [MonthlyAllocation].
  Future<MonthlyAllocation> deleteRow(
    _i1.DatabaseSession session,
    MonthlyAllocation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MonthlyAllocation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MonthlyAllocation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MonthlyAllocationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MonthlyAllocation>(
      where: where(MonthlyAllocation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MonthlyAllocationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MonthlyAllocation>(
      where: where?.call(MonthlyAllocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MonthlyAllocation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MonthlyAllocationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MonthlyAllocation>(
      where: where(MonthlyAllocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
