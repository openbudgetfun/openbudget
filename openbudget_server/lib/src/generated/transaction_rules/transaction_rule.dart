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

/// A rule that auto-assigns an envelope when a specific payee is used.
abstract class TransactionRule
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required _is.UuidValue payeeId,
    required _is.UuidValue targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) = _TransactionRuleImpl;

  factory TransactionRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionRule(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      payeeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['payeeId'],
      ),
      targetEnvelopeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['targetEnvelopeId'],
      ),
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TransactionRuleTable();

  static const db = TransactionRuleRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue budgetId;

  /// The payee this rule matches against.
  _is.UuidValue payeeId;

  /// The envelope to auto-assign when this rule matches.
  _is.UuidValue targetEnvelopeId;

  /// Whether this rule is active.
  bool enabled;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TransactionRule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionRule copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? payeeId,
    _is.UuidValue? targetEnvelopeId,
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
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    TransactionRuleInclude? include,
  }) {
    return TransactionRuleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TransactionRuleImpl extends TransactionRule {
  _TransactionRuleImpl({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required _is.UuidValue payeeId,
    required _is.UuidValue targetEnvelopeId,
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
  @_is.useResult
  @override
  TransactionRule copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? payeeId,
    _is.UuidValue? targetEnvelopeId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return TransactionRule(
      id: id is _is.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      payeeId: payeeId ?? this.payeeId,
      targetEnvelopeId: targetEnvelopeId ?? this.targetEnvelopeId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransactionRuleUpdateTable extends _is.UpdateTable<TransactionRuleTable> {
  TransactionRuleUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> payeeId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.payeeId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> targetEnvelopeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.targetEnvelopeId,
    value,
  );

  _is.ColumnValue<bool, bool> enabled(bool value) => _is.ColumnValue(
    table.enabled,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TransactionRuleTable extends _is.Table<_is.UuidValue?> {
  TransactionRuleTable({super.tableRelation})
    : super(tableName: 'transaction_rule') {
    updateTable = TransactionRuleUpdateTable(this);
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    payeeId = _is.ColumnUuid(
      'payeeId',
      this,
    );
    targetEnvelopeId = _is.ColumnUuid(
      'targetEnvelopeId',
      this,
    );
    enabled = _is.ColumnBool(
      'enabled',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TransactionRuleUpdateTable updateTable;

  late final _is.ColumnUuid budgetId;

  /// The payee this rule matches against.
  late final _is.ColumnUuid payeeId;

  /// The envelope to auto-assign when this rule matches.
  late final _is.ColumnUuid targetEnvelopeId;

  /// Whether this rule is active.
  late final _is.ColumnBool enabled;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    budgetId,
    payeeId,
    targetEnvelopeId,
    enabled,
    createdAt,
  ];
}

class TransactionRuleInclude extends _is.IncludeObject {
  TransactionRuleInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => TransactionRule.t;
}

class TransactionRuleIncludeList extends _is.IncludeList {
  TransactionRuleIncludeList._({
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionRule.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TransactionRule.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TransactionRule>(
      where: where?.call(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [TransactionRule]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `TransactionRule.t`.
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
  _ida.Stream<List<TransactionRule>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<TransactionRule>(
      where: where?.call(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? offset,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TransactionRule>(
      where: where?.call(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TransactionRule] by its [id] or null if no such row exists.
  Future<TransactionRule?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TransactionRule>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TransactionRule]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionRule]s will have their `id` fields set.
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
  Future<List<TransactionRule>> insert(
    _is.DatabaseSession session,
    List<TransactionRule> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TransactionRule>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TransactionRule] and returns the inserted row.
  ///
  /// The returned [TransactionRule] will have its `id` field set.
  Future<TransactionRule> insertRow(
    _is.DatabaseSession session,
    TransactionRule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionRule>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TransactionRule]s in the list and returns the resulting rows.
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
  /// The returned [TransactionRule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionRule>> upsert(
    _is.DatabaseSession session,
    List<TransactionRule> rows, {
    required _is.ColumnSelections<TransactionRuleTable> conflictColumns,
    _is.ColumnSelections<TransactionRuleTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionRuleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TransactionRule>(
      rows,
      conflictColumns: conflictColumns(TransactionRule.t),
      updateColumns: updateColumns?.call(TransactionRule.t),
      updateWhere: updateWhere?.call(TransactionRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TransactionRule] and returns the resulting row.
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
  /// The returned [TransactionRule] will have its `id` field set.
  Future<TransactionRule?> upsertRow(
    _is.DatabaseSession session,
    TransactionRule row, {
    required _is.ColumnSelections<TransactionRuleTable> conflictColumns,
    _is.ColumnSelections<TransactionRuleTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionRuleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TransactionRule>(
      row,
      conflictColumns: conflictColumns(TransactionRule.t),
      updateColumns: updateColumns?.call(TransactionRule.t),
      updateWhere: updateWhere?.call(TransactionRule.t),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionRule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionRule>> update(
    _is.DatabaseSession session,
    List<TransactionRule> rows, {
    _is.ColumnSelections<TransactionRuleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TransactionRule>(
      rows,
      columns: columns?.call(TransactionRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TransactionRule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionRule> updateRow(
    _is.DatabaseSession session,
    TransactionRule row, {
    _is.ColumnSelections<TransactionRuleTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TransactionRuleUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionRule>(
      id,
      columnValues: columnValues(TransactionRule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionRule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionRule>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TransactionRuleUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<TransactionRuleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TransactionRule>(
      columnValues: columnValues(TransactionRule.t.updateTable),
      where: where(TransactionRule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TransactionRule]s in the list and returns the deleted rows.
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
  Future<List<TransactionRule>> delete(
    _is.DatabaseSession session,
    List<TransactionRule> rows, {
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TransactionRule>(
      rows,
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TransactionRule].
  Future<TransactionRule> deleteRow(
    _is.DatabaseSession session,
    TransactionRule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionRule>(
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
  Future<List<TransactionRule>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionRuleTable> where,
    _is.OrderByBuilder<TransactionRuleTable>? orderBy,
    _is.OrderByListBuilder<TransactionRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TransactionRule>(
      where: where(TransactionRule.t),
      orderBy: orderBy?.call(TransactionRule.t),
      orderByList: orderByList?.call(TransactionRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionRuleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TransactionRule>(
      where: where?.call(TransactionRule.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TransactionRule] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionRuleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TransactionRule>(
      where: where(TransactionRule.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
