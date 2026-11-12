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

/// Geographic availability and popularity metadata for an institution.
abstract class InstitutionLocation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  InstitutionLocation._({
    this.id,
    required this.institutionId,
    required this.locationCode,
    bool? isPopular,
    this.popularityRank,
    DateTime? createdAt,
  }) : isPopular = isPopular ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory InstitutionLocation({
    _is.UuidValue? id,
    required _is.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) = _InstitutionLocationImpl;

  factory InstitutionLocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return InstitutionLocation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      institutionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['institutionId'],
      ),
      locationCode: jsonSerialization['locationCode'] as String,
      isPopular: jsonSerialization['isPopular'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isPopular']),
      popularityRank: jsonSerialization['popularityRank'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = InstitutionLocationTable();

  static const db = InstitutionLocationRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue institutionId;

  /// ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  String locationCode;

  /// Whether this institution is shown in "Popular options" for the location.
  bool isPopular;

  /// Lower rank means higher priority in popular ordering.
  int? popularityRank;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InstitutionLocation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InstitutionLocation',
      if (id != null) 'id': id?.toJson(),
      'institutionId': institutionId.toJson(),
      'locationCode': locationCode,
      'isPopular': isPopular,
      if (popularityRank != null) 'popularityRank': popularityRank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InstitutionLocation',
      if (id != null) 'id': id?.toJson(),
      'institutionId': institutionId.toJson(),
      'locationCode': locationCode,
      'isPopular': isPopular,
      if (popularityRank != null) 'popularityRank': popularityRank,
      'createdAt': createdAt.toJson(),
    };
  }

  static InstitutionLocationInclude include() {
    return InstitutionLocationInclude._();
  }

  static InstitutionLocationIncludeList includeList({
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    InstitutionLocationInclude? include,
  }) {
    return InstitutionLocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionLocationImpl extends InstitutionLocation {
  _InstitutionLocationImpl({
    _is.UuidValue? id,
    required _is.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         institutionId: institutionId,
         locationCode: locationCode,
         isPopular: isPopular,
         popularityRank: popularityRank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InstitutionLocation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    Object? popularityRank = _Undefined,
    DateTime? createdAt,
  }) {
    return InstitutionLocation(
      id: id is _is.UndefinedSentinel ? this.id : id,
      institutionId: institutionId ?? this.institutionId,
      locationCode: locationCode ?? this.locationCode,
      isPopular: isPopular ?? this.isPopular,
      popularityRank: popularityRank is int?
          ? popularityRank
          : this.popularityRank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InstitutionLocationUpdateTable
    extends _is.UpdateTable<InstitutionLocationTable> {
  InstitutionLocationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> institutionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.institutionId,
    value,
  );

  _is.ColumnValue<String, String> locationCode(String value) => _is.ColumnValue(
    table.locationCode,
    value,
  );

  _is.ColumnValue<bool, bool> isPopular(bool value) => _is.ColumnValue(
    table.isPopular,
    value,
  );

  _is.ColumnValue<int, int> popularityRank(int? value) => _is.ColumnValue(
    table.popularityRank,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class InstitutionLocationTable extends _is.Table<_is.UuidValue?> {
  InstitutionLocationTable({super.tableRelation})
    : super(tableName: 'institution_location') {
    updateTable = InstitutionLocationUpdateTable(this);
    institutionId = _is.ColumnUuid(
      'institutionId',
      this,
    );
    locationCode = _is.ColumnString(
      'locationCode',
      this,
    );
    isPopular = _is.ColumnBool(
      'isPopular',
      this,
      hasDefault: true,
    );
    popularityRank = _is.ColumnInt(
      'popularityRank',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final InstitutionLocationUpdateTable updateTable;

  late final _is.ColumnUuid institutionId;

  /// ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  late final _is.ColumnString locationCode;

  /// Whether this institution is shown in "Popular options" for the location.
  late final _is.ColumnBool isPopular;

  /// Lower rank means higher priority in popular ordering.
  late final _is.ColumnInt popularityRank;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    institutionId,
    locationCode,
    isPopular,
    popularityRank,
    createdAt,
  ];
}

class InstitutionLocationInclude extends _is.IncludeObject {
  InstitutionLocationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => InstitutionLocation.t;
}

class InstitutionLocationIncludeList extends _is.IncludeList {
  InstitutionLocationIncludeList._({
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InstitutionLocation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => InstitutionLocation.t;
}

class InstitutionLocationRepository {
  const InstitutionLocationRepository._();

  /// Returns a list of [InstitutionLocation]s matching the given query parameters.
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
  Future<List<InstitutionLocation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [InstitutionLocation]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `InstitutionLocation.t`.
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
  _ida.Stream<List<InstitutionLocation>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [InstitutionLocation] matching the given query parameters.
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
  Future<InstitutionLocation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? offset,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InstitutionLocation] by its [id] or null if no such row exists.
  Future<InstitutionLocation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InstitutionLocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InstitutionLocation]s in the list and returns the inserted rows.
  ///
  /// The returned [InstitutionLocation]s will have their `id` fields set.
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
  Future<List<InstitutionLocation>> insert(
    _is.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<InstitutionLocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [InstitutionLocation] and returns the inserted row.
  ///
  /// The returned [InstitutionLocation] will have its `id` field set.
  Future<InstitutionLocation> insertRow(
    _is.DatabaseSession session,
    InstitutionLocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<InstitutionLocation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [InstitutionLocation]s in the list and returns the resulting rows.
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
  /// The returned [InstitutionLocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InstitutionLocation>> upsert(
    _is.DatabaseSession session,
    List<InstitutionLocation> rows, {
    required _is.ColumnSelections<InstitutionLocationTable> conflictColumns,
    _is.ColumnSelections<InstitutionLocationTable>? updateColumns,
    _is.WhereExpressionBuilder<InstitutionLocationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<InstitutionLocation>(
      rows,
      conflictColumns: conflictColumns(InstitutionLocation.t),
      updateColumns: updateColumns?.call(InstitutionLocation.t),
      updateWhere: updateWhere?.call(InstitutionLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [InstitutionLocation] and returns the resulting row.
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
  /// The returned [InstitutionLocation] will have its `id` field set.
  Future<InstitutionLocation?> upsertRow(
    _is.DatabaseSession session,
    InstitutionLocation row, {
    required _is.ColumnSelections<InstitutionLocationTable> conflictColumns,
    _is.ColumnSelections<InstitutionLocationTable>? updateColumns,
    _is.WhereExpressionBuilder<InstitutionLocationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<InstitutionLocation>(
      row,
      conflictColumns: conflictColumns(InstitutionLocation.t),
      updateColumns: updateColumns?.call(InstitutionLocation.t),
      updateWhere: updateWhere?.call(InstitutionLocation.t),
      transaction: transaction,
    );
  }

  /// Updates all [InstitutionLocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InstitutionLocation>> update(
    _is.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _is.ColumnSelections<InstitutionLocationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<InstitutionLocation>(
      rows,
      columns: columns?.call(InstitutionLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [InstitutionLocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InstitutionLocation> updateRow(
    _is.DatabaseSession session,
    InstitutionLocation row, {
    _is.ColumnSelections<InstitutionLocationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<InstitutionLocation>(
      row,
      columns: columns?.call(InstitutionLocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InstitutionLocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InstitutionLocation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<InstitutionLocationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<InstitutionLocation>(
      id,
      columnValues: columnValues(InstitutionLocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InstitutionLocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InstitutionLocation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InstitutionLocationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<InstitutionLocationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<InstitutionLocation>(
      columnValues: columnValues(InstitutionLocation.t.updateTable),
      where: where(InstitutionLocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [InstitutionLocation]s in the list and returns the deleted rows.
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
  Future<List<InstitutionLocation>> delete(
    _is.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<InstitutionLocation>(
      rows,
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [InstitutionLocation].
  Future<InstitutionLocation> deleteRow(
    _is.DatabaseSession session,
    InstitutionLocation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InstitutionLocation>(
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
  Future<List<InstitutionLocation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InstitutionLocationTable> where,
    _is.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _is.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<InstitutionLocation>(
      where: where(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InstitutionLocation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InstitutionLocationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InstitutionLocation>(
      where: where(InstitutionLocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
