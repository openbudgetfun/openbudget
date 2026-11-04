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

/// A financial transaction within a budget, optionally assigned to an envelope.
abstract class Transaction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Transaction._({
    this.id,
    required this.description,
    required this.amountCents,
    required this.currencyCode,
    this.envelopeId,
    required this.budgetId,
    this.accountId,
    this.payeeId,
    required this.transactionDate,
    this.transferPairId,
    this.parentTransactionId,
    this.memo,
    bool? cleared,
    bool? reconciled,
    this.flagColor,
    DateTime? createdAt,
  }) : cleared = cleared ?? false,
       reconciled = reconciled ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Transaction({
    _is.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _is.UuidValue? envelopeId,
    required _is.UuidValue budgetId,
    _is.UuidValue? accountId,
    _is.UuidValue? payeeId,
    required DateTime transactionDate,
    _is.UuidValue? transferPairId,
    _is.UuidValue? parentTransactionId,
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  }) = _TransactionImpl;

  factory Transaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transaction(
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
      transactionDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['transactionDate'],
      ),
      transferPairId: jsonSerialization['transferPairId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['transferPairId'],
            ),
      parentTransactionId: jsonSerialization['parentTransactionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['parentTransactionId'],
            ),
      memo: jsonSerialization['memo'] as String?,
      cleared: jsonSerialization['cleared'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['cleared']),
      reconciled: jsonSerialization['reconciled'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['reconciled']),
      flagColor: jsonSerialization['flagColor'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TransactionTable();

  static const db = TransactionRepository._();

  @override
  _is.UuidValue? id;

  String description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  int amountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _is.UuidValue? envelopeId;

  _is.UuidValue budgetId;

  /// The account this transaction belongs to (optional for backwards compat).
  _is.UuidValue? accountId;

  /// The payee associated with this transaction.
  _is.UuidValue? payeeId;

  DateTime transactionDate;

  /// If this transaction is part of a transfer, this links to the paired transaction.
  _is.UuidValue? transferPairId;

  /// If this is a split sub-transaction, links to the parent transaction.
  _is.UuidValue? parentTransactionId;

  /// Optional user memo or note for additional context.
  String? memo;

  /// Whether this transaction has been cleared by the user.
  bool cleared;

  /// Whether this transaction has been reconciled.
  bool reconciled;

  /// Optional flag color for marking transactions (red, orange, yellow, green, blue, purple).
  String? flagColor;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Transaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    DateTime? transactionDate,
    _is.UuidValue? transferPairId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? parentTransactionId = const _is.$UndefinedUuidValue(),
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'transactionDate': transactionDate.toJson(),
      if (transferPairId != null) 'transferPairId': transferPairId?.toJson(),
      if (parentTransactionId != null)
        'parentTransactionId': parentTransactionId?.toJson(),
      if (memo != null) 'memo': memo,
      'cleared': cleared,
      'reconciled': reconciled,
      if (flagColor != null) 'flagColor': flagColor,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'description': description,
      'amountCents': amountCents,
      'currencyCode': currencyCode,
      if (envelopeId != null) 'envelopeId': envelopeId?.toJson(),
      'budgetId': budgetId.toJson(),
      if (accountId != null) 'accountId': accountId?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'transactionDate': transactionDate.toJson(),
      if (transferPairId != null) 'transferPairId': transferPairId?.toJson(),
      if (parentTransactionId != null)
        'parentTransactionId': parentTransactionId?.toJson(),
      if (memo != null) 'memo': memo,
      'cleared': cleared,
      'reconciled': reconciled,
      if (flagColor != null) 'flagColor': flagColor,
      'createdAt': createdAt.toJson(),
    };
  }

  static TransactionInclude include() {
    return TransactionInclude._();
  }

  static TransactionIncludeList includeList({
    _is.WhereExpressionBuilder<TransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    TransactionInclude? include,
  }) {
    return TransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionImpl extends Transaction {
  _TransactionImpl({
    _is.UuidValue? id,
    required String description,
    required int amountCents,
    required String currencyCode,
    _is.UuidValue? envelopeId,
    required _is.UuidValue budgetId,
    _is.UuidValue? accountId,
    _is.UuidValue? payeeId,
    required DateTime transactionDate,
    _is.UuidValue? transferPairId,
    _is.UuidValue? parentTransactionId,
    String? memo,
    bool? cleared,
    bool? reconciled,
    String? flagColor,
    DateTime? createdAt,
  }) : super._(
         id: id,
         description: description,
         amountCents: amountCents,
         currencyCode: currencyCode,
         envelopeId: envelopeId,
         budgetId: budgetId,
         accountId: accountId,
         payeeId: payeeId,
         transactionDate: transactionDate,
         transferPairId: transferPairId,
         parentTransactionId: parentTransactionId,
         memo: memo,
         cleared: cleared,
         reconciled: reconciled,
         flagColor: flagColor,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Transaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? description,
    int? amountCents,
    String? currencyCode,
    _is.UuidValue? envelopeId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? budgetId,
    _is.UuidValue? accountId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    DateTime? transactionDate,
    _is.UuidValue? transferPairId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? parentTransactionId = const _is.$UndefinedUuidValue(),
    Object? memo = _Undefined,
    bool? cleared,
    bool? reconciled,
    Object? flagColor = _Undefined,
    DateTime? createdAt,
  }) {
    return Transaction(
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
      transactionDate: transactionDate ?? this.transactionDate,
      transferPairId: transferPairId is _is.UndefinedSentinel
          ? this.transferPairId
          : transferPairId,
      parentTransactionId: parentTransactionId is _is.UndefinedSentinel
          ? this.parentTransactionId
          : parentTransactionId,
      memo: memo is String? ? memo : this.memo,
      cleared: cleared ?? this.cleared,
      reconciled: reconciled ?? this.reconciled,
      flagColor: flagColor is String? ? flagColor : this.flagColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TransactionUpdateTable extends _is.UpdateTable<TransactionTable> {
  TransactionUpdateTable(super.table);

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

  _is.ColumnValue<DateTime, DateTime> transactionDate(DateTime value) =>
      _is.ColumnValue(
        table.transactionDate,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> transferPairId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.transferPairId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> parentTransactionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.parentTransactionId,
    value,
  );

  _is.ColumnValue<String, String> memo(String? value) => _is.ColumnValue(
    table.memo,
    value,
  );

  _is.ColumnValue<bool, bool> cleared(bool value) => _is.ColumnValue(
    table.cleared,
    value,
  );

  _is.ColumnValue<bool, bool> reconciled(bool value) => _is.ColumnValue(
    table.reconciled,
    value,
  );

  _is.ColumnValue<String, String> flagColor(String? value) => _is.ColumnValue(
    table.flagColor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TransactionTable extends _is.Table<_is.UuidValue?> {
  TransactionTable({super.tableRelation}) : super(tableName: 'transaction') {
    updateTable = TransactionUpdateTable(this);
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
    transactionDate = _is.ColumnDateTime(
      'transactionDate',
      this,
    );
    transferPairId = _is.ColumnUuid(
      'transferPairId',
      this,
    );
    parentTransactionId = _is.ColumnUuid(
      'parentTransactionId',
      this,
    );
    memo = _is.ColumnString(
      'memo',
      this,
    );
    cleared = _is.ColumnBool(
      'cleared',
      this,
      hasDefault: true,
    );
    reconciled = _is.ColumnBool(
      'reconciled',
      this,
      hasDefault: true,
    );
    flagColor = _is.ColumnString(
      'flagColor',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final TransactionUpdateTable updateTable;

  late final _is.ColumnString description;

  /// Amount in integer cents. Positive = inflow, negative = outflow.
  late final _is.ColumnInt amountCents;

  /// ISO 4217 currency code.
  late final _is.ColumnString currencyCode;

  late final _is.ColumnUuid envelopeId;

  late final _is.ColumnUuid budgetId;

  /// The account this transaction belongs to (optional for backwards compat).
  late final _is.ColumnUuid accountId;

  /// The payee associated with this transaction.
  late final _is.ColumnUuid payeeId;

  late final _is.ColumnDateTime transactionDate;

  /// If this transaction is part of a transfer, this links to the paired transaction.
  late final _is.ColumnUuid transferPairId;

  /// If this is a split sub-transaction, links to the parent transaction.
  late final _is.ColumnUuid parentTransactionId;

  /// Optional user memo or note for additional context.
  late final _is.ColumnString memo;

  /// Whether this transaction has been cleared by the user.
  late final _is.ColumnBool cleared;

  /// Whether this transaction has been reconciled.
  late final _is.ColumnBool reconciled;

  /// Optional flag color for marking transactions (red, orange, yellow, green, blue, purple).
  late final _is.ColumnString flagColor;

  late final _is.ColumnDateTime createdAt;

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
    transactionDate,
    transferPairId,
    parentTransactionId,
    memo,
    cleared,
    reconciled,
    flagColor,
    createdAt,
  ];
}

class TransactionInclude extends _is.IncludeObject {
  TransactionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Transaction.t;
}

class TransactionIncludeList extends _is.IncludeList {
  TransactionIncludeList._({
    _is.WhereExpressionBuilder<TransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Transaction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Transaction.t;
}

class TransactionRepository {
  const TransactionRepository._();

  /// Returns a list of [Transaction]s matching the given query parameters.
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
  Future<List<Transaction>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Transaction>(
      where: where?.call(Transaction.t),
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Transaction]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Transaction.t`.
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
  _ida.Stream<List<Transaction>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Transaction>(
      where: where?.call(Transaction.t),
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Transaction] matching the given query parameters.
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
  Future<Transaction?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionTable>? where,
    int? offset,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Transaction>(
      where: where?.call(Transaction.t),
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Transaction] by its [id] or null if no such row exists.
  Future<Transaction?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Transaction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Transaction]s in the list and returns the inserted rows.
  ///
  /// The returned [Transaction]s will have their `id` fields set.
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
  Future<List<Transaction>> insert(
    _is.DatabaseSession session,
    List<Transaction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Transaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Transaction] and returns the inserted row.
  ///
  /// The returned [Transaction] will have its `id` field set.
  Future<Transaction> insertRow(
    _is.DatabaseSession session,
    Transaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Transaction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Transaction]s in the list and returns the resulting rows.
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
  /// The returned [Transaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transaction>> upsert(
    _is.DatabaseSession session,
    List<Transaction> rows, {
    required _is.ColumnSelections<TransactionTable> conflictColumns,
    _is.ColumnSelections<TransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Transaction>(
      rows,
      conflictColumns: conflictColumns(Transaction.t),
      updateColumns: updateColumns?.call(Transaction.t),
      updateWhere: updateWhere?.call(Transaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Transaction] and returns the resulting row.
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
  /// The returned [Transaction] will have its `id` field set.
  Future<Transaction?> upsertRow(
    _is.DatabaseSession session,
    Transaction row, {
    required _is.ColumnSelections<TransactionTable> conflictColumns,
    _is.ColumnSelections<TransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<TransactionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Transaction>(
      row,
      conflictColumns: conflictColumns(Transaction.t),
      updateColumns: updateColumns?.call(Transaction.t),
      updateWhere: updateWhere?.call(Transaction.t),
      transaction: transaction,
    );
  }

  /// Updates all [Transaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transaction>> update(
    _is.DatabaseSession session,
    List<Transaction> rows, {
    _is.ColumnSelections<TransactionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Transaction>(
      rows,
      columns: columns?.call(Transaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Transaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Transaction> updateRow(
    _is.DatabaseSession session,
    Transaction row, {
    _is.ColumnSelections<TransactionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Transaction>(
      row,
      columns: columns?.call(Transaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Transaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Transaction?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TransactionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Transaction>(
      id,
      columnValues: columnValues(Transaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Transaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Transaction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TransactionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TransactionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Transaction>(
      columnValues: columnValues(Transaction.t.updateTable),
      where: where(Transaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Transaction]s in the list and returns the deleted rows.
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
  Future<List<Transaction>> delete(
    _is.DatabaseSession session,
    List<Transaction> rows, {
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Transaction>(
      rows,
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Transaction].
  Future<Transaction> deleteRow(
    _is.DatabaseSession session,
    Transaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Transaction>(
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
  Future<List<Transaction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionTable> where,
    _is.OrderByBuilder<TransactionTable>? orderBy,
    _is.OrderByListBuilder<TransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Transaction>(
      where: where(Transaction.t),
      orderBy: orderBy?.call(Transaction.t),
      orderByList: orderByList?.call(Transaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TransactionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Transaction>(
      where: where?.call(Transaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Transaction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TransactionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Transaction>(
      where: where(Transaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
