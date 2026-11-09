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

/// One allocation of a transaction to an envelope, a ledger account and a
/// tax treatment. A transaction has one or more lines that sum exactly to it.
abstract class TransactionLine
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  TransactionLine._({
    this.id,
    required this.transactionId,
    required this.amountMinor,
    required this.baseAmountMinor,
    this.envelopeId,
    this.ledgerAccountId,
    this.taxCategoryCode,
    this.businessUsePercent,
    this.salesTaxMinor,
    this.memo,
    int? sortOrder,
  }) : sortOrder = sortOrder ?? 0;

  factory TransactionLine({
    _is.UuidValue? id,
    required _is.UuidValue transactionId,
    required int amountMinor,
    required int baseAmountMinor,
    _is.UuidValue? envelopeId,
    _is.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  }) = _TransactionLineImpl;

  factory TransactionLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionLine(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      transactionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['transactionId'],
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      baseAmountMinor: jsonSerialization['baseAmountMinor'] as int,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      ledgerAccountId: jsonSerialization['ledgerAccountId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['ledgerAccountId'],
            ),
      taxCategoryCode: jsonSerialization['taxCategoryCode'] as String?,
      businessUsePercent: jsonSerialization['businessUsePercent'] as int?,
      salesTaxMinor: jsonSerialization['salesTaxMinor'] as int?,
      memo: jsonSerialization['memo'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
    );
  }

  static final t = TransactionLineTable();

  static const db = TransactionLineRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue transactionId;

  /// Part of the transaction amount, account-currency minor units, signed.
  int amountMinor;

  /// Part of the base amount, base-currency minor units, signed.
  int baseAmountMinor;

  /// Null on an on-budget account means Ready to Assign (inflow) or
  /// uncategorised (outflow). Always null on off-budget accounts.
  _is.UuidValue? envelopeId;

  /// Coding in ledger-mode books; null posts to the suspense account.
  _is.UuidValue? ledgerAccountId;

  /// Tax category code; overrides the envelope's default when set.
  String? taxCategoryCode;

  /// Share of the line used for business, 0-100.
  int? businessUsePercent;

  /// Sales tax included in amountMinor, account-currency minor units.
  int? salesTaxMinor;

  String? memo;

  int sortOrder;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [TransactionLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TransactionLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? transactionId,
    int? amountMinor,
    int? baseAmountMinor,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TransactionLine',
      if (id != null) 'id': id?.toJson(),
      'transactionId': transactionId.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TransactionLine',
      if (id != null) 'id': id?.toJson(),
      'transactionId': transactionId.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (taxCategoryCode != null) 'taxCategoryCode': taxCategoryCode,
      if (businessUsePercent != null) 'businessUsePercent': businessUsePercent,
      if (salesTaxMinor != null) 'salesTaxMinor': salesTaxMinor,
      if (memo != null) 'memo': memo,
      'sortOrder': sortOrder,
    };
  }

  static TransactionLineInclude include() {
    return TransactionLineInclude._();
  }

  static TransactionLineIncludeList includeList({
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    TransactionLineInclude? include,
  }) {
    return TransactionLineIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionLineImpl extends TransactionLine {
  _TransactionLineImpl({
    _is.UuidValue? id,
    required _is.UuidValue transactionId,
    required int amountMinor,
    required int baseAmountMinor,
    _is.UuidValue? envelopeId,
    _is.UuidValue? ledgerAccountId,
    String? taxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
    String? memo,
    int? sortOrder,
  }) : super._(
         id: id,
         transactionId: transactionId,
         amountMinor: amountMinor,
         baseAmountMinor: baseAmountMinor,
         envelopeId: envelopeId,
         ledgerAccountId: ledgerAccountId,
         taxCategoryCode: taxCategoryCode,
         businessUsePercent: businessUsePercent,
         salesTaxMinor: salesTaxMinor,
         memo: memo,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [TransactionLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TransactionLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? transactionId,
    int? amountMinor,
    int? baseAmountMinor,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    Object? taxCategoryCode = _Undefined,
    Object? businessUsePercent = _Undefined,
    Object? salesTaxMinor = _Undefined,
    Object? memo = _Undefined,
    int? sortOrder,
  }) {
    return TransactionLine(
      id: id is _is.UndefinedSentinel ? this.id : id,
      transactionId: transactionId ?? this.transactionId,
      amountMinor: amountMinor ?? this.amountMinor,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      envelopeId: envelopeId is _is.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      ledgerAccountId: ledgerAccountId is _is.UndefinedSentinel
          ? this.ledgerAccountId
          : ledgerAccountId,
      taxCategoryCode: taxCategoryCode is String?
          ? taxCategoryCode
          : this.taxCategoryCode,
      businessUsePercent: businessUsePercent is int?
          ? businessUsePercent
          : this.businessUsePercent,
      salesTaxMinor: salesTaxMinor is int? ? salesTaxMinor : this.salesTaxMinor,
      memo: memo is String? ? memo : this.memo,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class TransactionLineUpdateTable extends _is.UpdateTable<TransactionLineTable> {
  TransactionLineUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> transactionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.transactionId,
    value,
  );

  _is.ColumnValue<int, int> amountMinor(int value) => _is.ColumnValue(
    table.amountMinor,
    value,
  );

  _is.ColumnValue<int, int> baseAmountMinor(int value) => _is.ColumnValue(
    table.baseAmountMinor,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> envelopeId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.envelopeId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ledgerAccountId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.ledgerAccountId,
    value,
  );

  _is.ColumnValue<String, String> taxCategoryCode(String? value) =>
      _is.ColumnValue(
        table.taxCategoryCode,
        value,
      );

  _is.ColumnValue<int, int> businessUsePercent(int? value) => _is.ColumnValue(
    table.businessUsePercent,
    value,
  );

  _is.ColumnValue<int, int> salesTaxMinor(int? value) => _is.ColumnValue(
    table.salesTaxMinor,
    value,
  );

  _is.ColumnValue<String, String> memo(String? value) => _is.ColumnValue(
    table.memo,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );
}

class TransactionLineTable extends _is.Table<_is.UuidValue?> {
  TransactionLineTable({super.tableRelation})
    : super(tableName: 'transaction_line') {
    updateTable = TransactionLineUpdateTable(this);
    transactionId = _is.ColumnUuid(
      'transactionId',
      this,
    );
    amountMinor = _is.ColumnInt(
      'amountMinor',
      this,
    );
    baseAmountMinor = _is.ColumnInt(
      'baseAmountMinor',
      this,
    );
    envelopeId = _is.ColumnUuid(
      'envelopeId',
      this,
    );
    ledgerAccountId = _is.ColumnUuid(
      'ledgerAccountId',
      this,
    );
    taxCategoryCode = _is.ColumnString(
      'taxCategoryCode',
      this,
    );
    businessUsePercent = _is.ColumnInt(
      'businessUsePercent',
      this,
    );
    salesTaxMinor = _is.ColumnInt(
      'salesTaxMinor',
      this,
    );
    memo = _is.ColumnString(
      'memo',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
      hasDefault: true,
    );
  }

  late final TransactionLineUpdateTable updateTable;

  late final _is.ColumnUuid transactionId;

  /// Part of the transaction amount, account-currency minor units, signed.
  late final _is.ColumnInt amountMinor;

  /// Part of the base amount, base-currency minor units, signed.
  late final _is.ColumnInt baseAmountMinor;

  /// Null on an on-budget account means Ready to Assign (inflow) or
  /// uncategorised (outflow). Always null on off-budget accounts.
  late final _is.ColumnUuid envelopeId;

  /// Coding in ledger-mode books; null posts to the suspense account.
  late final _is.ColumnUuid ledgerAccountId;

  /// Tax category code; overrides the envelope's default when set.
  late final _is.ColumnString taxCategoryCode;

  /// Share of the line used for business, 0-100.
  late final _is.ColumnInt businessUsePercent;

  /// Sales tax included in amountMinor, account-currency minor units.
  late final _is.ColumnInt salesTaxMinor;

  late final _is.ColumnString memo;

  late final _is.ColumnInt sortOrder;

  @override
  List<_is.Column> get columns => [
    id,
    transactionId,
    amountMinor,
    baseAmountMinor,
    envelopeId,
    ledgerAccountId,
    taxCategoryCode,
    businessUsePercent,
    salesTaxMinor,
    memo,
    sortOrder,
  ];
}

class TransactionLineInclude extends _is.IncludeObject {
  TransactionLineInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => TransactionLine.t;
}

class TransactionLineIncludeList extends _is.IncludeList {
  TransactionLineIncludeList._({
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionLine.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => TransactionLine.t;
}

class TransactionLineRepository {
  const TransactionLineRepository._();

  /// Returns a list of [TransactionLine]s matching the given query parameters.
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
  Future<List<TransactionLine>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TransactionLine>(
      where: where?.call(TransactionLine.t),
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [TransactionLine]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `TransactionLine.t`.
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
  _ida.Stream<List<TransactionLine>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<TransactionLine>(
      where: where?.call(TransactionLine.t),
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [TransactionLine] matching the given query parameters.
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
  Future<TransactionLine?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    int? offset,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TransactionLine>(
      where: where?.call(TransactionLine.t),
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TransactionLine] by its [id] or null if no such row exists.
  Future<TransactionLine?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TransactionLine>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TransactionLine]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionLine]s will have their `id` fields set.
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
  Future<List<TransactionLine>> insert(
    _is.DatabaseSession session,
    List<TransactionLine> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TransactionLine>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TransactionLine] and returns the inserted row.
  ///
  /// The returned [TransactionLine] will have its `id` field set.
  Future<TransactionLine> insertRow(
    _is.DatabaseSession session,
    TransactionLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionLine>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TransactionLine]s in the list and returns the resulting rows.
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
  /// The returned [TransactionLine]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionLine>> upsert(
    _is.DatabaseSession session,
    List<TransactionLine> rows, {
    required _is.ColumnSelections<TransactionLineTable> conflictColumns,
    _is.ColumnSelections<TransactionLineTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionLineTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TransactionLine>(
      rows,
      conflictColumns: conflictColumns(TransactionLine.t),
      updateColumns: updateColumns?.call(TransactionLine.t),
      updateWhere: updateWhere?.call(TransactionLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TransactionLine] and returns the resulting row.
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
  /// The returned [TransactionLine] will have its `id` field set.
  Future<TransactionLine?> upsertRow(
    _is.DatabaseSession session,
    TransactionLine row, {
    required _is.ColumnSelections<TransactionLineTable> conflictColumns,
    _is.ColumnSelections<TransactionLineTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionLineTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TransactionLine>(
      row,
      conflictColumns: conflictColumns(TransactionLine.t),
      updateColumns: updateColumns?.call(TransactionLine.t),
      updateWhere: updateWhere?.call(TransactionLine.t),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionLine]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionLine>> update(
    _is.DatabaseSession session,
    List<TransactionLine> rows, {
    _is.ColumnSelections<TransactionLineTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TransactionLine>(
      rows,
      columns: columns?.call(TransactionLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TransactionLine]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionLine> updateRow(
    _is.DatabaseSession session,
    TransactionLine row, {
    _is.ColumnSelections<TransactionLineTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TransactionLine>(
      row,
      columns: columns?.call(TransactionLine.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionLine] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TransactionLine?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TransactionLineUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TransactionLine>(
      id,
      columnValues: columnValues(TransactionLine.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TransactionLine]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TransactionLine>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TransactionLineUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<TransactionLineTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TransactionLine>(
      columnValues: columnValues(TransactionLine.t.updateTable),
      where: where(TransactionLine.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TransactionLine]s in the list and returns the deleted rows.
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
  Future<List<TransactionLine>> delete(
    _is.DatabaseSession session,
    List<TransactionLine> rows, {
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TransactionLine>(
      rows,
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TransactionLine].
  Future<TransactionLine> deleteRow(
    _is.DatabaseSession session,
    TransactionLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionLine>(
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
  Future<List<TransactionLine>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionLineTable> where,
    _is.OrderByBuilder<TransactionLineTable>? orderBy,
    _is.OrderByListBuilder<TransactionLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TransactionLine>(
      where: where(TransactionLine.t),
      orderBy: orderBy?.call(TransactionLine.t),
      orderByList: orderByList?.call(TransactionLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionLineTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TransactionLine>(
      where: where?.call(TransactionLine.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TransactionLine] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionLineTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TransactionLine>(
      where: where(TransactionLine.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
