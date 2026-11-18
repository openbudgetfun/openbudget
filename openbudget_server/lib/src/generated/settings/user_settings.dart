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

/// Per-user preferences that span entities.
abstract class UserSettings
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  UserSettings._({
    this.id,
    required this.userId,
    required this.reportingCurrencyCode,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory UserSettings({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String reportingCurrencyCode,
    DateTime? updatedAt,
  }) = _UserSettingsImpl;

  factory UserSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserSettings(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      reportingCurrencyCode:
          jsonSerialization['reportingCurrencyCode'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = UserSettingsTable();

  static const db = UserSettingsRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue userId;

  /// ISO 4217 code that combined net worth and cross-entity totals use.
  String reportingCurrencyCode;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserSettings copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? reportingCurrencyCode,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'reportingCurrencyCode': reportingCurrencyCode,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserSettings',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'reportingCurrencyCode': reportingCurrencyCode,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static UserSettingsInclude include() {
    return UserSettingsInclude._();
  }

  static UserSettingsIncludeList includeList({
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    UserSettingsInclude? include,
  }) {
    return UserSettingsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UserSettingsImpl extends UserSettings {
  _UserSettingsImpl({
    _is.UuidValue? id,
    required _is.UuidValue userId,
    required String reportingCurrencyCode,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         userId: userId,
         reportingCurrencyCode: reportingCurrencyCode,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserSettings]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UserSettings copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? userId,
    String? reportingCurrencyCode,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id is _is.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      reportingCurrencyCode:
          reportingCurrencyCode ?? this.reportingCurrencyCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserSettingsUpdateTable extends _is.UpdateTable<UserSettingsTable> {
  UserSettingsUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> userId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.userId,
        value,
      );

  _is.ColumnValue<String, String> reportingCurrencyCode(String value) =>
      _is.ColumnValue(
        table.reportingCurrencyCode,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class UserSettingsTable extends _is.Table<_is.UuidValue?> {
  UserSettingsTable({super.tableRelation}) : super(tableName: 'user_settings') {
    updateTable = UserSettingsUpdateTable(this);
    userId = _is.ColumnUuid(
      'userId',
      this,
    );
    reportingCurrencyCode = _is.ColumnString(
      'reportingCurrencyCode',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final UserSettingsUpdateTable updateTable;

  late final _is.ColumnUuid userId;

  /// ISO 4217 code that combined net worth and cross-entity totals use.
  late final _is.ColumnString reportingCurrencyCode;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    reportingCurrencyCode,
    updatedAt,
  ];
}

class UserSettingsInclude extends _is.IncludeObject {
  UserSettingsInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => UserSettings.t;
}

class UserSettingsIncludeList extends _is.IncludeList {
  UserSettingsIncludeList._({
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserSettings.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => UserSettings.t;
}

class UserSettingsRepository {
  const UserSettingsRepository._();

  /// Returns a list of [UserSettings]s matching the given query parameters.
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
  Future<List<UserSettings>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserSettings>(
      where: where?.call(UserSettings.t),
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [UserSettings]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `UserSettings.t`.
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
  _ida.Stream<List<UserSettings>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<UserSettings>(
      where: where?.call(UserSettings.t),
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [UserSettings] matching the given query parameters.
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
  Future<UserSettings?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    int? offset,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserSettings>(
      where: where?.call(UserSettings.t),
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserSettings] by its [id] or null if no such row exists.
  Future<UserSettings?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserSettings>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserSettings]s in the list and returns the inserted rows.
  ///
  /// The returned [UserSettings]s will have their `id` fields set.
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
  Future<List<UserSettings>> insert(
    _is.DatabaseSession session,
    List<UserSettings> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserSettings>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserSettings] and returns the inserted row.
  ///
  /// The returned [UserSettings] will have its `id` field set.
  Future<UserSettings> insertRow(
    _is.DatabaseSession session,
    UserSettings row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserSettings>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UserSettings]s in the list and returns the resulting rows.
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
  /// The returned [UserSettings]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserSettings>> upsert(
    _is.DatabaseSession session,
    List<UserSettings> rows, {
    required _is.ColumnSelections<UserSettingsTable> conflictColumns,
    _is.ColumnSelections<UserSettingsTable>? updateColumns,
    _is.WhereExpressionBuilder<UserSettingsTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserSettings>(
      rows,
      conflictColumns: conflictColumns(UserSettings.t),
      updateColumns: updateColumns?.call(UserSettings.t),
      updateWhere: updateWhere?.call(UserSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserSettings] and returns the resulting row.
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
  /// The returned [UserSettings] will have its `id` field set.
  Future<UserSettings?> upsertRow(
    _is.DatabaseSession session,
    UserSettings row, {
    required _is.ColumnSelections<UserSettingsTable> conflictColumns,
    _is.ColumnSelections<UserSettingsTable>? updateColumns,
    _is.WhereExpressionBuilder<UserSettingsTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserSettings>(
      row,
      conflictColumns: conflictColumns(UserSettings.t),
      updateColumns: updateColumns?.call(UserSettings.t),
      updateWhere: updateWhere?.call(UserSettings.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserSettings]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserSettings>> update(
    _is.DatabaseSession session,
    List<UserSettings> rows, {
    _is.ColumnSelections<UserSettingsTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserSettings>(
      rows,
      columns: columns?.call(UserSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserSettings]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserSettings> updateRow(
    _is.DatabaseSession session,
    UserSettings row, {
    _is.ColumnSelections<UserSettingsTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserSettings>(
      row,
      columns: columns?.call(UserSettings.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserSettings] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserSettings?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<UserSettingsUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserSettings>(
      id,
      columnValues: columnValues(UserSettings.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserSettings]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserSettings>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserSettingsUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserSettingsTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserSettings>(
      columnValues: columnValues(UserSettings.t.updateTable),
      where: where(UserSettings.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserSettings]s in the list and returns the deleted rows.
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
  Future<List<UserSettings>> delete(
    _is.DatabaseSession session,
    List<UserSettings> rows, {
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserSettings>(
      rows,
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserSettings].
  Future<UserSettings> deleteRow(
    _is.DatabaseSession session,
    UserSettings row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserSettings>(
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
  Future<List<UserSettings>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserSettingsTable> where,
    _is.OrderByBuilder<UserSettingsTable>? orderBy,
    _is.OrderByListBuilder<UserSettingsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserSettings>(
      where: where(UserSettings.t),
      orderBy: orderBy?.call(UserSettings.t),
      orderByList: orderByList?.call(UserSettings.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserSettingsTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserSettings>(
      where: where?.call(UserSettings.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserSettings] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserSettingsTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserSettings>(
      where: where(UserSettings.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
