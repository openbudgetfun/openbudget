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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../agent/agent_provider.dart' as _ice504k4;

/// Token usage and cost of one model call.
abstract class AgentUsageRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentUsageRecord._({
    this.id,
    required this.userId,
    this.conversationId,
    required this.provider,
    required this.model,
    required this.promptTokens,
    required this.cachedTokens,
    required this.completionTokens,
    required this.costMicroUsd,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentUsageRecord({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    _isc.UuidValue? conversationId,
    required _ice504k4.AgentProvider provider,
    required String model,
    required int promptTokens,
    required int cachedTokens,
    required int completionTokens,
    required int costMicroUsd,
    DateTime? createdAt,
  }) = _AgentUsageRecordImpl;

  factory AgentUsageRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentUsageRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['conversationId'],
            ),
      provider: _ice504k4.AgentProvider.fromJson(
        (jsonSerialization['provider'] as String),
      ),
      model: jsonSerialization['model'] as String,
      promptTokens: jsonSerialization['promptTokens'] as int,
      cachedTokens: jsonSerialization['cachedTokens'] as int,
      completionTokens: jsonSerialization['completionTokens'] as int,
      costMicroUsd: jsonSerialization['costMicroUsd'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  _isc.UuidValue? conversationId;

  _ice504k4.AgentProvider provider;

  String model;

  int promptTokens;

  /// Prompt tokens served from the provider's cache.
  int cachedTokens;

  int completionTokens;

  /// Cost in micro-dollars. BYO calls are recorded at zero.
  int costMicroUsd;

  DateTime createdAt;

  /// Returns a shallow copy of this [AgentUsageRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentUsageRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? conversationId = const _isc.$UndefinedUuidValue(),
    _ice504k4.AgentProvider? provider,
    String? model,
    int? promptTokens,
    int? cachedTokens,
    int? completionTokens,
    int? costMicroUsd,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentUsageRecord',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'provider': provider.toJson(),
      'model': model,
      'promptTokens': promptTokens,
      'cachedTokens': cachedTokens,
      'completionTokens': completionTokens,
      'costMicroUsd': costMicroUsd,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentUsageRecord',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'provider': provider.toJson(),
      'model': model,
      'promptTokens': promptTokens,
      'cachedTokens': cachedTokens,
      'completionTokens': completionTokens,
      'costMicroUsd': costMicroUsd,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AgentUsageRecordImpl extends AgentUsageRecord {
  _AgentUsageRecordImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    _isc.UuidValue? conversationId,
    required _ice504k4.AgentProvider provider,
    required String model,
    required int promptTokens,
    required int cachedTokens,
    required int completionTokens,
    required int costMicroUsd,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         conversationId: conversationId,
         provider: provider,
         model: model,
         promptTokens: promptTokens,
         cachedTokens: cachedTokens,
         completionTokens: completionTokens,
         costMicroUsd: costMicroUsd,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AgentUsageRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentUsageRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? conversationId = const _isc.$UndefinedUuidValue(),
    _ice504k4.AgentProvider? provider,
    String? model,
    int? promptTokens,
    int? cachedTokens,
    int? completionTokens,
    int? costMicroUsd,
    DateTime? createdAt,
  }) {
    return AgentUsageRecord(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      conversationId: conversationId is _isc.UndefinedSentinel
          ? this.conversationId
          : conversationId,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      promptTokens: promptTokens ?? this.promptTokens,
      cachedTokens: cachedTokens ?? this.cachedTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      costMicroUsd: costMicroUsd ?? this.costMicroUsd,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
