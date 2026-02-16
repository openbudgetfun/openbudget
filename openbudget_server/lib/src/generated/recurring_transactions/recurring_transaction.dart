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

/// A recurring/scheduled transaction template that generates transactions on a schedule.
abstract class RecurringTransaction
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  RecurringTransaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    this.payeeId,
    required this.frequency,
    required this.nextOccurrence,
    this.endDate,
    required this.isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory RecurringTransaction({
    _i1.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _i1.UuidValue? envelopeId,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? accountId,
    _i1.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecurringTransactionImpl;

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RecurringTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['accountId']),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      frequency: jsonSerialization['frequency'] as String,
      nextOccurrence: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextOccurrence'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endDate']),
      isActive: jsonSerialization['isActive'] as bool,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = RecurringTransactionTable();

  static const db = RecurringTransactionRepository._();

  @override
  _i1.UuidValue? id;

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _i1.UuidValue? envelopeId;

  _i1.UuidValue budgetId;

  _i1.UuidValue? accountId;

  _i1.UuidValue? payeeId;

  /// Recurrence frequency: daily, weekly, biweekly, monthly, yearly.
  String frequency;

  /// The next date a transaction should be created.
  DateTime nextOccurrence;

  /// Optional end date after which no more transactions are generated.
  DateTime? endDate;

  /// Whether this recurring transaction is active.
  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RecurringTransaction copyWith({
    _i1.UuidValue? id,
    String? description,
    int? amountCents,
    String? currencyCode,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? accountId,
    _i1.UuidValue? payeeId,
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static RecurringTransactionInclude include() {
    return RecurringTransactionInclude._();
  }

  static RecurringTransactionIncludeList includeList({
    _i1.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RecurringTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    RecurringTransactionInclude? include,
  }) {
    return RecurringTransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RecurringTransaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RecurringTransactionImpl extends RecurringTransaction {
  _RecurringTransactionImpl({
    _i1.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _i1.UuidValue? envelopeId,
    required _i1.UuidValue budgetId,
    _i1.UuidValue? accountId,
    _i1.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         payeeId: payeeId,
         frequency: frequency,
         nextOccurrence: nextOccurrence,
         endDate: endDate,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RecurringTransaction copyWith({
    Object? id = _Undefined,
    String? description,
    int? amountCents,
    String? currencyCode,
    Object? envelopeId = _Undefined,
    _i1.UuidValue? budgetId,
    Object? accountId = _Undefined,
    Object? payeeId = _Undefined,
    String? frequency,
    DateTime? nextOccurrence,
    Object? endDate = _Undefined,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id is _i1.UuidValue? ? id : this.id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      envelopeId: envelopeId is _i1.UuidValue? ? envelopeId : this.envelopeId,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId is _i1.UuidValue? ? accountId : this.accountId,
      payeeId: payeeId is _i1.UuidValue? ? payeeId : this.payeeId,
      frequency: frequency ?? this.frequency,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      endDate: endDate is DateTime? ? endDate : this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecurringTransactionUpdateTable
    extends _i1.UpdateTable<RecurringTransactionTable> {
  RecurringTransactionUpdateTable(super.table);

  _i1.ColumnValue<String, String> description(String value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<int, int> amountCents(int value) => _i1.ColumnValue(
    table.amountCents,
    value,
  );

  _i1.ColumnValue<String, String> currencyCode(String value) => _i1.ColumnValue(
    table.currencyCode,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> envelopeId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.envelopeId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> payeeId(_i1.UuidValue? value) =>
      _i1.ColumnValue(
        table.payeeId,
        value,
      );

  _i1.ColumnValue<String, String> frequency(String value) => _i1.ColumnValue(
    table.frequency,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> nextOccurrence(DateTime value) =>
      _i1.ColumnValue(
        table.nextOccurrence,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> endDate(DateTime? value) =>
      _i1.ColumnValue(
        table.endDate,
        value,
      );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RecurringTransactionTable extends _i1.Table<_i1.UuidValue?> {
  RecurringTransactionTable({super.tableRelation})
    : super(tableName: 'recurring_transaction') {
    updateTable = RecurringTransactionUpdateTable(this);
    description = _i1.ColumnString(
      'description',
      this,
    );
    amountCents = _i1.ColumnInt(
      'amountCents',
      this,
    );
    currencyCode = _i1.ColumnString(
      'currencyCode',
      this,
    );
    envelopeId = _i1.ColumnUuid(
      'envelopeId',
      this,
    );
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    accountId = _i1.ColumnUuid(
      'accountId',
      this,
    );
    payeeId = _i1.ColumnUuid(
      'payeeId',
      this,
    );
    frequency = _i1.ColumnString(
      'frequency',
      this,
    );
    nextOccurrence = _i1.ColumnDateTime(
      'nextOccurrence',
      this,
    );
    endDate = _i1.ColumnDateTime(
      'endDate',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final RecurringTransactionUpdateTable updateTable;

  late final _i1.ColumnString description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  late final _i1.ColumnInt amountCents;

  /// ISO 4217 currency code.
  late final _i1.ColumnString currencyCode;

  late final _i1.ColumnUuid envelopeId;

  late final _i1.ColumnUuid budgetId;

  late final _i1.ColumnUuid accountId;

  late final _i1.ColumnUuid payeeId;

  /// Recurrence frequency: daily, weekly, biweekly, monthly, yearly.
  late final _i1.ColumnString frequency;

  /// The next date a transaction should be created.
  late final _i1.ColumnDateTime nextOccurrence;

  /// Optional end date after which no more transactions are generated.
  late final _i1.ColumnDateTime endDate;

  /// Whether this recurring transaction is active.
  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    description,
    amountCents,
    currencyCode,
    envelopeId,
    budgetId,
    accountId,
    payeeId,
    frequency,
    nextOccurrence,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class RecurringTransactionInclude extends _i1.IncludeObject {
  RecurringTransactionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => RecurringTransaction.t;
}

class RecurringTransactionIncludeList extends _i1.IncludeList {
  RecurringTransactionIncludeList._({
    _i1.WhereExpressionBuilder<RecurringTransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecurringTransaction.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => RecurringTransaction.t;
}

class RecurringTransactionRepository {
  const RecurringTransactionRepository._();

  /// Returns a list of [RecurringTransaction]s matching the given query parameters.
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
  Future<List<RecurringTransaction>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RecurringTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [RecurringTransaction] matching the given query parameters.
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
  Future<RecurringTransaction?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? offset,
    _i1.OrderByBuilder<RecurringTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [RecurringTransaction] by its [id] or null if no such row exists.
  Future<RecurringTransaction?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<RecurringTransaction>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [RecurringTransaction]s in the list and returns the inserted rows.
  ///
  /// The returned [RecurringTransaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<RecurringTransaction>> insert(
    _i1.Session session,
    List<RecurringTransaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<RecurringTransaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [RecurringTransaction] and returns the inserted row.
  ///
  /// The returned [RecurringTransaction] will have its `id` field set.
  Future<RecurringTransaction> insertRow(
    _i1.Session session,
    RecurringTransaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecurringTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RecurringTransaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RecurringTransaction>> update(
    _i1.Session session,
    List<RecurringTransaction> rows, {
    _i1.ColumnSelections<RecurringTransactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RecurringTransaction>(
      rows,
      columns: columns?.call(RecurringTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecurringTransaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecurringTransaction> updateRow(
    _i1.Session session,
    RecurringTransaction row, {
    _i1.ColumnSelections<RecurringTransactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecurringTransaction>(
      row,
      columns: columns?.call(RecurringTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecurringTransaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecurringTransaction?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<RecurringTransactionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RecurringTransaction>(
      id,
      columnValues: columnValues(RecurringTransaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecurringTransaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RecurringTransaction>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<RecurringTransactionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<RecurringTransactionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _i1.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RecurringTransaction>(
      columnValues: columnValues(RecurringTransaction.t.updateTable),
      where: where(RecurringTransaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RecurringTransaction]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RecurringTransaction>> delete(
    _i1.Session session,
    List<RecurringTransaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RecurringTransaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RecurringTransaction].
  Future<RecurringTransaction> deleteRow(
    _i1.Session session,
    RecurringTransaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecurringTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RecurringTransaction>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RecurringTransactionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RecurringTransaction>(
      where: where(RecurringTransaction.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
