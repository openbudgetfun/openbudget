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

/// Catalog entry for a financial institution that can be linked to accounts.
abstract class Institution
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Institution._({
    this.id,
    required this.slug,
    required this.name,
    this.website,
    this.plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : isDigitalBank = isDigitalBank ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Institution({
    _is.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) = _InstitutionImpl;

  factory Institution.fromJson(Map<String, dynamic> jsonSerialization) {
    return Institution(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slug: jsonSerialization['slug'] as String,
      name: jsonSerialization['name'] as String,
      website: jsonSerialization['website'] as String?,
      plaidInstitutionId: jsonSerialization['plaidInstitutionId'] as String?,
      isDigitalBank: jsonSerialization['isDigitalBank'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isDigitalBank']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = InstitutionTable();

  static const db = InstitutionRepository._();

  @override
  _is.UuidValue? id;

  /// Stable identifier used for idempotent catalog seeding.
  String slug;

  /// Institution display name.
  String name;

  /// Optional homepage domain for discovery/search.
  String? website;

  /// Optional Plaid institution id, when known.
  String? plaidInstitutionId;

  /// Marks digital-first challengers (e.g., Monzo, Revolut, Wise).
  bool isDigitalBank;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Institution copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? slug,
    String? name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Institution',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (website != null) 'website': website,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      'isDigitalBank': isDigitalBank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Institution',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (website != null) 'website': website,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      'isDigitalBank': isDigitalBank,
      'createdAt': createdAt.toJson(),
    };
  }

  static InstitutionInclude include() {
    return InstitutionInclude._();
  }

  static InstitutionIncludeList includeList({
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    InstitutionInclude? include,
  }) {
    return InstitutionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionImpl extends Institution {
  _InstitutionImpl({
    _is.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         slug: slug,
         name: name,
         website: website,
         plaidInstitutionId: plaidInstitutionId,
         isDigitalBank: isDigitalBank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Institution copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? slug,
    String? name,
    Object? website = _Undefined,
    Object? plaidInstitutionId = _Undefined,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) {
    return Institution(
      id: id is _is.UndefinedSentinel ? this.id : id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      website: website is String? ? website : this.website,
      plaidInstitutionId: plaidInstitutionId is String?
          ? plaidInstitutionId
          : this.plaidInstitutionId,
      isDigitalBank: isDigitalBank ?? this.isDigitalBank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InstitutionUpdateTable extends _is.UpdateTable<InstitutionTable> {
  InstitutionUpdateTable(super.table);

  _is.ColumnValue<String, String> slug(String value) => _is.ColumnValue(
    table.slug,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> website(String? value) => _is.ColumnValue(
    table.website,
    value,
  );

  _is.ColumnValue<String, String> plaidInstitutionId(String? value) =>
      _is.ColumnValue(
        table.plaidInstitutionId,
        value,
      );

  _is.ColumnValue<bool, bool> isDigitalBank(bool value) => _is.ColumnValue(
    table.isDigitalBank,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class InstitutionTable extends _is.Table<_is.UuidValue?> {
  InstitutionTable({super.tableRelation}) : super(tableName: 'institution') {
    updateTable = InstitutionUpdateTable(this);
    slug = _is.ColumnString(
      'slug',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    website = _is.ColumnString(
      'website',
      this,
    );
    plaidInstitutionId = _is.ColumnString(
      'plaidInstitutionId',
      this,
    );
    isDigitalBank = _is.ColumnBool(
      'isDigitalBank',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final InstitutionUpdateTable updateTable;

  /// Stable identifier used for idempotent catalog seeding.
  late final _is.ColumnString slug;

  /// Institution display name.
  late final _is.ColumnString name;

  /// Optional homepage domain for discovery/search.
  late final _is.ColumnString website;

  /// Optional Plaid institution id, when known.
  late final _is.ColumnString plaidInstitutionId;

  /// Marks digital-first challengers (e.g., Monzo, Revolut, Wise).
  late final _is.ColumnBool isDigitalBank;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    slug,
    name,
    website,
    plaidInstitutionId,
    isDigitalBank,
    createdAt,
  ];
}

class InstitutionInclude extends _is.IncludeObject {
  InstitutionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Institution.t;
}

class InstitutionIncludeList extends _is.IncludeList {
  InstitutionIncludeList._({
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Institution.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Institution.t;
}

class InstitutionRepository {
  const InstitutionRepository._();

  /// Returns a list of [Institution]s matching the given query parameters.
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
  Future<List<Institution>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Institution>(
      where: where?.call(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Institution]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Institution.t`.
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
  _ida.Stream<List<Institution>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Institution>(
      where: where?.call(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Institution] matching the given query parameters.
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
  Future<Institution?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    int? offset,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Institution>(
      where: where?.call(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Institution] by its [id] or null if no such row exists.
  Future<Institution?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Institution>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Institution]s in the list and returns the inserted rows.
  ///
  /// The returned [Institution]s will have their `id` fields set.
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
  Future<List<Institution>> insert(
    _is.DatabaseSession session,
    List<Institution> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Institution>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Institution] and returns the inserted row.
  ///
  /// The returned [Institution] will have its `id` field set.
  Future<Institution> insertRow(
    _is.DatabaseSession session,
    Institution row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Institution>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Institution]s in the list and returns the resulting rows.
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
  /// The returned [Institution]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Institution>> upsert(
    _is.DatabaseSession session,
    List<Institution> rows, {
    required _is.ColumnSelections<InstitutionTable> conflictColumns,
    _is.ColumnSelections<InstitutionTable>? updateColumns,
    _is.WhereExpressionBuilder<InstitutionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Institution>(
      rows,
      conflictColumns: conflictColumns(Institution.t),
      updateColumns: updateColumns?.call(Institution.t),
      updateWhere: updateWhere?.call(Institution.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Institution] and returns the resulting row.
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
  /// The returned [Institution] will have its `id` field set.
  Future<Institution?> upsertRow(
    _is.DatabaseSession session,
    Institution row, {
    required _is.ColumnSelections<InstitutionTable> conflictColumns,
    _is.ColumnSelections<InstitutionTable>? updateColumns,
    _is.WhereExpressionBuilder<InstitutionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Institution>(
      row,
      conflictColumns: conflictColumns(Institution.t),
      updateColumns: updateColumns?.call(Institution.t),
      updateWhere: updateWhere?.call(Institution.t),
      transaction: transaction,
    );
  }

  /// Updates all [Institution]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Institution>> update(
    _is.DatabaseSession session,
    List<Institution> rows, {
    _is.ColumnSelections<InstitutionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Institution>(
      rows,
      columns: columns?.call(Institution.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Institution]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Institution> updateRow(
    _is.DatabaseSession session,
    Institution row, {
    _is.ColumnSelections<InstitutionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Institution>(
      row,
      columns: columns?.call(Institution.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Institution] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Institution?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<InstitutionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Institution>(
      id,
      columnValues: columnValues(Institution.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Institution]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Institution>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InstitutionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<InstitutionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Institution>(
      columnValues: columnValues(Institution.t.updateTable),
      where: where(Institution.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Institution]s in the list and returns the deleted rows.
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
  Future<List<Institution>> delete(
    _is.DatabaseSession session,
    List<Institution> rows, {
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Institution>(
      rows,
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Institution].
  Future<Institution> deleteRow(
    _is.DatabaseSession session,
    Institution row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Institution>(
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
  Future<List<Institution>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InstitutionTable> where,
    _is.OrderByBuilder<InstitutionTable>? orderBy,
    _is.OrderByListBuilder<InstitutionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Institution>(
      where: where(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Institution>(
      where: where?.call(Institution.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Institution] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InstitutionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Institution>(
      where: where(Institution.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
