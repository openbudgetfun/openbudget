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

/// One-time login challenge used for Solana wallet signature auth.
abstract class SolanaWalletAuthChallenge
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SolanaWalletAuthChallenge._({
    this.id,
    required this.publicKeyBase64,
    required this.challengeMessage,
    DateTime? createdAt,
    required this.expiresAt,
    this.usedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SolanaWalletAuthChallenge({
    _i1.UuidValue? id,
    required String publicKeyBase64,
    required String challengeMessage,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) = _SolanaWalletAuthChallengeImpl;

  factory SolanaWalletAuthChallenge.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletAuthChallenge(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      publicKeyBase64: jsonSerialization['publicKeyBase64'] as String,
      challengeMessage: jsonSerialization['challengeMessage'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  static final t = SolanaWalletAuthChallengeTable();

  static const db = SolanaWalletAuthChallengeRepository._();

  @override
  _i1.UuidValue? id;

  String publicKeyBase64;

  String challengeMessage;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? usedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWalletAuthChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletAuthChallenge copyWith({
    _i1.UuidValue? id,
    String? publicKeyBase64,
    String? challengeMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletAuthChallenge',
      if (id != null) 'id': id?.toJson(),
      'publicKeyBase64': publicKeyBase64,
      'challengeMessage': challengeMessage,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWalletAuthChallenge',
      if (id != null) 'id': id?.toJson(),
      'publicKeyBase64': publicKeyBase64,
      'challengeMessage': challengeMessage,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  static SolanaWalletAuthChallengeInclude include() {
    return SolanaWalletAuthChallengeInclude._();
  }

  static SolanaWalletAuthChallengeIncludeList includeList({
    _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthChallengeTable>? orderByList,
    SolanaWalletAuthChallengeInclude? include,
  }) {
    return SolanaWalletAuthChallengeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletAuthChallenge.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SolanaWalletAuthChallenge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletAuthChallengeImpl extends SolanaWalletAuthChallenge {
  _SolanaWalletAuthChallengeImpl({
    _i1.UuidValue? id,
    required String publicKeyBase64,
    required String challengeMessage,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) : super._(
         id: id,
         publicKeyBase64: publicKeyBase64,
         challengeMessage: challengeMessage,
         createdAt: createdAt,
         expiresAt: expiresAt,
         usedAt: usedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletAuthChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletAuthChallenge copyWith({
    Object? id = _Undefined,
    String? publicKeyBase64,
    String? challengeMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
  }) {
    return SolanaWalletAuthChallenge(
      id: id is _i1.UuidValue? ? id : this.id,
      publicKeyBase64: publicKeyBase64 ?? this.publicKeyBase64,
      challengeMessage: challengeMessage ?? this.challengeMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
    );
  }
}

class SolanaWalletAuthChallengeUpdateTable
    extends _i1.UpdateTable<SolanaWalletAuthChallengeTable> {
  SolanaWalletAuthChallengeUpdateTable(super.table);

  _i1.ColumnValue<String, String> publicKeyBase64(String value) =>
      _i1.ColumnValue(
        table.publicKeyBase64,
        value,
      );

  _i1.ColumnValue<String, String> challengeMessage(String value) =>
      _i1.ColumnValue(
        table.challengeMessage,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.usedAt,
        value,
      );
}

class SolanaWalletAuthChallengeTable extends _i1.Table<_i1.UuidValue?> {
  SolanaWalletAuthChallengeTable({super.tableRelation})
    : super(tableName: 'solana_wallet_auth_challenge') {
    updateTable = SolanaWalletAuthChallengeUpdateTable(this);
    publicKeyBase64 = _i1.ColumnString(
      'publicKeyBase64',
      this,
    );
    challengeMessage = _i1.ColumnString(
      'challengeMessage',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _i1.ColumnDateTime(
      'usedAt',
      this,
    );
  }

  late final SolanaWalletAuthChallengeUpdateTable updateTable;

  late final _i1.ColumnString publicKeyBase64;

  late final _i1.ColumnString challengeMessage;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime usedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    publicKeyBase64,
    challengeMessage,
    createdAt,
    expiresAt,
    usedAt,
  ];
}

class SolanaWalletAuthChallengeInclude extends _i1.IncludeObject {
  SolanaWalletAuthChallengeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletAuthChallenge.t;
}

class SolanaWalletAuthChallengeIncludeList extends _i1.IncludeList {
  SolanaWalletAuthChallengeIncludeList._({
    _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletAuthChallenge.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletAuthChallenge.t;
}

class SolanaWalletAuthChallengeRepository {
  const SolanaWalletAuthChallengeRepository._();

  /// Returns a list of [SolanaWalletAuthChallenge]s matching the given query parameters.
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
  Future<List<SolanaWalletAuthChallenge>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthChallengeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SolanaWalletAuthChallenge>(
      where: where?.call(SolanaWalletAuthChallenge.t),
      orderBy: orderBy?.call(SolanaWalletAuthChallenge.t),
      orderByList: orderByList?.call(SolanaWalletAuthChallenge.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SolanaWalletAuthChallenge] matching the given query parameters.
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
  Future<SolanaWalletAuthChallenge?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable>? where,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthChallengeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletAuthChallengeTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SolanaWalletAuthChallenge>(
      where: where?.call(SolanaWalletAuthChallenge.t),
      orderBy: orderBy?.call(SolanaWalletAuthChallenge.t),
      orderByList: orderByList?.call(SolanaWalletAuthChallenge.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SolanaWalletAuthChallenge] by its [id] or null if no such row exists.
  Future<SolanaWalletAuthChallenge?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SolanaWalletAuthChallenge>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SolanaWalletAuthChallenge]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaWalletAuthChallenge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SolanaWalletAuthChallenge>> insert(
    _i1.Session session,
    List<SolanaWalletAuthChallenge> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SolanaWalletAuthChallenge>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SolanaWalletAuthChallenge] and returns the inserted row.
  ///
  /// The returned [SolanaWalletAuthChallenge] will have its `id` field set.
  Future<SolanaWalletAuthChallenge> insertRow(
    _i1.Session session,
    SolanaWalletAuthChallenge row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletAuthChallenge>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletAuthChallenge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SolanaWalletAuthChallenge>> update(
    _i1.Session session,
    List<SolanaWalletAuthChallenge> rows, {
    _i1.ColumnSelections<SolanaWalletAuthChallengeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SolanaWalletAuthChallenge>(
      rows,
      columns: columns?.call(SolanaWalletAuthChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletAuthChallenge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletAuthChallenge> updateRow(
    _i1.Session session,
    SolanaWalletAuthChallenge row, {
    _i1.ColumnSelections<SolanaWalletAuthChallengeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaWalletAuthChallenge>(
      row,
      columns: columns?.call(SolanaWalletAuthChallenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletAuthChallenge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaWalletAuthChallenge?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SolanaWalletAuthChallengeUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletAuthChallenge>(
      id,
      columnValues: columnValues(SolanaWalletAuthChallenge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletAuthChallenge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SolanaWalletAuthChallenge>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SolanaWalletAuthChallengeUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletAuthChallengeTable>? orderBy,
    _i1.OrderByListBuilder<SolanaWalletAuthChallengeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SolanaWalletAuthChallenge>(
      columnValues: columnValues(SolanaWalletAuthChallenge.t.updateTable),
      where: where(SolanaWalletAuthChallenge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletAuthChallenge.t),
      orderByList: orderByList?.call(SolanaWalletAuthChallenge.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SolanaWalletAuthChallenge]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SolanaWalletAuthChallenge>> delete(
    _i1.Session session,
    List<SolanaWalletAuthChallenge> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SolanaWalletAuthChallenge>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SolanaWalletAuthChallenge].
  Future<SolanaWalletAuthChallenge> deleteRow(
    _i1.Session session,
    SolanaWalletAuthChallenge row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletAuthChallenge>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SolanaWalletAuthChallenge>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SolanaWalletAuthChallenge>(
      where: where(SolanaWalletAuthChallenge.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SolanaWalletAuthChallengeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletAuthChallenge>(
      where: where?.call(SolanaWalletAuthChallenge.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
