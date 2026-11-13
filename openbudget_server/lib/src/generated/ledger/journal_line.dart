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

import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod/serverpod.dart' as _is;

/// One line of a journal: a one-sided amount on one ledger account.
///
/// Each line carries the transaction-currency amount and the base amount
/// with the exact rate that produced it. Exactly one of debitMinor and
/// creditMinor is positive, and the base pair follows the same side.
///
/// UUID ids sort only by their embedded millisecond timestamp, so lines
/// written in the same millisecond have no inherent order; lineNumber is
/// the stable, unique order the reads rely on.
abstract class JournalLine
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  JournalLine._({
    this.id,
    required this.journalId,
    required this.ledgerAccountId,
    this.description,
    int? lineNumber,
    int? debitMinor,
    int? creditMinor,
    required this.currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required this.fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    this.taxCode,
  }) : lineNumber = lineNumber ?? 0,
       debitMinor = debitMinor ?? 0,
       creditMinor = creditMinor ?? 0,
       baseDebitMinor = baseDebitMinor ?? 0,
       baseCreditMinor = baseCreditMinor ?? 0,
       fxRate = fxRate ?? '1',
       fxRateSource = fxRateSource ?? _ifz8weqz.FxRateSource.identity;

  factory JournalLine({
    _is.UuidValue? id,
    required _is.UuidValue journalId,
    required _is.UuidValue ledgerAccountId,
    String? description,
    int? lineNumber,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  }) = _JournalLineImpl;

  factory JournalLine.fromJson(Map<String, dynamic> jsonSerialization) {
    return JournalLine(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      journalId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['journalId'],
      ),
      ledgerAccountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['ledgerAccountId'],
      ),
      description: jsonSerialization['description'] as String?,
      lineNumber: jsonSerialization['lineNumber'] as int?,
      debitMinor: jsonSerialization['debitMinor'] as int?,
      creditMinor: jsonSerialization['creditMinor'] as int?,
      currencyCode: jsonSerialization['currencyCode'] as String,
      baseDebitMinor: jsonSerialization['baseDebitMinor'] as int?,
      baseCreditMinor: jsonSerialization['baseCreditMinor'] as int?,
      fxRate: jsonSerialization['fxRate'] as String?,
      fxRateDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fxRateDate'],
      ),
      fxRateSource: jsonSerialization['fxRateSource'] == null
          ? null
          : _ifz8weqz.FxRateSource.fromJson(
              (jsonSerialization['fxRateSource'] as String),
            ),
      taxCode: jsonSerialization['taxCode'] as String?,
    );
  }

  static final t = JournalLineTable();

  static const db = JournalLineRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue journalId;

  _is.UuidValue ledgerAccountId;

  String? description;

  /// Zero-based position of this line within its journal.
  ///
  /// Assigned in the order the caller supplied the lines and renumbered
  /// whenever a draft's lines are replaced; reads order by it.
  int lineNumber;

  /// Debit in transaction-currency minor units, or 0.
  int debitMinor;

  /// Credit in transaction-currency minor units, or 0.
  int creditMinor;

  /// ISO 4217 code of the transaction currency.
  String currencyCode;

  /// Debit in base-currency minor units, or 0.
  int baseDebitMinor;

  /// Credit in base-currency minor units, or 0.
  int baseCreditMinor;

  /// Base currency per one transaction-currency unit, exact decimal.
  String fxRate;

  /// Calendar date of the rate.
  DateTime fxRateDate;

  _ifz8weqz.FxRateSource fxRateSource;

  /// Sales-tax code applied to this line.
  String? taxCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [JournalLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  JournalLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? journalId,
    _is.UuidValue? ledgerAccountId,
    String? description,
    int? lineNumber,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JournalLine',
      if (id != null) 'id': id?.toJson(),
      'journalId': journalId.toJson(),
      'ledgerAccountId': ledgerAccountId.toJson(),
      if (description != null) 'description': description,
      'lineNumber': lineNumber,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'currencyCode': currencyCode,
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      if (taxCode != null) 'taxCode': taxCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JournalLine',
      if (id != null) 'id': id?.toJson(),
      'journalId': journalId.toJson(),
      'ledgerAccountId': ledgerAccountId.toJson(),
      if (description != null) 'description': description,
      'lineNumber': lineNumber,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'currencyCode': currencyCode,
      'baseDebitMinor': baseDebitMinor,
      'baseCreditMinor': baseCreditMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      if (taxCode != null) 'taxCode': taxCode,
    };
  }

  static JournalLineInclude include() {
    return JournalLineInclude._();
  }

  static JournalLineIncludeList includeList({
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    JournalLineInclude? include,
  }) {
    return JournalLineIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JournalLineImpl extends JournalLine {
  _JournalLineImpl({
    _is.UuidValue? id,
    required _is.UuidValue journalId,
    required _is.UuidValue ledgerAccountId,
    String? description,
    int? lineNumber,
    int? debitMinor,
    int? creditMinor,
    required String currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    String? taxCode,
  }) : super._(
         id: id,
         journalId: journalId,
         ledgerAccountId: ledgerAccountId,
         description: description,
         lineNumber: lineNumber,
         debitMinor: debitMinor,
         creditMinor: creditMinor,
         currencyCode: currencyCode,
         baseDebitMinor: baseDebitMinor,
         baseCreditMinor: baseCreditMinor,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
         taxCode: taxCode,
       );

  /// Returns a shallow copy of this [JournalLine]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  JournalLine copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? journalId,
    _is.UuidValue? ledgerAccountId,
    Object? description = _Undefined,
    int? lineNumber,
    int? debitMinor,
    int? creditMinor,
    String? currencyCode,
    int? baseDebitMinor,
    int? baseCreditMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    Object? taxCode = _Undefined,
  }) {
    return JournalLine(
      id: id is _is.UndefinedSentinel ? this.id : id,
      journalId: journalId ?? this.journalId,
      ledgerAccountId: ledgerAccountId ?? this.ledgerAccountId,
      description: description is String? ? description : this.description,
      lineNumber: lineNumber ?? this.lineNumber,
      debitMinor: debitMinor ?? this.debitMinor,
      creditMinor: creditMinor ?? this.creditMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      baseDebitMinor: baseDebitMinor ?? this.baseDebitMinor,
      baseCreditMinor: baseCreditMinor ?? this.baseCreditMinor,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate ?? this.fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      taxCode: taxCode is String? ? taxCode : this.taxCode,
    );
  }
}

