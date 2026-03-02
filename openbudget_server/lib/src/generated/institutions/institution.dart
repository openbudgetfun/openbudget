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

/// Catalog entry for a financial institution that can be linked to accounts.
abstract class Institution
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Institution._({
    this.id,
    required this.slug,
    required this.name,
    this.website,
    this.plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : isDigitalBank = isDigitalBank ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Institution({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) = _InstitutionImpl;

  factory Institution.fromJson(Map<String, dynamic> jsonSerialization) {
    return Institution(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slug: jsonSerialization['slug'] as String,
      name: jsonSerialization['name'] as String,
      website: jsonSerialization['website'] as String?,
      plaidInstitutionId: jsonSerialization['plaidInstitutionId'] as String?,
      isDigitalBank: jsonSerialization['isDigitalBank'] as bool?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = InstitutionTable();

  static const db = InstitutionRepository._();

  @override
  _i1.UuidValue? id;

  /// Stable identifier used for idempotent catalog seeding.
  String slug;

  /// Institution display name.
  String name;

  /// Optional homepage domain for discovery/search.
  String? website;

  /// Optional Plaid institution id, when known.
  String? plaidInstitutionId;

  /// Marks digital-first challengers (e.g., Monzo, Revolut, Wise).
  bool isDigitalBank;

  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Institution copyWith({
    _i1.UuidValue? id,
    String? slug,
    String? name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Institution',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (website != null) 'website': website,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      'isDigitalBank': isDigitalBank,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Institution',
      if (id != null) 'id': id?.toJson(),
      'slug': slug,
      'name': name,
      if (website != null) 'website': website,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      'isDigitalBank': isDigitalBank,
      'createdAt': createdAt.toJson(),
    };
  }

  static InstitutionInclude include() {
    return InstitutionInclude._();
  }

  static InstitutionIncludeList includeList({
    _i1.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionTable>? orderByList,
    InstitutionInclude? include,
  }) {
    return InstitutionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Institution.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Institution.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InstitutionImpl extends Institution {
  _InstitutionImpl({
    _i1.UuidValue? id,
    required String slug,
    required String name,
    String? website,
    String? plaidInstitutionId,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) : super._(
         id: id,
         slug: slug,
         name: name,
         website: website,
         plaidInstitutionId: plaidInstitutionId,
         isDigitalBank: isDigitalBank,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Institution]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Institution copyWith({
    Object? id = _Undefined,
    String? slug,
    String? name,
    Object? website = _Undefined,
    Object? plaidInstitutionId = _Undefined,
    bool? isDigitalBank,
    DateTime? createdAt,
  }) {
    return Institution(
      id: id is _i1.UuidValue? ? id : this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      website: website is String? ? website : this.website,
      plaidInstitutionId: plaidInstitutionId is String?
          ? plaidInstitutionId
          : this.plaidInstitutionId,
      isDigitalBank: isDigitalBank ?? this.isDigitalBank,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InstitutionUpdateTable extends _i1.UpdateTable<InstitutionTable> {
  InstitutionUpdateTable(super.table);

  _i1.ColumnValue<String, String> slug(String value) => _i1.ColumnValue(
    table.slug,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> website(String? value) => _i1.ColumnValue(
    table.website,
    value,
  );

  _i1.ColumnValue<String, String> plaidInstitutionId(String? value) =>
      _i1.ColumnValue(
        table.plaidInstitutionId,
        value,
      );

  _i1.ColumnValue<bool, bool> isDigitalBank(bool value) => _i1.ColumnValue(
    table.isDigitalBank,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class InstitutionTable extends _i1.Table<_i1.UuidValue?> {
  InstitutionTable({super.tableRelation}) : super(tableName: 'institution') {
    updateTable = InstitutionUpdateTable(this);
    slug = _i1.ColumnString(
      'slug',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    website = _i1.ColumnString(
      'website',
      this,
    );
    plaidInstitutionId = _i1.ColumnString(
      'plaidInstitutionId',
      this,
    );
    isDigitalBank = _i1.ColumnBool(
      'isDigitalBank',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final InstitutionUpdateTable updateTable;

  /// Stable identifier used for idempotent catalog seeding.
  late final _i1.ColumnString slug;

  /// Institution display name.
  late final _i1.ColumnString name;

  /// Optional homepage domain for discovery/search.
  late final _i1.ColumnString website;

  /// Optional Plaid institution id, when known.
  late final _i1.ColumnString plaidInstitutionId;

  /// Marks digital-first challengers (e.g., Monzo, Revolut, Wise).
  late final _i1.ColumnBool isDigitalBank;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    slug,
    name,
    website,
    plaidInstitutionId,
    isDigitalBank,
    createdAt,
  ];
}

class InstitutionInclude extends _i1.IncludeObject {
  InstitutionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Institution.t;
}

class InstitutionIncludeList extends _i1.IncludeList {
  InstitutionIncludeList._({
    _i1.WhereExpressionBuilder<InstitutionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Institution.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Institution.t;
}

class InstitutionRepository {
  const InstitutionRepository._();

  /// Returns a list of [Institution]s matching the given query parameters.
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
  Future<List<Institution>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Institution>(
      where: where?.call(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Institution] matching the given query parameters.
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
  Future<Institution?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InstitutionTable>? where,
    int? offset,
    _i1.OrderByBuilder<InstitutionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InstitutionTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Institution>(
      where: where?.call(Institution.t),
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Institution] by its [id] or null if no such row exists.
  Future<Institution?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Institution>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Institution]s in the list and returns the inserted rows.
  ///
  /// The returned [Institution]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Institution>> insert(
    _i1.Session session,
    List<Institution> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Institution>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Institution] and returns the inserted row.
  ///
  /// The returned [Institution] will have its `id` field set.
  Future<Institution> insertRow(
    _i1.Session session,
    Institution row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Institution>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Institution]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Institution>> update(
    _i1.Session session,
    List<Institution> rows, {
    _i1.ColumnSelections<InstitutionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Institution>(
      rows,
      columns: columns?.call(Institution.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Institution]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Institution> updateRow(
    _i1.Session session,
    Institution row, {
    _i1.ColumnSelections<InstitutionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Institution>(
      row,
      columns: columns?.call(Institution.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Institution] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Institution?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<InstitutionUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Institution>(
      id,
      columnValues: columnValues(Institution.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Institution]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Institution>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<InstitutionUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<InstitutionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InstitutionTable>? orderBy,
    _i1.OrderByListBuilder<InstitutionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Institution>(
      columnValues: columnValues(Institution.t.updateTable),
      where: where(Institution.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Institution.t),
      orderByList: orderByList?.call(Institution.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Institution]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Institution>> delete(
    _i1.Session session,
    List<Institution> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Institution>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Institution].
  Future<Institution> deleteRow(
    _i1.Session session,
    Institution row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Institution>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Institution>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<InstitutionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Institution>(
      where: where(Institution.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<InstitutionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Institution>(
      where: where?.call(Institution.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
