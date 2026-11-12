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

import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

import '../common/confidence.dart' as _itaosqa4;

/// A parsed on-chain transaction that touched a wallet.
abstract class WalletTransaction
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WalletTransaction._({
    this.id,
    required this.walletId,
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
    this.pnlCurrencyCode,
    this.costBasisMinor,
    this.proceedsMinor,
    this.realizedPnlMinor,
    this.category,
    this.tags,
    this.memo,
    this.rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletTransaction({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required String signature,
    required int slot,
    DateTime? occurredAt,
    required String description,
    required String txType,
    required String source,
    _itaosqa4.Confidence? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    String? pnlCurrencyCode,
    int? costBasisMinor,
    int? proceedsMinor,
    int? realizedPnlMinor,
    String? category,
    List<String>? tags,
    String? memo,
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletTransactionImpl;

  factory WalletTransaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
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
          jsonSerialization['interpretationConfidence'] == null
          ? null
          : _itaosqa4.Confidence.fromJson(
              (jsonSerialization['interpretationConfidence'] as String),
            ),
      programsJson: jsonSerialization['programsJson'] as String?,
      nativeTransfersJson: jsonSerialization['nativeTransfersJson'] as String?,
      tokenTransfersJson: jsonSerialization['tokenTransfersJson'] as String?,
      pnlCurrencyCode: jsonSerialization['pnlCurrencyCode'] as String?,
      costBasisMinor: jsonSerialization['costBasisMinor'] as int?,
      proceedsMinor: jsonSerialization['proceedsMinor'] as int?,
      realizedPnlMinor: jsonSerialization['realizedPnlMinor'] as int?,
      category: jsonSerialization['category'] as String?,
      tags: jsonSerialization['tags'] == null
          ? null
          : _is0sbm8r.Protocol().deserialize<List<String>>(
              jsonSerialization['tags'],
            ),
      memo: jsonSerialization['memo'] as String?,
      rawJson: jsonSerialization['rawJson'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = WalletTransactionTable();

  static const db = WalletTransactionRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletId;

  String signature;

  int slot;

  DateTime? occurredAt;

  String description;

  /// Helius transaction type, such as `SWAP`. External vocabulary.
  String txType;

  /// Helius source, such as `JUPITER`. External vocabulary.
  String source;

  _itaosqa4.Confidence? interpretationConfidence;

  /// JSON list of program ids the transaction invoked.
  String? programsJson;

  String? nativeTransfersJson;

  String? tokenTransfersJson;

  /// ISO 4217 code of the three estimates below.
  String? pnlCurrencyCode;

  int? costBasisMinor;

  int? proceedsMinor;

  int? realizedPnlMinor;

  /// User-managed classification.
  String? category;

  List<String>? tags;

  String? memo;

  /// Raw enhanced transaction payload from Helius.
  String? rawJson;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    String? signature,
    int? slot,
    DateTime? occurredAt = const _is.$UndefinedDateTime(),
    String? description,
    String? txType,
    String? source,
    _itaosqa4.Confidence? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    String? pnlCurrencyCode,
    int? costBasisMinor,
    int? proceedsMinor,
    int? realizedPnlMinor,
    String? category,
    List<String>? tags = const _is.$UndefinedList<String>(),
    String? memo,
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'signature': signature,
      'slot': slot,
      if (occurredAt != null) 'occurredAt': occurredAt?.toJson(),
      'description': description,
      'txType': txType,
      'source': source,
      if (interpretationConfidence != null)
        'interpretationConfidence': interpretationConfidence?.toJson(),
      if (programsJson != null) 'programsJson': programsJson,
      if (nativeTransfersJson != null)
        'nativeTransfersJson': nativeTransfersJson,
      if (tokenTransfersJson != null) 'tokenTransfersJson': tokenTransfersJson,
      if (pnlCurrencyCode != null) 'pnlCurrencyCode': pnlCurrencyCode,
      if (costBasisMinor != null) 'costBasisMinor': costBasisMinor,
      if (proceedsMinor != null) 'proceedsMinor': proceedsMinor,
      if (realizedPnlMinor != null) 'realizedPnlMinor': realizedPnlMinor,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags?.toJson(),
      if (memo != null) 'memo': memo,
      if (rawJson != null) 'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'signature': signature,
      'slot': slot,
      if (occurredAt != null) 'occurredAt': occurredAt?.toJson(),
      'description': description,
      'txType': txType,
      'source': source,
      if (interpretationConfidence != null)
        'interpretationConfidence': interpretationConfidence?.toJson(),
      if (programsJson != null) 'programsJson': programsJson,
      if (nativeTransfersJson != null)
        'nativeTransfersJson': nativeTransfersJson,
      if (tokenTransfersJson != null) 'tokenTransfersJson': tokenTransfersJson,
      if (pnlCurrencyCode != null) 'pnlCurrencyCode': pnlCurrencyCode,
      if (costBasisMinor != null) 'costBasisMinor': costBasisMinor,
      if (proceedsMinor != null) 'proceedsMinor': proceedsMinor,
      if (realizedPnlMinor != null) 'realizedPnlMinor': realizedPnlMinor,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags?.toJson(),
      if (memo != null) 'memo': memo,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static WalletTransactionInclude include() {
    return WalletTransactionInclude._();
  }

  static WalletTransactionIncludeList includeList({
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    WalletTransactionInclude? include,
  }) {
    return WalletTransactionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletTransactionImpl extends WalletTransaction {
  _WalletTransactionImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required String signature,
    required int slot,
    DateTime? occurredAt,
    required String description,
    required String txType,
    required String source,
    _itaosqa4.Confidence? interpretationConfidence,
    String? programsJson,
    String? nativeTransfersJson,
    String? tokenTransfersJson,
    String? pnlCurrencyCode,
    int? costBasisMinor,
    int? proceedsMinor,
    int? realizedPnlMinor,
    String? category,
    List<String>? tags,
    String? memo,
    String? rawJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
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
         pnlCurrencyCode: pnlCurrencyCode,
         costBasisMinor: costBasisMinor,
         proceedsMinor: proceedsMinor,
         realizedPnlMinor: realizedPnlMinor,
         category: category,
         tags: tags,
         memo: memo,
         rawJson: rawJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletTransaction copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
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
    Object? pnlCurrencyCode = _Undefined,
    Object? costBasisMinor = _Undefined,
    Object? proceedsMinor = _Undefined,
    Object? realizedPnlMinor = _Undefined,
    Object? category = _Undefined,
    List<String>? tags = const _is.$UndefinedList<String>(),
    Object? memo = _Undefined,
    Object? rawJson = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id is _is.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      signature: signature ?? this.signature,
      slot: slot ?? this.slot,
      occurredAt: occurredAt is _is.UndefinedSentinel
          ? this.occurredAt
          : occurredAt,
      description: description ?? this.description,
      txType: txType ?? this.txType,
      source: source ?? this.source,
      interpretationConfidence:
          interpretationConfidence is _itaosqa4.Confidence?
          ? interpretationConfidence
          : this.interpretationConfidence,
      programsJson: programsJson is String? ? programsJson : this.programsJson,
      nativeTransfersJson: nativeTransfersJson is String?
          ? nativeTransfersJson
          : this.nativeTransfersJson,
      tokenTransfersJson: tokenTransfersJson is String?
          ? tokenTransfersJson
          : this.tokenTransfersJson,
      pnlCurrencyCode: pnlCurrencyCode is String?
          ? pnlCurrencyCode
          : this.pnlCurrencyCode,
      costBasisMinor: costBasisMinor is int?
          ? costBasisMinor
          : this.costBasisMinor,
      proceedsMinor: proceedsMinor is int? ? proceedsMinor : this.proceedsMinor,
      realizedPnlMinor: realizedPnlMinor is int?
          ? realizedPnlMinor
          : this.realizedPnlMinor,
      category: category is String? ? category : this.category,
      tags: tags is _is.UndefinedSentinel
          ? this.tags?.map((e0) => e0).toList()
          : tags,
      memo: memo is String? ? memo : this.memo,
      rawJson: rawJson is String? ? rawJson : this.rawJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WalletTransactionUpdateTable
    extends _is.UpdateTable<WalletTransactionTable> {
  WalletTransactionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.walletId,
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

  _is.ColumnValue<_itaosqa4.Confidence, _itaosqa4.Confidence>
  interpretationConfidence(_itaosqa4.Confidence? value) => _is.ColumnValue(
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

  _is.ColumnValue<String, String> pnlCurrencyCode(String? value) =>
      _is.ColumnValue(
        table.pnlCurrencyCode,
        value,
      );

  _is.ColumnValue<int, int> costBasisMinor(int? value) => _is.ColumnValue(
    table.costBasisMinor,
    value,
  );

  _is.ColumnValue<int, int> proceedsMinor(int? value) => _is.ColumnValue(
    table.proceedsMinor,
    value,
  );

  _is.ColumnValue<int, int> realizedPnlMinor(int? value) => _is.ColumnValue(
    table.realizedPnlMinor,
    value,
  );

  _is.ColumnValue<String, String> category(String? value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<List<String>, List<String>> tags(List<String>? value) =>
      _is.ColumnValue(
        table.tags,
        value,
      );

  _is.ColumnValue<String, String> memo(String? value) => _is.ColumnValue(
    table.memo,
    value,
  );

  _is.ColumnValue<String, String> rawJson(String? value) => _is.ColumnValue(
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

class WalletTransactionTable extends _is.Table<_is.UuidValue?> {
  WalletTransactionTable({super.tableRelation})
    : super(tableName: 'wallet_transaction') {
    updateTable = WalletTransactionUpdateTable(this);
    walletId = _is.ColumnUuid(
      'walletId',
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
    interpretationConfidence = _is.ColumnEnum(
      'interpretationConfidence',
      this,
      _is.EnumSerialization.byName,
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
    pnlCurrencyCode = _is.ColumnString(
      'pnlCurrencyCode',
      this,
    );
    costBasisMinor = _is.ColumnInt(
      'costBasisMinor',
      this,
    );
    proceedsMinor = _is.ColumnInt(
      'proceedsMinor',
      this,
    );
    realizedPnlMinor = _is.ColumnInt(
      'realizedPnlMinor',
      this,
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    tags = _is.ColumnSerializable<List<String>>(
      'tags',
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

  late final WalletTransactionUpdateTable updateTable;

  late final _is.ColumnUuid walletId;

  late final _is.ColumnString signature;

  late final _is.ColumnInt slot;

  late final _is.ColumnDateTime occurredAt;

  late final _is.ColumnString description;

  /// Helius transaction type, such as `SWAP`. External vocabulary.
  late final _is.ColumnString txType;

  /// Helius source, such as `JUPITER`. External vocabulary.
  late final _is.ColumnString source;

  late final _is.ColumnEnum<_itaosqa4.Confidence> interpretationConfidence;

  /// JSON list of program ids the transaction invoked.
  late final _is.ColumnString programsJson;

  late final _is.ColumnString nativeTransfersJson;

  late final _is.ColumnString tokenTransfersJson;

  /// ISO 4217 code of the three estimates below.
  late final _is.ColumnString pnlCurrencyCode;

  late final _is.ColumnInt costBasisMinor;

  late final _is.ColumnInt proceedsMinor;

  late final _is.ColumnInt realizedPnlMinor;

  /// User-managed classification.
  late final _is.ColumnString category;

  late final _is.ColumnSerializable<List<String>> tags;

  late final _is.ColumnString memo;

  /// Raw enhanced transaction payload from Helius.
  late final _is.ColumnString rawJson;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    walletId,
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
    pnlCurrencyCode,
    costBasisMinor,
    proceedsMinor,
    realizedPnlMinor,
    category,
    tags,
    memo,
    rawJson,
    createdAt,
    updatedAt,
  ];
}

class WalletTransactionInclude extends _is.IncludeObject {
  WalletTransactionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletTransaction.t;
}

class WalletTransactionIncludeList extends _is.IncludeList {
  WalletTransactionIncludeList._({
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletTransaction.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletTransaction.t;
}

class WalletTransactionRepository {
  const WalletTransactionRepository._();

  /// Returns a list of [WalletTransaction]s matching the given query parameters.
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
  Future<List<WalletTransaction>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletTransaction>(
      where: where?.call(WalletTransaction.t),
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [WalletTransaction]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `WalletTransaction.t`.
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
  _ida.Stream<List<WalletTransaction>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<WalletTransaction>(
      where: where?.call(WalletTransaction.t),
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [WalletTransaction] matching the given query parameters.
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
  Future<WalletTransaction?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletTransaction>(
      where: where?.call(WalletTransaction.t),
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletTransaction] by its [id] or null if no such row exists.
  Future<WalletTransaction?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WalletTransaction>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WalletTransaction]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletTransaction]s will have their `id` fields set.
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
  Future<List<WalletTransaction>> insert(
    _is.DatabaseSession session,
    List<WalletTransaction> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WalletTransaction>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WalletTransaction] and returns the inserted row.
  ///
  /// The returned [WalletTransaction] will have its `id` field set.
  Future<WalletTransaction> insertRow(
    _is.DatabaseSession session,
    WalletTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletTransaction>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WalletTransaction]s in the list and returns the resulting rows.
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
  /// The returned [WalletTransaction]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletTransaction>> upsert(
    _is.DatabaseSession session,
    List<WalletTransaction> rows, {
    required _is.ColumnSelections<WalletTransactionTable> conflictColumns,
    _is.ColumnSelections<WalletTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletTransactionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WalletTransaction>(
      rows,
      conflictColumns: conflictColumns(WalletTransaction.t),
      updateColumns: updateColumns?.call(WalletTransaction.t),
      updateWhere: updateWhere?.call(WalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WalletTransaction] and returns the resulting row.
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
  /// The returned [WalletTransaction] will have its `id` field set.
  Future<WalletTransaction?> upsertRow(
    _is.DatabaseSession session,
    WalletTransaction row, {
    required _is.ColumnSelections<WalletTransactionTable> conflictColumns,
    _is.ColumnSelections<WalletTransactionTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletTransactionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WalletTransaction>(
      row,
      conflictColumns: conflictColumns(WalletTransaction.t),
      updateColumns: updateColumns?.call(WalletTransaction.t),
      updateWhere: updateWhere?.call(WalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates all [WalletTransaction]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletTransaction>> update(
    _is.DatabaseSession session,
    List<WalletTransaction> rows, {
    _is.ColumnSelections<WalletTransactionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WalletTransaction>(
      rows,
      columns: columns?.call(WalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WalletTransaction]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletTransaction> updateRow(
    _is.DatabaseSession session,
    WalletTransaction row, {
    _is.ColumnSelections<WalletTransactionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WalletTransaction>(
      row,
      columns: columns?.call(WalletTransaction.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletTransaction] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WalletTransaction?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletTransactionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletTransaction>(
      id,
      columnValues: columnValues(WalletTransaction.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletTransaction]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletTransaction>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletTransactionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<WalletTransactionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WalletTransaction>(
      columnValues: columnValues(WalletTransaction.t.updateTable),
      where: where(WalletTransaction.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WalletTransaction]s in the list and returns the deleted rows.
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
  Future<List<WalletTransaction>> delete(
    _is.DatabaseSession session,
    List<WalletTransaction> rows, {
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WalletTransaction>(
      rows,
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WalletTransaction].
  Future<WalletTransaction> deleteRow(
    _is.DatabaseSession session,
    WalletTransaction row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletTransaction>(
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
  Future<List<WalletTransaction>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletTransactionTable> where,
    _is.OrderByBuilder<WalletTransactionTable>? orderBy,
    _is.OrderByListBuilder<WalletTransactionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WalletTransaction>(
      where: where(WalletTransaction.t),
      orderBy: orderBy?.call(WalletTransaction.t),
      orderByList: orderByList?.call(WalletTransaction.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletTransactionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WalletTransaction>(
      where: where?.call(WalletTransaction.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletTransaction] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletTransactionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletTransaction>(
      where: where(WalletTransaction.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
