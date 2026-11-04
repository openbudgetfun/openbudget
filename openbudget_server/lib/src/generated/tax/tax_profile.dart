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

/// The tax profile attached to a budget, stored as the tax engine's JSON.
abstract class TaxProfileRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TaxProfileRecord._({
    this.id,
    required this.budgetId,
    required this.jurisdiction,
    required this.entityKind,
    required this.profileJson,
    this.linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TaxProfileRecord({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    _is.UuidValue? linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TaxProfileRecordImpl;

  factory TaxProfileRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxProfileRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      jurisdiction: jsonSerialization['jurisdiction'] as String,
      entityKind: jsonSerialization['entityKind'] as String,
      profileJson: jsonSerialization['profileJson'] as String,
      linkedBudgetId: jsonSerialization['linkedBudgetId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['linkedBudgetId'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = TaxProfileRecordTable();

  static const db = TaxProfileRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue budgetId;

  /// ISO 3166-1 alpha-2 country code, such as GB.
  String jurisdiction;

  /// TaxEntityKind name: individual, soleTrader, or company.
  String entityKind;

  /// TaxProfile.toJson payload for the jurisdiction.
  String profileJson;

  /// Personal budget this business feeds, or the director's personal budget.
  _is.UuidValue? linkedBudgetId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxProfileRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    String? jurisdiction,
    String? entityKind,
    String? profileJson,
    _is.UuidValue? linkedBudgetId = const _is.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
      if (linkedBudgetId != null) 'linkedBudgetId': linkedBudgetId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
      if (linkedBudgetId != null) 'linkedBudgetId': linkedBudgetId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static TaxProfileRecordInclude include() {
    return TaxProfileRecordInclude._();
  }

  static TaxProfileRecordIncludeList includeList({
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    TaxProfileRecordInclude? include,
  }) {
    return TaxProfileRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TaxProfileRecordImpl extends TaxProfileRecord {
  _TaxProfileRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    _is.UuidValue? linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         jurisdiction: jurisdiction,
         entityKind: entityKind,
         profileJson: profileJson,
         linkedBudgetId: linkedBudgetId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxProfileRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    String? jurisdiction,
    String? entityKind,
    String? profileJson,
    _is.UuidValue? linkedBudgetId = const _is.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxProfileRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      entityKind: entityKind ?? this.entityKind,
      profileJson: profileJson ?? this.profileJson,
      linkedBudgetId: linkedBudgetId is _is.UndefinedSentinel
          ? this.linkedBudgetId
          : linkedBudgetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaxProfileRecordUpdateTable
    extends _is.UpdateTable<TaxProfileRecordTable> {
  TaxProfileRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<String, String> jurisdiction(String value) => _is.ColumnValue(
    table.jurisdiction,
    value,
  );

  _is.ColumnValue<String, String> entityKind(String value) => _is.ColumnValue(
    table.entityKind,
    value,
  );

  _is.ColumnValue<String, String> profileJson(String value) => _is.ColumnValue(
    table.profileJson,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> linkedBudgetId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.linkedBudgetId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class TaxProfileRecordTable extends _is.Table<_is.UuidValue?> {
  TaxProfileRecordTable({super.tableRelation})
    : super(tableName: 'tax_profile') {
    updateTable = TaxProfileRecordUpdateTable(this);
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    jurisdiction = _is.ColumnString(
      'jurisdiction',
      this,
    );
    entityKind = _is.ColumnString(
      'entityKind',
      this,
    );
    profileJson = _is.ColumnString(
      'profileJson',
      this,
    );
    linkedBudgetId = _is.ColumnUuid(
      'linkedBudgetId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final TaxProfileRecordUpdateTable updateTable;

  late final _is.ColumnUuid budgetId;

  /// ISO 3166-1 alpha-2 country code, such as GB.
  late final _is.ColumnString jurisdiction;

  /// TaxEntityKind name: individual, soleTrader, or company.
  late final _is.ColumnString entityKind;

  /// TaxProfile.toJson payload for the jurisdiction.
  late final _is.ColumnString profileJson;

  /// Personal budget this business feeds, or the director's personal budget.
  late final _is.ColumnUuid linkedBudgetId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    budgetId,
    jurisdiction,
    entityKind,
    profileJson,
    linkedBudgetId,
    createdAt,
    updatedAt,
  ];
}

class TaxProfileRecordInclude extends _is.IncludeObject {
  TaxProfileRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => TaxProfileRecord.t;
}

class TaxProfileRecordIncludeList extends _is.IncludeList {
  TaxProfileRecordIncludeList._({
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TaxProfileRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TaxProfileRecord.t;
}

class TaxProfileRecordRepository {
  const TaxProfileRecordRepository._();

  /// Returns a list of [TaxProfileRecord]s matching the given query parameters.
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
  Future<List<TaxProfileRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TaxProfileRecord>(
      where: where?.call(TaxProfileRecord.t),
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [TaxProfileRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `TaxProfileRecord.t`.
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
  _ida.Stream<List<TaxProfileRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<TaxProfileRecord>(
      where: where?.call(TaxProfileRecord.t),
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [TaxProfileRecord] matching the given query parameters.
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
  Future<TaxProfileRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TaxProfileRecord>(
      where: where?.call(TaxProfileRecord.t),
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TaxProfileRecord] by its [id] or null if no such row exists.
  Future<TaxProfileRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TaxProfileRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TaxProfileRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [TaxProfileRecord]s will have their `id` fields set.
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
  Future<List<TaxProfileRecord>> insert(
    _is.DatabaseSession session,
    List<TaxProfileRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TaxProfileRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TaxProfileRecord] and returns the inserted row.
  ///
  /// The returned [TaxProfileRecord] will have its `id` field set.
  Future<TaxProfileRecord> insertRow(
    _is.DatabaseSession session,
    TaxProfileRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TaxProfileRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TaxProfileRecord]s in the list and returns the resulting rows.
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
  /// The returned [TaxProfileRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaxProfileRecord>> upsert(
    _is.DatabaseSession session,
    List<TaxProfileRecord> rows, {
    required _is.ColumnSelections<TaxProfileRecordTable> conflictColumns,
    _is.ColumnSelections<TaxProfileRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TaxProfileRecord>(
      rows,
      conflictColumns: conflictColumns(TaxProfileRecord.t),
      updateColumns: updateColumns?.call(TaxProfileRecord.t),
      updateWhere: updateWhere?.call(TaxProfileRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TaxProfileRecord] and returns the resulting row.
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
  /// The returned [TaxProfileRecord] will have its `id` field set.
  Future<TaxProfileRecord?> upsertRow(
    _is.DatabaseSession session,
    TaxProfileRecord row, {
    required _is.ColumnSelections<TaxProfileRecordTable> conflictColumns,
    _is.ColumnSelections<TaxProfileRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TaxProfileRecord>(
      row,
      conflictColumns: conflictColumns(TaxProfileRecord.t),
      updateColumns: updateColumns?.call(TaxProfileRecord.t),
      updateWhere: updateWhere?.call(TaxProfileRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [TaxProfileRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaxProfileRecord>> update(
    _is.DatabaseSession session,
    List<TaxProfileRecord> rows, {
    _is.ColumnSelections<TaxProfileRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TaxProfileRecord>(
      rows,
      columns: columns?.call(TaxProfileRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TaxProfileRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TaxProfileRecord> updateRow(
    _is.DatabaseSession session,
    TaxProfileRecord row, {
    _is.ColumnSelections<TaxProfileRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TaxProfileRecord>(
      row,
      columns: columns?.call(TaxProfileRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TaxProfileRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TaxProfileRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TaxProfileRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TaxProfileRecord>(
      id,
      columnValues: columnValues(TaxProfileRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TaxProfileRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TaxProfileRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TaxProfileRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<TaxProfileRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TaxProfileRecord>(
      columnValues: columnValues(TaxProfileRecord.t.updateTable),
      where: where(TaxProfileRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TaxProfileRecord]s in the list and returns the deleted rows.
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
  Future<List<TaxProfileRecord>> delete(
    _is.DatabaseSession session,
    List<TaxProfileRecord> rows, {
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TaxProfileRecord>(
      rows,
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TaxProfileRecord].
  Future<TaxProfileRecord> deleteRow(
    _is.DatabaseSession session,
    TaxProfileRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TaxProfileRecord>(
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
  Future<List<TaxProfileRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TaxProfileRecordTable> where,
    _is.OrderByBuilder<TaxProfileRecordTable>? orderBy,
    _is.OrderByListBuilder<TaxProfileRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TaxProfileRecord>(
      where: where(TaxProfileRecord.t),
      orderBy: orderBy?.call(TaxProfileRecord.t),
      orderByList: orderByList?.call(TaxProfileRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TaxProfileRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TaxProfileRecord>(
      where: where?.call(TaxProfileRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TaxProfileRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TaxProfileRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TaxProfileRecord>(
      where: where(TaxProfileRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
