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

/// A saved allocation template that can be applied to any month.
abstract class BudgetTemplate
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  BudgetTemplate._({
    this.id,
    required this.budgetId,
    required this.name,
    required this.allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BudgetTemplate({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String name,
    required String allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetTemplateImpl;

  factory BudgetTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetTemplate(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      name: jsonSerialization['name'] as String,
      allocationData: jsonSerialization['allocationData'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = BudgetTemplateTable();

  static const db = BudgetTemplateRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  /// User-chosen name for the template (e.g. "Standard Month").
  String name;

  /// JSON-encoded map of envelope ID → allocated cents.
  String allocationData;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BudgetTemplate copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    String? name,
    String? allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetTemplate',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'name': name,
      'allocationData': allocationData,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetTemplate',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'name': name,
      'allocationData': allocationData,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static BudgetTemplateInclude include() {
    return BudgetTemplateInclude._();
  }

  static BudgetTemplateIncludeList includeList({
    _i1.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    BudgetTemplateInclude? include,
  }) {
    return BudgetTemplateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(BudgetTemplate.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BudgetTemplateImpl extends BudgetTemplate {
  _BudgetTemplateImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String name,
    required String allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         name: name,
         allocationData: allocationData,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BudgetTemplate copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    String? name,
    String? allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetTemplate(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      allocationData: allocationData ?? this.allocationData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BudgetTemplateUpdateTable extends _i1.UpdateTable<BudgetTemplateTable> {
  BudgetTemplateUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.budgetId, value);

  _i1.ColumnValue<String, String> name(String value) =>
      _i1.ColumnValue(table.name, value);

  _i1.ColumnValue<String, String> allocationData(String value) =>
      _i1.ColumnValue(table.allocationData, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class BudgetTemplateTable extends _i1.Table<_i1.UuidValue?> {
  BudgetTemplateTable({super.tableRelation})
    : super(tableName: 'budget_template') {
    updateTable = BudgetTemplateUpdateTable(this);
    budgetId = _i1.ColumnUuid('budgetId', this);
    name = _i1.ColumnString('name', this);
    allocationData = _i1.ColumnString('allocationData', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
    updatedAt = _i1.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final BudgetTemplateUpdateTable updateTable;

  late final _i1.ColumnUuid budgetId;

  /// User-chosen name for the template (e.g. "Standard Month").
  late final _i1.ColumnString name;

  /// JSON-encoded map of envelope ID → allocated cents.
  late final _i1.ColumnString allocationData;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    budgetId,
    name,
    allocationData,
    createdAt,
    updatedAt,
  ];
}

class BudgetTemplateInclude extends _i1.IncludeObject {
  BudgetTemplateInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => BudgetTemplate.t;
}

class BudgetTemplateIncludeList extends _i1.IncludeList {
  BudgetTemplateIncludeList._({
    _i1.WhereExpressionBuilder<BudgetTemplateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BudgetTemplate.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => BudgetTemplate.t;
}

class BudgetTemplateRepository {
  const BudgetTemplateRepository._();

  /// Returns a list of [BudgetTemplate]s matching the given query parameters.
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
  Future<List<BudgetTemplate>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [BudgetTemplate] matching the given query parameters.
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
  Future<BudgetTemplate?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? offset,
    _i1.OrderByBuilder<BudgetTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BudgetTemplate] by its [id] or null if no such row exists.
  Future<BudgetTemplate?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BudgetTemplate>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BudgetTemplate]s in the list and returns the inserted rows.
  ///
  /// The returned [BudgetTemplate]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<BudgetTemplate>> insert(
    _i1.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<BudgetTemplate>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [BudgetTemplate] and returns the inserted row.
  ///
  /// The returned [BudgetTemplate] will have its `id` field set.
  Future<BudgetTemplate> insertRow(
    _i1.DatabaseSession session,
    BudgetTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<BudgetTemplate>(row, transaction: transaction);
  }

  /// Updates all [BudgetTemplate]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<BudgetTemplate>> update(
    _i1.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _i1.ColumnSelections<BudgetTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<BudgetTemplate>(
      rows,
      columns: columns?.call(BudgetTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BudgetTemplate]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BudgetTemplate> updateRow(
    _i1.DatabaseSession session,
    BudgetTemplate row, {
    _i1.ColumnSelections<BudgetTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<BudgetTemplate>(
      row,
      columns: columns?.call(BudgetTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BudgetTemplate] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BudgetTemplate?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<BudgetTemplateUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<BudgetTemplate>(
      id,
      columnValues: columnValues(BudgetTemplate.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BudgetTemplate]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<BudgetTemplate>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<BudgetTemplateUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<BudgetTemplateTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTemplateTable>? orderBy,
    _i1.OrderByListBuilder<BudgetTemplateTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<BudgetTemplate>(
      columnValues: columnValues(BudgetTemplate.t.updateTable),
      where: where(BudgetTemplate.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplate.t),
      orderByList: orderByList?.call(BudgetTemplate.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [BudgetTemplate]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<BudgetTemplate>> delete(
    _i1.DatabaseSession session,
    List<BudgetTemplate> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<BudgetTemplate>(rows, transaction: transaction);
  }

  /// Deletes a single [BudgetTemplate].
  Future<BudgetTemplate> deleteRow(
    _i1.DatabaseSession session,
    BudgetTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BudgetTemplate>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<BudgetTemplate>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BudgetTemplateTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<BudgetTemplate>(
      where: where(BudgetTemplate.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTemplateTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<BudgetTemplate>(
      where: where?.call(BudgetTemplate.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BudgetTemplate] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BudgetTemplateTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BudgetTemplate>(
      where: where(BudgetTemplate.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
