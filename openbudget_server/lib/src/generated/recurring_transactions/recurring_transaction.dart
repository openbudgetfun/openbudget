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

/// A recurring/scheduled transaction template that generates transactions on a schedule.
abstract class RecurringTransaction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  RecurringTransaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    this.payeeId,
    required this.frequency,
    required this.nextOccurrence,
    this.endDate,
    required this.isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory RecurringTransaction({
    _is.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _is.UuidValue? envelopeId,
    required _is.UuidValue budgetId,
    _is.UuidValue? accountId,
    _is.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RecurringTransactionImpl;

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RecurringTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      description: jsonSerialization['description'] as String,
      amountCents: jsonSerialization['amountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      envelopeId: jsonSerialization['envelopeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['envelopeId'],
            ),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      accountId: jsonSerialization['accountId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['accountId']),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      frequency: jsonSerialization['frequency'] as String,
      nextOccurrence: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextOccurrence'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endDate']),
      isActive: _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = RecurringTransactionTable();

  static const db = RecurringTransactionRepository._();

  @override
  _is.UuidValue? id;

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _is.UuidValue? envelopeId;

  _is.UuidValue budgetId;

  _is.UuidValue? accountId;

  _is.UuidValue? payeeId;

  /// Recurrence frequency: daily, weekly, biweekly, monthly, yearly.
  String frequency;

  /// The next date a transaction should be created.
  DateTime nextOccurrence;

  /// Optional end date after which no more transactions are generated.
  DateTime? endDate;

  /// Whether this recurring transaction is active.
  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RecurringTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate = const _is.$UndefinedDateTime(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RecurringTransaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'frequency': frequency,
      'nextOccurrence': nextOccurrence.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static RecurringTransactionInclude include() {
    return RecurringTransactionInclude._();
  }

  static RecurringTransactionIncludeList includeList({
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    RecurringTransactionInclude? include,
  }) {
    return RecurringTransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RecurringTransactionImpl extends RecurringTransaction {
  _RecurringTransactionImpl({
    _is.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _is.UuidValue? envelopeId,
    required _is.UuidValue budgetId,
    _is.UuidValue? accountId,
    _is.UuidValue? payeeId,
    required String frequency,
    required DateTime nextOccurrence,
    DateTime? endDate,
    required bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         payeeId: payeeId,
         frequency: frequency,
         nextOccurrence: nextOccurrence,
         endDate: endDate,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RecurringTransaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RecurringTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate = const _is.$UndefinedDateTime(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id is _is.UndefinedSentinel ? this.id : id,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      envelopeId: envelopeId is _is.UndefinedSentinel
          ? this.envelopeId
          : envelopeId,
      budgetId: budgetId ?? this.budgetId,
      accountId: accountId is _is.UndefinedSentinel
          ? this.accountId
          : accountId,
      payeeId: payeeId is _is.UndefinedSentinel ? this.payeeId : payeeId,
      frequency: frequency ?? this.frequency,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
      endDate: endDate is _is.UndefinedSentinel ? this.endDate : endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecurringTransactionUpdateTable
    extends _is.UpdateTable<RecurringTransactionTable> {
  RecurringTransactionUpdateTable(super.table);

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> amountCents(int value) => _is.ColumnValue(
    table.amountCents,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> envelopeId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.envelopeId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.accountId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> payeeId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.payeeId,
        value,
      );

  _is.ColumnValue<String, String> frequency(String value) => _is.ColumnValue(
    table.frequency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextOccurrence(DateTime value) =>
      _is.ColumnValue(
        table.nextOccurrence,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> endDate(DateTime? value) =>
      _is.ColumnValue(
        table.endDate,
        value,
      );

  _is.ColumnValue<bool, bool> isActive(bool value) => _is.ColumnValue(
    table.isActive,
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

class RecurringTransactionTable extends _is.Table<_is.UuidValue?> {
  RecurringTransactionTable({super.tableRelation})
    : super(tableName: 'recurring_transaction') {
    updateTable = RecurringTransactionUpdateTable(this);
    description = _is.ColumnString(
      'description',
      this,
    );
    amountCents = _is.ColumnInt(
      'amountCents',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    envelopeId = _is.ColumnUuid(
      'envelopeId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    accountId = _is.ColumnUuid(
      'accountId',
      this,
    );
    payeeId = _is.ColumnUuid(
      'payeeId',
      this,
    );
    frequency = _is.ColumnString(
      'frequency',
      this,
    );
    nextOccurrence = _is.ColumnDateTime(
      'nextOccurrence',
      this,
    );
    endDate = _is.ColumnDateTime(
      'endDate',
      this,
    );
    isActive = _is.ColumnBool(
      'isActive',
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

  late final RecurringTransactionUpdateTable updateTable;

  late final _is.ColumnString description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  late final _is.ColumnInt amountCents;

  /// ISO 4217 currency code.
  late final _is.ColumnString currencyCode;

  late final _is.ColumnUuid envelopeId;

  late final _is.ColumnUuid budgetId;

  late final _is.ColumnUuid accountId;

  late final _is.ColumnUuid payeeId;

  /// Recurrence frequency: daily, weekly, biweekly, monthly, yearly.
  late final _is.ColumnString frequency;

  /// The next date a transaction should be created.
  late final _is.ColumnDateTime nextOccurrence;

  /// Optional end date after which no more transactions are generated.
  late final _is.ColumnDateTime endDate;

  /// Whether this recurring transaction is active.
  late final _is.ColumnBool isActive;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    description,
    amountCents,
    currencyCode,
    envelopeId,
    budgetId,
    accountId,
    payeeId,
    frequency,
    nextOccurrence,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}

class RecurringTransactionInclude extends _is.IncludeObject {
  RecurringTransactionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => RecurringTransaction.t;
}

class RecurringTransactionIncludeList extends _is.IncludeList {
  RecurringTransactionIncludeList._({
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RecurringTransaction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => RecurringTransaction.t;
}

class RecurringTransactionRepository {
  const RecurringTransactionRepository._();

  /// Returns a list of [RecurringTransaction]s matching the given query parameters.
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
  Future<List<RecurringTransaction>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [RecurringTransaction]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `RecurringTransaction.t`.
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
  _ida.Stream<List<RecurringTransaction>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [RecurringTransaction] matching the given query parameters.
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
  Future<RecurringTransaction?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? offset,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RecurringTransaction] by its [id] or null if no such row exists.
  Future<RecurringTransaction?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RecurringTransaction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RecurringTransaction]s in the list and returns the inserted rows.
  ///
  /// The returned [RecurringTransaction]s will have their `id` fields set.
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
  Future<List<RecurringTransaction>> insert(
    _is.DatabaseSession session,
    List<RecurringTransaction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<RecurringTransaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [RecurringTransaction] and returns the inserted row.
  ///
  /// The returned [RecurringTransaction] will have its `id` field set.
  Future<RecurringTransaction> insertRow(
    _is.DatabaseSession session,
    RecurringTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<RecurringTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [RecurringTransaction]s in the list and returns the resulting rows.
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
  /// The returned [RecurringTransaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecurringTransaction>> upsert(
    _is.DatabaseSession session,
    List<RecurringTransaction> rows, {
    required _is.ColumnSelections<RecurringTransactionTable> conflictColumns,
    _is.ColumnSelections<RecurringTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<RecurringTransactionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<RecurringTransaction>(
      rows,
      conflictColumns: conflictColumns(RecurringTransaction.t),
      updateColumns: updateColumns?.call(RecurringTransaction.t),
      updateWhere: updateWhere?.call(RecurringTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [RecurringTransaction] and returns the resulting row.
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
  /// The returned [RecurringTransaction] will have its `id` field set.
  Future<RecurringTransaction?> upsertRow(
    _is.DatabaseSession session,
    RecurringTransaction row, {
    required _is.ColumnSelections<RecurringTransactionTable> conflictColumns,
    _is.ColumnSelections<RecurringTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<RecurringTransactionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<RecurringTransaction>(
      row,
      conflictColumns: conflictColumns(RecurringTransaction.t),
      updateColumns: updateColumns?.call(RecurringTransaction.t),
      updateWhere: updateWhere?.call(RecurringTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates all [RecurringTransaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecurringTransaction>> update(
    _is.DatabaseSession session,
    List<RecurringTransaction> rows, {
    _is.ColumnSelections<RecurringTransactionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<RecurringTransaction>(
      rows,
      columns: columns?.call(RecurringTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [RecurringTransaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RecurringTransaction> updateRow(
    _is.DatabaseSession session,
    RecurringTransaction row, {
    _is.ColumnSelections<RecurringTransactionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<RecurringTransaction>(
      row,
      columns: columns?.call(RecurringTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RecurringTransaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RecurringTransaction?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<RecurringTransactionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<RecurringTransaction>(
      id,
      columnValues: columnValues(RecurringTransaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RecurringTransaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<RecurringTransaction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<RecurringTransactionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<RecurringTransactionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<RecurringTransaction>(
      columnValues: columnValues(RecurringTransaction.t.updateTable),
      where: where(RecurringTransaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [RecurringTransaction]s in the list and returns the deleted rows.
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
  Future<List<RecurringTransaction>> delete(
    _is.DatabaseSession session,
    List<RecurringTransaction> rows, {
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<RecurringTransaction>(
      rows,
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [RecurringTransaction].
  Future<RecurringTransaction> deleteRow(
    _is.DatabaseSession session,
    RecurringTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RecurringTransaction>(
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
  Future<List<RecurringTransaction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecurringTransactionTable> where,
    _is.OrderByBuilder<RecurringTransactionTable>? orderBy,
    _is.OrderByListBuilder<RecurringTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<RecurringTransaction>(
      where: where(RecurringTransaction.t),
      orderBy: orderBy?.call(RecurringTransaction.t),
      orderByList: orderByList?.call(RecurringTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<RecurringTransactionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<RecurringTransaction>(
      where: where?.call(RecurringTransaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RecurringTransaction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<RecurringTransactionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RecurringTransaction>(
      where: where(RecurringTransaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
