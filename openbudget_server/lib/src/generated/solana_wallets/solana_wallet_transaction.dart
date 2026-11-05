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

/// A parsed Solana transaction associated with a wallet.
abstract class SolanaWalletTransaction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _is.UuidValue budgetId,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      signature: jsonSerialization['signature'] as String,
      slot: jsonSerialization['slot'] as int,
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['occurredAt']),
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletTransactionTable();

  static const db = SolanaWalletTransactionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletId;

  _is.UuidValue budgetId;

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
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SolanaWalletTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _is.UuidValue? budgetId,
    String? signature,
    int? slot,
    DateTime? occurredAt = const _is.$UndefinedDateTime(),
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
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    SolanaWalletTransactionInclude? include,
  }) {
    return SolanaWalletTransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletTransactionImpl extends SolanaWalletTransaction {
  _SolanaWalletTransactionImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _is.UuidValue budgetId,
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
  @_is.useResult
  @override
  SolanaWalletTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _is.UuidValue? budgetId,
    String? signature,
    int? slot,
    DateTime? occurredAt = const _is.$UndefinedDateTime(),
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
      id: id is _is.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      budgetId: budgetId ?? this.budgetId,
      signature: signature ?? this.signature,
      slot: slot ?? this.slot,
      occurredAt: occurredAt is _is.UndefinedSentinel
          ? this.occurredAt
          : occurredAt,
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
    extends _is.UpdateTable<SolanaWalletTransactionTable> {
  SolanaWalletTransactionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.walletId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<String, String> signature(String value) => _is.ColumnValue(
    table.signature,
    value,
  );

  _is.ColumnValue<int, int> slot(int value) => _is.ColumnValue(
    table.slot,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> occurredAt(DateTime? value) =>
      _is.ColumnValue(
        table.occurredAt,
        value,
      );

  _is.ColumnValue<String, String> description(String value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> txType(String value) => _is.ColumnValue(
    table.txType,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
    value,
  );

  _is.ColumnValue<String, String> interpretationConfidence(String? value) =>
      _is.ColumnValue(
        table.interpretationConfidence,
        value,
      );

  _is.ColumnValue<String, String> programsJson(String? value) =>
      _is.ColumnValue(
        table.programsJson,
        value,
      );

  _is.ColumnValue<String, String> nativeTransfersJson(String? value) =>
      _is.ColumnValue(
        table.nativeTransfersJson,
        value,
      );

  _is.ColumnValue<String, String> tokenTransfersJson(String? value) =>
      _is.ColumnValue(
        table.tokenTransfersJson,
        value,
      );

  _is.ColumnValue<double, double> estimatedCostBasis(double? value) =>
      _is.ColumnValue(
        table.estimatedCostBasis,
        value,
      );

  _is.ColumnValue<double, double> estimatedProceeds(double? value) =>
      _is.ColumnValue(
        table.estimatedProceeds,
        value,
      );

  _is.ColumnValue<double, double> estimatedRealizedPnl(double? value) =>
      _is.ColumnValue(
        table.estimatedRealizedPnl,
        value,
      );

  _is.ColumnValue<String, String> pnlCurrency(String? value) => _is.ColumnValue(
    table.pnlCurrency,
    value,
  );

  _is.ColumnValue<int, int> taxYear(int? value) => _is.ColumnValue(
    table.taxYear,
    value,
  );

  _is.ColumnValue<String, String> category(String? value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> tagsCsv(String? value) => _is.ColumnValue(
    table.tagsCsv,
    value,
  );

  _is.ColumnValue<String, String> memo(String? value) => _is.ColumnValue(
    table.memo,
    value,
  );

  _is.ColumnValue<String, String> rawJson(String value) => _is.ColumnValue(
    table.rawJson,
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

class SolanaWalletTransactionTable extends _is.Table<_is.UuidValue?> {
  SolanaWalletTransactionTable({super.tableRelation})
    : super(tableName: 'solana_wallet_transaction') {
    updateTable = SolanaWalletTransactionUpdateTable(this);
    walletId = _is.ColumnUuid(
      'walletId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    signature = _is.ColumnString(
      'signature',
      this,
    );
    slot = _is.ColumnInt(
      'slot',
      this,
    );
    occurredAt = _is.ColumnDateTime(
      'occurredAt',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    txType = _is.ColumnString(
      'txType',
      this,
    );
    source = _is.ColumnString(
      'source',
      this,
    );
    interpretationConfidence = _is.ColumnString(
      'interpretationConfidence',
      this,
    );
    programsJson = _is.ColumnString(
      'programsJson',
      this,
    );
    nativeTransfersJson = _is.ColumnString(
      'nativeTransfersJson',
      this,
    );
    tokenTransfersJson = _is.ColumnString(
      'tokenTransfersJson',
      this,
    );
    estimatedCostBasis = _is.ColumnDouble(
      'estimatedCostBasis',
      this,
    );
    estimatedProceeds = _is.ColumnDouble(
      'estimatedProceeds',
      this,
    );
    estimatedRealizedPnl = _is.ColumnDouble(
      'estimatedRealizedPnl',
      this,
    );
    pnlCurrency = _is.ColumnString(
      'pnlCurrency',
      this,
    );
    taxYear = _is.ColumnInt(
      'taxYear',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    tagsCsv = _is.ColumnString(
      'tagsCsv',
      this,
    );
    memo = _is.ColumnString(
      'memo',
      this,
    );
    rawJson = _is.ColumnString(
      'rawJson',
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

  late final SolanaWalletTransactionUpdateTable updateTable;

  late final _is.ColumnUuid walletId;

  late final _is.ColumnUuid budgetId;

  /// Transaction signature.
  late final _is.ColumnString signature;

  /// Ledger slot number.
  late final _is.ColumnInt slot;

  /// Transaction timestamp from chain data.
  late final _is.ColumnDateTime occurredAt;

  /// Human-readable transaction description.
  late final _is.ColumnString description;

  /// Parsed transaction type from Helius.
  late final _is.ColumnString txType;

  /// Parsed transaction source from Helius.
  late final _is.ColumnString source;

  /// Confidence level for synthesized fallback interpretation.
  late final _is.ColumnString interpretationConfidence;

  /// JSON-encoded list of detected program IDs.
  late final _is.ColumnString programsJson;

  /// JSON-encoded native transfer details.
  late final _is.ColumnString nativeTransfersJson;

  /// JSON-encoded token transfer details.
  late final _is.ColumnString tokenTransfersJson;

  /// Estimated disposal cost basis in quote currency.
  late final _is.ColumnDouble estimatedCostBasis;

  /// Estimated disposal proceeds in quote currency.
  late final _is.ColumnDouble estimatedProceeds;

  /// Estimated realized gain/loss in quote currency.
  late final _is.ColumnDouble estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  late final _is.ColumnString pnlCurrency;

  /// Tax year inferred from occurredAt.
  late final _is.ColumnInt taxYear;

  /// User-managed category value.
  late final _is.ColumnString category;

  /// User-managed comma-separated tags.
  late final _is.ColumnString tagsCsv;

  /// User-managed memo.
  late final _is.ColumnString memo;

  /// Raw enhanced transaction payload JSON.
  late final _is.ColumnString rawJson;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
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

class SolanaWalletTransactionInclude extends _is.IncludeObject {
  SolanaWalletTransactionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWalletTransaction.t;
}

class SolanaWalletTransactionIncludeList extends _is.IncludeList {
  SolanaWalletTransactionIncludeList._({
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletTransaction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWalletTransaction.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SolanaWalletTransaction]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SolanaWalletTransaction.t`.
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
  _ida.Stream<List<SolanaWalletTransaction>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWalletTransaction] by its [id] or null if no such row exists.
  Future<SolanaWalletTransaction?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletTransaction>> insert(
    _is.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SolanaWalletTransaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SolanaWalletTransaction] and returns the inserted row.
  ///
  /// The returned [SolanaWalletTransaction] will have its `id` field set.
  Future<SolanaWalletTransaction> insertRow(
    _is.DatabaseSession session,
    SolanaWalletTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SolanaWalletTransaction]s in the list and returns the resulting rows.
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
  /// The returned [SolanaWalletTransaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletTransaction>> upsert(
    _is.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    required _is.ColumnSelections<SolanaWalletTransactionTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SolanaWalletTransaction>(
      rows,
      conflictColumns: conflictColumns(SolanaWalletTransaction.t),
      updateColumns: updateColumns?.call(SolanaWalletTransaction.t),
      updateWhere: updateWhere?.call(SolanaWalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SolanaWalletTransaction] and returns the resulting row.
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
  /// The returned [SolanaWalletTransaction] will have its `id` field set.
  Future<SolanaWalletTransaction?> upsertRow(
    _is.DatabaseSession session,
    SolanaWalletTransaction row, {
    required _is.ColumnSelections<SolanaWalletTransactionTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SolanaWalletTransaction>(
      row,
      conflictColumns: conflictColumns(SolanaWalletTransaction.t),
      updateColumns: updateColumns?.call(SolanaWalletTransaction.t),
      updateWhere: updateWhere?.call(SolanaWalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletTransaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletTransaction>> update(
    _is.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _is.ColumnSelections<SolanaWalletTransactionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SolanaWalletTransaction>(
      rows,
      columns: columns?.call(SolanaWalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SolanaWalletTransaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletTransaction> updateRow(
    _is.DatabaseSession session,
    SolanaWalletTransaction row, {
    _is.ColumnSelections<SolanaWalletTransactionTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SolanaWalletTransactionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletTransaction>(
      id,
      columnValues: columnValues(SolanaWalletTransaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletTransaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletTransaction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SolanaWalletTransactionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SolanaWalletTransaction>(
      columnValues: columnValues(SolanaWalletTransaction.t.updateTable),
      where: where(SolanaWalletTransaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SolanaWalletTransaction]s in the list and returns the deleted rows.
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
  Future<List<SolanaWalletTransaction>> delete(
    _is.DatabaseSession session,
    List<SolanaWalletTransaction> rows, {
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SolanaWalletTransaction>(
      rows,
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SolanaWalletTransaction].
  Future<SolanaWalletTransaction> deleteRow(
    _is.DatabaseSession session,
    SolanaWalletTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletTransaction>(
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
  Future<List<SolanaWalletTransaction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    _is.OrderByBuilder<SolanaWalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SolanaWalletTransaction>(
      where: where(SolanaWalletTransaction.t),
      orderBy: orderBy?.call(SolanaWalletTransaction.t),
      orderByList: orderByList?.call(SolanaWalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletTransactionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletTransaction>(
      where: where?.call(SolanaWalletTransaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWalletTransaction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletTransactionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWalletTransaction>(
      where: where(SolanaWalletTransaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
