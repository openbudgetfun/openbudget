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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../common/confidence.dart' as _itaosqa4;

/// A parsed on-chain transaction that touched a wallet.
abstract class WalletTransaction
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletTransaction._({
    this.id,
    required this.walletId,
    required this.network,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletTransaction({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletTransactionImpl;

  factory WalletTransaction.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletTransaction(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      signature: jsonSerialization['signature'] as String,
      slot: jsonSerialization['slot'] as int,
      occurredAt: jsonSerialization['occurredAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['occurredAt'],
            ),
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
          : _irkl4crj.Protocol().deserialize<List<String>>(
              jsonSerialization['tags'],
            ),
      memo: jsonSerialization['memo'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue walletId;

  /// The network the transaction is on.
  _ifz8weqz.WalletNetwork network;

  /// The transaction id: a Solana signature, an EVM or Tron hash, a Bitcoin
  /// txid or an XRP Ledger hash.
  String signature;

  /// Solana slot, block height or ledger index; orders transactions within
  /// one network.
  int slot;

  DateTime? occurredAt;

  String description;

  /// The provider's transaction type vocabulary, such as Helius `SWAP`.
  /// External vocabulary.
  String txType;

  /// The provider's source vocabulary, such as Helius `JUPITER`. External
  /// vocabulary.
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

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [WalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletTransaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    String? signature,
    int? slot,
    DateTime? occurredAt = const _isc.$UndefinedDateTime(),
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
    List<String>? tags = const _isc.$UndefinedList<String>(),
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
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

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletTransaction',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletTransactionImpl extends WalletTransaction {
  _WalletTransactionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         network: network,
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
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WalletTransaction]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletTransaction copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    String? signature,
    int? slot,
    DateTime? occurredAt = const _isc.$UndefinedDateTime(),
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
    List<String>? tags = const _isc.$UndefinedList<String>(),
    Object? memo = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      network: network ?? this.network,
      signature: signature ?? this.signature,
      slot: slot ?? this.slot,
      occurredAt: occurredAt is _isc.UndefinedSentinel
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
      tags: tags is _isc.UndefinedSentinel
          ? this.tags?.map((e0) => e0).toList()
          : tags,
      memo: memo is String? ? memo : this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
