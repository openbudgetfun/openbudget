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

import '../envelope_goals/envelope_goal_kind.dart' as _ietq9ydg;

/// A savings or funding target for one envelope.
abstract class EnvelopeGoal
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  EnvelopeGoal._({
    this.id,
    required this.entityId,
    required this.envelopeId,
    required this.kind,
    required this.amountMinor,
    this.targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvelopeGoal({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue envelopeId,
    required _ietq9ydg.EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EnvelopeGoalImpl;

  factory EnvelopeGoal.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvelopeGoal(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      envelopeId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      kind: _ietq9ydg.EnvelopeGoalKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      targetDate: jsonSerialization['targetDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['targetDate']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = EnvelopeGoalTable();

  static const db = EnvelopeGoalRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  _is.UuidValue envelopeId;

  _ietq9ydg.EnvelopeGoalKind kind;

  /// Base-currency minor units, positive. The target balance for
  /// targetBalance and targetByDate; the amount to assign each month for
  /// monthlyFunding.
  int amountMinor;

  /// Calendar date; required for targetByDate, null otherwise.
  DateTime? targetDate;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EnvelopeGoal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? envelopeId,
    _ietq9ydg.EnvelopeGoalKind? kind,
    int? amountMinor,
    DateTime? targetDate = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'kind': kind.toJson(),
      'amountMinor': amountMinor,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'kind': kind.toJson(),
      'amountMinor': amountMinor,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static EnvelopeGoalInclude include() {
    return EnvelopeGoalInclude._();
  }

  static EnvelopeGoalIncludeList includeList({
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    EnvelopeGoalInclude? include,
  }) {
    return EnvelopeGoalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EnvelopeGoalImpl extends EnvelopeGoal {
  _EnvelopeGoalImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue envelopeId,
    required _ietq9ydg.EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         envelopeId: envelopeId,
         kind: kind,
         amountMinor: amountMinor,
         targetDate: targetDate,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EnvelopeGoal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? envelopeId,
    _ietq9ydg.EnvelopeGoalKind? kind,
    int? amountMinor,
    DateTime? targetDate = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvelopeGoal(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      envelopeId: envelopeId ?? this.envelopeId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      targetDate: targetDate is _is.UndefinedSentinel
          ? this.targetDate
          : targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EnvelopeGoalUpdateTable extends _is.UpdateTable<EnvelopeGoalTable> {
  EnvelopeGoalUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> envelopeId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.envelopeId,
    value,
  );

  _is.ColumnValue<_ietq9ydg.EnvelopeGoalKind, _ietq9ydg.EnvelopeGoalKind> kind(
    _ietq9ydg.EnvelopeGoalKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> targetDate(DateTime? value) =>
      _is.ColumnValue(
        table.targetDate,
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

class EnvelopeGoalTable extends _is.Table<_is.UuidValue?> {
  EnvelopeGoalTable({super.tableRelation}) : super(tableName: 'envelope_goal') {
    updateTable = EnvelopeGoalUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    envelopeId = _is.ColumnUuid(
      'envelopeId',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    targetDate = _is.ColumnDateTime(
      'targetDate',
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

  late final EnvelopeGoalUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnUuid envelopeId;

  late final _is.ColumnEnum<_ietq9ydg.EnvelopeGoalKind> kind;

  /// Base-currency minor units, positive. The target balance for
  /// targetBalance and targetByDate; the amount to assign each month for
  /// monthlyFunding.
  late final _is.ColumnInt amountMinor;

  /// Calendar date; required for targetByDate, null otherwise.
  late final _is.ColumnDateTime targetDate;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    envelopeId,
    kind,
    amountMinor,
    targetDate,
    createdAt,
    updatedAt,
  ];
}

class EnvelopeGoalInclude extends _is.IncludeObject {
  EnvelopeGoalInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => EnvelopeGoal.t;
}

class EnvelopeGoalIncludeList extends _is.IncludeList {
  EnvelopeGoalIncludeList._({
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EnvelopeGoal.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => EnvelopeGoal.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [EnvelopeGoal]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `EnvelopeGoal.t`.
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
  _ida.Stream<List<EnvelopeGoal>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? offset,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EnvelopeGoal] by its [id] or null if no such row exists.
  Future<EnvelopeGoal?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EnvelopeGoal>> insert(
    _is.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<EnvelopeGoal>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [EnvelopeGoal] and returns the inserted row.
  ///
  /// The returned [EnvelopeGoal] will have its `id` field set.
  Future<EnvelopeGoal> insertRow(
    _is.DatabaseSession session,
    EnvelopeGoal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<EnvelopeGoal>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [EnvelopeGoal]s in the list and returns the resulting rows.
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
  /// The returned [EnvelopeGoal]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EnvelopeGoal>> upsert(
    _is.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    required _is.ColumnSelections<EnvelopeGoalTable> conflictColumns,
    _is.ColumnSelections<EnvelopeGoalTable>? updateColumns,
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<EnvelopeGoal>(
      rows,
      conflictColumns: conflictColumns(EnvelopeGoal.t),
      updateColumns: updateColumns?.call(EnvelopeGoal.t),
      updateWhere: updateWhere?.call(EnvelopeGoal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [EnvelopeGoal] and returns the resulting row.
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
  /// The returned [EnvelopeGoal] will have its `id` field set.
  Future<EnvelopeGoal?> upsertRow(
    _is.DatabaseSession session,
    EnvelopeGoal row, {
    required _is.ColumnSelections<EnvelopeGoalTable> conflictColumns,
    _is.ColumnSelections<EnvelopeGoalTable>? updateColumns,
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<EnvelopeGoal>(
      row,
      conflictColumns: conflictColumns(EnvelopeGoal.t),
      updateColumns: updateColumns?.call(EnvelopeGoal.t),
      updateWhere: updateWhere?.call(EnvelopeGoal.t),
      transaction: transaction,
    );
  }

  /// Updates all [EnvelopeGoal]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EnvelopeGoal>> update(
    _is.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _is.ColumnSelections<EnvelopeGoalTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<EnvelopeGoal>(
      rows,
      columns: columns?.call(EnvelopeGoal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [EnvelopeGoal]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EnvelopeGoal> updateRow(
    _is.DatabaseSession session,
    EnvelopeGoal row, {
    _is.ColumnSelections<EnvelopeGoalTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<EnvelopeGoalUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<EnvelopeGoal>(
      id,
      columnValues: columnValues(EnvelopeGoal.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EnvelopeGoal]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<EnvelopeGoal>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EnvelopeGoalUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EnvelopeGoalTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<EnvelopeGoal>(
      columnValues: columnValues(EnvelopeGoal.t.updateTable),
      where: where(EnvelopeGoal.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [EnvelopeGoal]s in the list and returns the deleted rows.
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
  Future<List<EnvelopeGoal>> delete(
    _is.DatabaseSession session,
    List<EnvelopeGoal> rows, {
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<EnvelopeGoal>(
      rows,
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [EnvelopeGoal].
  Future<EnvelopeGoal> deleteRow(
    _is.DatabaseSession session,
    EnvelopeGoal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EnvelopeGoal>(
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
  Future<List<EnvelopeGoal>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EnvelopeGoalTable> where,
    _is.OrderByBuilder<EnvelopeGoalTable>? orderBy,
    _is.OrderByListBuilder<EnvelopeGoalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<EnvelopeGoal>(
      where: where(EnvelopeGoal.t),
      orderBy: orderBy?.call(EnvelopeGoal.t),
      orderByList: orderByList?.call(EnvelopeGoal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnvelopeGoalTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<EnvelopeGoal>(
      where: where?.call(EnvelopeGoal.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EnvelopeGoal] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EnvelopeGoalTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EnvelopeGoal>(
      where: where(EnvelopeGoal.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
