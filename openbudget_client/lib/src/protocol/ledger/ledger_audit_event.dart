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

/// One audit trail entry for a budget's books.
///
/// Every post, reversal, lock change and accounting-mode switch writes one
/// row: who did what, when, with a JSON payload of the details. Rows are
/// never updated or deleted.
abstract class LedgerAuditEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LedgerAuditEvent._({
    this.id,
    required this.budgetId,
    required this.actor,
    required this.action,
    this.entity,
    this.entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) : payloadJson = payloadJson ?? '{}',
       createdAt = createdAt ?? DateTime.now();

  factory LedgerAuditEvent({
    int? id,
    required _isc.UuidValue budgetId,
    required _isc.UuidValue actor,
    required String action,
    String? entity,
    _isc.UuidValue? entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) = _LedgerAuditEventImpl;

  factory LedgerAuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return LedgerAuditEvent(
      id: jsonSerialization['id'] as int?,
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      actor: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['actor']),
      action: jsonSerialization['action'] as String,
      entity: jsonSerialization['entity'] as String?,
      entityId: jsonSerialization['entityId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['entityId']),
      payloadJson: jsonSerialization['payloadJson'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue budgetId;

  /// The acting user, or the system identity for automated actions.
  _isc.UuidValue actor;

  /// Stable action name, such as `journal.posted` or `lock.set`.
  String action;

  /// The affected entity kind, such as `journal`, when there is one.
  String? entity;

  /// The affected entity's id, when there is one.
  _isc.UuidValue? entityId;

  /// JSON payload with the action's details.
  String payloadJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [LedgerAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LedgerAuditEvent copyWith({
    int? id,
    _isc.UuidValue? budgetId,
    _isc.UuidValue? actor,
    String? action,
    String? entity,
    _isc.UuidValue? entityId = const _isc.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LedgerAuditEvent',
      if (id != null) 'id': id,
      'budgetId': budgetId.toJson(),
      'actor': actor.toJson(),
      'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entityId': entityId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LedgerAuditEvent',
      if (id != null) 'id': id,
      'budgetId': budgetId.toJson(),
      'actor': actor.toJson(),
      'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entityId': entityId?.toJson(),
      'payloadJson': payloadJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LedgerAuditEventImpl extends LedgerAuditEvent {
  _LedgerAuditEventImpl({
    int? id,
    required _isc.UuidValue budgetId,
    required _isc.UuidValue actor,
    required String action,
    String? entity,
    _isc.UuidValue? entityId,
    String? payloadJson,
    DateTime? createdAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         actor: actor,
         action: action,
         entity: entity,
         entityId: entityId,
         payloadJson: payloadJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [LedgerAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LedgerAuditEvent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? budgetId,
    _isc.UuidValue? actor,
    String? action,
    Object? entity = _Undefined,
    _isc.UuidValue? entityId = const _isc.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? createdAt,
  }) {
    return LedgerAuditEvent(
      id: id is int? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      entity: entity is String? ? entity : this.entity,
      entityId: entityId is _isc.UndefinedSentinel ? this.entityId : entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
