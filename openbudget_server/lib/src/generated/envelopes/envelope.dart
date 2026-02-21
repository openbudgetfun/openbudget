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

/// An envelope within a category, tracking budgeted and spent amounts.
abstract class Envelope
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Envelope._({
    this.id,
    required this.name,
    required this.categoryId,
    required this.budgetedAmountCents,
    required this.spentAmountCents,
    required this.currencyCode,
    required this.sortOrder,
    this.note,
    bool? isHidden,
    DateTime? createdAt,
  }) : isHidden = isHidden ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Envelope({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue categoryId,
    required int budgetedAmountCents,
    required int spentAmountCents,
    required String currencyCode,
    required int sortOrder,
    String? note,
    bool? isHidden,
    DateTime? createdAt,
  }) = _EnvelopeImpl;

  factory Envelope.fromJson(Map<String, dynamic> jsonSerialization) {
    return Envelope(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      categoryId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['categoryId'],
      ),
      budgetedAmountCents: jsonSerialization['budgetedAmountCents'] as int,
      spentAmountCents: jsonSerialization['spentAmountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
      note: jsonSerialization['note'] as String?,
      isHidden: jsonSerialization['isHidden'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = EnvelopeTable();

  static const db = EnvelopeRepository._();

  @override
  _i1.UuidValue? id;

  String name;

  _i1.UuidValue categoryId;

  /// Budgeted amount stored as integer cents to avoid floating-point issues.
  int budgetedAmountCents;

  /// Spent amount stored as integer cents.
  int spentAmountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  /// Display order within the parent category.
  int sortOrder;

  /// Optional user-facing note providing context for the envelope.
  String? note;

  /// Whether this envelope is hidden from the default budget view.
  bool? isHidden;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Envelope copyWith({
    _i1.UuidValue? id,
    String? name,
    _i1.UuidValue? categoryId,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? currencyCode,
    int? sortOrder,
    String? note,
    bool? isHidden,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Envelope',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'categoryId': categoryId.toJson(),
      'budgetedAmountCents': budgetedAmountCents,
      'spentAmountCents': spentAmountCents,
      'currencyCode': currencyCode,
      'sortOrder': sortOrder,
      if (note != null) 'note': note,
      if (isHidden != null) 'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Envelope',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'categoryId': categoryId.toJson(),
      'budgetedAmountCents': budgetedAmountCents,
      'spentAmountCents': spentAmountCents,
      'currencyCode': currencyCode,
      'sortOrder': sortOrder,
      if (note != null) 'note': note,
      if (isHidden != null) 'isHidden': isHidden,
      'createdAt': createdAt.toJson(),
    };
  }

  static EnvelopeInclude include() {
    return EnvelopeInclude._();
  }

  static EnvelopeIncludeList includeList({
    _i1.WhereExpressionBuilder<EnvelopeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeTable>? orderByList,
    EnvelopeInclude? include,
  }) {
    return EnvelopeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Envelope.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Envelope.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvelopeImpl extends Envelope {
  _EnvelopeImpl({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue categoryId,
    required int budgetedAmountCents,
    required int spentAmountCents,
    required String currencyCode,
    required int sortOrder,
    String? note,
    bool? isHidden,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         categoryId: categoryId,
         budgetedAmountCents: budgetedAmountCents,
         spentAmountCents: spentAmountCents,
         currencyCode: currencyCode,
         sortOrder: sortOrder,
         note: note,
         isHidden: isHidden,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Envelope copyWith({
    Object? id = _Undefined,
    String? name,
    _i1.UuidValue? categoryId,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? currencyCode,
    int? sortOrder,
    Object? note = _Undefined,
    Object? isHidden = _Undefined,
    DateTime? createdAt,
  }) {
    return Envelope(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      budgetedAmountCents: budgetedAmountCents ?? this.budgetedAmountCents,
      spentAmountCents: spentAmountCents ?? this.spentAmountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      sortOrder: sortOrder ?? this.sortOrder,
      note: note is String? ? note : this.note,
      isHidden: isHidden is bool? ? isHidden : this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EnvelopeUpdateTable extends _i1.UpdateTable<EnvelopeTable> {
  EnvelopeUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> categoryId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.categoryId,
    value,
  );

  _i1.ColumnValue<int, int> budgetedAmountCents(int value) => _i1.ColumnValue(
    table.budgetedAmountCents,
    value,
  );

  _i1.ColumnValue<int, int> spentAmountCents(int value) => _i1.ColumnValue(
    table.spentAmountCents,
    value,
  );

  _i1.ColumnValue<String, String> currencyCode(String value) => _i1.ColumnValue(
    table.currencyCode,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<String, String> note(String? value) => _i1.ColumnValue(
    table.note,
    value,
  );

  _i1.ColumnValue<bool, bool> isHidden(bool? value) => _i1.ColumnValue(
    table.isHidden,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class EnvelopeTable extends _i1.Table<_i1.UuidValue?> {
  EnvelopeTable({super.tableRelation}) : super(tableName: 'envelope') {
    updateTable = EnvelopeUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    categoryId = _i1.ColumnUuid(
      'categoryId',
      this,
    );
    budgetedAmountCents = _i1.ColumnInt(
      'budgetedAmountCents',
      this,
    );
    spentAmountCents = _i1.ColumnInt(
      'spentAmountCents',
      this,
    );
    currencyCode = _i1.ColumnString(
      'currencyCode',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    note = _i1.ColumnString(
      'note',
      this,
    );
    isHidden = _i1.ColumnBool(
      'isHidden',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final EnvelopeUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnUuid categoryId;

  /// Budgeted amount stored as integer cents to avoid floating-point issues.
  late final _i1.ColumnInt budgetedAmountCents;

  /// Spent amount stored as integer cents.
  late final _i1.ColumnInt spentAmountCents;

  /// ISO 4217 currency code.
  late final _i1.ColumnString currencyCode;

  /// Display order within the parent category.
  late final _i1.ColumnInt sortOrder;

  /// Optional user-facing note providing context for the envelope.
  late final _i1.ColumnString note;

  /// Whether this envelope is hidden from the default budget view.
  late final _i1.ColumnBool isHidden;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    categoryId,
    budgetedAmountCents,
    spentAmountCents,
    currencyCode,
    sortOrder,
    note,
    isHidden,
    createdAt,
  ];
}

class EnvelopeInclude extends _i1.IncludeObject {
  EnvelopeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Envelope.t;
}

class EnvelopeIncludeList extends _i1.IncludeList {
  EnvelopeIncludeList._({
    _i1.WhereExpressionBuilder<EnvelopeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Envelope.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Envelope.t;
}

class EnvelopeRepository {
  const EnvelopeRepository._();

  /// Returns a list of [Envelope]s matching the given query parameters.
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
  Future<List<Envelope>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EnvelopeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Envelope>(
      where: where?.call(Envelope.t),
      orderBy: orderBy?.call(Envelope.t),
      orderByList: orderByList?.call(Envelope.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Envelope] matching the given query parameters.
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
  Future<Envelope?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EnvelopeTable>? where,
    int? offset,
    _i1.OrderByBuilder<EnvelopeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Envelope>(
      where: where?.call(Envelope.t),
      orderBy: orderBy?.call(Envelope.t),
      orderByList: orderByList?.call(Envelope.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Envelope] by its [id] or null if no such row exists.
  Future<Envelope?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Envelope>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Envelope]s in the list and returns the inserted rows.
  ///
  /// The returned [Envelope]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Envelope>> insert(
    _i1.Session session,
    List<Envelope> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Envelope>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Envelope] and returns the inserted row.
  ///
  /// The returned [Envelope] will have its `id` field set.
  Future<Envelope> insertRow(
    _i1.Session session,
    Envelope row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Envelope>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Envelope]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Envelope>> update(
    _i1.Session session,
    List<Envelope> rows, {
    _i1.ColumnSelections<EnvelopeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Envelope>(
      rows,
      columns: columns?.call(Envelope.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Envelope]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Envelope> updateRow(
    _i1.Session session,
    Envelope row, {
    _i1.ColumnSelections<EnvelopeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Envelope>(
      row,
      columns: columns?.call(Envelope.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Envelope] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Envelope?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<EnvelopeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Envelope>(
      id,
      columnValues: columnValues(Envelope.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Envelope]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Envelope>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<EnvelopeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EnvelopeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeTable>? orderBy,
    _i1.OrderByListBuilder<EnvelopeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Envelope>(
      columnValues: columnValues(Envelope.t.updateTable),
      where: where(Envelope.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Envelope.t),
      orderByList: orderByList?.call(Envelope.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Envelope]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Envelope>> delete(
    _i1.Session session,
    List<Envelope> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Envelope>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Envelope].
  Future<Envelope> deleteRow(
    _i1.Session session,
    Envelope row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Envelope>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Envelope>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<EnvelopeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Envelope>(
      where: where(Envelope.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<EnvelopeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Envelope>(
      where: where?.call(Envelope.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
