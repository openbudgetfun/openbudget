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

/// A journal in a budget's books: a dated, referenced bundle of lines.
///
/// Drafts may be edited or deleted. Posted journals are immutable —
/// corrections are [Journal]s with `reversalOfJournalId` pointing back, and
/// the original flips to `reversed`. No update or delete path exists for
/// posted rows.
abstract class Journal
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Journal._({
    this.id,
    required this.budgetId,
    required this.date,
    String? reference,
    this.narration,
    String? status,
    String? source,
    this.postedAt,
    this.postedBy,
    this.reversalOfJournalId,
    DateTime? createdAt,
  }) : reference = reference ?? '',
       status = status ?? 'draft',
       source = source ?? 'manual',
       createdAt = createdAt ?? DateTime.now();

  factory Journal({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required DateTime date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt,
    _is.UuidValue? postedBy,
    _is.UuidValue? reversalOfJournalId,
    DateTime? createdAt,
  }) = _JournalImpl;

  factory Journal.fromJson(Map<String, dynamic> jsonSerialization) {
    return Journal(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      reference: jsonSerialization['reference'] as String?,
      narration: jsonSerialization['narration'] as String?,
      status: jsonSerialization['status'] as String?,
      source: jsonSerialization['source'] as String?,
      postedAt: jsonSerialization['postedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['postedAt']),
      postedBy: jsonSerialization['postedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['postedBy']),
      reversalOfJournalId: jsonSerialization['reversalOfJournalId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['reversalOfJournalId'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = JournalTable();

  static const db = JournalRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue budgetId;

  /// Calendar date in the budget's time zone, not a UTC instant.
  DateTime date;

  /// Human reference, such as `JB-2026-0001`.
  String reference;

  /// Optional narrative.
  String? narration;

  /// JournalStatus name: draft, posted or reversed.
  String status;

  /// JournalSource name: manual, opening, import or reversal.
  String source;

  /// Server time of posting. Never trusted from the client.
  DateTime? postedAt;

  /// The user who posted the journal.
  _is.UuidValue? postedBy;

  /// The posted journal this one reverses, when source is `reversal`.
  _is.UuidValue? reversalOfJournalId;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Journal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Journal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    DateTime? date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? postedBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? reversalOfJournalId = const _is.$UndefinedUuidValue(),
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Journal',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status,
      'source': source,
      if (postedAt != null) 'postedAt': postedAt?.toJson(),
      if (postedBy != null) 'postedBy': postedBy?.toJson(),
      if (reversalOfJournalId != null)
        'reversalOfJournalId': reversalOfJournalId?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Journal',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'date': date.toJson(),
      'reference': reference,
      if (narration != null) 'narration': narration,
      'status': status,
      'source': source,
      if (postedAt != null) 'postedAt': postedAt?.toJson(),
      if (postedBy != null) 'postedBy': postedBy?.toJson(),
      if (reversalOfJournalId != null)
        'reversalOfJournalId': reversalOfJournalId?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static JournalInclude include() {
    return JournalInclude._();
  }

  static JournalIncludeList includeList({
    _is.WhereExpressionBuilder<JournalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    JournalInclude? include,
  }) {
    return JournalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalImpl extends Journal {
  _JournalImpl({
    _is.UuidValue? id,
    required _is.UuidValue budgetId,
    required DateTime date,
    String? reference,
    String? narration,
    String? status,
    String? source,
    DateTime? postedAt,
    _is.UuidValue? postedBy,
    _is.UuidValue? reversalOfJournalId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         date: date,
         reference: reference,
         narration: narration,
         status: status,
         source: source,
         postedAt: postedAt,
         postedBy: postedBy,
         reversalOfJournalId: reversalOfJournalId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Journal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Journal copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    DateTime? date,
    String? reference,
    Object? narration = _Undefined,
    String? status,
    String? source,
    DateTime? postedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? postedBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? reversalOfJournalId = const _is.$UndefinedUuidValue(),
    DateTime? createdAt,
  }) {
    return Journal(
      id: id is _is.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      narration: narration is String? ? narration : this.narration,
      status: status ?? this.status,
      source: source ?? this.source,
      postedAt: postedAt is _is.UndefinedSentinel ? this.postedAt : postedAt,
      postedBy: postedBy is _is.UndefinedSentinel ? this.postedBy : postedBy,
      reversalOfJournalId: reversalOfJournalId is _is.UndefinedSentinel
          ? this.reversalOfJournalId
          : reversalOfJournalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class JournalUpdateTable extends _is.UpdateTable<JournalTable> {
  JournalUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> date(DateTime value) => _is.ColumnValue(
    table.date,
    value,
  );

  _is.ColumnValue<String, String> reference(String value) => _is.ColumnValue(
    table.reference,
    value,
  );

  _is.ColumnValue<String, String> narration(String? value) => _is.ColumnValue(
    table.narration,
    value,
  );

  _is.ColumnValue<String, String> status(String value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> postedAt(DateTime? value) =>
      _is.ColumnValue(
        table.postedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> postedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.postedBy,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reversalOfJournalId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.reversalOfJournalId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class JournalTable extends _is.Table<_is.UuidValue?> {
  JournalTable({super.tableRelation}) : super(tableName: 'journal') {
    updateTable = JournalUpdateTable(this);
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    date = _is.ColumnDateTime(
      'date',
      this,
    );
    reference = _is.ColumnString(
      'reference',
      this,
      hasDefault: true,
    );
    narration = _is.ColumnString(
      'narration',
      this,
    );
    status = _is.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    source = _is.ColumnString(
      'source',
      this,
      hasDefault: true,
    );
    postedAt = _is.ColumnDateTime(
      'postedAt',
      this,
    );
    postedBy = _is.ColumnUuid(
      'postedBy',
      this,
    );
    reversalOfJournalId = _is.ColumnUuid(
      'reversalOfJournalId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final JournalUpdateTable updateTable;

  late final _is.ColumnUuid budgetId;

  /// Calendar date in the budget's time zone, not a UTC instant.
  late final _is.ColumnDateTime date;

  /// Human reference, such as `JB-2026-0001`.
  late final _is.ColumnString reference;

  /// Optional narrative.
  late final _is.ColumnString narration;

  /// JournalStatus name: draft, posted or reversed.
  late final _is.ColumnString status;

  /// JournalSource name: manual, opening, import or reversal.
  late final _is.ColumnString source;

  /// Server time of posting. Never trusted from the client.
  late final _is.ColumnDateTime postedAt;

  /// The user who posted the journal.
  late final _is.ColumnUuid postedBy;

  /// The posted journal this one reverses, when source is `reversal`.
  late final _is.ColumnUuid reversalOfJournalId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    budgetId,
    date,
    reference,
    narration,
    status,
    source,
    postedAt,
    postedBy,
    reversalOfJournalId,
    createdAt,
  ];
}

class JournalInclude extends _is.IncludeObject {
  JournalInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Journal.t;
}

class JournalIncludeList extends _is.IncludeList {
  JournalIncludeList._({
    _is.WhereExpressionBuilder<JournalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Journal.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Journal.t;
}

class JournalRepository {
  const JournalRepository._();

  /// Returns a list of [Journal]s matching the given query parameters.
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
  Future<List<Journal>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Journal>(
      where: where?.call(Journal.t),
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Journal]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Journal.t`.
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
  _ida.Stream<List<Journal>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Journal>(
      where: where?.call(Journal.t),
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Journal] matching the given query parameters.
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
  Future<Journal?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalTable>? where,
    int? offset,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Journal>(
      where: where?.call(Journal.t),
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Journal] by its [id] or null if no such row exists.
  Future<Journal?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Journal>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Journal]s in the list and returns the inserted rows.
  ///
  /// The returned [Journal]s will have their `id` fields set.
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
  Future<List<Journal>> insert(
    _is.DatabaseSession session,
    List<Journal> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Journal>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Journal] and returns the inserted row.
  ///
  /// The returned [Journal] will have its `id` field set.
  Future<Journal> insertRow(
    _is.DatabaseSession session,
    Journal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Journal>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Journal]s in the list and returns the resulting rows.
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
  /// The returned [Journal]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Journal>> upsert(
    _is.DatabaseSession session,
    List<Journal> rows, {
    required _is.ColumnSelections<JournalTable> conflictColumns,
    _is.ColumnSelections<JournalTable>? updateColumns,
    _is.WhereExpressionBuilder<JournalTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Journal>(
      rows,
      conflictColumns: conflictColumns(Journal.t),
      updateColumns: updateColumns?.call(Journal.t),
      updateWhere: updateWhere?.call(Journal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Journal] and returns the resulting row.
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
  /// The returned [Journal] will have its `id` field set.
  Future<Journal?> upsertRow(
    _is.DatabaseSession session,
    Journal row, {
    required _is.ColumnSelections<JournalTable> conflictColumns,
    _is.ColumnSelections<JournalTable>? updateColumns,
    _is.WhereExpressionBuilder<JournalTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Journal>(
      row,
      conflictColumns: conflictColumns(Journal.t),
      updateColumns: updateColumns?.call(Journal.t),
      updateWhere: updateWhere?.call(Journal.t),
      transaction: transaction,
    );
  }

  /// Updates all [Journal]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Journal>> update(
    _is.DatabaseSession session,
    List<Journal> rows, {
    _is.ColumnSelections<JournalTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Journal>(
      rows,
      columns: columns?.call(Journal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Journal]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Journal> updateRow(
    _is.DatabaseSession session,
    Journal row, {
    _is.ColumnSelections<JournalTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Journal>(
      row,
      columns: columns?.call(Journal.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Journal] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Journal?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<JournalUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Journal>(
      id,
      columnValues: columnValues(Journal.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Journal]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Journal>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<JournalUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<JournalTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Journal>(
      columnValues: columnValues(Journal.t.updateTable),
      where: where(Journal.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Journal]s in the list and returns the deleted rows.
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
  Future<List<Journal>> delete(
    _is.DatabaseSession session,
    List<Journal> rows, {
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Journal>(
      rows,
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Journal].
  Future<Journal> deleteRow(
    _is.DatabaseSession session,
    Journal row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Journal>(
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
  Future<List<Journal>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JournalTable> where,
    _is.OrderByBuilder<JournalTable>? orderBy,
    _is.OrderByListBuilder<JournalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Journal>(
      where: where(Journal.t),
      orderBy: orderBy?.call(Journal.t),
      orderByList: orderByList?.call(Journal.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Journal>(
      where: where?.call(Journal.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Journal] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JournalTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Journal>(
      where: where(Journal.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
