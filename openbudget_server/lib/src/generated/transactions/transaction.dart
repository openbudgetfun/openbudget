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

import '../transactions/transaction_flag.dart' as _i2fej0yw;
import '../transactions/transaction_kind.dart' as _iwdxlbcu;
import '../transactions/transaction_status.dart' as _i45koviu;

/// Money moving into or out of one account on one calendar date.
///
/// The header is the movement; its lines allocate it to envelopes, ledger
/// accounts and tax treatments. Written only through TransactionWriter.
abstract class Transaction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Transaction._({
    this.id,
    required this.entityId,
    required this.accountId,
    required this.date,
    required this.amountMinor,
    required this.baseAmountMinor,
    String? fxRate,
    required this.fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    this.flag,
    this.payeeId,
    String? description,
    this.memo,
    this.externalId,
    this.recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : fxRate = fxRate ?? '1',
       fxRateSource = fxRateSource ?? _ifz8weqz.FxRateSource.identity,
       kind = kind ?? _iwdxlbcu.TransactionKind.standard,
       status = status ?? _i45koviu.TransactionStatus.uncleared,
       description = description ?? '',
       revision = revision ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Transaction({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required _is.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    required int baseAmountMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _is.UuidValue? payeeId,
    String? description,
    String? memo,
    String? externalId,
    _is.UuidValue? recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionImpl;

  factory Transaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return Transaction(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      date: _is.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      amountMinor: jsonSerialization['amountMinor'] as int,
      baseAmountMinor: jsonSerialization['baseAmountMinor'] as int,
      fxRate: jsonSerialization['fxRate'] as String?,
      fxRateDate: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['fxRateDate'],
      ),
      fxRateSource: jsonSerialization['fxRateSource'] == null
          ? null
          : _ifz8weqz.FxRateSource.fromJson(
              (jsonSerialization['fxRateSource'] as String),
            ),
      kind: jsonSerialization['kind'] == null
          ? null
          : _iwdxlbcu.TransactionKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      status: jsonSerialization['status'] == null
          ? null
          : _i45koviu.TransactionStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      flag: jsonSerialization['flag'] == null
          ? null
          : _i2fej0yw.TransactionFlag.fromJson(
              (jsonSerialization['flag'] as String),
            ),
      payeeId: jsonSerialization['payeeId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['payeeId']),
      description: jsonSerialization['description'] as String?,
      memo: jsonSerialization['memo'] as String?,
      externalId: jsonSerialization['externalId'] as String?,
      recurringTransactionId:
          jsonSerialization['recurringTransactionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['recurringTransactionId'],
            ),
      revision: jsonSerialization['revision'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = TransactionTable();

  static const db = TransactionRepository._();

  @override
  _is.UuidValue? id;

  /// Always the account's entity; never changes.
  _is.UuidValue entityId;

  _is.UuidValue accountId;

  /// Calendar date in the entity's time zone, at UTC midnight.
  DateTime date;

  /// Signed amount in account-currency minor units: positive in, negative out.
  int amountMinor;

  /// The same movement in the entity's base-currency minor units.
  int baseAmountMinor;

  /// Base currency per one unit of the account currency, exact decimal.
  String fxRate;

  /// Calendar date of the rate actually used.
  DateTime fxRateDate;

  _ifz8weqz.FxRateSource fxRateSource;

  _iwdxlbcu.TransactionKind kind;

  _i45koviu.TransactionStatus status;

  _i2fej0yw.TransactionFlag? flag;

  _is.UuidValue? payeeId;

  /// Statement text or a short title.
  String description;

  String? memo;

  /// Provider id for imported rows (Plaid transaction_id, `csv:<sha256>`),
  /// unique per account, so imports are idempotent.
  String? externalId;

  _is.UuidValue? recurringTransactionId;

  /// Increments whenever date, amount, account or lines change; ledger-mode
  /// books post one journal per revision.
  int revision;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Transaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    int? baseAmountMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    String? description,
    String? memo,
    String? externalId,
    _is.UuidValue? recurringTransactionId = const _is.$UndefinedUuidValue(),
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
      if (recurringTransactionId != null)
        'recurringTransactionId': recurringTransactionId?.toJson(),
      'revision': revision,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Transaction',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'date': date.toJson(),
      'amountMinor': amountMinor,
      'baseAmountMinor': baseAmountMinor,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate.toJson(),
      'fxRateSource': fxRateSource.toJson(),
      'kind': kind.toJson(),
      'status': status.toJson(),
      if (flag != null) 'flag': flag?.toJson(),
      if (payeeId != null) 'payeeId': payeeId?.toJson(),
      'description': description,
      if (memo != null) 'memo': memo,
      if (externalId != null) 'externalId': externalId,
      if (recurringTransactionId != null)
        'recurringTransactionId': recurringTransactionId?.toJson(),
      'revision': revision,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
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
    required _is.UuidValue entityId,
    required _is.UuidValue accountId,
    required DateTime date,
    required int amountMinor,
    required int baseAmountMinor,
    String? fxRate,
    required DateTime fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    _i2fej0yw.TransactionFlag? flag,
    _is.UuidValue? payeeId,
    String? description,
    String? memo,
    String? externalId,
    _is.UuidValue? recurringTransactionId,
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         accountId: accountId,
         date: date,
         amountMinor: amountMinor,
         baseAmountMinor: baseAmountMinor,
         fxRate: fxRate,
         fxRateDate: fxRateDate,
         fxRateSource: fxRateSource,
         kind: kind,
         status: status,
         flag: flag,
         payeeId: payeeId,
         description: description,
         memo: memo,
         externalId: externalId,
         recurringTransactionId: recurringTransactionId,
         revision: revision,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Transaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Transaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    _is.UuidValue? accountId,
    DateTime? date,
    int? amountMinor,
    int? baseAmountMinor,
    String? fxRate,
    DateTime? fxRateDate,
    _ifz8weqz.FxRateSource? fxRateSource,
    _iwdxlbcu.TransactionKind? kind,
    _i45koviu.TransactionStatus? status,
    Object? flag = _Undefined,
    _is.UuidValue? payeeId = const _is.$UndefinedUuidValue(),
    String? description,
    Object? memo = _Undefined,
    Object? externalId = _Undefined,
    _is.UuidValue? recurringTransactionId = const _is.$UndefinedUuidValue(),
    int? revision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      amountMinor: amountMinor ?? this.amountMinor,
      baseAmountMinor: baseAmountMinor ?? this.baseAmountMinor,
      fxRate: fxRate ?? this.fxRate,
      fxRateDate: fxRateDate ?? this.fxRateDate,
      fxRateSource: fxRateSource ?? this.fxRateSource,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      flag: flag is _i2fej0yw.TransactionFlag? ? flag : this.flag,
      payeeId: payeeId is _is.UndefinedSentinel ? this.payeeId : payeeId,
      description: description ?? this.description,
      memo: memo is String? ? memo : this.memo,
      externalId: externalId is String? ? externalId : this.externalId,
      recurringTransactionId: recurringTransactionId is _is.UndefinedSentinel
          ? this.recurringTransactionId
          : recurringTransactionId,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TransactionUpdateTable extends _is.UpdateTable<TransactionTable> {
  TransactionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> accountId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.accountId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> date(DateTime value) => _is.ColumnValue(
    table.date,
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

  _is.ColumnValue<_iwdxlbcu.TransactionKind, _iwdxlbcu.TransactionKind> kind(
    _iwdxlbcu.TransactionKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<_i45koviu.TransactionStatus, _i45koviu.TransactionStatus>
  status(_i45koviu.TransactionStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<_i2fej0yw.TransactionFlag, _i2fej0yw.TransactionFlag> flag(
    _i2fej0yw.TransactionFlag? value,
  ) => _is.ColumnValue(
    table.flag,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> payeeId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.payeeId,
        value,
      );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> memo(String? value) => _is.ColumnValue(
    table.memo,
    value,
  );

  _is.ColumnValue<String, String> externalId(String? value) => _is.ColumnValue(
    table.externalId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> recurringTransactionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.recurringTransactionId,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
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

class TransactionTable extends _is.Table<_is.UuidValue?> {
  TransactionTable({super.tableRelation}) : super(tableName: 'transaction') {
    updateTable = TransactionUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    accountId = _is.ColumnUuid(
      'accountId',
      this,
    );
    date = _is.ColumnDateTime(
      'date',
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
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    flag = _is.ColumnEnum(
      'flag',
      this,
      _is.EnumSerialization.byName,
    );
    payeeId = _is.ColumnUuid(
      'payeeId',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
      hasDefault: true,
    );
    memo = _is.ColumnString(
      'memo',
      this,
    );
    externalId = _is.ColumnString(
      'externalId',
      this,
    );
    recurringTransactionId = _is.ColumnUuid(
      'recurringTransactionId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
      hasDefault: true,
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

  late final TransactionUpdateTable updateTable;

  /// Always the account's entity; never changes.
  late final _is.ColumnUuid entityId;

  late final _is.ColumnUuid accountId;

  /// Calendar date in the entity's time zone, at UTC midnight.
  late final _is.ColumnDateTime date;

  /// Signed amount in account-currency minor units: positive in, negative out.
  late final _is.ColumnInt amountMinor;

  /// The same movement in the entity's base-currency minor units.
  late final _is.ColumnInt baseAmountMinor;

  /// Base currency per one unit of the account currency, exact decimal.
  late final _is.ColumnString fxRate;

  /// Calendar date of the rate actually used.
  late final _is.ColumnDateTime fxRateDate;

  late final _is.ColumnEnum<_ifz8weqz.FxRateSource> fxRateSource;

  late final _is.ColumnEnum<_iwdxlbcu.TransactionKind> kind;

  late final _is.ColumnEnum<_i45koviu.TransactionStatus> status;

  late final _is.ColumnEnum<_i2fej0yw.TransactionFlag> flag;

  late final _is.ColumnUuid payeeId;

  /// Statement text or a short title.
  late final _is.ColumnString description;

  late final _is.ColumnString memo;

  /// Provider id for imported rows (Plaid transaction_id, `csv:<sha256>`),
  /// unique per account, so imports are idempotent.
  late final _is.ColumnString externalId;

  late final _is.ColumnUuid recurringTransactionId;

  /// Increments whenever date, amount, account or lines change; ledger-mode
  /// books post one journal per revision.
  late final _is.ColumnInt revision;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    accountId,
    date,
    amountMinor,
    baseAmountMinor,
    fxRate,
    fxRateDate,
    fxRateSource,
    kind,
    status,
    flag,
    payeeId,
    description,
    memo,
    externalId,
    recurringTransactionId,
    revision,
    createdAt,
    updatedAt,
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
