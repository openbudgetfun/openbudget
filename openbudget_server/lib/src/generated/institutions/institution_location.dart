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

/// Geographic availability and popularity metadata for an institution.
abstract class InstitutionLocation
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  InstitutionLocation._({
    this.id,
    required this.institutionId,
    required this.locationCode,
    bool? isPopular,
    this.popularityRank,
    DateTime? createdAt,
  }) : isPopular = isPopular ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory InstitutionLocation({
    _i1.UuidValue? id,
    required _i1.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) = _InstitutionLocationImpl;

  factory InstitutionLocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return InstitutionLocation(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      institutionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['institutionId'],
      ),
      locationCode: jsonSerialization['locationCode'] as String,
      isPopular: jsonSerialization['isPopular'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPopular']),
      popularityRank: jsonSerialization['popularityRank'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = InstitutionLocationTable();

  static const db = InstitutionLocationRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue institutionId;

  /// ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  String locationCode;

  /// Whether this institution should be shown in "Popular options" for location.
  bool isPopular;

  /// Lower rank means higher priority in popular ordering.
  int? popularityRank;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InstitutionLocation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InstitutionLocation',
      if (id != null) 'id': id?.toJson(),
      'institutionId': institutionId.toJson(),
      'locationCode': locationCode,
      'isPopular': isPopular,
      if (popularityRank != null) 'popularityRank': popularityRank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InstitutionLocation',
      if (id != null) 'id': id?.toJson(),
      'institutionId': institutionId.toJson(),
      'locationCode': locationCode,
      'isPopular': isPopular,
      if (popularityRank != null) 'popularityRank': popularityRank,
      'createdAt': createdAt.toJson(),
    };
  }

  static InstitutionLocationInclude include() {
    return InstitutionLocationInclude._();
  }

  static InstitutionLocationIncludeList includeList({
    _i1.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionLocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    InstitutionLocationInclude? include,
  }) {
    return InstitutionLocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(InstitutionLocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionLocationImpl extends InstitutionLocation {
  _InstitutionLocationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue institutionId,
    required String locationCode,
    bool? isPopular,
    int? popularityRank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         institutionId: institutionId,
         locationCode: locationCode,
         isPopular: isPopular,
         popularityRank: popularityRank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InstitutionLocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InstitutionLocation copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? institutionId,
    String? locationCode,
    bool? isPopular,
    Object? popularityRank = _Undefined,
    DateTime? createdAt,
  }) {
    return InstitutionLocation(
      id: id is _i1.UuidValue? ? id : this.id,
      institutionId: institutionId ?? this.institutionId,
      locationCode: locationCode ?? this.locationCode,
      isPopular: isPopular ?? this.isPopular,
      popularityRank: popularityRank is int?
          ? popularityRank
          : this.popularityRank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InstitutionLocationUpdateTable
    extends _i1.UpdateTable<InstitutionLocationTable> {
  InstitutionLocationUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> institutionId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.institutionId,
    value,
  );

  _i1.ColumnValue<String, String> locationCode(String value) => _i1.ColumnValue(
    table.locationCode,
    value,
  );

  _i1.ColumnValue<bool, bool> isPopular(bool value) => _i1.ColumnValue(
    table.isPopular,
    value,
  );

  _i1.ColumnValue<int, int> popularityRank(int? value) => _i1.ColumnValue(
    table.popularityRank,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class InstitutionLocationTable extends _i1.Table<_i1.UuidValue?> {
  InstitutionLocationTable({super.tableRelation})
    : super(tableName: 'institution_location') {
    updateTable = InstitutionLocationUpdateTable(this);
    institutionId = _i1.ColumnUuid(
      'institutionId',
      this,
    );
    locationCode = _i1.ColumnString(
      'locationCode',
      this,
    );
    isPopular = _i1.ColumnBool(
      'isPopular',
      this,
      hasDefault: true,
    );
    popularityRank = _i1.ColumnInt(
      'popularityRank',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final InstitutionLocationUpdateTable updateTable;

  late final _i1.ColumnUuid institutionId;

  /// ISO 3166 country code (e.g. US, GB) or regional marker (e.g. EU).
  late final _i1.ColumnString locationCode;

  /// Whether this institution should be shown in "Popular options" for location.
  late final _i1.ColumnBool isPopular;

  /// Lower rank means higher priority in popular ordering.
  late final _i1.ColumnInt popularityRank;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    institutionId,
    locationCode,
    isPopular,
    popularityRank,
    createdAt,
  ];
}

class InstitutionLocationInclude extends _i1.IncludeObject {
  InstitutionLocationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => InstitutionLocation.t;
}

class InstitutionLocationIncludeList extends _i1.IncludeList {
  InstitutionLocationIncludeList._({
    _i1.WhereExpressionBuilder<InstitutionLocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InstitutionLocation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => InstitutionLocation.t;
}

class InstitutionLocationRepository {
  const InstitutionLocationRepository._();

  /// Returns a list of [InstitutionLocation]s matching the given query parameters.
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
  Future<List<InstitutionLocation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionLocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [InstitutionLocation] matching the given query parameters.
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
  Future<InstitutionLocation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? offset,
    _i1.OrderByBuilder<InstitutionLocationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InstitutionLocation] by its [id] or null if no such row exists.
  Future<InstitutionLocation?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InstitutionLocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InstitutionLocation]s in the list and returns the inserted rows.
  ///
  /// The returned [InstitutionLocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<InstitutionLocation>> insert(
    _i1.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<InstitutionLocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [InstitutionLocation] and returns the inserted row.
  ///
  /// The returned [InstitutionLocation] will have its `id` field set.
  Future<InstitutionLocation> insertRow(
    _i1.DatabaseSession session,
    InstitutionLocation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<InstitutionLocation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [InstitutionLocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<InstitutionLocation>> update(
    _i1.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _i1.ColumnSelections<InstitutionLocationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<InstitutionLocation>(
      rows,
      columns: columns?.call(InstitutionLocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InstitutionLocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InstitutionLocation> updateRow(
    _i1.DatabaseSession session,
    InstitutionLocation row, {
    _i1.ColumnSelections<InstitutionLocationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<InstitutionLocation>(
      row,
      columns: columns?.call(InstitutionLocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InstitutionLocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InstitutionLocation?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<InstitutionLocationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<InstitutionLocation>(
      id,
      columnValues: columnValues(InstitutionLocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InstitutionLocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<InstitutionLocation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<InstitutionLocationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<InstitutionLocationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionLocationTable>? orderBy,
    _i1.OrderByListBuilder<InstitutionLocationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<InstitutionLocation>(
      columnValues: columnValues(InstitutionLocation.t.updateTable),
      where: where(InstitutionLocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InstitutionLocation.t),
      orderByList: orderByList?.call(InstitutionLocation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [InstitutionLocation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<InstitutionLocation>> delete(
    _i1.DatabaseSession session,
    List<InstitutionLocation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<InstitutionLocation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [InstitutionLocation].
  Future<InstitutionLocation> deleteRow(
    _i1.DatabaseSession session,
    InstitutionLocation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InstitutionLocation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<InstitutionLocation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InstitutionLocationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<InstitutionLocation>(
      where: where(InstitutionLocation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InstitutionLocationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<InstitutionLocation>(
      where: where?.call(InstitutionLocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InstitutionLocation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InstitutionLocationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InstitutionLocation>(
      where: where(InstitutionLocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
