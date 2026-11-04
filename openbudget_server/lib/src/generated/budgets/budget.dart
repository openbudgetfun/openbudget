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

/// A budget owned by a user, representing a financial plan in a specific currency.
abstract class Budget
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Budget._({
    this.id,
    required this.name,
    required this.currencyCode,
    this.displayCurrencyCode,
    required this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Budget({
    _is.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _is.UuidValue ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetImpl;

  factory Budget.fromJson(Map<String, dynamic> jsonSerialization) {
    return Budget(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String,
      displayCurrencyCode: jsonSerialization['displayCurrencyCode'] as String?,
      ownerId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = BudgetTable();

  static const db = BudgetRepository._();

  @override
  _is.UuidValue? id;

  String name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  String currencyCode;

  /// Optional display currency override for aggregated/reporting views.
  /// If null, the budget's native currencyCode is used for display.
  String? displayCurrencyCode;

  /// The user who owns this budget.
  _is.UuidValue ownerId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Budget copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    _is.UuidValue? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Budget',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'currencyCode': currencyCode,
      if (displayCurrencyCode != null)
        'displayCurrencyCode': displayCurrencyCode,
      'ownerId': ownerId.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Budget',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'currencyCode': currencyCode,
      if (displayCurrencyCode != null)
        'displayCurrencyCode': displayCurrencyCode,
      'ownerId': ownerId.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static BudgetInclude include() {
    return BudgetInclude._();
  }

  static BudgetIncludeList includeList({
    _is.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    BudgetInclude? include,
  }) {
    return BudgetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BudgetImpl extends Budget {
  _BudgetImpl({
    _is.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _is.UuidValue ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         name: name,
         currencyCode: currencyCode,
         displayCurrencyCode: displayCurrencyCode,
         ownerId: ownerId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Budget copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    String? currencyCode,
    Object? displayCurrencyCode = _Undefined,
    _is.UuidValue? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id is _is.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      displayCurrencyCode: displayCurrencyCode is String?
          ? displayCurrencyCode
          : this.displayCurrencyCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetUpdateTable extends _is.UpdateTable<BudgetTable> {
  BudgetUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<String, String> displayCurrencyCode(String? value) =>
      _is.ColumnValue(
        table.displayCurrencyCode,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ownerId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.ownerId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class BudgetTable extends _is.Table<_is.UuidValue?> {
  BudgetTable({super.tableRelation}) : super(tableName: 'budget') {
    updateTable = BudgetUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    displayCurrencyCode = _is.ColumnString(
      'displayCurrencyCode',
      this,
    );
    ownerId = _is.ColumnUuid(
      'ownerId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final BudgetUpdateTable updateTable;

  late final _is.ColumnString name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  late final _is.ColumnString currencyCode;

  /// Optional display currency override for aggregated/reporting views.
  /// If null, the budget's native currencyCode is used for display.
  late final _is.ColumnString displayCurrencyCode;

  /// The user who owns this budget.
  late final _is.ColumnUuid ownerId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    currencyCode,
    displayCurrencyCode,
    ownerId,
    createdAt,
    updatedAt,
  ];
}

class BudgetInclude extends _is.IncludeObject {
  BudgetInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Budget.t;
}

class BudgetIncludeList extends _is.IncludeList {
  BudgetIncludeList._({
    _is.WhereExpressionBuilder<BudgetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Budget.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Budget.t;
}

class BudgetRepository {
  const BudgetRepository._();

  /// Returns a list of [Budget]s matching the given query parameters.
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
  Future<List<Budget>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Budget>(
      where: where?.call(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Budget]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Budget.t`.
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
  _ida.Stream<List<Budget>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Budget>(
      where: where?.call(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Budget] matching the given query parameters.
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
  Future<Budget?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTable>? where,
    int? offset,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Budget>(
      where: where?.call(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Budget] by its [id] or null if no such row exists.
  Future<Budget?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Budget>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Budget]s in the list and returns the inserted rows.
  ///
  /// The returned [Budget]s will have their `id` fields set.
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
  Future<List<Budget>> insert(
    _is.DatabaseSession session,
    List<Budget> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Budget>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Budget] and returns the inserted row.
  ///
  /// The returned [Budget] will have its `id` field set.
  Future<Budget> insertRow(
    _is.DatabaseSession session,
    Budget row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Budget>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Budget]s in the list and returns the resulting rows.
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
  /// The returned [Budget]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Budget>> upsert(
    _is.DatabaseSession session,
    List<Budget> rows, {
    required _is.ColumnSelections<BudgetTable> conflictColumns,
    _is.ColumnSelections<BudgetTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Budget>(
      rows,
      conflictColumns: conflictColumns(Budget.t),
      updateColumns: updateColumns?.call(Budget.t),
      updateWhere: updateWhere?.call(Budget.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Budget] and returns the resulting row.
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
  /// The returned [Budget] will have its `id` field set.
  Future<Budget?> upsertRow(
    _is.DatabaseSession session,
    Budget row, {
    required _is.ColumnSelections<BudgetTable> conflictColumns,
    _is.ColumnSelections<BudgetTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Budget>(
      row,
      conflictColumns: conflictColumns(Budget.t),
      updateColumns: updateColumns?.call(Budget.t),
      updateWhere: updateWhere?.call(Budget.t),
      transaction: transaction,
    );
  }

  /// Updates all [Budget]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Budget>> update(
    _is.DatabaseSession session,
    List<Budget> rows, {
    _is.ColumnSelections<BudgetTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Budget>(
      rows,
      columns: columns?.call(Budget.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Budget]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Budget> updateRow(
    _is.DatabaseSession session,
    Budget row, {
    _is.ColumnSelections<BudgetTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Budget>(
      row,
      columns: columns?.call(Budget.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Budget] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Budget?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<BudgetUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Budget>(
      id,
      columnValues: columnValues(Budget.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Budget]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Budget>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BudgetUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BudgetTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Budget>(
      columnValues: columnValues(Budget.t.updateTable),
      where: where(Budget.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Budget]s in the list and returns the deleted rows.
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
  Future<List<Budget>> delete(
    _is.DatabaseSession session,
    List<Budget> rows, {
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Budget>(
      rows,
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Budget].
  Future<Budget> deleteRow(
    _is.DatabaseSession session,
    Budget row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Budget>(
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
  Future<List<Budget>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTable> where,
    _is.OrderByBuilder<BudgetTable>? orderBy,
    _is.OrderByListBuilder<BudgetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Budget>(
      where: where(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Budget>(
      where: where?.call(Budget.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Budget] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Budget>(
      where: where(Budget.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
