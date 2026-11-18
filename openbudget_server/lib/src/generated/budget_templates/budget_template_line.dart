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

/// One envelope's amount in a budget template.
abstract class BudgetTemplateLine
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  BudgetTemplateLine._({
    this.id,
    required this.templateId,
    required this.envelopeId,
    required this.allocatedMinor,
  });

  factory BudgetTemplateLine({
    _is.UuidValue? id,
    required _is.UuidValue templateId,
    required _is.UuidValue envelopeId,
    required int allocatedMinor,
  }) = _BudgetTemplateLineImpl;

  factory BudgetTemplateLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetTemplateLine(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      templateId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['templateId'],
      ),
      envelopeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
    );
  }

  static final t = BudgetTemplateLineTable();

  static const db = BudgetTemplateLineRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue templateId;

  _is.UuidValue envelopeId;

  /// Base-currency minor units.
  int allocatedMinor;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [BudgetTemplateLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BudgetTemplateLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? templateId,
    _is.UuidValue? envelopeId,
    int? allocatedMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetTemplateLine',
      if (id != null) 'id': id?.toJson(),
      'templateId': templateId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BudgetTemplateLine',
      if (id != null) 'id': id?.toJson(),
      'templateId': templateId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'allocatedMinor': allocatedMinor,
    };
  }

  static BudgetTemplateLineInclude include() {
    return BudgetTemplateLineInclude._();
  }

  static BudgetTemplateLineIncludeList includeList({
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    BudgetTemplateLineInclude? include,
  }) {
    return BudgetTemplateLineIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _BudgetTemplateLineImpl extends BudgetTemplateLine {
  _BudgetTemplateLineImpl({
    _is.UuidValue? id,
    required _is.UuidValue templateId,
    required _is.UuidValue envelopeId,
    required int allocatedMinor,
  }) : super._(
         id: id,
         templateId: templateId,
         envelopeId: envelopeId,
         allocatedMinor: allocatedMinor,
       );

  /// Returns a shallow copy of this [BudgetTemplateLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BudgetTemplateLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? templateId,
    _is.UuidValue? envelopeId,
    int? allocatedMinor,
  }) {
    return BudgetTemplateLine(
      id: id is _is.UndefinedSentinel ? this.id : id,
      templateId: templateId ?? this.templateId,
      envelopeId: envelopeId ?? this.envelopeId,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
    );
  }
}

class BudgetTemplateLineUpdateTable
    extends _is.UpdateTable<BudgetTemplateLineTable> {
  BudgetTemplateLineUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> templateId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.templateId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> envelopeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.envelopeId,
    value,
  );

  _is.ColumnValue<int, int> allocatedMinor(int value) => _is.ColumnValue(
    table.allocatedMinor,
    value,
  );
}

class BudgetTemplateLineTable extends _is.Table<_is.UuidValue?> {
  BudgetTemplateLineTable({super.tableRelation})
    : super(tableName: 'budget_template_line') {
    updateTable = BudgetTemplateLineUpdateTable(this);
    templateId = _is.ColumnUuid(
      'templateId',
      this,
    );
    envelopeId = _is.ColumnUuid(
      'envelopeId',
      this,
    );
    allocatedMinor = _is.ColumnInt(
      'allocatedMinor',
      this,
    );
  }

  late final BudgetTemplateLineUpdateTable updateTable;

  late final _is.ColumnUuid templateId;

  late final _is.ColumnUuid envelopeId;

  /// Base-currency minor units.
  late final _is.ColumnInt allocatedMinor;

  @override
  List<_is.Column> get columns => [
    id,
    templateId,
    envelopeId,
    allocatedMinor,
  ];
}

class BudgetTemplateLineInclude extends _is.IncludeObject {
  BudgetTemplateLineInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => BudgetTemplateLine.t;
}

