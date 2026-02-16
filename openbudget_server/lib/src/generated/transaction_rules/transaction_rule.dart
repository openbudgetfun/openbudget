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

/// A rule that auto-assigns an envelope when a specific payee is used.
abstract class TransactionRule
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  TransactionRule._({
    this.id,
    required this.budgetId,
    required this.payeeId,
    required this.targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : enabled = enabled ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory TransactionRule({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required _i1.UuidValue payeeId,
    required _i1.UuidValue targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) = _TransactionRuleImpl;

  factory TransactionRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionRule(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      payeeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['payeeId'],
      ),
      targetEnvelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['targetEnvelopeId'],
      ),
      enabled: jsonSerialization['enabled'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TransactionRuleTable();

  static const db = TransactionRuleRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  /// The payee this rule matches against.
  _i1.UuidValue payeeId;

  /// The envelope to auto-assign when this rule matches.
  _i1.UuidValue targetEnvelopeId;

  /// Whether this rule is active.
  bool enabled;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionRule copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? payeeId,
    _i1.UuidValue? targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionRule',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'payeeId': payeeId.toJson(),
      'targetEnvelopeId': targetEnvelopeId.toJson(),
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionRule',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'payeeId': payeeId.toJson(),
      'targetEnvelopeId': targetEnvelopeId.toJson(),
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  static TransactionRuleInclude include() {
    return TransactionRuleInclude._();
  }

  static TransactionRuleIncludeList includeList({
    _i1.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionRuleTable>? orderByList,
    TransactionRuleInclude? include,
  }) {
    return TransactionRuleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionRule.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TransactionRule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionRuleImpl extends TransactionRule {
  _TransactionRuleImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required _i1.UuidValue payeeId,
    required _i1.UuidValue targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         payeeId: payeeId,
         targetEnvelopeId: targetEnvelopeId,
         enabled: enabled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionRule copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    _i1.UuidValue? payeeId,
    _i1.UuidValue? targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return TransactionRule(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      payeeId: payeeId ?? this.payeeId,
      targetEnvelopeId: targetEnvelopeId ?? this.targetEnvelopeId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransactionRuleUpdateTable extends _i1.UpdateTable<TransactionRuleTable> {
  TransactionRuleUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.budgetId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> payeeId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.payeeId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> targetEnvelopeId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(table.targetEnvelopeId, value);

  _i1.ColumnValue<bool, bool> enabled(bool value) =>
      _i1.ColumnValue(table.enabled, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);
}

class TransactionRuleTable extends _i1.Table<_i1.UuidValue?> {
  TransactionRuleTable({super.tableRelation})
    : super(tableName: 'transaction_rule') {
    updateTable = TransactionRuleUpdateTable(this);
    budgetId = _i1.ColumnUuid('budgetId', this);
    payeeId = _i1.ColumnUuid('payeeId', this);
    targetEnvelopeId = _i1.ColumnUuid('targetEnvelopeId', this);
    enabled = _i1.ColumnBool('enabled', this, hasDefault: true);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
  }

  late final TransactionRuleUpdateTable updateTable;

  late final _i1.ColumnUuid budgetId;

  /// The payee this rule matches against.
  late final _i1.ColumnUuid payeeId;

  /// The envelope to auto-assign when this rule matches.
  late final _i1.ColumnUuid targetEnvelopeId;

  /// Whether this rule is active.
  late final _i1.ColumnBool enabled;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    budgetId,
    payeeId,
    targetEnvelopeId,
    enabled,
    createdAt,
  ];
}

class TransactionRuleInclude extends _i1.IncludeObject {
  TransactionRuleInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => TransactionRule.t;
}

class TransactionRuleIncludeList extends _i1.IncludeList {
  TransactionRuleIncludeList._({
    _i1.WhereExpressionBuilder<TransactionRuleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionRule.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => TransactionRule.t;
}

class TransactionRuleRepository {
  const TransactionRuleRepository._();

  /// Returns a list of [TransactionRule]s matching the given query parameters.
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
  Future<List<TransactionRule>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TransactionRule>(
      where: where?.call(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TransactionRule] matching the given query parameters.
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
  Future<TransactionRule?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? offset,
    _i1.OrderByBuilder<TransactionRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TransactionRule>(
      where: where?.call(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TransactionRule] by its [id] or null if no such row exists.
  Future<TransactionRule?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TransactionRule>(id, transaction: transaction);
  }

  /// Inserts all [TransactionRule]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionRule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TransactionRule>> insert(
    _i1.Session session,
    List<TransactionRule> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TransactionRule>(rows, transaction: transaction);
  }

  /// Inserts a single [TransactionRule] and returns the inserted row.
  ///
  /// The returned [TransactionRule] will have its `id` field set.
  Future<TransactionRule> insertRow(
    _i1.Session session,
    TransactionRule row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionRule>(row, transaction: transaction);
  }

  /// Updates all [TransactionRule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TransactionRule>> update(
    _i1.Session session,
    List<TransactionRule> rows, {
    _i1.ColumnSelections<TransactionRuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TransactionRule>(
      rows,
      columns: columns?.call(TransactionRule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionRule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionRule> updateRow(
    _i1.Session session,
    TransactionRule row, {
    _i1.ColumnSelections<TransactionRuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TransactionRule>(
      row,
      columns: columns?.call(TransactionRule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionRule] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TransactionRule?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<TransactionRuleUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionRule>(
      id,
      columnValues: columnValues(TransactionRule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionRule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TransactionRule>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TransactionRuleUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<TransactionRuleTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionRuleTable>? orderBy,
    _i1.OrderByListBuilder<TransactionRuleTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TransactionRule>(
      columnValues: columnValues(TransactionRule.t.updateTable),
      where: where(TransactionRule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TransactionRule]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TransactionRule>> delete(
    _i1.Session session,
    List<TransactionRule> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TransactionRule>(rows, transaction: transaction);
  }

  /// Deletes a single [TransactionRule].
  Future<TransactionRule> deleteRow(
    _i1.Session session,
    TransactionRule row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionRule>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TransactionRule>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TransactionRuleTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TransactionRule>(
      where: where(TransactionRule.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TransactionRule>(
      where: where?.call(TransactionRule.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
