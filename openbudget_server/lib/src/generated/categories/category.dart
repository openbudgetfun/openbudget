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

/// A grouping of envelopes within a budget.
abstract class Category
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Category._({
    this.id,
    required this.name,
    required this.budgetId,
    required this.sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) : isHidden = isHidden ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Category({
    _is.UuidValue? id,
    required String name,
    required _is.UuidValue budgetId,
    required int sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) = _CategoryImpl;

  factory Category.fromJson(Map<String, dynamic> jsonSerialization) {
    return Category(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as int,
      isHidden: jsonSerialization['isHidden'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isHidden']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CategoryTable();

  static const db = CategoryRepository._();

  @override
  _is.UuidValue? id;

  String name;

  _is.UuidValue budgetId;

  int sortOrder;

  /// Whether this category is hidden from the default budget view.
  bool? isHidden;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Category copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    _is.UuidValue? budgetId,
    int? sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Category',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'sortOrder': sortOrder,
      if (isHidden != null) 'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Category',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'sortOrder': sortOrder,
      if (isHidden != null) 'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
    };
  }

  static CategoryInclude include() {
    return CategoryInclude._();
  }

  static CategoryIncludeList includeList({
    _is.WhereExpressionBuilder<CategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    CategoryInclude? include,
  }) {
    return CategoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CategoryImpl extends Category {
  _CategoryImpl({
    _is.UuidValue? id,
    required String name,
    required _is.UuidValue budgetId,
    required int sortOrder,
    bool? isHidden,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         budgetId: budgetId,
         sortOrder: sortOrder,
         isHidden: isHidden,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Category]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Category copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    _is.UuidValue? budgetId,
    int? sortOrder,
    Object? isHidden = _Undefined,
    DateTime? createdAt,
  }) {
    return Category(
      id: id is _is.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      budgetId: budgetId ?? this.budgetId,
      sortOrder: sortOrder ?? this.sortOrder,
      isHidden: isHidden is bool? ? isHidden : this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CategoryUpdateTable extends _is.UpdateTable<CategoryTable> {
  CategoryUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<bool, bool> isHidden(bool? value) => _is.ColumnValue(
    table.isHidden,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CategoryTable extends _is.Table<_is.UuidValue?> {
  CategoryTable({super.tableRelation}) : super(tableName: 'category') {
    updateTable = CategoryUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
    );
    isHidden = _is.ColumnBool(
      'isHidden',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final CategoryUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnUuid budgetId;

  late final _is.ColumnInt sortOrder;

  /// Whether this category is hidden from the default budget view.
  late final _is.ColumnBool isHidden;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    budgetId,
    sortOrder,
    isHidden,
    createdAt,
  ];
}

class CategoryInclude extends _is.IncludeObject {
  CategoryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Category.t;
}

class CategoryIncludeList extends _is.IncludeList {
  CategoryIncludeList._({
    _is.WhereExpressionBuilder<CategoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Category.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Category.t;
}

class CategoryRepository {
  const CategoryRepository._();

  /// Returns a list of [Category]s matching the given query parameters.
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
  Future<List<Category>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Category>(
      where: where?.call(Category.t),
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Category]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Category.t`.
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
  _ida.Stream<List<Category>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Category>(
      where: where?.call(Category.t),
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Category] matching the given query parameters.
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
  Future<Category?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CategoryTable>? where,
    int? offset,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Category>(
      where: where?.call(Category.t),
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Category] by its [id] or null if no such row exists.
  Future<Category?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Category>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Category]s in the list and returns the inserted rows.
  ///
  /// The returned [Category]s will have their `id` fields set.
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
  Future<List<Category>> insert(
    _is.DatabaseSession session,
    List<Category> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Category>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Category] and returns the inserted row.
  ///
  /// The returned [Category] will have its `id` field set.
  Future<Category> insertRow(
    _is.DatabaseSession session,
    Category row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Category>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Category]s in the list and returns the resulting rows.
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
  /// The returned [Category]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Category>> upsert(
    _is.DatabaseSession session,
    List<Category> rows, {
    required _is.ColumnSelections<CategoryTable> conflictColumns,
    _is.ColumnSelections<CategoryTable>? updateColumns,
    _is.WhereExpressionBuilder<CategoryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Category>(
      rows,
      conflictColumns: conflictColumns(Category.t),
      updateColumns: updateColumns?.call(Category.t),
      updateWhere: updateWhere?.call(Category.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Category] and returns the resulting row.
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
  /// The returned [Category] will have its `id` field set.
  Future<Category?> upsertRow(
    _is.DatabaseSession session,
    Category row, {
    required _is.ColumnSelections<CategoryTable> conflictColumns,
    _is.ColumnSelections<CategoryTable>? updateColumns,
    _is.WhereExpressionBuilder<CategoryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Category>(
      row,
      conflictColumns: conflictColumns(Category.t),
      updateColumns: updateColumns?.call(Category.t),
      updateWhere: updateWhere?.call(Category.t),
      transaction: transaction,
    );
  }

  /// Updates all [Category]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Category>> update(
    _is.DatabaseSession session,
    List<Category> rows, {
    _is.ColumnSelections<CategoryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Category>(
      rows,
      columns: columns?.call(Category.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Category]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Category> updateRow(
    _is.DatabaseSession session,
    Category row, {
    _is.ColumnSelections<CategoryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Category>(
      row,
      columns: columns?.call(Category.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Category] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Category?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CategoryUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Category>(
      id,
      columnValues: columnValues(Category.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Category]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Category>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CategoryUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CategoryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Category>(
      columnValues: columnValues(Category.t.updateTable),
      where: where(Category.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Category]s in the list and returns the deleted rows.
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
  Future<List<Category>> delete(
    _is.DatabaseSession session,
    List<Category> rows, {
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Category>(
      rows,
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Category].
  Future<Category> deleteRow(
    _is.DatabaseSession session,
    Category row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Category>(
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
  Future<List<Category>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CategoryTable> where,
    _is.OrderByBuilder<CategoryTable>? orderBy,
    _is.OrderByListBuilder<CategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Category>(
      where: where(Category.t),
      orderBy: orderBy?.call(Category.t),
      orderByList: orderByList?.call(Category.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CategoryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Category>(
      where: where?.call(Category.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Category] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CategoryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Category>(
      where: where(Category.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
