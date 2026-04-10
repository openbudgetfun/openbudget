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

/// A savings goal or target for an envelope.
abstract class EnvelopeGoal
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  EnvelopeGoal._({
    this.id,
    required this.envelopeId,
    required this.goalType,
    required this.targetAmountCents,
    this.targetDate,
    this.monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvelopeGoal({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required String goalType,
    required int targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EnvelopeGoalImpl;

  factory EnvelopeGoal.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvelopeGoal(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      envelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      goalType: jsonSerialization['goalType'] as String,
      targetAmountCents: jsonSerialization['targetAmountCents'] as int,
      targetDate: jsonSerialization['targetDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['targetDate']),
      monthlyFundingCents: jsonSerialization['monthlyFundingCents'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = EnvelopeGoalTable();

  static const db = EnvelopeGoalRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue envelopeId;

  /// Goal type: 'target_balance', 'monthly_funding', or 'target_by_date'.
  String goalType;

  /// Target amount in integer cents.
  int targetAmountCents;

  /// Target date for 'target_by_date' goals (nullable for other types).
  DateTime? targetDate;

  /// Monthly funding amount in cents for 'monthly_funding' goals.
  int? monthlyFundingCents;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EnvelopeGoal copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? envelopeId,
    String? goalType,
    int? targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'goalType': goalType,
      'targetAmountCents': targetAmountCents,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      if (monthlyFundingCents != null)
        'monthlyFundingCents': monthlyFundingCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'goalType': goalType,
      'targetAmountCents': targetAmountCents,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      if (monthlyFundingCents != null)
        'monthlyFundingCents': monthlyFundingCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static EnvelopeGoalInclude include() {
    return EnvelopeGoalInclude._();
  }

  static EnvelopeGoalIncludeList includeList({
    _i1.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    EnvelopeGoalInclude? include,
  }) {
    return EnvelopeGoalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EnvelopeGoal.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvelopeGoalImpl extends EnvelopeGoal {
  _EnvelopeGoalImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required String goalType,
    required int targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         envelopeId: envelopeId,
         goalType: goalType,
         targetAmountCents: targetAmountCents,
         targetDate: targetDate,
         monthlyFundingCents: monthlyFundingCents,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EnvelopeGoal copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? envelopeId,
    String? goalType,
    int? targetAmountCents,
    Object? targetDate = _Undefined,
    Object? monthlyFundingCents = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvelopeGoal(
      id: id is _i1.UuidValue? ? id : this.id,
      envelopeId: envelopeId ?? this.envelopeId,
      goalType: goalType ?? this.goalType,
      targetAmountCents: targetAmountCents ?? this.targetAmountCents,
      targetDate: targetDate is DateTime? ? targetDate : this.targetDate,
      monthlyFundingCents: monthlyFundingCents is int?
          ? monthlyFundingCents
          : this.monthlyFundingCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EnvelopeGoalUpdateTable extends _i1.UpdateTable<EnvelopeGoalTable> {
  EnvelopeGoalUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> envelopeId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.envelopeId,
    value,
  );

  _i1.ColumnValue<String, String> goalType(String value) => _i1.ColumnValue(
    table.goalType,
    value,
  );

  _i1.ColumnValue<int, int> targetAmountCents(int value) => _i1.ColumnValue(
    table.targetAmountCents,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> targetDate(DateTime? value) =>
      _i1.ColumnValue(
        table.targetDate,
        value,
      );

  _i1.ColumnValue<int, int> monthlyFundingCents(int? value) => _i1.ColumnValue(
    table.monthlyFundingCents,
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

class EnvelopeGoalTable extends _i1.Table<_i1.UuidValue?> {
  EnvelopeGoalTable({super.tableRelation}) : super(tableName: 'envelope_goal') {
    updateTable = EnvelopeGoalUpdateTable(this);
    envelopeId = _i1.ColumnUuid(
      'envelopeId',
      this,
    );
    goalType = _i1.ColumnString(
      'goalType',
      this,
    );
    targetAmountCents = _i1.ColumnInt(
      'targetAmountCents',
      this,
    );
    targetDate = _i1.ColumnDateTime(
      'targetDate',
      this,
    );
    monthlyFundingCents = _i1.ColumnInt(
      'monthlyFundingCents',
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

  late final EnvelopeGoalUpdateTable updateTable;

  late final _i1.ColumnUuid envelopeId;

  /// Goal type: 'target_balance', 'monthly_funding', or 'target_by_date'.
  late final _i1.ColumnString goalType;

  /// Target amount in integer cents.
  late final _i1.ColumnInt targetAmountCents;

  /// Target date for 'target_by_date' goals (nullable for other types).
  late final _i1.ColumnDateTime targetDate;

  /// Monthly funding amount in cents for 'monthly_funding' goals.
  late final _i1.ColumnInt monthlyFundingCents;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    envelopeId,
    goalType,
    targetAmountCents,
    targetDate,
    monthlyFundingCents,
    createdAt,
    updatedAt,
  ];
}

class EnvelopeGoalInclude extends _i1.IncludeObject {
  EnvelopeGoalInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => EnvelopeGoal.t;
}

class EnvelopeGoalIncludeList extends _i1.IncludeList {
  EnvelopeGoalIncludeList._({
    _i1.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EnvelopeGoal.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => EnvelopeGoal.t;
}

class EnvelopeGoalRepository {
  const EnvelopeGoalRepository._();

  /// Returns a list of [EnvelopeGoal]s matching the given query parameters.
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
  Future<List<EnvelopeGoal>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EnvelopeGoal] matching the given query parameters.
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
  Future<EnvelopeGoal?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? offset,
    _i1.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EnvelopeGoal] by its [id] or null if no such row exists.
  Future<EnvelopeGoal?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EnvelopeGoal>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EnvelopeGoal]s in the list and returns the inserted rows.
  ///
  /// The returned [EnvelopeGoal]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EnvelopeGoal>> insert(
    _i1.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EnvelopeGoal>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EnvelopeGoal] and returns the inserted row.
  ///
  /// The returned [EnvelopeGoal] will have its `id` field set.
  Future<EnvelopeGoal> insertRow(
    _i1.DatabaseSession session,
    EnvelopeGoal row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EnvelopeGoal>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EnvelopeGoal]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EnvelopeGoal>> update(
    _i1.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _i1.ColumnSelections<EnvelopeGoalTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EnvelopeGoal>(
      rows,
      columns: columns?.call(EnvelopeGoal.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EnvelopeGoal]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EnvelopeGoal> updateRow(
    _i1.DatabaseSession session,
    EnvelopeGoal row, {
    _i1.ColumnSelections<EnvelopeGoalTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EnvelopeGoal>(
      row,
      columns: columns?.call(EnvelopeGoal.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EnvelopeGoal] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EnvelopeGoal?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<EnvelopeGoalUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EnvelopeGoal>(
      id,
      columnValues: columnValues(EnvelopeGoal.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EnvelopeGoal]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EnvelopeGoal>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EnvelopeGoalUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EnvelopeGoalTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _i1.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EnvelopeGoal>(
      columnValues: columnValues(EnvelopeGoal.t.updateTable),
      where: where(EnvelopeGoal.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EnvelopeGoal]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EnvelopeGoal>> delete(
    _i1.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EnvelopeGoal>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EnvelopeGoal].
  Future<EnvelopeGoal> deleteRow(
    _i1.DatabaseSession session,
    EnvelopeGoal row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EnvelopeGoal>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EnvelopeGoal>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EnvelopeGoalTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EnvelopeGoal>(
      where: where(EnvelopeGoal.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EnvelopeGoal] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EnvelopeGoalTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EnvelopeGoal>(
      where: where(EnvelopeGoal.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
