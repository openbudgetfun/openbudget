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

/// A parsed Solana transaction associated with a wallet.
abstract class SolanaWalletTransaction
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SolanaWalletTransaction._({
    this.id,
    required this.walletId,
    required this.budgetId,
    required this.signature,
    required this.slot,
    this.occurredAt,
    required this.description,
    required this.txType,
    required this.source,
    this.interpretationConfidence,
    this.programsJson,
    this.nativeTransfersJson,
    this.tokenTransfersJson,
    this.estimatedCostBasis,
    this.estimatedProceeds,
    this.estimatedRealizedPnl,
    this.pnlCurrency,
    this.taxYear,
    this.category,
    this.tagsCsv,
    this.memo,
    required this.rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory SolanaWalletTransaction({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    required _i1.UuidValue budgetId,
    required String signature,
    required int slot,
    DateTime? occurredAt,
    required String description,
    required String txType,
    required String source,
    String? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    double? estimatedCostBasis,
    double? estimatedProceeds,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    int? taxYear,
    String? category,
    String? tagsCsv,
    String? memo,
    required String rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SolanaWalletTransactionImpl;

  factory SolanaWalletTransaction.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      signature: jsonSerialization['signature'] as String,
      slot: jsonSerialization['slot'] as int,
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['occurredAt']),
      description: jsonSerialization['description'] as String,
      txType: jsonSerialization['txType'] as String,
      source: jsonSerialization['source'] as String,
      interpretationConfidence:
          jsonSerialization['interpretationConfidence'] as String?,
      programsJson: jsonSerialization['programsJson'] as String?,
      nativeTransfersJson: jsonSerialization['nativeTransfersJson'] as String?,
      tokenTransfersJson: jsonSerialization['tokenTransfersJson'] as String?,
      estimatedCostBasis: (jsonSerialization['estimatedCostBasis'] as num?)
          ?.toDouble(),
      estimatedProceeds: (jsonSerialization['estimatedProceeds'] as num?)
          ?.toDouble(),
      estimatedRealizedPnl: (jsonSerialization['estimatedRealizedPnl'] as num?)
          ?.toDouble(),
      pnlCurrency: jsonSerialization['pnlCurrency'] as String?,
      taxYear: jsonSerialization['taxYear'] as int?,
      category: jsonSerialization['category'] as String?,
      tagsCsv: jsonSerialization['tagsCsv'] as String?,
      memo: jsonSerialization['memo'] as String?,
      rawJson: jsonSerialization['rawJson'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletTransactionTable();

  static const db = SolanaWalletTransactionRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue walletId;

  _i1.UuidValue budgetId;

  /// Transaction signature.
  String signature;

  /// Ledger slot number.
  int slot;

  /// Transaction timestamp from chain data.
  DateTime? occurredAt;

  /// Human-readable transaction description.
  String description;

  /// Parsed transaction type from Helius.
  String txType;

  /// Parsed transaction source from Helius.
  String source;

  /// Confidence level for synthesized fallback interpretation.
  String? interpretationConfidence;

  /// JSON-encoded list of detected program IDs.
  String? programsJson;

  /// JSON-encoded native transfer details.
  String? nativeTransfersJson;

  /// JSON-encoded token transfer details.
  String? tokenTransfersJson;

  /// Estimated disposal cost basis in quote currency.
  double? estimatedCostBasis;

  /// Estimated disposal proceeds in quote currency.
  double? estimatedProceeds;

  /// Estimated realized gain/loss in quote currency.
  double? estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  String? pnlCurrency;

  /// Tax year inferred from occurredAt.
  int? taxYear;

  /// User-managed category value.
  String? category;

  /// User-managed comma-separated tags.
  String? tagsCsv;

  /// User-managed memo.
  String? memo;

  /// Raw enhanced transaction payload JSON.
  String rawJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletTransaction copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? walletId,
    _i1.UuidValue? budgetId,
    String? signature,
    int? slot,
    DateTime? occurredAt,
    String? description,
    String? txType,
    String? source,
    String? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    double? estimatedCostBasis,
    double? estimatedProceeds,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    int? taxYear,
    String? category,
    String? tagsCsv,
    String? memo,
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'budgetId': budgetId.toJson(),
      'signature': signature,
      'slot': slot,
      if (occurredAt != null) 'occurredAt': occurredAt?.toJson(),
      'description': description,
      'txType': txType,
      'source': source,
      if (interpretationConfidence != null)
        'interpretationConfidence': interpretationConfidence,
      if (programsJson != null) 'programsJson': programsJson,
      if (nativeTransfersJson != null)
        'nativeTransfersJson': nativeTransfersJson,
      if (tokenTransfersJson != null) 'tokenTransfersJson': tokenTransfersJson,
      if (estimatedCostBasis != null) 'estimatedCostBasis': estimatedCostBasis,
      if (estimatedProceeds != null) 'estimatedProceeds': estimatedProceeds,
      if (estimatedRealizedPnl != null)
        'estimatedRealizedPnl': estimatedRealizedPnl,
      if (pnlCurrency != null) 'pnlCurrency': pnlCurrency,
      if (taxYear != null) 'taxYear': taxYear,
      if (category != null) 'category': category,
      if (tagsCsv != null) 'tagsCsv': tagsCsv,
      if (memo != null) 'memo': memo,
      'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'budgetId': budgetId.toJson(),
      'signature': signature,
      'slot': slot,
      if (occurredAt != null) 'occurredAt': occurredAt?.toJson(),
      'description': description,
      'txType': txType,
      'source': source,
      if (interpretationConfidence != null)
        'interpretationConfidence': interpretationConfidence,
      if (programsJson != null) 'programsJson': programsJson,
      if (nativeTransfersJson != null)
        'nativeTransfersJson': nativeTransfersJson,
      if (tokenTransfersJson != null) 'tokenTransfersJson': tokenTransfersJson,
      if (estimatedCostBasis != null) 'estimatedCostBasis': estimatedCostBasis,
      if (estimatedProceeds != null) 'estimatedProceeds': estimatedProceeds,
      if (estimatedRealizedPnl != null)
        'estimatedRealizedPnl': estimatedRealizedPnl,
      if (pnlCurrency != null) 'pnlCurrency': pnlCurrency,
      if (taxYear != null) 'taxYear': taxYear,
      if (category != null) 'category': category,
      if (tagsCsv != null) 'tagsCsv': tagsCsv,
      if (memo != null) 'memo': memo,
      'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SolanaWalletTransactionInclude include() {
    return SolanaWalletTransactionInclude._();
  }

  static SolanaWalletTransactionIncludeList includeList({
    _i1.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    SolanaWalletTransactionInclude? include,
  }) {
    return SolanaWalletTransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletTransactionImpl extends SolanaWalletTransaction {
  _SolanaWalletTransactionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    required _i1.UuidValue budgetId,
    required String signature,
    required int slot,
    DateTime? occurredAt,
    required String description,
    required String txType,
    required String source,
    String? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    double? estimatedCostBasis,
    double? estimatedProceeds,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    int? taxYear,
    String? category,
    String? tagsCsv,
    String? memo,
    required String rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         budgetId: budgetId,
         signature: signature,
         slot: slot,
         occurredAt: occurredAt,
         description: description,
         txType: txType,
         source: source,
         interpretationConfidence: interpretationConfidence,
         programsJson: programsJson,
         nativeTransfersJson: nativeTransfersJson,
         tokenTransfersJson: tokenTransfersJson,
         estimatedCostBasis: estimatedCostBasis,
         estimatedProceeds: estimatedProceeds,
         estimatedRealizedPnl: estimatedRealizedPnl,
         pnlCurrency: pnlCurrency,
         taxYear: taxYear,
         category: category,
         tagsCsv: tagsCsv,
         memo: memo,
         rawJson: rawJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletTransaction copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? walletId,
    _i1.UuidValue? budgetId,
    String? signature,
    int? slot,
    Object? occurredAt = _Undefined,
    String? description,
    String? txType,
    String? source,
    Object? interpretationConfidence = _Undefined,
    Object? programsJson = _Undefined,
    Object? nativeTransfersJson = _Undefined,
    Object? tokenTransfersJson = _Undefined,
    Object? estimatedCostBasis = _Undefined,
    Object? estimatedProceeds = _Undefined,
    Object? estimatedRealizedPnl = _Undefined,
    Object? pnlCurrency = _Undefined,
    Object? taxYear = _Undefined,
    Object? category = _Undefined,
    Object? tagsCsv = _Undefined,
    Object? memo = _Undefined,
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolanaWalletTransaction(
      id: id is _i1.UuidValue? ? id : this.id,
      walletId: walletId ?? this.walletId,
      budgetId: budgetId ?? this.budgetId,
      signature: signature ?? this.signature,
      slot: slot ?? this.slot,
      occurredAt: occurredAt is DateTime? ? occurredAt : this.occurredAt,
      description: description ?? this.description,
      txType: txType ?? this.txType,
      source: source ?? this.source,
      interpretationConfidence: interpretationConfidence is String?
          ? interpretationConfidence
          : this.interpretationConfidence,
      programsJson: programsJson is String? ? programsJson : this.programsJson,
      nativeTransfersJson: nativeTransfersJson is String?
          ? nativeTransfersJson
          : this.nativeTransfersJson,
      tokenTransfersJson: tokenTransfersJson is String?
          ? tokenTransfersJson
          : this.tokenTransfersJson,
      estimatedCostBasis: estimatedCostBasis is double?
          ? estimatedCostBasis
          : this.estimatedCostBasis,
      estimatedProceeds: estimatedProceeds is double?
          ? estimatedProceeds
          : this.estimatedProceeds,
      estimatedRealizedPnl: estimatedRealizedPnl is double?
          ? estimatedRealizedPnl
          : this.estimatedRealizedPnl,
      pnlCurrency: pnlCurrency is String? ? pnlCurrency : this.pnlCurrency,
      taxYear: taxYear is int? ? taxYear : this.taxYear,
      category: category is String? ? category : this.category,
      tagsCsv: tagsCsv is String? ? tagsCsv : this.tagsCsv,
      memo: memo is String? ? memo : this.memo,
      rawJson: rawJson ?? this.rawJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SolanaWalletTransactionUpdateTable
    extends _i1.UpdateTable<SolanaWalletTransactionTable> {
  SolanaWalletTransactionUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> walletId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.walletId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.budgetId, value);

  _i1.ColumnValue<String, String> signature(String value) =>
      _i1.ColumnValue(table.signature, value);

  _i1.ColumnValue<int, int> slot(int value) =>
      _i1.ColumnValue(table.slot, value);

  _i1.ColumnValue<DateTime, DateTime> occurredAt(DateTime? value) =>
      _i1.ColumnValue(table.occurredAt, value);

  _i1.ColumnValue<String, String> description(String value) =>
      _i1.ColumnValue(table.description, value);

  _i1.ColumnValue<String, String> txType(String value) =>
      _i1.ColumnValue(table.txType, value);

  _i1.ColumnValue<String, String> source(String value) =>
      _i1.ColumnValue(table.source, value);

  _i1.ColumnValue<String, String> interpretationConfidence(String? value) =>
      _i1.ColumnValue(table.interpretationConfidence, value);

  _i1.ColumnValue<String, String> programsJson(String? value) =>
      _i1.ColumnValue(table.programsJson, value);

  _i1.ColumnValue<String, String> nativeTransfersJson(String? value) =>
      _i1.ColumnValue(table.nativeTransfersJson, value);

  _i1.ColumnValue<String, String> tokenTransfersJson(String? value) =>
      _i1.ColumnValue(table.tokenTransfersJson, value);

  _i1.ColumnValue<double, double> estimatedCostBasis(double? value) =>
      _i1.ColumnValue(table.estimatedCostBasis, value);

  _i1.ColumnValue<double, double> estimatedProceeds(double? value) =>
      _i1.ColumnValue(table.estimatedProceeds, value);

  _i1.ColumnValue<double, double> estimatedRealizedPnl(double? value) =>
      _i1.ColumnValue(table.estimatedRealizedPnl, value);

  _i1.ColumnValue<String, String> pnlCurrency(String? value) =>
      _i1.ColumnValue(table.pnlCurrency, value);

  _i1.ColumnValue<int, int> taxYear(int? value) =>
      _i1.ColumnValue(table.taxYear, value);

  _i1.ColumnValue<String, String> category(String? value) =>
      _i1.ColumnValue(table.category, value);

  _i1.ColumnValue<String, String> tagsCsv(String? value) =>
      _i1.ColumnValue(table.tagsCsv, value);

  _i1.ColumnValue<String, String> memo(String? value) =>
      _i1.ColumnValue(table.memo, value);

  _i1.ColumnValue<String, String> rawJson(String value) =>
      _i1.ColumnValue(table.rawJson, value);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(table.createdAt, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class SolanaWalletTransactionTable extends _i1.Table<_i1.UuidValue?> {
  SolanaWalletTransactionTable({super.tableRelation})
    : super(tableName: 'solana_wallet_transaction') {
    updateTable = SolanaWalletTransactionUpdateTable(this);
    walletId = _i1.ColumnUuid('walletId', this);
    budgetId = _i1.ColumnUuid('budgetId', this);
    signature = _i1.ColumnString('signature', this);
    slot = _i1.ColumnInt('slot', this);
    occurredAt = _i1.ColumnDateTime('occurredAt', this);
    description = _i1.ColumnString('description', this);
    txType = _i1.ColumnString('txType', this);
    source = _i1.ColumnString('source', this);
    interpretationConfidence = _i1.ColumnString(
      'interpretationConfidence',
      this,
    );
    programsJson = _i1.ColumnString('programsJson', this);
    nativeTransfersJson = _i1.ColumnString('nativeTransfersJson', this);
    tokenTransfersJson = _i1.ColumnString('tokenTransfersJson', this);
    estimatedCostBasis = _i1.ColumnDouble('estimatedCostBasis', this);
    estimatedProceeds = _i1.ColumnDouble('estimatedProceeds', this);
    estimatedRealizedPnl = _i1.ColumnDouble('estimatedRealizedPnl', this);
    pnlCurrency = _i1.ColumnString('pnlCurrency', this);
    taxYear = _i1.ColumnInt('taxYear', this);
    category = _i1.ColumnString('category', this);
    tagsCsv = _i1.ColumnString('tagsCsv', this);
    memo = _i1.ColumnString('memo', this);
    rawJson = _i1.ColumnString('rawJson', this);
    createdAt = _i1.ColumnDateTime('createdAt', this, hasDefault: true);
    updatedAt = _i1.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final SolanaWalletTransactionUpdateTable updateTable;

  late final _i1.ColumnUuid walletId;

  late final _i1.ColumnUuid budgetId;

  /// Transaction signature.
  late final _i1.ColumnString signature;

  /// Ledger slot number.
  late final _i1.ColumnInt slot;

  /// Transaction timestamp from chain data.
  late final _i1.ColumnDateTime occurredAt;

  /// Human-readable transaction description.
  late final _i1.ColumnString description;

  /// Parsed transaction type from Helius.
  late final _i1.ColumnString txType;

  /// Parsed transaction source from Helius.
  late final _i1.ColumnString source;

  /// Confidence level for synthesized fallback interpretation.
  late final _i1.ColumnString interpretationConfidence;

  /// JSON-encoded list of detected program IDs.
  late final _i1.ColumnString programsJson;

  /// JSON-encoded native transfer details.
  late final _i1.ColumnString nativeTransfersJson;

  /// JSON-encoded token transfer details.
  late final _i1.ColumnString tokenTransfersJson;

  /// Estimated disposal cost basis in quote currency.
  late final _i1.ColumnDouble estimatedCostBasis;

  /// Estimated disposal proceeds in quote currency.
  late final _i1.ColumnDouble estimatedProceeds;

  /// Estimated realized gain/loss in quote currency.
  late final _i1.ColumnDouble estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  late final _i1.ColumnString pnlCurrency;

  /// Tax year inferred from occurredAt.
  late final _i1.ColumnInt taxYear;

  /// User-managed category value.
  late final _i1.ColumnString category;

  /// User-managed comma-separated tags.
  late final _i1.ColumnString tagsCsv;

  /// User-managed memo.
  late final _i1.ColumnString memo;

  /// Raw enhanced transaction payload JSON.
  late final _i1.ColumnString rawJson;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    walletId,
    budgetId,
    signature,
    slot,
    occurredAt,
    description,
    txType,
    source,
    interpretationConfidence,
    programsJson,
    nativeTransfersJson,
    tokenTransfersJson,
    estimatedCostBasis,
    estimatedProceeds,
    estimatedRealizedPnl,
    pnlCurrency,
    taxYear,
    category,
    tagsCsv,
    memo,
    rawJson,
    createdAt,
    updatedAt,
  ];
}

class SolanaWalletTransactionInclude extends _i1.IncludeObject {
  SolanaWalletTransactionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletTransaction.t;
}

class SolanaWalletTransactionIncludeList extends _i1.IncludeList {
  SolanaWalletTransactionIncludeList._({
    _i1.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletTransaction.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletTransaction.t;
}

class SolanaWalletTransactionRepository {
  const SolanaWalletTransactionRepository._();

  /// Returns a list of [SolanaWalletTransaction]s matching the given query parameters.
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
  Future<List<SolanaWalletTransaction>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SolanaWalletTransaction] matching the given query parameters.
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
  Future<SolanaWalletTransaction?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWalletTransaction] by its [id] or null if no such row exists.
  Future<SolanaWalletTransaction?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SolanaWalletTransaction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SolanaWalletTransaction]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaWalletTransaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SolanaWalletTransaction>> insert(
    _i1.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SolanaWalletTransaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SolanaWalletTransaction] and returns the inserted row.
  ///
  /// The returned [SolanaWalletTransaction] will have its `id` field set.
  Future<SolanaWalletTransaction> insertRow(
    _i1.DatabaseSession session,
    SolanaWalletTransaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletTransaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SolanaWalletTransaction>> update(
    _i1.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _i1.ColumnSelections<SolanaWalletTransactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SolanaWalletTransaction>(
      rows,
      columns: columns?.call(SolanaWalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletTransaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletTransaction> updateRow(
    _i1.DatabaseSession session,
    SolanaWalletTransaction row, {
    _i1.ColumnSelections<SolanaWalletTransactionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaWalletTransaction>(
      row,
      columns: columns?.call(SolanaWalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletTransaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaWalletTransaction?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SolanaWalletTransactionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletTransaction>(
      id,
      columnValues: columnValues(SolanaWalletTransaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletTransaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SolanaWalletTransaction>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SolanaWalletTransactionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _i1.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SolanaWalletTransaction>(
      columnValues: columnValues(SolanaWalletTransaction.t.updateTable),
      where: where(SolanaWalletTransaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SolanaWalletTransaction]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SolanaWalletTransaction>> delete(
    _i1.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SolanaWalletTransaction>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SolanaWalletTransaction].
  Future<SolanaWalletTransaction> deleteRow(
    _i1.DatabaseSession session,
    SolanaWalletTransaction row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SolanaWalletTransaction>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SolanaWalletTransaction>(
      where: where(SolanaWalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWalletTransaction] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWalletTransaction>(
      where: where(SolanaWalletTransaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
