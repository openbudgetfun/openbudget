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

import '../accounts/valuation_source.dart' as _iglrpvk1;

/// The value of an account from a calendar date onwards, for accounts whose
/// balance comes from valuations (a house, a car, a brokerage, a wallet).
abstract class AccountValuation
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AccountValuation._({
    this.id,
    required this.accountId,
    required this.valuationDate,
    required this.valueMinor,
    required this.source,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory AccountValuation({
    _is.UuidValue? id,
    required _is.UuidValue accountId,
    required DateTime valuationDate,
    required int valueMinor,
    required _iglrpvk1.ValuationSource source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AccountValuationImpl;

  factory AccountValuation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountValuation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      valuationDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['valuationDate'],
      ),
      valueMinor: jsonSerialization['valueMinor'] as int,
      source: _iglrpvk1.ValuationSource.fromJson(
        (jsonSerialization['source'] as String),
      ),
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AccountValuationTable();

  static const db = AccountValuationRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue accountId;

  /// Calendar date the value applies from.
  DateTime valuationDate;

  /// Value in account-currency minor units, signed like Account.balanceMinor.
  int valueMinor;

  _iglrpvk1.ValuationSource source;

  String? note;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AccountValuation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountValuation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? accountId,
    DateTime? valuationDate,
    int? valueMinor,
    _iglrpvk1.ValuationSource? source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountValuation',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'valuationDate': valuationDate.toJson(),
      'valueMinor': valueMinor,
      'source': source.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountValuation',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'valuationDate': valuationDate.toJson(),
      'valueMinor': valueMinor,
      'source': source.toJson(),
      if (note != null) 'note': note,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AccountValuationInclude include() {
    return AccountValuationInclude._();
  }

  static AccountValuationIncludeList includeList({
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    AccountValuationInclude? include,
  }) {
    return AccountValuationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountValuationImpl extends AccountValuation {
  _AccountValuationImpl({
    _is.UuidValue? id,
    required _is.UuidValue accountId,
    required DateTime valuationDate,
    required int valueMinor,
    required _iglrpvk1.ValuationSource source,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         accountId: accountId,
         valuationDate: valuationDate,
         valueMinor: valueMinor,
         source: source,
         note: note,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AccountValuation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountValuation copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? accountId,
    DateTime? valuationDate,
    int? valueMinor,
    _iglrpvk1.ValuationSource? source,
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountValuation(
      id: id is _is.UndefinedSentinel ? this.id : id,
      accountId: accountId ?? this.accountId,
      valuationDate: valuationDate ?? this.valuationDate,
      valueMinor: valueMinor ?? this.valueMinor,
      source: source ?? this.source,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccountValuationUpdateTable
    extends _is.UpdateTable<AccountValuationTable> {
  AccountValuationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.accountId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> valuationDate(DateTime value) =>
      _is.ColumnValue(
        table.valuationDate,
        value,
      );

  _is.ColumnValue<int, int> valueMinor(int value) => _is.ColumnValue(
    table.valueMinor,
    value,
  );

  _is.ColumnValue<_iglrpvk1.ValuationSource, _iglrpvk1.ValuationSource> source(
    _iglrpvk1.ValuationSource value,
  ) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
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

class AccountValuationTable extends _is.Table<_is.UuidValue?> {
  AccountValuationTable({super.tableRelation})
    : super(tableName: 'account_valuation') {
    updateTable = AccountValuationUpdateTable(this);
    accountId = _is.ColumnUuid(
      'accountId',
      this,
    );
    valuationDate = _is.ColumnDateTime(
      'valuationDate',
      this,
    );
    valueMinor = _is.ColumnInt(
      'valueMinor',
      this,
    );
    source = _is.ColumnEnum(
      'source',
      this,
      _is.EnumSerialization.byName,
    );
    note = _is.ColumnString(
      'note',
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

  late final AccountValuationUpdateTable updateTable;

  late final _is.ColumnUuid accountId;

  /// Calendar date the value applies from.
  late final _is.ColumnDateTime valuationDate;

  /// Value in account-currency minor units, signed like Account.balanceMinor.
  late final _is.ColumnInt valueMinor;

  late final _is.ColumnEnum<_iglrpvk1.ValuationSource> source;

  late final _is.ColumnString note;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    accountId,
    valuationDate,
    valueMinor,
    source,
    note,
    createdAt,
    updatedAt,
  ];
}

class AccountValuationInclude extends _is.IncludeObject {
  AccountValuationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AccountValuation.t;
}

class AccountValuationIncludeList extends _is.IncludeList {
  AccountValuationIncludeList._({
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountValuation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AccountValuation.t;
}

class AccountValuationRepository {
  const AccountValuationRepository._();

  /// Returns a list of [AccountValuation]s matching the given query parameters.
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
  Future<List<AccountValuation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountValuation>(
      where: where?.call(AccountValuation.t),
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AccountValuation]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AccountValuation.t`.
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
  _ida.Stream<List<AccountValuation>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AccountValuation>(
      where: where?.call(AccountValuation.t),
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AccountValuation] matching the given query parameters.
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
  Future<AccountValuation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountValuation>(
      where: where?.call(AccountValuation.t),
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountValuation] by its [id] or null if no such row exists.
  Future<AccountValuation?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountValuation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountValuation]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountValuation]s will have their `id` fields set.
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
  Future<List<AccountValuation>> insert(
    _is.DatabaseSession session,
    List<AccountValuation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountValuation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountValuation] and returns the inserted row.
  ///
  /// The returned [AccountValuation] will have its `id` field set.
  Future<AccountValuation> insertRow(
    _is.DatabaseSession session,
    AccountValuation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountValuation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccountValuation]s in the list and returns the resulting rows.
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
  /// The returned [AccountValuation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountValuation>> upsert(
    _is.DatabaseSession session,
    List<AccountValuation> rows, {
    required _is.ColumnSelections<AccountValuationTable> conflictColumns,
    _is.ColumnSelections<AccountValuationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountValuationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountValuation>(
      rows,
      conflictColumns: conflictColumns(AccountValuation.t),
      updateColumns: updateColumns?.call(AccountValuation.t),
      updateWhere: updateWhere?.call(AccountValuation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountValuation] and returns the resulting row.
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
  /// The returned [AccountValuation] will have its `id` field set.
  Future<AccountValuation?> upsertRow(
    _is.DatabaseSession session,
    AccountValuation row, {
    required _is.ColumnSelections<AccountValuationTable> conflictColumns,
    _is.ColumnSelections<AccountValuationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountValuationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountValuation>(
      row,
      conflictColumns: conflictColumns(AccountValuation.t),
      updateColumns: updateColumns?.call(AccountValuation.t),
      updateWhere: updateWhere?.call(AccountValuation.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountValuation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountValuation>> update(
    _is.DatabaseSession session,
    List<AccountValuation> rows, {
    _is.ColumnSelections<AccountValuationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountValuation>(
      rows,
      columns: columns?.call(AccountValuation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountValuation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountValuation> updateRow(
    _is.DatabaseSession session,
    AccountValuation row, {
    _is.ColumnSelections<AccountValuationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountValuation>(
      row,
      columns: columns?.call(AccountValuation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountValuation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountValuation?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AccountValuationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountValuation>(
      id,
      columnValues: columnValues(AccountValuation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountValuation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountValuation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountValuationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccountValuationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountValuation>(
      columnValues: columnValues(AccountValuation.t.updateTable),
      where: where(AccountValuation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountValuation]s in the list and returns the deleted rows.
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
  Future<List<AccountValuation>> delete(
    _is.DatabaseSession session,
    List<AccountValuation> rows, {
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountValuation>(
      rows,
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountValuation].
  Future<AccountValuation> deleteRow(
    _is.DatabaseSession session,
    AccountValuation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountValuation>(
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
  Future<List<AccountValuation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountValuationTable> where,
    _is.OrderByBuilder<AccountValuationTable>? orderBy,
    _is.OrderByListBuilder<AccountValuationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountValuation>(
      where: where(AccountValuation.t),
      orderBy: orderBy?.call(AccountValuation.t),
      orderByList: orderByList?.call(AccountValuation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountValuationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountValuation>(
      where: where?.call(AccountValuation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountValuation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountValuationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountValuation>(
      where: where(AccountValuation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
