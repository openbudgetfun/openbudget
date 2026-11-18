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

/// Somewhere money or value is held or owed: a bank account, card, loan,
/// wallet, house or car. Belongs to exactly one entity.
abstract class Account
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Account._({
    this.id,
    required this.entityId,
    required this.name,
    required this.kind,
    required this.currencyCode,
    required this.balanceSource,
    int? balanceMinor,
    bool? onBudget,
    this.institutionId,
    this.plaidConnectionId,
    this.plaidAccountId,
    this.reportedBalanceMinor,
    this.reportedBalanceAt,
    this.ledgerAccountId,
    this.reconciledThroughDate,
    this.note,
    int? sortOrder,
    this.closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : balanceMinor = balanceMinor ?? 0,
       onBudget = onBudget ?? false,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Account({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required String currencyCode,
    required _ifz8weqz.AccountBalanceSource balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _is.UuidValue? institutionId,
    _is.UuidValue? plaidConnectionId,
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    _is.UuidValue? ledgerAccountId,
    DateTime? reconciledThroughDate,
    String? note,
    int? sortOrder,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      name: jsonSerialization['name'] as String,
      kind: _ifz8weqz.AccountKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      currencyCode: jsonSerialization['currencyCode'] as String,
      balanceSource: _ifz8weqz.AccountBalanceSource.fromJson(
        (jsonSerialization['balanceSource'] as String),
      ),
      balanceMinor: jsonSerialization['balanceMinor'] as int?,
      onBudget: jsonSerialization['onBudget'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['onBudget']),
      institutionId: jsonSerialization['institutionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['institutionId'],
            ),
      plaidConnectionId: jsonSerialization['plaidConnectionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['plaidConnectionId'],
            ),
      plaidAccountId: jsonSerialization['plaidAccountId'] as String?,
      reportedBalanceMinor: jsonSerialization['reportedBalanceMinor'] as int?,
      reportedBalanceAt: jsonSerialization['reportedBalanceAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['reportedBalanceAt'],
            ),
      ledgerAccountId: jsonSerialization['ledgerAccountId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['ledgerAccountId'],
            ),
      reconciledThroughDate: jsonSerialization['reconciledThroughDate'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['reconciledThroughDate'],
            ),
      note: jsonSerialization['note'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AccountTable();

  static const db = AccountRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entityId;

  String name;

  _ifz8weqz.AccountKind kind;

  /// ISO 4217 code. Every transaction and valuation amount on the account is
  /// in this currency. Fixed after creation.
  String currencyCode;

  /// Fixed after creation.
  _ifz8weqz.AccountBalanceSource balanceSource;

  /// Cached current balance in account-currency minor units, signed:
  /// positive is owned, negative is owed. Equals the sum of the account's
  /// transaction amounts, or its latest valuation. Written only by
  /// `AccountBalanceService`.
  int balanceMinor;

  /// Whether the account's money is in the envelope plan.
  bool onBudget;

  _is.UuidValue? institutionId;

  _is.UuidValue? plaidConnectionId;

  /// Plaid `account_id`, when linked through Plaid.
  String? plaidAccountId;

  /// Balance the institution last reported, in account minor units. Shown to
  /// prompt a reconciliation; never used for budgeting or net worth.
  int? reportedBalanceMinor;

  DateTime? reportedBalanceAt;

  /// The ledger account that mirrors this account in ledger-mode books.
  _is.UuidValue? ledgerAccountId;

  /// Statement date of the last completed reconciliation.
  DateTime? reconciledThroughDate;

  String? note;

  int sortOrder;

  DateTime? closedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Account copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    String? currencyCode,
    _ifz8weqz.AccountBalanceSource? balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _is.UuidValue? institutionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? plaidConnectionId = const _is.$UndefinedUuidValue(),
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    DateTime? reconciledThroughDate = const _is.$UndefinedDateTime(),
    String? note,
    int? sortOrder,
    DateTime? closedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'currencyCode': currencyCode,
      'balanceSource': balanceSource.toJson(),
      'balanceMinor': balanceMinor,
      'onBudget': onBudget,
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      if (plaidConnectionId != null)
        'plaidConnectionId': plaidConnectionId?.toJson(),
      if (plaidAccountId != null) 'plaidAccountId': plaidAccountId,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'name': name,
      'kind': kind.toJson(),
      'currencyCode': currencyCode,
      'balanceSource': balanceSource.toJson(),
      'balanceMinor': balanceMinor,
      'onBudget': onBudget,
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      if (plaidConnectionId != null)
        'plaidConnectionId': plaidConnectionId?.toJson(),
      if (plaidAccountId != null) 'plaidAccountId': plaidAccountId,
      if (reportedBalanceMinor != null)
        'reportedBalanceMinor': reportedBalanceMinor,
      if (reportedBalanceAt != null)
        'reportedBalanceAt': reportedBalanceAt?.toJson(),
      if (ledgerAccountId != null) 'ledgerAccountId': ledgerAccountId?.toJson(),
      if (reconciledThroughDate != null)
        'reconciledThroughDate': reconciledThroughDate?.toJson(),
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AccountInclude include() {
    return AccountInclude._();
  }

  static AccountIncludeList includeList({
    _is.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    AccountInclude? include,
  }) {
    return AccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountImpl extends Account {
  _AccountImpl({
    _is.UuidValue? id,
    required _is.UuidValue entityId,
    required String name,
    required _ifz8weqz.AccountKind kind,
    required String currencyCode,
    required _ifz8weqz.AccountBalanceSource balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _is.UuidValue? institutionId,
    _is.UuidValue? plaidConnectionId,
    String? plaidAccountId,
    int? reportedBalanceMinor,
    DateTime? reportedBalanceAt,
    _is.UuidValue? ledgerAccountId,
    DateTime? reconciledThroughDate,
    String? note,
    int? sortOrder,
    DateTime? closedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         name: name,
         kind: kind,
         currencyCode: currencyCode,
         balanceSource: balanceSource,
         balanceMinor: balanceMinor,
         onBudget: onBudget,
         institutionId: institutionId,
         plaidConnectionId: plaidConnectionId,
         plaidAccountId: plaidAccountId,
         reportedBalanceMinor: reportedBalanceMinor,
         reportedBalanceAt: reportedBalanceAt,
         ledgerAccountId: ledgerAccountId,
         reconciledThroughDate: reconciledThroughDate,
         note: note,
         sortOrder: sortOrder,
         closedAt: closedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Account copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entityId,
    String? name,
    _ifz8weqz.AccountKind? kind,
    String? currencyCode,
    _ifz8weqz.AccountBalanceSource? balanceSource,
    int? balanceMinor,
    bool? onBudget,
    _is.UuidValue? institutionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? plaidConnectionId = const _is.$UndefinedUuidValue(),
    Object? plaidAccountId = _Undefined,
    Object? reportedBalanceMinor = _Undefined,
    DateTime? reportedBalanceAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? ledgerAccountId = const _is.$UndefinedUuidValue(),
    DateTime? reconciledThroughDate = const _is.$UndefinedDateTime(),
    Object? note = _Undefined,
    int? sortOrder,
    DateTime? closedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceSource: balanceSource ?? this.balanceSource,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      onBudget: onBudget ?? this.onBudget,
      institutionId: institutionId is _is.UndefinedSentinel
          ? this.institutionId
          : institutionId,
      plaidConnectionId: plaidConnectionId is _is.UndefinedSentinel
          ? this.plaidConnectionId
          : plaidConnectionId,
      plaidAccountId: plaidAccountId is String?
          ? plaidAccountId
          : this.plaidAccountId,
      reportedBalanceMinor: reportedBalanceMinor is int?
          ? reportedBalanceMinor
          : this.reportedBalanceMinor,
      reportedBalanceAt: reportedBalanceAt is _is.UndefinedSentinel
          ? this.reportedBalanceAt
          : reportedBalanceAt,
      ledgerAccountId: ledgerAccountId is _is.UndefinedSentinel
          ? this.ledgerAccountId
          : ledgerAccountId,
      reconciledThroughDate: reconciledThroughDate is _is.UndefinedSentinel
          ? this.reconciledThroughDate
          : reconciledThroughDate,
      note: note is String? ? note : this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      closedAt: closedAt is _is.UndefinedSentinel ? this.closedAt : closedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AccountUpdateTable extends _is.UpdateTable<AccountTable> {
  AccountUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_ifz8weqz.AccountKind, _ifz8weqz.AccountKind> kind(
    _ifz8weqz.AccountKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<
    _ifz8weqz.AccountBalanceSource,
    _ifz8weqz.AccountBalanceSource
  >
  balanceSource(_ifz8weqz.AccountBalanceSource value) => _is.ColumnValue(
    table.balanceSource,
    value,
  );

  _is.ColumnValue<int, int> balanceMinor(int value) => _is.ColumnValue(
    table.balanceMinor,
    value,
  );

  _is.ColumnValue<bool, bool> onBudget(bool value) => _is.ColumnValue(
    table.onBudget,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> institutionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.institutionId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> plaidConnectionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.plaidConnectionId,
    value,
  );

  _is.ColumnValue<String, String> plaidAccountId(String? value) =>
      _is.ColumnValue(
        table.plaidAccountId,
        value,
      );

  _is.ColumnValue<int, int> reportedBalanceMinor(int? value) => _is.ColumnValue(
    table.reportedBalanceMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> reportedBalanceAt(DateTime? value) =>
      _is.ColumnValue(
        table.reportedBalanceAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> ledgerAccountId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.ledgerAccountId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> reconciledThroughDate(DateTime? value) =>
      _is.ColumnValue(
        table.reconciledThroughDate,
        value,
      );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> closedAt(DateTime? value) =>
      _is.ColumnValue(
        table.closedAt,
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

class AccountTable extends _is.Table<_is.UuidValue?> {
  AccountTable({super.tableRelation}) : super(tableName: 'account') {
    updateTable = AccountUpdateTable(this);
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    balanceSource = _is.ColumnEnum(
      'balanceSource',
      this,
      _is.EnumSerialization.byName,
    );
    balanceMinor = _is.ColumnInt(
      'balanceMinor',
      this,
      hasDefault: true,
    );
    onBudget = _is.ColumnBool(
      'onBudget',
      this,
      hasDefault: true,
    );
    institutionId = _is.ColumnUuid(
      'institutionId',
      this,
    );
    plaidConnectionId = _is.ColumnUuid(
      'plaidConnectionId',
      this,
    );
    plaidAccountId = _is.ColumnString(
      'plaidAccountId',
      this,
    );
    reportedBalanceMinor = _is.ColumnInt(
      'reportedBalanceMinor',
      this,
    );
    reportedBalanceAt = _is.ColumnDateTime(
      'reportedBalanceAt',
      this,
    );
    ledgerAccountId = _is.ColumnUuid(
      'ledgerAccountId',
      this,
    );
    reconciledThroughDate = _is.ColumnDateTime(
      'reconciledThroughDate',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
      hasDefault: true,
    );
    closedAt = _is.ColumnDateTime(
      'closedAt',
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

  late final AccountUpdateTable updateTable;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnString name;

  late final _is.ColumnEnum<_ifz8weqz.AccountKind> kind;

  /// ISO 4217 code. Every transaction and valuation amount on the account is
  /// in this currency. Fixed after creation.
  late final _is.ColumnString currencyCode;

  /// Fixed after creation.
  late final _is.ColumnEnum<_ifz8weqz.AccountBalanceSource> balanceSource;

  /// Cached current balance in account-currency minor units, signed:
  /// positive is owned, negative is owed. Equals the sum of the account's
  /// transaction amounts, or its latest valuation. Written only by
  /// `AccountBalanceService`.
  late final _is.ColumnInt balanceMinor;

  /// Whether the account's money is in the envelope plan.
  late final _is.ColumnBool onBudget;

  late final _is.ColumnUuid institutionId;

  late final _is.ColumnUuid plaidConnectionId;

  /// Plaid `account_id`, when linked through Plaid.
  late final _is.ColumnString plaidAccountId;

  /// Balance the institution last reported, in account minor units. Shown to
  /// prompt a reconciliation; never used for budgeting or net worth.
  late final _is.ColumnInt reportedBalanceMinor;

  late final _is.ColumnDateTime reportedBalanceAt;

  /// The ledger account that mirrors this account in ledger-mode books.
  late final _is.ColumnUuid ledgerAccountId;

  /// Statement date of the last completed reconciliation.
  late final _is.ColumnDateTime reconciledThroughDate;

  late final _is.ColumnString note;

  late final _is.ColumnInt sortOrder;

  late final _is.ColumnDateTime closedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    entityId,
    name,
    kind,
    currencyCode,
    balanceSource,
    balanceMinor,
    onBudget,
    institutionId,
    plaidConnectionId,
    plaidAccountId,
    reportedBalanceMinor,
    reportedBalanceAt,
    ledgerAccountId,
    reconciledThroughDate,
    note,
    sortOrder,
    closedAt,
    createdAt,
    updatedAt,
  ];
}

class AccountInclude extends _is.IncludeObject {
  AccountInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Account.t;
}

class AccountIncludeList extends _is.IncludeList {
  AccountIncludeList._({
    _is.WhereExpressionBuilder<AccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Account.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Account.t;
}

class AccountRepository {
  const AccountRepository._();

  /// Returns a list of [Account]s matching the given query parameters.
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
  Future<List<Account>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Account>(
      where: where?.call(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Account]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Account.t`.
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
  _ida.Stream<List<Account>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Account>(
      where: where?.call(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Account] matching the given query parameters.
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
  Future<Account?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Account>(
      where: where?.call(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Account] by its [id] or null if no such row exists.
  Future<Account?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Account>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Account]s in the list and returns the inserted rows.
  ///
  /// The returned [Account]s will have their `id` fields set.
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
  Future<List<Account>> insert(
    _is.DatabaseSession session,
    List<Account> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Account>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Account] and returns the inserted row.
  ///
  /// The returned [Account] will have its `id` field set.
  Future<Account> insertRow(
    _is.DatabaseSession session,
    Account row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Account>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Account]s in the list and returns the resulting rows.
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
  /// The returned [Account]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Account>> upsert(
    _is.DatabaseSession session,
    List<Account> rows, {
    required _is.ColumnSelections<AccountTable> conflictColumns,
    _is.ColumnSelections<AccountTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Account>(
      rows,
      conflictColumns: conflictColumns(Account.t),
      updateColumns: updateColumns?.call(Account.t),
      updateWhere: updateWhere?.call(Account.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Account] and returns the resulting row.
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
  /// The returned [Account] will have its `id` field set.
  Future<Account?> upsertRow(
    _is.DatabaseSession session,
    Account row, {
    required _is.ColumnSelections<AccountTable> conflictColumns,
    _is.ColumnSelections<AccountTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Account>(
      row,
      conflictColumns: conflictColumns(Account.t),
      updateColumns: updateColumns?.call(Account.t),
      updateWhere: updateWhere?.call(Account.t),
      transaction: transaction,
    );
  }

  /// Updates all [Account]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Account>> update(
    _is.DatabaseSession session,
    List<Account> rows, {
    _is.ColumnSelections<AccountTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Account>(
      rows,
      columns: columns?.call(Account.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Account]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Account> updateRow(
    _is.DatabaseSession session,
    Account row, {
    _is.ColumnSelections<AccountTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Account>(
      row,
      columns: columns?.call(Account.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Account] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Account?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AccountUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Account>(
      id,
      columnValues: columnValues(Account.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Account]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Account>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AccountTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Account>(
      columnValues: columnValues(Account.t.updateTable),
      where: where(Account.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Account]s in the list and returns the deleted rows.
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
  Future<List<Account>> delete(
    _is.DatabaseSession session,
    List<Account> rows, {
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Account>(
      rows,
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Account].
  Future<Account> deleteRow(
    _is.DatabaseSession session,
    Account row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Account>(
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
  Future<List<Account>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountTable> where,
    _is.OrderByBuilder<AccountTable>? orderBy,
    _is.OrderByListBuilder<AccountTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Account>(
      where: where(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Account>(
      where: where?.call(Account.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Account] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Account>(
      where: where(Account.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
