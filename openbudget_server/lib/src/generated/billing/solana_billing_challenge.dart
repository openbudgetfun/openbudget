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

/// A one-time wallet ownership challenge for a Solana subscription.
abstract class SolanaBillingChallenge
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  SolanaBillingChallenge._({
    this.id,
    required this.userId,
    required this.message,
    required this.expiresAt,
    this.usedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SolanaBillingChallenge({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String message,
    required DateTime expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  }) = _SolanaBillingChallengeImpl;

  factory SolanaBillingChallenge.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaBillingChallenge(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      message: jsonSerialization['message'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SolanaBillingChallengeTable();

  static const db = SolanaBillingChallengeRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  String message;

  DateTime expiresAt;

  DateTime? usedAt;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaBillingChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SolanaBillingChallenge copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? message,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaBillingChallenge',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'message': message,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SolanaBillingChallengeInclude include() {
    return SolanaBillingChallengeInclude._();
  }

  static SolanaBillingChallengeIncludeList includeList({
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    SolanaBillingChallengeInclude? include,
  }) {
    return SolanaBillingChallengeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SolanaBillingChallengeImpl extends SolanaBillingChallenge {
  _SolanaBillingChallengeImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String message,
    required DateTime expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         message: message,
         expiresAt: expiresAt,
         usedAt: usedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SolanaBillingChallenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SolanaBillingChallenge copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? message,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
  }) {
    return SolanaBillingChallenge(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is _is.UndefinedSentinel ? this.usedAt : usedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SolanaBillingChallengeUpdateTable
    extends _is.UpdateTable<SolanaBillingChallengeTable> {
  SolanaBillingChallengeUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> message(String value) => _is.ColumnValue(
    table.message,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SolanaBillingChallengeTable extends _is.Table<_is.UuidValue?> {
  SolanaBillingChallengeTable({super.tableRelation})
    : super(tableName: 'solana_billing_challenge') {
    updateTable = SolanaBillingChallengeUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    message = _is.ColumnString(
      'message',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _is.ColumnDateTime(
      'usedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final SolanaBillingChallengeUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  late final _is.ColumnString message;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime usedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    message,
    expiresAt,
    usedAt,
    createdAt,
  ];
}

class SolanaBillingChallengeInclude extends _is.IncludeObject {
  SolanaBillingChallengeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaBillingChallenge.t;
}

class SolanaBillingChallengeIncludeList extends _is.IncludeList {
  SolanaBillingChallengeIncludeList._({
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaBillingChallenge.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaBillingChallenge.t;
}

class SolanaBillingChallengeRepository {
  const SolanaBillingChallengeRepository._();

  /// Returns a list of [SolanaBillingChallenge]s matching the given query parameters.
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
  Future<List<SolanaBillingChallenge>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaBillingChallenge>(
      where: where?.call(SolanaBillingChallenge.t),
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SolanaBillingChallenge]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SolanaBillingChallenge.t`.
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
  _ida.Stream<List<SolanaBillingChallenge>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SolanaBillingChallenge>(
      where: where?.call(SolanaBillingChallenge.t),
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SolanaBillingChallenge] matching the given query parameters.
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
  Future<SolanaBillingChallenge?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    int? offset,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaBillingChallenge>(
      where: where?.call(SolanaBillingChallenge.t),
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaBillingChallenge] by its [id] or null if no such row exists.
  Future<SolanaBillingChallenge?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SolanaBillingChallenge>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SolanaBillingChallenge]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaBillingChallenge]s will have their `id` fields set.
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
  Future<List<SolanaBillingChallenge>> insert(
    _is.DatabaseSession session,
    List<SolanaBillingChallenge> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SolanaBillingChallenge>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SolanaBillingChallenge] and returns the inserted row.
  ///
  /// The returned [SolanaBillingChallenge] will have its `id` field set.
  Future<SolanaBillingChallenge> insertRow(
    _is.DatabaseSession session,
    SolanaBillingChallenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaBillingChallenge>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SolanaBillingChallenge]s in the list and returns the resulting rows.
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
  /// The returned [SolanaBillingChallenge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaBillingChallenge>> upsert(
    _is.DatabaseSession session,
    List<SolanaBillingChallenge> rows, {
    required _is.ColumnSelections<SolanaBillingChallengeTable> conflictColumns,
    _is.ColumnSelections<SolanaBillingChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SolanaBillingChallenge>(
      rows,
      conflictColumns: conflictColumns(SolanaBillingChallenge.t),
      updateColumns: updateColumns?.call(SolanaBillingChallenge.t),
      updateWhere: updateWhere?.call(SolanaBillingChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SolanaBillingChallenge] and returns the resulting row.
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
  /// The returned [SolanaBillingChallenge] will have its `id` field set.
  Future<SolanaBillingChallenge?> upsertRow(
    _is.DatabaseSession session,
    SolanaBillingChallenge row, {
    required _is.ColumnSelections<SolanaBillingChallengeTable> conflictColumns,
    _is.ColumnSelections<SolanaBillingChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SolanaBillingChallenge>(
      row,
      conflictColumns: conflictColumns(SolanaBillingChallenge.t),
      updateColumns: updateColumns?.call(SolanaBillingChallenge.t),
      updateWhere: updateWhere?.call(SolanaBillingChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaBillingChallenge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaBillingChallenge>> update(
    _is.DatabaseSession session,
    List<SolanaBillingChallenge> rows, {
    _is.ColumnSelections<SolanaBillingChallengeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SolanaBillingChallenge>(
      rows,
      columns: columns?.call(SolanaBillingChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SolanaBillingChallenge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaBillingChallenge> updateRow(
    _is.DatabaseSession session,
    SolanaBillingChallenge row, {
    _is.ColumnSelections<SolanaBillingChallengeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaBillingChallenge>(
      row,
      columns: columns?.call(SolanaBillingChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaBillingChallenge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaBillingChallenge?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SolanaBillingChallengeUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaBillingChallenge>(
      id,
      columnValues: columnValues(SolanaBillingChallenge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaBillingChallenge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaBillingChallenge>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SolanaBillingChallengeUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SolanaBillingChallengeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SolanaBillingChallenge>(
      columnValues: columnValues(SolanaBillingChallenge.t.updateTable),
      where: where(SolanaBillingChallenge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SolanaBillingChallenge]s in the list and returns the deleted rows.
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
  Future<List<SolanaBillingChallenge>> delete(
    _is.DatabaseSession session,
    List<SolanaBillingChallenge> rows, {
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SolanaBillingChallenge>(
      rows,
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SolanaBillingChallenge].
  Future<SolanaBillingChallenge> deleteRow(
    _is.DatabaseSession session,
    SolanaBillingChallenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaBillingChallenge>(
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
  Future<List<SolanaBillingChallenge>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaBillingChallengeTable> where,
    _is.OrderByBuilder<SolanaBillingChallengeTable>? orderBy,
    _is.OrderByListBuilder<SolanaBillingChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SolanaBillingChallenge>(
      where: where(SolanaBillingChallenge.t),
      orderBy: orderBy?.call(SolanaBillingChallenge.t),
      orderByList: orderByList?.call(SolanaBillingChallenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaBillingChallengeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SolanaBillingChallenge>(
      where: where?.call(SolanaBillingChallenge.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaBillingChallenge] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaBillingChallengeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaBillingChallenge>(
      where: where(SolanaBillingChallenge.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
