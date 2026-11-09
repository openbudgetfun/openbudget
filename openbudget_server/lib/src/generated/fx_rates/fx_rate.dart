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

import '../fx_rates/fx_provider.dart' as _i6j6w2ot;

/// One currency's daily rate against USD, the provider's base.
abstract class FxRate
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  FxRate._({
    this.id,
    required this.rateDate,
    required this.currencyCode,
    required this.rate,
    required this.provider,
    required this.fetchedAt,
  });

  factory FxRate({
    _is.UuidValue? id,
    required DateTime rateDate,
    required String currencyCode,
    required String rate,
    required _i6j6w2ot.FxProvider provider,
    required DateTime fetchedAt,
  }) = _FxRateImpl;

  factory FxRate.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxRate(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      rateDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['rateDate'],
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      rate: jsonSerialization['rate'] as String,
      provider: _i6j6w2ot.FxProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      fetchedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  static final t = FxRateTable();

  static const db = FxRateRepository._();

  @override
  _is.UuidValue? id;

  /// Calendar date (UTC) the rate is for.
  DateTime rateDate;

  /// ISO 4217 code.
  String currencyCode;

  /// Units of currencyCode per 1 USD, exact decimal string.
  String rate;

  _i6j6w2ot.FxProvider provider;

  /// Last time the provider was asked for this day's rate.
  DateTime fetchedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [FxRate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FxRate copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    DateTime? rateDate,
    String? currencyCode,
    String? rate,
    _i6j6w2ot.FxProvider? provider,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxRate',
      if (id != null) 'id': id?.toJson(),
      'rateDate': rateDate.toJson(),
      'currencyCode': currencyCode,
      'rate': rate,
      'provider': provider.toJson(),
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static FxRateInclude include() {
    return FxRateInclude._();
  }

  static FxRateIncludeList includeList({
    _is.WhereExpressionBuilder<FxRateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    FxRateInclude? include,
  }) {
    return FxRateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _FxRateImpl extends FxRate {
  _FxRateImpl({
    _is.UuidValue? id,
    required DateTime rateDate,
    required String currencyCode,
    required String rate,
    required _i6j6w2ot.FxProvider provider,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         rateDate: rateDate,
         currencyCode: currencyCode,
         rate: rate,
         provider: provider,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [FxRate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FxRate copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    DateTime? rateDate,
    String? currencyCode,
    String? rate,
    _i6j6w2ot.FxProvider? provider,
    DateTime? fetchedAt,
  }) {
    return FxRate(
      id: id is _is.UndefinedSentinel ? this.id : id,
      rateDate: rateDate ?? this.rateDate,
      currencyCode: currencyCode ?? this.currencyCode,
      rate: rate ?? this.rate,
      provider: provider ?? this.provider,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

class FxRateUpdateTable extends _is.UpdateTable<FxRateTable> {
  FxRateUpdateTable(super.table);

  _is.ColumnValue<DateTime, DateTime> rateDate(DateTime value) =>
      _is.ColumnValue(
        table.rateDate,
        value,
      );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<String, String> rate(String value) => _is.ColumnValue(
    table.rate,
    value,
  );

  _is.ColumnValue<_i6j6w2ot.FxProvider, _i6j6w2ot.FxProvider> provider(
    _i6j6w2ot.FxProvider value,
  ) => _is.ColumnValue(
    table.provider,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _is.ColumnValue(
        table.fetchedAt,
        value,
      );
}

class FxRateTable extends _is.Table<_is.UuidValue?> {
  FxRateTable({super.tableRelation}) : super(tableName: 'fx_rate') {
    updateTable = FxRateUpdateTable(this);
    rateDate = _is.ColumnDateTime(
      'rateDate',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    rate = _is.ColumnString(
      'rate',
      this,
    );
    provider = _is.ColumnEnum(
      'provider',
      this,
      _is.EnumSerialization.byName,
    );
    fetchedAt = _is.ColumnDateTime(
      'fetchedAt',
      this,
    );
  }

  late final FxRateUpdateTable updateTable;

  /// Calendar date (UTC) the rate is for.
  late final _is.ColumnDateTime rateDate;

  /// ISO 4217 code.
  late final _is.ColumnString currencyCode;

  /// Units of currencyCode per 1 USD, exact decimal string.
  late final _is.ColumnString rate;

  late final _is.ColumnEnum<_i6j6w2ot.FxProvider> provider;

  /// Last time the provider was asked for this day's rate.
  late final _is.ColumnDateTime fetchedAt;

  @override
  List<_is.Column> get columns => [
    id,
    rateDate,
    currencyCode,
    rate,
    provider,
    fetchedAt,
  ];
}

class FxRateInclude extends _is.IncludeObject {
  FxRateInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRate.t;
}

class FxRateIncludeList extends _is.IncludeList {
  FxRateIncludeList._({
    _is.WhereExpressionBuilder<FxRateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxRate.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => FxRate.t;
}

class FxRateRepository {
  const FxRateRepository._();

  /// Returns a list of [FxRate]s matching the given query parameters.
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
  Future<List<FxRate>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FxRate>(
      where: where?.call(FxRate.t),
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [FxRate]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `FxRate.t`.
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
  _ida.Stream<List<FxRate>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<FxRate>(
      where: where?.call(FxRate.t),
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [FxRate] matching the given query parameters.
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
  Future<FxRate?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateTable>? where,
    int? offset,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FxRate>(
      where: where?.call(FxRate.t),
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FxRate] by its [id] or null if no such row exists.
  Future<FxRate?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FxRate>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FxRate]s in the list and returns the inserted rows.
  ///
  /// The returned [FxRate]s will have their `id` fields set.
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
  Future<List<FxRate>> insert(
    _is.DatabaseSession session,
    List<FxRate> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FxRate>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FxRate] and returns the inserted row.
  ///
  /// The returned [FxRate] will have its `id` field set.
  Future<FxRate> insertRow(
    _is.DatabaseSession session,
    FxRate row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxRate>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FxRate]s in the list and returns the resulting rows.
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
  /// The returned [FxRate]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRate>> upsert(
    _is.DatabaseSession session,
    List<FxRate> rows, {
    required _is.ColumnSelections<FxRateTable> conflictColumns,
    _is.ColumnSelections<FxRateTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FxRate>(
      rows,
      conflictColumns: conflictColumns(FxRate.t),
      updateColumns: updateColumns?.call(FxRate.t),
      updateWhere: updateWhere?.call(FxRate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FxRate] and returns the resulting row.
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
  /// The returned [FxRate] will have its `id` field set.
  Future<FxRate?> upsertRow(
    _is.DatabaseSession session,
    FxRate row, {
    required _is.ColumnSelections<FxRateTable> conflictColumns,
    _is.ColumnSelections<FxRateTable>? updateColumns,
    _is.WhereExpressionBuilder<FxRateTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FxRate>(
      row,
      conflictColumns: conflictColumns(FxRate.t),
      updateColumns: updateColumns?.call(FxRate.t),
      updateWhere: updateWhere?.call(FxRate.t),
      transaction: transaction,
    );
  }

  /// Updates all [FxRate]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRate>> update(
    _is.DatabaseSession session,
    List<FxRate> rows, {
    _is.ColumnSelections<FxRateTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FxRate>(
      rows,
      columns: columns?.call(FxRate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FxRate]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxRate> updateRow(
    _is.DatabaseSession session,
    FxRate row, {
    _is.ColumnSelections<FxRateTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxRate>(
      row,
      columns: columns?.call(FxRate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxRate] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxRate?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<FxRateUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FxRate>(
      id,
      columnValues: columnValues(FxRate.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxRate]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FxRate>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FxRateUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FxRateTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FxRate>(
      columnValues: columnValues(FxRate.t.updateTable),
      where: where(FxRate.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FxRate]s in the list and returns the deleted rows.
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
  Future<List<FxRate>> delete(
    _is.DatabaseSession session,
    List<FxRate> rows, {
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FxRate>(
      rows,
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FxRate].
  Future<FxRate> deleteRow(
    _is.DatabaseSession session,
    FxRate row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxRate>(
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
  Future<List<FxRate>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateTable> where,
    _is.OrderByBuilder<FxRateTable>? orderBy,
    _is.OrderByListBuilder<FxRateTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FxRate>(
      where: where(FxRate.t),
      orderBy: orderBy?.call(FxRate.t),
      orderByList: orderByList?.call(FxRate.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FxRateTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FxRate>(
      where: where?.call(FxRate.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FxRate] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FxRateTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FxRate>(
      where: where(FxRate.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
