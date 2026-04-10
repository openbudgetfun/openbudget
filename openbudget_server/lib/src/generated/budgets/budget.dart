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

/// A budget owned by a user, representing a financial plan in a specific currency.
abstract class Budget
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
    _i1.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _i1.UuidValue ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetImpl;

  factory Budget.fromJson(Map<String, dynamic> jsonSerialization) {
    return Budget(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String,
      displayCurrencyCode: jsonSerialization['displayCurrencyCode'] as String?,
      ownerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = BudgetTable();

  static const db = BudgetRepository._();

  @override
  _i1.UuidValue? id;

  String name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  String currencyCode;

  /// Optional display currency override for aggregated/reporting views.
  /// If null, the budget's native currencyCode is used for display.
  String? displayCurrencyCode;

  /// The user who owns this budget.
  _i1.UuidValue ownerId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Budget copyWith({
    _i1.UuidValue? id,
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    _i1.UuidValue? ownerId,
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
    _i1.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTable>? orderByList,
    BudgetInclude? include,
  }) {
    return BudgetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Budget.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Budget.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BudgetImpl extends Budget {
  _BudgetImpl({
    _i1.UuidValue? id,
    required String name,
    required String currencyCode,
    String? displayCurrencyCode,
    required _i1.UuidValue ownerId,
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
  @_i1.useResult
  @override
  Budget copyWith({
    Object? id = _Undefined,
    String? name,
    String? currencyCode,
    Object? displayCurrencyCode = _Undefined,
    _i1.UuidValue? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id is _i1.UuidValue? ? id : this.id,
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

class BudgetUpdateTable extends _i1.UpdateTable<BudgetTable> {
  BudgetUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) =>
      _i1.ColumnValue(table.name, value);

  _i1.ColumnValue<String, String> currencyCode(String value) =>
      _i1.ColumnValue(table.currencyCode, value);

  _i1.ColumnValue<String, String> displayCurrencyCode(String? value) =>
      _i1.ColumnValue(table.displayCurrencyCode, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> ownerId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.ownerId, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class BudgetTable extends _i1.Table<_i1.UuidValue?> {
  BudgetTable({super.tableRelation}) : super(tableName: 'budget') {
    updateTable = BudgetUpdateTable(this);
    name = _i1.ColumnString('name', this);
    currencyCode = _i1.ColumnString('currencyCode', this);
    displayCurrencyCode = _i1.ColumnString('displayCurrencyCode', this);
    ownerId = _i1.ColumnUuid('ownerId', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
    updatedAt = _i1.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final BudgetUpdateTable updateTable;

  late final _i1.ColumnString name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  late final _i1.ColumnString currencyCode;

  /// Optional display currency override for aggregated/reporting views.
  /// If null, the budget's native currencyCode is used for display.
  late final _i1.ColumnString displayCurrencyCode;

  /// The user who owns this budget.
  late final _i1.ColumnUuid ownerId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    currencyCode,
    displayCurrencyCode,
    ownerId,
    createdAt,
    updatedAt,
  ];
}

class BudgetInclude extends _i1.IncludeObject {
  BudgetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Budget.t;
}

class BudgetIncludeList extends _i1.IncludeList {
  BudgetIncludeList._({
    _i1.WhereExpressionBuilder<BudgetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Budget.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Budget.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Budget>(
      where: where?.call(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTable>? where,
    int? offset,
    _i1.OrderByBuilder<BudgetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<BudgetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Budget>(
      where: where?.call(Budget.t),
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Budget] by its [id] or null if no such row exists.
  Future<Budget?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<Budget>> insert(
    _i1.DatabaseSession session,
    List<Budget> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Budget>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Budget] and returns the inserted row.
  ///
  /// The returned [Budget] will have its `id` field set.
  Future<Budget> insertRow(
    _i1.DatabaseSession session,
    Budget row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Budget>(row, transaction: transaction);
  }

  /// Updates all [Budget]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Budget>> update(
    _i1.DatabaseSession session,
    List<Budget> rows, {
    _i1.ColumnSelections<BudgetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Budget>(
      rows,
      columns: columns?.call(Budget.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Budget]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Budget> updateRow(
    _i1.DatabaseSession session,
    Budget row, {
    _i1.ColumnSelections<BudgetTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<BudgetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Budget>(
      id,
      columnValues: columnValues(Budget.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Budget]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Budget>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<BudgetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<BudgetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<BudgetTable>? orderBy,
    _i1.OrderByListBuilder<BudgetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Budget>(
      columnValues: columnValues(Budget.t.updateTable),
      where: where(Budget.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Budget.t),
      orderByList: orderByList?.call(Budget.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Budget]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Budget>> delete(
    _i1.DatabaseSession session,
    List<Budget> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Budget>(rows, transaction: transaction);
  }

  /// Deletes a single [Budget].
  Future<Budget> deleteRow(
    _i1.DatabaseSession session,
    Budget row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Budget>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Budget>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BudgetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Budget>(
      where: where(Budget.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<BudgetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Budget>(
      where: where?.call(Budget.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Budget] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<BudgetTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Budget>(
      where: where(Budget.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