class JournalLineUpdateTable extends _is.UpdateTable<JournalLineTable> {
  JournalLineUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> journalId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.journalId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ledgerAccountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.ledgerAccountId,
    value,
  );

  _is.ColumnValue<String, String> description(String? value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<int, int> lineNumber(int value) => _is.ColumnValue(
    table.lineNumber,
    value,
  );

  _is.ColumnValue<int, int> debitMinor(int value) => _is.ColumnValue(
    table.debitMinor,
    value,
  );

  _is.ColumnValue<int, int> creditMinor(int value) => _is.ColumnValue(
    table.creditMinor,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<int, int> baseDebitMinor(int value) => _is.ColumnValue(
    table.baseDebitMinor,
    value,
  );

  _is.ColumnValue<int, int> baseCreditMinor(int value) => _is.ColumnValue(
    table.baseCreditMinor,
    value,
  );

  _is.ColumnValue<String, String> fxRate(String value) => _is.ColumnValue(
    table.fxRate,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> fxRateDate(DateTime value) =>
      _is.ColumnValue(
        table.fxRateDate,
        value,
      );

  _is.ColumnValue<_ifz8weqz.FxRateSource, _ifz8weqz.FxRateSource> fxRateSource(
    _ifz8weqz.FxRateSource value,
  ) => _is.ColumnValue(
    table.fxRateSource,
    value,
  );

  _is.ColumnValue<String, String> taxCode(String? value) => _is.ColumnValue(
    table.taxCode,
    value,
  );
}

class JournalLineTable extends _is.Table<_is.UuidValue?> {
  JournalLineTable({super.tableRelation}) : super(tableName: 'journal_line') {
    updateTable = JournalLineUpdateTable(this);
    journalId = _is.ColumnUuid(
      'journalId',
      this,
    );
    ledgerAccountId = _is.ColumnUuid(
      'ledgerAccountId',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    lineNumber = _is.ColumnInt(
      'lineNumber',
      this,
      hasDefault: true,
    );
    debitMinor = _is.ColumnInt(
      'debitMinor',
      this,
      hasDefault: true,
    );
    creditMinor = _is.ColumnInt(
      'creditMinor',
      this,
      hasDefault: true,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    baseDebitMinor = _is.ColumnInt(
      'baseDebitMinor',
      this,
      hasDefault: true,
    );
    baseCreditMinor = _is.ColumnInt(
      'baseCreditMinor',
      this,
      hasDefault: true,
    );
    fxRate = _is.ColumnString(
      'fxRate',
      this,
      hasDefault: true,
    );
    fxRateDate = _is.ColumnDateTime(
      'fxRateDate',
      this,
    );
    fxRateSource = _is.ColumnEnum(
      'fxRateSource',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    taxCode = _is.ColumnString(
      'taxCode',
      this,
    );
  }

  late final JournalLineUpdateTable updateTable;

  late final _is.ColumnUuid journalId;

  late final _is.ColumnUuid ledgerAccountId;

  late final _is.ColumnString description;

  /// Zero-based position of this line within its journal.
  ///
  /// Assigned in the order the caller supplied the lines and renumbered
  /// whenever a draft's lines are replaced; reads order by it.
  late final _is.ColumnInt lineNumber;

  /// Debit in transaction-currency minor units, or 0.
  late final _is.ColumnInt debitMinor;

  /// Credit in transaction-currency minor units, or 0.
  late final _is.ColumnInt creditMinor;

  /// ISO 4217 code of the transaction currency.
  late final _is.ColumnString currencyCode;

  /// Debit in base-currency minor units, or 0.
  late final _is.ColumnInt baseDebitMinor;

  /// Credit in base-currency minor units, or 0.
  late final _is.ColumnInt baseCreditMinor;

  /// Base currency per one transaction-currency unit, exact decimal.
  late final _is.ColumnString fxRate;

  /// Calendar date of the rate.
  late final _is.ColumnDateTime fxRateDate;

  late final _is.ColumnEnum<_ifz8weqz.FxRateSource> fxRateSource;

  /// Sales-tax code applied to this line.
  late final _is.ColumnString taxCode;

  @override
  List<_is.Column> get columns => [
    id,
    journalId,
    ledgerAccountId,
    description,
    lineNumber,
    debitMinor,
    creditMinor,
    currencyCode,
    baseDebitMinor,
    baseCreditMinor,
    fxRate,
    fxRateDate,
    fxRateSource,
    taxCode,
  ];
}

class JournalLineInclude extends _is.IncludeObject {
  JournalLineInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => JournalLine.t;
}

class JournalLineIncludeList extends _is.IncludeList {
  JournalLineIncludeList._({
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(JournalLine.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => JournalLine.t;
}

class JournalLineRepository {
  const JournalLineRepository._();

  /// Returns a list of [JournalLine]s matching the given query parameters.
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
  Future<List<JournalLine>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<JournalLine>(
      where: where?.call(JournalLine.t),
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [JournalLine]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `JournalLine.t`.
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
  _ida.Stream<List<JournalLine>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<JournalLine>(
      where: where?.call(JournalLine.t),
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [JournalLine] matching the given query parameters.
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
  Future<JournalLine?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    int? offset,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<JournalLine>(
      where: where?.call(JournalLine.t),
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [JournalLine] by its [id] or null if no such row exists.
  Future<JournalLine?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<JournalLine>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [JournalLine]s in the list and returns the inserted rows.
  ///
  /// The returned [JournalLine]s will have their `id` fields set.
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
  Future<List<JournalLine>> insert(
    _is.DatabaseSession session,
    List<JournalLine> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<JournalLine>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [JournalLine] and returns the inserted row.
  ///
  /// The returned [JournalLine] will have its `id` field set.
  Future<JournalLine> insertRow(
    _is.DatabaseSession session,
    JournalLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<JournalLine>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [JournalLine]s in the list and returns the resulting rows.
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
  /// The returned [JournalLine]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JournalLine>> upsert(
    _is.DatabaseSession session,
    List<JournalLine> rows, {
    required _is.ColumnSelections<JournalLineTable> conflictColumns,
    _is.ColumnSelections<JournalLineTable>? updateColumns,
    _is.WhereExpressionBuilder<JournalLineTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<JournalLine>(
      rows,
      conflictColumns: conflictColumns(JournalLine.t),
      updateColumns: updateColumns?.call(JournalLine.t),
      updateWhere: updateWhere?.call(JournalLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [JournalLine] and returns the resulting row.
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
  /// The returned [JournalLine] will have its `id` field set.
  Future<JournalLine?> upsertRow(
    _is.DatabaseSession session,
    JournalLine row, {
    required _is.ColumnSelections<JournalLineTable> conflictColumns,
    _is.ColumnSelections<JournalLineTable>? updateColumns,
    _is.WhereExpressionBuilder<JournalLineTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<JournalLine>(
      row,
      conflictColumns: conflictColumns(JournalLine.t),
      updateColumns: updateColumns?.call(JournalLine.t),
      updateWhere: updateWhere?.call(JournalLine.t),
      transaction: transaction,
    );
  }

  /// Updates all [JournalLine]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JournalLine>> update(
    _is.DatabaseSession session,
    List<JournalLine> rows, {
    _is.ColumnSelections<JournalLineTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<JournalLine>(
      rows,
      columns: columns?.call(JournalLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [JournalLine]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<JournalLine> updateRow(
    _is.DatabaseSession session,
    JournalLine row, {
    _is.ColumnSelections<JournalLineTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<JournalLine>(
      row,
      columns: columns?.call(JournalLine.t),
      transaction: transaction,
    );
  }

  /// Updates a single [JournalLine] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<JournalLine?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<JournalLineUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<JournalLine>(
      id,
      columnValues: columnValues(JournalLine.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [JournalLine]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<JournalLine>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<JournalLineUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<JournalLineTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<JournalLine>(
      columnValues: columnValues(JournalLine.t.updateTable),
      where: where(JournalLine.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [JournalLine]s in the list and returns the deleted rows.
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
  Future<List<JournalLine>> delete(
    _is.DatabaseSession session,
    List<JournalLine> rows, {
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<JournalLine>(
      rows,
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [JournalLine].
  Future<JournalLine> deleteRow(
    _is.DatabaseSession session,
    JournalLine row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<JournalLine>(
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
  Future<List<JournalLine>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JournalLineTable> where,
    _is.OrderByBuilder<JournalLineTable>? orderBy,
    _is.OrderByListBuilder<JournalLineTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<JournalLine>(
      where: where(JournalLine.t),
      orderBy: orderBy?.call(JournalLine.t),
      orderByList: orderByList?.call(JournalLine.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<JournalLineTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<JournalLine>(
      where: where?.call(JournalLine.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [JournalLine] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<JournalLineTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<JournalLine>(
      where: where(JournalLine.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