class BudgetTemplateLineIncludeList extends _is.IncludeList {
  BudgetTemplateLineIncludeList._({
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BudgetTemplateLine.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => BudgetTemplateLine.t;
}

class BudgetTemplateLineRepository {
  const BudgetTemplateLineRepository._();

  /// Returns a list of [BudgetTemplateLine]s matching the given query parameters.
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
  Future<List<BudgetTemplateLine>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BudgetTemplateLine>(
      where: where?.call(BudgetTemplateLine.t),
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [BudgetTemplateLine]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `BudgetTemplateLine.t`.
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
  _ida.Stream<List<BudgetTemplateLine>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<BudgetTemplateLine>(
      where: where?.call(BudgetTemplateLine.t),
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [BudgetTemplateLine] matching the given query parameters.
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
  Future<BudgetTemplateLine?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BudgetTemplateLine>(
      where: where?.call(BudgetTemplateLine.t),
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BudgetTemplateLine] by its [id] or null if no such row exists.
  Future<BudgetTemplateLine?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BudgetTemplateLine>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BudgetTemplateLine]s in the list and returns the inserted rows.
  ///
  /// The returned [BudgetTemplateLine]s will have their `id` fields set.
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
  Future<List<BudgetTemplateLine>> insert(
    _is.DatabaseSession session,
    List<BudgetTemplateLine> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BudgetTemplateLine>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BudgetTemplateLine] and returns the inserted row.
  ///
  /// The returned [BudgetTemplateLine] will have its `id` field set.
  Future<BudgetTemplateLine> insertRow(
    _is.DatabaseSession session,
    BudgetTemplateLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BudgetTemplateLine>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [BudgetTemplateLine]s in the list and returns the resulting rows.
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
  /// The returned [BudgetTemplateLine]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplateLine>> upsert(
    _is.DatabaseSession session,
    List<BudgetTemplateLine> rows, {
    required _is.ColumnSelections<BudgetTemplateLineTable> conflictColumns,
    _is.ColumnSelections<BudgetTemplateLineTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BudgetTemplateLine>(
      rows,
      conflictColumns: conflictColumns(BudgetTemplateLine.t),
      updateColumns: updateColumns?.call(BudgetTemplateLine.t),
      updateWhere: updateWhere?.call(BudgetTemplateLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BudgetTemplateLine] and returns the resulting row.
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
  /// The returned [BudgetTemplateLine] will have its `id` field set.
  Future<BudgetTemplateLine?> upsertRow(
    _is.DatabaseSession session,
    BudgetTemplateLine row, {
    required _is.ColumnSelections<BudgetTemplateLineTable> conflictColumns,
    _is.ColumnSelections<BudgetTemplateLineTable>? updateColumns,
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BudgetTemplateLine>(
      row,
      conflictColumns: conflictColumns(BudgetTemplateLine.t),
      updateColumns: updateColumns?.call(BudgetTemplateLine.t),
      updateWhere: updateWhere?.call(BudgetTemplateLine.t),
      transaction: transaction,
    );
  }

  /// Updates all [BudgetTemplateLine]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplateLine>> update(
    _is.DatabaseSession session,
    List<BudgetTemplateLine> rows, {
    _is.ColumnSelections<BudgetTemplateLineTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BudgetTemplateLine>(
      rows,
      columns: columns?.call(BudgetTemplateLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BudgetTemplateLine]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BudgetTemplateLine> updateRow(
    _is.DatabaseSession session,
    BudgetTemplateLine row, {
    _is.ColumnSelections<BudgetTemplateLineTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BudgetTemplateLine>(
      row,
      columns: columns?.call(BudgetTemplateLine.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BudgetTemplateLine] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BudgetTemplateLine?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<BudgetTemplateLineUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BudgetTemplateLine>(
      id,
      columnValues: columnValues(BudgetTemplateLine.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BudgetTemplateLine]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BudgetTemplateLine>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BudgetTemplateLineUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<BudgetTemplateLineTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BudgetTemplateLine>(
      columnValues: columnValues(BudgetTemplateLine.t.updateTable),
      where: where(BudgetTemplateLine.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BudgetTemplateLine]s in the list and returns the deleted rows.
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
  Future<List<BudgetTemplateLine>> delete(
    _is.DatabaseSession session,
    List<BudgetTemplateLine> rows, {
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BudgetTemplateLine>(
      rows,
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BudgetTemplateLine].
  Future<BudgetTemplateLine> deleteRow(
    _is.DatabaseSession session,
    BudgetTemplateLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BudgetTemplateLine>(
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
  Future<List<BudgetTemplateLine>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTemplateLineTable> where,
    _is.OrderByBuilder<BudgetTemplateLineTable>? orderBy,
    _is.OrderByListBuilder<BudgetTemplateLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BudgetTemplateLine>(
      where: where(BudgetTemplateLine.t),
      orderBy: orderBy?.call(BudgetTemplateLine.t),
      orderByList: orderByList?.call(BudgetTemplateLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BudgetTemplateLineTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BudgetTemplateLine>(
      where: where?.call(BudgetTemplateLine.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BudgetTemplateLine] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BudgetTemplateLineTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BudgetTemplateLine>(
      where: where(BudgetTemplateLine.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
