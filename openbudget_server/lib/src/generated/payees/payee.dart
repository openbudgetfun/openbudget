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

/// A payee (merchant or person) associated with transactions in a budget.
abstract class Payee
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Payee._({
    this.id,
    required this.name,
    required this.budgetId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payee({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    DateTime? createdAt,
  }) = _PayeeImpl;

  factory Payee.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payee(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = PayeeTable();

  static const db = PayeeRepository._();

  @override
  _i1.UuidValue? id;

  String name;

  _i1.UuidValue budgetId;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Payee copyWith({
    _i1.UuidValue? id,
    String? name,
    _i1.UuidValue? budgetId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Payee',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Payee',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static PayeeInclude include() {
    return PayeeInclude._();
  }

  static PayeeIncludeList includeList({
    _i1.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PayeeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PayeeTable>? orderByList,
    PayeeInclude? include,
  }) {
    return PayeeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payee.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Payee.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PayeeImpl extends Payee {
  _PayeeImpl({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         budgetId: budgetId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Payee copyWith({
    Object? id = _Undefined,
    String? name,
    _i1.UuidValue? budgetId,
    DateTime? createdAt,
  }) {
    return Payee(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      budgetId: budgetId ?? this.budgetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PayeeUpdateTable extends _i1.UpdateTable<PayeeTable> {
  PayeeUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PayeeTable extends _i1.Table<_i1.UuidValue?> {
  PayeeTable({super.tableRelation}) : super(tableName: 'payee') {
    updateTable = PayeeUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final PayeeUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnUuid budgetId;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    budgetId,
    createdAt,
  ];
}

class PayeeInclude extends _i1.IncludeObject {
  PayeeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Payee.t;
}

class PayeeIncludeList extends _i1.IncludeList {
  PayeeIncludeList._({
    _i1.WhereExpressionBuilder<PayeeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Payee.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Payee.t;
}

class PayeeRepository {
  const PayeeRepository._();

  /// Returns a list of [Payee]s matching the given query parameters.
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
  Future<List<Payee>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PayeeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PayeeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Payee>(
      where: where?.call(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Payee] matching the given query parameters.
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
  Future<Payee?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PayeeTable>? where,
    int? offset,
    _i1.OrderByBuilder<PayeeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PayeeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Payee>(
      where: where?.call(Payee.t),
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Payee] by its [id] or null if no such row exists.
  Future<Payee?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Payee>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Payee]s in the list and returns the inserted rows.
  ///
  /// The returned [Payee]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Payee>> insert(
    _i1.Session session,
    List<Payee> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Payee>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Payee] and returns the inserted row.
  ///
  /// The returned [Payee] will have its `id` field set.
  Future<Payee> insertRow(
    _i1.Session session,
    Payee row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Payee>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Payee]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Payee>> update(
    _i1.Session session,
    List<Payee> rows, {
    _i1.ColumnSelections<PayeeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Payee>(
      rows,
      columns: columns?.call(Payee.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Payee]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Payee> updateRow(
    _i1.Session session,
    Payee row, {
    _i1.ColumnSelections<PayeeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Payee>(
      row,
      columns: columns?.call(Payee.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Payee] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Payee?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PayeeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Payee>(
      id,
      columnValues: columnValues(Payee.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Payee]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Payee>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PayeeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PayeeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PayeeTable>? orderBy,
    _i1.OrderByListBuilder<PayeeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Payee>(
      columnValues: columnValues(Payee.t.updateTable),
      where: where(Payee.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payee.t),
      orderByList: orderByList?.call(Payee.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Payee]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Payee>> delete(
    _i1.Session session,
    List<Payee> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Payee>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Payee].
  Future<Payee> deleteRow(
    _i1.Session session,
    Payee row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Payee>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Payee>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PayeeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Payee>(
      where: where(Payee.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PayeeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Payee>(
      where: where?.call(Payee.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
