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
import 'package:serverpod/serverpod.dart' as _i1;

/// A financial account within a budget (checking, savings, credit card, cash, etc.).
abstract class Account
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Account._({
    this.id,
    required this.name,
    required this.accountType,
    required this.balanceCents,
    required this.currencyCode,
    required this.budgetId,
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
    _i1.UuidValue? id,
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _i1.UuidValue budgetId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
    DateTime? lastSyncedAt,
    String? syncStatus,
    DateTime? createdAt,
  }) = _AccountImpl;

  factory Account.fromJson(Map<String, dynamic> jsonSerialization) {
    return Account(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      accountType: jsonSerialization['accountType'] as String,
      balanceCents: jsonSerialization['balanceCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      onBudget: jsonSerialization['onBudget'] as bool,
      sortOrder: jsonSerialization['sortOrder'] as int,
      isClosed: jsonSerialization['isClosed'] as bool,
      sourceType: jsonSerialization['sourceType'] as String?,
      externalAccountId: jsonSerialization['externalAccountId'] as String?,
      connectionId: jsonSerialization['connectionId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['connectionId'],
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AccountTable();

  static const db = AccountRepository._();

  @override
  _i1.UuidValue? id;

  String name;

  /// Account type: checking, savings, creditCard, cash, investment, other.
  String accountType;

  /// Current balance in integer cents.
  int balanceCents;

  /// ISO 4217 currency code.
  String currencyCode;

  _i1.UuidValue budgetId;

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
  _i1.UuidValue? connectionId;

  /// Last time the account was synchronized from an external provider.
  DateTime? lastSyncedAt;

  /// Latest sync status for the account (e.g. synced, stale, error).
  String? syncStatus;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Account]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Account copyWith({
    _i1.UuidValue? id,
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _i1.UuidValue? budgetId,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
    DateTime? lastSyncedAt,
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
    _i1.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountTable>? orderByList,
    AccountInclude? include,
  }) {
    return AccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Account.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Account.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountImpl extends Account {
  _AccountImpl({
    _i1.UuidValue? id,
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required _i1.UuidValue budgetId,
    required bool onBudget,
    required int sortOrder,
    required bool isClosed,
    String? sourceType,
    String? externalAccountId,
    _i1.UuidValue? connectionId,
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
  @_i1.useResult
  @override
  Account copyWith({
    Object? id = _Undefined,
    String? name,
    String? accountType,
    int? balanceCents,
    String? currencyCode,
    _i1.UuidValue? budgetId,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
    Object? sourceType = _Undefined,
    Object? externalAccountId = _Undefined,
    Object? connectionId = _Undefined,
    Object? lastSyncedAt = _Undefined,
    Object? syncStatus = _Undefined,
    DateTime? createdAt,
  }) {
    return Account(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balanceCents: balanceCents ?? this.balanceCents,
      currencyCode: currencyCode ?? this.currencyCode,
      budgetId: budgetId ?? this.budgetId,
      onBudget: onBudget ?? this.onBudget,
      sortOrder: sortOrder ?? this.sortOrder,
      isClosed: isClosed ?? this.isClosed,
      sourceType: sourceType is String? ? sourceType : this.sourceType,
      externalAccountId: externalAccountId is String?
          ? externalAccountId
          : this.externalAccountId,
      connectionId: connectionId is _i1.UuidValue?
          ? connectionId
          : this.connectionId,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AccountUpdateTable extends _i1.UpdateTable<AccountTable> {
  AccountUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> accountType(String value) => _i1.ColumnValue(
    table.accountType,
    value,
  );

  _i1.ColumnValue<int, int> balanceCents(int value) => _i1.ColumnValue(
    table.balanceCents,
    value,
  );

  _i1.ColumnValue<String, String> currencyCode(String value) => _i1.ColumnValue(
    table.currencyCode,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.budgetId,
        value,
      );

  _i1.ColumnValue<bool, bool> onBudget(bool value) => _i1.ColumnValue(
    table.onBudget,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<bool, bool> isClosed(bool value) => _i1.ColumnValue(
    table.isClosed,
    value,
  );

  _i1.ColumnValue<String, String> sourceType(String? value) => _i1.ColumnValue(
    table.sourceType,
    value,
  );

  _i1.ColumnValue<String, String> externalAccountId(String? value) =>
      _i1.ColumnValue(
        table.externalAccountId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> connectionId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.connectionId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _i1.ColumnValue<String, String> syncStatus(String? value) => _i1.ColumnValue(
    table.syncStatus,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class AccountTable extends _i1.Table<_i1.UuidValue?> {
  AccountTable({super.tableRelation}) : super(tableName: 'account') {
    updateTable = AccountUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    accountType = _i1.ColumnString(
      'accountType',
      this,
    );
    balanceCents = _i1.ColumnInt(
      'balanceCents',
      this,
    );
    currencyCode = _i1.ColumnString(
      'currencyCode',
      this,
    );
    budgetId = _i1.ColumnUuid(
      'budgetId',
      this,
    );
    onBudget = _i1.ColumnBool(
      'onBudget',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    isClosed = _i1.ColumnBool(
      'isClosed',
      this,
    );
    sourceType = _i1.ColumnString(
      'sourceType',
      this,
    );
    externalAccountId = _i1.ColumnString(
      'externalAccountId',
      this,
    );
    connectionId = _i1.ColumnUuid(
      'connectionId',
      this,
    );
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    syncStatus = _i1.ColumnString(
      'syncStatus',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final AccountUpdateTable updateTable;

  late final _i1.ColumnString name;

  /// Account type: checking, savings, creditCard, cash, investment, other.
  late final _i1.ColumnString accountType;

  /// Current balance in integer cents.
  late final _i1.ColumnInt balanceCents;

  /// ISO 4217 currency code.
  late final _i1.ColumnString currencyCode;

  late final _i1.ColumnUuid budgetId;

  /// Whether this account is included in the budget's "on budget" calculations.
  late final _i1.ColumnBool onBudget;

  /// Sort order for display.
  late final _i1.ColumnInt sortOrder;

  /// Whether this account has been closed/archived.
  late final _i1.ColumnBool isClosed;

  /// Source of account data: manual, plaid, solana.
  late final _i1.ColumnString sourceType;

  /// External source account identifier (e.g. Plaid account_id or wallet address).
  late final _i1.ColumnString externalAccountId;

  /// Connection identifier used by external account sync providers.
  late final _i1.ColumnUuid connectionId;

  /// Last time the account was synchronized from an external provider.
  late final _i1.ColumnDateTime lastSyncedAt;

  /// Latest sync status for the account (e.g. synced, stale, error).
  late final _i1.ColumnString syncStatus;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    accountType,
    balanceCents,
    currencyCode,
    budgetId,
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

class AccountInclude extends _i1.IncludeObject {
  AccountInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Account.t;
}

class AccountIncludeList extends _i1.IncludeList {
  AccountIncludeList._({
    _i1.WhereExpressionBuilder<AccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Account.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Account.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Account>(
      where: where?.call(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountTable>? where,
    int? offset,
    _i1.OrderByBuilder<AccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Account>(
      where: where?.call(Account.t),
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Account] by its [id] or null if no such row exists.
  Future<Account?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Account>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Account]s in the list and returns the inserted rows.
  ///
  /// The returned [Account]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Account>> insert(
    _i1.Session session,
    List<Account> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Account>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Account] and returns the inserted row.
  ///
  /// The returned [Account] will have its `id` field set.
  Future<Account> insertRow(
    _i1.Session session,
    Account row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Account>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Account]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Account>> update(
    _i1.Session session,
    List<Account> rows, {
    _i1.ColumnSelections<AccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Account>(
      rows,
      columns: columns?.call(Account.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Account]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Account> updateRow(
    _i1.Session session,
    Account row, {
    _i1.ColumnSelections<AccountTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AccountUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Account>(
      id,
      columnValues: columnValues(Account.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Account]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Account>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AccountUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AccountTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AccountTable>? orderBy,
    _i1.OrderByListBuilder<AccountTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Account>(
      columnValues: columnValues(Account.t.updateTable),
      where: where(Account.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Account.t),
      orderByList: orderByList?.call(Account.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Account]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Account>> delete(
    _i1.Session session,
    List<Account> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Account>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Account].
  Future<Account> deleteRow(
    _i1.Session session,
    Account row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Account>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Account>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AccountTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Account>(
      where: where(Account.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AccountTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Account>(
      where: where?.call(Account.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
