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

/// Mapping between a Solana wallet public key and an auth user.
abstract class SolanaWalletAuthAccount
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SolanaWalletAuthAccount._({
    this.id,
    required this.authUserId,
    required this.publicKeyBase64,
    this.walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       lastAuthenticatedAt = lastAuthenticatedAt ?? DateTime.now();

  factory SolanaWalletAuthAccount({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required String publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) = _SolanaWalletAuthAccountImpl;

  factory SolanaWalletAuthAccount.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletAuthAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      publicKeyBase64: jsonSerialization['publicKeyBase64'] as String,
      walletAddress: jsonSerialization['walletAddress'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastAuthenticatedAt: jsonSerialization['lastAuthenticatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAuthenticatedAt'],
            ),
    );
  }

  static final t = SolanaWalletAuthAccountTable();

  static const db = SolanaWalletAuthAccountRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue authUserId;

  String publicKeyBase64;

  String? walletAddress;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime lastAuthenticatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWalletAuthAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletAuthAccount copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletAuthAccount',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      'publicKeyBase64': publicKeyBase64,
      if (walletAddress != null) 'walletAddress': walletAddress,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'lastAuthenticatedAt': lastAuthenticatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWalletAuthAccount',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      'publicKeyBase64': publicKeyBase64,
      if (walletAddress != null) 'walletAddress': walletAddress,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'lastAuthenticatedAt': lastAuthenticatedAt.toJson(),
    };
  }

  static SolanaWalletAuthAccountInclude include() {
    return SolanaWalletAuthAccountInclude._();
  }

  static SolanaWalletAuthAccountIncludeList includeList({
    _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthAccountTable>? orderByList,
    SolanaWalletAuthAccountInclude? include,
  }) {
    return SolanaWalletAuthAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletAuthAccount.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SolanaWalletAuthAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletAuthAccountImpl extends SolanaWalletAuthAccount {
  _SolanaWalletAuthAccountImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required String publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         publicKeyBase64: publicKeyBase64,
         walletAddress: walletAddress,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastAuthenticatedAt: lastAuthenticatedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletAuthAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletAuthAccount copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    String? publicKeyBase64,
    Object? walletAddress = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) {
    return SolanaWalletAuthAccount(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      publicKeyBase64: publicKeyBase64 ?? this.publicKeyBase64,
      walletAddress: walletAddress is String?
          ? walletAddress
          : this.walletAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
    );
  }
}

class SolanaWalletAuthAccountUpdateTable
    extends _i1.UpdateTable<SolanaWalletAuthAccountTable> {
  SolanaWalletAuthAccountUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> publicKeyBase64(String value) =>
      _i1.ColumnValue(
        table.publicKeyBase64,
        value,
      );

  _i1.ColumnValue<String, String> walletAddress(String? value) =>
      _i1.ColumnValue(
        table.walletAddress,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastAuthenticatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.lastAuthenticatedAt,
        value,
      );
}

class SolanaWalletAuthAccountTable extends _i1.Table<_i1.UuidValue?> {
  SolanaWalletAuthAccountTable({super.tableRelation})
    : super(tableName: 'solana_wallet_auth_account') {
    updateTable = SolanaWalletAuthAccountUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    publicKeyBase64 = _i1.ColumnString(
      'publicKeyBase64',
      this,
    );
    walletAddress = _i1.ColumnString(
      'walletAddress',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    lastAuthenticatedAt = _i1.ColumnDateTime(
      'lastAuthenticatedAt',
      this,
      hasDefault: true,
    );
  }

  late final SolanaWalletAuthAccountUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  late final _i1.ColumnString publicKeyBase64;

  late final _i1.ColumnString walletAddress;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime lastAuthenticatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    publicKeyBase64,
    walletAddress,
    createdAt,
    updatedAt,
    lastAuthenticatedAt,
  ];
}

class SolanaWalletAuthAccountInclude extends _i1.IncludeObject {
  SolanaWalletAuthAccountInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletAuthAccount.t;
}

class SolanaWalletAuthAccountIncludeList extends _i1.IncludeList {
  SolanaWalletAuthAccountIncludeList._({
    _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletAuthAccount.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletAuthAccount.t;
}

class SolanaWalletAuthAccountRepository {
  const SolanaWalletAuthAccountRepository._();

  /// Returns a list of [SolanaWalletAuthAccount]s matching the given query parameters.
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
  Future<List<SolanaWalletAuthAccount>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SolanaWalletAuthAccount>(
      where: where?.call(SolanaWalletAuthAccount.t),
      orderBy: orderBy?.call(SolanaWalletAuthAccount.t),
      orderByList: orderByList?.call(SolanaWalletAuthAccount.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SolanaWalletAuthAccount] matching the given query parameters.
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
  Future<SolanaWalletAuthAccount?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable>? where,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SolanaWalletAuthAccount>(
      where: where?.call(SolanaWalletAuthAccount.t),
      orderBy: orderBy?.call(SolanaWalletAuthAccount.t),
      orderByList: orderByList?.call(SolanaWalletAuthAccount.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SolanaWalletAuthAccount] by its [id] or null if no such row exists.
  Future<SolanaWalletAuthAccount?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SolanaWalletAuthAccount>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SolanaWalletAuthAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaWalletAuthAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SolanaWalletAuthAccount>> insert(
    _i1.Session session,
    List<SolanaWalletAuthAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SolanaWalletAuthAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SolanaWalletAuthAccount] and returns the inserted row.
  ///
  /// The returned [SolanaWalletAuthAccount] will have its `id` field set.
  Future<SolanaWalletAuthAccount> insertRow(
    _i1.Session session,
    SolanaWalletAuthAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletAuthAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletAuthAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SolanaWalletAuthAccount>> update(
    _i1.Session session,
    List<SolanaWalletAuthAccount> rows, {
    _i1.ColumnSelections<SolanaWalletAuthAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SolanaWalletAuthAccount>(
      rows,
      columns: columns?.call(SolanaWalletAuthAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletAuthAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletAuthAccount> updateRow(
    _i1.Session session,
    SolanaWalletAuthAccount row, {
    _i1.ColumnSelections<SolanaWalletAuthAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaWalletAuthAccount>(
      row,
      columns: columns?.call(SolanaWalletAuthAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletAuthAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaWalletAuthAccount?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SolanaWalletAuthAccountUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletAuthAccount>(
      id,
      columnValues: columnValues(SolanaWalletAuthAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletAuthAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SolanaWalletAuthAccount>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SolanaWalletAuthAccountUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthAccountTable>? orderBy,
    _i1.OrderByListBuilder<SolanaWalletAuthAccountTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SolanaWalletAuthAccount>(
      columnValues: columnValues(SolanaWalletAuthAccount.t.updateTable),
      where: where(SolanaWalletAuthAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletAuthAccount.t),
      orderByList: orderByList?.call(SolanaWalletAuthAccount.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SolanaWalletAuthAccount]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SolanaWalletAuthAccount>> delete(
    _i1.Session session,
    List<SolanaWalletAuthAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SolanaWalletAuthAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SolanaWalletAuthAccount].
  Future<SolanaWalletAuthAccount> deleteRow(
    _i1.Session session,
    SolanaWalletAuthAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletAuthAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SolanaWalletAuthAccount>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SolanaWalletAuthAccount>(
      where: where(SolanaWalletAuthAccount.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthAccountTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletAuthAccount>(
      where: where?.call(SolanaWalletAuthAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
