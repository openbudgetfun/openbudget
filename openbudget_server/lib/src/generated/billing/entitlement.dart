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

import '../billing/entitlement_source.dart' as _i34ejbb7;
import '../billing/entitlement_status.dart' as _iudzg4q8;

/// A user's paid OpenBudget Plus subscription on one payment rail.
///
/// Each rail writes its own row, keyed by the rail's subscription id, so a
/// user who pays twice by mistake keeps two rows and the later period wins.
abstract class Entitlement
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Entitlement._({
    this.id,
    required this.userId,
    required this.source,
    required this.externalId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Entitlement({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _i34ejbb7.EntitlementSource source,
    required String externalId,
    required _iudzg4q8.EntitlementStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EntitlementImpl;

  factory Entitlement.fromJson(Map<String, dynamic> jsonSerialization) {
    return Entitlement(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      source: _i34ejbb7.EntitlementSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      externalId: jsonSerialization['externalId'] as String,
      status: _iudzg4q8.EntitlementStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      currentPeriodStart: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['currentPeriodStart'],
      ),
      currentPeriodEnd: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['currentPeriodEnd'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = EntitlementTable();

  static const db = EntitlementRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  _i34ejbb7.EntitlementSource source;

  /// The rail's subscription id: a Stripe subscription, a RevenueCat
  /// original transaction, or a Solana subscription account address.
  String externalId;

  _iudzg4q8.EntitlementStatus status;

  DateTime currentPeriodStart;

  DateTime currentPeriodEnd;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Entitlement copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _i34ejbb7.EntitlementSource? source,
    String? externalId,
    _iudzg4q8.EntitlementStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Entitlement',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'source': source.toJson(),
      'externalId': externalId,
      'status': status.toJson(),
      'currentPeriodStart': currentPeriodStart.toJson(),
      'currentPeriodEnd': currentPeriodEnd.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Entitlement',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'source': source.toJson(),
      'externalId': externalId,
      'status': status.toJson(),
      'currentPeriodStart': currentPeriodStart.toJson(),
      'currentPeriodEnd': currentPeriodEnd.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static EntitlementInclude include() {
    return EntitlementInclude._();
  }

  static EntitlementIncludeList includeList({
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    EntitlementInclude? include,
  }) {
    return EntitlementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EntitlementImpl extends Entitlement {
  _EntitlementImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required _i34ejbb7.EntitlementSource source,
    required String externalId,
    required _iudzg4q8.EntitlementStatus status,
    required DateTime currentPeriodStart,
    required DateTime currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         source: source,
         externalId: externalId,
         status: status,
         currentPeriodStart: currentPeriodStart,
         currentPeriodEnd: currentPeriodEnd,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Entitlement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Entitlement copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    _i34ejbb7.EntitlementSource? source,
    String? externalId,
    _iudzg4q8.EntitlementStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entitlement(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class EntitlementUpdateTable extends _is.UpdateTable<EntitlementTable> {
  EntitlementUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<_i34ejbb7.EntitlementSource, _i34ejbb7.EntitlementSource>
  source(_i34ejbb7.EntitlementSource value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> externalId(String value) => _is.ColumnValue(
    table.externalId,
    value,
  );

  _is.ColumnValue<_iudzg4q8.EntitlementStatus, _iudzg4q8.EntitlementStatus>
  status(_iudzg4q8.EntitlementStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> currentPeriodStart(DateTime value) =>
      _is.ColumnValue(
        table.currentPeriodStart,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> currentPeriodEnd(DateTime value) =>
      _is.ColumnValue(
        table.currentPeriodEnd,
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

class EntitlementTable extends _is.Table<_is.UuidValue?> {
  EntitlementTable({super.tableRelation}) : super(tableName: 'entitlement') {
    updateTable = EntitlementUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    source = _is.ColumnEnum(
      'source',
      this,
      _is.EnumSerialization.byName,
    );
    externalId = _is.ColumnString(
      'externalId',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    currentPeriodStart = _is.ColumnDateTime(
      'currentPeriodStart',
      this,
    );
    currentPeriodEnd = _is.ColumnDateTime(
      'currentPeriodEnd',
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

  late final EntitlementUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnEnum<_i34ejbb7.EntitlementSource> source;

  /// The rail's subscription id: a Stripe subscription, a RevenueCat
  /// original transaction, or a Solana subscription account address.
  late final _is.ColumnString externalId;

  late final _is.ColumnEnum<_iudzg4q8.EntitlementStatus> status;

  late final _is.ColumnDateTime currentPeriodStart;

  late final _is.ColumnDateTime currentPeriodEnd;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    source,
    externalId,
    status,
    currentPeriodStart,
    currentPeriodEnd,
    createdAt,
    updatedAt,
  ];
}

class EntitlementInclude extends _is.IncludeObject {
  EntitlementInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Entitlement.t;
}

class EntitlementIncludeList extends _is.IncludeList {
  EntitlementIncludeList._({
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Entitlement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Entitlement.t;
}

class EntitlementRepository {
  const EntitlementRepository._();

  /// Returns a list of [Entitlement]s matching the given query parameters.
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
  Future<List<Entitlement>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Entitlement>(
      where: where?.call(Entitlement.t),
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Entitlement]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Entitlement.t`.
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
  _ida.Stream<List<Entitlement>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Entitlement>(
      where: where?.call(Entitlement.t),
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Entitlement] matching the given query parameters.
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
  Future<Entitlement?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    int? offset,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Entitlement>(
      where: where?.call(Entitlement.t),
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Entitlement] by its [id] or null if no such row exists.
  Future<Entitlement?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Entitlement>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Entitlement]s in the list and returns the inserted rows.
  ///
  /// The returned [Entitlement]s will have their `id` fields set.
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
  Future<List<Entitlement>> insert(
    _is.DatabaseSession session,
    List<Entitlement> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Entitlement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Entitlement] and returns the inserted row.
  ///
  /// The returned [Entitlement] will have its `id` field set.
  Future<Entitlement> insertRow(
    _is.DatabaseSession session,
    Entitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Entitlement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Entitlement]s in the list and returns the resulting rows.
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
  /// The returned [Entitlement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entitlement>> upsert(
    _is.DatabaseSession session,
    List<Entitlement> rows, {
    required _is.ColumnSelections<EntitlementTable> conflictColumns,
    _is.ColumnSelections<EntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<EntitlementTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Entitlement>(
      rows,
      conflictColumns: conflictColumns(Entitlement.t),
      updateColumns: updateColumns?.call(Entitlement.t),
      updateWhere: updateWhere?.call(Entitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Entitlement] and returns the resulting row.
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
  /// The returned [Entitlement] will have its `id` field set.
  Future<Entitlement?> upsertRow(
    _is.DatabaseSession session,
    Entitlement row, {
    required _is.ColumnSelections<EntitlementTable> conflictColumns,
    _is.ColumnSelections<EntitlementTable>? updateColumns,
    _is.WhereExpressionBuilder<EntitlementTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Entitlement>(
      row,
      conflictColumns: conflictColumns(Entitlement.t),
      updateColumns: updateColumns?.call(Entitlement.t),
      updateWhere: updateWhere?.call(Entitlement.t),
      transaction: transaction,
    );
  }

  /// Updates all [Entitlement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entitlement>> update(
    _is.DatabaseSession session,
    List<Entitlement> rows, {
    _is.ColumnSelections<EntitlementTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Entitlement>(
      rows,
      columns: columns?.call(Entitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Entitlement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Entitlement> updateRow(
    _is.DatabaseSession session,
    Entitlement row, {
    _is.ColumnSelections<EntitlementTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Entitlement>(
      row,
      columns: columns?.call(Entitlement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Entitlement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Entitlement?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<EntitlementUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Entitlement>(
      id,
      columnValues: columnValues(Entitlement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Entitlement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Entitlement>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EntitlementUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EntitlementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Entitlement>(
      columnValues: columnValues(Entitlement.t.updateTable),
      where: where(Entitlement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Entitlement]s in the list and returns the deleted rows.
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
  Future<List<Entitlement>> delete(
    _is.DatabaseSession session,
    List<Entitlement> rows, {
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Entitlement>(
      rows,
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Entitlement].
  Future<Entitlement> deleteRow(
    _is.DatabaseSession session,
    Entitlement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Entitlement>(
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
  Future<List<Entitlement>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EntitlementTable> where,
    _is.OrderByBuilder<EntitlementTable>? orderBy,
    _is.OrderByListBuilder<EntitlementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Entitlement>(
      where: where(Entitlement.t),
      orderBy: orderBy?.call(Entitlement.t),
      orderByList: orderByList?.call(Entitlement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EntitlementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Entitlement>(
      where: where?.call(Entitlement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Entitlement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EntitlementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Entitlement>(
      where: where(Entitlement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
