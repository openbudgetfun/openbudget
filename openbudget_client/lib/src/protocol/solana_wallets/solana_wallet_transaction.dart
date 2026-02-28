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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A parsed Solana transaction associated with a wallet.
abstract class SolanaWalletTransaction implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
      if (category != null) 'category': category,
      if (tagsCsv != null) 'tagsCsv': tagsCsv,
      if (memo != null) 'memo': memo,
      'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
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
      category: category is String? ? category : this.category,
      tagsCsv: tagsCsv is String? ? tagsCsv : this.tagsCsv,
      memo: memo is String? ? memo : this.memo,
      rawJson: rawJson ?? this.rawJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
