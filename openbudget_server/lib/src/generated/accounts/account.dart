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

/// A financial account within a budget (checking, savings, credit card, cash, etc.).
abstract class Account
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Account._({
    this.id,
    required this.name,
    required this.accountType,
    required this.balanceCents,
    required this.currencyCode,
    required this.budgetId,
    this.creatorId,
    this.institutionId,
    required this.onBudget,
    required this.sortOrder,
    required this.isClosed,
    this.sourceType,
    this.externalAccountId,
    this.connectionId,
    this.lastSyncedAt,
    this.syncStatus,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Account({
    _is.UuidValue? id,
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _is.UuidValue budgetId,
    _is.UuidValue? creatorId,
    _is.UuidValue? institutionId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _is.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      accountType: jsonSerialization['accountType'] as String,
      balanceCents: jsonSerialization['balanceCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      creatorId: jsonSerialization['creatorId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['creatorId']),
      institutionId: jsonSerialization['institutionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['institutionId'],
            ),
      onBudget: _is.BoolJsonExtension.fromJson(jsonSerialization['onBudget']),
      sortOrder: jsonSerialization['sortOrder'] as int,
      isClosed: _is.BoolJsonExtension.fromJson(jsonSerialization['isClosed']),
      sourceType: jsonSerialization['sourceType'] as String?,
      externalAccountId: jsonSerialization['externalAccountId'] as String?,
      connectionId: jsonSerialization['connectionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['connectionId'],
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AccountTable();

  static const db = AccountRepository._();

  @override
  _is.UuidValue? id;

  String name;

  /// Account type: checking, savings, creditCard, cash, investment, other.
  String accountType;

  /// Current balance in integer cents.
  int balanceCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _is.UuidValue budgetId;

  /// The authenticated user that created this account record.
  _is.UuidValue? creatorId;

  /// Optional linked financial institution for this account.
  _is.UuidValue? institutionId;

  /// Whether this account is included in the budget's "on budget" calculations.
  bool onBudget;

  /// Sort order for display.
  int sortOrder;

  /// Whether this account has been closed/archived.
  bool isClosed;

  /// Source of account data: manual, plaid, solana.
  String? sourceType;

  /// External source account identifier (e.g. Plaid account_id or wallet address).
  String? externalAccountId;

  /// Connection identifier used by external account sync providers.
  _is.UuidValue? connectionId;

  /// Last time the account was synchronized from an external provider.
  DateTime? lastSyncedAt;

  /// Latest sync status for the account (e.g. synced, stale, error).
  String? syncStatus;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Account copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _is.UuidValue? budgetId,
    _is.UuidValue? creatorId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? institutionId = const _is.$UndefinedUuidValue(),
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    String? sourceType,
    String? externalAccountId,
    _is.UuidValue? connectionId = const _is.$UndefinedUuidValue(),
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    String? syncStatus,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'accountType': accountType,
      'balanceCents': balanceCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId.toJson(),
      if (creatorId != null) 'creatorId': creatorId?.toJson(),
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      'onBudget': onBudget,
      'sortOrder': sortOrder,
      'isClosed': isClosed,
      if (sourceType != null) 'sourceType': sourceType,
      if (externalAccountId != null) 'externalAccountId': externalAccountId,
      if (connectionId != null) 'connectionId': connectionId?.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Account',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'accountType': accountType,
      'balanceCents': balanceCents,
      'currencyCode': currencyCode,
      'budgetId': budgetId.toJson(),
      if (creatorId != null) 'creatorId': creatorId?.toJson(),
      if (institutionId != null) 'institutionId': institutionId?.toJson(),
      'onBudget': onBudget,
      'sortOrder': sortOrder,
      'isClosed': isClosed,
      if (sourceType != null) 'sourceType': sourceType,
      if (externalAccountId != null) 'externalAccountId': externalAccountId,
      if (connectionId != null) 'connectionId': connectionId?.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      'createdAt': createdAt.toJson(),
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
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _is.UuidValue budgetId,
    _is.UuidValue? creatorId,
    _is.UuidValue? institutionId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _is.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         accountType: accountType,
         balanceCents: balanceCents,
         currencyCode: currencyCode,
         budgetId: budgetId,
         creatorId: creatorId,
         institutionId: institutionId,
         onBudget: onBudget,
         sortOrder: sortOrder,
         isClosed: isClosed,
         sourceType: sourceType,
         externalAccountId: externalAccountId,
         connectionId: connectionId,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Account copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _is.UuidValue? budgetId,
    _is.UuidValue? creatorId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? institutionId = const _is.$UndefinedUuidValue(),
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    Object? sourceType = _Undefined,
    Object? externalAccountId = _Undefined,
    _is.UuidValue? connectionId = const _is.$UndefinedUuidValue(),
    DateTime? lastSyncedAt = const _is.$UndefinedDateTime(),
    Object? syncStatus = _Undefined,
    DateTime? createdAt,
  }) {
    return Account(
      id: id is _is.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balanceCents: balanceCents ?? this.balanceCents,
      currencyCode: currencyCode ?? this.currencyCode,
      budgetId: budgetId ?? this.budgetId,
      creatorId: creatorId is _is.UndefinedSentinel
          ? this.creatorId
          : creatorId,
      institutionId: institutionId is _is.UndefinedSentinel
          ? this.institutionId
          : institutionId,
      onBudget: onBudget ?? this.onBudget,
      sortOrder: sortOrder ?? this.sortOrder,
      isClosed: isClosed ?? this.isClosed,
      sourceType: sourceType is String? ? sourceType : this.sourceType,
      externalAccountId: externalAccountId is String?
          ? externalAccountId
          : this.externalAccountId,
      connectionId: connectionId is _is.UndefinedSentinel
          ? this.connectionId
          : connectionId,
      lastSyncedAt: lastSyncedAt is _is.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AccountUpdateTable extends _is.UpdateTable<AccountTable> {
  AccountUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> accountType(String value) => _is.ColumnValue(
    table.accountType,
    value,
  );

  _is.ColumnValue<int, int> balanceCents(int value) => _is.ColumnValue(
    table.balanceCents,
    value,
  );

  _is.ColumnValue<String, String> currencyCode(String value) => _is.ColumnValue(
    table.currencyCode,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> creatorId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.creatorId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> institutionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.institutionId,
    value,
  );

  _is.ColumnValue<bool, bool> onBudget(bool value) => _is.ColumnValue(
    table.onBudget,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<bool, bool> isClosed(bool value) => _is.ColumnValue(
    table.isClosed,
    value,
  );

  _is.ColumnValue<String, String> sourceType(String? value) => _is.ColumnValue(
    table.sourceType,
    value,
  );

  _is.ColumnValue<String, String> externalAccountId(String? value) =>
      _is.ColumnValue(
        table.externalAccountId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> connectionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.connectionId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _is.ColumnValue<String, String> syncStatus(String? value) => _is.ColumnValue(
    table.syncStatus,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AccountTable extends _is.Table<_is.UuidValue?> {
  AccountTable({super.tableRelation}) : super(tableName: 'account') {
    updateTable = AccountUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    accountType = _is.ColumnString(
      'accountType',
      this,
    );
    balanceCents = _is.ColumnInt(
      'balanceCents',
      this,
    );
    currencyCode = _is.ColumnString(
      'currencyCode',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    creatorId = _is.ColumnUuid(
      'creatorId',
      this,
    );
    institutionId = _is.ColumnUuid(
      'institutionId',
      this,
    );
    onBudget = _is.ColumnBool(
      'onBudget',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sortOrder',
      this,
    );
    isClosed = _is.ColumnBool(
      'isClosed',
      this,
    );
    sourceType = _is.ColumnString(
      'sourceType',
      this,
    );
    externalAccountId = _is.ColumnString(
      'externalAccountId',
      this,
    );
    connectionId = _is.ColumnUuid(
      'connectionId',
      this,
    );
    lastSyncedAt = _is.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _is.ColumnString(
      'syncStatus',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AccountUpdateTable updateTable;

  late final _is.ColumnString name;

  /// Account type: checking, savings, creditCard, cash, investment, other.
  late final _is.ColumnString accountType;

  /// Current balance in integer cents.
  late final _is.ColumnInt balanceCents;

  /// ISO 4217 currency code.
  late final _is.ColumnString currencyCode;

  late final _is.ColumnUuid budgetId;

  /// The authenticated user that created this account record.
  late final _is.ColumnUuid creatorId;

  /// Optional linked financial institution for this account.
  late final _is.ColumnUuid institutionId;

  /// Whether this account is included in the budget's "on budget" calculations.
  late final _is.ColumnBool onBudget;

  /// Sort order for display.
  late final _is.ColumnInt sortOrder;

  /// Whether this account has been closed/archived.
  late final _is.ColumnBool isClosed;

  /// Source of account data: manual, plaid, solana.
  late final _is.ColumnString sourceType;

  /// External source account identifier (e.g. Plaid account_id or wallet address).
  late final _is.ColumnString externalAccountId;

  /// Connection identifier used by external account sync providers.
  late final _is.ColumnUuid connectionId;

  /// Last time the account was synchronized from an external provider.
  late final _is.ColumnDateTime lastSyncedAt;

  /// Latest sync status for the account (e.g. synced, stale, error).
  late final _is.ColumnString syncStatus;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    accountType,
    balanceCents,
    currencyCode,
    budgetId,
    creatorId,
    institutionId,
    onBudget,
    sortOrder,
    isClosed,
    sourceType,
    externalAccountId,
    connectionId,
    lastSyncedAt,
    syncStatus,
    createdAt,
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
